"""The Level Load Path window: one level's whole chain, and its edits.

The overworld tile that loads the level, the translevel and the tables it
indexes, the level number, the files and the Layer 2 stream its pointer names,
and the entrance -- read from whichever document or table can answer, and each
box editable exactly where the thing it describes is owned. Following the
editor rather than pinned to a level: the selected tile over the world map,
the open level otherwise.

The window itself is :mod:`shiny_mushroom.ui.load_path_dialog`; what is here
is what fills it in and where each committed row lands.
"""

from __future__ import annotations

from shiny_mushroom import level_names, secondary_header
from shiny_mushroom.fields import Action, Field, readout
from shiny_mushroom.header import FIELDS_BY_KEY, HEADER_SIZE
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer2_table import Layer2TableError
from shiny_mushroom.load_path import (
    EDIT_HEADER,
    LAYER2_ENTRY,
    OPEN_LEVEL,
    SHOW_ON_MAP,
    LevelInfo,
    cell_for_level,
    cell_level,
    frozen_fields,
    level_info_fields,
)
from shiny_mushroom.overworld import (
    TILEMAP_SIZE,
    TRANSLEVEL_LEVELS_SIZE,
    WorldMap,
    cell_at,
    cell_place,
)
from shiny_mushroom.overworld_fields import CellWalk, name_fields, walk_fields
from shiny_mushroom.project import ProjectError
from shiny_mushroom.rom_patches import (
    layer1_base,
    layer2_is_background,
    levels_sharing_layer2,
)
from shiny_mushroom.ui.load_path_dialog import LoadPathDialog, Section
from shiny_mushroom.ui.overworld_mode import Kind
from shiny_mushroom.ui.window.modes import EditorMode

__all__ = ["SHOW_ON_MAP_ZOOM", "LoadPathWindow"]

# Where the load path's "Show on map" lands: close enough that the one tile it
# points at reads as a tile, far enough out that the map around it still says
# where on the world that is. Set outright, not as a ceiling -- the button's
# question is "where is this tile", and the answer should look the same
# whatever the map was last zoomed to.
SHOW_ON_MAP_ZOOM = 3


