"""Extract the game's binary assets out of a reference ROM.

Replaces ``AsarScripts/ExtractAssets.bat``, which is Windows-only, interactive,
and drives the slicing through generated temp .asm files because batch cannot
read a binary. The mechanism here is the same one, minus the contortions:

1. Assemble ``AsarScripts/AssetPointersAndFiles.asm`` with ``--define ROMVer``
   set to the version's bit. That file is not code -- it assembles to a table
   describing where every asset lives in the retail ROM and what it should be
   called on disk.
2. Read that table back out of the assembled binary.
3. Slice the reference ROM and write the pieces out.

Assets come out **verbatim**: graphics are stored still-compressed (``.lz1`` for
the LZ1 versions, ``.lz2`` for LZ2) and go back in through a plain ``incbin``.
Nothing is decompressed and recompressed, which is what makes a byte-exact
rebuild possible at all -- no compressor is known to reproduce Nintendo's exact
output, so a decompress/recompress round trip would silently change the ROM.

Table layout, all values 24-bit little-endian (asar ``dl``)::

    $008000  6 x (pointer, value)      the group directory
             group 0 is the directory itself, where value is a byte size;
             for groups 1-5 value is an entry *count*
    each entry, $0C bytes:
             (snes start, snes end, filename label, filename end)

The filename is ASCII bytes living at its own label inside the same assembled
table, so the mapping from ROM range to output path is entirely data.
"""

from __future__ import annotations

import json
import tempfile
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

from smw_tools.asar import run_asar, warning_flags
from smw_tools.paths import ASSETS_DIR, EXTRACTION_STATE
from smw_tools.rom_image import read_rom, snes_to_pc

#: Our version id -> the bit ``AssetPointersAndFiles.asm`` tests in ``!ROMVer``.
#:
#: The naming does NOT line up, and getting it wrong silently extracts the wrong
#: revision's assets: **their E1 is PAL rev 0 (our E0) and their E2 is PAL rev 1
#: (our E1)**. Their "A" (arcade) is our "SS", the Super Nintendo Super System.
VERSION_BITS: dict[str, int] = {
    "U": 0x0001,  # theirs: SMW_U
    "J": 0x0002,  # theirs: SMW_J
    "E0": 0x0004,  # theirs: SMW_E1  -- PAL rev 0
    "E1": 0x0008,  # theirs: SMW_E2  -- PAL rev 1
    "SS": 0x0010,  # theirs: SMW_A   -- arcade
}

#: Group order is fixed by the directory at the head of the table.
GROUP_NAMES = (
    "directory",
    "gfx",
    "level_music",
    "overworld_music",
    "credits_music",
    "brr",
)

#: Where each group lands, relative to the assets root. Music and
#: samples are shared across every release -- extracting them from any one ROM
#: is enough, which is what lets J and SS be populated without their carts.
GROUP_DESTS: dict[str, str] = {
    "level_music": "SPC700/Music/Levels",
    "overworld_music": "SPC700/Music/Overworld",
    "credits_music": "SPC700/Music/Credits",
    "brr": "SPC700/Samples",
}

#: Graphics are the only version-varying group, and only three sets exist:
#: U, E0 and SS share one, J has its own, and our E1 (their "E2") has its own.
#: The two LZ1 sets and the one LZ2 set are why the filenames differ by suffix.
GFX_DESTS: dict[str, str] = {
    "U": "GFX/SMW_U",
    "E0": "GFX/SMW_U",
    "SS": "GFX/SMW_U",
    "J": "GFX/SMW_J",
    "E1": "GFX/SMW_E2",
}

#: ROM version -> the asset set its graphics belong to, which is the last
#: component of its destination. The one home for that name: a base declares
#: which set a target reads, and `graphics` keys the compression family on it.
GFX_SETS: dict[str, str] = {
    version: dest.rsplit("/", 1)[-1] for version, dest in GFX_DESTS.items()
}

_ENTRY_SIZE = 0x0C
_POINTER_TABLE_ORIGIN = 0x008000


