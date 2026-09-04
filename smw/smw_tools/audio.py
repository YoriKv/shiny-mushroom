"""The cartridge's audio: what the SPC700 is sent, and what it holds.

The audio hardware is a second computer with its own 64 KB of memory, and the
65816 reaches it through four bytes. Everything this module answers follows from
that: what is uploaded into ARAM and where it lands, what the engine finds at
those addresses, and which of the four mailboxes asks for it.

**Everything the 65816 uploads is one stream format.** ``%SPCDataBlockStart``
emits ``[length:u16][ARAM destination:u16][payload]`` per block and
``%EndSPCUploadAndJumpToEngine`` closes the stream with ``[0000][entry]``, which
is the IPL ROM's own upload protocol -- ``SMW_HandleSPCUploads`` walks exactly
that. So a block's destination and extent are *in the ROM*, not inferred:
:func:`read_stream` reads them back, and nothing here has to declare where
anything lands.

**The engine blob does not close its stream.** ``Engine.asm`` ends without the
terminator macro, so the boot upload runs on into whatever the ROM map placed
next -- the overworld music bank -- and stops at *its* terminator. Engine, sound
effects and the title screen's music therefore arrive as one upload, which is
why :func:`read_stream` is bounded by a limit as well as by the terminator and
reports which of the two stopped it.

**One ARAM window, three occupants.** The music bank at
``!ARAM_SMW_MusicBankLoc`` is written by whichever of the three music blobs was
uploaded last -- level, overworld or credits -- so the window's wall is set by
the largest of them and not by any one. :func:`compose` builds the ARAM image
for one of those three, which is the only form in which the question "what is in
memory" has an answer.

**The sequence format is N-SPC.** A song is a list of phrase pointers; a phrase
is eight channel pointers, one per DSP voice, zero where the channel is silent;
a channel is a byte stream this module walks with :func:`track_end`. The grammar
is read off ``Engine.asm``'s own dispatch: a byte under ``$80`` is a duration,
optionally followed by a velocity byte, ``$80``-``$D9`` is a note, ``$DA`` and up
is a command whose length comes from ``CommandLengthTable``, and ``$00`` ends the
stream. Walking it is what turns "where does this song start" into "how many
bytes is it", which no pointer table says.

Standard library only and no Qt, like the rest of :mod:`smw_tools`: this reads
bytes and returns numbers.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Iterator, Mapping
from dataclasses import dataclass
from pathlib import Path

#: The SPC700's whole address space.
ARAM_SIZE = 0x10000

#: Where the four mailboxes are in the 65816's memory. The game writes a value
#: into one of these and ``SMW_VBlankRoutine`` passes it to the APU ports; the
#: names are the disassembly's own (``!RAM_SMW_IO_SoundCh1`` and up).
MUSIC_PORT = 0x7E1DFB
SFX_PORTS = (0x7E1DF9, 0x7E1DFA, 0x7E1DFC)

#: Which of the SPC700's four ports each mailbox reaches, from the copy
#: ``SMW_VBlankRoutine`` makes every frame: the music mailbox goes to port 2 and
#: the three effect mailboxes to ports 0, 1 and 3. The engine polls each port in
#: turn, so this is what says where a value has to be put to be heard.
APU_PORTS = {
    SFX_PORTS[0]: 0,
    SFX_PORTS[1]: 1,
    MUSIC_PORT: 2,
    SFX_PORTS[2]: 3,
}

#: Where the SPC700 reads the four ports, which is also where a saved state
#: carries their last values.
PORT_LATCHES = 0x00F4

#: The blob labels ``SMW_HandleSPCUploads`` points its uploader at, by the
#: namespaced name the build's symbol file carries. The order is the order a
#: playing cartridge uploads them in: the engine at boot, samples once, and then
#: whichever music bank the game mode wants.
NAMESPACE = "SMW_HandleSPCUploads"
ENGINE_BLOB = "SPC700Engine"
SAMPLES_BLOB = "SPC700Samples"
LEVEL_MUSIC_BLOB = "LevelMusicBank"
OVERWORLD_MUSIC_BLOB = "OverworldMusicBank"
CREDITS_MUSIC_BLOB = "CreditsMusicBank"

#: The three blobs that write the music window, and the mailbox values each
#: one's pointer table covers. Every one of them is uploaded to the same place,
#: which is the whole point of listing them together.
MUSIC_BLOBS = (LEVEL_MUSIC_BLOB, OVERWORLD_MUSIC_BLOB, CREDITS_MUSIC_BLOB)

#: How many entries each music bank's pointer table holds. The count is the
#: format -- the table is indexed by the mailbox value with no bound check, so
#: reading past it is what a bad value does rather than something the data says.
#: Read off the ``dw`` runs under each blob's ``MusicPtrs``.
MUSIC_COUNTS = {
    LEVEL_MUSIC_BLOB: 0x1D,
    OVERWORLD_MUSIC_BLOB: 0x09,
    CREDITS_MUSIC_BLOB: 0x0C,
}

#: Voices the DSP has, and so channel pointers in a phrase.
CHANNELS = 8

#: A phrase: eight ``dw`` channel pointers.
PHRASE_SIZE = CHANNELS * 2

#: What a word in a song's phrase list means when it is not a phrase pointer.
SONG_END = 0x0000
SONG_LOOP = 0x00FF

#: The first command byte, and ``CommandLengthTable`` from ``Engine.asm`` --
#: one length per command from :data:`VCMD_FIRST` up, counting the command byte
#: itself. The dispatch is ``JMP (CommandDispatchTable-$B4+X)`` with ``X`` twice
#: the command byte, which is what puts the first command at ``$DA``.
VCMD_FIRST = 0xDA
VCMD_LENGTHS = (
    0x02, 0x02, 0x03, 0x04, 0x04, 0x01,
    0x02, 0x03, 0x02, 0x03, 0x02, 0x04, 0x01, 0x02,
    0x03, 0x04, 0x02, 0x04, 0x04, 0x01, 0x02, 0x04,
    0x01, 0x04, 0x04,
)  # fmt: skip
VCMD_LAST = VCMD_FIRST + len(VCMD_LENGTHS) - 1

#: The lowest note byte. Below it a byte is a duration; from here to
#: :data:`VCMD_FIRST` it is a note, a tie, a rest or a percussion note.
NOTE_FIRST = 0x80

#: The percussion notes, which index :data:`PERCUSSION_STRIDE` records rather
#: than naming a pitch -- ``CODE_05CE`` subtracts this before the lookup.
PERCUSSION_FIRST = 0xD0

#: The regions of ARAM no upload ever writes, which is why nothing in the ROM
#: describes them. The engine's boot clears ``$0000``-``$00E7`` and
#: ``$0200``-``$03FF``; the stack pointer starts at ``$01CF``; ``$00F0``-``$00FF``
#: is the SPC700's own register window. ``$0400``-``$04FF`` is cleared by nothing
#: and used by nothing except the Japanese build, which leaves ``$A5 $5A`` in its
#: last two bytes to recognise an engine that is already running.
FIXED_REGIONS = (
    (0x0000, 0x00F0, "Engine variables"),
    (0x00F0, 0x0100, "SPC700 registers"),
    (0x0100, 0x0200, "Stack"),
    (0x0200, 0x0400, "Channel state"),
    (0x0400, 0x0500, "Warm-boot marker"),
)


class AudioError(ValueError):
    """A stream, table or sequence that is not in the format described here."""


# -- what the 65816 uploads ---------------------------------------------------


@dataclass(frozen=True)
class UploadBlock:
    """One ``[length][destination][payload]`` block of an upload stream."""

    #: Where in ARAM the payload lands.
    aram: int
    size: int
    #: Where the payload is in the headerless ROM image.
    rom: int

    @property
    def end(self) -> int:
        """One past the block's last ARAM byte."""
        return self.aram + self.size


