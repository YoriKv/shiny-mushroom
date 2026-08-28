"""The SNES command-stream LZ family: LZ1 and LZ2, decode and encode.

Every graphics file in the ROM is stored compressed in this family, and the
family has two members that differ in exactly one thing -- the byte order of a
backreference's offset. **LZ1** is little-endian and ships in `J` and `E1`;
**LZ2** is big-endian and ships in `U`, `SS` and `E0`. Everything else -- the
header forms, all five commands, the terminator -- is shared, which is why one
engine with one conditional byte swap covers both.
[`docs/smw/graphics-loading.md`](../../docs/smw/graphics-loading.md#compression)
is the format reference and `CODE_00B8DE` in `Banks/Bank00.asm` is the decoder
this mirrors.

## This encoder does not reproduce the cartridge, and does not need to

LZ is not canonical -- many valid streams decode to identical bytes -- so an
encoder is free to choose a different one, and a better encoder reliably does.
Reproducing a cartridge blob means reproducing the exact parse its packer chose,
which the format implies nowhere: over the 156 shipped blobs this encoder
reproduces none, and neither does Lunar Compress's own `LunarRecompress`.

That does not matter here, because **byte-exactness is bought by not
recompressing**. :func:`repack` hands back the shipped bytes for anything
unedited, which is exact by construction rather than by a parse being right; a
perfect encoder could only equal it while adding a way to be wrong. Anything
that does reach this encoder has been edited, cannot match the cartridge however
it is packed, and needs to be small.

The cartridges' own parse is a separate subject and largely known --
[`cart_parse`](cart_parse.py) has it, exact for two releases of three, and is
used by nothing.

## The parse

Greedy by benefit with a one-step lazy deferral, after shiny-egg's
`lz2-encode-improved.ts`. Measured over the cartridge's 156 blobs it is **5.4%
smaller than the shipped data at ~6 ms a blob**. One parse rather than two: a
shortest-path search is 0.6% smaller again for eight times the time, which no
caller here would spend.

[`cart_parse`](cart_parse.py) is faster -- 0.25 s against 0.31 s over the 52 `U`
blobs -- but lands 0.1% under the shipped bytes where this lands 5.4% under.
Anything reaching an encoder here has to *fit* a region, so size decides.

It emits only backreference command `100`. The decoder aliases `101`, `110` and
`111` onto it, and long-form `111` collides with the `$FF` terminator, so
emitting one command keeps every header this writes unambiguous.

## Checked against Lunar Compress

Both directions, against `Lunar Compress.dll` 2.00 driven through its own API
(`LC_LZ1` is format 0, `LC_LZ2` is 1): over all 156 shipped blobs, our decode is
byte-identical to `LunarDecompress`, `LunarDecompress` reads back everything
:func:`compress` writes, and the byte count we report consuming matches its
`LastROMPosition`. `smw/tmp/lcxval/` is the harness.

From the same run: ours comes out **0.3% smaller than `LunarRecompress`**,
winning on 135 of the 156 blobs, so the parse is competitive with the reference
tool rather than merely correct.
"""

from __future__ import annotations

from enum import Enum

#: The reach of an absolute 16-bit backreference offset, and so the largest
#: structure this family can encode.
MAX_SIZE = 0x10000

_TERMINATOR = 0xFF
_MAX_SHORT = 32
_MAX_LONG = 1024

_OP_LITERAL = 0x00
_OP_FILL = 0x20
_OP_WORD_FILL = 0x40
_OP_INCREASING = 0x60
_OP_BACKREF = 0x80

#: Below this a run or backreference never beats writing the bytes out.
_MIN_MATCH = 3
#: Recent positions sharing a prefix that a search tests. Measured over the 52
#: `U` blobs: 64 gives 123,336 bytes in 0.32 s and 512 gives 123,098 in 0.46 s
#: -- 0.19% for half again the time, which is why the deeper walk is reserved
#: for :func:`compress`'s ``smallest`` and is not the default.
_MAX_CHAIN = 64
_DEEP_CHAIN = 512

#: Versions whose graphics are LZ1 -- the `!ROM_SMW_J|!ROM_SMW_E2|!ROM_SMASW_E`
#: mask guarding the offset byte swap at `CODE_00B966` in `Banks/Bank00.asm`.
LZ1_VERSIONS = frozenset({"J", "E1"})


