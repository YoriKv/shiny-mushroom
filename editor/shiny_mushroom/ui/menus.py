"""The window's menu bar, and the actions it hands back.

Assembly with no behaviour in it: a row's label, its shortcut, and the method it
calls, and nothing else.

**It is part of the window's construction, not a service to it.** ``build``
takes the window and wires its own methods to its own menu bar, which is why it
reads the window's view options directly and why the type is imported only for
checking. What it hands back is :class:`Actions` -- the rows the window has to
keep in step afterwards, because an action carries a *keyboard shortcut* as well
as a menu row and a disabled action's shortcut is a dead key. Everything with no
state to sync is built, added and forgotten.

Adding a feature that needs a menu row adds it here and a field to
:class:`Actions` if anything has to grey it out later. Nothing else in the
window moves -- Help > Shortcuts reads this bar rather than a table of its own,
so a row with a key documents itself (see :mod:`shiny_mushroom.ui.help_dialogs`,
and give the row a ``guideLabel`` if the window renames it at runtime).
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum
from typing import TYPE_CHECKING

from PySide6.QtGui import QAction, QActionGroup, QKeySequence
from PySide6.QtWidgets import QDockWidget, QMenu, QToolBar

from shiny_mushroom import APP_NAME
from shiny_mushroom.ui.canvas import GridMode
from shiny_mushroom.ui.level_bar import EDITING_ROWS
from shiny_mushroom.ui.settings import load_enum_setting
from shiny_mushroom.ui.theme import THEME_KEY, Theme
from shiny_mushroom.ui.world_bar import EDIT_ROWS

if TYPE_CHECKING:
    from shiny_mushroom.ui.main_window import MainWindow

GRID_KEY = "view/grid"

# What each menu entry offers, as ``member -> (label, shortcut or None)``. Kept
# as data because the two menus below are the same widget-building loop over
# different enums, and the only thing that differs is this table.
_GRID_ENTRIES = {
    GridMode.OFF: ("&Off", None),
    GridMode.TILE: ("&Tile (8x8)", None),
    # The two states worth flipping between are off and the block lattice, so
    # the shortcut goes here rather than on a separate toggle that would have to
    # be kept in sync with the group.
    GridMode.BLOCK: ("&Block (16x16)", "Ctrl+G"),
}
_THEME_ENTRIES = {
    Theme.LIGHT: ("&Light", None),
    Theme.DARK: ("&Dark", None),
}


@dataclass(frozen=True, slots=True)
class Actions:
    """The menu rows the window has to keep in step, by what they act on.

    Only these. A row whose enabled state never changes -- New Project, Exit,
    About, the zoom steps -- is built and forgotten, because holding a
    reference to it would suggest there is something to do with it.
    """

    #: File. The projects on disk as rows, rebuilt as the submenu opens --
    #: a project made or deleted between launches is one this has to show.
    open_projects: QMenu

    #: The two exports -- a copy of the project's built cartridge, with and
    #: without a copier header. One question greys both: whether there is a
    #: project to build, since an export is that build's output and nothing
    #: else. Two rows rather than one and a checkbox, because which spelling
    #: is wanted is a property of where the file is going.
    export: QAction
    export_headered: QAction

    #: Play the whole cartridge in the editor's own emulator, from its title
    #: screen. Greyed out until there is a cartridge open, which is all this
    #: run needs: the build it owes is one it runs itself.
    test_rom: QAction

    #: The same cartridge, opened in the external emulator instead. Greyed out
    #: on the exports' question -- what it hands over is a project's build --
    #: and no other: which emulator is set, or whether one is at all, is
    #: answered when the row is used, so the setting stays findable from the
    #: row that needs it.
    test_rom_external: QAction

    save: QAction
    revert: QAction
    cartridge: QAction

    #: The cartridge size. The submenu only, and empty until it is opened: the
    #: sizes on offer are the *base's*, and the two do not agree -- ``vanilla``
    #: runs 512 KB to 4 MB, ``sa1`` 1 MB to 8 MB. So the rows are rebuilt from
    #: whichever project is open, exactly as ``open_projects`` is rebuilt from
    #: what is on disk, and ``sync_project_menu`` only decides whether the row
    #: can be reached at all.
    rom_sizes: QMenu

    #: The project's asm patches. Greyed out with no buildable project, the
    #: same question as the ROM size -- but not on expandability: patching
    #: needs a project, not room.
    patches: QAction

    #: What the project's cartridge is assembled with beyond the stock game.
    #: Greyed out on the same question as the patches, and for the same
    #: reason: a feature is a property of a project's build.
    features: QAction

    #: The project's level data as three tabs -- the level numbers, the
    #: labels their entries name, and the ``.mwl`` files behind them. Greyed
    #: out with no project: the rows are a reading of a project's tree,
    #: overlay included.
    level_data: QAction

    #: The files the project holds of its own, for editing the disassembly by
    #: hand. Greyed out with no project, for :attr:`level_data`' reason: the
    #: rows are a reading of one project's overlay.
    source_files: QAction

    #: The project's graphics files: a sheet per file, PNG in and out, the
    #: tile-editor handover. Greyed out with no project, for
    #: :attr:`level_data`' reason -- the rows are one project's set.
    graphics_files: QAction

    #: Where everything the editor writes sits in the cartridge, and what room
    #: is left around it. Greyed out with no project, for :attr:`level_data`'
    #: reason again -- and no more than that, because a project with no build
    #: still has banks, level data and padding to show.
    memory_map: QAction

    #: The music, the sound effects, what the SPC700 holds and how the game
    #: asks for any of it. Greyed out with no project, for :attr:`memory_map`'
    #: reason -- though unlike the map this one needs a build to say anything,
    #: and says so when there is none.
    audio: QAction

    #: The game's text -- the message boxes and the level-name parts -- in a
    #: window of its own. Greyed out with no project: what it edits is the
    #: project's overlay, and a cartridge opened by hand has none.
    strings: QAction

    #: The cartridge's secondary entrances, in a window of its own. Greyed
    #: out with no project, for :attr:`strings`' reason: the tables are the
    #: project's overlay to write.
    secondary_entrances: QAction

    #: Assemble the project again and open what came out. Greyed out with no
    #: buildable project, since it is that project's build.
    rebuild: QAction

    #: Edit. All of these carry a key as well as a row, and
    #: ``MainWindow.sync_edit_actions`` is the one place their answer is
    #: worked out -- see it for why that cannot wait until the menu opens.
    undo: QAction
    redo: QAction
    cut: QAction
    copy: QAction
    paste: QAction
    duplicate: QAction
    delete: QAction
    forward: QAction
    back: QAction

    #: View. The toggles are checkable; the two groups are exclusive, so
    #: checking one member unchecks the rest with no bookkeeping in the window.
    layer1: QAction
    layer2: QAction
    layer3: QAction
    sprites: QAction
    sprite_outlines: QAction
    objects: QAction
    screens: QAction
    grid: QActionGroup
    theme: QActionGroup

    #: Go, greyed out at the ends of the trail.
    go_back: QAction
    go_forward: QAction

    #: The three editing environments, each a checkable row that is checked
    #: while its picture holds the canvas -- and, on the mode bar, a button.
    #: The level's row is the way back from the other two by name; it is
    #: never unchecked by hand, so triggering it is only ever a return.
    level_mode: QAction

    #: The world map mode, checkable: checked while the map is on the canvas.
    #: Greyed out until a cartridge is open.
    world_map: QAction

    #: The Tilemap editor, checkable the same way. Greyed out
    #: until a project and a level are open: the tables are the project's,
    #: and the sheet is drawn with a level's graphics.
    map16_mode: QAction

    #: Ctrl+Tab and Ctrl+Shift+Tab: the next and previous environment of the
    #: three, skipping any that cannot be entered. Greyed out while the
    #: level is the only one there is.
    next_mode: QAction
    previous_mode: QAction

    #: The events view, checkable: the world map with every event replayed.
    #: Greyed out except in world map mode.
    world_events: QAction

    #: The world map's own three layers -- the two tile layers and the
    #: sprite markers -- checkable and on by default. Greyed out except in
    #: world map mode, like the events view: the level's layer toggles are
    #: preferences about a different picture.
    world_layer1: QAction
    world_layer2: QAction
    world_sprites: QAction

    #: The world map's two overlay readouts, under the same rules: the tile
    #: marks (walk arrows, path steps, warp boxes), and the framing marks
    #: (the framed map's box, a submap's border mask).
    world_tile_marks: QAction
    world_frame: QAction

    #: The map's View toggles as one group, and the level's as the other.
    #: The two sets take turns -- they carry the same Shift+digits, so
    #: exactly one may ever be armed -- and every place that arms or greys a
    #: set iterates the group rather than naming its members again. A
    #: seventh toggle joins by being built into the group here, which is what
    #: stops it being armed in one of those places and forgotten in the rest.
    #: The screen grid is in neither: it is one row for both pictures.
    world_views: tuple[QAction, ...]
    level_views: tuple[QAction, ...]

    #: Everything in the menus that belongs to one environment, that one's
    #: View toggles and Editing submenu included: the set is made visible with
    #: the mode and taken out of the menus with it, which is a different
    #: question from the greying above and asked in the same place. A row
    #: joins by being built into the set where the two are gathered, at the
    #: end of :func:`build`.
    world_rows: tuple[QAction, ...]
    level_rows: tuple[QAction, ...]

    #: The world map's table editors -- the game's overworld tables, rows and
    #: columns in a modeless dialog. Greyed out except in world map mode,
    #: since they edit the world document.
    world_warps: QAction
    world_exits: QAction

    #: The world map's cross-checks -- what the game itself never verifies,
    #: reported as findings. World map mode only, like the tables.
    world_checks: QAction

    #: The per-level tables -- walks and events over every numbered level --
    #: as rows. World map mode only, like the warp table.
    world_levels: QAction

    #: The focused event's stamp placements as rows -- add, delete,
    #: reorder, retile. World map mode only, like the warp table.
    world_event_rows: QAction

    #: The silent-tiles block as rows -- the offscreen tiles flagged
    #: events place with no animation. World map mode only, like the rest.
    world_silent: QAction

    #: The destroyed-tiles block as rows: which event crushes which cell,
    #: and what a crushed tile becomes. World map mode only, like the rest.
    world_destroy: QAction
    world_ruins: QAction

    #: The pass-1 substitution as rows: where each event aims its Layer 1
    #: tile swap, and the before/after pairs every swap draws from. World
    #: map mode only, like the rest.
    world_subs: QAction
    world_swaps: QAction

    #: Those rows as one group, armed and greyed with the mode together,
    #: for :attr:`world_views`' reason.
    world_dialogs: tuple[QAction, ...]

    #: Which part of the map a gesture edits, one row per Editing box row and
    #: exclusive like the box. The group is enabled per mode as one thing:
    #: its rows carry the bare digits, which have to be dead everywhere else.
    world_editing: QActionGroup

    #: Which part of the *level* a gesture edits -- the level bar's Editing
    #: box as menu rows, exclusive like it. Enabled per mode as one thing,
    #: for the world group's reason and against it: both carry the bare
    #: digits, so only one of the two may ever be armed.
    level_editing: QActionGroup

    #: Which grain a gesture edits in the Map16 environment -- the Map16
    #: bar's Editing box as menu rows, on the same bare digits as the other
    #: two groups and armed in the third mode alone.
    map16_editing: QActionGroup

    #: The Map16 environment's flips: H and V mirror the selection as one
    #: picture -- the words change places and each one's bit toggles --
    #: and Shift+H, Shift+V flip each word in place. Armed with the
    #: environment, like its Editing rows.
    map16_flips: tuple[QAction, ...]

    #: The world map's, on the same letters over its Layer 2 tiles. The two
    #: sets are armed by mode, never together, as the Editing digits are.
    world_flips: tuple[QAction, ...]

    #: The Map16 environment's own rows, put in the menus with the mode and
    #: taken out with it, as the level's and the map's are.
    map16_rows: tuple[QAction, ...]

    #: Window: the row for the offer dock, whose text is the page it shows --
    #: Create over the level, Tiles over the map, VRAM over a sheet. Kept
    #: for its text alone; the other rows are the user's in every environment
    #: and are built and forgotten.
    offer_panel: QAction

    #: Level. The header, graphics and exits dialogs act on the level and are
    #: greyed out when there is none; Test follows the mode instead, testing
    #: whichever document is being edited, so it is in neither environment's
    #: set.
    header: QAction
    graphics_row: QAction
    exits: QAction
    test: QAction

    #: The external test run, which asks a different question from the one
    #: above it: Test Level needs a document, and this needs a *project to
    #: build*, since what it opens is the cartridge asar produced. So it is
    #: armed with the rest of the project's rows
    #: (``MainWindow._sync_rom_size_menu``) rather than with the level's.
    #:
    #: And on one more question than they ask: whether the emulator on file is
    #: a Mesen, since the warp is the whole of what this row does that
    #: :attr:`test_rom_external` does not, and only Mesen can be asked for it.
    #: That is greying a row for a reason the menu *can* give -- File > Test
    #: ROM Externally is right there, doing the part that still works.
    test_external: QAction

    #: The Level Load Path window: one level's chain from overworld tile to
    #: level data. Greyed out until a cartridge is open -- the chain is a
    #: reading of one.
    load_path: QAction


def build(window: MainWindow) -> Actions:
    """Fill ``window``'s menu bar, and hand back the rows it has to maintain."""
    bar = window.menuBar()

    # A project is the document this editor opens, so the File menu is the
    # project's: made, opened, saved, reverted and exported here. What stays
    # behind in Project is the settings of the one already open.
    file_menu = bar.addMenu("&File")
    action(file_menu, window, "&New Project...", None, window.new_project)
    open_projects = file_menu.addMenu("&Open Project")
    open_projects.aboutToShow.connect(window.fill_project_menu)
    file_menu.addSeparator()
    save = action(
        file_menu,
        window,
        "&Save Level",
        QKeySequence.StandardKey.Save,
        # The router, not `save_level`: Ctrl+S saves whichever document the
        # canvas is showing, and the window renames the row per mode.
        window.save_current,
    )
    revert = action(
        file_menu,
        window,
        "Re&vert Level",
        None,
        # The router, like Save above: Revert puts back whichever document has
        # the focus, and the window renames the row to say which.
        window.revert_current,
    )
    # Three rows whose label is rewritten as the mode changes -- Save Level,
    # Save World Map, Save Palettes -- and the shortcut guide reads labels. It
    # is given the name the *key* has, which is the one that does not move
    # (see :mod:`shiny_mushroom.ui.help_dialogs`).
    save.setProperty("guideLabel", "Save")
    revert.setProperty("guideLabel", "Revert")
    file_menu.addSeparator()
    export = action(file_menu, window, "&Export ROM...", None, window.export_rom)
    export.setEnabled(False)
    export_headered = action(
        file_menu,
        window,
        "Export &Headered ROM...",
        None,
        lambda: window.export_rom(with_header=True),
    )
    export_headered.setEnabled(False)
    # The third and fourth things done with a build, and filed with the two
    # that write it out: these two open it. The cartridge, from its title
    # screen -- here, or in whatever emulator is set -- which is what makes
    # them File rows rather than Level's, since they test no document in
    # particular. Here first: it is the one that needs no preference set.
    test_rom = action(file_menu, window, "&Test ROM", None, window.test_rom)
    test_rom.setEnabled(False)
    test_rom_external = action(
        file_menu, window, "Test ROM Externa&lly", None, window.test_rom_external
    )
    test_rom_external.setEnabled(False)
    file_menu.addSeparator()
    cartridge = action(
        file_menu, window, "Reference &Cartridge...", None, window.choose_cartridge
    )
    file_menu.addSeparator()
    # The application's own preferences, as opposed to the open project's,
    # which are Project's. Never greyed: what it sets belongs to the person and
    # is worth setting before there is anything open at all.
    action(file_menu, window, "Se&ttings...", None, window.edit_settings)
    file_menu.addSeparator()
    # Ctrl+Q spelled out rather than the platform's own Quit key, which is not
    # one thing: Windows binds nothing at all, and X11 answers a bare Exit media
    # key most keyboards do not have. So the row would advertise a different key
    # on each platform and none on one of them. Qt maps Ctrl to Command on
    # macOS, so this one spelling is Cmd+Q there and Ctrl+Q on the other two --
    # which is what every application on all three already quits with.
    action(file_menu, window, "E&xit", "Ctrl+Q", window.close)
    file_menu.aboutToShow.connect(window.sync_file_menu)

    project_menu = bar.addMenu("&Project")
    rebuild = action(project_menu, window, "&Rebuild", "Ctrl+B", window.rebuild_project)
    action(project_menu, window, "Open Projects &Folder", None, window.reveal_projects)
    project_menu.addSeparator()
    rom_sizes = project_menu.addMenu("&ROM Size")
    rom_sizes.aboutToShow.connect(window.fill_rom_size_menu)
    features = action(project_menu, window, "&Features...", None, window.edit_features)
    level_data = action(
        project_menu, window, "&Level Data...", None, window.view_level_data
    )
    secondary_entrances = action(
        project_menu,
        window,
        "Secondary &Entrances...",
        None,
        window.edit_secondary_entrances,
    )
    graphics_files = action(
        project_menu, window, "&Graphics Files...", None, window.edit_graphics_files
    )
    audio = action(project_menu, window, "&Audio...", None, window.view_audio)
    # A window rather than a panel: the text is a document of its own, saved
    # on its own, and the row opens it or brings it forward.
    strings = action(project_menu, window, "&Strings...", None, window.edit_strings)
    strings.setEnabled(False)
    source_files = action(
        project_menu, window, "&Source Files...", None, window.edit_source_files
    )
    patches = action(project_menu, window, "&Patches...", None, window.edit_patches)
    # Filed apart from the rows above it: those say what the project is built
    # from, and this one only reports where it all landed in the cartridge.
    project_menu.addSeparator()
    memory_map = action(
        project_menu, window, "&Memory Map...", None, window.view_memory_map
    )
    project_menu.aboutToShow.connect(window.sync_project_menu)

    edit_menu = bar.addMenu("&Edit")
    undo = action(
        edit_menu, window, "&Undo", QKeySequence.StandardKey.Undo, window.undo
    )
    redo = action(
        edit_menu, window, "&Redo", QKeySequence.StandardKey.Redo, window.redo
    )
    # Ctrl+Shift+Z as well as the platform's own redo key, which on Windows
    # is Ctrl+Y and nowhere near the undo it pairs with. Both, rather than
    # one: whichever a hand reaches for is the one that should work.
    redo.setShortcuts(
        [QKeySequence(QKeySequence.StandardKey.Redo), QKeySequence("Ctrl+Shift+Z")]
    )
    edit_menu.addSeparator()
    cut = action(
        edit_menu, window, "Cu&t", QKeySequence.StandardKey.Cut, window.cut_selection
    )
    copy = action(
        edit_menu, window, "&Copy", QKeySequence.StandardKey.Copy, window.copy_selection
    )
    paste = action(
        edit_menu, window, "&Paste", QKeySequence.StandardKey.Paste, window.paste
    )
    # Ctrl+D, which has no standard key because Qt has no standard idea of
    # what it means -- but it is what every editor with a duplicate binds,
    # and nothing here wants it.
    duplicate = action(
        edit_menu, window, "D&uplicate", "Ctrl+D", window.duplicate_selection
    )
    edit_menu.addSeparator()
    delete = action(
        edit_menu,
        window,
        "&Delete",
        QKeySequence.StandardKey.Delete,
        window.delete_selection,
    )
    edit_menu.addSeparator()
    # The keys these two answer to are written into the rows rather than bound
    # to them. `-` and `=` are bare keys, so a shortcut on the window would fire
    # while the level number is being typed into the toolbar's spin box -- the
    # picture takes them off the view instead, in `KeyRouting._edit_keys`, and
    # a row that named no key at all would leave the only two bare commands in
    # the editor undiscoverable. A tab puts what follows it in the menu's
    # shortcut column without binding anything.
    forward = action(
        edit_menu,
        window,
        "Bring &Forward\t=",
        None,
        lambda: window.reorder_selection(+1),
    )
    back = action(
        edit_menu, window, "Send &Back\t-", None, lambda: window.reorder_selection(-1)
    )
    edit_menu.addSeparator()
    # The world map's editing modes -- the world bar's Editing box as menu
    # rows, and the digits that reach them without it. The names come from the
    # box's own table so the two cannot drift apart; the digit is the row's
    # accelerator, which is why none carries a mnemonic. Dead outside world map
    # mode, which is what leaves the bare digits to everything else.
    editing_menu = edit_menu.addMenu("Overworld &Editing")
    world_editing = QActionGroup(window)
    world_editing.setExclusive(True)
    world_editing.triggered.connect(
        lambda chosen: window.set_world_editing(chosen.data())
    )
    for index, (name, _tabs) in enumerate(EDIT_ROWS):
        row = QAction(name, window)
        row.setCheckable(True)
        row.setChecked(index == 0)
        row.setData(index)
        row.setShortcut(QKeySequence(str(index + 1)))
        world_editing.addAction(row)
        editing_menu.addAction(row)
    world_editing.setEnabled(False)
    editing_menu.addSeparator()
    world_flips = flip_rows(editing_menu, window, window.flip_world)
    # The level's own editing modes, beside the map's and from the level
    # bar's table for the same no-drift reason. Their rows carry the bare
    # digits too, counting the same way the map's do -- 1 is the layer a
    # gesture lands on, 2 the one behind it -- and the two groups are armed
    # by mode, never together, so one digit means one thing at a time.
    level_editing_menu = edit_menu.addMenu("&Level Editing")
    level_editing = QActionGroup(window)
    level_editing.setExclusive(True)
    level_editing.triggered.connect(
        lambda chosen: window.set_level_editing(chosen.data())
    )
    for index, name in enumerate(EDITING_ROWS):
        row = QAction(name.replace("&", "&&"), window)
        row.setCheckable(True)
        row.setChecked(index == 0)
        row.setData(index)
        row.setShortcut(QKeySequence(str(index + 1)))
        level_editing.addAction(row)
        level_editing_menu.addAction(row)
    level_editing.setEnabled(False)
    # And the Tilemap editor's two grains, the third set on the same
    # digits: whole tiles, or their 8x8 cells. Named for what they are on
    # every sheet -- a stamp sheet's whole unit is a block. M, not T, which
    # Cut has.
    map16_editing_menu = edit_menu.addMenu("Tile&map Editing")
    map16_editing = QActionGroup(window)
    map16_editing.setExclusive(True)
    map16_editing.triggered.connect(
        lambda chosen: window.set_map16_editing(chosen.data())
    )
    for index, name in enumerate(("Tiles", "Cells")):
        row = QAction(name, window)
        row.setCheckable(True)
        row.setChecked(index == 0)
        row.setData(index)
        row.setShortcut(QKeySequence(str(index + 1)))
        map16_editing.addAction(row)
        map16_editing_menu.addAction(row)
    map16_editing.setEnabled(False)
    map16_editing_menu.addSeparator()
    map16_flips = flip_rows(map16_editing_menu, window, window.flip_map16)
    # The three that act on the level are bound on the *window*, so they work
    # wherever the keyboard is, and two of them go further -- see
    # `MainWindow._wants_the_level_key` for which and why. The menu is not what
    # keeps them in step: a disabled action's shortcut does not fire, so their
    # enabled state is refreshed as the level and the selection change rather
    # than when the menu is opened. Opening it re-asks anyway, which costs
    # nothing and cannot be the only time the question is put.
    edit_menu.aboutToShow.connect(window.sync_edit_actions)

    view_menu = bar.addMenu("&View")
    zoom_in = action(view_menu, window, "Zoom &In", None, window.view.zoom_in)
    # Two bindings: the standard one is Ctrl++, which on most layouts means
    # holding Shift as well. Ctrl+= is the same physical key without it, and
    # is what every editor that gets this right also accepts.
    zoom_in.setShortcuts([QKeySequence.StandardKey.ZoomIn, QKeySequence("Ctrl+=")])
    action(
        view_menu,
        window,
        "Zoom &Out",
        QKeySequence.StandardKey.ZoomOut,
        window.view.zoom_out,
    )
    action(view_menu, window, "&Reset Zoom", "Ctrl+0", window.zoom_reset)

    view_menu.addSeparator()
    # A row of one thing, and each says only the four decisions that are its
    # own: the row's label, the state it starts in, its shortcut, and the setter
    # it drives. Not shorter than as many blocks of assembly would be -- but the
    # assembly is the half that can be got wrong quietly, by wiring one toggle
    # to another's setter or checking it against another's preference, and it is
    # written once.
    #
    # **Shift and a digit, counting each environment's row from 1.** A toggle
    # answers "is this in the picture", and the number is where the row sits:
    # over the level 1-3 the layers, 4 the sprites, 5 and 6 the two overlay
    # readouts, 7 the screen grid; over the map, which has no third layer,
    # 1-2 the layers, 3 the sprites, 4 the tile marks, 5 the frame, 6 the same
    # screen grid. Each row is the digit its bar shows it at -- see
    # ``view_bar.LEVEL_BUTTONS`` and ``WORLD_BUTTONS`` -- so no digit is
    # skipped around a row the other environment does not have; the events
    # view, which is only the map's, carries no key at all. The *editing*
    # modes carry bare digits of their own, and past the layers those are the
    # map's own order, not this one. Only one environment's toggles are armed
    # at a time (see ``MainWindow._show_world_chrome``, which also moves the
    # shared screen grid's key between the two rows' counts).
    options = window.options
    layer1 = toggle(
        view_menu, window, "Show Layer &1", options.layer1, "Shift+1", window.set_layer1
    )
    layer2 = toggle(
        view_menu, window, "Show Layer &2", options.layer2, "Shift+2", window.set_layer2
    )
    layer3 = toggle(
        view_menu, window, "Show Layer &3", options.layer3, "Shift+3", window.set_layer3
    )
    sprites = toggle(
        view_menu,
        window,
        "Show &Sprites",
        options.sprites,
        "Shift+4",
        window.set_sprites,
    )
    objects = toggle(
        view_menu,
        window,
        "Show Object &Outlines",
        options.objects,
        "Shift+5",
        window.set_objects,
    )
    sprite_outlines = toggle(
        view_menu,
        window,
        "Show Sprite Out&lines",
        options.sprite_outlines,
        "Shift+6",
        window.set_sprite_outlines,
    )
    screens = toggle(
        view_menu,
        window,
        "Show Sc&reens",
        options.screens,
        "Shift+7",
        window.set_screens,
    )

    # The map's own toggles, the same rows under the same keys for the other
    # picture. Each starts dead -- the keys belong to the level's row until
    # the mode is entered -- and each starts in the stance
    # :class:`OverworldMode` starts in, layer visibility not being the
    # cartridge's to decide.
    world_layer1 = toggle(
        view_menu,
        window,
        "Overworld Layer &1",
        True,
        "Shift+1",
        window.set_world_layer1,
    )
    world_layer2 = toggle(
        view_menu,
        window,
        "Overworld La&yer 2",
        True,
        "Shift+2",
        window.set_world_layer2,
    )
    # No key: the events view is the one map toggle with a handle of its own
    # already -- the world bar's Event box -- and a key on it would make the
    # digits count past a row the other environment does not have.
    world_events = toggle(
        view_menu,
        window,
        "Overworld &Events",
        False,
        "",
        window.set_world_events,
    )
    world_sprites = toggle(
        view_menu,
        window,
        "Overworld Sprite&s",
        True,
        "Shift+3",
        window.set_world_sprites,
    )
    # Down at the start, like the events view: the tile marks cover the map
    # they describe, so they are asked for when a path is the question.
    world_tile_marks = toggle(
        view_menu,
        window,
        "Overworld Tile &Marks",
        False,
        "Shift+4",
        window.set_world_tile_marks,
    )
    world_frame = toggle(
        view_menu, window, "Overworld &Frame", True, "Shift+5", window.set_world_frame
    )
    world_views = (
        world_layer1,
        world_layer2,
        world_events,
        world_sprites,
        world_tile_marks,
        world_frame,
    )
    level_views = (layer1, layer2, layer3, sprites, objects, sprite_outlines)
    for row in world_views:
        row.setEnabled(False)

    # Grid and theme are both "pick exactly one", which is what makes an
    # exclusive QActionGroup the right shape: checking one unchecks the rest
    # with no bookkeeping in the window.
    grid_menu = view_menu.addMenu("&Grid")
    grid = exclusive(
        grid_menu,
        window,
        _GRID_ENTRIES,
        load_enum_setting(GRID_KEY, GridMode.OFF),
        window.set_grid,
    )
    # One bare key steps the whole ladder, in the order the rows are in: off,
    # tiles, blocks, off again. It is the row that carries the key rather than
    # a binding on the window, so the menu says the grid can be cycled and
    # what cycles it.
    grid_menu.addSeparator()
    action(grid_menu, window, "&Cycle", "G", lambda: step(grid))
    theme = exclusive(
        view_menu.addMenu("&Theme"),
        window,
        _THEME_ENTRIES,
        load_enum_setting(THEME_KEY, Theme.LIGHT),
        window.set_theme,
    )

    go_menu = bar.addMenu("&Go")
    # Alt and an arrow, which is what a browser binds these to and what nothing
    # on the canvas wants: the bare arrows nudge a selection.
    go_back = action(go_menu, window, "&Back", QKeySequence("Alt+Left"), window.go_back)
    go_forward = action(
        go_menu, window, "&Forward", QKeySequence("Alt+Right"), window.go_forward
    )
    go_menu.addSeparator()
    # The three environments, one checkable row each, checked for the one on
    # the canvas, on Ctrl+1, Ctrl+2, Ctrl+3 in the order they sit -- the keys
    # a tabbed application gives its tabs, which is what these are, and the
    # only keys they carry. Ctrl+Tab walks the three as well.
    level_mode = QAction("&Level", window)
    level_mode.setToolTip("Edit the level")
    level_mode.setShortcut(QKeySequence("Ctrl+1"))
    level_mode.setCheckable(True)
    level_mode.setChecked(True)
    level_mode.setEnabled(False)
    level_mode.triggered.connect(window.toggle_level)
    go_menu.addAction(level_mode)
    # Its digit and nothing else: the same key enters and leaves, which is
    # what makes the mode cheap to peek into.
    world_map = QAction("&World Map", window)
    world_map.setToolTip("Edit the world map")
    world_map.setShortcut(QKeySequence("Ctrl+2"))
    world_map.setCheckable(True)
    world_map.setEnabled(False)
    world_map.triggered.connect(window.toggle_world_map)
    go_menu.addAction(world_map)
    # The Map16 tables' own environment, the same shape: one checkable row
    # in and out, on the third digit.
    map16_mode = QAction("&Tilemap Editor", window)
    map16_mode.setToolTip("Edit the Map16 tiles and the world map's stamp sheets")
    map16_mode.setShortcut(QKeySequence("Ctrl+3"))
    map16_mode.setCheckable(True)
    map16_mode.setEnabled(False)
    map16_mode.triggered.connect(window.toggle_map16)
    go_menu.addAction(map16_mode)
    go_menu.addSeparator()
    # And the three as a ring, on the keys a tabbed window walks its tabs
    # with: the environments are the tabs this window does not draw.
    next_mode = action(
        go_menu, window, "&Next Editor", "Ctrl+Tab", lambda: window.cycle_mode(+1)
    )
    next_mode.setEnabled(False)
    previous_mode = action(
        go_menu,
        window,
        "P&revious Editor",
        "Ctrl+Shift+Tab",
        lambda: window.cycle_mode(-1),
    )
    previous_mode.setEnabled(False)
    go_menu.aboutToShow.connect(window.sync_go_menu)

    find_menu = bar.addMenu("Fi&nd")
    action(find_menu, window, "&Find Object or Sprite...", "Ctrl+F", window.focus_find)
    # F3 and Shift+F3, which is what every editor binds "again" and "back" to --
    # so the search can be stepped with the keyboard while the hands are nowhere
    # near the bar.
    action(find_menu, window, "Find &Next", "F3", window.find_bar.find_next)
    action(
        find_menu, window, "Find &Previous", "Shift+F3", window.find_bar.find_previous
    )

    level_menu = bar.addMenu("&Level")
    # First row of the menu: the chain that decides which level the rest of
    # these edit, read from the overworld tile down.
    load_path = action(
        level_menu, window, "Level Load &Path...", None, window.view_load_path
    )
    load_path.setEnabled(False)
    header = action(
        level_menu, window, "Level &Header...", "Ctrl+L", window.edit_header
    )
    # Nothing to edit the header of until a level is loaded; a byte map has no
    # header, and neither does an empty window.
    header.setEnabled(False)
    # The other half of "everything about this level as a whole": which file
    # each of its eight graphics slots loads. A row of its own rather than a
    # page of the header dialog -- it is not the game's level record, and the
    # cartridge only has room for it under a feature.
    graphics_row = action(
        level_menu,
        window,
        "Level &Graphics...",
        "Ctrl+Shift+L",
        window.edit_level_graphics,
    )
    graphics_row.setEnabled(False)
    # Where the level leads, beside what it is made of: the screen exits as a
    # table, and the same records the canvas's number boxes select.
    exits = action(level_menu, window, "Level E&xits...", None, window.view_level_exits)
    exits.setEnabled(False)
    # The world map's table editors, in the same menu the header dialog
    # lives in: both are "the record behind the picture, as rows". Armed
    # only in world map mode, where the document they edit is up.
    world_warps = action(
        level_menu,
        window,
        "Overworld &Warp Triggers...",
        None,
        window.world_tables.warps.open,
    )
    world_exits = action(
        level_menu,
        window,
        "Overworld Path E&xits...",
        None,
        window.world_tables.exits.open,
    )
    world_levels = action(
        level_menu,
        window,
        "Overworld &Level Table...",
        None,
        window.world_tables.levels.open,
    )
    world_event_rows = action(
        level_menu,
        window,
        "Overworld &Event Rows...",
        None,
        window.world_tables.events.open,
    )
    world_silent = action(
        level_menu,
        window,
        "Overworld &Silent Tiles...",
        None,
        window.world_tables.silent.open,
    )
    world_destroy = action(
        level_menu,
        window,
        "Overworld &Destroyed Tiles...",
        None,
        window.world_tables.destroy.open,
    )
    world_ruins = action(
        level_menu,
        window,
        "Overworld &Ruin Tiles...",
        None,
        window.world_tables.ruins.open,
    )
    world_subs = action(
        level_menu,
        window,
        "Overworld Tile S&ubstitutions...",
        None,
        window.world_tables.subs.open,
    )
    world_swaps = action(
        level_menu,
        window,
        "Overworld Substitution &Pairs...",
        None,
        window.world_tables.swaps.open,
    )
    world_checks = action(
        level_menu,
        window,
        "Check World &Map...",
        None,
        window.world_tables.check,
    )
    world_dialogs = (
        world_warps,
        world_exits,
        world_levels,
        world_event_rows,
        world_silent,
        world_destroy,
        world_ruins,
        world_subs,
        world_swaps,
        world_checks,
    )
    for row in world_dialogs:
        row.setEnabled(False)
    level_menu.addSeparator()
    test = action(level_menu, window, "&Test Level", "Ctrl+R", window.test_level)
    test.setEnabled(False)
    # Renamed per mode too, and pinned for the guide alongside Save and Revert.
    test.setProperty("guideLabel", "Test")
    # Never greyed: what drives the pad is a preference of the person's, so it
    # is answerable with no project open and with none of the rows above it
    # armed.
    action(level_menu, window, "Edit Test &Controls...", None, window.edit_controls)
    # The other test run: the project's cartridge as it was built, warped to
    # whichever document is being edited. Greyed out unless the emulator on
    # file is a Mesen, because the warp *is* the row -- opening the cart at its
    # title screen is File > Test ROM Externally, and two rows that did the
    # same thing under different names would be one row too many.
    test_external = action(
        level_menu,
        window,
        "Test Level &Externally",
        "Ctrl+Shift+R",
        window.test_level_external,
    )
    test_external.setEnabled(False)
    # Renamed per mode like Test above it, so the guide is told the name the
    # key has rather than whichever one the menu is wearing.
    test_external.setProperty("guideLabel", "Test Externally")

    # The panels themselves, gathered where every application puts them rather
    # than among View's questions about what is *in* the picture. Each brings
    # its own checkable action, already wired to the panel's visibility -- one
    # less pair of states to keep in step -- so all this does is label it and
    # decide the order. The label is the panel's own title, with a mnemonic
    # added: the same action is the panel's row in the dock context menu, and
    # two names for one panel is one name too many.
    window_menu = bar.addMenu("&Window")
    # One row for what every environment places from: the dock turns to
    # the environment's page and takes its name, and the row -- the dock's
    # own toggle action -- follows the name on its own.
    offer_panel = panel(window_menu, window.offers, "Create")
    panel(window_menu, window.properties, "&Properties")
    panel(window_menu, window.palette_dock, "Pa&lettes")
    # A toolbar rather than a dock, and the one bar whose visibility is the
    # user's rather than the mode's -- which is exactly what earns it a row
    # here. World map mode greys it instead of hiding it (see
    # shiny_mushroom.ui.toolbars).
    panel(window_menu, window.find_bar, "&Find")

    # Which environment each row belongs to, so the two sets can be put up
    # and taken down as one -- :meth:`MainWindow._show_world_chrome` swaps
    # them. A row that means nothing where the canvas is *leaves the menu*
    # rather than sitting in it greyed: both View rows and both Editing
    # submenus carry the same keys, and a menu is a list of what can be done
    # here. Greying still says the rest -- whether there is a level to act on,
    # whether a sheet is over the map -- and the two are independent, Qt
    # keeping a hidden row disabled whatever its enabled state says.
    #
    # Test is in neither: same row, same key, testing whichever document is
    # being edited. Nor is the screen grid, or World Map itself, which is the
    # door between the two.
    world_rows = (*world_views, *world_dialogs, editing_menu.menuAction())
    level_rows = (
        *level_views,
        level_editing_menu.menuAction(),
        header,
        graphics_row,
    )
    map16_rows = (map16_editing_menu.menuAction(),)
    # The window opens over a level, so the other two environments' rows
    # start out of the menus.
    for row in (*world_rows, *map16_rows):
        row.setVisible(False)

    # Built last, so the guide -- which reads the finished menu bar -- sees
    # every other menu (see :mod:`shiny_mushroom.ui.help_dialogs`).
    help_menu = bar.addMenu("&Help")
    shortcuts = action(
        help_menu,
        window,
        "&Shortcuts...",
        QKeySequence.StandardKey.HelpContents,
        window.show_shortcuts,
    )
    shortcuts.setToolTip("Every keyboard shortcut in one page")
    help_menu.addSeparator()
    action(help_menu, window, f"&About {APP_NAME}", None, window.show_about)

    return Actions(
        open_projects=open_projects,
        export=export,
        export_headered=export_headered,
        save=save,
        revert=revert,
        cartridge=cartridge,
        rom_sizes=rom_sizes,
        patches=patches,
        features=features,
        level_data=level_data,
        source_files=source_files,
        graphics_files=graphics_files,
        memory_map=memory_map,
        audio=audio,
        level_mode=level_mode,
        map16_mode=map16_mode,
        next_mode=next_mode,
        previous_mode=previous_mode,
        secondary_entrances=secondary_entrances,
        strings=strings,
        rebuild=rebuild,
        undo=undo,
        redo=redo,
        cut=cut,
        copy=copy,
        paste=paste,
        duplicate=duplicate,
        delete=delete,
        forward=forward,
        back=back,
        layer1=layer1,
        layer2=layer2,
        layer3=layer3,
        sprites=sprites,
        sprite_outlines=sprite_outlines,
        objects=objects,
        screens=screens,
        grid=grid,
        theme=theme,
        go_back=go_back,
        go_forward=go_forward,
        world_map=world_map,
        world_events=world_events,
        world_layer1=world_layer1,
        world_layer2=world_layer2,
        world_sprites=world_sprites,
        world_tile_marks=world_tile_marks,
        world_frame=world_frame,
        world_views=world_views,
        level_views=level_views,
        world_rows=world_rows,
        level_rows=level_rows,
        world_dialogs=world_dialogs,
        world_warps=world_warps,
        world_exits=world_exits,
        world_levels=world_levels,
        world_event_rows=world_event_rows,
        world_silent=world_silent,
        world_destroy=world_destroy,
        world_ruins=world_ruins,
        world_subs=world_subs,
        world_swaps=world_swaps,
        world_editing=world_editing,
        level_editing=level_editing,
        map16_editing=map16_editing,
        map16_flips=map16_flips,
        world_flips=world_flips,
        map16_rows=map16_rows,
        world_checks=world_checks,
        offer_panel=offer_panel,
        header=header,
        graphics_row=graphics_row,
        exits=exits,
        load_path=load_path,
        test=test,
        test_external=test_external,
        test_rom=test_rom,
        test_rom_external=test_rom_external,
    )


