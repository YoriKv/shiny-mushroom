"""Where each RAM-map entry lives, and how many bytes it owns.

What the layout is for: **a 16-bit access names one entry and touches two.**
``STA.W !RAM_SMW_Misc_GameMode`` with a 16-bit accumulator also writes whatever
sits one byte above, and no name-keyed index can see that, because the second
address appears in no operand. Knowing which entry follows is what turns that
store into a write of both.

Addresses come from the map itself -- every entry is `!Name #= $address`, some
relative to an earlier one -- resolved by
:func:`smw_tools.address_index._memory_label_locations`, which is the single place
that arithmetic lives so two callers cannot disagree about it.

**Size is inferred, not declared.** This map states addresses and nothing else,
so an entry is treated as owning the bytes up to the next address in use. That
is exactly the question the overrun analysis asks -- "what does the second byte
land in" -- but it is an inference: entries that share an address (mirrors, or a
region marker above the entry that really occupies it) yield a size of zero, and
the highest entry of each address space has no successor to bound it.

No build required; this reads the source.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .bases import RomBase


@dataclass(frozen=True)
class MemEntry:
    name: str
    #: Path relative to src/, as `SMW/Memory/WRAM_Stack.asm`.
    file: str
    #: 1-indexed line of the `!Name #= $address` define.
    line: int
    #: 24-bit address.
    addr: int
    #: Bytes of storage, inferred as the gap to the next address in use. Zero
    #: means two entries share an address -- a mirror, or a region marker above
    #: the entry that really occupies it -- and only one of them is the
    #: occupant.
    size: int


@dataclass
class MemoryLayout:
    entries: dict[str, MemEntry] = field(default_factory=dict)
    #: entry -> the entry one address below it, where the two are adjacent. A
    #: 16-bit access to that neighbour runs one byte past its own storage and
    #: lands here.
    covered_by: dict[str, str] = field(default_factory=dict)


def build_memory_layout(base: RomBase | None = None) -> MemoryLayout:
    """Every entry of ``base``'s RAM map, with the storage each one owns.

    Base-dependent even though the *ordering* is not: which entry sits above
    another is a property of the map file, but a base that relocates part of it
    interleaves the moved range with whatever it landed among -- so a neighbour
    computed on the wrong base names the wrong victim.
    """
    # Imported here rather than at module scope: address_index pulls in the code
    # graph, and only this function needs it.
    from .address_index import _memory_label_locations  # noqa: PLC0415

    layout = MemoryLayout()
    located = _memory_label_locations(base)
    if not located:
        return layout

    # **One number line per address space.** Work RAM, SRAM and the register
    # file are separate memories that share a range of numbers, so sorting them
    # together makes the entry above the top of one the entry below the bottom
    # of the next -- and reports a 16-bit store to the last work-RAM byte as
    # landing in a save file.
    by_space: dict[str, list[tuple[int, str, str, int]]] = {}
    for name, (file, line, space, addr) in located.items():
        by_space.setdefault(space, []).append((addr, name, file, line))

    for rows in by_space.values():
        # Ordered by address so "what follows" is a lookup rather than a search.
        # Ties keep source order, which puts a region marker ahead of the entry
        # that really occupies the address.
        ordered = sorted(rows, key=lambda t: t[0])

        for i, (addr, name, file, line) in enumerate(ordered):
            nxt = ordered[i + 1][0] if i + 1 < len(ordered) else None
            # Size is the gap to the next address in use. A shared address gives
            # 0, which correctly marks an alias rather than an occupant.
            size = (nxt - addr) if nxt is not None and nxt >= addr else 0
            layout.entries.setdefault(
                name, MemEntry(name=name, file=file, line=line, addr=addr, size=size)
            )

        # A 16-bit access to a single-byte entry runs one past it and lands in
        # whatever begins at the next address.
        for (addr, name, _f, _l), (nxt_addr, nxt_name, _nf, _nl) in zip(
            ordered, ordered[1:], strict=False
        ):
            if nxt_addr == addr + 1:
                layout.covered_by.setdefault(nxt_name, name)
    return layout