@dataclass(frozen=True)
class UploadStream:
    """A blob as the uploader walks it: its blocks and how it ended.

    ``entry`` is the ARAM address the terminator hands the SPC700, and is
    ``None`` for a stream that ran to its limit without one -- which the engine
    blob does by design, so it is a shape rather than a fault.
    """

    rom: int
    blocks: tuple[UploadBlock, ...]
    entry: int | None

    @property
    def size(self) -> int:
        """How many ROM bytes the stream occupies, headers included."""
        payload = sum(block.size + 4 for block in self.blocks)
        return payload + (4 if self.entry is not None else 0)

    @property
    def terminated(self) -> bool:
        return self.entry is not None


def read_stream(rom: bytes, offset: int, limit: int) -> UploadStream:
    """Walk one upload stream from ``offset``, stopping at its terminator or at
    ``limit``.

    ``limit`` is where the *next* thing in the ROM begins. A stream that reaches
    it without a terminator is one whose upload runs on into that next thing,
    which is what the engine blob does; a block that would cross it is a stream
    this format cannot read and says so.
    """
    blocks: list[UploadBlock] = []
    at = offset
    while at + 4 <= limit:
        size = rom[at] | rom[at + 1] << 8
        destination = rom[at + 2] | rom[at + 3] << 8
        at += 4
        if size == 0:
            return UploadStream(offset, tuple(blocks), destination)
        if at + size > limit:
            raise AudioError(
                f"the block at ${at - 4:06X} runs {at + size - limit} bytes "
                f"past ${limit:06X}, where the next blob begins"
            )
        if destination + size > ARAM_SIZE:
            raise AudioError(
                f"the block at ${at - 4:06X} lands at ${destination:04X} and "
                f"would run past the end of ARAM"
            )
        blocks.append(UploadBlock(destination, size, at))
        at += size
    return UploadStream(offset, tuple(blocks), None)


