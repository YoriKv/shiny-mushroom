"""The five assemblable releases, and the exact bytes each one must produce.

The hashes below are the regression gate for the whole project: a source change
that alters any of them has changed the ROM, and is wrong unless it was meant
to. ``smw check`` compares against these and nothing else -- they are the truth,
not the build log (see check.py).

U's CRC32/SHA-1 are the No-Intro entry for "Super Mario World (USA)", so a
passing U build is independently verifiable against any clean cart dump.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class RomVersionInfo:
    #: Short id, as used on the command line and in output filenames.
    id: str
    #: Human-readable release name.
    label: str
    #: Output filename under build/.
    output_name: str
    #: CRC32 of the assembled ROM, uppercase hex, headerless.
    crc32: str
    #: SHA-1 of the assembled ROM, lowercase hex, headerless.
    sha1: str
    #: Size in bytes. All five are 512 KiB.
    size: int


ROM_VERSIONS: dict[str, RomVersionInfo] = {
    "J": RomVersionInfo(
        id="J",
        label="Japan (NTSC)",
        output_name="SMW_J.sfc",
        crc32="0EC0DDAC",
        sha1="f977afabf24ed269d86366209a460450bbc37e76",
        size=524288,
    ),
    "U": RomVersionInfo(
        id="U",
        label="USA (NTSC)",
        output_name="SMW_U.sfc",
        crc32="B19ED489",
        sha1="6b47bb75d16514b6a476aa0c73a683a2a4c18765",
        size=524288,
    ),
    "SS": RomVersionInfo(
        id="SS",
        label="Super Nintendo Super System (arcade)",
        output_name="SMW_SS.sfc",
        crc32="C46766F2",
        sha1="06a6efc246c6fdb83efab1d402d61d2179a84494",
        size=524288,
    ),
    "E0": RomVersionInfo(
        id="E0",
        label="Europe (PAL) rev 0",
        output_name="SMW_E0.sfc",
        crc32="3C41070F",
        sha1="56265120a74b55260ff7cacc00da1f21cbcb64f4",
        size=524288,
    ),
    "E1": RomVersionInfo(
        id="E1",
        label="Europe (PAL) rev 1",
        output_name="SMW_E1.sfc",
        crc32="B47F5F20",
        sha1="46bf36be1c3a2ce9de7581323370bd2d891ad5a1",
        size=524288,
    ),
}

ALL_VERSIONS: list[str] = ["J", "U", "SS", "E0", "E1"]


def identify(sha1: str) -> str | None:
    """Which release a cartridge is, from its SHA-1, or ``None`` for none of them.

    By hash rather than by anything in the header, because the five releases are
    not distinguishable from their headers in any way that survives a hack -- and
    the whole point of asking is to refuse a cart that is not one of them. A
    modified cartridge answers ``None``, which is the honest answer: its assets
    are not the ones the disassembly's byte-exactness is defined against.
    """
    for info in ROM_VERSIONS.values():
        if info.sha1 == sha1:
            return info.id
    return None
