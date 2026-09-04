"""The Project menu's windows: the tables and text that belong to no level.

The Secondary Entrances window, the Strings window, the memory map and the
audio. Each is a window over the open **project** rather than over the
level on the canvas, so none of them follows a level switch, and each is kept
and brought forward rather than rebuilt -- the work in one outlives a trip to
another level or to the world map. The Map16 tables are not here any more:
they are an editing environment of their own -- see
:mod:`shiny_mushroom.ui.map16_mode`.

The cartridge's arrival tables are read here too, because a screen exit marked
Secondary entrance is read against them wherever it is shown.
"""

from __future__ import annotations

import shutil
from collections.abc import Callable

from shiny_mushroom import level_names, secondary_entrances, strings
from shiny_mushroom.audio import AudioMap, AudioMapError, audio_map, audition
from shiny_mushroom.build import (
    BuildError,
    SharedRoom,
    asm_runs,
    asm_shared_rooms,
    features_wanted,
    rom_path,
)
from shiny_mushroom.external_emulator import LaunchError, launch
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memory_map import MemoryMap, memory_map
from shiny_mushroom.music_tables import MusicTableError
from shiny_mushroom.project import OUTPUT_DIR, HandEditedRegion, ProjectError
from shiny_mushroom.project_music import custom_track_value
from shiny_mushroom.rom_patches import secondary_entrance_rows
from shiny_mushroom.ui.audio_dialog import AudioDialog
from shiny_mushroom.ui.memory_map_dialog import MemoryMapDialog
from shiny_mushroom.ui.secondary_entrances_dialog import SecondaryEntrancesDialog
from shiny_mushroom.ui.settings_dialog import addmusick_tool, external_emulator
from shiny_mushroom.ui.strings_window import StringsWindow
from shiny_mushroom.ui.window.parts import MUSIC, STRINGS, _rebuild_detail
from smw_tools.asm_codec import AsmRegionError, AsmRegionFull
from smw_tools.asm_regions import region_for
from smw_tools.audio import LEVEL_MUSIC_BLOB, MUSIC_PORT, AudioError
from smw_tools.features import CUSTOM_MUSIC, STRING_TABLES_RELOCATED, FeatureError
from smw_tools.music import MusicError
from smw_tools.paths import asar_binary
from smw_tools.spc import SpcError

__all__ = ["ProjectWindows"]