def compose(rom: bytes, streams: Iterable[UploadStream]) -> bytes:
    """The ARAM image the given streams leave behind, applied in order.

    Later blocks overwrite earlier ones exactly as a second upload does, which
    is how the three music banks share one window.
    """
    aram = bytearray(ARAM_SIZE)
    for stream in streams:
        for block in stream.blocks:
            aram[block.aram : block.end] = rom[block.rom : block.rom + block.size]
    return bytes(aram)


# -- auditioning one value ----------------------------------------------------

#: ``MOV A,#$F0`` then ``MOV $00F1,A``, the write ``SPC700_Engine`` makes near
#: the end of its initialisation. Bits 4 and 5 of the control register clear the
#: four port latches, so the engine wipes whatever the ports held before it ever
#: polls one -- which on a cartridge is right, and for a saved state that was
#: handed a value is the difference between a song and silence.
PORT_CLEAR = bytes((0xE8, 0xF0, 0xC5, 0xF1, 0x00))

#: The same write with those two bits taken out, which leaves the latches
#: alone. Everything else the byte says -- the IPL ROM bit, the timers -- is
#: unchanged, and four instructions later the engine writes the register again
#: with the value it always does.
PORT_KEEP = 0xC0

#: Where the neutralised bits sit in :data:`PORT_CLEAR`.
_CLEAR_OPERAND = 1


def primed(aram: bytes, ports: Mapping[int, int]) -> bytes:
    """``aram`` with ``ports`` in the latches and the engine made to keep them.

    ``ports`` is keyed by SPC700 port, ``0`` to ``3`` -- :data:`APU_PORTS` maps
    a mailbox to one. The result is an image that boots the engine from its own
    entry point and finds the given value already asked for, which is what
    turns a cartridge's ARAM into an audition of one song or one effect.

    Two things have to be true of it and both are checked rather than assumed:
    the engine's port-clearing write is in there exactly once, and no caller
    named a port that does not exist. A modified engine that no longer makes
    that write in that shape cannot be auditioned this way, and says so instead
    of being handed back an image that plays nothing.
    """
    for port in ports:
        if not 0 <= port <= 3:
            raise AudioError(f"the SPC700 has ports 0 to 3, not {port}")
    found = [
        at
        for at in range(len(aram) - len(PORT_CLEAR) + 1)
        if aram[at : at + len(PORT_CLEAR)] == PORT_CLEAR
    ]
    if len(found) != 1:
        raise AudioError(
            f"the engine's port-clearing write appears {len(found)} times in "
            f"ARAM, not once, so this engine cannot be auditioned"
        )
    out = bytearray(aram)
    out[found[0] + _CLEAR_OPERAND] = PORT_KEEP
    for port, value in ports.items():
        out[PORT_LATCHES + port] = value & 0xFF
    return bytes(out)


# -- the sequences ------------------------------------------------------------