def _dl(buf: bytes, off: int) -> int:
    return buf[off] | (buf[off + 1] << 8) | (buf[off + 2] << 16)


@dataclass(frozen=True)
class AssetEntry:
    """One extractable asset: a ROM range and the file it becomes."""

    group: str
    start: int
    end: int
    filename: str

    @property
    def offset(self) -> int:
        return snes_to_pc(self.start)

    @property
    def size(self) -> int:
        return snes_to_pc(self.end) - snes_to_pc(self.start)


class ExtractError(RuntimeError):
    pass


def build_pointer_table(
    asar_bin: Path, asar_scripts_dir: Path, version: str, workdir: Path
) -> bytes:
    """Assemble the asset pointer table for ``version`` and return its bytes."""
    try:
        bit = VERSION_BITS[version]
    except KeyError:
        raise ExtractError(
            f"unknown version {version!r}; expected one of {sorted(VERSION_BITS)}"
        ) from None

    out = workdir / f"pointers_{version}.sfc"
    run_asar(
        asar_bin,
        [
            "--fix-checksum=off",
            "--no-title-check",
            *warning_flags(),
            "--define",
            f"ROMVer=${bit:04X}",
            "AssetPointersAndFiles.asm",
            str(out),
        ],
        cwd=asar_scripts_dir,
    )
    if not out.is_file():
        raise ExtractError(f"asar produced no pointer table for {version}")
    return out.read_bytes()


def parse_pointer_table(table: bytes) -> list[AssetEntry]:
    """Decode the assembled table into asset entries."""

    def at(snes: int, length: int) -> bytes:
        try:
            off = snes_to_pc(snes)
        except ValueError as exc:
            # A pointer read out of a truncated or garbled table lands anywhere;
            # it is the table that is wrong, not the address arithmetic.
            raise ExtractError(f"pointer table holds a bad address: {exc}") from None
        if off + length > len(table):
            raise ExtractError(
                f"pointer table is truncated: need {off + length:#x}, "
                f"have {len(table):#x}"
            )
        return table[off : off + length]

    entries: list[AssetEntry] = []

    for index, group in enumerate(GROUP_NAMES):
        if index == 0:
            continue  # the directory describes itself; nothing to extract
        record = at(_POINTER_TABLE_ORIGIN + index * 6, 6)
        pointer, count = _dl(record, 0), _dl(record, 3)
        for i in range(count):
            raw = at(pointer + i * _ENTRY_SIZE, _ENTRY_SIZE)
            start, end = _dl(raw, 0), _dl(raw, 3)
            name_ptr, name_end = _dl(raw, 6), _dl(raw, 9)
            name = at(name_ptr, snes_to_pc(name_end) - snes_to_pc(name_ptr))
            entries.append(
                AssetEntry(
                    group=group,
                    start=start,
                    end=end,
                    filename=name.decode("ascii").strip().strip("\x00"),
                )
            )
    return entries


