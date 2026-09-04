"""One SPC700 state, in the file format every music player reads.

An ``.spc`` is a snapshot of the sound chip and nothing else: the 64 KB of ARAM,
the DSP's 128 registers, and the processor registers to resume from. A player
restores the three and runs, which is why a song can be heard without the
cartridge that carried it.

**The state is a resumption, not a boot.** The registers say where the SPC700
was when the snapshot was taken, so a file that resumes into a driver's own
entry point runs that driver's initialisation -- and a file that resumes into
its main loop does not. Which of the two is wanted is the caller's to decide;
this module writes whatever state it is handed and reads nothing into it.

The layout is version 0.30's, every field at a fixed offset, and the whole file
is always :data:`FILE_SIZE` bytes. The ID666 tag is the block of text between
the registers and ARAM -- a title, a game, an artist -- which players show and
nothing depends on. Text is ASCII, truncated to its field and NUL-padded, since
each field is a fixed run of bytes rather than a string.

Standard library only and no Qt, like the rest of :mod:`smw_tools`: this takes
bytes and returns bytes.
"""

from __future__ import annotations

#: What the first bytes of every ``.spc`` say. A file that does not begin with
#: this is not one, which is the whole of the format's identification.
SIGNATURE = b"SNES-SPC700 Sound File Data v0.30"

#: The SPC700's whole address space, which the file carries in full.
ARAM_SIZE = 0x10000

#: The DSP's registers, in the order it numbers them.
DSP_SIZE = 0x80

#: The IPL ROM's 64 bytes. Only read while ``$F1``'s top bit is set, which a
#: driver running from ARAM clears, so a state that resumes into one may carry
#: zeros here and lose nothing.
IPL_SIZE = 0x40

#: Every ``.spc`` is exactly this long: the header, ARAM, the DSP and the IPL
#: ROM, none of them optional and none of them variable.
FILE_SIZE = 0x10200

# -- where each field is ------------------------------------------------------
#
# The offsets are the format's own and are not derived from each other, so each
# is written out rather than added up: a wrong one is then wrong in one place.

_MARK_AT = 0x21
#: The two bytes after the signature, and then the byte that says a text tag
#: follows. ``$1B`` in the third would say there is none; every field this
#: module writes lives in that tag, so it always says there is.
_MARK = bytes((0x1A, 0x1A, 0x1A))

_MINOR_AT = 0x24
_MINOR = 30

_PC_AT = 0x25
_A_AT = 0x27
_X_AT = 0x28
_Y_AT = 0x29
_PSW_AT = 0x2A
_SP_AT = 0x2B

#: Each text field of the ID666 tag: where it starts and how many bytes it has.
_TITLE = (0x2E, 32)
_GAME = (0x4E, 32)
_DUMPER = (0x6E, 16)
_COMMENT = (0x7E, 32)
_ARTIST = (0xB1, 32)

_ARAM_AT = 0x100
_DSP_AT = 0x10100
_IPL_AT = 0x101C0


class SpcError(ValueError):
    """A state that could not be written as an ``.spc``."""


def _text(into: bytearray, field: tuple[int, int], said: str) -> None:
    """Lay ``said`` into one fixed-width tag field, NUL-padded.

    Encoded as ASCII with anything outside it replaced rather than refused: a
    tag is what a player shows and never what it plays, so a song named with a
    character the format cannot hold is worth a ``?`` and not an error.
    """
    at, size = field
    held = said.encode("ascii", "replace")[: size - 1]
    into[at : at + len(held)] = held


def state(
    aram: bytes,
    *,
    pc: int,
    dsp: bytes = b"",
    a: int = 0,
    x: int = 0,
    y: int = 0,
    psw: int = 0,
    sp: int = 0xCF,
    title: str = "",
    game: str = "",
    artist: str = "",
    comment: str = "",
    dumper: str = "",
) -> bytes:
    """The ``.spc`` for one SPC700 state.

    ``aram`` is the full 64 KB and ``dsp`` the DSP's registers, short or empty
    for the zeros a reset leaves. ``pc`` is where the chip resumes; the rest of
    the registers default to what the SMW engine's own initialisation sets, so
    a state resuming into a driver need only say where.
    """
    if len(aram) != ARAM_SIZE:
        raise SpcError(f"ARAM is {len(aram)} bytes, not {ARAM_SIZE}")
    if len(dsp) > DSP_SIZE:
        raise SpcError(f"the DSP has {DSP_SIZE} registers, not {len(dsp)}")
    if not 0 <= pc < ARAM_SIZE:
        raise SpcError(f"${pc:04X} is not an address the SPC700 can resume at")

    out = bytearray(FILE_SIZE)
    out[: len(SIGNATURE)] = SIGNATURE
    out[_MARK_AT : _MARK_AT + len(_MARK)] = _MARK
    out[_MINOR_AT] = _MINOR
    out[_PC_AT : _PC_AT + 2] = pc.to_bytes(2, "little")
    out[_A_AT] = a & 0xFF
    out[_X_AT] = x & 0xFF
    out[_Y_AT] = y & 0xFF
    out[_PSW_AT] = psw & 0xFF
    out[_SP_AT] = sp & 0xFF

    _text(out, _TITLE, title)
    _text(out, _GAME, game)
    _text(out, _DUMPER, dumper)
    _text(out, _COMMENT, comment)
    _text(out, _ARTIST, artist)

    out[_ARAM_AT : _ARAM_AT + ARAM_SIZE] = aram
    out[_DSP_AT : _DSP_AT + len(dsp)] = dsp
    # The IPL ROM's run is left at zero: a state that resumes into a driver
    # running from ARAM has already turned it off, so nothing reads it.
    assert len(out) == FILE_SIZE
    return bytes(out)
