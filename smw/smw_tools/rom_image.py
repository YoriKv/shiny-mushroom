"""Reading and comparing ROM images.

Everything downstream works on *headerless* bytes. Dumps in the wild often carry
a 512-byte copier header, and comparing a headered dump against a headerless
build byte-for-byte reports every single byte as different -- a failure mode
that looks like a catastrophic build regression and is actually a file-format
detail. ``strip_copier_header`` normalises that away.
"""

from __future__ import annotations

import hashlib
import zlib
from dataclasses import dataclass
from pathlib import Path


@dataclass
class RomImage:
    path: Path
    #: Headerless ROM bytes.
    data: bytes
    #: True when a 512-byte copier header was present and removed.
    had_copier_header: bool
    crc32: str
    sha1: str
    md5: str
    size: int


def strip_copier_header(buf: bytes) -> tuple[bytes, bool]:
    """Detect and remove an SMC/SWC/FIG-style 512-byte copier header.

    A cartridge ROM is always a whole number of KiB, so a file that is 512 bytes
    over a KiB boundary carries one::

        (size & 0x3FF) == 0x200

    Testing against 32 KiB instead is the intuitive move -- LoROM banks are that
    size -- but it is narrower than the rule the format actually guarantees, and
    would miss the header on any image whose payload is not a multiple of 32 KiB.
    """
    if (len(buf) & 0x3FF) == 0x200:
        return buf[512:], True
    return buf, False


def read_rom(path: Path | str) -> RomImage:
    p = Path(path)
    raw = p.read_bytes()
    data, had_header = strip_copier_header(raw)
    return RomImage(
        path=p,
        data=data,
        had_copier_header=had_header,
        crc32=format(zlib.crc32(data) & 0xFFFFFFFF, "08X"),
        sha1=hashlib.sha1(data).hexdigest(),
        md5=hashlib.md5(data).hexdigest(),
        size=len(data),
    )


def pc_to_snes(pc: int) -> int:
    """LoROM file offset -> SNES address."""
    return ((pc >> 15) << 16) | 0x8000 | (pc & 0x7FFF)


def snes_to_pc(address: int) -> int:
    """LoROM SNES address -> file offset. Inverse of :func:`pc_to_snes`.

    Bank bit 7 is a mirror, so ``$05E000`` and ``$85E000`` are the same byte --
    but ``$7E`` and ``$7F`` are work RAM rather than a mirror of anything, and
    masking the bit off would answer with a perfectly plausible offset for a
    byte that is not in the cartridge at all. Both those banks and the lower
    half of any bank are refused instead.
    """
    bank = (address >> 16) & 0xFF
    within = address & 0xFFFF
    if within < 0x8000:
        raise ValueError(f"${address:06X} is not in the ROM half of its bank")
    if bank in (0x7E, 0x7F):
        raise ValueError(f"${address:06X} is in work RAM, not the cartridge")
    return ((bank & 0x7F) << 15) | (within - 0x8000)


def format_snes(pc: int) -> str:
    a = pc_to_snes(pc)
    return f"${a >> 16:02X}:{a & 0xFFFF:04X}"


@dataclass
class DiffCluster:
    #: File offset of the first differing byte.
    start: int
    #: File offset of the last differing byte.
    end: int
    #: Number of differing bytes inside the cluster.
    count: int
    a: bytes
    b: bytes


def diff_clusters(a: bytes, b: bytes, gap: int = 64) -> list[DiffCluster]:
    """Group differing byte offsets into clusters.

    Runs separated by fewer than ``gap`` matching bytes are merged. Raw offset
    lists are useless at this scale (a single inserted routine shows up as
    hundreds of scattered offsets); the clustered view makes "one patch was
    applied here" legible at a glance.
    """
    n = min(len(a), len(b))
    clusters: list[DiffCluster] = []
    start = -1
    last = -1
    count = 0

    def flush() -> None:
        nonlocal start, count
        if start < 0:
            return
        clusters.append(
            DiffCluster(
                start=start,
                end=last,
                count=count,
                a=a[start : min(start + 8, len(a))],
                b=b[start : min(start + 8, len(b))],
            )
        )
        start = -1
        count = 0

    for i in range(n):
        if a[i] == b[i]:
            continue
        if start < 0:
            start = i
        elif i - last > gap:
            flush()
            start = i
        last = i
        count += 1
    flush()
    return clusters


def count_diffs(a: bytes, b: bytes) -> int:
    n = min(len(a), len(b))
    d = abs(len(a) - len(b))
    for i in range(n):
        if a[i] != b[i]:
            d += 1
    return d
