"""How large a cartridge is assembled, and what the assembler is told to do it.

The framework already carries the whole mechanism. ``!Define_Global_ROMSize``
picks a row of ``%GetROMSize()``, which sets the header's size byte and
``!MaxROMSize`` -- the offset the ROM is padded out to. A ROM map states its own
cartridge's value and guards the assignment, so naming the define on the command
line assembles the *same source* into a larger image:

    asar --define Define_Global_ROMSize=$0A ...

Nothing else about the build changes. An expanded ROM differs from the stock one
by three bytes -- the size byte and the checksum pair, which asar recomputes --
and a tail of zeroes. Every address the game uses is where it was, so a project's
levels, graphics and tables are untouched by resizing.

**Everything added is freespace, and nothing has to declare it.** The pad is
zeroes and carries no RATS tag, which is exactly what asar's ``freespace`` /
``freecode`` / ``freedata`` scanner looks for -- so a patch assembled over an
expanded cartridge lands in the new banks with no help from us. Measured on a
2 MB build: forty 30,000-byte ``freedata`` blocks placed one per bank from
``$90`` upwards, and the file did not grow.

The stock cartridge has **none**. asar finds no run to use inside the shipped
512 KB, because the gaps hold the cart's own garbage bytes rather than zeroes --
the disassembly reinserts them to stay byte-exact. That is the whole reason
expanding is worth having.

**asar grows the file rather than failing when it runs out.** Ask a 2 MB
cartridge for more freespace than the 1.5 MB it has and the image comes back at
4 MB, silently. :func:`~smw_tools.build.build_rom` therefore checks the length of
what it produced against the length it asked for, which turns that into a named
failure.

**Which sizes exist is this module's business; which a base offers is the
base's.** They are not the same list. ``vanilla`` runs 512 KB to 4 MB, because
32 KB to a bank across banks ``$00``-``$7D`` and their ``$80`` mirrors is where
plain LoROM stops. ``sa1`` starts at 1 MB -- SA-1 Pack needs freespace, so a
512 KB cartridge is not a thing it can produce -- and reaches 6 and 8 MB, which
the chip's MMC maps in 1 MB super-banks. See :attr:`~smw_tools.bases.RomBase.sizes`.

A size whose :attr:`RomSize.define` is ``None`` would be one the *assembler*
cannot reach, because the memory map the source assembles under cannot address
it; no size lacks one today. Past 4 MB only the SA-1 layout reaches, under the
framework's own codes, and ``Config/SA1Pack.asm`` does what a >4 MB SA-1 ROM
needs besides -- the MMC bank-switch values and the cartridge header's second
copy.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

#: The define a ROM map guards and the build overrides.
DEFINE = "Define_Global_ROMSize"

#: What every shipped cartridge is, in bytes. Freespace is measured from here,
#: because everything up to it is the game and its own garbage.
STOCK_BYTES = 512 * 1024


class RomSizeError(ValueError):
    """A ROM size that is not one this repository knows about."""


def bytes_label(count: int) -> str:
    """``524288`` as ``512 KB``, ``1572864`` as ``1.5 MB``.

    Every size here is a whole number of 512 KB steps, so this never has to
    round -- which is what lets one spelling serve the menu, the command line
    and the id.
    """
    if count < 1024 * 1024:
        return f"{count // 1024} KB"
    return f"{count / (1024 * 1024):g} MB"


@dataclass(frozen=True)
class RomSize:
    """One selectable cartridge size."""

    #: What names it on the command line and in a project's ``project.json``.
    id: str

    #: What it is called: the size and nothing else, so it reads in a sentence.
    label: str

    #: The ``!Define_Global_ROMSize`` value, as the assembler is given it, or
    #: ``None`` for a size the source assembly cannot reach at all -- see the
    #: module docstring.
    define: str | None

    #: How many bytes the assembled image is. The framework pads to
    #: ``!MaxROMSize``, so this is exact rather than a lower bound -- which is
    #: what lets a build check that what came out is what was asked for.
    size: int


#: Every size any base can be built at, smallest first. A base offers a subset.
#:
#: The framework offers sizes below 512 KB too. They are left out because the
#: game does not fit in them: the disassembly places routines to the end of bank
#: ``$0F``, so anything smaller is an assembly that cannot succeed rather than a
#: choice anyone could want.
#:
#: 5 MB and 7 MB are absent because nothing offers them: past 4 MB only the
#: SA-1 layout reaches, and the framework declares 6 MB and 8 MB for it and
#: nothing between.
ROM_SIZES: dict[str, RomSize] = {
    size.id: size
    for size in (
        RomSize("512kb", "512 KB", "$09", 512 * 1024),
        RomSize("1mb", "1 MB", "$0A", 1024 * 1024),
        RomSize("1.5mb", "1.5 MB", "$0B", 1536 * 1024),
        RomSize("2mb", "2 MB", "$0C", 2048 * 1024),
        RomSize("2.5mb", "2.5 MB", "$0D", 2560 * 1024),
        RomSize("3mb", "3 MB", "$0E", 3072 * 1024),
        RomSize("3.5mb", "3.5 MB", "$0F", 3584 * 1024),
        RomSize("4mb", "4 MB", "$10", 4096 * 1024),
        # The framework's own codes for the two SA-1 sizes past 4 MB: the
        # header byte written is $0D for both, and the image is padded to
        # the size named. Only a coprocessor base offers them.
        RomSize("6mb", "6 MB", "$12", 6144 * 1024),
        RomSize("8mb", "8 MB", "$13", 8192 * 1024),
    )
}

#: What every shipped cartridge is, what the default base's ladder starts at,
#: and what :func:`rom_size` answers when nobody has said. The one size whose
#: targets can claim a No-Intro hash.
#:
#: **Not "the stock size" in general** -- that is per base, and ``sa1``'s is
#: 1 MB. :attr:`~smw_tools.bases.RomBase.stock_size` is the question to ask.
STOCK = "512kb"


def size_for(length: int, sizes: Iterable[str]) -> str | None:
    """Which of ``sizes`` a cartridge ``length`` bytes long is, or ``None``
    where it is shorter than the smallest of them.

    The **largest one it covers**, not the nearest: what anything asks a size
    is whether some bank is in the image, so an image longer than a size holds
    everything that size holds. That is also what makes this right over a
    length no ladder names -- a ``.smc`` dump carrying its 512-byte copier
    header answers as the cartridge under the header rather than as nothing.

    For a caller holding the cartridge itself rather than a record of it: the
    file's length is the one answer that cannot be stale, and it is what
    :attr:`~smw_tools.bases.RomBase.built_at` wants. ``sizes`` is the base's
    own ladder, since that is what a base may be read at.
    """
    covered = [one for one in sizes if length >= ROM_SIZES[one].size]
    return max(covered, key=lambda one: ROM_SIZES[one].size, default=None)


def rom_size(size_id: str | None = None) -> RomSize:
    """One size by id, or the stock one. Raises with the valid set listed."""
    if size_id is None:
        return ROM_SIZES[STOCK]
    try:
        return ROM_SIZES[size_id]
    except KeyError:
        raise RomSizeError(
            f'unknown ROM size "{size_id}" -- expected one of {", ".join(ROM_SIZES)}'
        ) from None
