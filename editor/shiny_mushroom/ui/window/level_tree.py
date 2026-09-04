"""The Level Data window: the project's level tree, and the edits its rows make.

One window over everything the project knows about its levels -- which file
holds each, what each is called, what the pointers say and how much room a
stream has -- and the edits made from its rows: remapping a level to another
number, repointing a stream, adding, renaming, deleting and reverting a level
file, and the labels a container carries. Kept and re-read rather than rebuilt,
so the work in it survives a level switch.

The project's graphics files sit here too: the window that edits them is the
Project menu's, but what a saved graphics edit costs is a level reload, which
is the same question every row here asks.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtWidgets import QDialog, QFileDialog, QInputDialog

from shiny_mushroom import level_palettes
from shiny_mushroom.build import BuildError, asm_runs
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer2_table import Layer2Entry, Layer2TableError
from shiny_mushroom.level_data import LevelData, level_label_rows, level_number_rows
from shiny_mushroom.level_files import (
    container_names,
    level_choices,
    level_file_rows,
)
from shiny_mushroom.level_pointers import LevelPointersError, StreamTarget
from shiny_mushroom.memory_map import LevelBudgets, level_budgets
from shiny_mushroom.mwl import Container, MwlError, blank_container
from shiny_mushroom.palettes import PaletteError
from shiny_mushroom.project import Project, ProjectError
from shiny_mushroom.ui.add_level_file_dialog import (
    BLANK,
    COPY,
    IMPORT_TITLE,
    AddLevelFileDialog,
    ImportLevelDialog,
    usable_name,
)
from shiny_mushroom.ui.level_data_dialog import LevelDataDialog
from shiny_mushroom.ui.remap_level_dialog import RemapLevelDialog
from smw_tools.asm_codec import AsmRegionError
from smw_tools.features import MANAGED_LEVEL_MEMORY
from smw_tools.levels import LEVELS_DIR, undecorated
from smw_tools.paths import GAME_DIR

__all__ = ["LevelTree"]


class LevelTree:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s level-tree half."""

    def view_level_data(self) -> None:
        """Open the project's level data -- numbers, labels and files as
        three tabs -- or bring the window forward.

        One dialog, kept, exactly as the overworld tables are: 512 numbers
        and 245 files are a place to work through. It is a view of the
        *project's* tree -- overlay included, so a remapped number reads as
        the remap and an edited level shows its edited sizes -- which is why
        it needs a project and goes down with one.
        """
        if self._project is None:
            return
        if self._level_data is None:
            self._level_data = LevelDataDialog(self)
            self._level_data.level_activated.connect(self._level_file_followed)
            self._level_data.pointers_edited.connect(self.edit_level_pointers)
            self._level_data.layer2_edited.connect(self.edit_level_layer2)
            self._level_data.remap_requested.connect(self.remap_level)
            self._level_data.add_requested.connect(self.add_level_file)
            self._level_data.import_requested.connect(self.import_level_files)
            self._level_data.rename_requested.connect(self.rename_level_file)
            self._level_data.recorded_level_edited.connect(self.record_level_number)
            self._level_data.delete_requested.connect(self.delete_level_files)
            self._level_data.revert_requested.connect(self.revert_level_files)
            self._level_data.restore_requested.connect(self.restore_level_files)
            self._level_data.delete_labels_requested.connect(self.delete_level_labels)
            self._level_data.restore_labels_requested.connect(self.restore_level_labels)
            self._adopt_shortcuts(self._level_data)
        self._level_data.show_data(self._level_data_rows())
        self._level_data.show()
        self._level_data.raise_()
        self._level_data.activateWindow()

    def _name_levels(self) -> None:
        """Tell the level picker which container each of its rows reads.

        Without a project that is the checkout's own tree, which is what a
        cart opened by hand was built from anyway.
        """
        project = self._project
        base = GAME_DIR if project is None else project.base
        target = None if project is None else project.target
        placed = None if project is None else project.level_map()
        self._container_files = container_names(base, target, placed)
        self._level_choices = level_choices(self._container_files)
        self.level_bar.show_files(self._container_files)
        # A destination picker on show is filled from the old names -- a
        # project's remap renames a level while the panel is up.
        self._refresh_properties()
        self._level_exits.refresh()

    def _level_data_rows(self) -> LevelData:
        """The window's three tabs over the project as it stands, and what
        its pickers may point a number at."""
        project = self._project
        if project is None:
            return LevelData(numbers=[], labels=[], files=[])
        layer1, sprites = project.level_pointer_labels()
        try:
            layer2 = project.layer2_table()
        except (Layer2TableError, OSError):
            layer2 = None
        added = project.added_level_files()
        deleted = project.deleted_level_labels()
        return LevelData(
            numbers=level_number_rows(
                layer1,
                sprites,
                project.level_definitions(),
                layer2,
                project.repointed_levels(),
            ),
            labels=level_label_rows(
                project.base, project.target, layer1, sprites, layer2, added, deleted
            ),
            files=level_file_rows(
                project.base,
                project.target,
                project.source,
                project.level_map(),
                added,
                deleted,
                tuple(sorted(project._edited_containers())),
            ),
            layer1_targets=project.layer1_targets(),
            sprite_targets=project.sprite_targets(),
            layer2_choices=() if layer2 is None else project.layer2_choices(),
            budgets=self._level_budgets(project),
        )

    def _level_budgets(self, project: Project) -> LevelBudgets | None:
        """Where ``project`` writes its level data, for the window's foot, or
        ``None`` when a container it prices cannot be read -- the tables are
        worth showing without the bars."""
        try:
            return level_budgets(project)
        except (ProjectError, OSError):
            return None

    def _refresh_level_data(self) -> None:
        """Bring the open window up to date after something moved a container
        or a pointer table. Cheap to skip: a closed window re-reads on open."""
        if self._level_data is not None and self._level_data.isVisible():
            self._level_data.show_data(self._level_data_rows())

    def remap_level(self, level: int = -1, container: str = "") -> None:
        """Point a level number at other containers, through the viewer's
        dialog -- ``level`` is where the flow starts, ``-1`` for the level on
        the canvas, and ``container`` the file the viewer had selected, which
        the pickers open on.

        The remap is a project edit, not a document one, so it does not join
        the level's undo stack the way the header dialog's Layer 2 repoint
        does: it can name any of the 512 numbers, most of which are not the
        level in hand, and taking one back is remapping back -- the dialog
        starts from the current mapping, so the way back is always on it.

        A remap of the level on the canvas replaces the document, exactly as
        loading it fresh would -- the number now *means* another file -- so it
        asks :meth:`_may_replace`'s question first and applies nothing when
        the answer is no. The reload previews through the same seam a saved
        level does: :func:`~shiny_mushroom.cart_patches.all_patches`
        compares the project's streams -- now the remapped container's --
        against the cartridge's own, so the picture is right before any build.
        """
        project = self._project
        if project is None:
            return
        placed = project.level_map()
        names = container_names(project.base, project.target, placed)
        if level < 0:
            level = self._level if self._level is not None else 0
        dialog = RemapLevelDialog(
            names,
            project.layer1_targets(),
            project.sprite_targets(),
            level,
            self._level_data or self,
            container=container or None,
            gap=project.layer2_gap,
            layer2=project.layer2_for_container,
        )
        if dialog.exec() != QDialog.DialogCode.Accepted.value:
            return
        self.edit_level_pointers(
            dialog.chosen_level, dialog.chosen_layer1(), dialog.chosen_sprites()
        )

    def edit_level_pointers(
        self,
        level: int,
        layer1: StreamTarget | None,
        sprites: StreamTarget | None,
    ) -> None:
        """Point ``level``'s entries at ``layer1`` and ``sprites`` -- ``None``
        for a stream left where it is -- and reload the level if it is the
        one on the canvas. What the remap dialog and the Level Data window's
        pointer cells both end in; :meth:`remap_level` says why it is a
        project edit rather than an undo step.

        A Layer 1 move takes the level's Layer 2 with it: the container
        records what its level had there
        (:meth:`~shiny_mushroom.project.Project.layer2_for_container`), and
        without it the number would draw its old background under the new
        level -- or hang on a Layer 2 mode with nothing to walk. A container
        that names none the tree holds leaves the entry alone, and the status
        line says so.
        """
        project = self._project
        if project is None or (layer1 is None and sprites is None):
            return
        if level == self._level and not self._may_replace(level):
            return
        carried = (
            None if layer1 is None else project.layer2_for_container(layer1.container)
        )
        try:
            project.save_level_pointers(level, layer1, sprites, layer2=carried)
        except (LevelPointersError, Layer2TableError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(level, 3)} could not be remapped.", detail=str(error)
            )
            return
        self._name_levels()
        self._refresh_level_data()
        self._refresh_memory_map()
        where = project.level_file(level)
        read = (
            "nothing"
            if where is None
            else where.layer1.stem
            if where.one_file
            else f"{where.layer1.stem} (Layer 1) and {where.sprites.stem} (sprites)"
        )
        if carried is not None:
            read += f", with {carried.describe()} as its Layer 2"
        elif layer1 is not None:
            read += "; its Layer 2 stays where it was"
        self.statusBar().showMessage(
            f"Level {hexnum(level, 3)} now reads {read}.", 5000
        )
        if level == self._level:
            # The number in hand means another file now; the document has to
            # be rebuilt from a load made under the new tables.
            self._reload_the_canvas_level()

    def edit_level_layer2(self, level: int, entry: Layer2Entry) -> None:
        """Point ``level``'s Layer 2 entry at ``entry``, from the Level Data
        window's cell.

        The level on the canvas goes through :meth:`_repoint_layer2`, so the
        repoint is one undo step and the reload carries the work in hand.
        Any other number is a project edit like a remap: the table is
        written, and the number loads under it when it is next opened --
        :func:`~shiny_mushroom.cart_patches.layer2_pointer_patch` previews
        the entry over the cartridge's own on every load.
        """
        project = self._project
        if project is None:
            return
        if level == self._level:
            self._repoint_layer2(entry)
            return
        try:
            project.save_layer2_pointer(level, entry)
        except (Layer2TableError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(level, 3)}'s Layer 2 could not be repointed.",
                detail=str(error),
            )
            return
        self._refresh_level_data()
        self._refresh_memory_map()
        self.statusBar().showMessage(
            f"Level {hexnum(level, 3)}'s Layer 2 now reads {entry.describe()}", 5000
        )

    def rename_level_file(self, name: str) -> None:
        """Call an added container something else, through the Level Data
        window: the level numbers reading it follow the new name."""
        project = self._project
        if project is None:
            return
        new_name, accepted = QInputDialog.getText(
            self._level_data or self,
            "Rename a Level File",
            f"New name for {name}.mwl:",
            text=name,
        )
        new_name = new_name.strip()
        if not accepted or not new_name or new_name == name:
            return
        try:
            written = project.rename_level_file(name, new_name)
        except (LevelPointersError, ProjectError, OSError) as error:
            self._alert(f"{name}.mwl could not be renamed.", detail=str(error))
            return
        self._name_levels()
        self._refresh_level_data()
        self.statusBar().showMessage(f"{name}.mwl is now {written.stem}.mwl.", 5000)

    def record_level_number(self, name: str, level: int) -> None:
        """Stamp a container with the level number it records, through the
        Level Data window's cell. A record the game never reads, so nothing
        on the canvas changes; the file is edited, so its row says so."""
        project = self._project
        if project is None:
            return
        try:
            project.record_level_in_file(name, level)
        except (ProjectError, OSError) as error:
            self._alert(f"{name}.mwl could not be restamped.", detail=str(error))
            return
        self._refresh_level_data()
        self.statusBar().showMessage(
            f"{name}.mwl now records level {hexnum(level, 3)}.", 5000
        )

    def add_level_file(self) -> None:
        """Bring a new container into the project, through the viewer's dialog.

        The bytes come from wherever the dialog chose -- a blank level, a copy
        of a container as the build would read it (the overlay's version, so
        copying an edited level copies the edit), or an ``.mwl`` from disk,
        which is how a level made in Lunar Magic comes in. The project
        validates and files it, and
        :meth:`~shiny_mushroom.project.Project.sync_level_fragments` writes the
        overlay fragment that puts it in the next build.
        """
        project = self._project
        if project is None:
            return
        shipped = {path.stem for path in (project.base / LEVELS_DIR).glob("*.mwl")}
        offered = tuple(
            sorted(shipped | set(project.added_level_files()), key=str.lower)
        )
        dialog = AddLevelFileDialog(offered, self._level_data or self)
        if dialog.exec() != QDialog.DialogCode.Accepted.value:
            return
        kind, detail = dialog.chosen_source
        try:
            if kind == BLANK:
                data = blank_container()
            elif kind == COPY:
                data = project.source(
                    project.base / LEVELS_DIR / f"{detail}.mwl"
                ).read_bytes()
            else:
                found, _ = QFileDialog.getOpenFileName(
                    self, "Add a Level File", "", "Lunar Magic levels (*.mwl)"
                )
                if not found:
                    return
                data = Path(found).read_bytes()
            # The streams are packed into the managed level banks, so the
            # first add offers to turn the feature on -- the same migration
            # the Features dialog runs, rebuild and all. The rebuild's reopen
            # puts the viewer away with the outgoing cartridge, so it comes
            # back below with the add in it.
            viewing = self._level_data is not None and self._level_data.isVisible()
            if not self._want_feature(MANAGED_LEVEL_MEMORY.id):
                return
            project = self._project
            written = project.add_level_file(dialog.chosen_name, data)
        except (ProjectError, OSError) as error:
            self._alert("The level file could not be added.", detail=str(error))
            return
        if viewing and not self._level_data.isVisible():
            self.view_level_data()
        else:
            self._refresh_level_data()
        self.statusBar().showMessage(
            f"{written.stem}.mwl added. Remap a level number at it to open it.",
            8000,
        )

    def import_level_files(self) -> None:
        """Bring ``.mwl`` files in from outside, whole: each is added, the
        level number it records is pointed at it, and the palette beside it
        becomes that level's own.

        What a Lunar Magic export is: ``105.mwl`` recording level ``$105``,
        and ``105.pal`` beside it where the palette was exported too. A
        container that carries a palette of its own -- the bit Lunar Magic
        sets when the level uses it -- dresses the level in that where no
        ``.pal`` sits beside the file. The dialog per file lets the name and
        the number be changed and the pointing declined.
        """
        project = self._project
        if project is None:
            return
        chosen, _filter = QFileDialog.getOpenFileNames(
            self, IMPORT_TITLE, "", "Lunar Magic levels (*.mwl)"
        )
        for path in map(Path, chosen):
            if not self._import_level_file(path):
                return

    def _import_level_file(self, path: Path) -> bool:
        """One file of :meth:`import_level_files`; ``False`` to stop the
        batch, on a cancel or a refusal."""
        project = self._project
        if project is None:
            return False
        try:
            data = path.read_bytes()
            container = Container.read(data)
        except (OSError, MwlError) as error:
            self._alert(f"{path.name} could not be read.", detail=str(error))
            return False
        shipped = {held.stem for held in (project.base / LEVELS_DIR).glob("*.mwl")}
        offered = tuple(
            sorted(shipped | set(project.added_level_files()), key=str.lower)
        )
        recorded = container.recorded_level
        if recorded is not None and not 0 <= recorded < 0x200:
            recorded = None
        beside = path.with_suffix(".pal")
        blob: bytes | None = None
        try:
            if beside.is_file():
                blob = level_palettes.read_pal(beside.read_bytes())
                palette = f"{beside.name} beside it becomes the level's own palette."
            elif container.custom_palette and container.carried_palette is not None:
                blob = level_palettes.from_container(container.carried_palette)
                palette = "The palette the file carries becomes the level's own."
            else:
                palette = (
                    "No palette comes with it: the level wears the shared colours."
                )
        except PaletteError as error:
            self._alert(f"{beside.name} could not be read.", detail=str(error))
            return False
        dialog = ImportLevelDialog(
            offered,
            usable_name(path.stem, offered),
            recorded,
            palette,
            self._level_data or self,
        )
        if dialog.exec() != QDialog.DialogCode.Accepted.value:
            return False
        name, level = dialog.chosen_name, dialog.chosen_level
        return self._land_level_file(
            name,
            data,
            level,
            blob,
            path.name,
            container.lunar_magic_settings,
            container.layer3_settings,
        )

    def _land_level_file(
        self,
        name: str,
        data: bytes,
        level: int | None,
        blob: bytes | None,
        source: str,
        settings: bytes | None = None,
        layer3: bytes | None = None,
    ) -> bool:
        """Add the container, point ``level`` at it, dress the level in
        ``blob`` and give it ``settings`` -- the four bytes a Lunar Magic
        container carries beyond the secondary header, where the project's
        cartridge keeps them -- the whole of what importing one file does,
        past the asking. Each step needs the feature that carries it and
        offers the switch the way the tick and Add a File do; the settings
        alone ask for nothing, landing only where the built cartridge already
        keeps the tables, since a container always carries some and a level
        that has not picked a scroll setting of its own is not a reason to
        grow the cartridge."""
        viewing = self._level_data is not None and self._level_data.isVisible()
        if not self._want_feature(MANAGED_LEVEL_MEMORY.id):
            return False
        project = self._project
        try:
            written = project.add_level_file(name, data)
        except (ProjectError, OSError) as error:
            self._alert(f"{source} could not be added.", detail=str(error))
            return False
        said = f"{written.stem}.mwl added"
        if level is not None:
            layer1 = next(
                (t for t in project.layer1_targets() if t.container == written.stem),
                None,
            )
            sprites = next(
                (t for t in project.sprite_targets() if t.container == written.stem),
                None,
            )
            # The settings land before the pointers move: the pointer edit
            # reloads the level if it is the one on the canvas, and that
            # load reads the tables as they stand.
            settled = settings is not None and self._settle_lunar_magic(level, settings)
            placed = layer3 is not None and self._settle_layer3(level, layer3)
            self.edit_level_pointers(level, layer1, sprites)
            said += f", read by level {hexnum(level, 3)}"
            if blob is not None and self._dress_level(level, blob):
                said += ", wearing its palette"
            if settled:
                said += ", with its Lunar Magic settings"
            if placed:
                said += ", placing Layer 3 its own way"
        else:
            said += ". Remap a level number at it to open it"
        if viewing and not (self._level_data and self._level_data.isVisible()):
            self.view_level_data()
        else:
            self._refresh_level_data()
        self.statusBar().showMessage(said + ".", 8000)
        return True

    def _settle_lunar_magic(self, level: int, settings: bytes) -> bool:
        """Write a container's four Lunar Magic bytes into the project's
        tables for ``level``, where the cartridge keeps them, and say whether
        anything landed. Not offered the feature: see :meth:`_land_level_file`."""
        project = self._project
        if project is None or not project.has_lunar_magic_settings:
            return False
        try:
            if project.lunar_magic_settings(level) == settings:
                return False
            project.save_lunar_magic_settings(level, settings, asm_runs(project))
        except (AsmRegionError, BuildError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(level, 3)}'s Lunar Magic settings were not written.",
                detail=str(error),
            )
            return False
        return True

    def _settle_layer3(self, level: int, settings: bytes) -> bool:
        """Write a container's four Layer 3 bytes into the project's tables
        for ``level``, where the cartridge keeps them, and say whether
        anything landed -- :meth:`_settle_lunar_magic`'s rule, for the same
        reason."""
        project = self._project
        if project is None or not project.has_layer3_settings:
            return False
        try:
            if project.layer3_settings(level) == settings:
                return False
            project.save_layer3_settings(level, settings, asm_runs(project))
        except (AsmRegionError, BuildError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(level, 3)}'s Layer 3 settings were not written.",
                detail=str(error),
            )
            return False
        return True

    def delete_level_files(self, names: list) -> None:
        """Take the named containers' level data out of the build, through
        the viewer.

        Asked about first, and the question differs by what a delete is:
        a file the project added has no other copy and goes for good, while
        one the game ships stays on disk, loads as the empty level and can be
        restored -- which is what makes deleting the game's own levels the
        way to make room. The project is what refuses an added file some
        level number still reads. A deletion that empties the level on the
        canvas reloads it, through the unsaved-work question first.
        """
        project = self._project
        if project is None or not names:
            return
        added = set(project.added_level_files())
        gone = [name for name in names if name in added]
        kept = [name for name in names if name not in added]
        listed = ", ".join(f"{name}.mwl" for name in names)
        detail = []
        if kept:
            detail.append(
                f"{len(kept)} of the game's own: every level reading one loads "
                f"as an empty level, and Restore puts it back."
            )
        if gone:
            detail.append(
                f"{len(gone)} added by this project: the file's level data is "
                f"lost, and any container it was copied from is untouched."
            )
        if not self._confirm(f"Delete {listed}?", " ".join(detail)):
            return
        if self._reads_any(names) and not self._may_replace(self._level):
            return
        failed = []
        for name in names:
            try:
                project.delete_level_file(name)
            except (ProjectError, OSError) as error:
                failed.append(f"{name}.mwl: {error}")
        self._level_files_changed(names, failed, "deleted")

    def revert_level_files(self, names: list) -> None:
        """Put the named containers back to the game's own bytes, through the
        viewer -- the file-wise form of Revert Level."""
        project = self._project
        if project is None or not names:
            return
        listed = ", ".join(f"{name}.mwl" for name in names)
        if not self._confirm(
            f"Revert {listed}?",
            "Every edit saved to these files is lost, and so is any undo "
            "history of a level on the canvas that reads them.",
        ):
            return
        if self._reads_any(names) and not self._may_replace(self._level):
            return
        failed = []
        for name in names:
            try:
                project.revert_level_file(name)
            except (ProjectError, OSError) as error:
                failed.append(f"{name}.mwl: {error}")
        self._level_files_changed(names, failed, "reverted")

    def restore_level_files(self, names: list) -> None:
        """Put the named deleted containers back into the build."""
        project = self._project
        if project is None or not names:
            return
        if self._reads_any(names) and not self._may_replace(self._level):
            return
        failed = []
        for name in names:
            try:
                project.restore_level_file(name)
            except (ProjectError, OSError) as error:
                failed.append(f"{name}.mwl: {error}")
        self._level_files_changed(names, failed, "restored")

    def delete_level_labels(self, labels: list) -> None:
        """Take the named labels' streams out of the build, through the
        Level Data window's label tab: a stream at a time, where the file
        tab's Delete is every stream of a file. Asked about first; a
        deletion that empties a stream of the level on the canvas reloads
        it, through the unsaved-work question."""
        project = self._project
        if project is None or not labels:
            return
        listed = ", ".join(labels)
        if not self._confirm(
            f"Delete {listed}?",
            "Each stream is inserted as the empty level: every level number "
            "naming the label loads it empty, and Restore puts it back.",
        ):
            return
        if self._reads_labels(labels) and not self._may_replace(self._level):
            return
        try:
            moved = project.delete_level_labels(labels)
        except (ProjectError, OSError) as error:
            self._alert("The labels could not be deleted.", detail=str(error))
            return
        self._level_labels_changed(labels, len(moved), "deleted")

    def restore_level_labels(self, labels: list) -> None:
        """Put the named deleted labels' streams back into the build."""
        project = self._project
        if project is None or not labels:
            return
        if self._reads_labels(labels) and not self._may_replace(self._level):
            return
        try:
            moved = project.restore_level_labels(labels)
        except (ProjectError, OSError) as error:
            self._alert("The labels could not be restored.", detail=str(error))
            return
        self._level_labels_changed(labels, len(moved), "restored")

    def _level_labels_changed(self, labels: list, done: int, did: str) -> None:
        self._name_levels()
        self._refresh_level_data()
        self._refresh_memory_map()
        if done:
            self.statusBar().showMessage(
                f"{done} level label{'s' if done != 1 else ''} {did}.", 5000
            )
        if self._reads_labels(labels):
            self._reload_the_canvas_level()

    def _reads_labels(self, labels: list) -> bool:
        """Whether the level on the canvas names one of ``labels`` in any of
        its three entries."""
        project = self._project
        if project is None or self._level is None:
            return False
        wanted = {undecorated(label) for label in labels}
        try:
            held = set(project.level_labels(self._level))
            held.add(undecorated(project.layer2_table().entry(self._level).label))
        except (LevelPointersError, Layer2TableError, OSError):
            return False
        return bool(held & wanted)

    def _reads_any(self, names: list) -> bool:
        """Whether the level on the canvas reads one of ``names``."""
        project = self._project
        if project is None or self._level is None:
            return False
        where = project.level_file(self._level)
        if where is None:
            return False
        held = {path.stem for path in where.paths}
        layer2 = project.layer2_file(self._level)
        if layer2 is not None:
            held.add(layer2.stem)
        return bool(held & set(names))

    def _level_files_changed(self, names: list, failed: list, did: str) -> None:
        """What every file-wise gesture ends with: the viewer and the memory
        map brought up to date, the canvas level reloaded where it read one
        of the files, and what could not be done said by file."""
        if failed:
            self._alert(f"Not every file could be {did}.", detail="\n".join(failed))
        self._name_levels()
        self._refresh_level_data()
        self._refresh_memory_map()
        done = len(names) - len(failed)
        if done:
            self.statusBar().showMessage(
                f"{done} level file{'s' if done != 1 else ''} {did}.", 5000
            )
        if self._reads_any(names):
            self._reload_the_canvas_level()

    def _close_level_data(self) -> None:
        """Put the viewer away with the project it was reading."""
        if self._level_data is not None:
            self._level_data.close()
