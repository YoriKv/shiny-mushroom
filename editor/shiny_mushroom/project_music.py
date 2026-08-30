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

from pathlib import Path

from shiny_mushroom.music_tables import (
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

#: Where the game's defines are, under the base's game folder -- the same file
#: the Audio window reads its names out of.
DEFINES_FILE = Path("Misc_Defines_SMW.asm")


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
        """Every track a header music setting may be given."""
        return track_choices(self._music_text(DEFINES_FILE))

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