def track_end(aram: bytes, start: int) -> int:
    """One past the ``$00`` that ends the channel track at ``start``.

    The walk is ``Engine.asm``'s own: ``CODE_0C57`` fetches a byte and ``$00``
    ends the track, a byte under :data:`NOTE_FIRST` is a duration which may be
    followed by one velocity byte, and the byte that follows either dispatches
    as a command from :data:`VCMD_FIRST` up or is a note.

    **Only the first byte of the three ends anything.** After a duration the
    engine tests the next byte for its sign and nothing else, so a ``$00``
    behind one is a velocity of zero, and a ``$00`` behind *that* is dispatched
    as a note. Ending the walk on either reads a track short.
    """
    at = start
    while True:
        if at >= ARAM_SIZE:
            raise AudioError(f"the track at ${start:04X} runs off the end of ARAM")
        byte = aram[at]
        at += 1
        if byte == 0x00:
            return at
        if byte < NOTE_FIRST:
            byte = aram[at]  # the velocity, or the note or command
            at += 1
            if byte < NOTE_FIRST:
                byte = aram[at]  # taken as the note or command whatever it is
                at += 1
        if byte >= VCMD_FIRST:
            if byte > VCMD_LAST:
                raise AudioError(
                    f"${byte:02X} at ${at - 1:04X} is past the last command "
                    f"${VCMD_LAST:02X}"
                )
            at += VCMD_LENGTHS[byte - VCMD_FIRST] - 1


@dataclass(frozen=True)
class Song:
    """One entry of a music bank's pointer table, walked.

    ``spans`` is every ``(start, end)`` range in ARAM the song reaches -- its own
    phrase list, each phrase's channel pointers and every channel track -- merged
    and in order. Songs share phrases and tracks freely (the credits are four
    entries over one body of data), so a span here is not this song's alone and
    :attr:`size` is what it *reaches*, not what it would free.
    """

    #: The value written to :data:`MUSIC_PORT` to ask for it.
    value: int
    #: Where its phrase list is in ARAM.
    pointer: int
    phrases: tuple[int, ...]
    #: The phrase the song loops back to, or ``None`` for one that plays once.
    loop_to: int | None
    #: Which of the eight channels any of its phrases uses.
    channels: frozenset[int]
    spans: tuple[tuple[int, int], ...]

    @property
    def size(self) -> int:
        return sum(end - start for start, end in self.spans)


def merged(spans: Iterable[tuple[int, int]]) -> tuple[tuple[int, int], ...]:
    """Overlapping and touching ranges joined, in address order.

    What makes a set of spans answerable as a size: songs share phrases and
    tracks, so adding their extents up counts the shared bytes twice.
    """
    out: list[tuple[int, int]] = []
    for start, end in sorted(spans):
        if out and start <= out[-1][1]:
            out[-1] = (out[-1][0], max(out[-1][1], end))
        else:
            out.append((start, end))
    return tuple(out)


def _word(aram: bytes, at: int) -> int:
    return aram[at] | aram[at + 1] << 8


def read_song(aram: bytes, value: int, pointer: int) -> Song:
    """Walk one song from its phrase list."""
    phrases: list[int] = []
    loop_to: int | None = None
    at = pointer
    while True:
        if at + 2 > ARAM_SIZE:
            raise AudioError(f"the song at ${pointer:04X} runs off the end of ARAM")
        word = _word(aram, at)
        at += 2
        if word == SONG_END:
            break
        if word == SONG_LOOP:
            loop_to = _word(aram, at)
            at += 2
            break
        phrases.append(word)
    spans = [(pointer, at)]
    channels: set[int] = set()
    for phrase in phrases:
        spans.append((phrase, phrase + PHRASE_SIZE))
        for channel in range(CHANNELS):
            track = _word(aram, phrase + channel * 2)
            if track:
                channels.add(channel)
                spans.append((track, track_end(aram, track)))
    return Song(
        value, pointer, tuple(phrases), loop_to, frozenset(channels), merged(spans)
    )


def read_songs(aram: bytes, table: int, count: int) -> tuple[Song, ...]:
    """Every song a music bank's pointer table names, by mailbox value.

    The table is indexed from one: value ``$01`` is its first word, because
    ``$00`` is the mailbox's "nothing asked for".
    """
    return tuple(
        read_song(aram, value, _word(aram, table + (value - 1) * 2))
        for value in range(1, count + 1)
    )


# -- the sound effects --------------------------------------------------------