class ProjectWindows:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s project windows."""

    # -- the cartridge's arrivals ----------------------------------------------

    def edit_secondary_entrances(self) -> None:
        """Open the Secondary Entrances window, or bring it forward.

        The cartridge's table of arrivals -- where a screen exit marked
        Secondary entrance lands, which level it loads and where in it the
        player arrives. A project window rather than a level one: the tables
        are indexed by the entrance number and belong to no level, so nothing
        in it follows the canvas. Kept like the Map16 editor, whose Save and
        Revert it works the same way -- see
        :mod:`shiny_mushroom.ui.secondary_entrances_dialog`.
        """
        if self._project is None:
            return
        if self._secondary_entrances is None:
            try:
                self._secondary_entrances = SecondaryEntrancesDialog(
                    self._project,
                    lambda: self._level_choices,
                    # Go to opens the level the row loads and looks at where
                    # the row lands in it, exactly as following the exit that
                    # names the row does.
                    lambda record: self.follow_exit(record.destination, record),
                    self,
                )
                # What a screen exit says on the canvas and where its Go to
                # leads are read out of these tables, so an edit here is an
                # edit of both.
                self._secondary_entrances.changed.connect(self._entrances_changed)
            except (
                AsmRegionError,
                secondary_entrances.EntrancesError,
                ProjectError,
                OSError,
            ) as error:
                self._alert(
                    "The secondary entrances could not be read.",
                    detail=str(error),
                )
                return
        self._secondary_entrances.show()
        self._secondary_entrances.raise_()
        self._secondary_entrances.activateWindow()

    def _close_secondary_entrances(self) -> None:
        """Put the window away with the project whose tables it holds."""
        if self._secondary_entrances is not None:
            self._secondary_entrances.close()
            self._secondary_entrances.deleteLater()
            self._secondary_entrances = None

    def _read_entrances(self) -> None:
        """Take the cartridge's arrival tables, for what a screen exit marked
        Secondary entrance offers and where it leads.

        The project's rows first and the image's second, on
        :meth:`_secondary_header_bytes`' terms and for its reason: the
        project carries what has been saved, which the session's ROM image
        predates, and a cartridge opened by hand has no project to ask but
        does have the tables in it.

        Read at the two moments they can change -- a cartridge loaded, a
        project opened -- rather than per question: a picker that asked the
        disassembly for four fragments every time a screen was clicked would
        put a file read behind a selection. ``None`` where neither can
        answer, which leaves an exit's destination the byte it holds.
        """
        self._entrances = None
        if self._project is not None:
            try:
                self._entrances = secondary_entrances.Entrances.read(
                    {
                        region_id: self._project.asm_rows(region_id)[0]
                        for region_id in secondary_entrances.REGION_IDS
                    }
                )
                return
            except (
                AsmRegionError,
                FeatureError,
                secondary_entrances.EntrancesError,
                ProjectError,
                OSError,
            ):
                self._entrances = None
        if self._rom is not None and self._addressable:
            try:
                self._entrances = secondary_entrances.Entrances(
                    secondary_entrance_rows(self._rom, where=self._addresses)
                )
            except secondary_entrances.EntrancesError:
                self._entrances = None

    def _entrances_changed(self) -> None:
        """Follow the Secondary Entrances window: a screen exit's label on the
        canvas and its rows in the panel are read out of the tables it owns,
        so an entrance edited there moves both."""
        self._show_screen_exits()
        self._refresh_properties()

    def _entrances_offered(self) -> secondary_entrances.Entrances | None:
        """The arrival tables a screen exit is read against.

        The **window's** where one has been opened, and the cartridge's as
        they were read otherwise: the Secondary Entrances window owns its
        document until it is saved, so an entrance filled in there is one a
        screen exit can be pointed at -- and read back through -- without
        saving first.
        """
        if self._secondary_entrances is not None:
            return self._secondary_entrances.document
        return self._entrances

    # -- the game's text -------------------------------------------------------

    def edit_strings(self) -> None:
        """Open the Strings window on the project's text, or bring it forward.

        Kept, like the viewers: the text is read out of the project once and
        edited in place, and reopening finds the window where it was left.
        Re-read on each opening only while nothing is unsaved in it -- an
        edit in hand is not thrown away by a menu click.
        """
        if self._project is None:
            return
        if self._strings is None:
            self._strings = StringsWindow(self)
            self._strings.save_asked.connect(self.save_strings)
            self._strings.revert_asked.connect(self.revert_strings)
        if not self._strings.unsaved and not self._read_strings():
            return
        self._strings.show()
        self._strings.raise_()
        self._strings.activateWindow()

    def _read_strings(self) -> bool:
        """Read the project's text into the window, saying so on failure."""
        assert self._strings is not None and self._project is not None
        project = self._project
        font = strings.Font.load(project.base)
        models: dict[str, tuple[bytes, ...] | None] = {}
        for region_id in (strings.MESSAGES, strings.NAMES):
            try:
                models[region_id] = project.asm_rows(region_id)
            except HandEditedRegion as error:
                self._alert("The strings could not be read.", detail=str(error.reason))
                return False
            except AsmRegionError as error:
                if "does not apply" in str(error):
                    # A target whose build has no such fragment: that half
                    # of the window is simply absent.
                    models[region_id] = None
                    continue
                self._alert(
                    "The strings could not be read.",
                    detail=_rebuild_detail(str(error)),
                )
                return False
            except OSError as error:
                self._alert("The strings could not be read.", detail=str(error))
                return False
        document = strings.StringsDocument.read(
            font, models[strings.MESSAGES], models[strings.NAMES]
        )
        # Both halves priced against the run *together*: a base that pools
        # them gives the two one run, and what one of them holds unsaved is
        # room the other does not have.
        rooms: tuple[SharedRoom, ...]
        try:
            rooms = asm_shared_rooms(
                project, [one for one, model in models.items() if model is not None]
            )
        except (BuildError, AsmRegionError, FeatureError, OSError):
            rooms = ()
        # Whether the slots and messages may be added to: the search follows
        # the tables only on a cartridge built with the growable strings.
        grows = (
            strings.MESSAGES in models
            and region_for(strings.MESSAGES, project.cartridge_base).grows
        )
        self._strings.show_document(
            font, document, rooms, self._translevel_namer(), grows=grows
        )
        return True

    def _translevel_namer(self) -> Callable[[int], str | None]:
        """A translevel's name off the world map in hand, or ``None`` where
        there is none to read -- for the Strings window's slot rows."""
        reading = self._world_reading()
        tables = self._name_tables()

        def name_of(translevel: int) -> str | None:
            if (
                reading is None
                or tables is None
                or not reading.level_names
                or translevel >= reading.shape.level_names
            ):
                return None
            return level_names.decode(reading.level_name(translevel), tables) or None

        return name_of

    def save_strings(self) -> bool:
        """Write the Strings window's text into the project, reporting
        success."""
        if self._project is None or self._strings is None:
            return False
        project = self._project
        document = self._strings.document
        font = strings.Font.load(project.base)
        try:
            models = document.models(font)
            changed = {
                region_id: model
                for region_id, model in models.items()
                if model != project.asm_region_stock(region_id)
                or project.asm_region_edited(region_id)
            }
            runs = asm_runs(project, changed) if changed else {}
            project.save_asm_regions(models, runs)
        except strings.TextError as error:
            self._alert("The strings could not be saved.", detail=str(error))
            return False
        except AsmRegionFull as error:
            if STRING_TABLES_RELOCATED.id not in features_wanted(project):
                # The stock run is what is full: the feature that moves the
                # text somewhere roomier is the answer, offered the way the
                # palettes offer theirs. The edit rides across the rebuild.
                return self._save_strings_relocated(document)
            self._alert(
                "The strings could not be saved: they no longer fit their run of ROM.",
                detail=f"{error.used:,} bytes against {error.room:,} - "
                f"{error.used - error.room:,} must come back out. "
                f"Nothing was saved.",
            )
            return False
        except HandEditedRegion as error:
            self._alert(
                "The strings could not be saved over a hand-edited fragment.",
                detail=str(error),
            )
            return False
        except (BuildError, ProjectError, AsmRegionError, OSError) as error:
            self._alert(
                "The strings could not be saved.",
                detail=_rebuild_detail(str(error)),
            )
            return False
        self._strings.set_saved(document)
        # Nothing patches the strings into a running cartridge -- they are
        # assembler text, not bytes at an offset -- so a test run shows the
        # built ones until a build carries these.
        self._note_build_only(STRINGS)
        self._status_message(
            "Strings saved -- Project > Rebuild (Ctrl+B) to see it", 8000
        )
        self._refresh_memory_map()
        return True

    def _save_strings_relocated(self, document: strings.StringsDocument) -> bool:
        """Offer the growable-strings feature for text the stock run cannot
        hold, and save through it if it is taken.

        A yes rebuilds and reopens the cartridge, which puts the window away
        with the outgoing project; the edit is marked saved first so the
        reopen's unsaved-work question does not ask about it, and put back
        into the reopened window before the save is tried again. A no leaves
        the edit in the window, unsaved, with the reason said.
        """
        assert self._strings is not None
        window = self._strings
        baseline = window.baseline
        window.set_saved(document)
        if not self._want_feature(STRING_TABLES_RELOCATED.id):
            window.set_saved(baseline)
            self._alert(
                "The strings could not be saved: they no longer fit their run "
                "of ROM, and the feature that would make room was not turned on.",
                detail="Shorten the text, or turn on Growable strings under "
                "Project > Features. Nothing was saved.",
            )
            return False
        if self._project is None:
            return False
        self.edit_strings()
        if self._strings is None or not self._read_strings():
            return False
        self._strings.restore(document)
        if STRING_TABLES_RELOCATED.id not in self._project.features:
            # The switch is thrown but the cartridge is still the old one --
            # the rebuild was declined or failed -- so the save would still
            # be priced against the stock run.
            self._status_message(
                "The strings save once the cartridge is rebuilt with growable strings.",
                8000,
            )
            return False
        return self.save_strings()

    def revert_strings(self, region_id: str) -> None:
        """Take one region's text back out of the project, and re-read."""
        if self._project is None or self._strings is None:
            return
        try:
            self._project.revert_asm_region(region_id)
        except (ProjectError, AsmRegionError, OSError) as error:
            self._alert(
                "The strings could not be reverted.",
                detail=_rebuild_detail(str(error)),
            )
            return
        self._read_strings()
        self._status_message("Strings put back", 4000)
        self._refresh_memory_map()

    def _close_strings(self) -> None:
        """Put the window away with the project it was editing."""
        if self._strings is not None:
            self._strings.close()

    def view_memory_map(self) -> None:
        """Open the cartridge's memory map, or bring it forward.

        Kept and re-read rather than rebuilt, exactly as
        :meth:`view_level_data` is: it is a thing to keep beside the work
        while making room, and its reading goes stale the moment anything is
        saved.
        """
        if self._project is None:
            return
        if self._memory_map is None:
            self._memory_map = MemoryMapDialog(self)
            self._adopt_shortcuts(self._memory_map)
        self._memory_map.show_map(self._laid_out())
        self._memory_map.show()
        self._memory_map.raise_()
        self._memory_map.activateWindow()

    def _laid_out(self) -> MemoryMap:
        """The open project's cartridge, laid out.

        Handed the window's own symbol table rather than letting the layout
        load one: it is already held against the build that wrote it
        (:meth:`_build_symbols`), and parsing ninety thousand lines again to
        answer the same question would be the most expensive part of opening
        this window.
        """
        return memory_map(self._project, self._build_symbols())

    def _refresh_memory_map(self) -> None:
        """Bring the open map up to date after a save moved something.

        Skipped when it is closed, which re-reads on open anyway -- the same
        trade :meth:`_refresh_level_data` makes, and worth more here, since
        this reads every bank of the ROM map rather than one project's levels.
        """
        if self._memory_map is not None and self._memory_map.isVisible():
            self._memory_map.show_map(self._laid_out())

    def _close_memory_map(self) -> None:
        """Put the map away with the project it was laid out from."""
        if self._memory_map is not None:
            self._memory_map.close()

    # -- what the SPC700 is sent ----------------------------------------------

    def view_audio(self) -> None:
        """Open the project's audio, or bring it forward.

        Kept and re-read, exactly as :meth:`view_memory_map` is. Unlike the
        map this one can only be read from a **build**: every byte it shows is
        in the cartridge and every address comes off the symbol file beside it,
        so a project that has never been built has nothing here to read and is
        told which menu row makes one.
        """
        if self._project is None:
            return
        read = self._audio_read()
        if read is None:
            return
        if self._audio is None:
            self._audio = AudioDialog(self)
            self._audio.repoint_asked.connect(self._repoint_music)
            self._audio.track_asked.connect(self._set_level_music)
            self._audio.import_asked.connect(self._import_music)
            self._audio.preview_asked.connect(self._preview_song)
            self._audio.music_preview_asked.connect(self._preview_music)
            self._audio.effect_preview_asked.connect(self._preview_effect)
            self._adopt_shortcuts(self._audio)
        self._audio.show_audio(read)
        self._show_songs()
        self._audio.show()
        self._audio.raise_()
        self._audio.activateWindow()

    def _audio_read(self) -> AudioMap | None:
        """The open project's audio, saying why not rather than opening empty.

        Handed the window's own symbol table and the cartridge already on the
        canvas, for :meth:`_laid_out`' reason: both are held against the build
        that wrote them, and this window is not worth a second reading of
        either.
        """
        assert self._project is not None
        symbols = self._build_symbols()
        if symbols is None or self._rom is None:
            self._alert(
                "The project's audio could not be read.",
                detail="It is read out of the cartridge the project builds, and "
                "this one has not been built yet -- Project > Rebuild (Ctrl+B) "
                "makes it.",
            )
            return None
        try:
            return audio_map(self._project, symbols, self._rom, self._addresses)
        except (AudioMapError, AudioError, ProjectError, OSError) as error:
            self._alert(
                "The project's audio could not be read.",
                detail=_rebuild_detail(str(error)),
            )
            return None

    def _refresh_audio(self) -> None:
        """Bring the open window up to date after a rebuild moved something.

        Skipped when it is closed, which re-reads on open anyway -- and skipped
        silently on a failed reading, since a window already showing a good one
        is better than an alert nobody asked for.
        """
        if self._audio is not None and self._audio.isVisible():
            read = self._audio_read()
            if read is not None:
                self._audio.show_audio(read)
            self._show_songs()

    def _show_songs(self) -> None:
        """Hand the AddmusicK tab what the project carries.

        Read from the overlay rather than from the cartridge, like the two
        editable tables and for the same reason: an import has to show at once,
        standing over a build that does not have it yet.
        """
        if self._audio is None or self._project is None:
            return
        self._audio.show_songs(
            self._project.imported_music(),
            self._project.music_folder,
            addmusick_tool() is not None,
            CUSTOM_MUSIC.id in features_wanted(self._project),
        )

    def _import_music(self) -> None:
        """Compile the project's songs into its cartridge.

        **The tool is the person's own and is never written to.** A run is
        staged into a directory of its own under the project's cache, because
        AddmusicK works in its working directory -- it rewrites its song list
        and fills its own output folders -- so running in an installation would
        edit it every time somebody imported, and two projects importing at
        once would race over one file.

        The cartridge is read by the tool and not written: it decides a
        freespace layout for a patch that is thrown away, since where anything
        goes is the disassembly's to say.
        """
        if self._project is None:
            return
        tool = addmusick_tool()
        if tool is None:
            self._alert(
                "No AddmusicK is set.",
                detail="Songs are compiled by AddmusicK, which is not part of "
                "this editor. File > Settings is where to point at your own "
                "copy.",
            )
            return
        # The songs reach the cartridge through the custom-music feature, so
        # importing is the flow that offers it -- the same offer a custom
        # palette or an overgrown string makes. A no still imports: the songs
        # are data the overlay keeps either way, and the note on the tab says
        # a build carries none of them until the switch is thrown.
        wanted = self._want_feature(CUSTOM_MUSIC.id)
        if self._project is None:
            return
        cartridge = rom_path(self._project)
        if not cartridge.is_file():
            self._alert(
                "The project has not been built yet.",
                detail="AddmusicK reads a cartridge to compile against, so "
                "Project > Rebuild (Ctrl+B) comes first.",
            )
            return
        work = self._project.root / OUTPUT_DIR / ".addmusick"
        try:
            shutil.rmtree(work, ignore_errors=True)
            found, _moved = self._project.import_music(
                tool, cartridge, work, asar_binary()
            )
        except (MusicError, ProjectError, OSError) as error:
            self._alert("The music could not be compiled.", detail=str(error))
            return
        finally:
            shutil.rmtree(work, ignore_errors=True)
        self._show_songs()
        # The songs land in the overlay as a fragment and its blobs, which no
        # patch can carry into a running cartridge -- the same reading the two
        # tables record in `_music_saved`, so an import owns up to it too.
        self._note_build_only(MUSIC)
        self._sync_rebuild_action()
        count = len(found.custom_songs)
        said = (
            f"{count} song{'' if count == 1 else 's'} compiled beside the "
            f"stock soundtrack, {found.rom_bytes:,} bytes"
        )
        self._status_message(
            f"{said} -- Project > Rebuild (Ctrl+B) to hear them"
            if wanted
            else f"{said} -- kept, but a build carries none until custom "
            f"music is turned on",
            8000,
        )

    def _repoint_music(self, blob: str, value: int, label: str) -> None:
        """Point one music value at another of its bank's songs.

        A token moving inside a fixed-size table, so there is nothing to price
        and no other value moves -- but the bytes are inside an SPC700 blob,
        which is its own assembly pass, so nothing is audible until the
        cartridge is rebuilt. The window is re-read from the project rather
        than from the build, which is what lets it show the edit at once and
        still be honest about needing one.
        """
        if self._project is None:
            return
        try:
            self._project.save_music_pointers(blob, {value: label})
        except (MusicTableError, ProjectError, OSError) as error:
            self._alert("The music value could not be repointed.", detail=str(error))
            return
        self._music_saved(f"Music value {hexnum(value, 2)} now plays {label}")

    def _set_level_music(self, setting: int, define: str) -> None:
        """Give one of the header's eight music settings another track.

        A stock track is a token move and nothing else. An imported song is
        reached through the custom-music feature, so picking one offers the
        switch first -- the table would otherwise name a define only the
        feature states, which is a build refused later for a reason given
        here.
        """
        if self._project is None:
            return
        if custom_track_value(define) is not None and not self._want_feature(
            CUSTOM_MUSIC.id
        ):
            self._alert(
                "The setting was left as it was.",
                detail="An imported song is reached through the custom-music "
                "feature, which was not turned on.",
            )
            return
        if self._project is None:
            return
        try:
            self._project.save_level_music({setting: define})
        except (MusicTableError, ProjectError, OSError) as error:
            self._alert("The music setting could not be changed.", detail=str(error))
            return
        self._music_saved(f"Music setting {setting} changed")

    def _preview_song(self, value: int) -> None:
        """Open one imported song's audition file in the external emulator.

        AddmusicK writes a playable ``.spc`` beside every song it compiles and
        the import keeps it, so hearing a song costs no rebuild and no SPC700
        core of our own: the emulator the person already uses opens the file.
        Nothing is patched or waited for, exactly as Test ROM Externally.
        """
        if self._project is None:
            return
        emulator = external_emulator()
        if emulator is None:
            self._alert(
                "No external emulator is set.",
                detail="A preview opens the song's .spc in the emulator named "
                "in File > Settings.",
            )
            return
        spc = self._project.imported_spc(value)
        if spc is None:
            self._alert(
                "This song has no audition file.",
                detail="Its compile predates song previews. Import again and "
                "one is kept beside every song.",
            )
            return
        try:
            launch(emulator, spc)
        except LaunchError as error:
            self._alert(
                f"{emulator.name} could not be started.",
                detail=f"{error} File > Settings is where the emulator is set.",
            )
            return
        self._status_message(f"Opened {spc.name} in {emulator.name}", 8000)

    def _preview_music(self, blob: str, value: int) -> None:
        """Open one of the cartridge's own songs in the external emulator."""
        self._audition(
            blob=blob,
            mailbox=MUSIC_PORT,
            value=value,
            name=f"music-{blob}-{value:02X}",
            title=self._song_named(blob, value),
        )

    def _preview_effect(self, mailbox: int, value: int) -> None:
        """Open one sound effect in the external emulator.

        The effects are uploaded once and are the same whichever music bank is
        resident, so the level bank stands in: an effect plays over whatever
        the window happens to hold, and here that is silence.
        """
        self._audition(
            blob=LEVEL_MUSIC_BLOB,
            mailbox=mailbox,
            value=value,
            name=f"sfx-{mailbox & 0xFFFF:04X}-{value:02X}",
            title=self._effect_named(mailbox, value),
        )

    def _song_named(self, blob: str, value: int) -> str:
        """What the window calls one music value, for the file's own tag."""
        read = self._audio.reading if self._audio is not None else None
        bank = read.bank(blob) if read is not None else None
        found = (
            next((one for one in bank.songs if one.value == value), None)
            if bank is not None
            else None
        )
        return found.name if found is not None else f"Music {hexnum(value, 2)}"

    def _effect_named(self, mailbox: int, value: int) -> str:
        read = self._audio.reading if self._audio is not None else None
        found = (
            next(
                (one for one in read.sfx if one.port == mailbox and one.value == value),
                None,
            )
            if read is not None
            else None
        )
        return found.name if found is not None else f"Effect {hexnum(value, 2)}"

    def _audition(
        self, *, blob: str, mailbox: int, value: int, name: str, title: str
    ) -> None:
        """Write one audition beside the cartridge and hand it to the emulator.

        The same route the imported songs' Preview takes, and for the same
        reason: an ``.spc`` is the whole of what a player needs, so nothing is
        patched, built or waited for. The difference is only where the file
        comes from -- AddmusicK wrote that one, and this one is composed from
        the cartridge's own uploads.

        It goes in the build folder because that is what it is made of: a
        reading of the last build, stale the moment another one lands, and
        nothing anyone needs to keep.
        """
        project = self._project
        if project is None:
            return
        emulator = external_emulator()
        if emulator is None:
            self._alert(
                "No external emulator is set.",
                detail="A preview opens the song's .spc in the emulator named "
                "in File > Settings.",
            )
            return
        symbols = self._build_symbols()
        if symbols is None or self._rom is None:
            self._alert(
                "There is no built cartridge to hear.",
                detail="A preview is composed from the cartridge's own uploads "
                "-- Project > Rebuild (Ctrl+B) makes one.",
            )
            return
        try:
            made = audition(
                self._rom,
                symbols,
                blob=blob,
                mailbox=mailbox,
                value=value,
                title=title,
                game=project.name,
            )
            path = project.root / OUTPUT_DIR / f"audition-{name}.spc"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(made)
        except (AudioMapError, AudioError, SpcError, OSError) as error:
            self._alert("This could not be auditioned.", detail=str(error))
            return
        try:
            launch(emulator, path)
        except LaunchError as error:
            self._alert(
                f"{emulator.name} could not be started.",
                detail=f"{error} File > Settings is where the emulator is set.",
            )
            return
        self._status_message(f"Playing {title} in {emulator.name}", 8000)

    def _music_saved(self, said: str) -> None:
        """After either audio table is written: show it, and arm Rebuild.

        The reading the window shows comes from the *cartridge* for everything
        but these two tables and from the **project** for them, so a re-read
        shows the edit standing over a build that does not have it yet. That is
        the honest picture, and the status line says which half is which.
        """
        self._refresh_audio()
        # The tables are assembler defines, which no patch can carry: the
        # cartridge plays the built ones until a build carries these.
        self._note_build_only(MUSIC)
        self._sync_rebuild_action()
        self._status_message(f"{said} -- Project > Rebuild (Ctrl+B) to hear it", 8000)

    def _close_audio(self) -> None:
        """Put the window away with the project it was read from.

        Closed and kept, like the memory map: what it holds is a reading rather
        than an edit, so the next project fills the same window.
        """
        if self._audio is not None:
            self._audio.close()
