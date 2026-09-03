"""Reading and writing the project's two audio tables.

:mod:`shiny_mushroom.music_tables` is the model; this is the half that touches
the project. Both tables are fixed-size and every edit is one token moving, so
this is the simplest save path in the editor: read the fragment the build would
read, move a token, and write the result to the overlay -- or take the overlay's
copy away again where the edit puts the table back to the disassembly's own.

**Nothing is priced.** No row is added or removed, so no run of ROM changes size
and there is no :class:`~smw_tools.asm_codec.AsmRegionFull` to raise. What can go
wrong is naming something that does not exist, which is refused by name here
rather than left for the assembler to fail on: a define no ``Misc_Defines_SMW``
line states, or a song label the bank's own source does not define.

**A save marks the build stale and nothing else.** The bytes only move when asar
next runs -- the pointer tables live inside the SPC700 blobs, which are their own
assembly passes -- so unlike a level or a palette there is no live preview to
feed. Project > Rebuild is what makes the edit audible.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom.music_tables import (
    LEVEL_MUSIC_PREFIX,
    LEVEL_MUSIC_TABLE,
    MUSIC_POINTERS,
    MUSIC_SOURCES,
    LevelMusicTable,
    MusicPointerTable,
    TrackChoice,
    setting_names,
    song_labels,
    track_choices,
)
from shiny_mushroom.project_files import ProjectError, _now
from smw_tools import music

#: Where the game's defines are, under the base's game folder -- the same file
#: the Audio window reads its names out of.
DEFINES_FILE = Path("Misc_Defines_SMW.asm")

#: Where a project keeps the songs somebody imported, in its own folder beside
#: ``patches/`` and for the same reason: this is authored content, not a
#: shadow of anything in the disassembly. A package keeps the shape it arrives
#: in -- an MML file with a folder of samples beside it -- so it can be edited
#: in a text editor, kept in somebody's own version control, or copied in
#: untouched from wherever it came.
MUSIC_DIR = Path("music")

#: What an MML file is called. AddmusicK's own corpus uses both.
MUSIC_SUFFIXES = (".txt", ".mml")

#: How an imported song is spelled as a level-header track: one define per
#: music value, stated by the generated fragment while the feature is on --
#: which is what lets giving a level an imported song be the same token edit
#: as giving it Castle.
_CUSTOM_TRACK = re.compile(rf"^{LEVEL_MUSIC_PREFIX}Custom([0-9A-Fa-f]{{2}})$")


def custom_track_define(value: int) -> str:
    """The track define the fragment states for one imported song."""
    return f"{LEVEL_MUSIC_PREFIX}Custom{value:02X}"


def custom_track_value(define: str) -> int | None:
    """The music value a custom track define names, or ``None`` for any other."""
    found = _CUSTOM_TRACK.match(define)
    return int(found.group(1), 16) if found else None


@dataclass(frozen=True)
class ImportedSong:
    """One song the project's cartridge carries, as the overlay records it."""

    value: int
    name: str
    #: What its sequence costs in the cartridge.
    size: int
    #: Where it lands in the sound chip's memory.
    aram: int
    #: How many samples it wants.
    samples: int
    #: How long it plays, in seconds, as the compile measured it.
    length: float = 0.0
    #: What its echo buffer takes of the sound chip's memory.
    echo: int = 0
    #: What the sound chip has left with this song resident -- the budget a
    #: song plays inside alone. ``None`` for a song imported before the
    #: compile's report was kept; importing again writes one.
    free_aram: int | None = None


