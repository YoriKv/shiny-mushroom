"""The project's audio, laid out: what is in ARAM and what asks for it.

The question this answers is the one the four audio mailboxes raise and none of
them can answer on its own: *what actually plays, and what is there room for?*
A level header names three bits; those bits pick a row of ``LevelMusicTable``;
that row holds the value the game writes to ``$7E1DFB``; and that value indexes
a pointer table that only exists while the right music bank happens to be
resident in the SPC700's memory. Four hops, three of them invisible from any one
place, and the last one conditional on which of three banks was uploaded last.

**Two sources, and each is the only one that can answer its part.** The
**built ROM** carries every audio byte in the IPL upload format
(:mod:`smw_tools.audio`), so where each block lands in ARAM, how big every song
and effect is and what the sample directory holds are all read rather than
declared -- against this project's cartridge, so an edited one reports itself.
The **disassembly's own defines** carry the vocabulary: the game names every
value it writes to a mailbox, and those names are the only place a song or an
effect is called anything at all.

**Three banks over one window.** The level, overworld and credits music all
upload to the same ARAM address, so :class:`MusicBank` is what a bank *would*
occupy, and :attr:`AudioMap.window` is the wall the largest of them sets. An
ARAM reading is therefore always *per bank*: :func:`audio_map` composes one
image apiece, because "what is in memory" has no bank-independent answer.

Qt-free, like :mod:`shiny_mushroom.memory_map`: this produces numbers and names,
and painting them is the dialog's job.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field

from shiny_mushroom.addresses import Addresses
from shiny_mushroom.header import HEADER_SIZE
from shiny_mushroom.index import LEVEL_COUNT
from shiny_mushroom.music_tables import (
    LEVEL_MUSIC_TABLE,
    MUSIC_POINTERS,
    MusicTableError,
    TrackChoice,
    setting_names,
)
from shiny_mushroom.project import Project
from shiny_mushroom.rom_patches import layer1_base
from smw_tools import audio
from smw_tools.rom_image import pc_to_snes, snes_to_pc
from smw_tools.symbols import SymbolTable

#: What each blob is called in the window, by the label the ROM map gives it.
#: The disassembly's label is the identity; this is what a reader is shown.
BLOB_NAMES = {
    audio.ENGINE_BLOB: "Engine and sound effects",
    audio.SAMPLES_BLOB: "Samples",
    audio.LEVEL_MUSIC_BLOB: "Level music",
    audio.OVERWORLD_MUSIC_BLOB: "Overworld music",
    audio.CREDITS_MUSIC_BLOB: "Credits music",
}

#: What each *block* holds, where a blob uploads more than one and they are
#: different things. The engine blob carries the driver and, well above it, the
#: sound effect bank with the instrument tables behind that; the samples blob
#: carries the directory the DSP reads and the waveforms it points into. Naming
#: a run for the blob it rode in on would put one label on both.
BLOCK_NAMES = {
    (audio.ENGINE_BLOB, 0): "Engine",
    (audio.ENGINE_BLOB, 1): "Sound effects and instruments",
    (audio.SAMPLES_BLOB, 0): "Sample directory",
    (audio.SAMPLES_BLOB, 1): "Samples",
}


def block_name(blob: str, index: int) -> str:
    """What one uploaded block holds, falling back to the blob's own name for a
    blob that uploads a single run."""
    return BLOCK_NAMES.get((blob, index), BLOB_NAMES[blob])


#: The fragment ``LevelMusicTable`` lives in, which is what this reads its
#: eight settings out of -- see :func:`audio_map`.
LEVEL_MUSIC_TABLE_FILE = LEVEL_MUSIC_TABLE

#: Where ``Misc_Defines_SMW.asm`` is under a base's game folder.
DEFINES_FILE = "Misc_Defines_SMW.asm"


class AudioMapError(ValueError):
    """The project's audio could not be read."""


# -- what one bank holds ------------------------------------------------------


@dataclass(frozen=True)
class SongRow:
    """One song, as a row: the value that asks for it and what it reaches.

    ``name`` and ``label`` are two different things and a repoint pulls them
    apart. The name is the **value's**, from the define that states it -- ``$01``
    is *Piano* whatever it points at -- while the label is the song the pointer
    table sends it to. On the shipped cartridge they agree; the moment a value
    is repointed they do not, and showing only one of them would hide the edit.
    """

    value: int
    name: str
    song: audio.Song
    #: The ``MUSIC_*`` label the bank's pointer table gives this value.
    label: str = ""

    @property
    def pointer(self) -> int:
        return self.song.pointer

    @property
    def size(self) -> int:
        return self.song.size

    @property
    def channels(self) -> tuple[int, ...]:
        return tuple(sorted(self.song.channels))

    @property
    def loops(self) -> bool:
        return self.song.loop_to is not None