def action(
    menu: QMenu,
    window: MainWindow,
    text: str,
    shortcut: QKeySequence.StandardKey | str | None,
    slot: Callable[[], None],
) -> QAction:
    """One ordinary menu row, parented to the window so its shortcut is the
    window's."""
    made = QAction(text, window)
    if shortcut is not None:
        made.setShortcut(QKeySequence(shortcut))
    made.triggered.connect(slot)
    menu.addAction(made)
    return made


def flip_rows(
    menu: QMenu, window: MainWindow, flip: Callable[..., None]
) -> tuple[QAction, ...]:
    """The four flip rows of one tile editor, on the letters a tilemap editor
    binds them to, starting greyed: the mode arms them.

    Bare H and V flip the selected **block** -- the selection as one
    picture, the tiles changing places across the axis and each one's own
    bit toggling. With Shift, the **tiles**: each flipped where it stands.
    ``flip`` is the window's hook, taking ``x``, ``y`` and ``mirror``.
    """
    rows = (
        action(menu, window, "&H Flip Block", "H", lambda: flip(x=True, mirror=True)),
        action(menu, window, "&V Flip Block", "V", lambda: flip(y=True, mirror=True)),
        action(menu, window, "H Flip &Tiles", "Shift+H", lambda: flip(x=True)),
        action(menu, window, "V Flip T&iles", "Shift+V", lambda: flip(y=True)),
    )
    for row in rows:
        row.setEnabled(False)
    return rows