#: What the sound effect bank holds at its head, in order, and the strides.
#: ``SFXInstrumentTable`` is nine bytes a record -- eight written straight to
#: voice 4's DSP registers (volume, pitch, source, ADSR and gain) and a ninth
#: kept as the pitch multiplier -- and the two pointer tables follow it.
SFX_INSTRUMENT_STRIDE = 9
SFX_INSTRUMENTS = 19

#: The two pointer tables in the sound effect bank, in the order they are
#: written, with the mailbox each answers and how many entries it has.
SFX_TABLES = (
    (0x7E1DFC, 52),
    (0x7E1DF9, 42),
)

#: The three commands a sound effect stream has, and how many bytes follow
#: each. ``CODE_08AF`` tests for exactly these and treats every other byte from
#: :data:`NOTE_FIRST` up as a note, so the music engine's twenty-five commands
#: and its ``CommandLengthTable`` have nothing to do with this stream.
#: ``$DA``'s count is the minimum: an argument of its own from
#: :data:`NOTE_FIRST` up is a pan setting, and the instrument follows it.
SFX_VCMD_ARGS = {0xDA: 1, 0xDD: 4, 0xEB: 3}

#: What ends a sound effect. ``$00`` stops it; ``$FF`` is where a sound that
#: holds until something else stops it -- the drum roll, the Valley of Bowser
#: fanfare -- parks, because ``CODE_08AF`` steps the pointer back onto it and
#: reads it again forever.
SFX_END = 0x00
SFX_HOLD = 0xFF


@dataclass(frozen=True)
class Sfx:
    """One entry of a sound effect pointer table."""

    #: Which mailbox asks for it.
    port: int
    #: The value written to that mailbox.
    value: int
    pointer: int
    spans: tuple[tuple[int, int], ...]

    @property
    def size(self) -> int:
        return sum(end - start for start, end in self.spans)


def sfx_tables(bank: int) -> tuple[tuple[int, int, int], ...]:
    """Where each sound effect pointer table sits, given the bank's ARAM base.

    ``(port, table address, entry count)``. Derived rather than declared: the
    tables follow ``SFXInstrumentTable`` at the head of the block, so the only
    literals are the strides and counts above, which
    ``smw/tests/test_audio.py`` holds against ``sfx.asm``.
    """
    at = bank + SFX_INSTRUMENTS * SFX_INSTRUMENT_STRIDE
    out = []
    for port, count in SFX_TABLES:
        out.append((port, at, count))
        at += count * 2
    return tuple(out)


def sfx_end(aram: bytes, start: int) -> int:
    """One past the last byte of the sound effect at ``start``.

    A **different grammar from the music's**, and the engine reads it with
    different code (``CODE_087D``): a byte under :data:`NOTE_FIRST` is a
    duration, which may be followed by one volume byte or by two, and then comes
    a note or one of the three commands in :data:`SFX_VCMD_ARGS`. Only the third
    byte after a duration is taken as the command whatever its value, so a
    ``$00`` there is a note rather than an ending.
    """
    at = start
    while True:
        if at >= ARAM_SIZE:
            raise AudioError(f"the effect at ${start:04X} runs off the end of ARAM")
        byte = aram[at]
        at += 1
        if byte == SFX_END:
            return at
        if byte < NOTE_FIRST:
            byte = aram[at]  # the left volume, or the command
            at += 1
            if byte < NOTE_FIRST:
                byte = aram[at]  # the right volume, or the command
                at += 1
                if byte < NOTE_FIRST:
                    byte = aram[at]  # taken as the command whatever it is
                    at += 1
        if byte == SFX_HOLD:
            return at
        if byte == 0xDA and aram[at] >= NOTE_FIRST:
            # A pan setting of its own, with the instrument behind it.
            at += 1
        at += SFX_VCMD_ARGS.get(byte, 0)


def read_sfx(aram: bytes, bank: int) -> tuple[Sfx, ...]:
    """Every sound effect both tables name, in table then value order.

    Entries repeat -- several values point at one effect, which the tables' own
    comments call clones -- so two rows can share a span.
    """
    found: list[Sfx] = []
    for port, table, count in sfx_tables(bank):
        for value in range(1, count + 1):
            pointer = _word(aram, table + (value - 1) * 2)
            spans = ((pointer, sfx_end(aram, pointer)),) if pointer else ()
            found.append(Sfx(port, value, pointer, spans))
    return tuple(found)


