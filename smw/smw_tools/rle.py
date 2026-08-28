"""The two byte RLEs: LC_RLE1 and LC_RLE2.

Not the LZ family the graphics use ([`compression`](compression.py)) -- a much
smaller format with one command byte and no backreferences:

```
cmd & $80 set    run:     (cmd & $7F) + 1 copies of the next byte
cmd & $80 clear  literal: cmd + 1 bytes follow
```

**The variants differ in how a stream ends, and nothing else.** LC_RLE1 stops on
two consecutive `$FF` at the read cursor; LC_RLE2 has no terminator at all and
stops on a byte count the caller has to know. Everything about the commands is
shared, which is why one engine covers both.

## The stride is not part of the encoding

LC_RLE2 is usually described as having "a stride of 2", which is true of the
*decoder* and not of the stream: `CODE_04DABA` reads the input linearly and
writes every other byte of the output buffer, because the overworld's Layer 2
tilemap is two interleaved streams -- `overworld/layer2/tiles.bin` into the even
bytes and `overworld/layer2/properties.bin` into the odd ones, making one 16-bit
entry per tile. A single stream still decodes to a plain run of bytes. So a
stride appears nowhere below: **for one file, LC_RLE2 is LC_RLE1 with a length
instead of a terminator.**

## Where each is used

| Variant | Files | Decoder |
|---|---|---|
| LC_RLE1 | the 17 Layer 2 background tilemaps | `SMW_BufferBGTilemap_Main` |
| LC_RLE1 | `overworld/layer2/events/properties.bin` | `CODE_04DD40` |
| LC_RLE2 | `overworld/layer2/tiles.bin` and `properties.bin` | `CODE_04DABA` |

The first is in `Banks/Bank05.asm` and the other two in `Banks/Bank04.asm`.

sneslab's RLE1 page names only the overworld event properties as SMW's use of
it; the 17 backgrounds use it too. Treat the wiki as authoritative on the
*format* and this tree on *what is stored in it* -- the same split
[`graphics-loading.md`](../../docs/smw/graphics-loading.md#compression) makes
for LZ1.

## Unlike LZ, this is very nearly canonical -- and that is the trade

The format offers one real choice: when to break a literal run for a run
command. Taking a run at **two** bytes or more reproduces **17 of the 20**
shipped blobs exactly, where taking one at three or more reproduces 2. The three
that differ each spell one byte as a run of length 1 where a literal would have
done, which is not a rule -- applying it everywhere drops the score to 2.

**The two-byte rule is not size-optimal, and is chosen anyway.** A run of two
sitting inside a literal stretch costs two bytes for the run command *plus* a
fresh header for the literals that follow, so it is a net loss there; Lunar
Compress declines it and comes out about 4% smaller over the same 20 files,
while reproducing only 2 of them. Matching the cartridge is worth more than the
4%, because it is what :func:`repack` turns into byte-exactness. If a growing
file ever fails to fit its region, this rule is the thing to revisit.

That is a much better position than the LZ family, where nothing reproduces
anything. It still is not a guarantee, so :func:`repack` keeps the shipped bytes
for an unedited file exactly as the graphics path does.

## Checked against Lunar Compress

Both directions, against `Lunar Compress.dll` 2.00 driven through its own API
(`LC_RLE1` is format 100, `LC_RLE2` is 101): over all 20 shipped blobs, our
decode is byte-identical to `LunarDecompress`, `LunarDecompress` reads back
everything :func:`compress` writes, and the byte count we report consuming
matches its `LastROMPosition`. `smw/tmp/lcxval/` is the harness.

`decomp.exe` cannot check LC_RLE2 -- it hardcodes a `MaxDataSize` of `$10000`,
and that format takes its length from that rather than from a terminator, so the
tool always returns `$10000` bytes for a `$2000`-byte stream. The DLL has to be
called directly.
"""

from __future__ import annotations

from enum import Enum

#: A command covers at most this many bytes, in either form.
MAX_RUN = 128


class Variant(Enum):
    """How a stream ends. The value is whether it carries a terminator."""

    RLE1 = True
    RLE2 = False

    @property
    def terminated(self) -> bool:
        return self.value


class CorruptStream(ValueError):
    """A stream that is not a valid structure in this format."""


def _fail(reason: str) -> CorruptStream:
    return CorruptStream(f"corrupt RLE stream: {reason}")