class LoadPathWindow:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s load-path half."""

    def view_load_path(self) -> None:
        """Open the Level Load Path window, or bring it forward.

        One level's whole chain -- the overworld tile, the translevel and its
        tables, the level number, the files and the Layer 2 the pointer
        names, the entrance -- following whatever the editor is on: the
        selected level tile over the world map, the open level otherwise.
        Kept and refreshed like the Level Data window, and its edits land in
        whichever document owns each row.
        """
        if self._path is None:
            return
        if self._load_path is None:
            self._load_path = LoadPathDialog(self)
            self._load_path.edited.connect(self._load_path_edited)
        heading, sections = self._load_path_sections()
        self._load_path.show_path(heading, sections)
        self._load_path.show()
        self._load_path.raise_()
        self._load_path.activateWindow()

    def _refresh_load_path(self) -> None:
        """Bring the window up to date with the editor, if it is up."""
        if self._load_path is None or not self._load_path.isVisible():
            return
        heading, sections = self._load_path_sections()
        self._load_path.refresh(heading, sections)

    def _close_load_path(self) -> None:
        """Put the window away with the cartridge its chain was read from."""
        if self._load_path is not None:
            self._load_path.close()

    def _world_reading(self) -> WorldMap | None:
        """The world map the chain is *read* from: the mode's document once a
        map has been shown, a reading of the cartridge's own tables before
        -- enough for every readout, and nothing a commit could reach."""
        if self._world.ready:
            return self._world.document
        if self._rom is None or not self._addressable:
            return None
        where = self._addresses

        def table(role: str, size: int) -> bytes:
            at = where.roles.get(role)
            if at is None:
                return b""
            offset = where.offset(at)
            return bytes(self._rom[offset : offset + size])

        tiles = table("overworld_layer1_tilemap", TILEMAP_SIZE)
        if len(tiles) != TILEMAP_SIZE:
            return None
        return WorldMap(
            tiles=tiles,
            directions=table(
                "overworld_level_directions",
                where.counts["overworld_level_directions"],
            ),
            level_events=table(
                "overworld_level_events", where.counts["overworld_level_events"]
            ),
            level_names=table(
                "overworld_level_names", where.counts["overworld_level_names"] * 2
            ),
            # Absent from the roles -- and so read as empty -- on every
            # cartridge without the translevel-remap feature, whose levels
            # are computed rather than tabled.
            translevel_levels=table(
                "overworld_translevel_levels", TRANSLEVEL_LEVELS_SIZE
            ),
        )

    def _load_path_subject(
        self,
    ) -> tuple[int | None, int | None, WorldMap | None, bool]:
        """Which level the window is about, and through which cell.

        Over the world map that is the selected level tile; over a level it
        is the open level, with its cell derived the way the game derives it
        forward -- and ``None`` for a sublevel no tile loads.
        """
        reading = self._world_reading()
        tiles = reading.tiles if reading is not None else b""
        world_mode = self._mode is EditorMode.WORLD
        level: int | None = None
        cell: int | None = None
        if world_mode:
            if self._world.ready:
                held = self._world.selection
                if held.kind is Kind.CELLS and len(held.keys) == 1:
                    index = next(iter(held.keys))
                    if reading is not None and reading.translevels[index]:
                        cell = index
                        level = cell_level(index, tiles, reading.translevel_levels)
        else:
            level = self._level
            if level is not None and tiles:
                cell = cell_for_level(
                    level, tiles, reading.translevel_levels if reading else b""
                )
        return level, cell, reading, world_mode

    def _load_path_sections(self) -> tuple[str, list[Section]]:
        """The window's heading and boxes for the editor as it stands."""
        level, cell, reading, world_mode = self._load_path_subject()
        if level is None:
            hint = (
                "Select a level tile on the map to trace its load path."
                if world_mode
                else "Open a level to trace its load path."
            )
            return hint, []
        sections = [
            found
            for found in (
                self._world_section(reading, cell, world_mode),
                self._level_section(level, world_mode),
                self._entrance_section(level, world_mode),
            )
            if found is not None
        ]
        name = ""
        tables = self._name_tables()
        if (
            reading is not None
            and cell is not None
            and tables is not None
            and reading.level_names
        ):
            translevel = reading.translevels[cell]
            if translevel < reading.shape.level_names:
                name = level_names.decode(reading.level_name(translevel), tables)
        return f"Level {hexnum(level, 3)}" + (f" -- {name}" if name else ""), sections

    def _name_tables(self) -> level_names.NameTables | None:
        """The cartridge's level-name tables, or ``None`` where the build
        has none -- the Japanese target's own format."""
        if self._rom is None or not self._addressable:
            return None
        return level_names.read_name_tables(self._rom, self._addresses)

    def _world_section(
        self, reading: WorldMap | None, cell: int | None, world_mode: bool
    ) -> Section | None:
        """The overworld box: the cell, the translevel's tables, the name."""
        if reading is None:
            return None
        if cell is None:
            return Section(
                "world",
                "Overworld",
                [],
                None,
                "No level tile loads this level: it is reached through "
                "screen exits and secondary entrances alone.",
            )
        record = CellWalk(
            reading, cell, self._world_level_events(reading), self._level_choices
        )
        translevel = reading.translevels[cell]
        rows = [
            readout(
                "Cell",
                lambda r: cell_place(*cell_at(r.index)),
                "Where the level tile stands on the map.",
            )
        ]
        if 0 < translevel < reading.shape.directions:
            rows += walk_fields(record)
            rows += name_fields(record, self._name_tables())
        else:
            rows += [
                readout(
                    "Translevel",
                    lambda r: hexnum(r.translevel),
                    "Past the walk-directions table's reach.",
                )
            ]
        rows.append(
            Field(
                key=SHOW_ON_MAP,
                label="",
                kind=Action("Show on map"),
                hint="Select this tile on the world map.",
            )
        )
        note = ""
        if not (world_mode and self._world.ready):
            rows = frozen_fields(rows)
            note = "Read from the map's tables; edit them over the world map (Ctrl+M)."
        return Section("world", "Overworld", rows, record, note)

    def _world_level_events(self, reading: WorldMap) -> bytes:
        """The level-events table the world rows quote -- the reading's own,
        or the capture's where the reading carries none."""
        if reading.level_events:
            return reading.level_events
        snapshot = self._world.snapshot
        return b"" if snapshot is None else snapshot.level_events

    def _level_section(self, level: int, world_mode: bool) -> Section:
        info = self._level_info(level, world_mode)
        return Section("level", "Level data", level_info_fields(info), info)

    def _level_info(self, level: int, world_mode: bool) -> LevelInfo:
        """The level half of the path, assembled from whoever can answer:
        the open document, the project's tree, or the cartridge image."""
        current = not world_mode and self._level == level and self._doc is not None
        files = shared = layer2_text = layer2_shared = header_text = None
        options: tuple[str, ...] = ()
        chosen = -1
        self._load_path_layer2 = ()
        named = self._container_files.get(level)
        if named is not None:
            files = (
                named.layer1
                if not named.split
                else f"{named.layer1} (Layer 1), {named.sprites} (sprites)"
            )
        if self._project is not None:
            also = self._project.also_changes(level)
            if also:
                shared = ", ".join(hexnum(found, 3) for found in also)
            try:
                table = self._project.layer2_table()
                entry = table.entry(level) if level < len(table.entries) else None
            except (Layer2TableError, ProjectError, OSError):
                entry = None
            if entry is not None:
                layer2_text = entry.describe()
                borrowers = [
                    found for found in table.levels_pointing(entry) if found != level
                ]
                if borrowers and not entry.background:
                    layer2_shared = ", ".join(hexnum(found, 3) for found in borrowers)
                if current:
                    try:
                        offered = tuple(self._project.layer2_choices())
                    except (Layer2TableError, ProjectError, OSError):
                        offered = ()
                    if offered:
                        self._load_path_layer2 = offered
                        options = tuple(one.describe() for one in offered)
                        chosen = next(
                            (at for at, one in enumerate(offered) if one == entry),
                            -1,
                        )
        elif self._rom is not None and self._addressable:
            try:
                background = layer2_is_background(
                    self._rom, level, where=self._addresses
                )
                layer2_text = (
                    "a shared background" if background else "a level's stream"
                )
                others = levels_sharing_layer2(self._rom, level, where=self._addresses)
                if others and not background:
                    layer2_shared = f"{others} other level(s) read the same stream"
            except ValueError:
                pass
        header_bytes: bytes | None = None
        if current:
            header_bytes = self._doc.header
        elif self._rom is not None and self._addressable:
            try:
                base = layer1_base(self._rom, level, where=self._addresses)
                header_bytes = bytes(self._rom[base : base + HEADER_SIZE])
            except ValueError:
                header_bytes = None
        if header_bytes and len(header_bytes) == HEADER_SIZE:
            header_text = self._header_summary(header_bytes)
        return LevelInfo(
            level=level,
            current=current,
            files=files,
            shared=shared,
            layer2=layer2_text,
            layer2_options=options,
            layer2_current=chosen,
            layer2_shared=layer2_shared,
            header=header_text,
        )

    def _header_summary(self, header: bytes) -> str:
        """The primary header in one line: the three fields the load cares
        about, with the dialog for the rest."""
        return ", ".join(
            f"{label} {FIELDS_BY_KEY[key].text(header)}"
            for key, label in (
                ("level_mode", "mode"),
                ("music", "music"),
                ("time_limit", "time"),
            )
        )

    def _entrance_section(self, level: int, world_mode: bool) -> Section | None:
        """The secondary header's box: editable over the open level, a
        reading of the tables anywhere else."""
        current = not world_mode and self._level == level and self._doc is not None
        rows = list(secondary_header.fields())
        note = ""
        if current and len(self._doc.secondary) == secondary_header.SIZE:
            record = secondary_header.SecondaryHeader(self._doc.secondary)
        else:
            data = self._secondary_header_bytes(level)
            if len(data) != secondary_header.SIZE:
                return None
            record = secondary_header.SecondaryHeader(data)
            rows = frozen_fields(rows)
            note = "Open the level to edit its entrance."
        return Section("entrance", "Entrance and camera", rows, record, note)

    def _load_path_edited(self, section: str, key: str, value: int) -> None:
        """A window row committed, or an action was pressed: route it to
        whoever owns that section's document."""
        if section == "world":
            self._load_path_world_edit(key, value)
        elif section == "level":
            self._load_path_level_edit(key, value)
        elif section == "entrance":
            self._load_path_entrance_edit(key, value)

    def _load_path_world_edit(self, key: str, value: int) -> None:
        level, cell, reading, world_mode = self._load_path_subject()
        if key == SHOW_ON_MAP:
            if cell is None:
                return
            if not world_mode:
                self.menu_actions.world_map.setChecked(True)
                self._enter_world()
                # Which the unsaved-level question may have refused.
                if self._mode is not EditorMode.WORLD:
                    return
            if self._world.ready:
                # Zoom first: center_on holds the middle of the viewport, and
                # the viewport the cell should be centered in is the zoomed one.
                self.view.set_zoom(SHOW_ON_MAP_ZOOM)
                self._world.show_cell(cell)
            return
        # The rows are frozen anywhere but over the map, so a value arriving
        # from elsewhere is a stale widget's and is dropped.
        if not (world_mode and self._world.ready) or cell is None:
            return
        tables = self._name_tables()
        record = CellWalk(
            self._world.document,
            cell,
            self._world_level_events(self._world.document),
            self._level_choices,
        )
        self._world.commit_table_field(
            record,
            lambda r: [*walk_fields(r), *name_fields(r, tables)],
            key,
            value,
        )
        self._refresh_load_path()

    def _load_path_level_edit(self, key: str, value: int) -> None:
        level, _cell, _reading, world_mode = self._load_path_subject()
        if level is None:
            return
        if key == OPEN_LEVEL:
            if world_mode:
                self.open_level_from_map(level)
            else:
                self._level_file_followed(level)
            return
        if key == EDIT_HEADER:
            if not world_mode and self._level == level:
                self.edit_header()
            return
        if key == LAYER2_ENTRY and 0 <= value < len(self._load_path_layer2):
            self._repoint_layer2(self._load_path_layer2[value])

    def _load_path_entrance_edit(self, key: str, value: int) -> None:
        if self._doc is None or len(self._doc.secondary) != secondary_header.SIZE:
            return
        record = secondary_header.SecondaryHeader(self._doc.secondary)
        found = next((one for one in secondary_header.fields() if one.key == key), None)
        if found is None:
            return
        edited = found.applied(record, value)
        if edited is record:
            return
        self._commit(self._doc.with_secondary(edited.data))

    def _level_file_followed(self, level: int) -> None:
        """A level number was clicked in the viewer: open that level.

        The same gate every other way of asking for a level goes through --
        the load replaces the document, so :meth:`_may_replace` answers first
        -- and refused over the world map for the reason :meth:`jump_to` is:
        a level load would repaint the canvas while the mode says otherwise.
        """
        if self._path is None or self._mode is EditorMode.WORLD:
            return
        if self._may_replace(level):
            self.load_level(level)
