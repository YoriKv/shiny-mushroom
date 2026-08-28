"""Which blocks each object drew, two ways.

The object stream says where an object *starts*; only the `$01`-`$0E` family's
settings byte says how far it reaches, and for everything else -- slopes, pipes,
ledges -- the extent is whatever the object's routine decided. So the extent has
to be observed, and the only thing that can observe it is the loader itself.

**The core's write log is the path the editor takes** (`boundaries`,
`attribute_writes`, ~2 ms): the vendored core is patched
(`packaging/mesen-patches/0002-memory-write-log.patch`) to keep every write
into the tilemap range with its master clock, so overdraw is kept -- a block
drawn twice is in both objects' footprints. The plain access counters
(`attribute`) are the fallback for a core without the patch or a run that
overflowed the log, and differ in exactly one way, stated under the counters
below: a counter keeps one writer per address, so there a block drawn twice is
credited to the later object alone. The trace logger (`condition`, `parse`,
~70 ms) is what both were checked against and remains available as an oracle.

All three index their answer the same way -- one entry per record, in the
order the loop reached them, including the records that draw nothing -- so a
caller cannot tell which produced it.

**The trace is read in execution order, and nothing there reasons about time.**
That is not a simplification, it is a requirement: the trace's clock is the
CPU's cycle count and the memory counters' is the master clock, and the two
advance at a ratio that changes with every region the CPU touches. Order is the
one sound relation between two rows, and order is all it needs -- a row at the
loop head closes an object, and every store into the tilemap before the next one
belongs to the object that just finished. (The counter path never mixes the two
clocks either: both of its columns are the master clock.)

Two things fall out of that for free:

- **Last writer wins**, which is what a click wants: an object overdrawn by a
  later one keeps its own cells in the trace, and whoever asks resolves the
  overlap by taking the last object that claims a block.
- **The buffer fill excludes itself.** `SMW_InitializeLevelData` clears the
  tilemap to the empty tile before any object draws, and it lives in bank `$05`,
  outside `condition`'s range -- so its ~12,000 stores never enter the trace.
"""

from __future__ import annotations

from bisect import bisect_right
from collections.abc import Iterable

# `COLUMNS` is re-exported rather than defined here: the trace path is asked
# for as one recipe -- condition, columns, parse -- and `emu.trace` is where the
# format both of this package's parses read is settled.
from shiny_mushroom.emu.trace import COLUMNS as COLUMNS
from shiny_mushroom.emu.trace import pc_range, rows
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.rom_patches import record_offsets
from smw_tools.rom_tables import VANILLA_TABLES

#: ``SMW_LoadLevelDataObject_LevLoadContinue``. The object loop reaches it once
#: per record with that record's drawing already finished, so a row here means
#: "the object just ended" -- a cleaner boundary than the loop head, which fires
#: before the record has even been read, and one the records that draw nothing
#: (screen exit, screen jump) reach as well, so they get their own empty
#: footprint instead of merging into a neighbour.
#:
#: The default target's address: the trace path below is the oracle the counter
#: path was checked against, and it only ever runs over the default target. The
#: registry carries the per-target variants (``E1`` moves it), and the counter
#: path -- the editor's -- needs no code address at all.
LOOP_CONTINUE = VANILLA_TABLES["object_loop_continue"].address

#: What the loader writes a block's low byte to. The high byte is written to a
#: second table for the same block, so watching one of the two is enough to know
#: a block was drawn -- and halves the rows to sift.
MAP16_LOW = 0x7EC800
MAP16_LOW_END = 0x7EC800 + 0x3800


def condition(
    object_routines: tuple[int, int], loop_continue: int = LOOP_CONTINUE
) -> str:
    """The trace filter for one base's object routines, plus the loop boundary.

    ``object_routines`` is that base's declared range --
    :attr:`~smw_tools.bases.TracedCode.object_routines`, which is where the
    reason for the whole bank is written down. A *declaration* because a bank
    range has no label to resolve through, unlike ``loop_continue``, which is
    a role in :mod:`smw_tools.rom_tables` and moves with the build that moved
    it.

    **Deliberately this coarse.** The instruction fetch does carry the opcode
    byte as ``value``, so the 24 store opcodes *can* be named and the trace cut
    from 37,000 rows to 6,100 -- and doing so is twice as slow, because the
    condition is evaluated on every instruction the CPU executes and the
    expression evaluator does not short-circuit. Measured: 201 ms for this,
    420 for the explicit store list, 234 for the cheapest opcode mask. Sifting
    the rows in :func:`parse` is where that work belongs.
    """
    return f"({pc_range(object_routines)}) || opPc == {loop_continue}"


def parse(
    lines: Iterable[str], loop_continue: int = LOOP_CONTINUE
) -> list[frozenset[int]]:
    """Group a trace's tilemap stores into one set of offsets per object.

    ``lines`` is the trace file, in order, and ``loop_continue`` the boundary
    the trace was filtered with -- the same parameter :func:`condition` takes
    and for the same reason: on a target that moved the loop no row would match
    the default, and the answer would be a silent empty list rather than a
    failure.

    The result is indexed the same way the object stream is -- entry *n* is the
    *n*th record's blocks, as Map16 tilemap offsets -- so it lines up with
    :func:`shiny_mushroom.objects.parse_objects` without anything having to be
    matched up by position.

    Offsets rather than blocks, because turning one into a block needs the
    level's geometry and this does not have it. That is
    :meth:`shiny_mushroom.level.Geometry.block_at`.
    """
    footprints: list[frozenset[int]] = []
    pending: set[int] = set()
    for counter, _mnemonic, address in rows(lines):
        if counter == loop_continue:
            footprints.append(frozenset(pending))
            pending = set()
        elif address is not None and MAP16_LOW <= address < MAP16_LOW_END:
            pending.add(address - MAP16_LOW)
    return footprints


