"""Custom music: driving AddmusicK, and what it hands back.

The cartridge's own audio is read by :mod:`smw_tools.audio`; this is the other
half, the songs a project adds. Nothing here compiles anything. **AddmusicK is
the compiler** -- the community's own, which every ported song on SMW Central
was written against -- and this module's whole job is to run the user's copy of
it, take the blobs it produced, and write them out as something the disassembly
can ``incbin``.

**Why the tool rather than a compiler of our own.** The corpus is MML written
for AddmusicK's dialect and *for AddmusicK's sound driver*: its extended
commands, its per-song sample directories, its ARAM layout. A compiler of ours
would be reimplementing a moving target to produce data for a driver we would
also have to reimplement. Running the tool gets both, exactly right, including
the parts nobody has written down.

**Compiler yes, patcher never.** AddmusicK's ordinary mode edits a built ROM:
it wipes banks ``$0E`` and ``$0F``, hijacks ``$8075``, and puts its data
wherever a freespace search lands -- which on a 2 MB cartridge is the expansion
banks this project reserves for other things. ``-p`` is the mode that stops
short of that, and it is a supported one: AddmusicK keeps its temporary files
precisely because "the user might need these". So the tool compiles, and the
disassembly decides where anything goes.

**Everything it emits is already an upload stream.** A song blob is
``[length][ARAM destination][payload]`` behind an eight-byte RATS tag -- the
same format ``%SPCDataBlockStart`` emits and :func:`smw_tools.audio.read_stream`
reads -- so placing one is ``incbin`` and nothing else. The tag is AddmusicK's
own way of finding its data again in a ROM it patched; here the assembler
places the blob, so the tag comes off.

**The driver comes from the same run as the songs.** A song's position in ARAM
is computed from the driver's size, so a driver and a sequence from two
different AddmusicK versions disagree about where the sequence lives, silently.
Taking both out of one run is what makes that impossible.

Standard library only and no Qt, like the rest of :mod:`smw_tools`: this runs a
subprocess and writes files.
"""

from __future__ import annotations

import re
import shutil
import subprocess
from collections.abc import Iterable, Mapping, Sequence
from contextlib import suppress
from dataclasses import dataclass, field
from pathlib import Path

#: What the tool's own working directory has to hold for it to run at all. It
#: resolves everything relative to that directory rather than to its argument,
#: so a lone executable is not a usable AddmusicK and saying so early beats a
#: missing-file error out of the subprocess.
DISTRIBUTION_MARKERS = ("asm/main.asm", "Addmusic_list.txt")

#: The directories a run needs staged, and the ones it writes into. The
#: distribution ships all but ``asm/SNES/bin``, which AddmusicK requires to
#: exist and does not create.
STAGED_DIRS = ("asm", "samples", "1DF9", "1DFC")
STAGED_FILES = (
    "Addmusic_list.txt",
    "Addmusic_sample groups.txt",
    "Addmusic_sound effects.txt",
)
MADE_DIRS = ("music", "SPCs", "stats", "asm/SNES/bin")

#: The music values a project's own songs answer to. With the driver resident
#: every mailbox value is AddmusicK's: the forty stock songs ride along as
#: ``music/originals`` at values $01-$28 -- their position in the tool's own
#: canonical numbering, the one its ``UserDefines.asm`` states and its
#: ``tweaks.asm`` writes into the game's request sites -- so a project's songs
#: are numbered from $29, the community's own first custom slot. $FF is the
#: driver's fade command. A song keeps its value across imports
#: (:meth:`shiny_mushroom.project_music.MusicFiles.import_music` pins them),
#: so a level given a song keeps that song.
CUSTOM_FIRST = 0x29
CUSTOM_LAST = 0x7F

#: How many of the originals are global songs -- compiled in with the driver,
#: playable with no upload, which is what lets a jingle interrupt a level and
#: the level's own song come back. The first nine of the canonical list: the
#: fanfares and stings, Miss through Bonus End, exactly as the tool's own
#: default list ships them.
ORIGINAL_GLOBALS = 9

#: How the music banks are priced: each reserved bank is 32 KB of LoROM, the
#: placement emits one sequence across them (Config/MusicBank.asm), and the
#: first bank gives up eight bytes to its RATS tag. ``TABLE_SLACK`` stands in
#: for what the fragment emits besides the blobs -- the pointer tables, the
#: sample groups, the driver's terminator and the frame hook -- which measure
#: a few bytes a row against blobs measured in kilobytes.
BANK_CAPACITY = 0x8000
TABLE_SLACK = 0x2000
COUNT_DEFINE = "Define_SMW_MusicBankCount"


