"""The Project menu's windows: the tables and text that belong to no level.

The Map16 editor, the Secondary Entrances window, the Strings window and the
memory map. Each is a window over the open **project** rather than over the
level on the canvas, so none of them follows a level switch, and each is kept
and brought forward rather than rebuilt -- the work in one outlives a trip to
another level or to the world map.

The cartridge's arrival tables are read here too, because a screen exit marked
Secondary entrance is read against them wherever it is shown.
"""

from __future__ import annotations

from collections.abc import Callable

from shiny_mushroom import level_names, secondary_entrances, strings
from shiny_mushroom.build import (
    BuildError,
    SharedRoom,
    asm_runs,
    asm_shared_rooms,
    features_wanted,
)
from shiny_mushroom.memory_map import MemoryMap, memory_map
from shiny_mushroom.project import HandEditedRegion, ProjectError
from shiny_mushroom.rom_patches import secondary_entrance_rows
from shiny_mushroom.ui.map16_dialog import Map16Dialog
from shiny_mushroom.ui.memory_map_dialog import MemoryMapDialog
from shiny_mushroom.ui.secondary_entrances_dialog import SecondaryEntrancesDialog
from shiny_mushroom.ui.strings_window import StringsWindow
from shiny_mushroom.ui.window.parts import _rebuild_detail
from smw_tools.asm_codec import AsmRegionError, AsmRegionFull
from smw_tools.asm_regions import region_for
from smw_tools.features import STRING_TABLES_RELOCATED, FeatureError

__all__ = ["ProjectWindows"]


class ProjectWindows:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s project windows."""

    def edit_map16(self) -> None:
        """Open the Map16 editor over the level on the canvas, or bring it
        forward -- see :mod:`shiny_mushroom.ui.map16_dialog`. Kept like the
        Strings window; a save there reloads the level through
        :meth:`_refresh_picture`, which is where the saved patch is seen."""
        if self._project is None or self._snapshot is None:
            return
        if self._map16 is None:
            self._map16 = Map16Dialog(self._project, self._refresh_picture, self)
        self._map16.show_snapshot(self._snapshot)
        self._map16.show()
        self._map16.raise_()
        self._map16.activateWindow()

    def _close_map16(self) -> None:
        """Put the editor away with the project whose tables it holds."""
        if self._map16 is not None:
            self._map16.close()
            self._map16.deleteLater()
            self._map16 = None

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
        self._status_message("Strings saved", 4000)
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