# -- the same answer, out of the access counters -----------------------------
#
# The trace above is a complete record of what the object loop did, and costs
# ~70 ms to obtain: Mesen disassembles every instruction it executes while the
# logger is on, and the rows have to be written and read back. The counters
# below give the same footprints for ~1.5 ms, because the core keeps them
# whether or not anyone looks.
#
# **The object stream's own bytes are the clock.** The loop reads record *n* out
# of ROM before drawing it and record *n+1* after, so the read stamps of the
# records are ordered boundaries on the master clock -- N records, N boundaries,
# with no hijack and nothing injected. The tilemap's write stamps are on that
# same clock, so which record was current when a block was written is a
# comparison rather than an inference.
#
# **What the one-stamp column cannot recover is overdraw.** A counter keeps one
# stamp per address, so a block drawn by one object and drawn over by a later
# one is credited to the later one alone: `attribute` reports what each object
# *left visible*, where the trace -- and `attribute_writes` over the patched
# core's write log -- reports what it *drew*. It never claims a block the trace
# does not, and the effect on the editor, when the fallback is what ran, is
# that an object buried entirely under later ones comes back with an empty
# footprint -- which every reader already treats as "no trace for this one" and
# falls back to the record's own rectangle for.


class NotObserved(RuntimeError):
    """The counters do not describe a run of this stream, so nothing is claimed.

    Raised rather than guessed at, and it catches a real blind spot the trace
    path has silently: the stream an editor resolves through the pointer table
    is not necessarily the one a given load walked. Where that happens the
    records' read stamps are zero or out of order, and refusing is the only
    honest answer -- the trace path, given the same mismatch, reports a
    footprint list matched against the wrong stream.
    """


def boundaries(
    read_stamps, streams: Iterable[tuple[int, bytes]]
) -> list[tuple[int, bool]]:
    """Each record's place on the master clock, as ``(stamp, is a record)``.

    ``read_stamps`` is called with ``(rom offset, length)`` and returns that
    slice of the ROM's read-stamp column; ``streams`` is the Layer 1 stream
    always and Layer 2's as well when it is objects rather than a background,
    because the loop runs once per layer.

    A stream that is nothing but its terminator contributes nothing: there is no
    record to attribute anything to, and the loader does not stamp a read on it,
    so demanding one would refuse a level that genuinely draws no objects.
    """
    found: list[tuple[int, bool]] = []
    for base, stream in streams:
        offsets = record_offsets(stream)
        if len(offsets) < 2:
            continue
        column = read_stamps(base, offsets[-1] + 1)
        previous = 0
        for at in offsets:
            stamp = column[at]
            if stamp == 0:
                raise NotObserved(
                    f"the byte at {hexnum(base + at, 6)} was never read, so this load "
                    f"did not walk the stream these offsets describe"
                )
            if stamp < previous:
                raise NotObserved(
                    f"the record at {hexnum(base + at, 6)} was read before the one in "
                    f"front of it, so something other than the loop read it"
                )
            previous = stamp
            found.append((stamp, at != offsets[-1]))
    found.sort()
    return found


def attribute(write_stamps, bounds: list[tuple[int, bool]]) -> list[frozenset[int]]:
    """Bucket each written tilemap offset by the record whose window it fell in.

    ``write_stamps`` is the counters' write-stamp column, indexed by offset --
    one stamp per address, so a cell drawn twice is credited to the later
    record alone. :func:`attribute_writes` is the same bucketing without that
    loss, for a core whose write log is available.
    """
    return attribute_writes(enumerate(write_stamps), bounds)


def attribute_writes(
    writes: Iterable[tuple[int, int]], bounds: list[tuple[int, bool]]
) -> list[frozenset[int]]:
    """Bucket every ``(offset, stamp)`` write by the record whose window it hit.

    Indexed exactly the way :func:`parse` is -- one entry per record, in the
    order the loop reached them, including the records that draw nothing -- so
    the two are interchangeable to a caller. Unlike :func:`attribute`'s one
    stamp per address, ``writes`` may carry the same offset many times, so a
    cell drawn by one object and drawn over by a later one lands in both
    records' footprints -- this is the overdraw the counters cannot keep.

    The first boundary excludes ``SMW_InitializeLevelData``'s buffer fill, which
    runs before any record is read; the last excludes whatever the frame after
    the loop does. :func:`parse` drops both for the same reason: there is no
    record either belongs to.
    """
    if not bounds:
        return []
    edges = [stamp for stamp, _ in bounds]
    first, last = edges[0], edges[-1]
    buckets: list[set[int]] = [set() for _ in bounds]
    for offset, stamp in writes:
        if first <= stamp < last:
            buckets[bisect_right(edges, stamp) - 1].add(offset)
    return [
        frozenset(cells)
        for cells, (_, is_record) in zip(buckets, bounds, strict=True)
        if is_record
    ]