@dataclass(frozen=True)
class MusicBank:
    """One of the three blobs that can occupy the music window.

    ``reached`` is how many of the block's bytes any of its songs actually
    touch. The gap to :attr:`size` is real and small: the shipped banks carry a
    handful of phrase rows the disassembly itself marks unused, and nothing
    points at them.
    """

    blob: str
    name: str
    #: Where the blob is in the headerless ROM image, and how long it is there.
    #: The offset is what reads it; :attr:`address` is what a reader is shown,
    #: because every other ROM address in the editor is a cartridge address.
    rom: int
    rom_size: int
    address: int
    #: Where its one block lands in ARAM, and how big it is.
    aram: int
    size: int
    songs: tuple[SongRow, ...]
    reached: int

    @property
    def end(self) -> int:
        return self.aram + self.size

    @property
    def unreached(self) -> int:
        return self.size - self.reached


@dataclass(frozen=True)
class SfxRow:
    """One sound effect: which mailbox asks for it, with what value."""

    port: int
    value: int
    name: str
    pointer: int
    size: int
    #: Whether another row of the same table points at the same bytes -- the
    #: tables' own comments call these clones.
    cloned: bool


@dataclass(frozen=True)
class Segment:
    """One run of ARAM in the layout: where it is, what it is, and what put it
    there.

    ``blob`` is the upload that wrote it, and ``None`` for a run the engine
    keeps at runtime or for one nothing claims.
    """

    start: int
    end: int
    name: str
    blob: str | None = None
    free: bool = False

    @property
    def size(self) -> int:
        return self.end - self.start


@dataclass(frozen=True)
class MusicSlot:
    """One row of ``LevelMusicTable``: what the header's three bits select.

    ``levels`` is every level in the cartridge whose header names this row,
    which is the only evidence of what a row is *for* -- the table itself says
    nothing about grassland or caves beyond a comment.
    """

    slot: int
    #: What this setting is called: the name of the track it holds, which is
    #: what every window naming a setting shows -- see
    #: :func:`~shiny_mushroom.music_tables.setting_names`.
    name: str
    #: The music value the row holds, which is what reaches the mailbox.
    value: int
    song: SongRow | None
    levels: tuple[int, ...]


@dataclass(frozen=True)
class AudioMap:
    """Everything the Audio window shows, read from one project's cartridge."""

    banks: tuple[MusicBank, ...]
    sfx: tuple[SfxRow, ...]
    samples: tuple[audio.Sample, ...]
    instruments: tuple[audio.Instrument, ...]
    percussion: tuple[audio.Instrument, ...]
    slots: tuple[MusicSlot, ...]
    #: The ARAM layout for each bank in turn, since the music window's occupant
    #: is what changes between them. Keyed by blob.
    layout: Mapping[str, tuple[Segment, ...]] = field(default_factory=dict)
    #: The music window itself: where it starts and how far the largest of the
    #: three banks reaches into it.
    window: int = 0
    window_size: int = 0
    #: Whether the engine blob's upload runs on into the bank behind it, which
    #: is how the stock cartridge is laid out.
    boot_runs_on: bool = True
    #: Every song label a music value may be repointed at, by blob -- the
    #: labels that bank's own source defines, which is the whole of what would
    #: assemble.
    songs_offered: Mapping[str, tuple[str, ...]] = field(default_factory=dict)
    #: Every track a header music setting may be given, in the order the
    #: defines state them.
    tracks_offered: tuple[TrackChoice, ...] = ()

    def bank(self, blob: str) -> MusicBank | None:
        return next((one for one in self.banks if one.blob == blob), None)

    @property
    def free(self) -> int:
        """ARAM no upload writes and the engine does not keep, on the reading
        that leaves the least of it."""
        return min(
            sum(one.size for one in segments if one.free)
            for segments in self.layout.values()
        )


# -- reading it ---------------------------------------------------------------


def _blob_offsets(symbols: SymbolTable) -> dict[str, int]:
    """Where each of the five blobs is in the headerless image."""
    found: dict[str, int] = {}
    for blob in (audio.ENGINE_BLOB, audio.SAMPLES_BLOB, *audio.MUSIC_BLOBS):
        symbol = symbols.by_name.get(f"{audio.NAMESPACE}_{blob}")
        if symbol is None:
            raise AudioMapError(
                f"the build's symbol file does not place {blob}; "
                f"Project > Rebuild writes one that does"
            )
        found[blob] = snes_to_pc(symbol.addr)
    return found


