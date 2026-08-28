"""Generate the app icon and the two platform icon containers from the artwork.

Its outputs are committed, so this only runs when the artwork changes. It lives
here rather than in scratch because losing it would mean nobody could change the
icon without hand-authoring an .icns.

    packaging/shiny-mushroom.png                    the master artwork, in
    editor/shiny_mushroom/resources/icons/app.png   256x256, the runtime window icon
    packaging/shiny-mushroom.ico                    Windows, embedded into the .exe
    packaging/shiny-mushroom.icns                   macOS, baked into the .app bundle

The master is pixel art, and is exported at whatever scale the drawing program
happened to be zoomed to. So it is first collapsed back onto its own pixel grid
-- the largest N for which the image is an N-fold block enlargement -- and every
size is resampled from that. What comes out therefore does not depend on the
export scale: re-exporting the same drawing at 16x rather than 32x produces
byte-identical icons.

Resampling is an area average over premultiplied alpha, so the transparent
surround does not bleed a dark fringe into the outline at the small sizes.

Standard library only (zlib + struct), so it runs with no environment at all.
Both containers embed PNGs directly, which .ico has allowed since Vista and
.icns since 10.7 -- well below anything the release workflow targets.

Usage:  python packaging/make_icons.py [--dry-run]
"""

from __future__ import annotations

import math
import struct
import sys
import zlib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SOURCE = REPO / "packaging/shiny-mushroom.png"
PNG_OUT = REPO / "editor/shiny_mushroom/resources/icons/app.png"
ICO_OUT = REPO / "packaging/shiny-mushroom.ico"
ICNS_OUT = REPO / "packaging/shiny-mushroom.icns"

# The window icon Qt loads at runtime, and the only size the app itself reads.
RUNTIME_SIZE = 256
# Sizes each container ships. .ico is capped at 256; .icns names its slots.
ICO_SIZES = (16, 24, 32, 48, 64, 128, 256)
# (OSType, pixel size). The `ic..` slots are the modern PNG-capable ones.
ICNS_SLOTS = (
    (b"icp4", 16),
    (b"icp5", 32),
    (b"ic07", 128),
    (b"ic08", 256),
    (b"ic09", 512),
    (b"ic10", 1024),
)

Pixel = tuple[int, int, int, int]
# An image is its width, its height, and its rows of RGBA pixels.
Image = tuple[int, int, list[list[Pixel]]]


def _chunk(tag: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + tag
        + payload
        + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)
    )


def decode(data: bytes) -> Image:
    """Decode an 8-bit RGBA, non-interlaced PNG.

    Only the one form the master is written in, since the alternative is a full
    decoder for a file this script reads exactly once. Anything else raises
    rather than producing a subtly wrong icon.
    """
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{SOURCE.name} is not a PNG")

    header, compressed, pos = None, bytearray(), 8
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos : pos + 4])
        tag, payload = data[pos + 4 : pos + 8], data[pos + 8 : pos + 8 + length]
        if tag == b"IHDR":
            header = struct.unpack(">IIBBBBB", payload)
        elif tag == b"IDAT":
            compressed += payload
        pos += 12 + length
    if header is None:
        raise ValueError(f"{SOURCE.name} has no IHDR")

    width, height, depth, color, _compression, _filter, interlace = header
    if (depth, color, interlace) != (8, 6, 0):
        raise ValueError(
            f"{SOURCE.name} must be 8-bit RGBA and non-interlaced; got depth "
            f"{depth}, color type {color}, interlace {interlace}"
        )

    raw = zlib.decompress(bytes(compressed))
    stride = width * 4
    rows: list[list[Pixel]] = []
    previous, pos = bytearray(stride), 0
    for _ in range(height):
        method, line = raw[pos], bytearray(raw[pos + 1 : pos + 1 + stride])
        pos += 1 + stride
        _unfilter(method, line, previous, stride)
        rows.append(
            [
                (line[i], line[i + 1], line[i + 2], line[i + 3])
                for i in range(0, stride, 4)
            ]
        )
        previous = line
    return width, height, rows


def _unfilter(method: int, line: bytearray, previous: bytearray, stride: int) -> None:
    """Undo one scanline's filter in place. Filter types are PNG spec 9.2."""
    if method == 0:  # None
        return
    for i in range(stride):
        left = line[i - 4] if i >= 4 else 0
        up = previous[i]
        if method == 1:  # Sub
            line[i] = (line[i] + left) & 0xFF
        elif method == 2:  # Up
            line[i] = (line[i] + up) & 0xFF
        elif method == 3:  # Average
            line[i] = (line[i] + ((left + up) >> 1)) & 0xFF
        elif method == 4:  # Paeth
            corner = previous[i - 4] if i >= 4 else 0
            estimate = left + up - corner
            deltas = (
                abs(estimate - left),
                abs(estimate - up),
                abs(estimate - corner),
            )
            line[i] = (line[i] + (left, up, corner)[deltas.index(min(deltas))]) & 0xFF
        else:
            raise ValueError(f"unknown PNG filter type {method}")