def panel(menu: QMenu, dock: QDockWidget | QToolBar, text: str) -> QAction:
    """One Window row: the panel's own show/hide action, relabelled.

    Nothing is wired here. A dock or a toolbar already owns a checkable action
    that follows its visibility in both directions, so the row is that action
    -- which is why showing a panel by any other route ticks the row without
    anything having to notice.
    """
    made = dock.toggleViewAction()
    made.setText(text)
    menu.addAction(made)
    return made


def toggle(
    menu: QMenu,
    window: MainWindow,
    text: str,
    checked: bool,
    shortcut: str,
    slot: Callable[[bool], None],
) -> QAction:
    """One checkable View row, starting where the stored preference left it.

    ``checked`` is set **before** the signal is connected, so restoring a
    preference is not itself a toggle: the setters each write the preference
    back, and wiring first would have every launch save what it had just read.
    An empty ``shortcut`` is a row reached from the menus and its bar alone.
    """
    made = QAction(text, window)
    made.setCheckable(True)
    made.setChecked(checked)
    made.setShortcut(QKeySequence(shortcut))
    made.toggled.connect(slot)
    menu.addAction(made)
    return made


def step(group: QActionGroup) -> None:
    """Check the member after the checked one, wrapping, and put it into
    effect.

    ``trigger`` rather than ``setChecked``, because only a triggered action
    reaches the group's own handler: checking one by hand would move the tick
    without applying anything.
    """
    rows = group.actions()
    if not rows:
        return
    at = next((index for index, row in enumerate(rows) if row.isChecked()), -1)
    rows[(at + 1) % len(rows)].trigger()


def exclusive(
    menu: QMenu,
    window: MainWindow,
    entries: dict[Enum, tuple[str, str | None]],
    current: Enum,
    apply: Callable[[Enum], None],
) -> QActionGroup:
    """Fill ``menu`` with one checkable action per entry, exclusive, and put
    ``current`` into effect."""
    group = QActionGroup(window)
    group.setExclusive(True)
    group.triggered.connect(lambda chosen: apply(chosen.data()))
    for member, (label, shortcut) in entries.items():
        made = QAction(label, window)
        made.setCheckable(True)
        made.setChecked(member is current)
        made.setData(member)
        if shortcut is not None:
            made.setShortcut(QKeySequence(shortcut))
        group.addAction(made)
        menu.addAction(made)
    # A stored preference has to take effect as well as show as checked; nothing
    # else applies it, since no action was triggered to get here.
    apply(current)
    return group