def _streams(rom: bytes, offsets: Mapping[str, int]) -> dict[str, audio.UploadStream]:
    """Each blob's upload stream, bounded by the next blob above it.

    The bound matters as much as the start: the engine blob has no terminator,
    so without one its walk would read the whole rest of the bank as blocks.
    """
    starts = sorted(offsets.values())
    out: dict[str, audio.UploadStream] = {}
    for blob, offset in offsets.items():
        after = [start for start in starts if start > offset]
        out[blob] = audio.read_stream(rom, offset, after[0] if after else len(rom))
    return out


def _boot(streams: Mapping[str, audio.UploadStream]) -> list[audio.UploadStream]:
    """The uploads a cartridge has made before any music bank is asked for.

    The engine, and -- where its stream has no terminator -- whatever the ROM
    map put behind it, which is the overworld music bank and is what the boot
    upload therefore carries into ARAM as well.
    """
    engine = streams[audio.ENGINE_BLOB]
    if engine.terminated:
        return [engine]
    return [engine, streams[audio.OVERWORLD_MUSIC_BLOB]]


def _music_window(streams: Mapping[str, audio.UploadStream]) -> int:
    """Where the three music banks all upload to."""
    blocks = streams[audio.LEVEL_MUSIC_BLOB].blocks
    if len(blocks) != 1:
        raise AudioMapError(
            f"the level music bank uploads {len(blocks)} blocks, not the one "
            f"this reading assumes"
        )
    return blocks[0].aram


def _sfx_bank(streams: Mapping[str, audio.UploadStream]) -> int:
    """Where the sound effect bank lands: the engine blob's second block."""
    blocks = streams[audio.ENGINE_BLOB].blocks
    if len(blocks) < 2:
        raise AudioMapError(
            "the engine blob uploads one block, so it carries no separate "
            "sound effect bank for this reading to find"
        )
    return blocks[1].aram


def _segments(
    streams: Mapping[str, audio.UploadStream], resident: str
) -> tuple[Segment, ...]:
    """The whole of ARAM as runs, for one resident music bank.

    Three kinds of run, in this order of authority: what the engine keeps at
    runtime (:data:`smw_tools.audio.FIXED_REGIONS`, which no upload describes),
    what an upload writes, and -- between and above them -- what nothing
    claims.
    """
    claimed: list[Segment] = [
        Segment(start, end, name) for start, end, name in audio.FIXED_REGIONS
    ]
    wanted = [audio.ENGINE_BLOB, audio.SAMPLES_BLOB, resident]
    for blob in wanted:
        for index, block in enumerate(streams[blob].blocks):
            claimed.append(
                Segment(block.aram, block.end, block_name(blob, index), blob)
            )
    # The boot upload's copy of the overworld bank lands in the music window,
    # which the resident bank owns: keep the resident one and drop the other,
    # since two runs cannot describe the same bytes.
    ordered = sorted(claimed, key=lambda one: one.start)
    out: list[Segment] = []
    at = 0
    for segment in ordered:
        if segment.start < at:
            continue
        if segment.start > at:
            out.append(Segment(at, segment.start, "Free", free=True))
        out.append(segment)
        at = segment.end
    if at < audio.ARAM_SIZE:
        out.append(Segment(at, audio.ARAM_SIZE, "Free", free=True))
    return tuple(out)


def _levels_by_slot(rom: bytes, where: Addresses) -> dict[int, list[int]]:
    """Every level's header music slot, gathered by slot.

    A level whose Layer 1 pointer does not resolve is no evidence and is
    dropped, exactly as :mod:`shiny_mushroom.index` drops it.
    """
    found: dict[int, list[int]] = {}
    for level in range(LEVEL_COUNT):
        try:
            base = layer1_base(rom, level, where=where)
        except (ValueError, IndexError):
            continue
        header = rom[base : base + HEADER_SIZE]
        if len(header) < HEADER_SIZE:
            continue
        found.setdefault(audio.header_music_slot(header), []).append(level)
    return found


