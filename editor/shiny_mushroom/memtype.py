"""Mesen's ``MemoryType`` enum, and the guard that keeps it honest.

These values are not an API. They are the ordinal positions of entries in
Mesen's ``Core/Shared/MemoryType.h``, which is free to gain a console or drop
one between versions -- and a silent shift here would not raise anything, it
would read sprite RAM and call it VRAM.

It sits beside :mod:`shiny_mushroom.addresses` rather than under
:mod:`shiny_mushroom.emu` because :meth:`~shiny_mushroom.addresses.Addresses.at`
-- the method every reader of a base's RAM goes through -- answers in these
values, and that declaration must be readable without loading the ctypes
binding. There is nothing native here either: it is a table of integers.

So the numbers below are a starting guess, and :func:`verify` is what makes them
trustworthy: every memory this package reads has a size fixed by the SNES
itself, and asking the core for those sizes catches a shifted enum immediately
and cheaply. A core whose layout has moved fails at startup with a clear message
instead of producing quietly wrong graphics.
"""

from __future__ import annotations

from enum import IntEnum

from smw_tools.ram_map import MemorySpace


class MemoryType(IntEnum):
    """The SNES entries of Mesen's MemoryType, as of MesenCE 2.2.1.

    Their positions are more stable than the enum as a whole: 2.2.1 added two
    Game Boy entries and moved 46 of the 93 values, and none of these. That is
    luck rather than a guarantee, which is what :func:`verify` is for.
    """

    #: The CPU bus: banks and mirrors as the 65816 sees them. Used only for
    #: address translation, never for bulk reads.
    SNES_MEMORY = 0

    #: The cartridge image, indexed by file offset with no header.
    SNES_PRG_ROM = 14

    #: 128 KB of work RAM: $7E0000 is 0, $7F0000 is 0x10000.
    SNES_WORK_RAM = 15

    #: The cartridge's save memory -- **and, on an SA-1 cartridge, its BW-RAM**.
    #: Mesen registers no type of its own for BW-RAM: ``Sa1.cpp`` reaches it
    #: through ``_cart->DebugGetSaveRam()``, so the 128 KB an SA-1 cart reports
    #: here is where most of SMW's work RAM went. See :mod:`smw_tools.ram_map`.
    SNES_SAVE_RAM = 16

    SNES_VIDEO_RAM = 17
    SNES_SPRITE_RAM = 18
    SNES_CG_RAM = 19

    #: SA-1 I-RAM: 2 KB at ``$3000-$37FF``, which is where SMW's direct page
    #: lives on that base. Zero-sized on a cartridge with no SA-1, which is what
    #: makes it safe to ask about unconditionally.
    SA1_INTERNAL_RAM = 27


#: What the SNES fixes, and therefore what a correctly-mapped enum must report.
#: Save RAM is deliberately absent: its size comes from the cartridge header, so
#: it says nothing about whether the enum is aligned.
EXPECTED_SIZES: dict[MemoryType, int] = {
    MemoryType.SNES_WORK_RAM: 0x20000,
    MemoryType.SNES_VIDEO_RAM: 0x10000,
    MemoryType.SNES_SPRITE_RAM: 0x220,
    MemoryType.SNES_CG_RAM: 0x200,
}


#: Which Mesen memory each of a base's memory spaces is.
#:
#: The one place the two vocabularies meet. :mod:`smw_tools` says a byte is in
#: BW-RAM because that is a fact about the cartridge; that Mesen files BW-RAM
#: under the save-RAM type is a fact about this emulator build, and belongs
#: here with the rest of them.
SPACES: dict[MemorySpace, MemoryType] = {
    MemorySpace.WORK_RAM: MemoryType.SNES_WORK_RAM,
    MemorySpace.SA1_IRAM: MemoryType.SA1_INTERNAL_RAM,
    MemorySpace.SA1_BWRAM: MemoryType.SNES_SAVE_RAM,
}


class MemoryLayoutError(RuntimeError):
    """The core's MemoryType numbering is not the one this package assumes."""


def verify(get_size) -> None:
    """Check the enum against a loaded core, given its ``GetMemorySize``.

    Called once per worker, after a ROM is loaded -- the sizes are not known
    before that, because the debugger the memory dumper belongs to does not
    exist until there is something to debug.
    """
    wrong = []
    for memory, expected in EXPECTED_SIZES.items():
        actual = get_size(memory)
        if actual != expected:
            wrong.append(f"{memory.name} is {actual} bytes, expected {expected}")
    if wrong:
        raise MemoryLayoutError(
            "this Mesen core numbers MemoryType differently than shiny_mushroom.emu "
            "expects, so every memory read would be from the wrong array:\n  "
            + "\n  ".join(wrong)
            + "\nRebuild the vendored core from a matching Mesen revision, or "
            "update shiny_mushroom/memtype.py to its Core/Shared/MemoryType.h."
        )
