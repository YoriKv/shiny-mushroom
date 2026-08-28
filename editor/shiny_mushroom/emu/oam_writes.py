"""Which OAM bytes a sprite's own code wrote, read out of a trace of the probe.

A sprite's appearance exists only as code, so the probe in
:mod:`shiny_mushroom.emu.smw` runs that code and reads the OAM buffer back. What
that leaves open is which of the 64 entries the sprite actually filled, and the
buffer alone cannot say: every byte holds *something*, and an entry the sprite
never touched looks exactly like one it did.

Filling the buffer with a sentinel first and treating anything else as drawn is
the obvious answer and an unsound one. ``$E0`` is a Y coordinate the game itself
parks tiles at, so a sprite that legitimately draws there vanishes; and a
sentinel says nothing about the bytes a sprite left alone *inside* an entry it
did touch, which read back as tile ``$E0`` of palette 8, flipped both ways.

Watching the stores answers it directly, the way
:mod:`shiny_mushroom.emu.footprints` answers the same question for objects.

**This is provenance, not values.** The rows say which addresses the sprite's
code wrote, and the values are still read out of memory afterwards: the trace
logger's ``[MemoryValue]`` column comes back empty for this core, on loads as
well as stores, so there is nothing to read them from here.

**The OAM buffer is in the low-RAM mirror, and that changes the address test.**
``$7E0300`` sits inside the ``$0000``-``$1FFF`` window every bank ``$00``-``$3F``
shares, so the effective address a row reports carries whichever data bank the
sprite code happened to hold -- measured, ``$01``, ``$02`` and ``$03``, never
``$7E``. Footprints can compare against a whole ``$7Exxxx`` address because the
Map16 tilemap at ``$7EC800`` is above the mirror and unreachable any other way;
copying that shape here matches nothing at all. The comparison has to be on the
low 16 bits, and getting it wrong is silent -- no row matches, the sprite
reports no tiles, and "no tiles" is exactly what a sprite that cannot draw
legitimately returns.

**And how low RAM is spelled is a fact about the base, so the base answers it.**
Under SA-1 Pack the same instruction at the same address stores to ``$6300,y``
where a console's stores to ``$0300,y`` -- the BW-RAM window rather than the
mirror. That is not a variation this module should know the shape of; it asks
:meth:`~smw_tools.ram_map.RamMap.low_ram_offset`, whose answer is always a
**vanilla** offset, so everything downstream keeps naming bytes one way.
"""

from __future__ import annotations

from collections.abc import Iterable

# `COLUMNS` is re-exported rather than defined here: a caller asks this module
# for the whole recipe -- condition, columns, parse -- and `emu.trace` is where
# the format both of this package's parses read is settled.
from shiny_mushroom.emu.trace import COLUMNS as COLUMNS
from shiny_mushroom.emu.trace import pc_range, rows
from smw_tools.ram_map import RamMap, WorkRam

#: What a base that keeps low RAM where a console does answers. The default, so
#: a caller with no base in hand -- a test, a cartridge opened by hand -- reads
#: a vanilla trace without having to construct one.
_DEFAULT_MAP = WorkRam()


def condition(sprite_gfx: tuple[int, int]) -> str:
    """The trace filter for one base's sprite GFX code.

    ``sprite_gfx`` is that base's declared range --
    :attr:`~smw_tools.bases.TracedCode.sprite_gfx`, which is where the reason
    for those banks and not others is written down. A *declaration* because a
    bank range has no label to resolve through, and one that named the wrong
    code would fail silently: no row matches, the sprite reports no tiles, and
    "no tiles" is exactly what a sprite that cannot draw legitimately returns.
    """
    return pc_range(sprite_gfx)


def parse(lines: Iterable[str], ram: RamMap = _DEFAULT_MAP) -> frozenset[int]:
    """Every low-RAM offset the traced code stored to.

    ``lines`` is the trace file and ``ram`` the base's RAM map. The result is
    offsets from ``$7E0000``, the same numbering :mod:`shiny_mushroom.emu.smw`
    uses for work RAM, so a caller tests membership against its own table
    addresses rather than having them defined twice -- and gets the same numbers
    back whichever base the trace came off.

    Unfiltered beyond that on purpose: which tables matter is the caller's
    question, and a probe's whole trace yields only a few hundred distinct
    offsets.
    """
    written: set[int] = set()
    for _counter, _mnemonic, address in rows(lines):
        if address is None:
            continue
        offset = ram.low_ram_offset(address)
        if offset is not None:
            written.add(offset)
    return frozenset(written)