def unscale(image: Image) -> Image:
    """Collapse an N-fold block enlargement back onto its own pixel grid.

    Returns the image unchanged when it is not one -- artwork drawn at its true
    size, or exported through something that resampled it.
    """
    width, height, rows = image
    span = math.gcd(width, height)
    for n in (d for d in range(span, 1, -1) if span % d == 0):
        if all(
            rows[y][x] == rows[y - y % n][x - x % n]
            for y in range(height)
            for x in range(width)
        ):
            return (
                width // n,
                height // n,
                [[rows[y][x] for x in range(0, width, n)] for y in range(0, height, n)],
            )
    return image


def _spans(source: int, target: int) -> list[list[tuple[int, float]]]:
    """For each output pixel, the source pixels it covers and how much of each."""
    spans = []
    for i in range(target):
        low, high = i * source / target, (i + 1) * source / target
        spans.append(
            [
                (j, min(high, j + 1) - max(low, j))
                for j in range(int(low), min(source, math.ceil(high)))
            ]
        )
    return spans


def resample(image: Image, size: int) -> list[list[Pixel]]:
    """Area-average ``image`` to ``size`` x ``size``, as rows of RGBA tuples.

    The average is over premultiplied alpha: a transparent pixel carries no
    color, so averaging its RGB in would darken every edge against the surround.
    """
    width, height, rows = image
    columns = _spans(width, size)
    out = []
    for span_y in _spans(height, size):
        row: list[Pixel] = []
        for span_x in columns:
            red = green = blue = weighted_alpha = coverage = 0.0
            for y, wy in span_y:
                source = rows[y]
                for x, wx in span_x:
                    weight = wy * wx
                    r, g, b, a = source[x]
                    premultiplied = a * weight
                    red += r * premultiplied
                    green += g * premultiplied
                    blue += b * premultiplied
                    weighted_alpha += premultiplied
                    coverage += weight
            if weighted_alpha == 0:
                row.append((0, 0, 0, 0))
                continue
            row.append(
                (
                    _byte(red / weighted_alpha),
                    _byte(green / weighted_alpha),
                    _byte(blue / weighted_alpha),
                    _byte(weighted_alpha / coverage),
                )
            )
        out.append(row)
    return out


def _byte(value: float) -> int:
    return min(255, max(0, round(value)))


def png(rows: list[list[Pixel]]) -> bytes:
    """Encode rows of RGBA tuples as an 8-bit RGBA PNG."""
    raw = bytearray()
    for row in rows:
        raw.append(0)  # filter type 0 (None) -- the image is tiny, so don't bother
        for pixel in row:
            raw.extend(pixel)
    header = struct.pack(">IIBBBBB", len(rows[0]), len(rows), 8, 6, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", header)
        + _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + _chunk(b"IEND", b"")
    )


def ico(images: dict[int, bytes], sizes: tuple[int, ...]) -> bytes:
    """Pack PNGs into an .ico container."""
    # ICONDIR, then one 16-byte ICONDIRENTRY per image, then the payloads.
    offset = 6 + 16 * len(sizes)
    directory = bytearray(struct.pack("<HHH", 0, 1, len(sizes)))
    for size in sizes:
        # 256 is stored as 0 in the single-byte width/height fields.
        directory += struct.pack(
            "<BBBBHHII", size % 256, size % 256, 0, 0, 1, 32, len(images[size]), offset
        )
        offset += len(images[size])
    return bytes(directory) + b"".join(images[size] for size in sizes)


def icns(images: dict[int, bytes], slots: tuple[tuple[bytes, int], ...]) -> bytes:
    """Pack PNGs into an .icns container."""
    body = b"".join(
        ostype + struct.pack(">I", len(images[size]) + 8) + images[size]
        for ostype, size in slots
    )
    return b"icns" + struct.pack(">I", len(body) + 8) + body


def main(argv: list[str]) -> int:
    dry_run = "--dry-run" in argv[1:]

    source = unscale(decode(SOURCE.read_bytes()))
    print(f"read {SOURCE.relative_to(REPO)} ({source[0]}x{source[1]} artwork)")

    sizes = {RUNTIME_SIZE, *ICO_SIZES, *(size for _, size in ICNS_SLOTS)}
    images = {size: png(resample(source, size)) for size in sorted(sizes)}

    outputs = {
        PNG_OUT: images[RUNTIME_SIZE],
        ICO_OUT: ico(images, ICO_SIZES),
        ICNS_OUT: icns(images, ICNS_SLOTS),
    }
    for path, data in outputs.items():
        verb = "would write" if dry_run else "wrote"
        if not dry_run:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        print(f"{verb} {path.relative_to(REPO)} ({len(data):,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
