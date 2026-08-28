"""The cartridges' own LZ parse, as far as it is known.

**Nothing in the build uses this, and nothing should.** A build reaches the
graphics as shipped bytes -- `incbin "GFX/SMW_U/GFX00.lz2"` -- and
[`compression.repack`](compression.py) keeps those bytes for anything unedited,
which is exact by construction. This exists because how the cartridges were
packed is worth knowing, and because a complete version would let a build
regenerate every blob from its raw form and stop needing the shipped one.

## What it reproduces

Encoding each committed blob's decompressed form and comparing against the blob:

| Set | Family | Byte-identical |
|---|---|---|
| `SMW_U` | LZ2 | 37 / 52 |
| `SMW_J` | LZ1 | **52 / 52** |
| `SMW_E2` | LZ1 | **52 / 52** |
| | | **141 / 156** |

`J` and `E1` are exact. `U` is not, and is the whole of what is unknown.
Everything this emits decodes back to its input either way, so it is a correct
encoder throughout; what is partial is the *imitation*, and only for one
release.

## The parse

A single left-to-right pass, no lookahead and no cost comparison. At each
position the first rule that fires wins: a fill run (>= 3), a word run (>= 4),
then an increasing run (>= 3) and the longest backreference (>= 4) in whichever
order :class:`Rules` gives that release, and otherwise the byte joins a pending
literal run.

The runs pre-empt everything, which is what makes the parse reproducible at all:
each is detected wherever it starts, and every other command stops short of it.
A word run yields the boundary byte to a fill run beginning inside it, and an
increasing run yields to both. A backreference stops where a fill or word run
would start -- which is why the cartridges routinely split one long match into
ref/word/ref -- and whether an increasing run stops it too is one of the things
the two packers disagree about. Three details the data confirms:

- increasing runs do **not** wrap at `$FF`;
- among equal-length matches the **earliest** offset wins, not the nearest;
- the length caps are not uniform: fill 1024, word 1023, backreference 512.

## The releases were packed by two different tools

`J` and `E1` by one, `U`/`SS`/`E0` by another. :class:`Rules` is where they
differ, and they differ on all of it:

| | `J`, `E1` | `U`, `SS`, `E0` |
|---|---|---|
| A backreference reads bytes it is writing | never, 0 of 6,873 | yes, 34 of 3,385 |
| A backreference covers the file's last byte | never | yes |
| A backreference stops short of an increasing run | yes | no |
| A backreference outranks an increasing run | no | yes |
| Smallest backreference distance | 1 | 4 |
| Smallest distance while a literal run is open | 1 | 5 |

The two disagree on every rule the model has, which is what "different tools"
amounts to in practice.

The first two are absolutes in the data rather than tendencies; the second shows
up as a command stopping one byte short of `$C00` (or `$800` for the 2bpp files)
with that byte written as a one-byte literal. The last two are `U`'s alone and
are what keep it from taking the short, self-overlapping matches this model
otherwise finds attractive.

The evidence that there are two tools is direct: 44 graphics files decompress to
byte-identical bytes in `SMW_U` and `SMW_J`, and 30 of those ship **different
command streams** -- same input, different output.

## What is unknown

`SMW_U`, on 15 of its 52 files. `J` and `E1` are complete.

The gap is concentrated: 83 of the 85 places this model and the cartridge part
company are a backreference at distance exactly four inside an open literal run.
`U` both takes and declines those, and neither the match length nor the number
of literals already pending separates the two -- the distributions overlap. No
threshold on anything this model can see decides it, so closing the gap needs a
different shape -- lookahead, or a cost the packer weighed -- rather than
another rule here.

Two things it is not. `U`, `E0` and `SS` embed byte-identical graphics, so there
is no second packing of the same input to compare against as there is for `J`.
And nothing is carried between files: the failures do not cluster by position in
the ROM's concatenation order.

`smw/tmp/decision_oracle.py` measures this: it replays the cartridge's own
command list and asks what this model would choose at each of its positions,
which localises a disagreement instead of reporting the cascade that follows it.
`smw/tmp/cart_parse_search.py` searches the rule space.
"""

from __future__ import annotations

from dataclasses import dataclass

from .compression import Family, family_for

#: Lengths each command may cover. Not uniform, and confirmed against the data.
MAX_SHORT = 32
MAX_FILL = 1024
MAX_WORD = 1023
MAX_INC = 1024
MAX_MATCH = 512
MAX_LITERAL = 1024