# -- the samples and the instruments ------------------------------------------

#: A BRR block: a header byte and eight bytes of packed samples. Bit 0 of the
#: header ends the sample and bit 1 marks it as looping.
BRR_BLOCK = 9
BRR_END = 0x01
BRR_LOOP = 0x02


@dataclass(frozen=True)
class Sample:
    """One entry of the sample directory: where a sample starts and loops."""

    index: int
    start: int
    #: Where the DSP resumes when the sample ends, which is the sample's own
    #: start for one that repeats whole.
    loop: int
    size: int
    #: Whether the last block asks the DSP to loop rather than stop.
    loops: bool


def sample_end(aram: bytes, start: int) -> int:
    """One past the last byte of the BRR sample at ``start``.

    Walked block by block to the one whose header sets :data:`BRR_END`, which is
    the only thing that says where a sample ends -- the directory gives a start
    and a loop point and no length at all.
    """
    at = start
    while at + BRR_BLOCK <= ARAM_SIZE:
        header = aram[at]
        at += BRR_BLOCK
        if header & BRR_END:
            return at
    raise AudioError(f"the sample at ${start:04X} has no end block")


def read_samples(aram: bytes, directory: int, count: int) -> tuple[Sample, ...]:
    """The sample directory: ``count`` pairs of ``[start][loop]`` words.

    The DSP reads this table itself, indexed by an instrument record's source
    number, so its address is a hardware setting rather than an engine one.
    """
    out = []
    for index in range(count):
        at = directory + index * 4
        start = _word(aram, at)
        loop = _word(aram, at + 2)
        end = sample_end(aram, start)
        out.append(
            Sample(
                index,
                start,
                loop,
                end - start,
                bool(aram[end - BRR_BLOCK] & BRR_LOOP),
            )
        )
    return tuple(out)


#: An instrument record, as ``VCMD_SetInstrument`` applies it: four bytes
#: straight to the voice's DSP registers -- source number, both ADSR bytes and
#: gain -- and a fifth kept as the channel's pitch multiplier.
INSTRUMENT_STRIDE = 5

#: A percussion record: an instrument record and the note it plays, which is
#: what makes it percussion. ``CODE_05CE`` reaches it for note bytes from
#: :data:`PERCUSSION_FIRST` up.
PERCUSSION_STRIDE = 6
PERCUSSION_COUNT = 9

#: How many instrument records the music instrument table holds.
INSTRUMENT_COUNT = 19


@dataclass(frozen=True)
class Instrument:
    """One instrument or percussion record."""

    index: int
    #: Which sample the DSP plays: the index into the sample directory.
    source: int
    adsr: tuple[int, int]
    gain: int
    #: What the note's pitch is multiplied by, so one sample can cover octaves.
    multiplier: int
    #: The note a percussion record plays, and ``None`` for an instrument.
    note: int | None = None


def read_instruments(
    aram: bytes, table: int, count: int, *, percussion: bool = False
) -> tuple[Instrument, ...]:
    """``count`` records from ``table``, as instruments or as percussion."""
    stride = PERCUSSION_STRIDE if percussion else INSTRUMENT_STRIDE
    out = []
    for index in range(count):
        at = table + index * stride
        out.append(
            Instrument(
                index,
                aram[at],
                (aram[at + 1], aram[at + 2]),
                aram[at + 3],
                aram[at + 4],
                aram[at + 5] & 0x7F if percussion else None,
            )
        )
    return tuple(out)


# -- what the game calls them -------------------------------------------------

#: The define prefixes that name a music value, by the blob whose table they
#: index. The disassembly names every value it writes to a mailbox, so this is
#: the game's own vocabulary rather than a list copied from anywhere.
MUSIC_DEFINES = {
    LEVEL_MUSIC_BLOB: "Define_SMW_LevelMusic_",
    OVERWORLD_MUSIC_BLOB: "Define_SMW_OverworldMusic_",
    CREDITS_MUSIC_BLOB: "Define_SMW_CreditsMusic_",
}

#: The define prefix that names a sound effect value, by mailbox.
SFX_DEFINES = {port: f"Define_SMW_Sound{port & 0xFFFF:04X}_" for port in SFX_PORTS}