def extract(
    *,
    asar_bin: Path,
    asar_scripts_dir: Path,
    rom_path: Path,
    version: str,
    dest_root: Path,
    dry_run: bool = False,
) -> list[tuple[AssetEntry, Path]]:
    """Slice ``rom_path`` into ``dest_root`` per the table for ``version``.

    ``dest_root`` is the assets root (``paths.ASSETS_DIR``), deliberately outside
    the source tree; each asset is routed into its group's subdirectory below it,
    mirroring the paths the tree incbins. Returns the (entry, destination) pairs
    it wrote, or would have written.
    """
    rom = read_rom(rom_path)
    with tempfile.TemporaryDirectory(prefix="smw-extract-") as tmp:
        table = build_pointer_table(asar_bin, asar_scripts_dir, version, Path(tmp))
    entries = parse_pointer_table(table)

    written: list[tuple[AssetEntry, Path]] = []
    for entry in entries:
        if entry.size <= 0:
            raise ExtractError(
                f"{entry.filename}: non-positive size from range "
                f"${entry.start:06X}..${entry.end:06X}"
            )
        if entry.offset + entry.size > rom.size:
            raise ExtractError(
                f"{entry.filename}: range ${entry.start:06X}..${entry.end:06X} "
                f"runs past the end of {rom_path.name} ({rom.size:#x} bytes)"
            )
        subdir = (
            GFX_DESTS[version] if entry.group == "gfx" else GROUP_DESTS[entry.group]
        )
        dest = dest_root / subdir / entry.filename
        if not dry_run:
            dest.parent.mkdir(parents=True, exist_ok=True)
            data = rom.data[entry.offset : entry.offset + entry.size]
            # Left alone when the bytes are already there. Music and samples
            # are shared by every release, so a second cart would otherwise
            # rewrite them identically -- and a build decides whether it has
            # anything to do by size and mtime, so every project would then
            # assemble again for nothing.
            if not (dest.is_file() and dest.read_bytes() == data):
                dest.write_bytes(data)
        written.append((entry, dest))

    if not dry_run:
        record_extraction(version=version, rom=rom_path, count=len(written))
    return written


def record_extraction(*, version: str, rom: Path, count: int) -> None:
    """Note which cart the assets on disk came from.

    The assets are gitignored, so a checkout carries no evidence of what
    produced them -- and assets from the wrong revision fail as a puzzling
    byte mismatch rather than as a missing file. This is that evidence.
    Per-checkout state, never committed.
    """
    image = read_rom(rom)
    state = {
        "romVersion": version,
        "extractedAt": datetime.now(UTC).isoformat(timespec="seconds"),
        "sourceCart": str(rom),
        "sourceCartMd5": image.md5,
        "sourceCartSha1": image.sha1,
        "extractedFiles": count,
    }
    prior = {}
    if EXTRACTION_STATE.is_file():
        try:
            prior = json.loads(EXTRACTION_STATE.read_text())
        except (OSError, ValueError):
            prior = {}
    # One entry per version: graphics differ per release, while music and
    # samples are shared, so several carts legitimately contribute.
    versions = prior.get("versions", {}) if isinstance(prior, dict) else {}
    versions[version] = state
    EXTRACTION_STATE.write_text(
        json.dumps({"pipelineVersion": 1, "versions": versions}, indent=2) + "\n"
    )


@dataclass(frozen=True)
class Extraction:
    """What the assets on disk were made from, for one release."""

    version: str
    #: When, as an ISO 8601 string, and the cart it came from.
    extracted_at: str
    cart: Path
    sha1: str
    files: int


def extractions() -> dict[str, Extraction]:
    """Every release the assets on disk have been extracted for.

    Empty when nothing has, which is what a fresh checkout is: the assets are
    gitignored because they are copyrighted cart data, so a clone carries no
    graphics, music or samples until someone supplies a cartridge.
    """
    try:
        state = json.loads(EXTRACTION_STATE.read_text())
    except (OSError, ValueError):
        return {}
    versions = state.get("versions", {}) if isinstance(state, dict) else {}
    found = {}
    for version, record in versions.items():
        if not isinstance(record, dict):
            continue
        found[version] = Extraction(
            version=version,
            extracted_at=str(record.get("extractedAt", "")),
            cart=Path(str(record.get("sourceCart", ""))),
            sha1=str(record.get("sourceCartSha1", "")),
            files=int(record.get("extractedFiles", 0) or 0),
        )
    return found


def assets_ready(version: str, dest_root: Path | None = None) -> bool:
    """Whether ``version`` can be built from what is on disk.

    Both halves are asked, because either alone lies. The state file says an
    extraction *happened*, which a deleted assets folder does not undo; the
    folders being there say nothing about which cart filled them. A build needs
    the graphics for this release and the sound the releases share.
    """
    if version not in extractions():
        return False
    root = dest_root or ASSETS_DIR
    wanted = [GFX_DESTS.get(version), *GROUP_DESTS.values()]
    return all(directory and any((root / directory).glob("*")) for directory in wanted)