def audio_map(
    project: Project,
    symbols: SymbolTable,
    rom: bytes,
    where: Addresses,
) -> AudioMap:
    """Read the project's cartridge into an :class:`AudioMap`.

    ``rom`` is the **headerless** image this project last built, ``symbols`` its
    build's symbol file, and ``where`` the ROM base it was built for.
    """
    offsets = _blob_offsets(symbols)
    streams = _streams(rom, offsets)
    boot = _boot(streams)
    window = _music_window(streams)
    bank_aram = _sfx_bank(streams)
    music_names, sfx_names = audio.read_names(
        project.source(project.base / DEFINES_FILE)
    )
    tracks = project.track_choices()

    banks: list[MusicBank] = []
    layout: dict[str, tuple[Segment, ...]] = {}
    for blob in audio.MUSIC_BLOBS:
        stream = streams[blob]
        block = stream.blocks[0]
        aram = audio.compose(rom, [*boot, streams[audio.SAMPLES_BLOB], stream])
        songs = audio.read_songs(aram, window, audio.MUSIC_COUNTS[blob])
        named = music_names.get(blob, {})
        try:
            pointers = project.music_pointers(blob)
        except MusicTableError as error:
            raise AudioMapError(
                f"{MUSIC_POINTERS[blob].name} could not be read: {error}"
            ) from error
        rows = tuple(
            SongRow(
                song.value,
                named.get(song.value, "Unnamed"),
                song,
                pointers.song(song.value),
            )
            for song in songs
        )
        reached = sum(
            end - start
            for start, end in audio.merged(
                span for song in songs for span in song.spans
            )
        )
        banks.append(
            MusicBank(
                blob,
                BLOB_NAMES[blob],
                offsets[blob],
                stream.size,
                pc_to_snes(offsets[blob]),
                block.aram,
                block.size,
                rows,
                reached,
            )
        )
        layout[blob] = _segments(streams, blob)

    # The sound effects, the samples and the instruments are the same on every
    # bank -- they are uploaded once and never overwritten -- so one image
    # answers for all three.
    aram = audio.compose(
        rom,
        [*boot, streams[audio.SAMPLES_BLOB], streams[audio.LEVEL_MUSIC_BLOB]],
    )
    seen: dict[tuple[int, int], int] = {}
    sfx: list[SfxRow] = []
    for one in audio.read_sfx(aram, bank_aram):
        key = (one.port, one.pointer)
        seen[key] = seen.get(key, 0) + 1
        sfx.append(
            SfxRow(
                one.port,
                one.value,
                sfx_names.get(one.port, {}).get(one.value, "Unnamed"),
                one.pointer,
                one.size,
                cloned=seen[key] > 1,
            )
        )

    directory = streams[audio.SAMPLES_BLOB].blocks[0]
    samples = audio.read_samples(aram, directory.aram, directory.size // 4)

    # The music instrument tables sit at the tail of the sound effect bank,
    # behind the effects themselves, so they are placed from its end rather
    # than from its head.
    sfx_block = streams[audio.ENGINE_BLOB].blocks[1]
    percussion_at = sfx_block.end - audio.PERCUSSION_COUNT * audio.PERCUSSION_STRIDE
    instruments_at = percussion_at - audio.INSTRUMENT_COUNT * audio.INSTRUMENT_STRIDE
    instruments = audio.read_instruments(aram, instruments_at, audio.INSTRUMENT_COUNT)
    percussion = audio.read_instruments(
        aram, percussion_at, audio.PERCUSSION_COUNT, percussion=True
    )

    level_bank = banks[0]
    by_value = {row.value: row for row in level_bank.songs}
    by_slot = _levels_by_slot(rom, where)
    # The eight settings come from the **project's** fragment rather than from
    # the cartridge, because they are one of the two things this window edits:
    # a setting just changed has to show as changed, standing over a build that
    # does not have it yet. Everything else here is the build's.
    try:
        held = project.level_music_table()
        worth = {one.define: one.value for one in tracks}
        values = tuple(
            worth.get(held.define(slot), 0) for slot in range(len(held.lines))
        )
        names = setting_names(held, tracks)
    except MusicTableError as error:
        raise AudioMapError(
            f"{LEVEL_MUSIC_TABLE_FILE.name} could not be read: {error}"
        ) from error
    slots = tuple(
        MusicSlot(
            slot,
            names[slot],
            value,
            by_value.get(value),
            tuple(by_slot.get(slot, ())),
        )
        for slot, value in enumerate(values)
    )

    return AudioMap(
        tuple(banks),
        tuple(sfx),
        samples,
        instruments,
        percussion,
        slots,
        layout,
        window,
        max(bank.size for bank in banks),
        boot_runs_on=not streams[audio.ENGINE_BLOB].terminated,
        songs_offered={blob: project.song_choices(blob) for blob in audio.MUSIC_BLOBS},
        tracks_offered=tracks,
    )