#: A define this reads: a literal, or an earlier define with a signed hex
#: offset. Both forms are in the tree -- ``!..._Wrong`` is written as
#: ``!..._Correct+$01``, because the two really are consecutive entries of one
#: table and saying so is better than repeating the number. Reading only the
#: literal form would leave that value looking unnamed, which is a fact about
#: the reader and not about the game.
_DEFINE = re.compile(
    r"^!(?P<name>\w+)\s*=\s*"
    r"(?:\$(?P<literal>[0-9A-Fa-f]+)"
    r"|!(?P<of>\w+)\s*(?:(?P<sign>[-+])\s*\$(?P<offset>[0-9A-Fa-f]+))?)\s*$"
)
#: Where a define's name breaks into words: at a lower-to-upper step, before
#: the last capital of a run that starts a word, and before a run of digits --
#: ``FightBowser1`` is three words and ``GhostHouse`` two.
_WORD_BREAK = re.compile(
    r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[A-Za-z])(?=\d)"
)


def readable(name: str) -> str:
    """A define's tail as prose: ``GhostHouse`` -> ``Ghost House``, and
    ``FightBowser1`` -> ``Fight Bowser 1``."""
    return _WORD_BREAK.sub(" ", name)


def _defines(text: str) -> Iterator[tuple[str, int]]:
    """Every define the file states, in file order, with references resolved.

    A reference is resolved against the defines *already seen*, which is how
    asar reads the file too; one that names something not yet defined is
    skipped rather than guessed at.
    """
    seen: dict[str, int] = {}
    for line in text.splitlines():
        match = _DEFINE.match(line.split(";")[0].strip())
        if match is None:
            continue
        if match["literal"] is not None:
            value = int(match["literal"], 16)
        else:
            base = seen.get(match["of"])
            if base is None:
                continue
            offset = int(match["offset"] or "0", 16)
            value = base - offset if match["sign"] == "-" else base + offset
        seen[match["name"]] = value
        yield match["name"], value


def defines_in(text: str, prefix: str) -> Iterator[tuple[str, int]]:
    """Every ``!<prefix><Name>`` define in ``text``, in **file order**, as the
    name past the prefix and its value.

    File order and every line, where :func:`names_for` gives a value its first
    name and drops the rest -- which is what a caller offering a *choice* needs,
    since two defines of one value are two things to offer and not one.
    """
    for name, value in _defines(text):
        if name.startswith(prefix):
            yield name[len(prefix) :], value


def names_for(text: str, prefix: str) -> dict[int, str]:
    """Every ``!<prefix><Name>`` define in ``text``, as value to prose.

    The first name a value gets keeps it: a value defined twice is an alias, and
    the earlier line is the one the table's own comments use.
    """
    out: dict[int, str] = {}
    for name, value in defines_in(text, prefix):
        out.setdefault(value, readable(name))
    return out


def read_names(defines: Path | str) -> tuple[dict[str, dict[int, str]], ...]:
    """The music and sound effect names out of ``Misc_Defines_SMW.asm``.

    Two mappings: music names by blob, and sound effect names by mailbox.
    """
    text = Path(defines).read_text(encoding="utf-8", errors="replace")
    music = {blob: names_for(text, prefix) for blob, prefix in MUSIC_DEFINES.items()}
    sfx = {port: names_for(text, prefix) for port, prefix in SFX_DEFINES.items()}
    return music, sfx


# -- how a level asks for music -----------------------------------------------

#: Which bits of the level header choose the music: byte 2, bits 4-6, read by
#: ``SMW_LoadLevelHeader`` as an index into ``LevelMusicTable``.
HEADER_MUSIC_BYTE = 2
HEADER_MUSIC_SHIFT = 4
HEADER_MUSIC_MASK = 0x07

#: How many entries ``LevelMusicTable`` has, which is what those three bits can
#: name. The table holds a music value apiece, so which song a level plays is
#: two lookups: the header picks a row, the row names the value.
LEVEL_MUSIC_SLOTS = 8


def header_music_slot(header: bytes) -> int:
    """Which ``LevelMusicTable`` row a level header selects."""
    return header[HEADER_MUSIC_BYTE] >> HEADER_MUSIC_SHIFT & HEADER_MUSIC_MASK