#: Lengths at which each command becomes worth emitting.
MIN_FILL = 3
MIN_WORD = 4
MIN_INC = 3
MIN_MATCH = 4

_OP_LITERAL = 0x00
_OP_FILL = 0x20
_OP_WORD = 0x40
_OP_INC = 0x60
_OP_BACKREF = 0x80


@dataclass(frozen=True)
class Rules:
    """How one release's packer behaved, where the two disagree."""

    #: May a backreference read bytes the same command is writing?
    overlap: bool
    #: May a backreference cover the last byte of the file, or must that byte
    #: always be written as a literal?
    may_end_the_file: bool
    #: Must a backreference stop short of an increasing run, as it must stop
    #: short of a fill or a word run?
    yields_to_inc: bool = True
    #: Does a backreference outrank an increasing run at the same position?
    ref_before_inc: bool = False
    #: Smallest distance a backreference may reach back.
    min_distance: int = 1
    #: Smallest distance allowed while a literal run is already pending. `J`
    #: and `E1` need no floor -- forbidding overlap is already one.
    min_distance_in_literal: int = 1
    #: Does that floor let through a match which runs past its own distance?
    #: `U` writes `ref12` at distance 4 with a literal run open, and declines
    #: `ref4` in the same spot, so what it refuses is a short copy near its
    #: source rather than a near match as such.
    near_extension_in_literal: bool = False


#: The packer behind `U`, `SS` and `E0`. `SS` and `E0` read the `U` asset set,
#: and `E1` reads `SMW_E2` and behaves as `J` does.
_LZ2_PACKER = Rules(
    overlap=True,
    may_end_the_file=True,
    yields_to_inc=False,
    ref_before_inc=True,
    min_distance=4,
    min_distance_in_literal=5,
    near_extension_in_literal=True,
)

#: The packer behind `J` and `E1`, which disagrees with it on every rule here.
_LZ1_PACKER = Rules(
    overlap=False,
    may_end_the_file=False,
    yields_to_inc=True,
    ref_before_inc=False,
    min_distance=1,
    min_distance_in_literal=1,
)

RULES: dict[str, Rules] = {
    "U": _LZ2_PACKER,
    "SS": _LZ2_PACKER,
    "E0": _LZ2_PACKER,
    "J": _LZ1_PACKER,
    "E1": _LZ1_PACKER,
}

#: What each version's parse reproduces of its own set, pinned so a change that
#: improves or regresses the imitation is visible. Keyed by asset set.
REPRODUCES: dict[str, int] = {"SMW_U": 37, "SMW_J": 52, "SMW_E2": 52}


def rules_for(version: str) -> Rules:
    """How ``version``'s packer behaved."""
    try:
        return RULES[version]
    except KeyError:
        raise ValueError(
            f"unknown version {version!r}; expected one of {sorted(RULES)}"
        ) from None


def encode(raw: bytes, version: str) -> bytes:
    """Encode ``raw`` the way ``version``'s cartridge packer would have.

    **Exact for `J`, `E1` and every file of their sets.** For `U`, `SS` and `E0`
    it is correct but only partly faithful -- see :data:`REPRODUCES`. The result
    always decodes back to ``raw`` either way. Use
    :func:`compression.compress` for anything that has to be small, and
    :func:`compression.repack` for anything that has to be byte-exact.
    """
    return _encode(raw, family_for(version), rules_for(version))