class MusicFiles:
    """:class:`~shiny_mushroom.project.Project`'s audio tables."""

    # -- reading ---------------------------------------------------------------

    def _music_text(self, relative: Path) -> str:
        """One of the audio sources as the build would read it -- the overlay's
        copy where an edit has written one."""
        return self.source(self.base / relative).read_text(encoding="utf-8")

    def level_music_table(self) -> LevelMusicTable:
        """The eight header music settings, as they would assemble."""
        return LevelMusicTable.read(self._music_text(LEVEL_MUSIC_TABLE))

    def music_pointers(self, blob: str) -> MusicPointerTable:
        """One bank's music values, as they would assemble."""
        return MusicPointerTable.read(self._music_text(MUSIC_POINTERS[blob]))

    def music_setting_names(self) -> tuple[str, ...]:
        """What this project's eight header music settings are called -- the
        names every window that shows a setting uses, so an edit reaches all of
        them at once."""
        return setting_names(self.level_music_table(), self.track_choices())

    def track_choices(self) -> tuple[TrackChoice, ...]:
        """Every track a header music setting may be given: the disassembly's
        own, then one per imported song -- named for the song, valued at the
        music value it answers to, spelled as the define the fragment states
        for it."""
        stock = track_choices(self._music_text(DEFINES_FILE))
        return stock + tuple(
            TrackChoice(custom_track_define(song.value), song.name, song.value)
            for song in self.imported_music()
        )

    def song_choices(self, blob: str) -> tuple[str, ...]:
        """Every song label one bank's music value may resolve to."""
        return song_labels(self._music_text(MUSIC_SOURCES[blob]))

    # -- writing ---------------------------------------------------------------

    def save_level_music(self, settings: dict[int, str]) -> list[Path]:
        """Give header music settings other tracks, and say which files moved.

        ``settings`` is setting number to define name, without the ``!``.
        Each must be a define the disassembly states: anything else assembles
        nothing, and a table written with it would fail the next build rather
        than this call.
        """
        known = {choice.define for choice in self.track_choices()}
        for setting, define in settings.items():
            if define not in known:
                raise ProjectError(
                    f"nothing defines !{define}, so giving music setting "
                    f"{setting} that track would not build"
                )
        table = self.level_music_table()
        for setting, define in settings.items():
            table = table.with_define(setting, define)
        return self._write_music(LEVEL_MUSIC_TABLE, table.text())

    def save_music_pointers(self, blob: str, values: dict[int, str]) -> list[Path]:
        """Point one bank's music values at other songs, and say which files
        moved.

        ``values`` is music value to song label. Each label must be one the
        **same bank's** source defines: the three banks share an ARAM window
        and never each other's songs, so a label from another one would
        assemble nothing here.
        """
        known = set(self.song_choices(blob))
        for value, label in values.items():
            if label not in known:
                raise ProjectError(
                    f"{MUSIC_SOURCES[blob].name} does not define {label}, so "
                    f"pointing music value ${value:02X} at it would not build"
                )
        table = self.music_pointers(blob)
        for value, label in values.items():
            table = table.with_song(value, label)
        return self._write_music(MUSIC_POINTERS[blob], table.text())

    def _write_music(self, relative: Path, text: str) -> list[Path]:
        """Shadow one fragment, or take the shadow away where the text is the
        disassembly's own again -- and stamp the project when either happened."""
        stock = (self.base / relative).read_text(encoding="utf-8")
        moved = self._shadow_or_revert(relative, text, stock)
        if moved is None:
            return []
        self._write_metadata({"modified": _now()})
        return [moved]

    def music_edited(self) -> bool:
        """Whether this project has written either table."""
        return any(
            self.overlaid(self.base / relative).is_file()
            for relative in (LEVEL_MUSIC_TABLE, *MUSIC_POINTERS.values())
        )

    def revert_music(self) -> list[Path]:
        """Take every audio table this project has written back out."""
        taken = []
        for relative in (LEVEL_MUSIC_TABLE, *MUSIC_POINTERS.values()):
            stock = (self.base / relative).read_text(encoding="utf-8")
            if moved := self._shadow_or_revert(relative, stock, stock):
                taken.append(moved)
        if taken:
            self._write_metadata({"modified": _now()})
        return taken

    # -- the songs the project carries -----------------------------------------

    @property
    def music_folder(self) -> Path:
        """Where this project's own song packages are."""
        return self.root / MUSIC_DIR

    def music_packages(self) -> list[Path]:
        """The MML files this project has, in the order they will be given
        music values: sorted by name, so importing twice with nothing changed
        gives every song the value it had.

        A package's samples are not listed. They are named by the MML's own
        ``#path`` and found beside it, which is the shape the community's
        packages arrive in and the shape AddmusicK expects to be handed.
        """
        folder = self.music_folder
        if not folder.is_dir():
            return []
        found = [
            path
            for path in folder.rglob("*")
            if path.is_file() and path.suffix.lower() in MUSIC_SUFFIXES
        ]
        return sorted(found, key=lambda path: str(path.relative_to(folder)).lower())

    def import_music(
        self, tool: Path, cartridge: Path, work: Path, asar: Path | None = None
    ) -> tuple[music.Soundtrack, list[Path]]:
        """Compile every package this project has, and lay the result over the
        disassembly.

        ``tool`` is the person's own AddmusicK -- nothing here is bundled --
        and ``cartridge`` this project's built ROM, which the tool reads and
        does not write. ``work`` is a directory for this one run, staged from
        the tool's own installation and thrown away by the caller: AddmusicK
        works in its working directory, so running in the person's copy would
        edit their install every time a song was imported.

        Answers what was compiled and which files moved. Raises
        :class:`~smw_tools.music.MusicError` with the tool's own words where it
        would not compile, because that is the only place a reason is written.
        """
        songs = self.music_packages()
        if not songs:
            raise ProjectError(
                f"there are no songs in {self.music_folder}. A song is an MML "
                f"file with its samples in a folder beside it, exactly as it "
                f"is packaged."
            )
        stems = [one.stem for one in songs]
        doubled = sorted({stem for stem in stems if stems.count(stem) > 1})
        if doubled:
            raise ProjectError(
                f"two packages are named {', '.join(doubled)}. Songs are "
                f"handed to AddmusicK and given values by name, so one of "
                f"them has to be renamed."
            )
        root = music.distribution(tool)
        found = music.compile_songs(
            root, songs, cartridge, work, asar, self._music_values(songs)
        )
        # The overlay's own two roots, asked for by the trees they shadow, so
        # nothing here has to know what the overlay calls them.
        moved = music.write(
            found,
            self.overlaid(self.base),
            self.overlaid(self.assets_base),
            music.version(root),
        )
        self._write_metadata({"modified": _now()})
        return found, moved

    def _music_values(self, songs: list[Path]) -> dict[str, int]:
        """A music value per package, by file name -- pinned across imports.

        A song keeps the value its last import gave it, read back from the
        fragment, so adding a package that sorts earlier renumbers nothing: a
        level given a song keeps that song. New packages take the lowest free
        value from :data:`~smw_tools.music.CUSTOM_FIRST` up, and a soundtrack
        that outgrows the mailbox is refused by name here rather than left to
        play the wrong thing.
        """
        held: dict[str, int] = {}
        fragment = self.overlaid(self.base / music.FRAGMENT)
        if fragment.is_file():
            held = {
                name: value
                for value, name in _imported_names(
                    fragment.read_text(encoding="utf-8", errors="replace")
                )
                # The originals ride every import at fixed values below the
                # floor, and a fragment from before the floor moved may pin a
                # song inside their range: neither is a pin worth keeping.
                if value >= music.CUSTOM_FIRST
            }
        used = set(held.values())
        out: dict[str, int] = {}
        free = music.CUSTOM_FIRST
        for path in songs:
            value = held.get(path.stem)
            if value is None:
                while free in used:
                    free += 1
                value = free
                used.add(value)
            if value > music.CUSTOM_LAST:
                raise ProjectError(
                    f"there is no music value left for {path.name}: imported "
                    f"songs answer to ${music.CUSTOM_FIRST:02X}-"
                    f"${music.CUSTOM_LAST:02X}, and every value is taken"
                )
            out[path.name] = value
        return out

    def imported_music(self) -> tuple[ImportedSong, ...]:
        """What this project's cartridge carries, read back out of the overlay.

        Read from the fragment and the blobs rather than kept in a sidecar,
        for the reason every other reading in this editor is taken from the
        files the build reads: a sidecar is a second copy of the truth, and the
        one that goes stale is always the one somebody trusts.
        """
        fragment = self.overlaid(self.base / music.FRAGMENT)
        if not fragment.is_file():
            return ()
        blobs = self.overlaid(self.assets_base / music.BLOB_DIR)
        found = []
        for value, name in _imported_names(
            fragment.read_text(encoding="utf-8", errors="replace")
        ):
            if value < music.CUSTOM_FIRST:
                # The originals: the stock soundtrack riding along so the
                # driver can play it, not something anybody imported.
                continue
            blob = blobs / f"song{value:02X}.bin"
            data = blob.read_bytes() if blob.is_file() else b""
            # The compile's own measurements, kept verbatim beside the blob:
            # the pricing is the tool's, read back rather than re-derived.
            stats = music.song_stats(blobs / f"song{value:02X}.stats.txt")
            free = stats.get("FREE ARAM (APPROXIMATE)")
            found.append(
                ImportedSong(
                    value,
                    name,
                    int.from_bytes(data[0:2], "little") if len(data) >= 4 else 0,
                    int.from_bytes(data[2:4], "little") if len(data) >= 4 else 0,
                    _group_size(fragment.read_text(encoding="utf-8"), value),
                    length=stats.get("SONG TOTAL LENGTH IN SECONDS", 0.0),
                    echo=int(stats.get("ECHO SIZE", 0)),
                    free_aram=int(free) if free is not None else None,
                )
            )
        return tuple(found)

    def imported_spc(self, value: int) -> Path | None:
        """The audition file one imported song's compile wrote, if it is kept.

        AddmusicK writes a playable ``.spc`` beside every song, and the import
        keeps it with the blobs -- so hearing a song costs handing this file
        to an emulator, with no rebuild in between. ``None`` for a song
        imported before previews were kept; importing again writes one.
        """
        path = self.overlaid(self.assets_base / music.BLOB_DIR / f"song{value:02X}.spc")
        return path if path.is_file() else None

    def imported_music_bytes(self) -> int:
        """What the imported blobs total, for pricing the music banks.

        The ``.bin`` files the fragment reads -- driver, sequences,
        samples -- and not the audition ``.spc`` files, which never enter the
        cartridge. Zero for a project that imported nothing.
        """
        blobs = self.overlaid(self.assets_base / music.BLOB_DIR)
        if not blobs.is_dir():
            return 0
        return sum(path.stat().st_size for path in blobs.glob("*.bin"))

    def music_imported(self) -> bool:
        """Whether this project has compiled any music into its cartridge."""
        return self.overlaid(self.base / music.FRAGMENT).is_file()

    def revert_imported_music(self) -> list[Path]:
        """Take the compiled music back out, leaving the packages alone.

        The songs somebody imported stay in ``music/``: what this removes is
        what the build reads, so the next import puts it back and nobody loses
        a file they went and found.
        """
        taken = []
        for relative in (music.FRAGMENT, music.TRACKS_FRAGMENT):
            fragment = self.overlaid(self.base / relative)
            if fragment.is_file():
                fragment.unlink()
                taken.append(fragment)
        blobs = self.overlaid(self.assets_base / music.BLOB_DIR)
        if blobs.is_dir():
            for blob in sorted(
                (*blobs.glob("*.bin"), *blobs.glob("*.spc"), *blobs.glob("*.stats.txt"))
            ):
                blob.unlink()
                taken.append(blob)
            # The runtime patch the same run generated: leaving it would hand
            # the next build a driver whose data the revert just took away.
            patch = blobs / music.PATCH_DIR
            if patch.is_dir():
                for path in sorted(patch.rglob("*"), reverse=True):
                    if path.is_file():
                        path.unlink()
                        taken.append(path)
                    else:
                        path.rmdir()
                patch.rmdir()
        if taken:
            self._write_metadata({"modified": _now()})
        return taken


_SONG_LINE = re.compile(
    r'^Song([0-9A-Fa-f]{2}):\s*incbin\s+"[^"]+"\s*;\s*(.*)$', re.MULTILINE
)
_GROUP_COUNT = re.compile(
    r"^Group([0-9A-Fa-f]{2}):\s*\n\s*db \$([0-9A-Fa-f]+)", re.MULTILINE
)


def _imported_names(text: str) -> list[tuple[int, str]]:
    """Which songs a fragment names, by value, with what they are called."""
    return [(int(value, 16), name.strip()) for value, name in _SONG_LINE.findall(text)]


def _group_size(text: str, value: int) -> int:
    """How many samples one song's group holds."""
    for found, count in _GROUP_COUNT.findall(text):
        if int(found, 16) == value:
            return int(count, 16)
    return 0