def decompress(
    data: bytes, variant: Variant, *, size: int | None = None
) -> tuple[bytes, int]:
    """Decode one structure from the start of ``data``.

    Returns ``(output, consumed)``. ``size`` is the decompressed length and is
    **required for LC_RLE2**, which has nothing in the stream to say where it
    ends -- the ROM's own decoder stops when its write cursor reaches `$4000`,
    which at a stride of two is `$2000` bytes of payload. For LC_RLE1 it is
    optional and, when given, checked.
    """
    if variant is Variant.RLE2 and size is None:
        raise ValueError("LC_RLE2 has no terminator; the decompressed size is required")

    out = bytearray()
    i = 0
    n = len(data)
    while True:
        if variant.terminated:
            if i + 1 < n and data[i] == 0xFF and data[i + 1] == 0xFF:
                break
        elif len(out) >= size:  # type: ignore[operator]
            break
        if i >= n:
            raise _fail(
                "source exhausted before the $FF $FF terminator"
                if variant.terminated
                else f"source exhausted with {len(out)} of {size} bytes decoded"
            )
        cmd = data[i]
        i += 1
        if cmd & 0x80:  # run
            if i >= n:
                raise _fail("source exhausted reading a run's byte")
            out += data[i : i + 1] * ((cmd & 0x7F) + 1)
            i += 1
        else:  # literal
            length = cmd + 1
            if i + length > n:
                raise _fail("source exhausted inside a literal run")
            out += data[i : i + length]
            i += length

    consumed = i + 2 if variant.terminated else i
    if size is not None and len(out) != size:
        raise _fail(f"decoded {len(out):#x} bytes, expected {size:#x}")
    return bytes(out), consumed


def compress(raw: bytes, variant: Variant, *, smallest: bool = False) -> bytes:
    """Encode ``raw`` as one structure.

    Greedy, taking a run at two bytes or more. That is not an arbitrary
    threshold -- it is the one the shipped data was packed with, and it
    reproduces 17 of the 20 shipped blobs byte for byte where taking a run at
    three or more reproduces 2.

    It is deliberately *not* the smallest output available: a run of two inside
    a literal stretch costs the run command plus a fresh literal header. With
    ``smallest`` both thresholds are tried and the shorter kept, which is worth
    about 4% and is what to use whenever the output has to *fit* something --
    every time this runs in earnest, since :func:`repack` hands back the
    shipped bytes for a file nobody edited and anything reaching here has
    changed.

    Both thresholds are tried rather than assuming three is smaller, because on
    data with many short runs it is not.
    """
    if smallest:
        return min((_compress(raw, variant, 2), _compress(raw, variant, 3)), key=len)
    return _compress(raw, variant, 2)


def _compress(raw: bytes, variant: Variant, threshold: int) -> bytes:
    """One greedy pass, taking a run at ``threshold`` bytes or more."""
    out = bytearray()
    literals = bytearray()

    def flush() -> None:
        at = 0
        while at < len(literals):
            chunk = literals[at : at + MAX_RUN]
            out.append(len(chunk) - 1)
            out.extend(chunk)
            at += MAX_RUN
        literals.clear()

    i = 0
    n = len(raw)
    while i < n:
        run = 1
        while run < MAX_RUN and i + run < n and raw[i + run] == raw[i]:
            run += 1
        # A run of 128 $FF bytes would be written `$FF $FF`, which LC_RLE1 reads
        # as its terminator -- so it is written as 127 and the last byte falls
        # into whatever comes next. LC_RLE2 has no terminator and no such trap,
        # but one rule is cheaper than two and costs a byte on data that never
        # occurs.
        if run == MAX_RUN and raw[i] == 0xFF:
            run = MAX_RUN - 1
        if run >= threshold:
            flush()
            out.append(0x80 | (run - 1))
            out.append(raw[i])
            i += run
        else:
            literals += raw[i : i + 1]
            i += 1
    flush()
    return bytes(out) + (b"\xff\xff" if variant.terminated else b"")


def repack(
    original: bytes,
    raw: bytes,
    variant: Variant,
    *,
    size: int | None,
    smallest: bool = False,
) -> bytes:
    """The compressed form of ``raw``, keeping ``original`` when nothing changed.

    The same bargain [`compression.repack`](compression.py) makes, for the same
    reason: re-encoding is not the inverse of decoding, so a file nobody edited
    keeps the bytes the cartridge shipped and only a changed one pays a new
    parse. It matters less here than it does for LZ -- this encoder reproduces
    most of the shipped data anyway -- but "most" is not a property a byte gate
    can be built on.
    """
    try:
        decoded, _consumed = decompress(original, variant, size=size)
    except (CorruptStream, ValueError):
        return compress(raw, variant, smallest=smallest)
    if decoded == raw:
        return original
    return compress(raw, variant, smallest=smallest)