def _encode(data: bytes, family: Family, rules: Rules) -> bytes:
    n = len(data)
    if n == 0:
        return b"\xff"
    if n > 0x10000:
        raise ValueError(f"{n:#x} bytes exceeds the format's 0x10000-byte cap")

    # The three run kinds, measured everywhere at once: each is a property of
    # the bytes alone, so one backward pass beats re-measuring per step.
    fill = [1] * n
    word = [0] * n
    inc = [1] * n
    for i in range(n - 1, -1, -1):
        if i + 1 < n and data[i + 1] == data[i]:
            fill[i] = min(fill[i + 1] + 1, MAX_FILL)
        # No wrap: at $FF, data[i] + 1 is 0x100 and matches nothing.
        if i + 1 < n and data[i + 1] == data[i] + 1:
            inc[i] = min(inc[i + 1] + 1, MAX_INC)
        word[i] = (
            min(word[i + 1] + 1, MAX_WORD)
            if i + 2 < n and data[i + 2] == data[i]
            else min(2, n - i)
        )

    # Runs pre-empt everything, so each command has to stop where the next run
    # begins. Built back to front so asking costs nothing.
    next_fill = [n] * (n + 1)
    next_word = [n] * (n + 1)
    next_run = [n] * (n + 1)
    word_len = [0] * n
    inc_len = [0] * n
    for i in range(n - 1, -1, -1):
        next_fill[i] = i if fill[i] >= MIN_FILL else next_fill[i + 1]
        word_len[i] = min(word[i], next_fill[i + 1] - i)
        next_word[i] = i if word_len[i] >= MIN_WORD else next_word[i + 1]
        inc_len[i] = min(inc[i], next_fill[i + 1] - i, next_word[i + 1] - i)
        stops = fill[i] >= MIN_FILL or word_len[i] >= MIN_WORD
        if rules.yields_to_inc:
            stops = stops or inc_len[i] >= MIN_INC
        next_run[i] = i if stops else next_run[i + 1]

    # Oldest-first chains, so the earliest offset wins among equal matches.
    chains: dict[bytes, list[int]] = {}
    indexed = 0

    def index_up_to(end: int) -> None:
        nonlocal indexed
        while indexed < end and indexed + MIN_MATCH <= n:
            chains.setdefault(data[indexed : indexed + MIN_MATCH], []).append(indexed)
            indexed += 1

    def match_at(at: int):
        limit = min(MAX_MATCH, n - at, next_run[at + 1] - at)
        if not rules.may_end_the_file:
            limit = min(limit, n - 1 - at)
        if limit < MIN_MATCH:
            return None
        index_up_to(at)
        best = best_off = 0
        for q in chains.get(data[at : at + MIN_MATCH], ()):
            if q >= at:
                break
            distance = at - q
            if distance < rules.min_distance:
                continue
            # Without overlap a copy may not outrun its own source.
            reach = limit if rules.overlap else min(limit, distance)
            if reach < MIN_MATCH:
                continue
            if best and data[q + best] != data[at + best]:
                continue
            length = 0
            while length < reach and data[at + length] == data[q + length]:
                length += 1
            if length > best:  # strictly greater: ties keep the earlier offset
                best, best_off = length, q
                if best == limit:
                    break
        return (_OP_BACKREF, best, at, best_off) if best >= MIN_MATCH else None

    cmds: list[tuple[int, int, int, int]] = []
    lit_start = -1

    def flush(end: int) -> None:
        nonlocal lit_start
        if lit_start < 0:
            return
        for i in range(lit_start, end, MAX_LITERAL):
            cmds.append((_OP_LITERAL, min(end - i, MAX_LITERAL), i, 0))
        lit_start = -1

    at = 0
    while at < n:
        if fill[at] >= MIN_FILL:
            chosen = (_OP_FILL, fill[at], at, 0)
        elif word_len[at] >= MIN_WORD:
            chosen = (_OP_WORD, word_len[at], at, 0)
        elif rules.ref_before_inc:
            chosen = match_at(at) or (
                (_OP_INC, inc_len[at], at, 0) if inc_len[at] >= MIN_INC else None
            )
        elif inc_len[at] >= MIN_INC:
            chosen = (_OP_INC, inc_len[at], at, 0)
        else:
            chosen = match_at(at)
        # A backreference too near its source is not taken at all while a
        # literal run is open -- it does not fall through to another command.
        # Unless it runs *past* its own distance: a periodic extension is
        # welcome however near its source, and a plain short copy is not.
        if (
            chosen
            and chosen[0] == _OP_BACKREF
            and lit_start >= 0
            and at - chosen[3] < rules.min_distance_in_literal
            and not (rules.near_extension_in_literal and chosen[1] > at - chosen[3])
        ):
            chosen = None
        if chosen:
            flush(at)
            cmds.append(chosen)
            at += chosen[1]
            continue
        if lit_start < 0:
            lit_start = at
        at += 1
    flush(n)

    big = family.big_endian_offsets
    out = bytearray()
    for op, length, pos, off in cmds:
        if length <= MAX_SHORT:
            out.append(op | (length - 1))
        else:
            encoded = length - 1
            out.append(0xE0 | ((op >> 3) & 0x1C) | (encoded >> 8))
            out.append(encoded & 0xFF)
        if op == _OP_LITERAL:
            out += data[pos : pos + length]
        elif op in (_OP_FILL, _OP_INC):
            out.append(data[pos])
        elif op == _OP_WORD:
            out += data[pos : pos + 2]
        else:
            out += bytes(
                ((off >> 8) & 0xFF, off & 0xFF) if big else (off & 0xFF, off >> 8)
            )
    out.append(0xFF)
    return bytes(out)