def banks_needed(blob_bytes: int) -> int:
    """How many music banks hold a soundtrack whose blobs total ``blob_bytes``.

    At least one -- the config reserves one by default -- and always priced
    with the table slack on top, so the placement's own assert is a backstop
    rather than the thing a soundtrack routinely hits.
    """
    return max(1, -(-(blob_bytes + TABLE_SLACK + 8) // BANK_CAPACITY))


def bank_count_define(banks: int) -> tuple[str, str]:
    """The ``--define`` pair that asks the assembler for ``banks`` music
    banks, in the shape :func:`smw_tools.build.build_rom` takes -- the
    managed graphics' own arrangement
    (:func:`~smw_tools.graphics_memory.bank_count_define`)."""
    if banks < 1:
        raise MusicError("the custom music needs at least one music bank")
    return (COUNT_DEFINE, str(banks))


#: How long one compile may take before it is killed. AddmusicK reports errors
#: as prose on stdout with no exit code behind them, and at least one release
#: prints one forever rather than stopping, so a bound is not optional.
TIMEOUT = 120

#: The patch a run generated, and the files it reads beside itself. Kept with
#: the compiled blobs because it is the other half of them: the data is what
#: the disassembly places, and this is the runtime that reads it, from the same
#: version of the same tool. A build applies it; nothing else assembles it.
#: The patch's entry point, relative to the tool's ``asm/`` directory. What it
#: reads beside itself is **discovered rather than listed**: AddmusicK has twice
#: moved a block of defines out into a new file (``UserDefines.asm``, then
#: ``AMKFreeRAMDefines.asm``), and each time a list would have gone stale
#: silently -- the patch assembles until it reaches the first define that is
#: suddenly somewhere else. Following its own ``incsrc`` lines cannot.
PATCH_ENTRY = "SNES/temppatch.asm"

#: Paths are relative to ``asm/`` rather than bare names because one include
#: reaches out of its directory: ``SNES/tweaks.asm`` reads ``../UserDefines.asm``.
#: Keeping the shape as well as the files is what lets the patch assemble
#: anywhere.
_INCSRC = re.compile(r'^\s*incsrc\s+"([^"]+)"', re.MULTILINE)

#: Where the patch and its includes are kept in a project, under the blobs.
PATCH_DIR = "patch"


def patch_files(root: Path, entry: str = PATCH_ENTRY) -> list[str]:
    """``entry`` and everything it reads, as paths relative to ``root``.

    Walks the ``incsrc`` lines rather than trusting a list of them, resolving
    each against the file that named it -- which is what makes an include
    reaching out of its own directory work, and what makes a release that moves
    defines into a new file a non-event.
    """
    found: list[str] = []
    pending = [entry]
    while pending:
        name = pending.pop(0)
        if name in found or not (root / name).is_file():
            continue
        found.append(name)
        text = (root / name).read_text(encoding="utf-8", errors="replace")
        for named in _INCSRC.findall(text):
            with suppress(ValueError):
                pending.append(
                    ((root / name).parent / named)
                    .resolve()
                    .relative_to(root.resolve())
                    .as_posix()
                )
    return found


#: Where AddmusicK leaves what a run produced, under its working directory.
BIN_DIR = "asm/SNES/bin"
PATCH_FILE = "asm/SNES/temppatch.asm"
GROUPS_FILE = "asm/SNES/SongSampleList.asm"
STATS_DIR = "stats"
SPC_DIR = "SPCs"

#: The eight-byte RATS tag AddmusicK writes in front of a song and a sample so
#: it can find them again in a ROM it patched. The assembler places these, so
#: the tag comes off and the pointer lands where AddmusicK's own would have:
#: eight bytes in.
RATS_BYTES = 8


class MusicError(Exception):
    """A soundtrack could not be compiled."""


# -- the tool -----------------------------------------------------------------


def distribution(path: Path) -> Path:
    """The AddmusicK working directory ``path`` names, whichever end is given.

    A person picking a tool picks its executable, and a person who has read the
    readme picks its folder; both mean the same installation, so both are
    taken. What comes back is the directory, which is the only form a run can
    use.
    """
    root = path if path.is_dir() else path.parent
    missing = [one for one in DISTRIBUTION_MARKERS if not (root / one).is_file()]
    if missing:
        raise MusicError(
            f"{root} does not look like an AddmusicK installation: it has no "
            f"{' and no '.join(missing)}. Point at the folder the tool was "
            f"unpacked into, or at the executable inside it."
        )
    return root


def executable(root: Path) -> Path:
    """The tool's binary inside its distribution, by any of its spellings."""
    for name in ("AddmusicK.exe", "AddmusicK", "addmusick", "addmusick.exe"):
        found = root / name
        if found.is_file():
            return found
    raise MusicError(
        f"{root} holds an AddmusicK distribution but no executable in it. "
        f"On macOS and Linux the tool has to be built from its source first."
    )


def version(root: Path) -> str:
    """What the tool calls itself, from the first line it prints.

    Worth showing rather than merely "found": which version a person has is
    what decides whether a given song compiles at all, and it is the first
    thing anyone debugging an import wants to know.
    """
    try:
        done = subprocess.run(  # noqa: S603 - the path is the user's own setting
            [str(executable(root).resolve()), "-?"],
            cwd=root,
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
            stdin=subprocess.DEVNULL,
            check=False,
        )
    except OSError as error:
        raise MusicError(f"{root} could not be run: {error}") from error
    except subprocess.TimeoutExpired as error:
        raise MusicError(f"{root} did not answer within {TIMEOUT} seconds") from error
    first = next((one.strip() for one in done.stdout.splitlines() if one.strip()), "")
    return first or "AddmusicK, version unknown"


# -- what a run produced ------------------------------------------------------


@dataclass(frozen=True)
class Song:
    """One compiled song: the bytes, and what the tool said they cost."""

    #: The music value this song answers to, which is its row in the pointer
    #: table and what the game writes to the mailbox.
    value: int
    #: What the person called it -- the MML file's name, without its suffix.
    name: str
    #: The sequence, as an upload stream block: length, ARAM destination,
    #: payload. Ready to ``incbin``.
    data: bytes
    #: Which samples it wants, as indices into the pool, in the order its own
    #: sequence names them.
    samples: tuple[int, ...]
    #: What AddmusicK measured, by the name it uses in ``stats/``. Sizes are
    #: bytes, the song lengths seconds.
    stats: dict[str, float] = field(default_factory=dict)
    #: The same measurements as the tool wrote them, kept whole so the report
    #: can ride with the song rather than die with the run.
    report: str = ""
    #: The playable ``.spc`` the same run wrote, where it wrote one.
    spc: bytes | None = None

    @property
    def aram(self) -> int:
        """Where its sequence lands in the sound chip's memory."""
        return int.from_bytes(self.data[2:4], "little")

    @property
    def size(self) -> int:
        """How long the sequence is, without the block header."""
        return int.from_bytes(self.data[0:2], "little")


@dataclass(frozen=True)
class Sample:
    """One waveform in the pool: its bytes and where it loops."""

    index: int
    #: A length word, then the BRR itself -- the shape the driver's own sample
    #: table expects, and what the pointer row names.
    data: bytes
    loop: int

    @property
    def size(self) -> int:
        return int.from_bytes(self.data[0:2], "little")


@dataclass(frozen=True)
class Soundtrack:
    """Everything one AddmusicK run produced, ready to be written out."""

    #: The sound driver, as an upload stream block. Every song's ARAM position
    #: was computed from this blob's length, so the two travel together.
    driver: bytes
    songs: tuple[Song, ...]
    samples: tuple[Sample, ...]
    #: Where the SPC700 resumes after an upload: a block that stands alone,
    #: one that precedes another, and the sample table. Read out of the patch
    #: AddmusicK generated, because nothing else knows them.
    aram_returns: tuple[int, int, int]
    #: How many songs the driver carries itself, needing no upload.
    globals: int = 0
    #: What the tool said, kept whole for a person to read when something did
    #: not come out as expected.
    log: str = ""
    #: The patch it generated and the files that patch reads, by name. The
    #: runtime half of what a run produced.
    patch: Mapping[str, str] = field(default_factory=dict)

    @property
    def custom_songs(self) -> tuple[Song, ...]:
        """The project's own songs: everything above the originals' range."""
        return tuple(one for one in self.songs if one.value >= CUSTOM_FIRST)

    @property
    def rows(self) -> int:
        """How many pointer rows the table needs: one past the highest value
        any song answers to, so a value beyond it is refused without reading
        the table at all."""
        return max((song.value for song in self.songs), default=-1) + 1

    @property
    def rom_bytes(self) -> int:
        """What the whole soundtrack costs in the cartridge, tables included."""
        tables = len(self.driver) + 4 + self.rows * 3 + len(self.samples) * 5
        groups = sum(1 + len(song.samples) * 2 + 2 for song in self.songs)
        blobs = sum(len(song.data) for song in self.songs)
        return tables + groups + blobs + sum(len(one.data) for one in self.samples)


# -- reading a run ------------------------------------------------------------

_DEFINE = re.compile(r"^!(\w+)\s*=\s*#?\$([0-9A-Fa-f]+)", re.MULTILINE)
_TABLE = re.compile(r"^(\w+):[ \t]*\n((?:\s*d[lw][^\n]*\n)+)", re.MULTILINE)
_WORD = re.compile(r"\$([0-9A-Fa-f]+)")
_GROUP_POINTER = re.compile(r"^SGPointer([0-9A-Fa-f]{2}):", re.MULTILINE)


def _defines(text: str) -> dict[str, int]:
    return {name: int(digits, 16) for name, digits in _DEFINE.findall(text)}


def _group_lists(text: str) -> dict[int, tuple[int, ...]]:
    """Which samples each song wants, out of the tool's own sample-group file.

    Several songs share one list where their sample sets are identical -- the
    tool emits every one of their labels over the same rows -- so the labels
    are gathered until a row appears and then all given it.
    """
    found: dict[int, tuple[int, ...]] = {}
    pending: list[int] = []
    for line in text.splitlines():
        stripped = line.strip()
        if match := _GROUP_POINTER.match(stripped):
            pending.append(int(match.group(1), 16))
        elif stripped.startswith("dw") and pending:
            samples = tuple(int(one, 16) for one in _WORD.findall(stripped))
            for index in pending:
                found[index] = samples
            pending.clear()
    return found


def _rows(text: str, table: str) -> list[str]:
    """One table's entries, as the tokens they were written as."""
    for name, body in _TABLE.findall(text):
        if name == table:
            entries: list[str] = []
            for line in body.splitlines():
                stripped = line.strip()
                if not stripped.startswith(("dl", "dw")):
                    continue
                entries += [one.strip() for one in stripped[2:].split(",")]
            return entries
    raise MusicError(f"AddmusicK's generated patch has no {table} table in it")


def song_stats(source: Path | str) -> dict[str, float]:
    """One song's measurements, as the tool wrote them -- a path to its
    ``stats`` file, or that file's text.

    Sizes arrive as hex, tick counts as integers, the three song lengths as
    decimal seconds; a line that is none of those is prose and skipped.
    """
    if isinstance(source, Path):
        if not source.is_file():
            return {}
        source = source.read_text(encoding="utf-8", errors="replace")
    found: dict[str, float] = {}
    for line in source.splitlines():
        name, _, value = line.partition(":")
        value = value.strip()
        if not value:
            continue
        try:
            found[name.strip()] = (
                int(value[2:], 16) if value.lower().startswith("0x") else float(value)
            )
        except ValueError:
            continue
    return found


def _blob(path: Path) -> bytes:
    """One of AddmusicK's data files, past the RATS tag it prefixes.

    The tag is checked rather than assumed: eight bytes taken off the front of
    something that is not one would be a blob quietly short of its head, which
    reads back as a plausible upload block and plays noise.
    """
    data = path.read_bytes()
    if not data.startswith(b"STAR"):
        raise MusicError(
            f"{path.name} does not begin with the RATS tag every AddmusicK "
            f"blob carries, so this release stores its data in a shape this "
            f"does not know how to read"
        )
    return data[RATS_BYTES:]


def read_run(work: Path, names: Mapping[int, str], log: str = "") -> Soundtrack:
    """Everything a finished ``-p`` run left in ``work``.

    ``names`` is the song list the run was given: music value to song name --
    the originals at their canonical values, a project's own from
    ``CUSTOM_FIRST`` up. Value ``$00`` is never a song, being what the game
    writes to mean silence.
    """
    named = dict(names)
    binaries = work / BIN_DIR
    driver = binaries / "main.bin"
    if not driver.is_file():
        raise MusicError(
            "AddmusicK produced no sound driver, so nothing it compiled can be "
            "placed. Its own output is above."
        )
    patch = (work / PATCH_FILE).read_text(encoding="utf-8", errors="replace")
    defines = _defines(patch)

    loops = [int(one.lstrip("$"), 16) for one in _rows(patch, "SampleLoopPtrs")]
    samples: list[Sample] = []
    for index, row in enumerate(_rows(patch, "SamplePtrs")):
        if not row.startswith("brr"):
            continue
        path = binaries / f"{row.split('+')[0]}.bin"
        if path.is_file():
            samples.append(Sample(index, _blob(path), loops[index]))

    groups = _group_lists(
        (work / GROUPS_FILE).read_text(encoding="utf-8", errors="replace")
        if (work / GROUPS_FILE).is_file()
        else ""
    )
    songs: list[Song] = []
    for value, row in enumerate(_rows(patch, "MusicPtrs")):
        if not row.startswith("music"):
            continue
        path = binaries / f"{row.split('+')[0]}.bin"
        if not path.is_file():
            continue
        name = named.get(value, f"song{value:02X}")
        stem = Path(name).stem
        report = work / STATS_DIR / name
        report_text = (
            report.read_text(encoding="utf-8", errors="replace")
            if report.is_file()
            else ""
        )
        spc = work / SPC_DIR / f"{stem}.spc"
        songs.append(
            Song(
                value,
                stem,
                _blob(path),
                groups.get(value, ()),
                song_stats(report_text),
                report_text,
                spc.read_bytes() if spc.is_file() else None,
            )
        )

    return Soundtrack(
        driver.read_bytes(),
        tuple(songs),
        tuple(samples),
        (
            defines.get("DefARAMRet", 0),
            defines.get("ExpARAMRet", 0),
            defines.get("TabARAMRet", 0),
        ),
        globals=defines.get("GlobalMusicCount", 0),
        log=log,
        patch={
            name: (work / "asm" / name).read_text(encoding="utf-8", errors="replace")
            for name in patch_files(work / "asm")
        },
    )


# -- running it ---------------------------------------------------------------


def stage(root: Path, work: Path, asar: Path | None = None) -> None:
    """Lay out a working directory for one run, copied from ``root``.

    **The user's own installation is read and never written.** AddmusicK works
    in its working directory -- it rewrites ``Addmusic_list.txt``, fills
    ``asm/SNES/bin``, and drops logs, ``.spc`` files and statistics around
    itself -- so running in place would edit somebody's install every time a
    song was imported, and two projects importing at once would race over one
    song list. A copy per run costs a few hundred kilobytes and has neither
    problem.

    ``asar`` is this repository's own assembler, dropped in beside the binary.
    AddmusicK ships one for Windows only and falls back to running an ``asar``
    from its working directory when the shared library will not load, which is
    every macOS and Linux run.
    """
    work.mkdir(parents=True, exist_ok=True)
    for name in STAGED_DIRS:
        source = root / name
        if source.is_dir():
            shutil.copytree(source, work / name, dirs_exist_ok=True)
    for name in STAGED_FILES:
        if (root / name).is_file():
            shutil.copy2(root / name, work / name)
    for name in MADE_DIRS:
        (work / name).mkdir(parents=True, exist_ok=True)
    binary = executable(root)
    shutil.copy2(binary, work / binary.name)
    if asar is not None and asar.is_file():
        shutil.copy2(asar, work / "asar")
        (work / "asar").chmod(0o755)


#: What each stock track define is called in AddmusicK's ``UserDefines.asm``,
#: which is where the values its ``tweaks.asm`` writes into the game come
#: from. This is the whole of the correspondence between the two vocabularies,
#: measured site by site: each tweaks hunk patches a byte whose stock value
#: names the define our source uses there, and the three music tables map the
#: rest. Two stock keyhole values share the tool's one Keyhole song, both
#: bowser-fight variants its one Bowser, and MusicFade is not here because
#: the driver's fade is the fixed command $FF rather than a song.
TRACK_NAMES: dict[str, str] = {
    "LevelMusic_Piano": "Piano",
    "LevelMusic_HereWeGo": "HereWeGo",
    "LevelMusic_WaterLevel": "Water",
    "LevelMusic_FightBowser1": "Bowser",
    "LevelMusic_BossBattle": "Boss",
    "LevelMusic_CaveDrums": "Cave",
    "LevelMusic_GhostHouse": "GhostHouse",
    "LevelMusic_Castle": "Castle",
    "LevelMusic_MarioDied": "Miss",
    "LevelMusic_GameOver": "GameOver",
    "LevelMusic_PassedBoss": "BossClear",
    "LevelMusic_PassedLevel": "StageClear",
    "LevelMusic_HaveStar": "Starman",
    "LevelMusic_DirectCoins": "PSwitch",
    "LevelMusic_IntoKeyhole1": "Keyhole",
    "LevelMusic_IntoKeyhole2": "Keyhole",
    "LevelMusic_ZoomIn": "IrisOut",
    "LevelMusic_SwitchPalace": "SwitchPalace",
    "LevelMusic_Welcome": "Welcome",
    "LevelMusic_DoneBonusGame": "BonusEnd",
    "LevelMusic_RescueEgg": "RescueEgg",
    "LevelMusic_FightBowser2": "Bowser",
    "LevelMusic_BowserZoomOut": "BowserZoomOut",
    "LevelMusic_BowserZoomIn": "BowserZoomIn",
    "LevelMusic_FightBowser3": "Bowser2",
    "LevelMusic_FightBowser4": "Bowser3",
    "LevelMusic_BowserDied": "BowserDefeated",
    "LevelMusic_PrincessKiss": "PrincessSaved",
    "LevelMusic_BowserInterlude": "BowserIntrlude",
    "OverworldMusic_TitleScreen": "Title",
    "OverworldMusic_Overworld": "Overworld",
    "OverworldMusic_YoshisIsland": "YoshisIsland",
    "OverworldMusic_VanillaDome": "VanillaDome",
    "OverworldMusic_StarRoad": "StarRoad",
    "OverworldMusic_ForestOfIllusion": "ForestOfIllusion",
    "OverworldMusic_BowsersValley": "ValleyOfBowser",
    "OverworldMusic_BowsersValleyRevealed": "VoBAppears",
    "OverworldMusic_SpecialWorld": "SpecialWorld",
    "CreditsMusic_StaffRoll": "StaffRoll",
    "CreditsMusic_TheYoshisAreHome": "YoshisAreHome",
    "CreditsMusic_CastList": "CastList",
}


def originals(root: Path) -> list[Path]:
    """The stock songs the tool ships, in canonical order -- position is value.

    ``music/originals`` in every AddmusicK tree: forty MML files whose
    two-digit decimal prefix is their place in the tool's own numbering, so
    the twenty-first, Title, answers to $15. A tree without them cannot carry
    the stock soundtrack and is refused by name, because a cartridge built
    without it plays nothing at all: the game's first request is for a song
    that would not be there.
    """
    folder = root / "music" / "originals"
    found = sorted(folder.glob("*.txt"), key=lambda one: one.name)
    if not found:
        raise MusicError(
            f"there are no original songs under {folder}. AddmusicK ships the "
            f"stock soundtrack there, and the driver replaces the stock "
            f"engine, so a build without them would play nothing."
        )
    if len(found) >= CUSTOM_FIRST:
        raise MusicError(
            f"{len(found)} original songs under {folder} would run into "
            f"${CUSTOM_FIRST:02X}, the first custom value -- this release's "
            f"originals do not fit under the community's numbering, and a "
            f"project's own songs would collide with them"
        )
    out = []
    for position, one in enumerate(found, 1):
        if not one.name[:2].isdigit() or int(one.name[:2]) != position:
            raise MusicError(
                f"the original songs under {folder} are not the tool's own "
                f"numbered set -- expected position {position:02d}, found "
                f"{one.name}. Their numbering is what the driver's request "
                f"sites are written against."
            )
        out.append(one)
    return out


def _song_list(entries: Sequence[tuple[int, str]]) -> str:
    """The song list AddmusicK reads: the originals at their canonical
    values, then the project's own songs from ``CUSTOM_FIRST`` up.

    The first :data:`ORIGINAL_GLOBALS` are global -- compiled in with the
    driver, playable with no upload, which is how a jingle interrupts a level
    and the level's song comes back -- and everything after is local,
    uploaded when its value is asked for. The values need not be contiguous:
    the tool pads its pointer table with zero rows, the same shape the
    fragment emits.
    """
    rows = sorted(entries)
    globals_ = [
        f"{value:02X} {name}" for value, name in rows if value <= ORIGINAL_GLOBALS
    ]
    locals_ = [
        f"{value:02X} {name}" for value, name in rows if value > ORIGINAL_GLOBALS
    ]
    return (
        "Globals:\n" + "\n".join(globals_) + "\n\nLocals:\n" + "\n".join(locals_) + "\n"
    )


def compile_songs(
    root: Path,
    songs: Iterable[Path],
    cartridge: Path,
    work: Path,
    asar: Path | None = None,
    values: Mapping[str, int] | None = None,
) -> Soundtrack:
    """Compile ``songs`` with the AddmusicK installed at ``root``.

    ``songs`` are MML files; each may have a folder of samples beside it, named
    by its own ``#path`` directive, which is copied in under ``samples/``.
    ``cartridge`` is the project's built ROM: ``-p`` writes nothing to it, but
    AddmusicK still reads one to decide the freespace layout of a patch we
    throw away. ``values`` is the music value each song answers to, by file
    name -- what pins a song to its value across imports; without it the songs
    are numbered from :data:`CUSTOM_FIRST` in the order given.

    Raises :class:`MusicError` with the tool's own output where it failed --
    which is the only place a reason is ever written, AddmusicK reporting by
    prose rather than by exit code.
    """
    songs = list(songs)
    if not songs:
        raise MusicError("no songs to compile")
    if values is None:
        values = {one.name: index for index, one in enumerate(songs, CUSTOM_FIRST)}
    unvalued = [one.name for one in songs if one.name not in values]
    if unvalued:
        raise MusicError(f"no music value chosen for {', '.join(unvalued)}")
    low = [
        f"{name} at ${value:02X}"
        for name, value in values.items()
        if value < CUSTOM_FIRST
    ]
    if low:
        raise MusicError(
            f"a project's songs answer to ${CUSTOM_FIRST:02X} and up -- below "
            f"that is the stock soundtrack's -- so these cannot be compiled: "
            f"{', '.join(sorted(low))}"
        )
    stock = originals(root)
    stage(root, work, asar)
    entries = [
        (position, f"originals/{one.name}") for position, one in enumerate(stock, 1)
    ] + sorted((values[one.name], one.name) for one in songs)
    for source in songs:
        shutil.copy2(source, work / "music" / source.name)
        for folder in _sample_folders(source):
            shutil.copytree(folder, work / "samples" / folder.name, dirs_exist_ok=True)
    (work / "music" / "originals").mkdir(exist_ok=True)
    for one in stock:
        shutil.copy2(one, work / "music" / "originals" / one.name)
    (work / "Addmusic_list.txt").write_text(_song_list(entries), encoding="utf-8")
    shutil.copy2(cartridge, work / cartridge.name)

    try:
        done = subprocess.run(  # noqa: S603 - the path is the user's own setting
            [
                str((work / executable(root).name).resolve()),
                "-noblock",
                "-v",
                "-p",
                cartridge.name,
            ],
            cwd=work,
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
            stdin=subprocess.DEVNULL,
            check=False,
            env={"LD_LIBRARY_PATH": "."},
        )
    except subprocess.TimeoutExpired as error:
        raise MusicError(
            f"AddmusicK did not finish within {TIMEOUT} seconds and was stopped. "
            f"Some releases print one error forever rather than giving up; the "
            f"song it was on is the last one named in its output."
        ) from error
    except OSError as error:
        raise MusicError(f"AddmusicK could not be run: {error}") from error

    log = done.stdout + done.stderr
    if "Success!" not in log:
        raise MusicError(f"AddmusicK did not finish. What it said:\n\n{log.strip()}")
    return read_run(work, dict(entries), log)


def sample_folders_named(mml: Path) -> list[Path]:
    """The sample folders one MML file names beside itself, whether or not
    they are there -- ``#path "name"`` is how a package says where its own
    waveforms are, and the folder is a sibling of the file. A song using
    only the shipped samples names none."""
    text = mml.read_text(encoding="utf-8", errors="replace")
    return [
        mml.parent / match.group(1) for match in re.finditer(r'#path\s+"([^"]+)"', text)
    ]


def _sample_folders(mml: Path) -> list[Path]:
    """The sample folders one MML file names that are actually beside it."""
    return [folder for folder in sample_folders_named(mml) if folder.is_dir()]


# -- writing it into the disassembly ------------------------------------------

#: Where the blobs go, under the assets root, and what the fragment calls them
#: from there. ``SPC700/*.asm`` already reaches ``Music/Levels/x.bin`` through
#: the same include path, so a directory beside those needs no build change at
#: all.
BLOB_DIR = Path("SPC700/Music/Custom")
BLOB_INCLUDE = "Music/Custom"

#: Where the fragment goes under the game folder.
FRAGMENT = Path("SPC700/Custom/custom-music.asm")
TRACKS_FRAGMENT = Path("SPC700/Custom/custom-tracks.asm")

_HEADER = """\
; Which songs this project carries, and the sample pool they share: the whole
; of what the custom music feature assembles into the music banks
; Config/MusicBank.asm reserves. Only read under !Define_SMW_CustomMusic.
;
; Written by the editor from one run of AddmusicK, which compiled every blob
; named here. The driver and the sequences have to come from the same run: a
; sequence's place in the sound chip's memory is computed from the driver's
; length, so two runs disagree about where a song lives without saying so.
;
; {tool}
"""


def _hex(value: int, digits: int = 2) -> str:
    return f"${value:0{digits}X}"


def _rows_of(entries: Sequence[str], directive: str, per_line: int = 8) -> str:
    """One table, wrapped so a person can read it."""
    if not entries:
        return "\t; none\n"
    lines = []
    for start in range(0, len(entries), per_line):
        lines.append(f"\t{directive} " + ", ".join(entries[start : start + per_line]))
    return "\n".join(lines) + "\n"


def fragment_text(found: Soundtrack, tool: str = "") -> str:
    """The fragment that assembles ``found`` into the music banks."""
    songs = {song.value: song for song in found.songs}
    out = [_HEADER.format(tool=tool or "Compiled by AddmusicK.")]

    out.append(
        f"\n!Define_SMW_CustomMusic_SongCount #= {_hex(found.rows)}\n"
        f"!Define_SMW_CustomMusic_GlobalCount #= {_hex(found.globals)}\n"
    )
    names = ("ARAMRet", "ARAMRetMore", "ARAMRetTable")
    out.append(
        "".join(
            f"!Define_SMW_CustomMusic_{name} #= {_hex(value, 4)}\n"
            for name, value in zip(names, found.aram_returns, strict=True)
        )
    )

    out.append(
        "\n; The driver, and the terminator that closes its stream and names\n"
        "; the entry point the sound chip jumps to once it has arrived.\n"
        "macro SMW_CustomMusic_Driver()\n"
        f'\tincbin "{BLOB_INCLUDE}/driver.bin"\n'
        f"\tdw $0000 : dw {_hex(_entry(found), 4)}\n"
        "endmacro\n"
    )

    out.append(
        "\n; One long pointer per music value; a zero row is a value with no\n"
        "; song, which is every row the project has not filled.\n"
        "macro SMW_CustomMusic_SongPointers()\n"
        + _rows_of(
            [
                f"Song{value:02X}" if value in songs else "$000000"
                for value in range(found.rows)
            ],
            "dl",
            4,
        )
        + "endmacro\n"
    )

    out.append(
        "\nmacro SMW_CustomMusic_SamplePointers()\n"
        + _rows_of([f"Sample{one.index:02X}" for one in found.samples], "dl", 4)
        + "endmacro\n"
    )
    out.append(
        "\nmacro SMW_CustomMusic_SampleLoops()\n"
        + _rows_of([_hex(one.loop, 4) for one in found.samples], "dw")
        + "endmacro\n"
    )

    out.append(
        "\n; A word per music value naming its sample list, then the lists:\n"
        "; a count, then that many sample numbers.\n"
        "macro SMW_CustomMusic_SampleGroups()\n"
        + _rows_of(
            [
                f"Group{value:02X}" if value in songs else "$0000"
                for value in range(found.rows)
            ],
            "dw",
            4,
        )
    )
    for song in found.songs:
        out.append(
            f"Group{song.value:02X}:\n"
            f"\tdb {_hex(len(song.samples))}\n"
            + _rows_of([_hex(one, 4) for one in song.samples], "dw")
        )
    out.append("endmacro\n")

    out.append("\nmacro SMW_CustomMusic_Blobs()\n")
    for song in found.songs:
        out.append(
            f"Song{song.value:02X}:\t"
            f'incbin "{BLOB_INCLUDE}/song{song.value:02X}.bin"\t; {song.name}\n'
        )
    for one in found.samples:
        out.append(
            f'Sample{one.index:02X}:\tincbin "{BLOB_INCLUDE}/brr{one.index:02X}.bin"\n'
        )
    out.append("endmacro\n")
    return "".join(out)


_TRACKS_HEADER = """\
; What every track define means while the sound driver is resident: the
; whole cartridge speaks AddmusicK's numbering, because the driver's request
; sites -- rewritten by its own tweaks -- and its pointer tables do. Each
; stock track becomes the value the tool's own defines give its song,
; read out of the very run that compiled the soundtrack, and each imported
; song gets a track define of its own. MusicFade becomes the driver's fade
; command, which is $FF rather than a song.
;
; Read from Misc_Defines_SMW.asm after the stock definitions, under the
; feature, so these win exactly where the driver is there to answer them.
; Written by the editor beside custom-music.asm; the shipped copy is empty,
; because a build with the feature on and nothing imported still runs the
; stock engine, whose numbering is the stock one.
"""


def tracks_text(found: Soundtrack) -> str:
    """The track redefinitions ``found``'s driver makes true.

    The values come from the run's own patch files -- the defines the tool's
    tweaks assemble their request-site patches against -- so the two cannot
    disagree. They are gathered over every file the patch reads, in include
    order, rather than keyed to ``UserDefines.asm`` by name: AddmusicK has
    moved its defines between files before (1.0.5 states them inline in
    ``tweaks.asm``), and following the patch is what :data:`PATCH_ENTRY`
    promises. A name no file states, or a value no row of the soundtrack
    answers, is refused by name: either is a release renumbering the
    originals, and a table written against a guess plays the wrong song.
    """
    stated: dict[str, int] = {}
    for text in found.patch.values():
        stated.update(_defines(text))
    rows = {song.value for song in found.songs} | set(range(1, found.globals + 1))
    out = [_TRACKS_HEADER]
    for stock, amk in TRACK_NAMES.items():
        value = stated.get(amk)
        if value is None:
            raise MusicError(
                f"no file of AddmusicK's patch states !{amk}, so what "
                f"the driver plays for {stock} is unknown -- this release "
                f"renumbers the originals, and guessing would play the wrong "
                f"song"
            )
        if value not in rows:
            raise MusicError(
                f"no row of the soundtrack answers to ${value:02X}, which "
                f"the patch's defines say is !{amk} -- the originals compiled "
                f"do not match the numbering the driver's request sites use"
            )
        out.append(f"!Define_SMW_{stock} = ${value:02X}\n")
    out.append("!Define_SMW_LevelMusic_MusicFade = $FF\n")
    customs = found.custom_songs
    if customs:
        out.append(
            "\n; One level-header track per imported song, so a\n"
            "; LevelMusicTable row can name it like any other.\n"
            + "".join(
                f"!Define_SMW_LevelMusic_Custom{song.value:02X} = "
                f"${song.value:02X}\t; {song.name}\n"
                for song in customs
            )
        )
    return "".join(out)


def _entry(found: Soundtrack) -> int:
    """Where the sound chip starts running once the driver has arrived: the
    driver block's own destination, which is where AddmusicK based it."""
    return int.from_bytes(found.driver[2:4], "little") if len(found.driver) >= 4 else 0


def write(found: Soundtrack, game: Path, assets: Path, tool: str = "") -> list[Path]:
    """Write ``found`` out as a fragment and its blobs, and say what moved.

    ``game`` is where the fragment goes -- the disassembly's game folder, or a
    project's shadow of it -- and ``assets`` the assets root the blobs are
    reached through.
    """
    # Both fragments are rendered before anything touches disk: rendering is
    # what refuses a soundtrack (a renumbering release, an unstated define),
    # and a refusal must leave the project as it was, not half-written.
    fragment = fragment_text(found, tool)
    tracks = tracks_text(found)
    blobs = assets / BLOB_DIR
    blobs.mkdir(parents=True, exist_ok=True)
    written = [blobs / "driver.bin"]
    (blobs / "driver.bin").write_bytes(found.driver)
    for song in found.songs:
        path = blobs / f"song{song.value:02X}.bin"
        path.write_bytes(song.data)
        written.append(path)
        if song.spc is not None and song.value >= CUSTOM_FIRST:
            # The audition file the same compile wrote: playable in an
            # emulator with no rebuild, so it is kept beside the sequence it
            # previews rather than thrown away with the run.
            path = blobs / f"song{song.value:02X}.spc"
            path.write_bytes(song.spc)
            written.append(path)
        if song.report and song.value >= CUSTOM_FIRST:
            # And the tool's own measurements, verbatim -- what the Songs tab
            # prices a song's ARAM against, read back rather than re-derived.
            path = blobs / f"song{song.value:02X}.stats.txt"
            path.write_text(song.report, encoding="utf-8")
            written.append(path)
    for one in found.samples:
        path = blobs / f"brr{one.index:02X}.bin"
        path.write_bytes(one.data)
        written.append(path)
    # Anything left from a soundtrack that had more songs than this one would
    # never be incbin'd again, but it would still be in the project.
    keep = {path.name for path in written}
    for stale in (
        *blobs.glob("*.bin"),
        *blobs.glob("*.spc"),
        *blobs.glob("*.stats.txt"),
    ):
        if stale.name not in keep:
            stale.unlink()

    patch = blobs / PATCH_DIR
    if found.patch:
        for name, text in found.patch.items():
            (patch / name).parent.mkdir(parents=True, exist_ok=True)
            (patch / name).write_text(text, encoding="utf-8")
            written.append(patch / name)
    # A file an earlier run's tool read and this one's does not -- a release
    # that moved its defines, say -- would still assemble, against text the
    # new run never wrote.
    if patch.is_dir():
        keep_patch = {(patch / name) for name in found.patch}
        for stale in sorted(patch.rglob("*"), reverse=True):
            if stale.is_file() and stale not in keep_patch:
                stale.unlink()
            elif stale.is_dir() and not any(stale.iterdir()):
                stale.rmdir()

    source = game / FRAGMENT
    source.parent.mkdir(parents=True, exist_ok=True)
    source.write_text(fragment, encoding="utf-8")
    written.append(source)
    tracks_path = game / TRACKS_FRAGMENT
    tracks_path.write_text(tracks, encoding="utf-8")
    written.append(tracks_path)
    return written


# -- letting AddmusicK's own runtime read our data ----------------------------

#: What the tool's generated patch calls the things we place ourselves. Its
#: pointer rows name a label eight bytes ahead of its own RATS tag, which is
#: exactly where our blob starts -- the tag is what it needs to find its data
#: again in a ROM it patched, and the assembler placing ours makes it
#: unnecessary.
_PLACED = re.compile(
    r"^org [$][0-9A-Fa-f]{6}\n(music|brr)([0-9A-Fa-f]{2}): incbin \"bin/\1\2\.bin\"\n",
    re.MULTILINE,
)
_DRIVER = re.compile(
    r"^org !SPCProgramLocation[ \t]*\r?\n\s*incbin \"bin/main\.bin\"[ \t]*\r?\n?",
    re.MULTILINE,
)
_PROGRAM_LOC = re.compile(r"^!SPCProgramLocation\s*=\s*[$][0-9A-Fa-f]+", re.MULTILINE)
_NAMED = re.compile(r"(music|brr)([0-9A-Fa-f]{2})\+8")

#: The tool's own way into the frame: a `JML` over five bytes of the main loop
#: -- the call to the game mode and the store that ends the frame. Those five
#: bytes are the disassembly's one frame hook, which the per-frame code feature
#: also wants, so the patch is turned round instead: it is entered by a `JSL`
#: from that hook rather than taking the bytes, and returns instead of jumping
#: back into the main loop.
_HIJACK = re.compile(
    r"^org [$]8075[ \t]*\r?\n\s*JML MainLabel[ \t]*\r?\n", re.MULTILINE
)
#: The tool's own sample-group table, which the fragment emits instead.
_GROUPS_INCLUDE = re.compile(
    r'^\s*incsrc "SongSampleList\.asm"[ \t]*\r?\n', re.MULTILINE
)
_RETURN = re.compile(r"^\s*JML [$]00806B\|!Bank\b[^\n]*$", re.MULTILINE)
#: The tool's rewrite of ``LevelMusicTable`` into its own numbering, in its
#: tweaks. The generated ``custom-tracks.asm`` makes our table assemble those
#: values already, so the hunk would write what is there -- except over a row
#: the editor repointed, which it would quietly put back. The one table hunk
#: with no ``read1`` guard of its own, so it is taken out on the way to the
#: assembler; the overworld pair guards itself against a table already in the
#: tool's numbering.
_LEVEL_TABLE_HUNK = re.compile(
    r"^org \$0584DB[ \t]*\r?\n\s*db [^\n]*\r?\n", re.MULTILINE
)


class PatchError(MusicError):
    """AddmusicK's generated patch could not be rewritten."""


def placed_labels(symbols: object, prefix: str = "SMW_CustomMusic_") -> dict[str, int]:
    """Where our own build put each blob, by the name AddmusicK knows it as.

    ``symbols`` is a :class:`smw_tools.symbols.SymbolTable`. The disassembly's
    labels are ``Song01`` and ``Sample00``; the tool's rows say ``music01`` and
    ``brr00``, so this is the one place the two vocabularies meet.
    """
    found: dict[str, int] = {}
    for name, symbol in getattr(symbols, "by_name", {}).items():
        if not name.startswith(prefix):
            continue
        tail = name[len(prefix) :]
        # Exactly two hex digits, so the three tables -- SamplePointers,
        # SampleLoops and SampleGroups -- are not read as samples of their own.
        if match := re.fullmatch(r"(Song|Sample)([0-9A-Fa-f]{2})", tail):
            kind = "music" if match.group(1) == "Song" else "brr"
            found[f"{kind}{match.group(2).upper()}"] = symbol.addr
        elif tail == "Driver":
            found["driver"] = symbol.addr
        elif tail == "FrameHook":
            found["framehook"] = symbol.addr
        elif tail == "SampleGroups":
            found["samplegroups"] = symbol.addr
    return found


def rewrite_patch(text: str, placed: Mapping[str, int]) -> str:
    """Point AddmusicK's patch at the data our own ROM map placed.

    The tool compiles the songs and writes the runtime that plays them; where
    the bytes go is the disassembly's to say. So the patch's own placement
    comes out -- every ``org``/``incbin`` pair, and the driver's -- and its
    pointer rows are rewritten to the addresses our build reports, which is the
    whole of the join between the two.

    **The three tables stay where the tool puts them.** Its runtime reads
    ``MusicPtrs``, ``SamplePtrs`` and ``SampleLoopPtrs`` with absolute indexed
    addressing inside its own bank, so moving them would mean changing
    instructions rather than data -- and they are a few bytes a song, where the
    sequences and samples are kilobytes. What moves is what is big.

    Raises :class:`PatchError` naming any blob the patch wants and the build
    did not place, because a row left pointing at a dropped ``incbin`` would
    assemble to an address in nothing.
    """
    wanted = {f"{kind}{index.upper()}" for kind, index in _NAMED.findall(text)} | (
        {"driver"} if _DRIVER.search(text) else set()
    )
    missing = sorted(one for one in wanted if one not in placed)
    if missing:
        raise PatchError(
            f"AddmusicK's patch names {', '.join(missing)}, which this build "
            f"did not place. The cartridge has to be built with the compiled "
            f"music in it before the patch can point at it."
        )

    # The placement comes out first, so what is left naming a blob is a
    # pointer row and nothing else.
    #
    # **Every substitution below is counted.** A release that spells one of
    # these differently would otherwise leave the tool's own placement in the
    # patch, which assembles the same songs a second time into banks nothing
    # declared -- a silent wrong answer, where a refusal is a message. The
    # anchors have not moved in the five years of this tool's history, but that
    # is a reason to check cheaply rather than a reason not to check.
    text, dropped = _PLACED.subn("", text)
    _expect(dropped, len(wanted) - (1 if "driver" in wanted else 0), "org/incbin pair")
    text, dropped = _DRIVER.subn("", text)
    _expect(dropped, 1 if "driver" in wanted else 0, "driver placement")
    text, named = _NAMED.subn(
        lambda one: f"${placed[f'{one.group(1)}{one.group(2).upper()}']:06X}", text
    )
    _expect(bool(named), bool(wanted - {"driver"}), "pointer row")
    text, moved = _PROGRAM_LOC.subn(
        f"!SPCProgramLocation = ${placed['driver']:06X}", text, count=1
    )
    _expect(moved, 1 if "driver" in wanted else 0, "driver's location")

    # And the frame: entered from the disassembly's own hook instead of taking
    # the main loop's five bytes, and returning instead of jumping back into
    # it. One exit to turn round -- the routine's pushes and pulls are already
    # balanced, so an RTL after them is what a JSL needs.
    if "framehook" in placed:
        text, hijacked = _HIJACK.subn(
            f"org ${placed['framehook']:06X}\n\tJSL MainLabel\n\tRTL\n", text
        )
        if hijacked:
            text, returned = _RETURN.subn("\tRTL", text)
            if returned != 1:
                raise PatchError(
                    f"AddmusicK's runtime has {returned} ways back into the "
                    f"main loop, not the one this rewrite turns into a return"
                )
    # And the sample groups: the tool writes them into a freespace search of
    # its own, and the fragment already emits the same table -- a word per
    # music value naming its list, then the lists, each a count and that many
    # sample numbers. So its file is dropped and every reference to the table
    # becomes the address ours landed at. \b keeps !SampleGroupPtrsLoc, which
    # is a different thing, out of it.
    if "samplegroups" in placed:
        text, dropped = _GROUPS_INCLUDE.subn("", text)
        _expect(dropped, 1, "sample-group include")
        text, named = re.subn(
            r"\bSampleGroupPtrs\b", f"${placed['samplegroups']:06X}", text
        )
        _expect(bool(named), True, "sample-group table")
    return text


def _expect(found: object, wanted: object, what: str) -> None:
    """Refuse a rewrite that did not find what it was rewriting."""
    if found != wanted:
        raise PatchError(
            f"AddmusicK's generated patch has {found} of what this expected to "
            f"be {wanted}: the {what}. This release spells something "
            f"differently from the ones the rewrite was written against, and "
            f"guessing would put the songs in the cartridge twice."
        )


def apply_patch(
    patch_dir: Path, rom: Path, symbols: object, asar: Path, work: Path
) -> bool:
    """Assemble the sound driver's runtime into ``rom``, and say whether it ran.

    ``patch_dir`` is where a project keeps what AddmusicK generated; ``symbols``
    the table this build emitted, which is where the data ended up. Answers
    ``False`` for a project that has imported nothing, which is not a failure --
    there is no runtime to write because there is nothing to play.

    **The patch is rewritten before it is assembled**, never applied as it
    stands: :func:`rewrite_patch` takes out its placement and points it at what
    the ROM map placed instead. It is then assembled by *this* repository's
    asar, in a directory of its own, so what reaches the cartridge is a build
    pass rather than a tool writing to it.
    """
    source = patch_dir / PATCH_ENTRY
    if not source.is_file():
        return False
    placed = placed_labels(symbols)
    if not placed:
        raise PatchError(
            "this build placed no custom music, so the sound driver's runtime "
            "has nothing to point at -- the cartridge has to be assembled with "
            "Define_SMW_CustomMusic on"
        )
    # The tool's own directory shape, because one include reaches out of it.
    # The one table hunk with no guard of its own comes out on the way -- see
    # _LEVEL_TABLE_HUNK -- counted across the lot, so a release that moves it
    # refuses rather than quietly putting a repointed row back.
    dropped = 0
    for name in patch_files(patch_dir)[1:]:
        (work / name).parent.mkdir(parents=True, exist_ok=True)
        held = (patch_dir / name).read_text(encoding="utf-8", errors="replace")
        held, taken = _LEVEL_TABLE_HUNK.subn("", held)
        dropped += taken
        (work / name).write_text(held, encoding="utf-8")
    _expect(dropped, 1, "level music table rewrite")
    written = work / "SNES" / "runtime.asm"
    written.parent.mkdir(parents=True, exist_ok=True)
    written.write_text(
        rewrite_patch(source.read_text(encoding="utf-8", errors="replace"), placed),
        encoding="utf-8",
    )
    done = subprocess.run(  # noqa: S603 - our own vendored assembler
        [
            str(asar.resolve()),
            "--fix-checksum=off",
            written.name,
            str(rom.resolve()),
        ],
        cwd=written.parent,
        capture_output=True,
        text=True,
        stdin=subprocess.DEVNULL,
        check=False,
    )
    if done.returncode != 0:
        raise PatchError(
            f"the sound driver's runtime could not be assembled into the "
            f"cartridge:\n\n{(done.stdout + done.stderr).strip()}"
        )
    return True