class Family(Enum):
    """Which member a stream is. The value is the backreference byte order."""

    LZ1 = False
    LZ2 = True

    @property
    def big_endian_offsets(self) -> bool:
        return self.value


def family_for(version: str) -> Family:
    """The family member a ROM version's graphics are stored in.

    Named for the compression rather than for the graphics because that is what
    it gates: 43 of the 52 files are byte-identical pixels across all three
    asset sets, and the byte swap affects all 52.
    """
    return Family.LZ1 if version in LZ1_VERSIONS else Family.LZ2


class CorruptStream(ValueError):
    """A stream that is not a valid structure in this family."""


def _fail(reason: str) -> CorruptStream:
    return CorruptStream(f"corrupt LZ stream: {reason}")


# -- decoding ----------------------------------------------------------------


def decompress(
    data: bytes, family: Family, *, allow_partial: bool = False
) -> tuple[bytes, int]:
    """Decode one structure from the start of ``data``.

    Returns ``(output, consumed)``, ``consumed`` counting through the
    terminator -- so a caller handing in an over-read buffer learns the
    structure's true extent, which is what a save-back has to fit back into.

    With ``allow_partial``, running out of source is not an error and the prefix
    decoded so far comes back. Structural corruption raises either way, which is
    what separates "this structure continues past the buffer" from "this is not
    a structure".
    """
    out = bytearray()
    n = len(data)
    i = 0

    def truncated(reason: str) -> tuple[bytes, int]:
        if allow_partial:
            return bytes(out), n
        raise _fail(reason)

    while True:
        if i >= n:
            return truncated("source exhausted before the $FF terminator")
        cmd = data[i]
        i += 1
        if cmd == _TERMINATOR:
            return bytes(out), i
        if (cmd & 0xE0) == 0xE0:  # long form
            if i >= n:
                return truncated("source exhausted inside a long-form header")
            length = (((cmd & 0x03) << 8) | data[i]) + 1
            i += 1
            op = (cmd << 3) & 0xE0
        else:
            length = (cmd & 0x1F) + 1
            op = cmd & 0xE0
        if len(out) + length > MAX_SIZE:
            raise _fail(f"output exceeds the {MAX_SIZE:#x}-byte cap")

        if op == _OP_LITERAL:
            if i + length > n:
                out += data[i:n]
                return truncated("source exhausted inside a literal run")
            out += data[i : i + length]
            i += length
        elif op == _OP_FILL:
            if i >= n:
                return truncated("source exhausted reading a fill byte")
            out += data[i : i + 1] * length
            i += 1
        elif op == _OP_WORD_FILL:
            if i + 2 > n:
                return truncated("source exhausted reading a word-fill pair")
            pair = data[i : i + 2]
            i += 2
            out += (pair * ((length + 1) // 2))[:length]
        elif op == _OP_INCREASING:
            if i >= n:
                return truncated("source exhausted reading an increasing-fill byte")
            value = data[i]
            i += 1
            out += bytes((value + k) & 0xFF for k in range(length))
        else:  # backreference -- all four high commands decode alike
            if i + 2 > n:
                return truncated("source exhausted reading a backreference offset")
            if family.big_endian_offsets:
                off = (data[i] << 8) | data[i + 1]
            else:
                off = data[i] | (data[i + 1] << 8)
            i += 2
            if off >= len(out):
                raise _fail(
                    f"backreference into unwritten output ({off:#x} >= {len(out):#x})"
                )
            # Byte at a time, forwards, so an offset inside what this command is
            # writing is a legal overlapping copy -- the format's run extension.
            for k in range(length):
                out.append(out[off + k])


# -- the shared search -------------------------------------------------------


class _MatchFinder:
    """A 3-byte-prefix index over one buffer, for finding backreferences.

    Positions are indexed as the parse passes them, never in advance: a
    candidate has to be somewhere the decoder will already have produced.
    There is no distance window -- the offset is absolute within the structure,
    so every earlier position is addressable.
    """

    __slots__ = ("_chain", "_data", "_index", "_n")

    def __init__(self, data: bytes, chain: int = _MAX_CHAIN) -> None:
        self._data = data
        self._n = len(data)
        self._chain = chain
        self._index: dict[bytes, list[int]] = {}

    def add(self, pos: int) -> None:
        if pos + _MIN_MATCH > self._n:
            return
        bucket = self._index.setdefault(self._data[pos : pos + _MIN_MATCH], [])
        bucket.append(pos)
        if len(bucket) > self._chain * 2:
            del bucket[: -self._chain]

    def add_run(self, start: int, stop: int) -> None:
        """Index the interior of an emitted match, which the parse steps over."""
        for pos in range(start, stop):
            self.add(pos)

    def _candidates(self, pos: int) -> list[int]:
        bucket = self._index.get(self._data[pos : pos + _MIN_MATCH])
        return list(reversed(bucket[-self._chain :])) if bucket else []

    def longest(self, pos: int, limit: int) -> tuple[int, int]:
        """The longest match at ``pos`` as ``(length, offset)``, or ``(0, 0)``.

        Counts legal self-overlap: the copy may run past ``pos``, so the source
        repeats with period ``pos - candidate``. A length routine that stopped
        at ``pos`` would give up the run extension the format offers for free.
        """
        data = self._data
        best_len, best_at = 0, 0
        for candidate in self._candidates(pos):
            distance = pos - candidate
            if best_len:
                # One comparison rules out a candidate that cannot beat the best
                # so far, which is what a long chain costs instead of measuring.
                offset = best_len if best_len < distance else best_len % distance
                if data[candidate + offset] != data[pos + best_len]:
                    continue
            length = 0
            while (
                length < limit
                and data[pos + length] == data[candidate + length % distance]
            ):
                length += 1
            if length > best_len:
                best_len, best_at = length, candidate
                if best_len == limit:
                    break
        return (best_len, best_at) if best_len >= _MIN_MATCH else (0, 0)


def _emit_header(out: bytearray, op: int, length: int) -> None:
    if length <= _MAX_SHORT:
        out.append(op | (length - 1))
    else:
        encoded = length - 1  # 0..1023
        out.append(0xE0 | ((op >> 3) & 0x1C) | (encoded >> 8))
        out.append(encoded & 0xFF)


def _header_cost(length: int) -> int:
    return 1 if length <= _MAX_SHORT else 2


def _payload(
    out: bytearray, data: bytes, op: int, at: int, off: int, big: bool
) -> None:
    if op == _OP_LITERAL:
        pass  # written by the caller, which knows the run's length
    elif op in (_OP_FILL, _OP_INCREASING):
        out.append(data[at])
    elif op == _OP_WORD_FILL:
        out += data[at : at + 2]
    else:
        out += bytes(((off >> 8) & 0xFF, off & 0xFF) if big else (off & 0xFF, off >> 8))


def _run_lengths(data: bytes) -> tuple[list[int], list[int], list[int]]:
    """How far fill, increasing and alternating reach from every position.

    These three are a property of the bytes alone, so measuring them everywhere
    once beats re-measuring per parse step.
    """
    n = len(data)
    fill = [1] * (n + 1)
    inc = [1] * (n + 1)
    alt = [1] * (n + 1)
    for i in range(n - 2, -1, -1):
        if data[i + 1] == data[i]:
            fill[i] = min(fill[i + 1] + 1, _MAX_LONG)
        if data[i + 1] == (data[i] + 1) & 0xFF:
            inc[i] = min(inc[i + 1] + 1, _MAX_LONG)
        # a,b,a,b,... continues exactly when data[i+2] repeats data[i]; the tail
        # from i+1 is the same shape with the pair swapped, so its length carries.
        alt[i] = (
            min(alt[i + 1] + 1, _MAX_LONG)
            if data[i + 2 : i + 3] == data[i : i + 1]
            else 2
        )
    return fill, inc, alt


# -- encoding ----------------------------------------------------------------


def _compress_greedy(data: bytes, big: bool, chain: int) -> bytes:
    """Greedy by benefit, with a one-step lazy deferral.

    At each position take the command that saves the most against literals --
    unless deferring one byte exposes a strictly longer one, in which case emit
    the byte and take the better command next. Milliseconds per blob, and about
    1% off the optimal parse.
    """
    n = len(data)
    out = bytearray()
    finder = _MatchFinder(data, chain)
    fill, inc, alt = _run_lengths(data)

    literal_start = -1

    def flush(end: int) -> None:
        nonlocal literal_start
        if literal_start < 0:
            return
        at = literal_start
        while at < end:
            chunk = min(end - at, _MAX_LONG)
            _emit_header(out, _OP_LITERAL, chunk)
            out.extend(data[at : at + chunk])
            at += chunk
        literal_start = -1

    def best_at(pos: int) -> tuple[int, int, int, int] | None:
        """``(op, length, cost, offset)`` for the best command, or ``None``."""
        best: tuple[int, int, int, int] | None = None

        def consider(op: int, length: int, cost: int, off: int = 0) -> None:
            nonlocal best
            if length < _MIN_MATCH or length - cost < 1:
                return
            if best is None or (length - cost, -cost) > (best[1] - best[2], -best[2]):
                best = (op, length, cost, off)

        consider(_OP_FILL, fill[pos], _header_cost(fill[pos]) + 1)
        consider(_OP_INCREASING, inc[pos], _header_cost(inc[pos]) + 1)
        if pos + 1 < n and data[pos] != data[pos + 1] and alt[pos] >= 4:
            consider(_OP_WORD_FILL, alt[pos], _header_cost(alt[pos]) + 2)
        room = n - pos
        length, off = finder.longest(pos, _MAX_LONG if _MAX_LONG < room else room)
        if length:
            consider(_OP_BACKREF, length, _header_cost(length) + 2, off)
        return best

    pos = 0
    while pos < n:
        chosen = best_at(pos)
        if chosen is not None:
            ahead = best_at(pos + 1) if pos + 1 < n else None
            if ahead is not None and ahead[1] > chosen[1]:
                chosen = None  # defer: a longer command starts one byte on
        if chosen is None:
            if literal_start < 0:
                literal_start = pos
            finder.add(pos)
            pos += 1
            continue
        op, length, _cost, off = chosen
        flush(pos)
        _emit_header(out, op, length)
        _payload(out, data, op, pos, off, big)
        finder.add_run(pos, pos + length)
        pos += length

    flush(n)
    out.append(_TERMINATOR)
    return bytes(out)


def compress(data: bytes, family: Family, *, smallest: bool = False) -> bytes:
    """Encode ``data`` as one structure in ``family``.

    The result decodes back to ``data`` exactly. It is **not** the bytes the
    cartridge shipped and nothing makes it so -- see the module docstring, and
    :func:`repack` for how byte-exactness is actually kept.

    ``smallest`` walks a deeper match chain: 0.19% smaller for about half again
    the time. Worth taking whenever the output has to *fit* something, which is
    every time this runs in earnest -- :func:`repack` hands back the shipped
    bytes for a file nobody edited, so anything that reaches here has changed
    and cannot match the cartridge however it is packed.
    """
    if len(data) > MAX_SIZE:
        raise ValueError(
            f"data is {len(data):#x} bytes; this family caps at {MAX_SIZE:#x}"
        )
    if not data:
        return bytes((_TERMINATOR,))
    chain = _DEEP_CHAIN if smallest else _MAX_CHAIN
    return _compress_greedy(data, family.big_endian_offsets, chain)


def repack(
    original: bytes, raw: bytes, family: Family, *, smallest: bool = False
) -> bytes:
    """The compressed form of ``raw``, keeping ``original`` when nothing changed.

    This is the whole of how a build stays byte-exact while still letting
    graphics be edited. Recompressing is not the inverse of decompressing -- a
    correct encoder reliably picks a *different* valid stream, and a better one
    picks a smaller stream that moves every address after it. So an unedited
    file is not re-encoded at all; it keeps the bytes the cartridge shipped, and
    only a file whose pixels actually changed pays a new parse.

    ``original`` is trusted to be the compressed form of what it decodes to, so
    the comparison is against the decode rather than against a re-encode.
    """
    try:
        decoded, _consumed = decompress(original, family)
    except CorruptStream:
        return compress(raw, family, smallest=smallest)
    if decoded == raw:
        return original
    return compress(raw, family, smallest=smallest)
