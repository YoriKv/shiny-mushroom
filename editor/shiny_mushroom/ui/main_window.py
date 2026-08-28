"""The main window: a canvas, the menu that drives it, and a status bar.

The window is built *around* the canvas - it is the central widget, not one
panel among several - so everything here is either something that changes what
the canvas shows (opening a file, picking a level), something that changes how
it shows it (zoom, grid, theme), or a readout of what it is showing.

It is also where the emulator gets connected to the picture, and the connection
is deliberately thin: the window asks :class:`~shiny_mushroom.ui.emulator.LevelLoader`
for a level number and is handed back a snapshot, which it renders and drops on
the canvas. Nothing here knows what a Map16 tile is or that there is a child
process involved.

**What this file holds is the decisions.** Everything with an answer of its own
has been moved out beside it, and each of those is a module rather than a
section:

- :mod:`shiny_mushroom.ui.menus` -- the menu bar, and the :class:`Actions`
  record of the rows the window has to keep in step afterwards.
- :mod:`shiny_mushroom.ui.view_options` -- the seven View toggles and where each
  is remembered between sessions.
- :mod:`shiny_mushroom.ui.picture` -- the level's pixels, and the two-buffer
  rule that lets an edit patch them instead of redrawing them.
- :mod:`shiny_mushroom.ui.previews` -- what the create panel offers, and the
  emulator round trips that fill it in.
- :mod:`shiny_mushroom.ui.gestures` -- the arithmetic behind a drag, a grip and
  an arrow key, with no window in it.

What is left here is the state a gesture reads and the order things happen in:
which level is open, what is selected, what a drag is carrying, and when each of
the above is asked. `docs/editor/architecture.md` is the shape of the whole
package.

All user-facing failure goes through :meth:`MainWindow._alert`, one modal
surface rather than a scattering of ``QMessageBox`` calls. That is worth the
indirection for the tests as much as for consistency: under Qt's offscreen
platform a modal ``exec()`` never returns, so the suite replaces this single
method and any dialog a test reaches becomes an assertion instead of a hang.
What either box actually *looks* like is :mod:`shiny_mushroom.ui.dialogs`; what
this window keeps is the method the suite reaches for.
"""

from __future__ import annotations

import logging
from collections.abc import Callable, Collection, Mapping, Sequence
from dataclasses import dataclass, replace
from functools import partial
from pathlib import Path

from PySide6.QtCore import (
    QByteArray,
    QEvent,
    QPoint,
    QRect,
    QSize,
    Qt,
    QTimer,
    Signal,
)
from PySide6.QtGui import QAction, QActionGroup, QImage
from PySide6.QtWidgets import (
    QApplication,
    QDockWidget,
    QFileDialog,
    QLabel,
    QMainWindow,
    QMenu,
    QProgressBar,
    QToolBar,
    QWidget,
)

from shiny_mushroom import (
    APP_NAME,
    cart_patches,
    graphics,
    level_graphics,
    level_palettes,
    palette_map,
    palettes,
    secondary_entrances,
    source_files,
)
from shiny_mushroom.addresses import DEFAULT_ADDRESSES, Addresses
from shiny_mushroom.build import (
    BuildError,
    asm_runs,
    needs_build,
    role_addresses,
    role_counts,
    rom_path,
    stale_disassembly,
    symbol_file,
    world_map_room,
)
from shiny_mushroom.catalog import Entry, key_of
from shiny_mushroom.edit import (
    History,
    Level,
    Record,
    bounding_blocks,
    group_origin,
)
from shiny_mushroom.fields import Choice as FieldChoice
from shiny_mushroom.fields import Field
from shiny_mushroom.header import (
    field_value,
    format_bytes,
)
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.index import LevelIndex, Occurrence, SearchKind, build_index
from shiny_mushroom.layer2_table import Layer2Entry, Layer2TableError, RepointMark
from shiny_mushroom.level import (
    BACKGROUND_COLUMNS,
    BACKGROUND_ROWS,
    BLOCK,
    Blocks,
    Geometry,
    Raster,
    background_index,
    background_thumbnails,
    background_tiles,
    block_runs,
    changed_blocks,
    geometry,
    layer2_block_at,
    level_shape,
)
from shiny_mushroom.level_exits import (
    EXIT_ADD,
    EXIT_FOLLOW,
    EXIT_REMOVE,
    EXIT_SCREEN,
    OCCUPIED,
    ScreenExit,
    exit_columns,
    free_screen,
    screen_fields,
    screen_heading,
    screen_note,
    with_exit,
    without_exit,
)
from shiny_mushroom.level_files import (
    ContainerNames,
)
from shiny_mushroom.level_palettes import LevelPalettes, PaletteDocument
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.load_path import (
    OPEN_LEVEL,
)
from shiny_mushroom.mwl import MwlError
from shiny_mushroom.navigation import Place, Trail
from shiny_mushroom.objects import (
    LevelObject,
    carried_footprints,
    parse_objects,
    screen_exits,
)
from shiny_mushroom.objects import stack_at as object_stack_at
from shiny_mushroom.objects import within as objects_within
from shiny_mushroom.overworld import (
    STOCK_SHAPE,
    MapShape,
    WorldMap,
)
from shiny_mushroom.palettes import Palette, PaletteError
from shiny_mushroom.project import (
    PROJECT_FILE,
    HandEditedRegion,
    Project,
    ProjectError,
    projects,
    projects_root,
    unused_name,
)
from shiny_mushroom.project_levels import Layer2Gap
from shiny_mushroom.project_overworld import (
    OVERWORLD_NAMES_REGION,
    OVERWORLD_PARTS,
    world_region_models,
)
from shiny_mushroom.rom_patches import (
    PlayerPosition,
    entrance_position,
    gfx_list_rows,
    headered,
    headerless,
    layer2_background_base,
    level_graphics_row,
    levels_sharing_layer2,
    secondary_header_bytes,
    vertical_level,
    vram_with_graphics,
)
from shiny_mushroom.setup import (
    SetupError,
    Stage,
    assets_ready,
    readiness,
    start_project,
)
from shiny_mushroom.sprite_art import PlayerArt, SpriteTile
from shiny_mushroom.sprites import Sprite, SpriteKind, at
from shiny_mushroom.sprites import stack_at as sprite_stack_at
from shiny_mushroom.sprites import within as sprites_within
from shiny_mushroom.tile_clipboard import (
    FloatController,
    FloatingSelection,
    FloatStep,
    SelectionMark,
    TileClipboard,
    centred,
    clamped,
    landing,
    relative,
)
from shiny_mushroom.ui import graphics_dialog, menus
from shiny_mushroom.ui.canvas import (
    DEFAULT_ZOOM,
    RESET_ZOOM,
    Canvas,
    GridMode,
    Overlay,
    as_percent,
    from_percent,
)
from shiny_mushroom.ui.canvas_view import CanvasView
from shiny_mushroom.ui.context_menu import SEPARATOR, Row, build
from shiny_mushroom.ui.create import CreateDock
from shiny_mushroom.ui.dialogs import Choice, ask, ask_to_save, warn
from shiny_mushroom.ui.emulator import LevelLoader
from shiny_mushroom.ui.features_dialog import FeaturesDialog
from shiny_mushroom.ui.find_bar import FindBar
from shiny_mushroom.ui.gestures import (
    GRIP_CURSORS,
    Grip,
    block_center,
    box_between,
    grip_within,
    landing_beside,
    next_in_stack,
    pulled_to,
)
from shiny_mushroom.ui.graphics_dialog import GraphicsDialog
from shiny_mushroom.ui.header_dialog import HeaderDialog, Layer2Options
from shiny_mushroom.ui.help_dialogs import AboutDialog, ShortcutGuide, shortcut_sections
from shiny_mushroom.ui.level_bar import LevelBar
from shiny_mushroom.ui.level_data_dialog import LevelDataDialog
from shiny_mushroom.ui.level_exits_dialog import LevelExits
from shiny_mushroom.ui.level_graphics_dialog import LevelGraphicsDialog
from shiny_mushroom.ui.level_palette import NO_LAYER2, BackgroundTile
from shiny_mushroom.ui.load_path_dialog import LoadPathDialog
from shiny_mushroom.ui.loading import CAPTURING, LevelLoadingDialog
from shiny_mushroom.ui.map16_dialog import Map16Dialog
from shiny_mushroom.ui.memory_map_dialog import MemoryMapDialog
from shiny_mushroom.ui.overlays import (
    DASH_LENGTH,
    SELECTION_DASH,
    SELECTION_LINE,
    Floating,
    Placing,
    Stretching,
    moving_overlays,
    outlined,
    resting_overlays,
    screen_overlays,
)
from shiny_mushroom.ui.overworld_mode import OverworldMode, Room
from shiny_mushroom.ui.palette_dock import PaletteDock
from shiny_mushroom.ui.patches_dialog import PatchesDialog
from shiny_mushroom.ui.picture import Picture
from shiny_mushroom.ui.play import PlayController
from shiny_mushroom.ui.play_window import PlayWindow
from shiny_mushroom.ui.previews import Held, Previews
from shiny_mushroom.ui.project_dialog import (
    CART_FILTER,
    BuildDialog,
    CartridgeDialog,
    ChooseProjectDialog,
    NameDialog,
    open_projects_folder,
)
from shiny_mushroom.ui.properties import NO_LEVEL, PropertiesDock
from shiny_mushroom.ui.render import DEFAULT_WIDTH, bytes_to_image, raster_to_image
from shiny_mushroom.ui.secondary_entrances_dialog import SecondaryEntrancesDialog
from shiny_mushroom.ui.settings import (
    load_bytes_setting,
    load_int_setting,
    load_str_setting,
    save_bytes_setting,
    save_enum_setting,
    save_int_setting,
    save_str_setting,
)
from shiny_mushroom.ui.source_files_dialog import SourceFilesDialog
from shiny_mushroom.ui.strings_window import StringsWindow
from shiny_mushroom.ui.theme import THEME_KEY, Theme, apply_theme
from shiny_mushroom.ui.tile_palette import PaletteTab, TilePaletteDock
from shiny_mushroom.ui.toolbars import ModeToolbars
from shiny_mushroom.ui.view_bar import LEVEL_BUTTONS, WORLD_BUTTONS, ViewBar
from shiny_mushroom.ui.view_options import ViewOptions
from shiny_mushroom.ui.window.colours import Colours
from shiny_mushroom.ui.window.keys import KeyRouting
from shiny_mushroom.ui.window.level_tree import LevelTree
from shiny_mushroom.ui.window.load_path import LoadPathWindow
from shiny_mushroom.ui.window.modes import EditorMode, LevelEditing
from shiny_mushroom.ui.window.parts import (
    DISASSEMBLY,
    LEVEL_PALETTE,
    POINTER_PARTS,
    SOURCE_FILES,
    WORLD_PARTS,
    WORLD_TABLES,
    _rebuild_detail,
)
from shiny_mushroom.ui.window.project_windows import ProjectWindows
from shiny_mushroom.ui.window.testing import Testing
from shiny_mushroom.ui.window.trail import Trailing
from shiny_mushroom.ui.world_bar import (
    EDIT_ROWS,
    EVERY_EVENT,
    NO_EVENTS,
    WorldBar,
    edit_row_of,
)
from shiny_mushroom.ui.world_tables import WorldTables
from shiny_mushroom.ui.zoom_bar import ZoomBar
from smw_tools import graphics as codec
from smw_tools import packed
from smw_tools.asm_codec import AsmRegionError, AsmRegionFull
from smw_tools.asm_regions import region_for
from smw_tools.asm_room import Run
from smw_tools.bases import BaseError
from smw_tools.bases import base as rom_base
from smw_tools.features import (
    LEVEL_GRAPHICS,
    MANAGED_GRAPHICS_MEMORY,
    OVERWORLD_TABLES_RELOCATED,
    FeatureError,
    applied,
)
from smw_tools.graphics import GraphicsError
from smw_tools.level_graphics import decode as decode_graphics
from smw_tools.level_graphics import effective as effective_graphics
from smw_tools.rom_sizes import bytes_label
from smw_tools.symbols import SymbolTable, load_symbols

ZOOM_KEY = "view/zoom"
#: The project last worked in, so a returning session offers it first.
PROJECT_KEY = "project/current"
#: The folder the last ROM was exported to. Where someone puts a built
#: cartridge is a habit -- an emulator's folder, a share, a flash cart -- and it
#: is nowhere near the projects folder, which is why the chooser cannot just
#: open there.
EXPORT_KEY = "export/folder"
GEOMETRY_KEY = "window/geometry"
STATE_KEY = "window/state"
#: Where each editing environment's dock arrangement is remembered -- see
#: :meth:`MainWindow._swap_chrome_layout`. Two arrangements rather than one,
#: because the create panel and the world map's tile palette take turns in a
#: single spot: one dragged wider or taller is a decision about *that*
#: environment, and handing the other the size it was left at loses it. The
#: level keeps the original key, so an arrangement made before there were two
#: is the one a returning session opens on.
CHROME_STATE_KEYS = {
    "level": STATE_KEY,
    "world": "window/state-world",
}

# Refuse to render something enormous as a byte map rather than spending a
# minute building a QImage nobody asked for. 8 MiB is well past the largest SNES
# cartridge, so anything above it was opened by mistake.
MAX_FILE_BYTES = 8 * 1024 * 1024

# A level is never opened magnified. A byte map is 256 pixels wide and wants
# magnifying; a level is up to 4096, and inheriting the byte map's 4x would open
# on a hugely magnified corner of one - which reads as the render having failed
# rather than as a zoom setting.
#
# A ceiling rather than a setting, though: a zoom at or below 1:1 is a deliberate
# choice about how much level to see at once, and the levels below it exist for
# exactly this picture. Pulling someone back to 1:1 on every load would undo that
# choice - and, now that the zoom is remembered, overwrite it.
LEVEL_ZOOM = 1

# How often a colour being dragged in the picker is allowed to repaint the
# canvas. A palette change invalidates the block and tile caches, so it is a
# whole re-render -- 5 to 12 ms for Layer 1, 28 to 63 for a composite -- and
# the picker reports every mouse move. Eight frames a second is enough to
# choose a colour by and cheap enough that the dialog stays responsive while
# it happens. The undo step is separate: one per pick, on OK.
PALETTE_PREVIEW_MS = 120

# How wide the busy bar in the status bar is. Narrow on purpose: it reports that
# a load is running and nothing else, so it belongs beside the message that says
# which level rather than stretched across the window looking like progress it
# cannot measure.
BUSY_BAR_WIDTH = 120

_log = logging.getLogger(__name__)

# What an edit made while a level is being opened is told. It is refused -- the
# document is the outgoing level's, or the level in hand has no marker on it yet
# -- and the whole point of saying it is that the refusal is otherwise invisible:
# the gesture is made, nothing happens, and nothing says why.
#
# In the status bar rather than a dialog. It answers a keystroke somebody may
# already have thought better of, and a modal for that would be a worse
# interruption than the one it is explaining.
EDIT_REFUSED = "The level is still opening; that edit was not applied."

# What an edit the streams cannot hold is told -- the other refusal, and the
# other thing that would otherwise look exactly like a gesture that did
# nothing. `Level` hands back `None` for it, and there is one cause: a sprite
# whose first byte would be the sprite list's terminator, so the records behind
# it would never load. Named rather than described as "invalid", because the
# person can act on it -- move the sprite a block, or clear an extra bit.
EDIT_UNWRITABLE = "A sprite would end the sprite list where it lands; not applied."

# The same span as the window's other transient messages. It does not have to
# outlast the load: the level arriving writes its own line over this one, which
# is the right moment for it to go.
EDIT_REFUSED_MS = 4000

#: Said when Level Graphics is asked for and there is nothing it could offer:
#: no project to save a row into, or an image whose tileset lists cannot be
#: read. The row is the project's, so a window with only a cartridge open has
#: nowhere to put one -- which is worth saying rather than greying a row whose
#: absence would look like the feature not existing.
NO_GRAPHICS_ROW = (
    "A level's own graphics need a project: the row reaches the cartridge "
    "through its build."
)

#: How the status line names a row that keeps every slot the tileset's, which
#: is a level with no row at all.
TILESETS_OWN = "the tileset's"

#: :meth:`MainWindow._background_to_save`'s "edited but unfileable" answer,
#: distinct from "nothing to save": the save must stop rather than quietly
#: drop the background's edit.
NOWHERE_TO_FILE = object()


def _plural(count: int, noun: str) -> str:
    """``count`` of ``noun``, with the ``s`` where English wants one.

    Four readouts count things -- records deleted, files written, levels
    unsaved, what a group selection holds -- and each had spelled the same
    conditional out inline. One of them is a place for it to be got wrong.
    """
    return f"{count} {noun}" + ("" if count == 1 else "s")


def _project_stamp(project: Project) -> int | None:
    """When ``project``'s record was last written, or ``None`` without one.

    Every edit the project saves stamps its metadata modified, and the file is
    rewritten atomically each time, so its clock is a change count that never
    repeats -- where the ``modified`` text inside it, kept to the second, would
    call a save made in the same second as the build it followed nothing.
    """
    try:
        return (project.root / PROJECT_FILE).stat().st_mtime_ns
    except OSError:
        return None


def _palette_sets(header: bytes) -> tuple[int, int, int]:
    """A header's three palette settings, in the order
    :func:`~shiny_mushroom.palette_map.level_runs` takes them."""
    return (
        field_value(header, "background_palette"),
        field_value(header, "foreground_palette"),
        field_value(header, "sprite_palette"),
    )


def _same_file(one: Path, other: Path) -> bool:
    """Whether two paths name the same file on disk.

    As the filesystem sees it rather than as text: Windows matches a path
    case-insensitively, so the project's own cartridge opened under another
    spelling of its case would compare unequal and be read through the
    default base -- the wrong pointer tables for every offset in this file.
    ``samefile`` needs both to exist; the resolved paths are the fallback
    for a cartridge that has not been built yet.
    """
    try:
        return one.samefile(other)
    except OSError:
        return one.resolve() == other.resolve()


@dataclass(frozen=True)
class _EditSurface:
    """What the Edit menu acts on, whichever of the three things is being
    edited: the level's records, its Layer 2 pattern, or the world map.

    Every Edit row and every Edit key routes through one of these, and
    :meth:`MainWindow._edit_surface` is the only place that decides which --
    so a row wired to a slot is wired to all three, and a mode added later
    cannot be half-connected. The callables are the operations the rows fire;
    the flags are the same questions asked for enablement, and they are read
    eagerly because each is a field or a property away.
    """

    #: One step along this document's undo stack, and what is said about it.
    walk: Callable[[bool], None]
    copy: Callable[[], None]
    cut: Callable[[], None]
    delete: Callable[[], None]
    paste: Callable[[], None]
    #: One committed properties-panel field. The panel is shared, so its
    #: edits route by mode exactly as the canvas's gestures do.
    commit_field: Callable[[str, int], None]
    can_undo: bool
    can_redo: bool
    #: Whether a copy -- and so a cut or a delete -- has something to take.
    can_copy: bool
    can_paste: bool
    #: Whether Bring Forward, Send Back and Duplicate mean anything. Only
    #: records have an order to be in: reordering a tilemap says nothing.
    can_order: bool


class _BackgroundFloat(FloatController[frozenset[tuple[int, int]], Level]):
    """What the painting mode has in hand.

    The window's answers for :class:`~shiny_mushroom.tile_clipboard.FloatController`,
    over the level's repeating Layer 2 pattern: one grid, one layer, and the
    window's own commit. The pattern wraps rather than ending, so
    :func:`~shiny_mushroom.level.background_index` answers everywhere and no
    entry is ever dropped.
    """

    def __init__(self, window: MainWindow) -> None:
        super().__init__()
        self.window = window

    def ready(self) -> bool:
        return self.window._doc is not None and self.window._shape is not None

    def document(self) -> Level:
        assert self.window._doc is not None
        return self.window._doc

    def selection(self) -> frozenset[tuple[int, int]]:
        return self.window._bg_selection

    def select(self, selection: frozenset[tuple[int, int]]) -> None:
        self.window._bg_select(selection)

    def nothing(self) -> frozenset[tuple[int, int]]:
        return frozenset()

    def spot(self, x: int, y: int) -> int | None:
        return background_index(x, y)

    def bounds(self) -> tuple[int, int]:
        shape = self.window._shape
        assert shape is not None
        return shape.columns, shape.rows

    def place(self, document: Level, placed: dict[int, int]) -> Level:
        return document.layer2_placed(placed)

    def covering(
        self, entries: tuple[tuple[int, int, int], ...], anchor: tuple[int, int]
    ) -> frozenset[tuple[int, int]]:
        return frozenset((anchor[0] + dx, anchor[1] + dy) for dx, dy, _ in entries)

    def spots(self) -> list[tuple[int, int, int]]:
        document = self.document()
        assert document.layer2 and self.window._bg_selection
        return [
            (column, row, document.layer2[background_index(column, row)])
            for column, row in sorted(self.window._bg_selection)
        ]

    def show(self, previous: Level, current: Level) -> None:
        self.window._show_background(current.layer2)

    def holds(self, document: Level) -> bool:
        history = self.window._history
        return history is not None and history.level is document

    def replace(
        self,
        held: FloatingSelection[Level],
        document: Level,
        mark: SelectionMark[frozenset[tuple[int, int]]],
    ) -> None:
        history = self.window._history
        assert history is not None
        history.replace(document, mark)
        self.window._settle(history.level)

    def commit(
        self,
        held: FloatingSelection[Level],
        document: Level,
        mark: SelectionMark[frozenset[tuple[int, int]]],
    ) -> bool:
        return self.window._commit(document, mark)

    def abandon(self, previous: Level) -> None:
        self.window._sync_background()


class MainWindow(
    Colours,
    KeyRouting,
    LevelTree,
    LoadPathWindow,
    ProjectWindows,
    Testing,
    Trailing,
    QMainWindow,
):
    """The application window.

    Assembled from the mixins in :mod:`shiny_mushroom.ui.window`, each one
    subject of the window rather than an object with state of its own -- see
    that package for why the shape is mixins and not delegates. All of the
    state is declared and described here, in ``__init__``; a mixin only reads
    and writes it.
    """

    #: Asks the loader for a level, with the cartridge edits to load it under.
    #: A signal rather than a direct call because the loader lives on another
    #: thread, and connecting to it is what makes Qt marshal the call across
    #: instead of running it here.
    level_requested = Signal(int, object)

    #: Asks the loader to capture what the player looks like. Emitted once a
    #: session, after a level is up: the probe needs a level running, and what
    #: it brings back does not vary with which one.
    player_art_requested = Signal()

    #: Asks the loader to capture the world map, over the project's edited
    #: graphics files as patches. Cached on the worker under that set, so only
    #: the first request a session makes for it pays for the loads.
    overworld_requested = Signal(object)

    #: The catalogue's two round trips are the create panel's supply
    #: (:class:`~shiny_mushroom.ui.previews.Previews`) rather than this window's.
    #: They are connected to the same loader alongside these -- see
    #: :meth:`load_level` -- and nothing here asks for a thumbnail.

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        #: How the level is shown, as against what is in it: the seven View
        #: toggles, restored from the store they were last written to.
        self.options = ViewOptions.load()
        self._path: Path | None = None
        self._level: int | None = None
        self._loader: LevelLoader | None = None
        # The opened file's bytes, kept so an in-memory edit can be turned into
        # a cartridge patch without reading it back off disk - see test_patches.
        self._rom: bytes | None = None
        # The test window, while one is open. One at a time: a run replaces
        # whatever the last one was, and two of them would be two cores.
        self._play: PlayWindow | None = None
        # And the emulator behind it, which outlives it: booted when the
        # cartridge is opened and put down rather than shut when the window
        # closes, so a test run costs a level load and not a boot. See
        # `ready_play_session`.
        self._session: PlayController | None = None
        # The last snapshot is held so the view can be redrawn without paying
        # for the emulator again - see _draw_level.
        self._snapshot = None
        # The level's shape in blocks, held because the position readout needs
        # it: which screen a block is on depends on whether the level runs
        # across or down, and only the geometry knows that.
        self._shape: Geometry | None = None
        # The level's own pixels and everything painted over them, with the
        # sprite plane cached beside them -- see shiny_mushroom.ui.picture.
        self._picture = Picture()
        # What the player looks like, captured once from the cart and kept for
        # the session. Unlike a sprite's, his artwork does not come from the
        # level's tileset, so it does not have to be recaptured per level -- and
        # the capture needs a level to be *running*, so it is asked for after
        # the first load rather than at startup.
        self._player_art = None
        # Whether it has been asked for at all for the cartridge in hand.
        # Separate from holding the artwork, because a probe that found nothing
        # is an answer: asked again per load, a cart whose player cannot be
        # captured would pay for the probe -- and wait behind it -- on every
        # level it opened, for a marker that is never going to arrive.
        self._player_art_asked = False
        # Where a test run starts, per level, when it is not the level's own
        # entrance. **Test state, never level data**: SMW's entrance cannot
        # express an arbitrary position, nothing here is written to a file, and
        # the level on disk is untouched by it. Kept per level so switching away
        # and back does not lose the spot being worked on.
        self._test_start: dict[int, PlayerPosition] = {}
        # The level being edited: both record streams, with the history that
        # takes an edit back. **This is the document.** Everything on the canvas
        # that is not a picture comes out of here, and every gesture that
        # changes something goes through it - see shiny_mushroom.edit.
        #
        # None until a level arrives, which is also what "there is nothing to
        # edit" means: a byte map is not a level and neither is an empty window.
        self._doc: Level | None = None
        self._history: History | None = None
        # Which blocks each object drew, by stream offset. Empty until a load
        # collects it: an object is then known by what it put on screen rather
        # than by the one block its record names.
        self._drawn: dict[int, frozenset[tuple[int, int]]] = {}
        # What is selected, as record ids. A **set**, because every edit gesture
        # applies to as many things as are held, and because the alternative -
        # one record plus a list of others - needs a rule for which is which at
        # every call site.
        #
        # Ids rather than the records themselves: an edit rewrites both streams,
        # so the record objects and their offsets are replaced wholesale, and a
        # selection has to survive that and an undo. Held here rather than on the
        # canvas, which is handed a picture and does not know either kind of
        # thing exists.
        self._selection: frozenset[int] = frozenset()
        # The **screen** held instead, or None. Its own state rather than a
        # member of the selection above, because a screen is not a record: it
        # has no uid, no bytes and no place in either stream, and every edit,
        # drag and clipboard operation there is works on records. The two are
        # exclusive -- what the panel describes is one thing -- and this is the
        # one the number boxes on the canvas select; see `_select_screen`.
        self._screen_selected: int | None = None
        # The selection box being dragged, in image pixels, or None outside one.
        self._marquee: tuple[QPoint, QPoint] | None = None
        # What a shift-marquee adds to: the selection as the box began, which
        # each frame of the drag unions against -- the same starting set,
        # never the one the previous frame produced. Empty for a bare box,
        # which replaces the selection the way a bare click does.
        self._marquee_from: frozenset[int] = frozenset()
        # A drag that is moving the selection: where it began, in image pixels,
        # and how far the selection has been carried from there, in blocks. Both
        # None outside one. The step is measured from where the drag began
        # rather than accumulated per frame, so a selection pushed into a wall
        # and back out again returns to where it started.
        #
        # **The document is not touched while this is set.** The step is drawn,
        # not applied: see `Floating`, and `_drag_ended` for where it lands.
        self._moving: QPoint | None = None
        self._floating: tuple[int, int] | None = None
        # A drag that is resizing the held object: where it began, in image
        # pixels, which of its edges it took hold of, and how far those have
        # actually been pulled, in blocks. All None outside one.
        #
        # **The document is not touched while this is set either**, and for a
        # sharper reason than a move's: a resize changes what the object draws,
        # and what it draws is the game's own work. Committing per frame would
        # ask the emulator for a picture per block crossed -- see `Stretching`
        # for what is drawn in the meantime, and `_drag_ended` for where it
        # lands.
        self._stretching: QPoint | None = None
        self._grip: Grip | None = None
        self._pulled: tuple[int, int] | None = None
        # What the create panel has put in hand, and which block the pointer is
        # offering to put it on. Both None outside a placement.
        #
        # **The third thing a gesture can be holding, and the only one that is
        # not in the level.** A move carries records and a resize pulls an edge
        # of one; this is a record that does not exist until the button comes
        # down, so there is nothing in the document to mark and the ghost is
        # drawn from the catalogue entry instead -- see `Placing`.
        self._placing: Entry | None = None
        self._placing_at: tuple[int, int] | None = None
        # The Layer 2 background's counterpart of the pair above: the tile in
        # hand while the level's Editing mode is Layer 2, its full-size image
        # for the ghost, and -- during a paint stroke -- the document the
        # stroke is being applied to, committed whole when the button comes
        # up so the stroke is one undo step. See `_bg_place` and friends.
        self._bg_placing: BackgroundTile | None = None
        self._bg_tile_image: QImage | None = None
        self._bg_stroke: Level | None = None
        # The painting mode's selection: level *blocks*, boxed or clicked out
        # of the picture -- one instance, though the pattern entry behind
        # each repeats across the level -- and the set a shift-marquee
        # extends from. The records' `_selection` twin, kept apart because
        # the two select different things and the modes take turns. What a
        # copy of it holds is values with relative geometry, like the world
        # map's clipboard and unlike the record clipboard below; it outlives
        # the level for the same reason the record clipboard does, with the
        # same caveat about the next level's page reading the same bytes
        # differently. A paste stays in hand in `_bg_hand` until another
        # gesture lands it -- see "the floating selection" below.
        self._bg_selection: frozenset[tuple[int, int]] = frozenset()
        self._bg_marquee_from: frozenset[tuple[int, int]] = frozenset()
        self._bg_clipboard: TileClipboard | None = None
        self._bg_hand = _BackgroundFloat(self)
        # What a copy or a cut took, and the tileset the objects in it were
        # copied under. **Records, not bytes**: a stream is only meaningful
        # beside the level that holds it -- the screen jumps in it place the
        # records after it -- so what the clipboard carries is the parsed
        # records, which a paste puts through `added` like any other placement.
        #
        # It belongs to the *cartridge* rather than to the level, which is what
        # makes copying out of one level and into another work at all. The
        # tileset is remembered with it because an object number is a different
        # object in a different one, and a paste that crosses tilesets is worth
        # saying so about; a sprite number means one thing across the cartridge,
        # so nothing is remembered for those.
        self._clipboard: tuple[Record, ...] = ()
        self._clipboard_tileset: int | None = None
        # Which block the pointer was last over, or None when it is not on the
        # picture at all. Held because a paste lands where the pointer is, and
        # the key that asks for one arrives from wherever the keyboard is rather
        # than from the canvas.
        self._pointing_at: tuple[int, int] | None = None
        #: The context menu last popped up, or ``None``. Kept so it is
        #: released when the next one is built rather than leaking a
        #: menu per right click, and so a test can read its rows.
        self._context_menu: QMenu | None = None
        # Whether the press that began a drag has already been taken as a
        # placement, so its release is not read as a second one. A placement is
        # a *click*, and at 4x zoom the four device pixels that turn one into a
        # drag are a single image pixel -- so a placement that is refused
        # because the hand wobbled is a placement that looks like it did
        # nothing. The press is answered instead, at the position it was aimed
        # at, which is the same rule `Canvas.release_at` follows for a click.
        self._placed_by_drag = False
        # The overlays for everything a gesture is *not* holding, held for the
        # length of one. None outside a gesture, and dropped whenever anything
        # they are drawn from changes -- see `_draw_overlays`.
        self._resting: tuple[Overlay, ...] | None = None
        # Whether the load now in flight was asked for by an edit rather than by
        # somebody opening a level. It decides whether the snapshot that comes
        # back rebuilds the document or only repaints it.
        self._refreshing = False
        # Whether a request is with the loader at all, and whether the document
        # has moved on since it was made. The loader answers in order and cannot
        # be told to abandon a request, so these are what keep a held-down arrow
        # key from queueing a load per repeat -- see `_refresh_picture`.
        self._loading = False
        self._refresh_pending = False
        # Whether the load in flight will **replace the document**, which is a
        # different question from whether one is in flight at all: a refresh
        # brings back a picture of the level already held and leaves everything
        # editable, while opening a level throws the document away. Editing
        # across the second one is editing a level that is on its way out --
        # see :meth:`_lock_for_load`.
        self._replacing = False
        # Whether the probe that captures the player is still out. It is the
        # *second half* of a cartridge's first load: the level is on the canvas
        # by then, but the spawn marker -- where a test run starts, and what a
        # middle click moves -- is not on it until this lands. The level is not
        # open until both have, so this holds the lock the way a load in flight
        # does.
        self._awaiting_player_art = False
        # Where everything in the cartridge is, built once when one is opened.
        # Empty without a ROM, so nothing has to test for one.
        self._index = LevelIndex()
        # The project a save goes into, or None when none is open. **Editing
        # works without one** -- a level can be looked at, changed and tested
        # entirely in memory -- and what a project adds is somewhere to put the
        # result. Kept apart for that reason: opening one is a decision about
        # where work is kept, not a precondition for doing it.
        self._project: Project | None = None
        # Which ROM base the cartridge on screen was assembled from, and where
        # that base keeps its tables. **Not the project's, but the file's**: a
        # cartridge opened by hand while a project is open is not that project's
        # cartridge, and reading it through a base it was not built on would
        # follow pointer tables that are not there. Kept in step by
        # :meth:`_use_base`, which every path that changes the file goes through.
        self._base_id: str | None = None
        self._target_id: str | None = None
        self._addresses: Addresses = DEFAULT_ADDRESSES
        # The open cartridge's own per-role addresses, resolved from its
        # build's symbol file -- None for a cartridge that has none. Travels
        # with every worker the window starts, so their reads agree with
        # :attr:`_addresses`.
        self._role_addresses: dict[str, int] | None = None
        #: And how many entries its growable tables hold, off the same
        #: symbol file -- :func:`shiny_mushroom.build.role_counts`.
        self._role_counts: dict[str, int] | None = None
        # And which capabilities beyond the stock game that cartridge has, as
        # feature ids -- its build's own record. Travels with the workers for
        # :attr:`_role_addresses`' reason, and amends the base every one of
        # them resolves through; see :mod:`smw_tools.features`.
        self._features: tuple[str, ...] = ()
        # How many entries each of the world map's tables holds on it -- the
        # stock format until a cartridge with a feature that grew one is open.
        # See `_use_base`.
        self._map_shape: MapShape = STOCK_SHAPE
        # Where you have been: a browser's back button over levels and views.
        # **Not the undo stack** -- that takes back a change to the level, this
        # takes back a change of view, and interleaving them would mean Back
        # sometimes resurrecting a deleted object. See shiny_mushroom.navigation.
        self._trail = Trail()
        # A place being travelled back (or forward) to, while its level loads.
        # The same shape as the pending search result below and for the same
        # reason: the load is asynchronous, so arriving is a separate event from
        # asking to go.
        self._going_to: Place | None = None
        # A search result being travelled to, while its level is still loading.
        # The whole of what makes a jump across levels work: the load is
        # asynchronous, so the record cannot be selected until it arrives, and
        # by then the click that asked for it is long over.
        self._pending: Occurrence | None = None
        # The level a followed exit leads to and the arrival it leads through,
        # while that level loads -- the same shape as the two above, for the
        # same reason. The arrival is `None` where the exit is an ordinary
        # one: it lands wherever the destination's own entrance does, which is
        # where the load itself puts the player and nothing here has to work
        # out. See :meth:`_serve_arrival`.
        self._arriving_at: (
            tuple[int, secondary_entrances.SecondaryEntrance | None] | None
        ) = None
        # Which document the central view is editing. Everything level-shaped
        # above stays exactly what it was: the world map's own state lives in
        # `self._world`, and this is only the switch the gesture dispatchers
        # route by.
        self._mode = EditorMode.LEVEL
        # Whether a world map capture is with the loader. Its own flag beside
        # `_loading` because the level flags gate level refreshes, and a world
        # capture must not be mistaken for one.
        self._awaiting_world = False
        # Whether the world map held -- or the capture in flight -- was made
        # over graphics files the project has since changed, so the picture
        # is of files the load no longer sees and the map is captured again
        # before it is looked at -- see `_graphics_changed`.
        self._world_stale = False
        # Where the level view was looking when the world map took the canvas,
        # so leaving the mode comes back to the same place.
        self._level_look: QPoint | None = None
        # Whether a layer toggle moved while the world map held the canvas, so
        # that the level's buffered picture no longer matches the options and
        # leaving the mode must render it again -- see `_redraw_layers`.
        self._level_stale = False

        self._build_canvas()
        self._build_docks()
        self._build_bars()
        self._build_status_bar()
        self._build_menus()

    def _build_canvas(self) -> None:
        """The canvas and the view it is looked at through, and the two event
        filters that get the editing keys to the level."""
        self.canvas = Canvas()
        # Before anything is connected: the canvas is being put where it was left
        # last session, which is not a change to announce or to write back.
        # Snapped, since a hand-edited or older config can name a percentage this
        # build's ladder does not have.
        self.canvas.set_zoom(
            from_percent(load_int_setting(ZOOM_KEY, as_percent(DEFAULT_ZOOM)))
        )
        self.canvas.set_screens(self.options.screens)
        # Every mode-sensitive gesture goes through a dispatcher -- see "the
        # world map mode" below -- so the level handlers stay exactly what they
        # were and the whole mode question lives in one visible block. The
        # zoom is the one signal both modes mean the same thing by.
        self.canvas.cursor_moved.connect(self._canvas_cursor_moved)
        self.canvas.cursor_left.connect(self._canvas_cursor_left)
        self.canvas.zoom_changed.connect(self._show_zoom)
        self.canvas.clicked.connect(self._canvas_clicked)
        # A click on a screen's own number box, which the canvas offers only
        # while the labels are targets -- see `_sync_screen_selecting`. A
        # second click on the same box takes the exit it holds.
        self.canvas.screen_clicked.connect(self._select_screen)
        self.canvas.screen_activated.connect(self._screen_activated)
        # Which document Edit and Ctrl+S act on follows the surface last worked
        # in -- see :meth:`_editing_palettes`. Any gesture on the canvas hands
        # it back to the level or the map.
        for gesture in (
            self.canvas.clicked,
            self.canvas.screen_clicked,
            self.canvas.screen_activated,
            self.canvas.clicked_away,
            self.canvas.middle_clicked,
            self.canvas.right_clicked,
            self.canvas.drag_begun,
        ):
            gesture.connect(self._left_palettes)
        self.canvas.clicked_away.connect(self._canvas_clicked_away)
        self.canvas.middle_clicked.connect(self._canvas_middle_clicked)
        # The right button is the way back to selecting. It reaches here from
        # the surround as well as from the picture, which is the point: putting
        # something down should not require finding a piece of level to do it
        # over.
        self.canvas.right_clicked.connect(self._canvas_right_clicked)
        self.canvas.drag_begun.connect(self._canvas_drag_begun)
        self.canvas.drag_moved.connect(self._canvas_drag_moved)
        self.canvas.drag_ended.connect(self._canvas_drag_ended)

        # The view is what the canvas is looked at through: it scrolls, pans and
        # zooms, and the canvas itself stays a picture of a fixed size.
        self.view = CanvasView(self.canvas)
        self.setCentralWidget(self.view)
        # The arrows and the rest of the bare editing keys are taken off the
        # view before it scrolls on them -- see eventFilter. Watched on the view
        # rather than on the application, so those are only ever asked about
        # keys already aimed at the picture.
        self.view.installEventFilter(self)
        # Whatever holds the keyboard, for the other half of eventFilter: the
        # *shortcuts* that act on the level have to reach it from wherever the
        # keyboard is, which is a question asked of the focused widget rather
        # than of the picture. See `_wants_the_level_key` and
        # `_follow_the_keyboard`.
        application = QApplication.instance()
        if application is not None:
            application.focusChanged.connect(self._follow_the_keyboard)

    def _build_docks(self) -> None:
        """The right-hand docks, and the world map mode that shares them.

        Two occupants of one spot -- the create panel and the world map's
        tile palette -- tabbed with the properties panel, and only the
        current mode's visible."""
        # Above the properties panel and on the same side, because the two are a
        # pair: this one says what a level could contain and that one says what
        # one record in it does. Tabbed together rather than stacked, so the
        # dock's width is spent on one of them at a time -- a catalogue of names
        # and a column of value boxes both want the room, and neither is looked
        # at while the other is being used.
        self.create = CreateDock(self)
        self.create.armed.connect(self._arm_placement)
        # The level's third placeable thing lives in the same panel, under its
        # own tab: the Layer 2 background's page of blocks. It says what was
        # picked on its own signal, because a block number is not an entry --
        # and the *tab* says which editing mode a gesture on the level is in,
        # which is `set_level_editing`'s to decide, exactly as the level bar's
        # Editing box is.
        self.level_palette = self.create.layer2
        self.level_palette.armed.connect(self._bg_armed)
        self.create.editing_picked.connect(self.set_level_editing)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, self.create)

        # What the panel is offering, and the round trips that fill it in. It
        # reads the window through `_held` -- asked afresh each time rather than
        # captured, because a probe outlives several edits.
        self._catalog = Previews(self.create, self._held, self)

        self.properties = PropertiesDock(self)
        self.properties.edited.connect(self._commit_field)
        # Escape in a field is "I am done here": the keyboard goes back to the
        # picture, where the arrows move what is held rather than stepping a
        # spin box. The selection stays -- what was let go of is the panel.
        self.properties.dismissed.connect(self.view.setFocus)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, self.properties)
        self.tabifyDockWidget(self.create, self.properties)
        # The properties panel in front on a first run: it is the one that
        # answers a click on the level, which is the first thing anybody does.
        # A remembered arrangement overrides this -- see `_restore_geometry`.
        self.properties.raise_()

        # The world map's tile palette, in the create panel's place: the two
        # are the same kind of thing for the two modes, so they share the spot
        # and only the current mode's is visible.
        self.tile_palette = TilePaletteDock(self)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, self.tile_palette)
        self.tabifyDockWidget(self.tile_palette, self.properties)
        self.tile_palette.setVisible(False)

        # The palettes, in both modes: the colours are the game's rather than
        # any one level's, so unlike the two above this does not take turns
        # with anything.
        self.palette_dock = PaletteDock(self)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, self.palette_dock)
        self.tabifyDockWidget(self.palette_dock, self.properties)
        self.palette_dock.picked.connect(self._entered_palettes)
        # A panel that has been put away is not the surface being worked in,
        # however recently it was.
        self.palette_dock.visibilityChanged.connect(self._palette_shown)
        self.palette_dock.previewed.connect(self._preview_color)
        self.palette_dock.committed.connect(self._commit_color)
        self.palette_dock.cancelled.connect(self._cancel_color)
        self.palette_dock.reset_asked.connect(self._reset_color)
        self.palette_dock.reset_all_asked.connect(self._reset_colors)
        self.palette_dock.custom_toggled.connect(self._custom_palette_toggled)
        self.palette_dock.save_asked.connect(self.save_palettes)
        # Closing the panel settles unsaved colours first -- see
        # :meth:`_may_close_palettes`.
        self.palette_dock.set_close_guard(self._may_close_palettes)
        # Which editing mode a gesture on the level is in: `self._level_editing`,
        # this window's, like the editor mode above.
        self._level_editing = LevelEditing.RECORDS
        # Each environment's dock arrangement, kept as it is left and put back
        # when it comes round again -- see `_swap_chrome_layout`. Which one is
        # on screen, against `_chrome`'s answer for which one should be.
        self._layouts: dict[str, QByteArray] = {}
        self._chrome_shown: str | None = None
        # Panels a restored arrangement left floating, kept off screen until the
        # window is -- see `_hold_floating_panels`.
        self._held_panels: list[QWidget] = []
        # Everything the world map mode is: its document, selection and
        # gestures, behind this window -- see shiny_mushroom.ui.overworld_mode.
        # Handed the shared widgets and two callbacks, so what an edit means
        # for the actions and the title stays this window's decision.
        self._world = OverworldMode(
            self.canvas,
            self.view,
            self.properties,
            self.tile_palette,
            self._position_label_text,
            self._world_changed,
        )
        # A row added to one of the map's growable tables is priced against
        # the project's own build -- its symbol file, read once per cartridge
        # and kept until the next one loads, since a rebuild reopens the ROM.
        self._world.price_room = self._price_world_room
        # And where a level cell's Level picker gets its rows: the same list
        # the toolbar's Level box is filled from, read live so it follows the
        # cartridge whose tree names them.
        self._world.level_choices = lambda: self._level_choices
        # And a level cell's panel button opens the window the Level menu's
        # row opens, on the cell the panel is describing.
        self._world.open_load_path = self.view_load_path
        # And the button beside a level cell's number: leave the map and edit
        # the level the tile loads, through both unsaved-work questions.
        self._world.open_level = self.open_level_from_map
        self._world_runs: dict[str, Run] | None = None
        #: Which submap's palette the panel is currently showing -- see
        #: `_world_changed`, which refreshes it only when this has moved.
        self._world_palette_shown: int | None = None
        # The four table editors over the same world document -- modeless
        # views, refreshed by `_world_changed` and closed with the mode.
        self.world_tables = WorldTables(
            self._world,
            self,
            self._adopt_shortcuts,
            self._status_message,
            lambda: self._map_shape,
        )
        # The Level Exits window: the open level's screen exits as a table,
        # built on first open and kept, refreshed by `_show_screen_exits`
        # wherever the screen labels are -- the two are one statement about
        # the level and follow the document together.
        self._level_exits = LevelExits(
            self,
            lambda: self._doc,
            lambda: self._level_choices,
            self._entrances_offered,
            self._adopt_shortcuts,
            self.commit_screen_field,
            self.add_screen_exit,
            self._select_screen,
        )
        # The Level Data window, while one is open: a modeless view of the
        # open project's containers, refreshed as levels are saved and closed
        # with the project -- see :meth:`view_level_data`.
        self._level_data: LevelDataDialog | None = None
        # The Graphics Files window, kept and closed with the project the
        # same way -- see :meth:`edit_graphics_files`.
        self._graphics_files: GraphicsDialog | None = None
        # The cartridge's memory map, kept for the same reason and closed with
        # the project the same way -- see :meth:`view_memory_map`.
        self._memory_map: MemoryMapDialog | None = None
        #: The Level Load Path window: one level's chain from overworld
        #: tile to level data, kept and refreshed like the viewers above.
        self._load_path: LoadPathDialog | None = None
        #: The Strings window: the game's text, kept like the viewers above
        #: and closed with the project -- see :meth:`edit_strings`.
        self._strings: StringsWindow | None = None
        #: The Map16 editor, kept and closed with the project the same way,
        #: and redrawn as levels arrive -- see :meth:`edit_map16`.
        self._map16: Map16Dialog | None = None
        #: The Secondary Entrances window, kept and closed with the project
        #: whose tables it holds -- see :meth:`edit_secondary_entrances`.
        self._secondary_entrances: SecondaryEntrancesDialog | None = None
        #: The cartridge's arrival tables, read when it is opened and kept
        #: for what a screen exit marked secondary offers and where it leads
        #: -- see :meth:`_read_entrances`. ``None`` where nothing could be
        #: read.
        self._entrances: secondary_entrances.Entrances | None = None
        #: The Layer 2 entries the window's pick offers, in list order --
        #: what a committed index resolves through.
        self._load_path_layer2: tuple[Layer2Entry, ...] = ()
        #: Which containers each level number reads -- the picker's map,
        #: kept for the load path's file rows.
        self._container_files: dict[int, ContainerNames] = {}
        # The same rows the level bar's picker is filled from, for every other
        # place that asks for a level -- a screen exit's destination. Built with
        # the names rather than per question: it is 512 rows, and the shared
        # list model behind every picker is keyed on the tuple.
        self._level_choices: tuple[FieldChoice, ...] = ()
        # What the last patch gather could not make the image carry, by the
        # gatherer that found it -- see :meth:`_note_skipped`. Two of them
        # report, so neither may speak for the other.
        self._skipped: dict[str, list[str]] = {}
        # An accepted Layer 2 repoint whose reload has not landed yet: the
        # level it belongs to, and the mark its undo step will carry. Consumed
        # by :meth:`_read_level` -- the arriving document commits onto the
        # history instead of starting a new one -- and dropped by any arrival
        # that is not the repoint's own.
        # ...and the graphics row the repoint carried, so the arriving
        # document keeps the row the same dialog edited rather than reading
        # the project's saved one back.
        self._pending_repoint: tuple[int, RepointMark, bytes | None] | None = None
        # A graphics-dialog accept whose row first needed the feature, and
        # whose yes rebuilt and reopened the cartridge under it: the level and
        # the row, committed as one step onto the document the reopen's reload
        # brings -- see :meth:`edit_level_graphics`.
        self._pending_graphics_edit: tuple[int, bytes] | None = None
        # Whether the next refresh's arrival must re-sync what the Layer 2
        # kind decides -- the palette's offer and the editing mode. Set by a
        # walk across a repoint step, which can flip the kind under chrome a
        # refresh normally has no reason to touch.
        self._layer2_chrome_stale = False
        # What the hand-editable overlay files looked like when the project was
        # last built or opened -- see :meth:`_check_source_files`. Nothing
        # watches them, so this is what an external edit is noticed against.
        self._source_stamps: dict[Path, tuple[int, int]] = {}
        # Whether the cartridge on the canvas is the one the project's next
        # build would produce, and the project's modification stamp when that
        # was last true -- see :meth:`_sync_rebuild_action`.
        self._build_current = False
        self._built_stamp: int | None = None
        # The project build's symbol table, held against the file it was read
        # from -- see :meth:`_build_symbols`. One slot: a stale key re-reads.
        self._symbols_held: tuple[tuple[str, int, int], SymbolTable] | None = None
        # The game's colours, and everything needed to show an edit to them
        # without asking the emulator again -- see :meth:`_palette_changed`.
        #
        # The document is the **project's**, not the level's: the shared file
        # outlives every level switch and every trip to the world map, and the
        # custom level palettes are project state too -- which levels wear one
        # is as much the document as what each holds. The two are edited on
        # one surface, so they undo as one stack: `_palette_history` holds the
        # whole `PaletteDocument`, and these two fields mirror its halves.
        self._palette = Palette()
        self._level_palettes = LevelPalettes()
        self._palette_history: History[PaletteDocument] = History(PaletteDocument())
        # The disassembly's own file, which the document's changes are measured
        # from, and the one the cartridge on the canvas was built with. They
        # part company exactly where this project has saved colours the build
        # has not yet placed.
        self._palette_base: bytes | None = None
        self._rom_palette: bytes | None = None
        # The palette file the level capture on the canvas was made **under**,
        # which is not always the cartridge's own: a canvas refresh reloads
        # through `test_patches`, and those carry the document's colours. What
        # provenance is checked against, so a colour already edited is still
        # recognised as coming from the file -- see `_palette_under`.
        self._capture_palette: bytes | None = None
        # What the document changes about each of those, which is what a
        # recolour writes onto the capture taken under it. Recomputed whenever
        # the document or either baseline moves. Two, because the two captures
        # are not always taken under the same colours: the world map is always
        # the cartridge's own, a refreshed level is whatever the refresh booted.
        self._palette_over_rom: dict[int, int] = {}
        self._palette_over_capture: dict[int, int] = {}
        # The level's CGRAM as it was captured, and where each of its colours
        # came from. Kept beside the snapshot rather than in it, because the
        # snapshot's own CGRAM is the recoloured one from the moment a colour
        # is changed.
        self._captured_cgram: bytes | None = None
        self._captured_backdrop: int | None = None
        # And the same pair for the graphics: the VRAM as captured, and which
        # eight files the level was loaded with. Kept for the CGRAM's reason --
        # the snapshot's own VRAM stops being the capture the moment a slot is
        # pointed at another file -- and used the same way, by measuring what
        # the document now wants against what the capture was made under. See
        # :meth:`_regraphicsed`.
        self._captured_vram: bytes | None = None
        self._captured_graphics: tuple[int, ...] | None = None
        # The animated tiles file the picture was last *synced* under -- the
        # row's ninth byte, which is the one slot a swap cannot carry. Kept so
        # the move can be spotted rather than the state: a level whose row
        # names a file the capture was not loaded with is a level to ask the
        # emulator about again, and asking on the move rather than on the
        # difference is what keeps a cartridge that cannot show it yet -- the
        # feature off, or the rows not built -- from asking on every edit.
        # Read only where there is a capture to measure against, which is what
        # makes `None` here the game's own tiles rather than "not yet asked".
        self._synced_animated: int | None = None
        # Each file's VRAM form, against the project and its write count: a
        # redraw asks for two per moved slot and decoding one costs a couple of
        # milliseconds, which is the whole margin this seam has over a load.
        self._graphics_vram: dict[
            tuple[str, tuple[int, int] | None, int, int], bytes
        ] = {}
        # Each slot's file as VRAM held it **when the capture was taken** --
        # the one thing the capture itself cannot say, since a slot's run is
        # the file with whatever was written over it since. Kept only while
        # the Graphics window is open, because that is when it earns the
        # ~150 ms it costs to work out: see :meth:`_capture_slot_files`.
        self._captured_slot_vram: tuple[bytes, ...] | None = None
        # What the overlay's raw graphics files were at the last such reading,
        # so a change can be measured against it and the reload skipped when
        # every file that moved is one the eight slots hold.
        self._graphics_stamps: dict[Path, tuple[int, int]] = {}
        # A row being previewed but not committed: what the Level Graphics
        # dialog is showing while it is open. The picture follows it, the
        # document does not, so Cancel is the level exactly as it was.
        self._previewed_graphics: bytes | None = None
        # And the same for the header, which the Level Header dialog drives:
        # its four palette settings are the part of it the canvas can answer
        # without a level load. See :meth:`preview_header`.
        self._previewed_header: bytes | None = None
        # And whose capture it was, with the header it arrived under: what
        # provenance is recomputed from when the document -- not the canvas --
        # moves, a level gaining or losing its own palette being the case.
        self._captured_level: int | None = None
        self._captured_header: bytes | None = None
        self._provenance: list[int] | None = None
        # The backdrop is the PPU's fixed colour rather than a CGRAM entry, so
        # where it came from is its own answer. ``None`` when the sky set does
        # not hold the colour the capture is showing.
        self._backdrop_offset: int | None = None
        # The same pair for the world map, one per submap: each wears a palette
        # of its own.
        self._world_captured: tuple[bytes, ...] = ()
        self._world_provenance: list[list[int] | None] = []
        # Whether the palette panel is the surface being worked in -- what
        # decides which document Ctrl+Z and Ctrl+S mean.
        self._palette_active = False
        # A repaint owed to a picker still being dragged -- see
        # :data:`PALETTE_PREVIEW_MS`.
        self._palette_pending = False
        self._palette_timer = QTimer(self)
        self._palette_timer.setSingleShot(True)
        self._palette_timer.setInterval(PALETTE_PREVIEW_MS)
        self._palette_timer.timeout.connect(self._flush_palette_preview)

    def _build_bars(self) -> None:
        """The toolbars, each registered with the modes it belongs to."""
        #: Which toolbars each editor mode puts up, swapped in one place --
        #: see shiny_mushroom.ui.toolbars. Bars register as they are built,
        #: and :meth:`_show_world_chrome` switches the whole set at once.
        self.toolbars = ModeToolbars()

        self.level_bar = LevelBar(self)
        self.level_bar.level_requested.connect(self._level_picked)
        self._name_levels()
        self.level_bar.editing_picked.connect(self.set_level_editing)
        # Nothing can be asked for until there is a cart to ask. The starting
        # state only, said as the bar is built and before there are menu
        # actions to go with it; from here on the answer is
        # :meth:`sync_level_rows`' alone.
        self.level_bar.setEnabled(False)
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, self.level_bar)
        self.toolbars.add(self.level_bar, {EditorMode.LEVEL})

        # The world map's own picker, taking the level bar's turn: each mode's
        # bar is up only while its mode is.
        self.world_bar = WorldBar(self)
        self.world_bar.submap_picked.connect(self._go_to_submap)
        self.world_bar.auto_select_picked.connect(self._world.set_auto_select)
        self.world_bar.palette_picked.connect(self._world.set_palette)
        # The panel shows the framed submap's colours, so it follows the pick.
        self.world_bar.palette_picked.connect(lambda _: self._show_palette())
        # The palette's tab is the one truth about the editing layer; the
        # bar's box is a second handle on it, kept saying the same thing.
        self.world_bar.layer_picked.connect(self._world_layer_picked)
        self.tile_palette.tab_changed.connect(self._world_layer_changed)
        self.tile_palette.sheet_edit_asked.connect(self._world_sheet_asked)
        # The Warps/Exits tab arms nothing: its rows reach a warp or path-exit
        # entry already on the map, so a pick is a selection rather than
        # something in hand.
        self.tile_palette.transfer_picked.connect(self._world.select_transfer)
        # A colour of the row being placed under, opened in the Palettes panel.
        self.tile_palette.colour_activated.connect(self.show_palette_offset)
        self.world_bar.event_picked.connect(self._world_event_picked)
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, self.world_bar)
        self.toolbars.add(self.world_bar, {EditorMode.WORLD})

        # Beside the level bar rather than inside it: a picture zooms whether or
        # not there is a cart behind it, and the level bar is switched off
        # whenever there is nothing to ask for.
        self.zoom_bar = ZoomBar(self.canvas.zoom, self)
        self.zoom_bar.zoom_requested.connect(self.view.set_zoom)
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, self.zoom_bar)
        self.toolbars.add(self.zoom_bar)  # every mode's: a picture always zooms

        # At the bottom, where a search bar belongs and where it is furthest
        # from the level picker: the two both move the canvas somewhere else,
        # and having them adjacent would make the wrong one easy to reach for.
        self.find_bar = FindBar(self)
        self.find_bar.jump_requested.connect(self.jump_to)
        self.addToolBar(Qt.ToolBarArea.BottomToolBarArea, self.find_bar)
        # Greyed rather than hidden outside the level: its visibility is the
        # user's -- put down from the toolbar menu, brought back by Ctrl+F --
        # so the mode must not write it.
        self.toolbars.add(self.find_bar, {EditorMode.LEVEL}, hides=False)

    def _build_status_bar(self) -> None:
        """The permanent status widgets, and the dialog for a first load."""
        self._position_label = QLabel()
        # What the cursor is over, when that is a sprite. A marker can say
        # "something is here" but not what, and at 1x there is no room to write
        # it into the picture.
        self._sprite_label = QLabel()
        # Shown only while a load that replaces the level is in flight, and
        # indeterminate because there is nothing to report a fraction of: the
        # emulator runs the cart's own loader and either finishes or does not.
        # It sits beside the "Loading level $XXX..." message rather than
        # replacing it, so the bar says *that something is happening* and the
        # message says what.
        self._loading_bar = QProgressBar()
        self._loading_bar.setRange(0, 0)
        self._loading_bar.setTextVisible(False)
        self._loading_bar.setMaximumWidth(BUSY_BAR_WIDTH)
        self._loading_bar.hide()
        # Permanent, so a transient message (the byte count after a load) slides
        # in beside them rather than replacing them.
        self.statusBar().addPermanentWidget(self._loading_bar)
        self.statusBar().addPermanentWidget(self._sprite_label)
        self.statusBar().addPermanentWidget(self._position_label)

        # The other half of the same story, for the one load the bar is not
        # enough for: a cartridge's first level, which is seconds of booting and
        # probing rather than the fifth of a second a switch costs. Built here
        # and shown when there is one, so there is one dialog for the window's
        # life rather than one per load. See shiny_mushroom.ui.loading.
        self._loading_dialog = LevelLoadingDialog(self)

    def _build_menus(self) -> None:
        """The menus, the view bars made out of them, and the starting state.

        Last, because every row is wired to a widget or an option above."""
        #: The menu rows that have to be kept in step afterwards, built by
        #: :func:`shiny_mushroom.ui.menus.build`. Last, because every one of them
        #: is wired to a widget or an option above.
        #:
        #: Not ``actions``, which is ``QWidget``'s own method for the actions
        #: added to a widget: an attribute of that name would shadow it, and the
        #: next caller of ``window.actions()`` would get a ``TypeError`` out of
        #: something that reads as ordinary Qt.
        self.menu_actions = menus.build(self)

        # The View toggles again, as square buttons beside the zoom -- the very
        # action objects the menu holds, so a button and its row check and grey
        # out together with nothing to sync. After the menus, because they are
        # made of them: one bar per mode, swapped with the rest of the chrome.
        self.view_bar = ViewBar(
            self.menu_actions, LEVEL_BUTTONS, "View", "view-bar", self
        )
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, self.view_bar)
        self.toolbars.add(self.view_bar, {EditorMode.LEVEL})
        self.world_view_bar = ViewBar(
            self.menu_actions, WORLD_BUTTONS, "Map View", "world-view-bar", self
        )
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, self.world_view_bar)
        self.toolbars.add(self.world_view_bar, {EditorMode.WORLD})
        # Every bar is registered: put up the starting mode's arrangement.
        self.toolbars.enter(self._mode)
        # Two of them start out asking a question nothing has answered yet: what
        # there is to undo, and whether the trail goes anywhere.
        self.sync_edit_actions()
        self.sync_go_menu()
        # The view starts focused rather than the first focusable widget on the
        # toolbars, which would be the zoom box - where the keyboard is not much
        # use and space steps the value. Not what makes hold-space-to-pan work:
        # the view takes space back off whichever widget holds the keyboard
        # whenever the pointer is over the picture.
        self.view.setFocus()
        self._restore_geometry()
        self._show_zoom(self.canvas.zoom)
        self._update_title()

    # -- what there is to do -------------------------------------------------
    #
    # An action is a keyboard shortcut as well as a menu row, and a disabled
    # action's shortcut is a dead key -- so what a row can act on is answered as
    # the answer changes, not when the menu opens. The other two of these live
    # with their subject: `sync_go_menu` with the trail, `sync_project_menu`
    # with the project.

    def sync_level_rows(self) -> None:
        """Arm what acts on the level on the canvas.

        Four menu rows and the level bar, from the three facts that decide
        them: which mode holds the canvas, whether a level is held, and whether
        a load is in flight. One function because three places used to answer
        it and did not agree -- a level arriving armed the rows whatever the
        mode was, which is the level's chrome over a canvas the world map
        still owns.

        The bar is the busy indicator as well as the picker, which is why the
        load is one of the three: it goes off for a load's duration and comes
        back with the picture or with the failure.

        Test is deliberately not asked the mode question. It follows the mode
        the way Save does -- same row, same key, testing whatever is being
        edited -- so what it needs is a cartridge with a level in it, which is
        what a map run carries too.
        """
        rows = self.menu_actions
        level_mode = self._mode is not EditorMode.WORLD
        holding = level_mode and self._doc is not None
        rows.header.setEnabled(holding)
        rows.graphics_row.setEnabled(holding)
        rows.exits.setEnabled(holding)
        rows.test.setEnabled(self._doc is not None)
        self.level_bar.setEnabled(
            level_mode and self._path is not None and not self._loading
        )

    def sync_edit_actions(self) -> None:
        """Grey out what there is nothing to do.

        **Called whenever the document or the selection moves, not only when the
        menu opens.** These actions carry the keys as well as the menu rows, and
        a disabled action's shortcut is a dead key -- so an undo action left
        stale is Ctrl+Z doing nothing until the Edit menu has been opened once,
        which is exactly what it looked like. Two call sites cover every way the
        answer can change: :meth:`_settle` for the document and :meth:`_select`
        for the selection, plus the two places a level arrives and leaves.
        """
        rows = self.menu_actions
        surface = self._edit_surface()
        # Re-run on every mode switch as well, or Ctrl+Z is a dead key -- the
        # same trap the docstring above names.
        rows.undo.setEnabled(surface.can_undo)
        rows.redo.setEnabled(surface.can_redo)
        # Three rows asking one question: is anything held. Written once,
        # because three copies of `setEnabled` is three chances for one of them
        # to be left out when a fourth is added.
        for row in (rows.cut, rows.copy, rows.delete):
            row.setEnabled(surface.can_copy)
        for row in (rows.forward, rows.back, rows.duplicate):
            row.setEnabled(surface.can_order)
        # Paste asks the clipboard rather than the selection, and somewhere to
        # put it: what was copied outlives both the selection it came from and
        # the level it came out of.
        rows.paste.setEnabled(surface.can_paste)

    def _edit_surface(self) -> _EditSurface:
        """What the Edit rows act on, from the mode the window is in.

        The one place the three-way choice is made -- see
        :class:`_EditSurface` for why it is worth having only one.
        """
        if self._editing_palettes():
            # The palettes are a document of their own, and the panel showing
            # them is where Edit acts while it has the focus. Not by *mode*
            # like the three below, because the colours are the game's rather
            # than any one level's: they are editable in both modes, and an
            # undo that took back a colour because the canvas happened to be
            # showing a level would be routed by the wrong question.
            history = self._palette_history
            return _EditSurface(
                walk=self._walk_palette,
                # A colour is not a record and not a tile. There is nothing to
                # take a copy of, and nothing a paste could mean.
                copy=lambda: None,
                cut=lambda: None,
                delete=lambda: None,
                paste=lambda: None,
                commit_field=lambda key, value: None,
                can_undo=history.can_undo,
                can_redo=history.can_redo,
                can_copy=False,
                can_paste=False,
                can_order=False,
            )
        if self._mode is EditorMode.WORLD:
            world = self._world
            history = world.history
            return _EditSurface(
                walk=self._walk_world,
                copy=world.copy_selection,
                cut=world.cut_selection,
                delete=world.delete_selection,
                paste=world.paste,
                commit_field=world.commit_field,
                can_undo=history is not None and history.can_undo,
                can_redo=history is not None and history.can_redo,
                can_copy=world.can_copy,
                can_paste=world.can_paste,
                can_order=False,
            )
        history = self._history
        if self._painting:
            return _EditSurface(
                walk=self._walk_history,
                copy=self._bg_copy,
                cut=self._bg_cut,
                delete=self._bg_delete,
                paste=self._bg_paste,
                # Painting selects blocks, not records, and the panel
                # describes records: there is no field to commit.
                commit_field=lambda key, value: None,
                can_undo=history is not None and history.can_undo,
                can_redo=history is not None and history.can_redo,
                can_copy=bool(self._bg_selection),
                can_paste=self._bg_clipboard is not None
                and self._background_editable(),
                can_order=False,
            )
        held = bool(self._selection)
        return _EditSurface(
            walk=self._walk_history,
            copy=self._copy_records,
            cut=self._cut_records,
            delete=self._delete_records,
            paste=self._paste_records,
            commit_field=self._commit_record_field,
            can_undo=history is not None and history.can_undo,
            can_redo=history is not None and history.can_redo,
            can_copy=held,
            can_paste=self._doc is not None and bool(self._clipboard),
            can_order=held,
        )

    # -- what the canvas shows ----------------------------------------------

    def _base_caveat(self) -> str:
        """What this base cannot show, as a clause to append to a message.

        A base whose player capture is declared off draws no marker, and says
        so here: someone who cannot find Mario should not have to guess whether
        the editor lost him or the level did. No base in the registry declares
        that today -- a base that hands the game's routines to a coprocessor
        renders its levels, its sprites and its player exactly as the default
        base does -- so this is what the next one that cannot would say, and
        the clause is empty until there is one. See
        :class:`~smw_tools.bases.DrivenPaths`.
        """
        if self._addresses.driven.player_art:
            return ""
        return " - the player marker is not drawn on this base"

    @property
    def _addressable(self) -> bool:
        """Whether the image in hand is a cartridge these offsets mean anything
        in.

        Everything the window reads out of a ROM is reached through the base's
        pointer tables, and the first of them is the Layer 1 table -- so an image
        too short to hold it is not a cartridge this file can follow. A byte map
        is one such image and so is the stub the suite's loader hands back, and
        the honest answer for both is to make no patches rather than to read off
        the end of a short file.

        Asked in the three places that build cartridge patches -- a test run, a
        project's saved level, and the catalogue probe -- and asked here rather
        than three times over, because the three had drifted into three
        different explanations of one rule.
        """
        return cart_patches.addressable(self._rom, self._addresses)

    def _secondary_header_bytes(self, level: int) -> bytes:
        """``level``'s four secondary-header bytes, for the document.

        The project's rows first -- they carry what has been saved, which the
        session's ROM image predates -- and the image where there is no
        project or its fragment cannot be read. Empty only when neither can
        answer, which no document operation minds.
        """
        if self._project is not None:
            try:
                return self._project.secondary_header(level)
            except (AsmRegionError, ProjectError, OSError):
                pass
        if self._rom is not None and self._addressable:
            return secondary_header_bytes(self._rom, level, where=self._addresses)
        return b""

    def _level_graphics_bytes(self, level: int) -> bytes:
        """``level``'s own graphics row, for the document.

        The project's saved row first -- the level's container's -- and the
        project's *answer* whenever there is one: its empty is a level with
        no row, and the image's own row is then one a build carried before
        the row was set back. The image is asked only without a project, or
        where the container cannot be read; empty when neither can say.
        """
        if self._project is not None:
            try:
                return self._project.level_graphics_record(level)
            except (ProjectError, OSError):
                pass
        if self._rom is not None and self._addressable:
            try:
                return level_graphics_row(self._rom, level, where=self._addresses)
            except ValueError:
                return b""
        return b""

    def _use_base(self, path: Path | None) -> None:
        """Take the ROM base and target ``path`` was built on, or the defaults.

        A project records the base its overlay is written against, and its
        cartridge is assembled from that base -- so the pointer tables, the
        secondary header and the routines a rebuild is driven through are all
        that base's. The target rides along because version conditionals move
        tables: a ``J`` project's bank 4 sits two bytes on from ``U``'s.
        Anything else, including a cartridge opened by hand while a project
        happens to be open, is read through the default base and target: it is
        the five shipped releases' base, and a file the editor did not
        assemble has no better claim than that.
        """
        project = self._project
        ours = (
            project is not None
            and path is not None
            and _same_file(path, rom_path(project))
        )
        self._base_id = project.base_id if ours and project else None
        self._target_id = project.target_id if ours and project else None
        # The project cartridge's own answers, where its build wrote a symbol
        # file -- the record of where *that* build put each table, which is
        # what stays right when a patch moves one. Anything else reads through
        # the base's declarations, as before. A symbol file that does not
        # describe this base's build is refused by the resolver; the
        # declarations are the honest remainder, and the person is told.
        self._role_addresses = None
        self._role_counts = None
        # And what that build put *in* the cartridge beyond the stock game:
        # its own record, not the patch manifest -- a patch enabled since is a
        # claim about the next build, and this one is reading this ROM.
        self._features = project.features if ours and project else ()
        if ours and project:
            try:
                self._role_addresses = role_addresses(project)
                self._role_counts = role_counts(project)
            except BuildError as error:
                self.statusBar().showMessage(str(error), 8000)
        try:
            self._addresses = Addresses.for_base(
                self._base_id,
                self._target_id,
                self._role_addresses,
                self._features,
                self._role_counts,
            )
        except FeatureError as error:
            # A cartridge claiming a capability this build has no declaration
            # for is read as the stock base rather than not at all: every
            # unmoved table still answers, which is most of them, and the one
            # thing that must not happen is a silent read through the wrong
            # ones. So it is said, and the features are dropped.
            self._features = ()
            self._addresses = Addresses.for_base(
                self._base_id,
                self._target_id,
                self._role_addresses,
                counts=self._role_counts,
            )
            self.statusBar().showMessage(
                f"{error} -- reading this cartridge as a stock {self._base_id}", 8000
            )
        # And how many entries each of the world map's tables holds on it,
        # which every part of the document is read and written against -- a
        # cartridge whose feature grew one has more rows to edit, and one
        # whose last save grew a growable table holds what its build
        # measured -- and this is what carries that from the capture through
        # to the fragment a save emits.
        self._map_shape = MapShape.of(
            applied(rom_base(self._base_id), self._features)
            if self._features
            else None,
            self._role_counts,
        )

    def load_file(self, path: Path) -> None:
        """Read ``path`` and render it onto the canvas.

        The one way a cartridge reaches the canvas: the project's own build
        when one is opened, or a path handed in on the command line.
        """
        try:
            size = path.stat().st_size
            if size > MAX_FILE_BYTES:
                self._alert(
                    f"{path.name} is {size / 1024 / 1024:.1f} MB, over the "
                    f"{MAX_FILE_BYTES // 1024 // 1024} MB limit."
                )
                return
            data = path.read_bytes()
        except OSError as error:
            # strerror, not the exception: the filename is already in the
            # message, and repeating the whole repr reads as a crash report.
            self._alert(f"Could not read {path.name}.", detail=error.strerror or "")
            return
        self._close_play()
        self._release_loader()
        outgoing, self._path = self._path, path
        self._world_runs = None
        # Before anything reads the image: every offset below is resolved
        # through this.
        self._use_base(path)
        # Headerless, because that is the numbering every offset in
        # shiny_mushroom.emu.smw uses and what the emulator's own copy holds. The
        # byte map above is drawn from the file as it is.
        self._rom = headerless(data)
        # What this cartridge's own colours are, which is what a capture's CGRAM
        # will have come from -- and not always what the project has saved.
        self._read_rom_palette()
        # And where a screen exit marked Secondary entrance lands, which is a
        # table of the cartridge's however it was opened.
        self._read_entrances()
        self._remeasure_palette()
        self._level = None
        self._forget_level()
        # The world map is the outgoing cartridge's too, and the new one has
        # its own; the mode's action arms below, once there is a cart to ask.
        self._forget_overworld()
        # And where you have been, when what is opening is a *different*
        # cartridge: a project switch comes through here rather than through
        # `close_file`, and level $105 of the next cart is somewhere else
        # entirely. The same file reopened is the same cartridge -- a rebuild
        # lands right back here -- so that trail is still of places in it.
        if outgoing is not None and not _same_file(outgoing, path):
            self._trail.clear()
            # And what was copied out of it, for the reason `close_file`
            # gives at length: an object number is whatever the *cartridge's*
            # tables say it is, and a record pasted into a different cart
            # would come out as whatever that one's say. Only a different
            # cart, so a copy survives the rebuild a Test Level does.
            self._clipboard = ()
            self._clipboard_tileset = None
            self._bg_clipboard = None
        # Every object and sprite in the cartridge, before a single level is
        # loaded. Synchronous because it is cheap enough to be: no emulator is
        # involved, and all 512 levels are walked in well under a tenth of a
        # second - see shiny_mushroom.index. A file that is not a cartridge
        # indexes to nothing rather than failing, which is what lets this sit in
        # the path that also opens one as a byte map.
        self._index = build_index(self._rom, where=self._addresses)
        self.find_bar.set_index(self._index)
        self.canvas.set_image(bytes_to_image(data))
        self.menu_actions.world_map.setEnabled(True)
        self.menu_actions.load_path.setEnabled(True)
        self.sync_level_rows()
        self._update_title()
        self.statusBar().showMessage(f"{len(data):,} bytes", 5000)
        # And straight into a level. The byte map above is what the file *is*,
        # which is worth a glance and is not what the editor is for; opening a
        # cart and then having to ask for a level is a step nobody wants twice.
        # The picture stands until the load arrives a couple of seconds later.
        self.load_level(self.level_bar.level)

    def close_file(self) -> None:
        """Clear the canvas, asking about the level in hand first."""
        if not self._may_discard():
            return
        self._close_play()
        self._release_loader()
        self._path = None
        self._use_base(None)
        self._rom = None
        self._level = None
        # The colours the closing cartridge was wearing, and where the capture's
        # came from. The document stays -- it belongs to the project.
        self._rom_palette = None
        self._palette_over_rom = {}
        self._palette_over_capture = {}
        self._capture_palette = None
        self._captured_cgram = None
        self._captured_level = None
        self._captured_header = None
        self._previewed_header = None
        self._provenance = None
        self._backdrop_offset = None
        self._world_captured = ()
        self._world_provenance = []
        self._show_palette()
        # The clipboard holds records out of that cart's vocabulary. It outlives
        # a level change deliberately -- copying out of one level and into
        # another is the point of having one -- but an object number is whatever
        # the *cartridge's* tables say it is, and the next one may not say the
        # same thing. Cleared before the level is forgotten, which is what greys
        # Paste out: that is where the edit actions are put back in step.
        self._clipboard = ()
        self._clipboard_tileset = None
        # The pattern clipboard's bytes read through the cart's own Map16
        # page, so it goes down with the cart for the record clipboard's
        # reason.
        self._bg_clipboard = None
        self._forget_level()
        self._forget_overworld()
        # The index belongs to the cartridge, not to the level: searching a
        # closed ROM would offer to jump into a file nobody has open.
        self._index = LevelIndex()
        self.find_bar.set_index(self._index)
        # The trail is of places in *that* cart; level $105 of the next one is
        # somewhere else entirely.
        self._trail.clear()
        self.canvas.set_image(bytes_to_image(b""))
        self.menu_actions.load_path.setEnabled(False)
        self._close_load_path()
        self._level_exits.close()
        self.sync_level_rows()
        self._update_title()

    def export_rom(self, *, with_header: bool = False) -> None:
        """Build the open project's cartridge and write a copy of it elsewhere.

        The build comes first, and it is the ordinary one -- assembling is
        skipped when nothing has moved since last time, so exporting work that
        has already been built is the file chooser and a copy. What lands is
        exactly the cartridge the editor edits and Test Level runs; there is no
        second build path for an export to disagree with.

        ``with_header`` puts the 512-byte copier header on the front, which is
        what some emulators, patchers and flash carts still expect. Nothing
        else differs between the two, which is why this is one method behind
        two menu rows.
        """
        project = self._project
        if project is None or not project.buildable:
            self._alert(
                "There is no project to export.",
                detail="An export is a copy of a project's built cartridge; "
                "Project > New Project makes one.",
            )
            return
        if not self._may_export():
            return
        if BuildDialog.run(project, self) is None:
            # Nothing to add: the dialog stays up with asar's complaint on it,
            # which is the only thing that says why there is no cartridge.
            return
        try:
            # Normalised on the way in, so the two branches below differ by
            # exactly the header: a build writes a headerless image, and an
            # export that assumed so would be wrong the day one does not.
            image = headerless(rom_path(project).read_bytes())
        except OSError as error:
            self._alert(
                "The built cartridge could not be read.",
                detail=error.strerror or str(error),
            )
            return
        # `.smc` for the headered spelling and `.sfc` for the plain one: it is
        # what the header meant when the two extensions were copier formats,
        # and what every emulator's file chooser is still written to expect.
        suffix = ".smc" if with_header else ".sfc"
        folder = load_str_setting(EXPORT_KEY) or str(Path.home())
        chosen, _ = QFileDialog.getSaveFileName(
            self,
            f"{APP_NAME} - Export {'Headered ' if with_header else ''}ROM",
            str(Path(folder) / f"{project.name}{suffix}"),
            CART_FILTER,
        )
        if not chosen:
            return
        destination = Path(chosen)
        # A name typed without one. The filter offers both extensions, so which
        # was meant is this row's answer rather than the chooser's.
        if not destination.suffix:
            destination = destination.with_suffix(suffix)
        written = headered(image) if with_header else image
        try:
            destination.write_bytes(written)
        except OSError as error:
            self._alert(
                f"Could not write {destination.name}.",
                detail=error.strerror or str(error),
            )
            return
        # Only once it has landed: a folder that could not be written to is not
        # the one to offer first next time.
        save_str_setting(EXPORT_KEY, str(destination.parent))
        self.statusBar().showMessage(
            f"Exported {destination.name} - {len(written):,} bytes", 5000
        )

    # -- levels ---------------------------------------------------------------

    def _level_picked(self, level: int) -> None:
        """The picker asked for a level: the one in hand goes, so ask about it.

        Cancelling puts the picker back on the level actually held. It shows
        what the canvas shows, and leaving it naming a level that was never
        loaded would make the next Previous or Next step from the wrong place.
        """
        if self._may_replace(level):
            self.load_level(level)
        elif self._level is not None:
            self.level_bar.set_level(self._level)

    def open_level_from_map(self, level: int) -> None:
        """Leave the world map and open ``level``, as the map's own buttons
        ask for it -- the cell panel's Open Level and the load path's.

        The load paints the level's canvas, so the map goes down first,
        through the same gate a level switch asks. Either question may
        refuse: the unsaved-level one here, and the unsaved-map one inside
        :meth:`_leave_world`, which puts the menu row back up -- and the
        level below would then load under a canvas the map still holds.
        """
        if not self._may_replace(level):
            return
        self.menu_actions.world_map.setChecked(False)
        self._leave_world()
        if self._mode is EditorMode.WORLD:
            return
        self.load_level(level)

    def load_level(
        self,
        level: int,
        patches: dict[int, bytes] | None = None,
        refreshing: bool = False,
    ) -> None:
        """Ask the emulator for ``level`` and show it when it arrives.

        Returns immediately. The work happens on the loader's thread and comes
        back to :meth:`_show_level` or :meth:`_level_failed`; until then the
        level bar is disabled, which both says "busy" and keeps a second
        request out of the queue while the first is still running.

        **This does not ask about unsaved work**: a load that replaces the
        document is what the gesture already decided on, and the gesture is
        where :meth:`_may_replace` is answered.
        """
        if self._path is None:
            return
        # Note where we were looking before leaving, so that coming back the
        # other way returns to the view rather than to the level's own opening
        # position. Harmless when the load *is* the trail's own doing: it is
        # about to overwrite the entry anyway.
        # Asked of the *argument* rather than of the flag, which is what makes
        # the flag safe to hold at all: a refresh that never came back -- a
        # failed load, an emulator that died -- would otherwise leave it set, and
        # the next real load would keep the document of a different level.
        if self._snapshot is not None and not refreshing:
            self._note_where_we_are_looking()
        # Asked before the loader is built, because building it *is* the boot:
        # the worker starts and runs the cart to the title screen, which is what
        # makes this load seconds rather than a fifth of a second, and the wait
        # is worth naming for the person watching it.
        booting = self._loader is None
        if self._loader is None:
            self._loader = LevelLoader(
                self._path,
                self._base_id,
                self._target_id,
                self._role_addresses,
                self._features,
                role_counts=self._role_counts,
            )
            self._loader.loaded.connect(self._show_level)
            self._loader.player_art_ready.connect(self._hold_player_art)
            self._loader.failed.connect(self._level_failed)
            self._loader.overworld_loaded.connect(self._show_overworld)
            self.level_requested.connect(self._loader.load)
            self.player_art_requested.connect(self._loader.player_art)
            self.overworld_requested.connect(self._loader.load_overworld)
            # The catalogue talks to the same loader on its own two signals --
            # wired here rather than by it, because the loader does not exist
            # until a cartridge does and this is where it is built.
            self._loader.catalog_probed.connect(self._catalog.probed)
            self._loader.sprite_art_ready.connect(self._catalog.sprite_art)
            self._catalog.catalog_requested.connect(self._loader.probe_catalog)
            self._catalog.sprite_art_requested.connect(self._loader.probe_sprite_art)
        # A load nobody handed patches to still gets the project's, if there is
        # one: a level the project has saved has to come back as *that* level
        # rather than as the cartridge's.
        if patches is None:
            was, self._level = self._level, level
            patches = self._project_patches()
            self._level = was
        # The first request also starts the worker and boots the cart, which is
        # seconds rather than milliseconds - long enough that saying nothing
        # looks like nothing happened.
        self.statusBar().showMessage(f"Loading level {hexnum(level, 3)}...")
        # Set here, where the request is made, so every load says which kind it
        # is rather than inheriting whatever the last one left behind. The
        # palette goes the same way and for the same reason: the capture that
        # comes back has to be read against the colours *this* load booted.
        self._refreshing = refreshing
        self._capture_palette = self._palette_under(patches)
        self._loading = True
        self._refresh_pending = False
        # Which puts the bar out of reach for the load's duration: it is the
        # busy indicator as well as the picker.
        self.sync_level_rows()
        self._lock_for_load(level, replacing=not refreshing, booting=booting)
        self.level_requested.emit(level, patches)

    def _reload_the_canvas_level(self, *, ask: bool = False) -> None:
        """Build the level on the canvas again, from a load made under the
        project as it now stands.

        What every project-tree edit that changes what a level *number means*
        ends with -- a graphics file moved, a level file reverted or restored,
        a label moved, a stream repointed. The document in hand was parsed out
        of bytes the number no longer reads, so it has to be parsed again.

        One place because four sites had written their own two lines and the
        lines had drifted apart. **The unsaved-work question belongs at the
        gesture**, before the files move: asked here it would come too late to
        act on, since a refusal would leave the canvas describing bytes that
        are already gone. ``ask`` is for the one caller whose gesture is in
        another window and cannot ask -- :meth:`_graphics_changed`, where a
        refusal costs only the reload.

        **The mode question is not asked here at all.** The document is rebuilt
        whichever mode holds the canvas; the picture and the chrome wait for
        the level to have the canvas back, which is :meth:`_show_level`'s.
        """
        if self._level is None:
            return
        if ask and not self._may_replace(self._level):
            return
        self.load_level(self._level)

    def _lock_for_load(self, level: int, replacing: bool, booting: bool) -> None:
        """Put the level out of reach while a load that will replace it runs.

        **Only for a load that replaces the document.** Between asking for a
        level and the picture arriving, the document is still the *outgoing*
        level's -- so a drag in that gap moves a record in a level that is on
        its way out, pushes it onto an undo stack about to be thrown away, and
        loses the edit without saying anything. Measured: a drag during a level
        switch moved an object three blocks, and the arriving level came back
        with the object where it started and nothing to undo.

        A **refresh** is the opposite case and must stay live. It brings back a
        picture of the level already held, keeps the document, the selection and
        the undo stack, and costs ~60 ms. That is short, and it is also *every
        edit* -- a held arrow key asks for one per repeat -- so locking it would
        flicker the window out of reach continuously while a level is worked on.

        The bar is **indeterminate**, because there is no progress to report: the
        emulator runs the cart's own loader and either finishes or does not, and
        a bar that crept along on a timer would be an invention.

        **And a modal over it**, because the bar and the disabled view are not
        enough on their own. Neither reaches the keyboard: the shortcuts that act
        on the level are watched for on the *application*, so an arrow key, a
        Delete or an edit typed into the properties panel arrives whatever the
        canvas is doing, and :meth:`_commit` refuses it. Modal is the only shape
        that stops the key being delivered at all.

        **Every replacing load takes it up, not only the slow one.** A
        cartridge's first level is seconds -- the worker starts, the cart boots to
        the title screen, the level loads, and the probe that captures the player
        runs behind it -- and a switch is nearer a fifth of a second. The
        difference is how long the window is out of reach, not whether an edit
        made in that window is dropped. What differs is what it says: ``booting``
        picks the line, so a switch does not claim to be starting an emulator
        that is already running.

        **From the moment the load is asked for**, with no wait first. Holding it
        back until a load has run long -- ``QProgressDialog``'s economy -- would
        keep a fast switch from flashing one up, at the price of a window at the
        start of every load in which the keyboard reaches an editor that will
        refuse it. That window is the defect; the flash is not.

        A refresh, again, gets none of it.
        """
        self._lock(
            partial(self._loading_dialog.begin, level, booting=booting)
            if replacing
            else None
        )

    def _lock(self, begin: Callable[[], None] | None) -> None:
        """Put the level out of reach, or leave it alone.

        The lock itself is one thing whatever is being loaded --
        :meth:`_lock_for_load` says what it is for -- and ``begin`` is the only
        part that differs: it opens the modal with the line for this kind of
        load. ``None`` is the refresh, which takes none of it.
        """
        replacing = begin is not None
        self._replacing = replacing
        self.view.setEnabled(not replacing)
        self._loading_bar.setVisible(replacing)
        if begin is not None:
            begin()

    def _unlock_after_load(self) -> None:
        """Give the level back, once every part of the load has landed.

        Called from the reply, from the player's artwork arriving behind it, and
        from the failure -- a lock that outlived a failed load would leave the
        editor unusable with no way back short of restarting it.

        **The picture arriving is not the load ending on a cartridge's first
        level.** The probe that captures the player is a second round trip behind
        it, and until it lands the level has no spawn marker: the editor looks
        open, and an edit made against it is refused. So the lock is held across
        both and the dialog says which half it is on; every later load has no
        probe to wait for and ends here.
        """
        if self._awaiting_player_art:
            self._loading_dialog.report(CAPTURING)
            return
        self._replacing = False
        self.view.setEnabled(True)
        self._loading_bar.setVisible(False)
        self._loading_dialog.finish()
        # The cartridge is open and whoever is looking at it is free to press
        # Test Level, which is why the emulator that answers one is booted
        # here rather than then -- see `ready_play_session`. Last, so the boot
        # is behind a window nobody is waiting on, and only over a level that
        # arrived: `_forget_level` unlocks through here too, and it is on its
        # way *out* of a cartridge rather than into one.
        if self._snapshot is not None:
            self.ready_play_session()

    def _show_level(self, snapshot: LevelSnapshot) -> None:
        # A load asked for by an *edit* brings back the picture of a level the
        # editor already holds, so the document it built survives -- along with
        # the selection and the undo stack, which are the whole reason the reload
        # cannot be allowed to look like opening a level.
        refreshing, self._refreshing = self._refreshing, False
        self._loading = False
        # Once a cartridge, and only now that a level is up: the probe runs the
        # game to draw him, so it needs one. Asked for *before* the unlock and
        # waited for by it -- the level is not finished opening until the marker
        # is on it, and the gap between the two is a window where the editor
        # looks ready and an edit is refused. A level whose player could not be
        # captured is a level without a marker rather than a failure, and comes
        # back as ``None`` so this is never left waiting.
        if not refreshing and not self._player_art_asked:
            self._player_art_asked = True
            self._awaiting_player_art = True
            self.player_art_requested.emit()
        self._unlock_after_load()
        previous = self._snapshot if refreshing else None
        if previous is not None and previous.header == snapshot.header:
            # **Keep the graphics the level already had.** An object or sprite
            # edit cannot change them -- VRAM and CGRAM come from the header's
            # tileset -- but a reload comes back with the animated tiles on
            # whatever phase the run happened to stop on, which is a different
            # picture for reasons that have nothing to do with the edit.
            # Measured on level $105, reloading it *unchanged* moved 35 tiles
            # and a palette row, which is 29 blocks of the picture; on $0C2 it
            # is 13% of it. Pinning them stops a drag re-phasing the level's
            # animation under the cursor, and is what leaves the tilemap as the
            # only thing an edit can have changed -- so the diff below is a
            # comparison of two tilemaps rather than of two pictures.
            #
            # Guarded on the header, because a header edit is exactly the case
            # where the tileset *has* changed and the new graphics are the point.
            #
            # The spawn comes along for a related reason: a rebuilt level skips
            # the settling frame, so the player is where the loader put him
            # rather than a frame later, and on a level where he starts falling
            # that is a pixel or two apart. Neither is wrong; drifting between
            # them as you drag is.
            # The camera and Layer 3's scroll are here for the same reason
            # as the spawn, and they matter more: `changed_blocks` reads any of
            # them moving as "something the whole picture is drawn from
            # changed" and falls back to a full render, so leaving them
            # unpinned costs 40 ms of rendering on every other refresh rather
            # than a pixel of marker.
            #
            # What all five have in common is that they describe where the
            # level currently *is*, not what is in it -- and a rebuild does not
            # run a frame of the game, so it cannot advance them the way a full
            # load's settling frame does.
            snapshot = replace(
                snapshot,
                vram=previous.vram,
                # The capture's own colours, not the snapshot's: from the
                # moment a colour is edited the held snapshot wears the
                # recoloured CGRAM, and pinning that would make an undo of the
                # edit have nothing to put back.
                cgram=self._captured_cgram
                if self._captured_cgram is not None
                else previous.cgram,
                spawn=previous.spawn,
                camera_x=previous.camera_x,
                camera_y=previous.camera_y,
                layer3_x=previous.layer3_x,
                layer3_y=previous.layer3_y,
            )
        if (
            refreshing
            and self._doc is not None
            and self._doc.layer2
            and snapshot.layer2_background
            and snapshot.layer2_low != self._doc.layer2
        ):
            # The document's background wins over the reload's. A refresh
            # carries the edit as a ROM patch when the re-encoding fits its
            # slot -- see `_level_document_patch` -- and this is the case
            # where it could not: the game redecoded the cartridge's own
            # stream, and letting that revert the picture would undo an edit
            # that still stands.
            snapshot = replace(snapshot, layer2_low=self._doc.layer2)
        # Where each of this level's colours came from, and the level as the
        # palette document has it -- so a saved or held colour edit is on screen
        # without the emulator being asked again. See :meth:`_palette_changed`.
        self._read_provenance(snapshot)
        snapshot = self._recoloured(snapshot)
        self._snapshot = snapshot
        # The panel shows the colours of whatever is on the canvas.
        self._show_palette()
        # And the Map16 editor draws its sheet in the level's own graphics.
        if self._map16 is not None and self._map16.isVisible():
            self._map16.show_snapshot(snapshot)
        # **Which level this is, before anything reads the snapshot.** Everything
        # keyed by level number -- the test start the marker is drawn at, the
        # catalogue's idea of what it is describing -- is asked for during the
        # read below, and taking the number afterwards meant every one of them
        # answered for the level being left. Measured: with a test start set in
        # one level, opening another drew the marker at the first level's spot.
        self._level = snapshot.level
        self._read_level(keep_document=refreshing, previous=previous)
        if refreshing:
            # Whatever the document became while this one was out. One load, not
            # one per edit: the picture nobody waited for is not worth drawing.
            if self._refresh_pending:
                self._refresh_pending = False
                self._refresh_picture()
            return
        if self._mode is EditorMode.WORLD:
            # **The canvas is the map's, so the level does not take it.** Every
            # deliberate level switch is refused over the map at the gesture,
            # but the windows that stay open over it reload the level as a
            # side effect of an edit -- Project > Graphics Files and Project >
            # Level Data both do -- and the load itself has no gesture to be
            # refused at. The document is built and the rows are armed for the
            # mode; the picture and the view are settled on the way back, which
            # is what :attr:`_level_stale` says to :meth:`_leave_world`.
            self._level_stale = True
            self.level_bar.set_level(snapshot.level)
            self._update_title()
            self._refresh_load_path()
            return
        self.view.set_zoom(min(self.canvas.zoom, LEVEL_ZOOM))
        self.level_bar.set_level(snapshot.level)
        self._update_title()
        # Where you have been. After the zoom is settled, because a place is
        # noted as the block in the middle of the viewport and that depends on
        # how much of the level fits in it.
        self._arrive(snapshot.level)
        drawn = sum(1 for sprite in self._sprites if sprite.kind is SpriteKind.SPRITE)
        # Said only where it is true, which is twenty-six level numbers: a
        # "0 on Layer 2" on every other level would read as a layer that is
        # there and empty rather than as one the level does not have.
        layer2 = (
            f" ({len(self._doc.layer2_objects)} on Layer 2)"
            if self._doc is not None and self._doc.layer2_records
            else ""
        )
        self.statusBar().showMessage(
            f"{self.canvas.image.width()}x{self.canvas.image.height()} pixels, "
            f"{len(self._doc.objects) if self._doc else 0} objects{layer2}, "
            f"{len(self._sprites)} sprites ({drawn} drawable), "
            f"loaded in {snapshot.duration * 1000:.0f} ms",
            5000,
        )
        # The load path window follows the open level.
        self._refresh_load_path()
        # Last, and after the zoom is settled: a jump has to scroll to where the
        # record is, and where that lands on screen depends on the zoom the
        # level opened at.
        self._serve_pending()
        self._serve_arrival()
        # Last of all, and only once the level is on the canvas: the catalogue's
        # thumbnails are worth a round trip but nobody is waiting on them, and
        # the loader answers in order.
        self._probe_catalog()

    def _hold_player_art(self, art: PlayerArt | None) -> None:
        """Keep the captured player, draw him, and finish opening the level.

        A repaint is enough for the drawing, unlike a marker that moves: nothing
        of his was in the picture before this arrived, so there is nothing to
        erase. It goes before the unlock so the marker is already on the level
        when the dialog comes down, rather than appearing a frame after it.

        ``art`` is **None when the probe brought nothing back**, and the level is
        handed over either way: a marker that could not be captured is a level
        without one, and an editor that stayed locked waiting for it would be a
        far worse answer than a missing figure.
        """
        if art is not None:
            self._player_art = art
            self._show_picture()
        self._awaiting_player_art = False
        self._unlock_after_load()

    def _test_start_for(self, level: int | None = None) -> PlayerPosition | None:
        """Where a test of ``level`` starts, or None to use its own entrance."""
        if level is None:
            level = self._level
        return None if level is None else self._test_start.get(level)

    def _player_at(self) -> PlayerPosition | None:
        """Where the player marker is.

        The override if there is one, and otherwise what the game itself worked
        out during the load. None when there is no level to stand in.

        Both are :class:`~shiny_mushroom.rom_patches.PlayerPosition`, which is what
        lets this have one return type at all: the override arrives from a click
        on a floor and the spawn from the game's own ``$0096``, and only the
        first of those needs converting.
        """
        if self._snapshot is None:
            return None
        override = self._test_start_for()
        return self._snapshot.spawn if override is None else override

    def _set_test_start(self, pos: QPoint) -> None:
        """Middle click: move the test start to the block under the cursor.

        Snapped to the block grid and to its floor, so the player stands on
        what was clicked rather than inside it -- a level is built out of these
        blocks, and a start that is repeatable is worth more here than one that
        is exact to the pixel.

        **This is the one place a floor is meant**, and so the one place that
        converts. A click says "his feet here"; everything downstream -- the
        marker, the entrance patch, the game -- means ``$0096``, which sits
        above them. :meth:`~shiny_mushroom.rom_patches.PlayerPosition.standing_on`
        is that conversion and the only way in.

        Middle-clicking the block he already stands on clears the override and
        puts him back at the level's own entrance, which is the only way back
        and is why it is the same gesture rather than a menu item.
        """
        if self._snapshot is None or self._level is None:
            return
        block_x = (pos.x() // BLOCK) * BLOCK
        floor_y = (pos.y() // BLOCK) * BLOCK + BLOCK
        start = PlayerPosition.standing_on(block_x, floor_y)
        if self._player_at() == start:
            self._test_start.pop(self._level, None)
            where = "the level's own entrance"
        else:
            self._test_start[self._level] = start
            where = hexspot(start.x, start.feet, 4)
        # A repaint, not a redraw. The marker has *moved*, which used to mean
        # drawing the level again -- the one buffer was written into and never
        # cleared, so painting him at the new place left him at the old one too.
        # `_show_picture` now composes from a clean copy every time, so his old
        # pixels were never in it.
        self._show_picture()
        self.statusBar().showMessage(f"Test start: {where}", 4000)

    # The level's two record streams, read out of the document. Properties
    # rather than fields because there is now exactly one place a record lives -
    # an edit rewrites both streams, and a second copy kept beside them would be
    # a chance for the picture and the document to disagree.

    @property
    def _objects(self) -> tuple[LevelObject, ...]:
        """The object stream a gesture is working -- Layer 1's, or Layer 2's
        while the Layer 2 mode is up over a level whose Layer 2 is a level.

        The one place the alternate pathway is chosen: what a click selects,
        what a marquee catches, what the outlines are drawn from and what the
        readout counts are all this list, so routing it here is what makes
        every record gesture reach Layer 2 without any of them knowing there
        is a second stream.
        """
        if self._doc is None:
            return ()
        return self._doc.layer2_objects if self._on_layer2 else self._doc.objects

    @property
    def _sprites(self) -> tuple[Sprite, ...]:
        return () if self._doc is None else self._doc.sprites

    def _read_level(
        self,
        keep_document: bool = False,
        previous: LevelSnapshot | None = None,
    ) -> None:
        """Re-read everything the held snapshot says, and redraw.

        Separate from :meth:`_show_level` because a header edit changes what the
        same snapshot means - the screen count is a header field, and the level
        is that many screens long - without a second emulator round trip.

        ``keep_document`` is what a reload *for an edit* passes. The snapshot
        that comes back is a picture of the level the editor already holds, so
        rebuilding the document from it would hand back the same records under
        different ids and throw away the undo stack -- an edit that undid its own
        history. What is re-read either way is everything derived from the
        picture, above all the footprints, whose offsets an edit has just moved.

        **The shape follows the document when the document is kept**, and the
        snapshot only when a level is being opened. They are the same answer:
        the picture was drawn from the header the document holds, patched into
        the emulator's copy of the cartridge on the way. Preferring the document
        is what says which of the two is the level and which is a picture of it
        -- and it is the difference between a header edit whose shape is in the
        undo stack and one whose shape is whatever the last load happened to
        say.

        ``previous`` is the snapshot this one replaces, and is what turns the
        redraw into a patch: see :meth:`_redraw_over`.
        """
        if self._snapshot is None:
            return
        if not keep_document or self._doc is None:
            # A fresh document, and a history that starts empty: undo belongs to
            # the level being worked on, and a stack that survived a level change
            # would offer to take back an edit made somewhere else.
            fresh = Level.read(
                self._snapshot.objects,
                self._snapshot.sprites,
                geometry(self._snapshot),
                self._snapshot.header,
                # The pattern as the loader decoded it -- the editable form
                # of the level's Layer 2, where it has one.
                layer2=(
                    self._snapshot.layer2_low
                    if self._snapshot.layer2_background
                    else b""
                ),
                # ...and the other kind of Layer 2, for the levels whose
                # pointer names an object stream instead. Exactly one of the
                # two is ever non-empty.
                layer2_objects=self._snapshot.layer2_objects,
                layer2_header=self._snapshot.layer2_header,
                secondary=self._secondary_header_bytes(self._snapshot.level),
                graphics=self._level_graphics_bytes(self._snapshot.level),
            )
            pending, self._pending_repoint = self._pending_repoint, None
            if (
                pending is not None
                and pending[0] == self._snapshot.level
                and self._history is not None
            ):
                # A repoint's own reload: the same replacement, committed onto
                # the level's history as one step wearing the repoint's mark,
                # so the document it replaced -- unsaved edits included -- is
                # an undo away. See :meth:`_walk_repoint`.
                #
                # The rebase keeps the unsaved dot honest for the common case:
                # this document is a fresh parse of what the project holds, so
                # a repoint of a clean level leaves a clean one. A level with
                # edits outstanding keeps its reading, since those edits are
                # down the stack rather than gone -- the dot then errs only
                # towards asking, never towards discarding.
                clean = not self._history.edited
                # The row the dialog edited beside the repoint rides into
                # the same step; the project's saved row is what a repoint
                # of an unedited level reads.
                if pending[2] is not None:
                    fresh = fresh.with_graphics(pending[2])
                self._doc = fresh
                self._history.commit(fresh, pending[1])
                if clean:
                    self._history.saved()
            else:
                self._doc = fresh
                self._history = History(fresh)
            edit, self._pending_graphics_edit = self._pending_graphics_edit, None
            if edit is not None and edit[0] == self._snapshot.level:
                self._apply_pending_graphics_edit(edit[1])
        shape = self._shape = self._doc.shape
        # What each object actually drew, as blocks. The snapshot reports tilemap
        # offsets, because the loader does; turning one into a block needs the
        # geometry, which is only settled here. Offsets past the end of the level
        # -- an object drawing off the edge -- drop out, and an object the trace
        # has nothing for keeps its record's rectangle.
        #
        # Paired against a fresh parse of the stream rather than against the
        # document's own list, because the two are not the same length: the
        # encoder writes the screen jumps a move needs and the document does not
        # keep them, so zipping the document's records against the loader's
        # footprints would pair a record with somebody else's tiles.
        #
        # Keyed by **uid**, though, and that is a different question from what
        # it is paired by. An offset is a property of the bytes and every edit
        # rewrites them, so a map keyed by offset goes wrong the moment a record
        # is deleted -- every offset after it shifts, and each surviving record
        # inherits its neighbour's tiles. The uid is what an edit carries
        # through, so the offsets are resolved to uids here, once, against the
        # document the snapshot was rendered from.
        #
        # And only when this picture is of the level currently held. A refresh
        # is ~60 ms and the document does not stop moving while it runs: hold an
        # arrow key down and the snapshot that arrives is a picture of the level
        # an edit or two ago. Its footprints describe where
        # those objects *were*, so trusting them would undo exactly the carrying
        # :meth:`_settle` does -- the outlines would snap back a block and then
        # forward again when the next picture landed. The ones already held were
        # carried along with every edit since and are the better answer; a newer
        # picture is already on its way.
        #
        # **Both object streams**, and in the order the loop reached them: the
        # loader runs the same loop again for a Layer 2 level, so the answer is
        # Layer 1's records followed by Layer 2's, and Layer 2's cells are
        # offsets into the other half of the buffer. An offset is only unique
        # *within* a stream, which is why the two are paired separately -- one
        # map from offsets to uids would have Layer 2's first record inherit
        # Layer 1's.
        current = self._doc.streams()[0] == self._snapshot.objects and (
            self._doc.layer2_stream() == self._snapshot.layer2_objects
        )
        if not keep_document or current:
            self._drawn = {}
            at = 0
            for stream, records, block_at in (
                (self._snapshot.objects, self._doc.objects, shape.block_at),
                (
                    self._snapshot.layer2_objects,
                    self._doc.layer2_objects,
                    lambda cell: layer2_block_at(shape, cell),
                ),
            ):
                parsed = parse_objects(stream, shape)
                uids = {obj.offset: obj.uid for obj in records}
                for record, footprint in zip(
                    parsed,
                    self._snapshot.footprints[at : at + len(parsed)],
                    strict=False,
                ):
                    if record.offset not in uids:
                        continue
                    self._drawn[uids[record.offset]] = frozenset(
                        block
                        for block in (block_at(cell) for cell in footprint)
                        if block is not None
                    )
                at += len(parsed)
        # Footprints come from the access counters, which keep one writer per
        # block -- so an object drawn over completely by later ones comes back
        # with an empty set rather than with its blocks. `objects.stack_at`
        # reads an empty entry as "placed no tiles", the same as a screen exit,
        # and such an object is therefore not selectable by clicking it. That is
        # accepted: it is two objects in eighty levels, and the alternative --
        # omitting the entry so the record's own rectangle is used instead --
        # would make a buried object selectable across a box it never drew.
        self._show_screen_grid(shape)
        self._show_screen_exits()
        if not keep_document:
            # A selection belongs to the level it was made in, and the panel has
            # to say so rather than describe an object from the last one.
            self._selection = frozenset()
            self._drop_screen()
            self._marquee = None
            self.properties.show_nothing()
            # And so does what is in hand: an object number picked out of one
            # tileset's list is a different object in the next level's, and a
            # background tile the next level's page may not offer at all.
            self._stop_all_placing()
            # The palette offers this level's page, under this level's
            # colours; the editing mode survives a switch between levels
            # that can serve it and falls back where the new one cannot.
            self._reoffer_background()
        elif self._layer2_chrome_stale:
            # A walk across a repoint step can flip what kind of Layer 2 the
            # level has, and this refresh's snapshot is the first to know --
            # so the kind-derived chrome is re-read here, where an ordinary
            # refresh (every arrow-key repeat) leaves it alone.
            self._layer2_chrome_stale = False
            self._reoffer_background()
        self._sync_level_editing_offer()
        # What can be placed into this level, and what it already holds.
        self._catalog.offer()
        # The footprints and the sprite artwork have both just been re-read, and
        # they are what the resting outlines are traced from.
        self._resting = None
        if keep_document:
            self._check_picture_is_of_this_level()
        # Nothing here decides whether the sprites are decoded again: the plane
        # is a function of the records, their artwork and the memories they are
        # drawn against, and `Picture` compares those itself. A window that had
        # to remember to say so is what let a stale one stay on the canvas.
        self._redraw_over(previous)
        # A level that has just been opened has an empty history and nothing
        # held, and one re-read for an edit has whatever it had -- and the keys
        # for both are the actions' own enabled state.
        self.sync_edit_actions()
        # And there is a level to act on now, which is the other half of what
        # a key can reach.
        self.sync_level_rows()

    def _check_picture_is_of_this_level(self) -> None:
        """Say so when a refresh brought back a picture of a different level
        than the document describes.

        **The invariant a refresh rests on**, and nothing was checking it. The
        streams go out as a patch over the emulator's copy of the cartridge and
        the picture comes back as what the game made of them, so once nothing
        further is queued the two must hold the same bytes. When they do not,
        every derived thing is quietly a picture of the level before the edit:
        the sprite plane is not rebuilt (its trigger is the snapshot's stream
        moving), the artwork for a number the edit added is never captured, and
        the canvas keeps drawing records that are gone. Which is what a deleted
        sprite that will not go away and a new one with no graphics both look
        like -- so it is worth catching where the disagreement is, rather than
        three symptoms later.

        Not an error, and not a dialog: a refresh that lands stale is followed
        by one that does not as soon as anything else is edited, and the level
        in hand is unharmed. The log line is what an investigation needs and the
        status bar is what makes it noticed at all -- warnings go nowhere
        without ``SHINY_MUSHROOM_DEBUG`` set.

        **Only once nothing is queued behind it.** A refresh is ~60 ms and the
        document does not stop moving while it runs, so a picture arriving in
        the middle of a drag is legitimately of the level an edit or two ago --
        see :meth:`_read_level`. That is the ordinary case and not this one.
        """
        if self._doc is None or self._snapshot is None or self._refresh_pending:
            return
        # No patches can be built for an image the base's offsets mean nothing
        # in, so the cartridge's own level is the honest answer there.
        if not self._addressable:
            return
        objects, sprites = self._doc.streams()
        stale = [
            what
            for what, held, drawn in (
                ("objects", objects, self._snapshot.objects),
                ("sprites", sprites, self._snapshot.sprites),
                (
                    "Layer 2 objects",
                    self._doc.layer2_stream(),
                    self._snapshot.layer2_objects,
                ),
            )
            if held != drawn
        ]
        if not stale:
            return
        _log.warning(
            "level $%03X was drawn from a stale %s stream: the document holds "
            "%d/%d bytes and the picture came back from %d/%d",
            self._snapshot.level,
            " and ".join(stale),
            len(objects),
            len(sprites),
            len(self._snapshot.objects),
            len(self._snapshot.sprites),
        )
        self.statusBar().showMessage(
            f"The picture is out of step with the level's {' and '.join(stale)} "
            f"— edit anything to redraw it; please report this",
            8000,
        )

    def _redraw_over(self, previous: LevelSnapshot | None) -> None:
        """Bring the picture up to date, patching it where that is enough.

        A level's picture is megabytes and rendering one costs 11 to 37 ms; an
        edit changes almost none of it. So a reload asked for by an edit
        compares the two snapshots' tilemaps and repaints only the blocks they
        disagree about -- measured on level ``$105``, four blocks and ~0.4 ms
        for a single-object move, against 37 ms to draw the level again.

        The comparison and its bail-out are
        :func:`~shiny_mushroom.level.changed_blocks`; ``None`` from it means
        something the whole picture is drawn from moved, and the answer is the
        render. Opening a level has nothing to patch over and always renders.
        """
        if previous is None or self._snapshot is None or not self._picture.drawn:
            self._draw_level()
            return
        moved = changed_blocks(
            previous, self._snapshot, self._shape, layer3=self.options.layer3
        )
        if moved is None:
            self._draw_level()
            return
        self._patch_level(block_runs(self._snapshot, moved, **self._layers))
        self._draw_overlays()

    @property
    def _layers(self) -> dict[str, bool]:
        """Which of the level's layers the picture is asked for, as the
        keywords both :meth:`Picture.render` and :func:`block_runs` take them
        under -- the render and the patch have to be of the same picture."""
        return {
            "layer2": self.options.layer2,
            "layer3": self.options.layer3,
            "layer1": self.options.layer1,
        }

    def _draw_level(self) -> None:
        """Re-render the level's pixels from the held snapshot, and show them.

        Kept separate from :meth:`_show_level` because a redraw must not mean a
        reload: the emulator round trip is ~260 ms and the render 11 to 37 --
        Layer 1 alone against Layer 1 composited over Layer 2 -- so re-rendering
        is the cheap half and there is no reason to cache a second picture.

        The whole picture is the expensive way, and an edit does not use it --
        see :meth:`_patch_level` and :meth:`_redraw_over`.
        """
        if self._snapshot is None:
            return
        self._picture.render(self._snapshot, **self._layers)
        self._level_stale = False
        self._show_picture()
        self._draw_overlays()

    def _patch_level(self, runs: tuple[tuple[int, bytes], ...]) -> None:
        """Redraw only the blocks an edit changes."""
        self._picture.patch(runs)
        self._show_picture()

    def _show_picture(self) -> None:
        """Compose the level, its sprites and the player, and hand it over.

        A repaint rather than a re-render, and the whole reason
        :class:`~shiny_mushroom.ui.picture.Picture` keeps two buffers: what is
        painted *over* the level can move -- a dragged sprite, the spawn marker
        following a middle click -- and starting from the clean copy is what
        stops the old pixels being left behind.

        The level's pixels and the sprites standing in them, because a sprite is
        part of the picture rather than a mark over it. What is *marked* over it
        is :meth:`_draw_overlays`, and none of that reaches the buffer.

        **Nothing while the world map holds the canvas.** The level's picture
        would be painted over the map, so the composition is deferred and
        :attr:`_level_stale` says so -- :meth:`_leave_world` redraws from it.
        """
        if self._snapshot is None:
            return
        if self._mode is EditorMode.WORLD:
            self._level_stale = True
            return
        image = self._picture.compose(
            self._snapshot,
            self._sprites,
            show_sprites=self.options.sprites,
            player_art=self._player_art,
            marker=self._player_at(),
        )
        if image is not None:
            self.canvas.set_image(image)

    def _draw_overlays(self) -> None:
        """Hand the canvas everything currently marked over the level.

        The whole set every time rather than a diff: it is a list of rectangles,
        the picture is untouched, and a repaint is all it costs - so the two
        view modes and the selection can each just say what they want and let
        this rebuild it.
        """
        objects = self._objects if self.options.objects else ()
        sprites = self._sprites if self.options.sprite_outlines else ()
        carrying = self._carried()
        # **Everything not in the hand is built once per gesture.** A drag
        # touches nothing in the document, so the outlines around the rest of the
        # level cannot change while it runs -- and rebuilding them is the
        # expensive part: each object is traced around the blocks it drew, and
        # the list is rebuilt whole even where `overlays._traced` answers for
        # every footprint in it. Rebuilding it every time the pointer crosses a
        # block is work done per frame for a document that has not moved.
        # A placement counts, and it is the case that needs the cache most: the
        # pointer sweeps a whole level looking for where to drop something, with
        # nothing in the document changing between one block and the next.
        holding = (
            self._moving is not None
            or self._marquee is not None
            or self._stretching is not None
            or self._placing is not None
            or self._bg_placing is not None
        )
        if not holding:
            self._resting = None
        if self._resting is None:
            resting = resting_overlays(
                objects, sprites, self._sprite_art, self._drawn, carrying
            )
            if holding:
                self._resting = tuple(resting)
        else:
            resting = self._resting
        self.canvas.set_overlays(
            [
                *resting,
                *self._bg_selection_overlays(),
                *self._screen_overlays(),
                *moving_overlays(
                    objects,
                    sprites,
                    () if self._doc is None else self._doc.records(self._selection),
                    self._sprite_art,
                    self._drawn,
                    self._marquee_mark(),
                    carrying,
                    self._stretched(),
                    self._placed(),
                ),
            ]
        )

    def _carried(self) -> Floating | None:
        """What a drag is holding off the level, or None outside one.

        Asked of the document rather than of the selection, because they are not
        the same set: a screen exit has no position to change, so it stays put
        while the rest of what was caught with it moves.
        """
        if self._floating is None or self._doc is None:
            return None
        columns, rows = self._floating
        return Floating(self._doc.movable(self._selection), columns, rows)

    def _marquee_rect(self) -> QRect | None:
        """The selection box being dragged, as a rectangle, or None outside one.

        Normalised by :func:`~shiny_mushroom.ui.gestures.box_between` rather than
        as it is recorded, because a drag is naturally kept as the two corners it
        was made from and one drawn upwards and to the left has a negative width.
        """
        if self._marquee is None:
            return None
        return box_between(*self._marquee)

    def _marquee_mark(self) -> QRect | None:
        """The box a drag in flight should *draw*, which is not every drag.

        A marquee is worth drawing where the box and the selection are
        different things: it reaches across the picture and catches whichever
        records it touches, so it has to be visible while the ants are
        somewhere else. Boxing a **tilemap** is not that. Every block inside
        the box is caught, so the ants already outline the box itself, and a
        second rectangle in another colour is one statement drawn twice.
        """
        if self._painting:
            return None
        return self._marquee_rect()

    def _caught_by_marquee(self) -> frozenset[int]:
        """Every record the box currently covers.

        Sprites in pixels and objects in blocks, each measured the way it is
        already outlined and hit-tested, so what a box catches is what it looks
        like it caught. Sprites only while they are shown, for the same reason a
        click cannot reach a hidden one: what is in the picture is what can be
        picked out of it -- and only while the records mode is up, because a
        sprite belongs to it and not to Layer 2.
        """
        box = self._marquee_rect()
        if box is None or self._doc is None:
            return frozenset()
        left, top, right, bottom = box.left(), box.top(), box.right(), box.bottom()
        caught = {
            obj.uid
            for obj in objects_within(
                self._objects,
                left // BLOCK,
                top // BLOCK,
                right // BLOCK,
                bottom // BLOCK,
                drawn=self._drawn,
            )
        }
        if self.options.any_sprites and not self._on_layer2:
            caught |= {
                sprite.uid
                for sprite in sprites_within(
                    self._doc.sprites, left, top, right, bottom, self._sprite_art
                )
            }
        return frozenset(caught)

    @property
    def _sprite_art(self) -> Mapping[int, tuple[SpriteTile, ...]]:
        """What each sprite in the held level draws, and nothing when there is
        no level. It is what a sprite's outline and the hover readout measure
        their box from, so both go through here rather than reaching into a
        snapshot that may not be there."""
        return {} if self._snapshot is None else self._snapshot.sprite_art

    def _forget_level(self) -> None:
        """Drop the held level. The byte map is not one, and neither is nothing.

        Called when a cart is closed and when one is opened, which is why the
        two things that belong to the *cart* are dropped here as well:

        - **Test starts** are keyed by level number, and level $105 of the next
          cart is a different level -- keeping them would put the marker
          somewhere nobody chose.
        - **The player's artwork** is the cart's own. A hack can draw him
          differently, and the next cart's is a probe or a cache read away.
        """
        self._test_start.clear()
        self._player_art = None
        self._player_art_asked = False
        self._pending = None
        self._going_to = None
        self._arriving_at = None
        self._snapshot = None
        self._shape = None
        # A screen belongs to the level it is a screen of, and the panel has to
        # stop describing it -- the same rule the record selection follows a
        # few lines down.
        self._drop_screen()
        self.canvas.set_screens_selectable(False)
        self._doc = None
        self._history = None
        self._drawn = {}
        self._selection = frozenset()
        self._marquee = None
        self._resting = None
        # Nor can a refresh waiting for the machine: it would ask for a picture
        # of a document that has gone. Neither is one already in flight -- the
        # reply is disconnected with the loader, and a flag left set would make
        # the next load look like a refresh of a level nobody holds.
        self._refresh_pending = False
        self._refreshing = False
        # And nothing is waiting on a probe for a cartridge that is not open any
        # more. The lock goes with it: a modal left up over no level would have
        # nothing to dismiss it, and a view left disabled no way back. Harmless
        # on the way *in* -- a cart is forgotten before the next one's first
        # level is asked for, which locks again a line later.
        self._awaiting_player_art = False
        self._unlock_after_load()
        # A gesture cannot outlive the level it was made in: a step still being
        # carried when the cart closes would be applied to whatever opens next,
        # and so would an edge still being pulled.
        self._moving = None
        self._floating = None
        self._stretching = None
        self._grip = None
        self._pulled = None
        # ...and neither can something armed but never placed: an object number
        # belongs to a tileset, and the next cartridge's is not this one's.
        self._placing = None
        self._placing_at = None
        self._placed_by_drag = False
        # The painting mode goes down with its level: the tile in hand, the
        # library it came from, the selection over its pattern, and the mode
        # itself, whose subject is gone. The clipboard stays, like the record
        # clipboard: copying out of one level and into another is the point.
        self._bg_placing = None
        self._bg_tile_image = None
        self._bg_stroke = None
        self._bg_selection = frozenset()
        self._bg_marquee_from = frozenset()
        # The float's edits are already committed, so nothing is lost here;
        # only the right to keep moving them goes down with the level.
        self._bg_hand.land()
        self.level_palette.set_tiles([])
        if self._level_editing is LevelEditing.LAYER2:
            self._level_editing = LevelEditing.RECORDS
            self._apply_editing_chrome()
            self._sync_level_editing()
        self._sync_level_editing_offer()
        self.view.set_hover_cursor(None)
        self._picture.forget()
        self._sprite_label.clear()
        self.sync_level_rows()
        self.properties.show_nothing(NO_LEVEL)
        # The catalogue's pictures, and everything remembered about having asked
        # for them. They are this cartridge's graphics; the next one's are not
        # these. It also empties the panel, which is what "there is nothing to
        # place into" looks like.
        self._catalog.forget()
        # A byte map has no screens in it, so the grid has nothing to divide -
        # and nothing in it to mark, so the overlays go with the level they
        # belonged to rather than hanging over whatever comes next.
        self.canvas.set_screen_size(QSize())
        self.canvas.set_screen_notes({})
        self.canvas.set_overlays(())
        # There is no level, so none of the level keys mean anything: they go
        # dead here and are armed again by the next one that arrives.
        self.sync_edit_actions()

    # -- the screen grid ----------------------------------------------------
    #
    # Two statements the canvas has to be told and cannot work out: how big a
    # screen is in this level, and which screens have an exit on them. Both
    # follow the *document* -- a header edit changes the first and any edit can
    # change the second -- so both are said from a level arriving and from an
    # edit settling, which is why neither is written out twice.

    def _show_screen_grid(self, shape: Geometry) -> None:
        """Divide the picture into ``shape``'s screens."""
        columns, rows = shape.screen
        self.canvas.set_screen_size(QSize(columns * BLOCK, rows * BLOCK))

    def _show_screen_exits(self) -> None:
        """Write each screen's exit into that screen's label, and into the
        Level Exits window while one is up.

        It is the one thing about a screen that is not visible in the picture,
        and the screen number is exactly what the exit is indexed by. The
        window is the same statement as a table, so it follows the document
        from here rather than from a hook of its own.
        """
        self.canvas.set_screen_notes(
            {
                # Layer 1's stream, whichever layer is being edited: an exit is
                # a fact about the level rather than about a layer, and no
                # shipped Layer 2 stream carries one.
                screen: screen_note(
                    ScreenExit(self._doc, screen, (), self._entrances_offered())
                )
                for screen in screen_exits(
                    () if self._doc is None else self._doc.objects
                )
            }
        )
        self._level_exits.refresh()
        self._sync_screen_selecting()

    def _sync_screen_selecting(self) -> None:
        """Offer the screen labels as targets exactly where a screen means
        something, and put a held one down where it does not.

        Three conditions, and each of them is about what the canvas is showing
        rather than about the labels: the level is on it, there is a document
        behind it, and a gesture on it is about Layer 1's records. Painting the
        background is the case worth naming -- the boxes are still drawn there,
        because a screen boundary is worth seeing whatever is being edited, but
        a click on one would select something the mode has no edits for.

        A screen the level no longer reaches goes down too: a header edit can
        make a level shorter, and the ants would be left around a screen with
        no picture under it.
        """
        offered = (
            self._mode is EditorMode.LEVEL
            and self._doc is not None
            and not self._painting
        )
        self.canvas.set_screens_selectable(offered)
        if not offered or (
            self._screen_selected is not None
            and self._screen_selected >= self._doc.shape.screens
        ):
            self._select_screen(None)

    # -- the View menu's toggles --------------------------------------------
    #
    # What each one holds is :class:`~shiny_mushroom.ui.view_options.ViewOptions`
    # and is remembered by it; what is here is what each one *costs*. Three
    # answers, and the difference between them is where the toggle's effect
    # lives: in the picture, over it, or in the canvas's own drawing.
    #
    # **All of them are about the level's picture**, so while the world map
    # holds the canvas each records its answer and paints nothing: drawing here
    # would put the level's pixels or its outlines over the map without leaving
    # the mode. Leaving the mode redraws from the options as they then stand.
    # The two exceptions are screens and the grid, which are the canvas's own
    # drawing and mean something over either picture.

    def set_sprites(self, checked: bool) -> None:
        self.options.set("sprites", checked)
        if self._mode is EditorMode.WORLD:
            # Sprites are composed in at :meth:`_show_picture`, which leaving
            # the mode runs anyway; the selection drop waits there too.
            return
        self._drop_a_hidden_sprite()
        # Unlike the other toggles this one is in the picture, so it costs a
        # re-render rather than a repaint - about 10 ms against the emulator's
        # 150, which is why the snapshot is held rather than reloaded.
        self._draw_level()

    def set_sprite_outlines(self, checked: bool) -> None:
        self.options.set("sprite_outlines", checked)
        # Which outlines are drawn at all has changed, and a gesture in progress
        # -- a placement, most plausibly, since the menu is reachable with one in
        # hand -- is holding a cached copy of the old answer.
        self._resting = None
        if self._mode is EditorMode.WORLD:
            return
        self._drop_a_hidden_sprite()
        self._draw_overlays()

    def _drop_a_hidden_sprite(self) -> None:
        """Clear the selection if it is a sprite that has just left the picture:
        the ants would be left around nothing, describing something no longer
        there. Both toggles have to be off for that - with either one on the
        sprite is still marked, and still the thing the panel is describing."""
        if self.options.any_sprites or self._doc is None:
            return
        self._select(
            {
                uid
                for uid in self._selection
                if not isinstance(self._doc.record(uid), Sprite)
            }
        )

    def set_objects(self, checked: bool) -> None:
        self.options.set("objects", checked)
        # See `set_sprite_outlines`: this changes what the cached resting
        # outlines would be, and a gesture may be holding the old ones.
        self._resting = None
        if self._mode is EditorMode.WORLD:
            return
        self._draw_overlays()

    def set_layer1(self, checked: bool) -> None:
        self.options.set("layer1", checked)
        self._redraw_layers()

    def set_layer2(self, checked: bool) -> None:
        self.options.set("layer2", checked)
        self._redraw_layers()

    def set_layer3(self, checked: bool) -> None:
        self.options.set("layer3", checked)
        self._redraw_layers()

    def _redraw_layers(self) -> None:
        """Draw the level again with the layers as they now stand."""
        if self._mode is EditorMode.WORLD:
            # The render waits for the level's return -- see `_leave_world`.
            # Unlike the compose-time toggles this one has a buffer to
            # invalidate: the pixels held are of the layers as they were.
            self._level_stale = True
            return
        self._draw_level()

    def set_screens(self, checked: bool) -> None:
        self.options.set("screens", checked)
        self.canvas.set_screens(checked)

    # -- selection ----------------------------------------------------------

    def _select_at(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """Select whatever covers the clicked pixel, or nothing.

        A plain click **replaces** the selection. Off it, it takes the
        **topmost** thing there, which is the one the user is looking at; on it,
        it steps to the next thing down that covers the clicked pixel, and round
        to the top again - so a shell inside a block, or the ground under a ledge
        under a pipe, is reached by clicking it a second time rather than by
        switching layers off to uncover it. The panel and the ants say which of
        them is in hand.

        A **shift** click adds the topmost thing there to the selection, or takes
        it out again if it is already in. It never cycles: shift is for
        assembling a group out of things you can see, and a modifier that
        sometimes reached past what was under the pointer would make that
        guesswork.

        What makes a plain click a repeat is the selection being under it, not
        the pixel being the one clicked last: a hand moves between two clicks,
        and a click anywhere else on the selected thing is still a click on it.
        So there is no cycle to hold on to - where a click lands is decided by
        where the selection is, and it stays right when the selection is changed
        by something other than a click.

        Clicking bare level clears the selection rather than keeping the last
        one: an outline that stays lit while the panel describes something the
        user is no longer pointing at is worse than an empty panel. Shift-
        clicking bare level keeps it, because the gesture says "as well as".

        **None of it applies while something is in hand.** The create panel has
        armed an entry, so a click on the picture is naming a place for it rather
        than picking something out of it -- see :meth:`_place_at`. And an
        **alt** click is the eyedropper, as it is over every tile layer: it
        arms the thing under the pointer rather than selecting it -- see
        :meth:`_pick_up_record`.
        """
        if self._doc is None:
            return
        if modifiers & Qt.KeyboardModifier.AltModifier:
            self._pick_up_record(pos)
            return
        if self._placing is not None:
            self._place_at(pos, modifiers)
            return
        # A click on the picture is about the picture, so a held screen goes
        # down whether or not the click found anything: `_select` only clears
        # it for a click that lands on a record, and clicking bare level while
        # a screen was held has to mean the same "nothing here" it always does.
        self._select_screen(None)
        stack = self._stack_at(pos)
        if modifiers & Qt.KeyboardModifier.ShiftModifier:
            if stack:
                self._select(self._selection ^ {stack[0].uid})
            return
        self._select(
            {next_in_stack(stack, self._selection).uid} if stack else frozenset()
        )

    def _clicked_away(self, modifiers: Qt.KeyboardModifier) -> None:
        """Drop the selection: the gray around the level was clicked.

        The surround is part of what the level is worked in rather than a margin
        beside it, and the one thing it can say is "nothing here" - which makes
        it the easy place to click to put a selection down, with no risk of
        picking something else up on the way. The same answer a click on bare
        level gives, reached without having to find a bare block.

        Held with shift it says nothing at all, exactly as a shift-click on bare
        level does: the gesture means "as well as", and there is nothing there to
        add.
        """
        if not modifiers & Qt.KeyboardModifier.ShiftModifier:
            self._select_screen(None)
            self._select(frozenset())

    # -- dragging -----------------------------------------------------------

    def _drag_begun(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """A drag started at image pixel ``pos``.

        One gesture with four meanings, and which one it is is settled here so
        that nothing downstream has to ask again:

        - **shift** draws a selection box, and that has to be true even over an
          object, or a box could never be started from inside a crowded part of
          a level;
        - a drag begun on the **edge of the one object held**, where that edge
          is one the object's settings byte can move, resizes it -- see
          :meth:`_grip_at`. Ahead of the move, because an edge is the narrower
          claim: it is a few pixels of the object rather than all of it, and a
          gesture aimed at one is not a gesture aimed vaguely at the middle;
        - a drag begun **on something held** moves the whole selection, which is
          what makes a group assembled by shift-clicking draggable as one thing;
        - a drag begun on something *not* held selects it first and then moves
          it, so picking a thing up and moving it is one gesture rather than two.

        A drag begun on bare level is a selection box as well, without the
        modifier -- there is nothing there to move, and sweeping an empty area is
        the other thing that gesture obviously means.

        **With something in hand it is none of the four.** A placement is a click
        and the create panel's tool is not a select tool, so a press that
        travelled is answered as the placement it was meant to be, at the point
        it was aimed at -- see :attr:`_placed_by_drag` for why that is not left to
        the release.
        """
        if self._doc is None:
            return
        if self._placing is not None:
            self._place_at(pos, modifiers)
            self._placed_by_drag = True
            return
        if not modifiers & Qt.KeyboardModifier.ShiftModifier:
            grip = self._grip_at(pos)
            if grip is not None:
                self._grip = grip
                self._stretching = pos
                self._pulled = (0, 0)
                return
            stack = self._stack_at(pos)
            if stack:
                if not any(thing.uid in self._selection for thing in stack):
                    self._select({stack[0].uid})
                if self._doc.movable(self._selection):
                    self._moving = pos
                    self._floating = (0, 0)
                    return
        self._marquee = (pos, pos)
        # A bare marquee replaces the selection, exactly as a bare click
        # does; shift is what says "as well as", on box and click alike.
        self._marquee_from = (
            self._selection
            if modifiers & Qt.KeyboardModifier.ShiftModifier
            else frozenset()
        )
        self._draw_overlays()

    def _drag_moved(self, pos: QPoint) -> None:
        """The drag reached ``pos``: grow the box, or carry what is held.

        A move is measured from where the drag **began** against the level as it
        was then, not from the last frame against the level as it is now:
        applying a delta per frame accumulates the trimming at an edge, so a
        selection pushed into a wall and back out again would come back somewhere
        other than where it started.

        **Nothing is edited here.** The step is asked for and drawn -- the
        outlines float a step away over a picture that has not moved -- and the
        level it names is not built until the button comes up. Building it every
        frame is a rewrite of both streams to draw a rectangle somewhere else,
        and the rewritten stream's offsets are not the ones the picture's
        footprints are keyed by, so the outlines it produced were the plain
        record boxes rather than the traced shapes they had a moment earlier.

        Repainted only when the step lands on a different block, which is what
        makes the gesture cost nothing between them: a level is worked at four
        or five device pixels to the image pixel, so most of the movements in a
        drag are inside the block it is already showing.
        """
        if self._stretching is not None:
            self._pull_to(pos)
            return
        if self._moving is not None:
            if self._doc is None:
                return
            step = self._doc.step(
                self._selection,
                pos.x() // BLOCK - self._moving.x() // BLOCK,
                pos.y() // BLOCK - self._moving.y() // BLOCK,
            )
            if step == self._floating:
                return
            self._floating = step
            self._draw_overlays()
            return
        if self._marquee is None:
            return
        self._marquee = (self._marquee[0], pos)
        self._select(self._marquee_from | self._caught_by_marquee(), redraw=False)
        self._draw_overlays()

    def _drag_ended(self, pos: QPoint) -> None:
        """The drag finished. Commit a move or a resize, or put the box away."""
        # A drag that was a placement has already done its work, at the press
        # rather than here. Nothing else in this method has any state to find,
        # so the flag is what stops the release being read as a second gesture.
        if self._placed_by_drag:
            self._placed_by_drag = False
            return
        if self._stretching is not None:
            self._drag_moved(pos)
            pulled = self._pulled or (0, 0)
            found = self._sizable()
            self._stretching = None
            self._grip = None
            self._pulled = None
            # The one place a pulled edge becomes an edit, so the whole gesture
            # is one undo step -- and an edge let go where it was picked up is
            # not an edit at all, because the fields hand back the record they
            # were given and `replaced` then hands back the level.
            if found is not None and self._doc is not None:
                record, _, sizes = found
                edited, _ = pulled_to(record, sizes, *pulled)
                if self._commit(self._doc.replaced(record.uid, edited)):
                    return
            # Nothing was committed, so nothing has redrawn: the reach has to be
            # taken off the picture by hand.
            self._draw_overlays()
            return
        if self._moving is not None:
            self._drag_moved(pos)
            columns, rows = self._floating or (0, 0)
            self._moving = None
            self._floating = None
            # The one place a carried step becomes an edit, so the whole gesture
            # is one undo step rather than one per frame of it -- and a drag that
            # ended where it began is not an edit at all, because `moved` hands
            # back the level it was given and `_commit` does not commit it.
            if self._doc is not None:
                self._commit(self._doc.moved(self._selection, columns, rows))
            return
        if self._marquee is None:
            return
        self._drag_moved(pos)
        self._marquee = None
        self._draw_overlays()

    # -- resizing by an edge ------------------------------------------------
    #
    # The mouse half of what Shift and an arrow already do, and it drives the
    # same field descriptors -- see `resize_selection`. What is added here is
    # only the geometry: which edge of the outline the pointer is on, and how
    # far it has been pulled.

    def _sizable(self) -> tuple[LevelObject, QRect, dict[str, Field]] | None:
        """The held object, the box it is outlined by, and the extents its
        settings byte offers -- or ``None`` when there is nothing an edge could
        drag.

        Three things have to be true, and each of them is a reason rather than a
        precaution:

        - **exactly one record is held**, because an edge belongs to a
          particular object's footprint, exactly as :meth:`resize_selection`
          says of the keys;
        - it is an **object**. A sprite's box is its artwork's, which is a fact
          about what the game draws rather than a field anything can write;
        - it offers a **width or a height**. A ``length`` deliberately does not
          count: an edge drag says "put this edge here", and a length cannot
          keep that promise -- it steps in the object's own units, growing the
          footprint by one, two or four columns depending on which variant is
          drawn, so the edge would land somewhere other than where it was
          dropped. Shift and an arrow still step it, because a step promises
          nothing about distance.

        The box is the one the object is *outlined* by, around the blocks it
        drew -- not its record's rectangle, which for most objects is one block
        whatever they put on screen. A grip has to be on the line the eye can
        see.
        """
        found = self._selected_fields()
        if found is None:
            return None
        record, fields = found
        if not isinstance(record, LevelObject):
            return None
        sizes = {
            field.key: field
            for field in fields
            if field.key in ("width", "height") and field.editable
        }
        if not sizes:
            return None
        return record, outlined(record, self._drawn), sizes

    def _grip_at(self, pos: QPoint) -> Grip | None:
        """Which of the held object's edges image pixel ``pos`` is on, if any.

        Which object that is and which of its edges can move at all is
        :meth:`_sizable`; where the edges *are* and how near counts as on one is
        :func:`~shiny_mushroom.ui.gestures.grip_within`, which needs the zoom
        because the reach is a distance on the screen rather than in the picture.
        """
        found = self._sizable()
        if found is None:
            return None
        _, box, sizes = found
        return grip_within(pos, box, sizes, self.canvas.zoom)

    def _pull_to(self, pos: QPoint) -> None:
        """The resize drag reached ``pos``: work out how far the edge has come.

        Measured from where the press was and in whole blocks, exactly as a move
        is, and against the object the drag began on -- nothing has been
        committed, so it is still the object it was.

        **Trimmed to what the field can say.** A drag past the largest size the
        nibble holds shows the size that would be got rather than the one being
        reached for, so the picture never promises an edit the byte cannot make.
        Repainted only when that trimmed step changes, which is what keeps a
        drag that is already at the limit free.
        """
        found = self._sizable()
        if found is None or self._stretching is None or self._grip is None:
            return
        record, _, sizes = found
        columns = rows = 0
        if Grip.RIGHT in self._grip:
            columns = pos.x() // BLOCK - self._stretching.x() // BLOCK
        if Grip.BOTTOM in self._grip:
            rows = pos.y() // BLOCK - self._stretching.y() // BLOCK
        _, pulled = pulled_to(record, sizes, columns, rows)
        if pulled == self._pulled:
            return
        self._pulled = pulled
        self._draw_overlays()

    def _stretched(self) -> Stretching | None:
        """What a resize drag is reaching for, or ``None`` outside one."""
        if self._pulled is None or self._doc is None:
            return None
        records = self._doc.records(self._selection)
        if len(records) != 1:
            return None
        return Stretching(records[0].uid, *self._pulled)

    def _show_grip(self, pos: QPoint) -> None:
        """Say on the pointer whether the picture is offering an edge here.

        The whole of what makes the gesture findable: an object's edge looks no
        different from its middle, so the cursor is where the editor says which
        of the two the pointer is on.

        A drag in progress keeps the cursor it started with, whatever the
        pointer has since travelled over -- it is still holding that edge, and a
        cursor that changed under a held button would be describing a gesture
        nobody is making.

        A placement in hand keeps its crosshair for a stronger reason: there is
        no edge to take hold of while the pointer is naming a place, and a resize
        cursor over the picture would be offering a gesture the next click is not
        going to make.
        """
        if self._stretching is None and self._placing is None:
            self.view.set_hover_cursor(GRIP_CURSORS.get(self._grip_at(pos)))

    def _drop_grip(self) -> None:
        """The pointer left the picture; there is no edge under it out there."""
        if self._stretching is None and self._placing is None:
            self.view.set_hover_cursor(None)

    # -- placing something new ----------------------------------------------
    #
    # The one gesture that brings a record into the level rather than moving one
    # that is already there, and the only one whose subject does not exist until
    # it lands. What is in hand comes from the create panel
    # (:mod:`shiny_mushroom.ui.create`) as a catalogue entry; where it goes is a
    # click on the picture; what it *becomes* is the entry's own answer, so this
    # file knows no more about the difference between an object and a sprite here
    # than it does anywhere else.

    def _arm_placement(self, entry: Entry) -> None:
        """Take ``entry`` from the create panel: the next click places one.

        **The selection is dropped**, so the ghost is the only mark in the
        picture saying "this is what the next gesture is about". Two of them --
        ants around something held and a ghost under the pointer -- would be two
        answers to the same question, and the arrows and Delete would still be
        acting on the first while the eye is on the second.
        """
        self._placing = entry
        self._placing_at = None
        self._select(frozenset())
        # A crosshair, because the pointer is now naming a place rather than
        # picking something out of the picture. It goes through the same hover
        # channel a grip does, so panning still wins over both.
        self.view.set_hover_cursor(Qt.CursorShape.CrossCursor)
        self._draw_overlays()
        self.statusBar().showMessage(f"Placing {entry.label}", EDIT_REFUSED_MS)

    def _stop_placing(self) -> None:
        """Put down whatever is in hand and go back to selecting.

        What the right button does, what Escape does, and what an ordinary
        placement does to itself. Safe with nothing in hand, which is what lets
        the right button be connected to it unconditionally: a right press with
        nothing armed means nothing, and doing nothing is how that is said.
        """
        if self._placing is None:
            return
        self._placing = None
        self._placing_at = None
        # Told rather than asked: the panel's highlight is its own way of saying
        # what is in hand, and it cannot know that a click on the level has put
        # the thing down. It does not emit on the way back, so this cannot loop.
        self.create.disarm()
        self.view.set_hover_cursor(None)
        self._draw_overlays()

    def _place_at(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """Put what is in hand into the level at image pixel ``pos``.

        **Plain places once; shift keeps the tool.** A single placement is by far
        the common case and an editor that stayed armed after it would make every
        following click add another copy of the last thing -- so the tool puts
        itself down, and the modifier is how a row of coins or a line of blocks
        is laid out without going back to the panel between each one.

        What is placed lands **on top** of the stream and is then selected, which
        is one statement rather than two: it is the thing you just made, it is
        the thing the properties panel should be describing, and the reorder keys
        are how it goes behind something.

        A refused commit -- a level still opening -- leaves the tool armed and
        says so in the status bar through :meth:`_commit`, because the gesture
        was fine and the moment was not.
        """
        entry = self._placing
        if entry is None or self._doc is None:
            return
        # Read before the edit: `added` hands out this number, and afterwards
        # the document's counter has already moved past it.
        uid = self._doc.next_uid
        record = entry.at(pos.x() // BLOCK, pos.y() // BLOCK, self._doc.shape)
        if not self._commit(self._doc.added(record, layer2=self._on_layer2)):
            return
        self._select({uid})
        self.statusBar().showMessage(f"Placed {entry.label}", 3000)
        if not modifiers & Qt.KeyboardModifier.ShiftModifier:
            self._stop_placing()

    def _stop_all_placing(self) -> None:
        """Put down whatever either level mode has in hand -- the records'
        armed object and the pattern's armed tile, the pattern's floating
        paste landed with it. What every caller means is "the gesture is
        over", and no hand may survive that."""
        self._stop_placing()
        self._bg_stop_placing()

    def _track_placement(self, pos: QPoint) -> None:
        """Follow the pointer with the ghost while a record is in hand."""
        if self._placing is not None:
            self._move_ghost(pos)

    def _move_ghost(self, pos: QPoint) -> bool:
        """Put the ghost on ``pos``'s block, reporting whether it moved.

        Repainted only when the block changes, exactly as a drag's step is: a
        level is worked at four or five device pixels to the image pixel, so most
        of the pointer's travel is inside the block already being shown.
        """
        at = (pos.x() // BLOCK, pos.y() // BLOCK)
        if at == self._placing_at:
            return False
        self._placing_at = at
        self._draw_overlays()
        return True

    def _drop_placement(self) -> None:
        """The pointer left the picture: there is nowhere out there to put it.

        The tool stays armed -- reaching for the panel or the menu bar is not
        putting something down -- and only the ghost goes, because a mark left
        over a block the pointer is no longer on would be pointing at a placement
        that is not being offered.
        """
        if self._placing_at is None:
            return
        self._placing_at = None
        self._draw_overlays()

    def _placed(self) -> Placing | None:
        """What a placement would put down, and where.

        **The picture where there is one.** A preview has been rendered for most
        of what the panel offers, and it is the measured answer to a question the
        ghost used to have to guess at: an object's real footprint rather than
        its record's rectangle, and a sprite's real artwork rather than the one
        block it is anchored to. Where nothing has been rendered -- an extended
        object, or a sprite still being probed -- the record's own extent is the
        fallback, which is what the ghost always used to be.
        """
        if self._bg_placing is not None:
            # The painting mode's ghost: the armed tile itself, one block,
            # over whichever block the pointer is naming.
            if self._placing_at is None:
                return None
            column, row = self._placing_at
            return Placing(column, row, 1, 1, art=self._bg_tile_image, offset=(0, 0))
        if self._placing is None or self._placing_at is None or self._doc is None:
            return None
        column, row = self._placing_at
        extent = self._placing.preview(column, row, self._doc.shape)
        found = self._catalog.thumb(self._placing.key)
        if found is None:
            return Placing(*extent)
        return Placing(
            column,
            row,
            extent[2],
            extent[3],
            art=found.image,
            offset=(found.dx, found.dy),
        )

    # -- editing the Layer 2 background --------------------------------------
    #
    # The level's second editing mode -- see `LevelEditing`. The palette dock
    # offers the background's own page of blocks, a click places one entry of
    # the repeating pattern, a drag paints a run as one undo step, and every
    # edit goes through the same document and history as a record edit --
    # which is what makes Ctrl+Z one key whichever mode made the last change.
    # With nothing in hand the gestures select instead -- a click takes one
    # entry, a marquee boxes them -- and the Edit menu's clipboard rows work
    # the selection the way the world map's Layer 2 tab does.
    # The picture is this editor's own to paint here: the background is drawn
    # from the snapshot's buffer rather than by the game, so a commit patches
    # the changed blocks directly instead of costing an emulator round trip.

    def set_level_editing(self, index: int) -> None:
        """Pick what a gesture on the level edits -- the bar's Editing box,
        Edit > Level Editing and the create panel's tabs all land here, by row
        index."""
        mode = LevelEditing.LAYER2 if index == 1 else LevelEditing.RECORDS
        if mode is self._level_editing:
            self._sync_level_editing()
            return
        if mode is LevelEditing.LAYER2 and not self._layer2_editable():
            self.statusBar().showMessage(NO_LAYER2, 5000)
            self._sync_level_editing()
            return
        # A gesture cannot cross the editing boundary: what is armed belongs
        # to the mode that armed it.
        self._stop_all_placing()
        self._level_editing = mode
        # The record selection is dropped whichever way the mode went, and for
        # one reason both ways: its ids name records of the layer being left.
        # On a background level that means the panel is left behind by
        # painting; on a Layer 2 *level* it means the ants stop marking Layer
        # 1's objects and start marking Layer 2's.
        self._select(frozenset())
        # And so does a held screen: the number boxes are a handle on Layer 1's
        # exits, which is not what a gesture on the background means.
        self._select_screen(None)
        if mode is LevelEditing.LAYER2:
            # Editing a layer that is switched off would work blind, so the
            # view toggle follows the mode in -- and it is the layer being
            # edited either way, pattern or records.
            if not self.options.layer2:
                self.menu_actions.layer2.setChecked(True)
        else:
            # And the painting selection stays behind the same boundary: its
            # keys mean pattern blocks, which the records mode has no ants
            # for. A floating paste is fixed where it sits on the way out.
            self._bg_hand.land()
            self._bg_select(frozenset())
        self._apply_editing_chrome()
        # The panel comes to the front whichever way the mode went: what was
        # just asked for is a tab of it, and a panel behind the properties
        # dock is a tab nobody can see.
        self.create.raise_()
        self._sync_level_editing()
        self._sync_screen_selecting()
        self.sync_edit_actions()

    def _sync_level_editing(self) -> None:
        """Show the mode in effect on each of its handles, without asking."""
        index = 1 if self._level_editing is LevelEditing.LAYER2 else 0
        self.level_bar.set_editing(index)
        self.create.set_editing(index)
        for row in self.menu_actions.level_editing.actions():
            row.setChecked(row.data() == index)

    def _sync_level_editing_offer(self) -> None:
        """Arm or grey the Layer 2 editing row, on every handle."""
        editable = self._layer2_editable()
        self.level_bar.offer_layer2(editable)
        self.create.offer_layer2(editable, records=self._layer2_records_editable())
        group = self.menu_actions.level_editing
        # The world map's rows carry the same bare digits, so the two groups
        # are never armed together: a level to edit *and* the level on the
        # canvas is what makes the digits mean these rows.
        group.setEnabled(self._doc is not None and self._mode is not EditorMode.WORLD)
        rows = group.actions()
        if len(rows) > 1:
            rows[1].setEnabled(editable)

    def _background_editable(self) -> bool:
        """Whether this level has a background to paint at all."""
        return (
            self._snapshot is not None
            and self._snapshot.layer2_background
            and self._doc is not None
            and bool(self._doc.layer2)
        )

    def _layer2_records_editable(self) -> bool:
        """Whether this level's Layer 2 is an **object stream** instead.

        The other kind, and the other pathway: such a level has no pattern to
        paint, and its Layer 2 is placed and selected exactly as Layer 1 is.
        Never true at the same time as :meth:`_background_editable` -- a
        level's Layer 2 pointer names one or the other.
        """
        return self._doc is not None and self._doc.layer2_records

    def _layer2_editable(self) -> bool:
        """Whether the Layer 2 editing mode can be entered at all.

        What the Editing box, the Edit menu's row and the create panel's tab
        are armed by. Greyed only for a level with neither kind -- a Layer 2
        background this editor could not read out of the cartridge.
        """
        return self._background_editable() or self._layer2_records_editable()

    @property
    def _painting(self) -> bool:
        """Whether a gesture paints the Layer 2 background.

        Every mode-sensitive dispatcher asks this rather than asking what the
        editing mode is, because "Layer 2" names two different pathways: a
        pattern to paint on most levels that have one, and a second record
        stream on the twenty-six that do not. The record handlers serve the
        second without change -- see :attr:`_objects`.
        """
        return (
            self._level_editing is LevelEditing.LAYER2 and self._background_editable()
        )

    @property
    def _on_layer2(self) -> bool:
        """Whether a *record* gesture works the Layer 2 stream rather than
        Layer 1's. The complement of :attr:`_painting` inside the Layer 2
        mode."""
        return self._level_editing is LevelEditing.LAYER2 and not self._painting

    @property
    def _chrome(self) -> str:
        """Which editing environment the window is in, as the key its dock
        arrangement is remembered under.

        The level's two editing modes are one environment: they are two tabs
        of the create panel, so nothing about the docks moves between them.
        """
        return "world" if self._mode is EditorMode.WORLD else "level"

    def _apply_editing_chrome(self) -> None:
        """Put up the dock the current environment places from, and no other.

        The create panel and the world map's tile palette take turns in one
        spot: what a level can hold against what the map can. Also what
        :meth:`_restore_geometry` reasserts over a remembered layout.

        Visibility is asserted *after* the arrangement is swapped, because a
        remembered arrangement carries the visibility it was saved with and
        that is the environment's answer to give, not the layout's.
        """
        if self._chrome != self._chrome_shown:
            self._swap_chrome_layout()
        in_world = self._mode is EditorMode.WORLD
        self.create.setVisible(not in_world)
        self.tile_palette.setVisible(in_world)
        if in_world:
            self.tile_palette.raise_()

    def _swap_chrome_layout(self) -> None:
        """Keep the arrangement the outgoing environment was left in, and put
        the incoming one's back up.

        Where the docks sit and how big they are belongs to the environment
        that was arranged, not to the window: three of them share one spot, so
        a palette dragged taller here would otherwise be handed to the next
        environment at that height and come back at whatever height that one
        left the spot at. Nothing to restore is not a failure -- an environment
        entered for the first time inherits the arrangement on screen, which is
        the only sensible starting point it has.
        """
        if self._chrome_shown is not None:
            self._layouts[self._chrome_shown] = self.saveState()
        self._chrome_shown = self._chrome
        remembered = self._layouts.get(self._chrome_shown)
        if remembered is not None:
            self.restoreState(remembered)
            # An arrangement carries the toolbars it was saved with; the
            # registry's answer for this environment goes back on top.
            self.toolbars.reassert()

    def _reoffer_background(self) -> None:
        """Re-read the Layer 2 page this level offers, and fall back off the
        painting mode where the level cannot serve it.

        The two halves of "the level's background changed under the chrome",
        asked wherever it can: a level arriving, and a refresh whose snapshot
        is the first to know a repoint flipped what kind of Layer 2 there is.
        """
        self._offer_background()
        if self._level_editing is LevelEditing.LAYER2 and not self._layer2_editable():
            self._level_editing = LevelEditing.RECORDS
            self._apply_editing_chrome()
            self._sync_level_editing()

    def _offer_background(self) -> None:
        """Fill the level palette with this level's placeable tiles."""
        snapshot = self._snapshot
        if (
            snapshot is None
            or not snapshot.layer2_background
            or not snapshot.layer2_low
        ):
            self.level_palette.set_tiles([])
            return
        self.level_palette.set_tiles(
            [raster_to_image(raster) for raster in background_thumbnails(snapshot)],
            first=background_tiles(snapshot).start,
        )

    def _bg_armed(self, payload: BackgroundTile) -> None:
        """Take ``payload`` from the palette: the next click places it."""
        # Arming a placement drops the selection, as it does for records: a
        # click means "put it here" now, so the ants would mark something no
        # gesture can reach. A floating paste is fixed where it sits first.
        self._bg_hand.land()
        self._bg_select(frozenset())
        self._bg_placing = payload
        self._placing_at = None
        snapshot = self._snapshot
        if snapshot is not None:
            blocks = Blocks(snapshot, layer2=True)
            self._bg_tile_image = raster_to_image(
                Raster(BLOCK, BLOCK, b"".join(blocks.rows(payload.number)))
            )
        self.view.set_hover_cursor(Qt.CursorShape.CrossCursor)
        self._draw_overlays()
        self.statusBar().showMessage(
            f"Placing tile {hexnum(payload.number)}", EDIT_REFUSED_MS
        )

    def _bg_stop_placing(self) -> None:
        """Put the tile down, and roll back a stroke that never committed.

        The Layer 2 mode's half of what the right button and Escape mean;
        safe with nothing in hand, like :meth:`_stop_placing`. A floating
        paste lands too: every caller means "the gesture is over".
        """
        self._bg_hand.land()
        if self._bg_stroke is not None:
            # The stroke's feedback was painted straight into the picture;
            # the document never moved, so it says what to paint back.
            self._bg_stroke = None
            self._sync_background()
        if self._bg_placing is None:
            return
        self._bg_placing = None
        self._bg_tile_image = None
        self._placing_at = None
        self.level_palette.disarm()
        self.view.set_hover_cursor(None)
        self._draw_overlays()

    def _bg_clicked(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        # Any click lands the floating paste: what follows is a new gesture,
        # and the float's one step is no longer the one being refined.
        self._bg_hand.land()
        if modifiers & Qt.KeyboardModifier.AltModifier:
            self._bg_pick_up(pos)
            return
        if self._bg_placing is not None:
            self._bg_place(pos, modifiers)
            return
        if self._doc is None or not self._doc.layer2:
            return
        # A bare click selects the block under it, shift toggles -- the world
        # map's Layer 2 gestures. The selection is *blocks*, one instance,
        # even though the entry behind each repeats across the level: the
        # ants mark where the gesture works, not everywhere the pattern
        # shows. Shift toggles by the entry, so the selection can never hold
        # the same entry twice under two of its repeats.
        block = (pos.x() // BLOCK, pos.y() // BLOCK)
        if modifiers & Qt.KeyboardModifier.ShiftModifier:
            entry = background_index(*block)
            twins = {
                held for held in self._bg_selection if background_index(*held) == entry
            }
            self._bg_select(
                self._bg_selection - twins if twins else self._bg_selection | {block}
            )
        else:
            self._bg_select(frozenset({block}))

    def _bg_pick_up(self, pos: QPoint) -> None:
        """The eyedropper: arm the tile already at ``pos``."""
        if self._doc is None or not self._doc.layer2 or self._snapshot is None:
            return
        entry = self._doc.layer2[background_index(pos.x() // BLOCK, pos.y() // BLOCK)]
        page = background_tiles(self._snapshot).start
        self.level_palette.pickup(BackgroundTile(page + entry))

    def _bg_place(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """Put the armed tile into the pattern at ``pos``.

        Plain places once and shift keeps the tool, the record placement's
        convention -- and a drag paints instead, so a run does not need the
        modifier.
        """
        placing = self._bg_placing
        if placing is None or self._doc is None:
            return
        index = background_index(pos.x() // BLOCK, pos.y() // BLOCK)
        if not self._commit(
            self._doc.layer2_placed({index: placing.number}), self._bg_hand.mark()
        ):
            return
        if not modifiers & Qt.KeyboardModifier.ShiftModifier:
            self._bg_stop_placing()

    def _bg_drag_begun(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """A drag with a tile in hand paints; with nothing in hand, one begun
        on the selection **moves** it -- lifting it into a float first when it
        is not one yet -- and one begun anywhere else boxes a selection. The
        records' conventions, tile for tile: shift always boxes, so a box can
        still start from inside a selection."""
        if self._doc is None or not self._doc.layer2:
            return
        if self._bg_placing is not None:
            self._bg_stroke = self._doc
            self._bg_paint(pos)
            return
        block = (pos.x() // BLOCK, pos.y() // BLOCK)
        if (
            block in self._bg_selection
            and not modifiers & Qt.KeyboardModifier.ShiftModifier
        ):
            # Taking hold of the selection: a paste already floats, and a
            # settled selection is lifted into one -- its tiles come along
            # and the spots they leave stay blank while it is in the air.
            self._bg_hand.take(*block)
            return
        self._bg_hand.land()
        self._marquee = (pos, pos)
        self._bg_marquee_from = (
            self._bg_selection
            if modifiers & Qt.KeyboardModifier.ShiftModifier
            else frozenset()
        )
        self._bg_select(self._bg_marquee_from | self._bg_caught())

    def _bg_drag_moved(self, pos: QPoint) -> None:
        if self._bg_stroke is not None:
            self._bg_paint(pos)
            return
        if self._bg_hand.grab is not None:
            self._bg_float_hover(pos)
            return
        if self._marquee is None:
            return
        self._marquee = (self._marquee[0], self._bg_marquee_clamped(pos))
        self._bg_select(self._bg_marquee_from | self._bg_caught())

    def _bg_drag_ended(self, pos: QPoint) -> None:
        """The stroke commits whole: one undo step however far it ran --
        and a carried float lands its step the same way, rewritten in place
        rather than added to."""
        if self._bg_stroke is not None:
            self._bg_paint(pos)
            stroke, self._bg_stroke = self._bg_stroke, None
            # The feedback painted the picture already; the commit is what
            # makes it the document's answer, one step against the level the
            # stroke began on. A stroke that changed nothing commits nothing,
            # and the picture was never touched.
            self._commit(stroke, self._bg_hand.mark())
            return
        if self._bg_hand.grab is not None:
            self._bg_float_hover(pos)
            self._bg_hand.settle()
            return
        if self._marquee is None:
            return
        self._bg_drag_moved(pos)
        self._marquee = None
        self._draw_overlays()

    def _bg_marquee_clamped(self, pos: QPoint) -> QPoint:
        """``pos`` held within one pattern's reach of the marquee's start.

        The pattern repeats every 32x27 blocks, so a box wider than that
        would wrap onto entries it already caught -- a selection overlapping
        itself. Clamped in the box's own pixels, so what is drawn and what is
        caught stop growing together.
        """
        assert self._marquee is not None
        start = self._marquee[0]
        c0, r0 = start.x() // BLOCK, start.y() // BLOCK
        left = (c0 - BACKGROUND_COLUMNS + 1) * BLOCK
        top = (r0 - BACKGROUND_ROWS + 1) * BLOCK
        return QPoint(
            min(max(pos.x(), left), (c0 + BACKGROUND_COLUMNS) * BLOCK - 1),
            min(max(pos.y(), top), (r0 + BACKGROUND_ROWS) * BLOCK - 1),
        )

    def _bg_caught(self) -> frozenset[tuple[int, int]]:
        """Every block the marquee's box covers -- at most one pattern's
        worth, by :meth:`_bg_marquee_clamped`, so no entry twice."""
        box = self._marquee_rect()
        if box is None:
            return frozenset()
        return frozenset(
            (column, row)
            for column in range(box.left() // BLOCK, box.right() // BLOCK + 1)
            for row in range(box.top() // BLOCK, box.bottom() // BLOCK + 1)
        )

    def _bg_select(self, blocks: frozenset[tuple[int, int]]) -> None:
        """Hold ``blocks`` as the painting mode's selection, and keep the
        ants and the Edit rows in step -- `_select`'s twin for the pattern."""
        if blocks == self._bg_selection:
            return
        self._bg_selection = blocks
        self._draw_overlays()
        self.sync_edit_actions()

    def _bg_selection_overlays(self) -> list[Overlay]:
        """The painting selection's ants: one instance, on the blocks the
        gesture named. The entry behind each block repeats across the level
        and an edit reaches every repeat -- the *picture* says so when one
        lands -- but ants on all of them would bury the level in dashes, so
        they mark where the gesture works."""
        if not self._painting or not self._bg_selection or self._shape is None:
            return []
        cells = tuple(
            QRect(column * BLOCK, row * BLOCK, BLOCK, BLOCK)
            for column, row in sorted(self._bg_selection)
        )
        bounding = cells[0]
        for cell in cells[1:]:
            bounding = bounding.united(cell)
        return [
            Overlay(bounding, color, dash=dash, cells=cells)
            for color, dash in ((SELECTION_LINE, 0), (SELECTION_DASH, DASH_LENGTH))
        ]

    # -- the floating selection -----------------------------------------------
    #
    # The machinery is
    # :class:`~shiny_mushroom.tile_clipboard.FloatController`, shared with the
    # world map's; `_bg_hand` is the window's answers for it, above. What is
    # left here is what the gestures mean: which of them land a float, and
    # what the status bar says about one.

    def _bg_float_hover(self, pos: QPoint) -> None:
        """Show the carried float under the pointer."""
        self._bg_hand.hover(pos.x() // BLOCK, pos.y() // BLOCK)

    # -- the painting mode's clipboard ---------------------------------------
    #
    # Copy, cut, paste and delete over the held pattern entries, exactly as
    # the world map's Layer 2 tab has them, and through the same relative
    # geometry -- see :mod:`shiny_mushroom.tile_clipboard`. The window's Edit
    # rows land here while the mode is up, so Ctrl+C is one key whichever
    # part of the level it is copying.

    def _bg_copy(self) -> None:
        """Take a copy of the held blocks' entries, as values with relative
        geometry -- the blocks' own shape, so the copy pastes back looking
        the way it was taken."""
        doc = self._doc
        if doc is None or not doc.layer2 or not self._bg_selection:
            return
        self._bg_clipboard = TileClipboard(
            *relative(
                (column, row, doc.layer2[background_index(column, row)])
                for column, row in sorted(self._bg_selection)
            )
        )
        self.sync_edit_actions()
        self.statusBar().showMessage(
            f"Copied {_plural(len(self._bg_selection), 'tile')}", 3000
        )

    def _bg_cut(self) -> None:
        """Copy the held entries, then take them out -- in that order, as the
        records cut."""
        self._bg_copy()
        self._bg_delete()

    def _bg_delete(self) -> None:
        """Take the held entries out of the pattern: each goes to tile ``$00``,
        the same spelling of "nothing here" the world map's Layer 2 uses.

        Deleting a **floating** paste means the other thing: put back what
        was beneath. That is an undo of the paste's one step, not a blanking
        of the ground under it.
        """
        held = self._bg_hand.held
        if held is not None:
            if self._bg_hand.cancel() is FloatStep.LANDED:
                # Something else committed over the float's step, so nothing
                # was taken out and nothing is claimed.
                return
            self.statusBar().showMessage(
                f"Deleted {_plural(len(held.holes), 'tile')}"
                if held.holes
                else "Removed the floating paste",
                3000,
            )
            return
        if self._doc is None or not self._bg_selection:
            return
        gone = len(self._bg_selection)
        entries = {background_index(*block) for block in self._bg_selection}
        # Undoing the deletion brings the tiles back held, which is where the
        # gesture started.
        if self._commit(
            self._doc.layer2_placed(dict.fromkeys(entries, 0)), self._bg_hand.mark()
        ):
            self.statusBar().showMessage(f"Deleted {_plural(gone, 'tile')}", 3000)
        self._bg_select(frozenset())

    def _bg_paste(self) -> None:
        """Land the clipboard under the pointer -- or centred on the
        viewport, where the user is looking -- and leave it **floating**:
        committed, but still the one edit a drag may move.

        Putting down the armed tile is for the same gesture: a drag paints
        while one is in hand, so a float pasted under it could never be
        grabbed.

        The anchor is clamped so the whole copy sits on the level: the
        pattern behind it wraps every 32 columns, so a copy allowed to hang
        past an edge would wrap onto itself.
        """
        held = self._bg_clipboard
        if held is None or self._doc is None or not self._background_editable():
            return
        self._bg_stop_placing()  # lands a second paste's float too
        assert self._shape is not None
        if self._pointing_at is not None:
            at = self._pointing_at
        else:
            middle = self.view.looking_at
            at = centred(held.entries, (middle.x() // BLOCK, middle.y() // BLOCK))
        anchor = clamped(held.entries, at, self._shape.columns, self._shape.rows)
        base = self._doc
        placed = landing(held.entries, anchor, background_index)
        doc = base.layer2_placed(placed)
        blocks = self._bg_hand.covering(held.entries, anchor)
        # What the paste was made from is the clipboard, so that is what an
        # undo of it gives back: the copy, floating here again.
        mark = SelectionMark(blocks, held.entries, anchor)
        if doc is not base and not self._commit(doc, mark):
            return
        self._bg_hand.carry(base, held.entries, anchor, mark)
        self._bg_select(blocks)
        self.statusBar().showMessage(
            f"Pasted {_plural(len(placed), 'tile')} -- drag to move, "
            "click away to set down",
            3000,
        )

    def _bg_paint(self, pos: QPoint) -> None:
        """Apply the armed tile at ``pos`` to the working stroke, painting
        the changed blocks as immediate feedback -- the document moves only
        when the stroke commits."""
        placing = self._bg_placing
        if placing is None or self._bg_stroke is None:
            return
        index = background_index(pos.x() // BLOCK, pos.y() // BLOCK)
        painted = self._bg_stroke.layer2_placed({index: placing.number})
        if painted is self._bg_stroke:
            return
        self._bg_stroke = painted
        self._show_background(painted.layer2)

    def _bg_track(self, pos: QPoint) -> None:
        """Follow the pointer with the tile's ghost while one is in hand,
        painting under it where a stroke is down: :meth:`_track_placement`'s
        twin for the painting mode, over the same :meth:`_move_ghost`."""
        if self._bg_placing is None:
            return
        if self._move_ghost(pos) and self._bg_stroke is not None:
            self._bg_paint(pos)

    def _sync_background(self) -> None:
        """Bring the picture's background in step with the document's.

        The one reconciliation point: a commit, an undo and a stroke rollback
        all land here, and a picture already in step costs nothing.
        """
        if self._snapshot is None or self._doc is None or not self._doc.layer2:
            return
        if not self._snapshot.layer2_background:
            return
        self._show_background(self._doc.layer2)

    def _show_background(self, layer2: bytes) -> None:
        """Paint the picture as it looks with ``layer2`` behind it.

        A patch of the changed blocks' every repeat -- `changed_blocks` fans
        one pattern entry out across the level -- and a full render only when
        it says the whole picture moved, which is :meth:`_redraw_over`'s
        whole job. Nothing is drawn at all before the level's first render:
        there is no picture yet for the pattern to be behind.
        """
        previous = self._snapshot
        if previous is None or previous.layer2_low == layer2:
            return
        self._snapshot = replace(previous, layer2_low=layer2)
        if not self._picture.drawn:
            return
        self._redraw_over(previous)

    # -- what the create panel is offering ----------------------------------
    #
    # All of it is :class:`~shiny_mushroom.ui.previews.Previews`, which owns the
    # pictures, the "have we asked" bookkeeping and the two round trips that
    # fill them in. What stays here is the two things it cannot work out for
    # itself: the level it is describing, and when a probe is worth starting.

    def _held(self) -> Held | None:
        """The level on the canvas, as the catalogue needs to see it.

        ``None`` whenever there is no level -- a byte map, an empty window, a
        cartridge between loads -- which is every case in which a question about
        what can be placed has no answer.

        The ROM goes in only when it is one the base's offsets mean anything in,
        because the only thing the catalogue does with it is build patches: a
        probe against a short file would read off the end of it. See
        :attr:`_addressable`.
        """
        if self._doc is None or self._snapshot is None or self._level is None:
            return None
        return Held(
            level=self._level,
            doc=self._doc,
            snapshot=self._snapshot,
            index=self._index,
            drawn=self._drawn,
            rom=self._rom if self._addressable else None,
            addresses=self._addresses,
        )

    def _probe_catalog(self) -> None:
        """Ask what every object in this tileset draws, once the level is up.

        **After the level is on screen, never before it.** Nobody is waiting on
        a thumbnail, and the loader answers in order -- so a probe asked for
        first would put its ~200 ms in front of the picture somebody is actually
        waiting for. That ordering is the window's to keep, which is why this
        one line stays here rather than moving with the rest.
        """
        self._catalog.probe()

    # -- editing ------------------------------------------------------------
    #
    # Every gesture that changes the level lands here, and every one of them
    # goes the same way: ask the document for the level it would become, commit
    # that, and let the commit decide what has to be redrawn.
    #
    # **The picture is the expensive half, and it is not this window's to draw.**
    # A level is drawn by running the cartridge's own loader, so the only way to
    # see an edited one is to hand the loader the edited bytes and ask again --
    # a round trip of ~60 ms, measured on level $105: ~55 in the worker
    # including IPC, and ~4 here for the picture that comes back, which is a
    # patch of the blocks the edit moved. Opening a level rather than refreshing
    # one is ~185. The outlines are ~2 ms, being geometry over a
    # picture that is already there. So the two are deliberately split: a gesture
    # moves the outlines at once and asks for the picture after, and a drag does
    # not ask at all until it is let go -- see `_drag_moved`, where the step is
    # drawn rather than applied.

    def _commit(self, level: Level | None, mark: SelectionMark | None = None) -> bool:
        """Make ``level`` the document, with an undo step, and redraw.

        Reports whether anything actually changed. A level that is the one
        already held -- which is what every operation returns when it had
        nothing to do, a drag against the edge or a resize of something with no
        size -- is not committed and costs nothing.

        ``mark`` is what an undo of this step puts the painting mode's
        selection back to -- see
        :meth:`~shiny_mushroom.tile_clipboard.FloatController.mark`. The record
        edits spell none: their selection is uids, which an undo carries home
        with the records themselves.

        **Nothing commits while a level is being opened.** Disabling the view is
        what stops a gesture from starting, and this is what makes it a property
        of the editor rather than of one widget: an edit that arrived anyway --
        a menu action, a shortcut, a test -- would be applied to the outgoing
        level and thrown away with it a moment later.

        That covers the wait for the player's artwork too. There the document is
        already the arriving level's, so the edit would not be lost -- but the
        level is still opening, the marker that says where it starts is not on
        it, and an editor that took an edit in one half of a load and refused it
        in the other would be answering the same gesture two ways.

        **And it says so.** No gesture should reach here at all -- the modal over
        the load takes the keyboard for the whole of it -- but a refusal is only
        the last line if it is also an audible one. An edit turned away without a
        word is an edit the person made, watched do nothing, and has no reason to
        make again, and that is not a state to leave reachable by a path nobody
        has thought of yet.

        **``None`` is the operation's own refusal**, and it gets the same
        treatment for the same reason. It is not a level that changed nothing:
        the edit was one the streams cannot hold -- see
        :meth:`~shiny_mushroom.edit.Level._rebuild` -- and it is the one
        outcome a caller could not otherwise tell from a drag against the edge.
        Every operation reaches this through a call site that already hands its
        result straight here, so the answer is given in one place rather than
        at each gesture. It is said *after* the load's own refusal, which is
        the more useful of the two whenever both are true: an edit made
        against an outgoing level was never going to land whatever its rows
        would have encoded to.
        """
        if self._replacing or self._awaiting_player_art:
            self.statusBar().showMessage(EDIT_REFUSED, EDIT_REFUSED_MS)
            return False
        if level is None:
            self.statusBar().showMessage(EDIT_UNWRITABLE, EDIT_REFUSED_MS)
            return False
        before = self._doc
        if self._history is None or not self._history.commit(level, mark):
            return False
        self._settle(level)
        # A background-only edit needs no reload: the background is drawn by
        # this editor from the document's own bytes -- `_settle` has already
        # patched the picture -- and the records the game would redraw have
        # not moved. The emulator's copy catches up through `test_patches`
        # whenever something next asks for it.
        if not self._records_moved(before, level):
            return True
        self._refresh_picture()
        return True

    def _settle(self, level: Level) -> None:
        """Hold ``level`` and put everything that reads it back in step.

        **The observed footprints come along.** They are what the loader saw
        each object draw, and the loader does not run again until the picture is
        redrawn ~60 ms later -- so between the edit and the picture
        they are the only thing the outlines have to go on. Left alone, they
        would describe where each object *was*: the ants would snap back to the
        position a drag started from and then jump forward again when the
        picture landed, which is the one moment the user is looking straight at
        them. :func:`~shiny_mushroom.objects.carried_footprints` moves them with
        the records instead.

        **The shape comes along too**, for the one edit that can change it: a
        header. The picture is a round trip behind, exactly as it is for a move
        -- but the grid, the screen numbers and the position readout are
        geometry over it and are free, so they follow at once rather than
        waiting.
        """
        if self._doc is not None:
            # Both object streams, because a Layer 2 record's outline has to
            # follow its drag the same way Layer 1's does -- and the uids are
            # one pool, so the two calls build up one map.
            self._drawn = carried_footprints(
                self._drawn, self._doc.objects, level.objects
            ) | carried_footprints(
                self._drawn, self._doc.layer2_objects, level.layer2_objects
            )
        self._doc = level
        if self._shape != level.shape:
            self._shape = level.shape
            self._show_screen_grid(level.shape)
        # The background is this editor's to paint -- see `_sync_background`.
        # Here, so a commit and an undo repaint it through the one path.
        self._sync_background()
        # And the level's own graphics, for the same reason and by the same
        # rule: the tiles are drawn out of the capture's VRAM, so a row that
        # moved is written into it rather than waited for -- see
        # `_sync_graphics`.
        self._sync_graphics()
        # A record the edit removed cannot stay selected, and the panel has to
        # stop describing it.
        self._select(self._selection)
        # Refreshed rather than rebuilt: an edit made *in* the panel would
        # otherwise destroy the widget it came from, taking the keyboard out of
        # the box the user is still working in. This falls back to a rebuild
        # whenever the rows are no longer the ones on show.
        self._refresh_properties()
        self._show_screen_exits()
        # What the level holds is what the "in this level" filter answers with.
        self._catalog.offer()
        # The outlines of everything a gesture is not holding are cached for the
        # length of that gesture, and this is a gesture that commits while it is
        # still running -- shift-clicking a row of blocks into place. The
        # document has moved, so the cache has to go with it.
        self._resting = None
        self._draw_overlays()
        self._update_title()
        # The window is a view of the document too -- the entrance rows
        # and the heading follow every commit and undo.
        self._refresh_load_path()
        # There is something to undo now, or there is not any more, and Ctrl+Z
        # is only a live key while the action behind it is enabled.
        self.sync_edit_actions()

    def _records_moved(self, before: Level | None, after: Level) -> bool:
        """Whether ``after`` differs from ``before`` in anything the *game*
        draws -- everything but the background, which is this editor's own
        rendering and needs no reload to show."""
        return (
            before is None
            or after.objects != before.objects
            or after.sprites != before.sprites
            or after.layer2_objects != before.layer2_objects
            or after.header != before.header
            or after.sprite_header != before.sprite_header
            # The secondary header is read by the game's own load -- the
            # entrance, the camera, the Layer 3 background -- so a change to
            # it is a change to the picture.
            or after.secondary != before.secondary
        )

    def _refresh_picture(self) -> None:
        """Ask the emulator to draw the level as the document now has it.

        The level is loaded again with the edited streams written over the
        core's copy of the cartridge -- see
        :func:`~shiny_mushroom.rom_patches.level_patch` -- because the picture is
        the game's own work and there is no shortcut to it that would still be
        the game's answer.

        A cartridge with nowhere to put a stream that has grown is a real
        answer and not a crash: the edit stands, the outlines are right, and the
        status bar says the picture could not be redrawn.

        **One request in flight, and one pending slot that is overwritten.** The
        loader answers requests strictly in order and cannot be told to abandon
        one, so an editor that asked per edit would queue them: measured, four
        arrow-key nudges 150 ms apart produced four serial loads and the right
        picture 1.3 seconds later, and holding the key down did it at the
        keyboard's repeat rate. Only the *last* document is worth a picture, so
        a refresh asked for while one is out sets a flag instead of queueing,
        and :meth:`_show_level` starts the one that matters when the machine
        comes free. The backlog is one load, whatever the fingers do.
        """
        if self._doc is None or self._level is None or self._loader is None:
            return
        if self._loading:
            self._refresh_pending = True
            return
        try:
            patches = self.test_patches()
        except ValueError as error:
            self.statusBar().showMessage(f"Could not redraw the level: {error}", 8000)
            return
        self.load_level(self._level, patches, refreshing=True)

    def _project_patches(self) -> dict[int, bytes]:
        """What the open project has already saved for the level being loaded."""
        return cart_patches.project_patches(
            self._project,
            self._rom,
            self._level,
            self._addresses,
            self._build_symbols(),
            self._status_message,
        )

    def _layer2_pointer_patch(self) -> dict[int, bytes]:
        """The project's repointed Layer 2 entry for this level, over the
        image's own table -- the label resolved through :meth:`_build_symbols`.

        A repoint whose label no symbol file resolves is one more thing a run
        cannot be made to show, so it reports where the others do."""
        return cart_patches.layer2_pointer_patch(
            self._project,
            self._rom,
            self._level,
            self._addresses,
            self._build_symbols(),
            lambda parts: self._note_skipped(POINTER_PARTS, parts),
        )

    def _build_symbols(self) -> SymbolTable | None:
        """The open project's build symbols, or ``None`` before a first build.

        Held against the file's identity rather than re-parsed per level load:
        the table is asked for on every load and redraw, and only a build
        moves it. A changed stat re-reads; a changed project changes the path,
        which is part of the key.
        """
        if self._project is None:
            return None
        path = symbol_file(self._project)
        try:
            stat = path.stat()
        except OSError:
            return None
        key = (str(path), stat.st_mtime_ns, stat.st_size)
        if self._symbols_held is not None and self._symbols_held[0] == key:
            return self._symbols_held[1]
        try:
            table = load_symbols(path)
        except OSError:
            return None
        self._symbols_held = (key, table)
        return table

    def undo(self) -> None:
        """Take back the last edit, in whichever document is on the canvas."""
        self._edit_surface().walk(back=True)

    def redo(self) -> None:
        """Put back the edit that was taken back."""
        self._edit_surface().walk(back=False)

    def _walk_world(self, back: bool) -> None:
        """One step along the world map's stack, said out loud --
        :meth:`_walk_history`'s twin for the map, which keeps its own."""
        if back:
            self._world.undo()
        else:
            self._world.redo()
        self.statusBar().showMessage("Undo" if back else "Redo", 2000)

    def _walk_history(self, back: bool) -> None:
        """Move one step along the undo stack and show where that landed.

        The two directions are the same operation and are written once: ask the
        history to move, and if it did, settle the level it now holds and ask
        for a picture of it. They are **not** :meth:`_commit` -- there is no new
        step to push, and the level being settled is one the stack already
        holds.

        **The selection walks with the document.** What is held now is handed
        to the stack for the step being left -- so coming back finds it as it
        was -- and whatever the step being restored held comes back with it.
        """
        if self._history is None:
            return
        # A step wearing a repoint's mark edits the project's pointer table as
        # well as the document, so it is recognised before the stack moves.
        ahead = self._history.ahead(back)
        if isinstance(ahead, RepointMark):
            self._walk_repoint(back, ahead)
            return
        # A floating paste lands before the walk: it is the top of the stack,
        # so the undo that follows takes the whole paste back in one press.
        # What it was is read off first: a paste in hand is part of the state
        # a step back here should find again.
        mark = self._bg_hand.mark()
        self._bg_hand.land()
        if not (self._history.undo(mark) if back else self._history.redo(mark)):
            return
        before = self._doc
        self._settle(self._history.level)
        self._bg_hand.restore(self._history.mark)
        # The same economy `_commit` keeps: a step that only moved the
        # background was painted by `_settle`, and the game has nothing to
        # redraw.
        if self._records_moved(before, self._history.level):
            self._refresh_picture()
        said = "Undo" if back else "Redo"
        if self._bg_hand.held is not None:
            said += " -- the paste is back in hand; drag to place it"
        self.statusBar().showMessage(said, 2000)

    def _walk_repoint(self, back: bool, mark: RepointMark) -> None:
        """Walk across a Layer 2 repoint step -- :meth:`_walk_history` for the
        one step whose edit is not in the document.

        The pointer lives in the project's table, so whichever way the walk
        crosses it the table is rewritten to the end being stepped onto --
        and rewritten *first*, because a table that cannot be written must
        leave the stack where it is. The mark is handed back into the walk,
        which files it with the step's other half: it stays on the boundary
        for the walk back the other way.

        The document that comes back was parsed under the other pointer, so
        nothing derived from this one survives. The selection, the hand and
        the footprints are dropped rather than pruned -- the replacing parse
        re-used the uid pool, so a stale id would answer for somebody else's
        record -- and the picture, the palette's offer and the editing mode
        follow from the refresh (:attr:`_layer2_chrome_stale`).
        """
        if self._project is None or self._level is None or self._history is None:
            return
        target = mark.before if back else mark.after
        try:
            self._project.save_layer2_pointer(self._level, target)
        except (Layer2TableError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(self._level, 3)}'s Layer 2 could not be repointed.",
                detail=str(error),
            )
            return
        if not (self._history.undo(mark) if back else self._history.redo(mark)):
            return
        self._bg_hand.land()
        self._bg_select(frozenset())
        self._stop_all_placing()
        self._select(frozenset(), redraw=False)
        self._drawn = {}
        self._settle(self._history.level)
        self._layer2_chrome_stale = True
        self._repointed_layer2(target)
        self._refresh_picture()
        self.statusBar().showMessage(
            f"{'Undo' if back else 'Redo'} -- Layer 2 reads {target.describe()} again",
            3000,
        )

    def delete_selection(self) -> None:
        """Take everything held out of whatever is being edited."""
        self._edit_surface().delete()

    def _delete_records(self) -> None:
        """Take the held records out of the level.

        Commands included, unlike a move: a screen exit has no position to drag
        but it is a record like any other, and this is how one is taken out.
        """
        if self._doc is None or not self._selection:
            return
        gone = len(self._selection)
        if self._commit(self._doc.without(self._selection)):
            self._select(frozenset())
            self.statusBar().showMessage(f"Deleted {_plural(gone, 'record')}", 3000)

    # -- the clipboard ------------------------------------------------------
    #
    # Copy, cut, paste and duplicate, over as many records as are held. There is
    # nothing here that a single record does differently from a group: what a
    # copy takes is `Level.records(selection)`, which is one record or six by
    # the same call, and `Level.landing` carries whatever it is given as one
    # shape.
    #
    # **The clipboard holds records, not bytes.** A stream is only meaningful
    # beside the level that holds it -- the jumps in it place the records after
    # it, and `_rebuild` re-derives them per write -- so a clipboard of bytes
    # would have to be re-parsed against a geometry it was not copied under. The
    # records go back in through `added`, which is the same door a placement
    # from the create panel uses.
    #
    # **And it is this window's, not the system's.** What is on it is records
    # from *this cartridge's* vocabulary: an object number is a different object
    # under a different tileset and a sprite number is whatever that cart's
    # tables say. Offering that to another application, or taking a paste from
    # one, would be offering a number without the thing that gives it a meaning.

    def copy_selection(self) -> None:
        """Take a copy of everything held."""
        self._edit_surface().copy()

    def _copy_records(self) -> None:
        """Take a copy of the held records.

        The records themselves, ids and offsets and all -- every one of those is
        overwritten on the way back in, by :meth:`~shiny_mushroom.edit.Level.added`
        for the id and by the rewrite for the rest. What survives the trip is
        what a record actually *is*: its number, its settings and where it sits
        relative to the others.
        """
        if self._doc is None or not self._selection:
            return
        self._clipboard = tuple(self._doc.records(self._selection))
        self._clipboard_tileset = self._doc.fg_bg_tileset
        self.sync_edit_actions()
        self.statusBar().showMessage(
            f"Copied {_plural(len(self._clipboard), 'record')}", 3000
        )

    def cut_selection(self) -> None:
        """Take a copy of everything held and then take it out.

        Copy and delete, in that order and with nothing between them, so a cut
        whose delete is refused -- a level still opening -- has still filled the
        clipboard. The undo step is the delete's: taking a copy changes nothing
        about the document and has nothing to take back.
        """
        self._edit_surface().cut()

    def _cut_records(self) -> None:
        """Copy the held records, then take them out."""
        if self._doc is None or not self._selection:
            return
        self._copy_records()
        gone = len(self._selection)
        if self._commit(self._doc.without(self._selection)):
            self._select(frozenset())
            self.statusBar().showMessage(f"Cut {_plural(gone, 'record')}", 3000)

    def paste(self) -> None:
        """Put the clipboard into whatever is being edited, at the pointer."""
        self._edit_surface().paste()

    def _paste_records(self) -> None:
        """Put the record clipboard into the level, at the pointer.

        **Where the pointer is**, when it is on the picture: a paste is a
        placement, and the only placement gesture this editor has already puts
        what is in hand under the cursor. Where it is not -- a paste from the
        menu, or with the mouse out in the panels -- the copy lands one block
        down and right of where it was taken from, which is the same offset a
        duplicate uses and for the same reason: a copy that arrives exactly on
        top of the original looks like a gesture that did nothing.
        """
        if self._doc is None or not self._clipboard:
            return
        at = self._pointing_at or landing_beside(group_origin(self._clipboard))
        self._put_down(self._clipboard, at, "Pasted")

    def duplicate_selection(self) -> None:
        """Put a second copy of everything held into the level.

        Copy and paste in one gesture, and deliberately **not** through the
        clipboard: duplicating something is not a statement about what you want
        to paste next, and an editor that threw away a copy every time one was
        duplicated would be losing work in a way nothing on the screen says.

        It ignores the pointer, unlike a paste. A duplicate says "another one of
        these, here" rather than "one of these, there", so it lands beside the
        original wherever the mouse happens to be resting.
        """
        if self._doc is None or not self._selection:
            return
        records = self._doc.records(self._selection)
        self._put_down(records, landing_beside(group_origin(records)), "Duplicated")

    def _put_down(
        self, records: Sequence[Record], at: tuple[int, int], said: str
    ) -> None:
        """Land ``records`` with their origin at ``at``, and hold what arrived.

        The one place a paste and a duplicate differ is the anchor they work
        out, so everything after that is here: trim the group into the level,
        add it on top, select it, say so.

        **What was placed is selected**, exactly as a placement's is, and for
        the same reason -- it is the thing you just made, it is what the
        properties panel should be describing, and the arrows are how it is
        moved off the thing it landed on. The ids are consecutive because
        :meth:`~shiny_mushroom.edit.Level.added` hands them out in order, so the
        range is the answer and nothing has to be collected.

        A placement still in hand is put down, because a ghost under the pointer
        and ants around what has just arrived are the two answers to one question
        that :meth:`_arm_placement` already refuses to have both of. **After the
        commit**, so a paste refused by a level still opening leaves the tool
        armed -- the same bargain :meth:`_place_at` makes, and for the same
        reason: the gesture was fine and the moment was not.
        """
        if self._doc is None or not records:
            return
        first = self._doc.next_uid
        landed = self._doc.landing(records, *at)
        if not self._commit(self._doc.added(*landed, layer2=self._on_layer2)):
            return
        self._stop_placing()
        self._select(frozenset(range(first, first + len(landed))))
        self.statusBar().showMessage(
            f"{said} {_plural(len(landed), 'record')}{self._tileset_caveat(landed)}",
            5000,
        )

    def _tileset_caveat(self, records: Sequence[Record]) -> str:
        """What to add to a paste's readout when it crossed tilesets.

        An object number is a different object in a different tileset -- five
        tables, fifteen tilesets -- so a paste into a level that does not share
        the one the copy was taken under puts down a record that says what it
        said and *means* something else. Refusing it would be worse: the number
        is what was copied, hacks share objects across tilesets deliberately,
        and the editor has no business deciding which of those this is. So it
        lands, and the readout says what happened.

        Sprites are not mentioned. A sprite number means one thing across the
        cartridge -- only its artwork depends on a tileset, and that is the
        create panel's warning to give, not this one's.
        """
        # Guarded on the *document*, which is what the tileset is read out of.
        # The snapshot is a picture of it and says nothing about whether there
        # is a level to compare against.
        if self._clipboard_tileset is None or self._doc is None:
            return ""
        now = self._doc.fg_bg_tileset
        if now == self._clipboard_tileset:
            return ""
        if not any(isinstance(found, LevelObject) for found in records):
            return ""
        return (
            f" - copied under tileset {hexnum(self._clipboard_tileset, 0)}, "
            f"this level is {hexnum(now, 0)}"
        )

    def _note_pointer(self, pos: QPoint) -> None:
        """Remember which block the pointer is over, for a paste to land on."""
        self._pointing_at = (pos.x() // BLOCK, pos.y() // BLOCK)

    def _forget_pointer(self) -> None:
        """The pointer left the picture: a paste has no block to aim at.

        Cleared rather than left at the last block it was over, which would have
        a paste from the menu bar land wherever the mouse crossed the canvas on
        its way up there.
        """
        self._pointing_at = None

    # -- moving and resizing what is held ------------------------------------
    #
    # The keyboard's half of the two drag gestures above, plus the one edit that
    # has no drag at all. Each is the same shape: ask the document for the level
    # it would become, and commit it.

    def nudge_selection(self, columns: int, rows: int) -> None:
        """Move everything held by whole blocks."""
        if self._doc is not None and self._selection:
            self._commit(self._doc.moved(self._selection, columns, rows))

    def resize_selection(self, columns: int, rows: int) -> None:
        """Step the held record's size fields by ``(columns, rows)``.

        One record, because a resize is about a particular object's footprint
        and there is no useful meaning for "resize these six by one" when they
        are different shapes.

        **It drives the same field descriptors the properties panel renders**,
        which is what lets it reach every object the loader was measured sizing
        rather than only the fourteen the format promises. Which nibble of the
        settings byte is a width is a property of the object *and its tileset*,
        measured rather than assumed, and this is a place that has the tileset
        -- a record on its own does not, which is why the decision cannot sit in
        :mod:`shiny_mushroom.edit`.

        A **length** is not an axis. It is one extent in the object's own steps
        -- a slope grows along both axes at once, by an amount that depends on
        which slope -- so all four arrows drive it, forward on right and down.
        Guessing an axis for it would make one pair of arrows silently do
        nothing.

        **An object measured as two lengths gets one arrow pair each**, which is
        the one place a length is given an axis. Neither of them is one -- the
        diagonal ledge's two extents both grow it down and across -- but sharing
        a pair between them would step both at once and leave neither reachable
        on its own, and that is the worse of the two answers.
        """
        found = self._selected_fields()
        if self._doc is None or found is None:
            return
        record, fields = found
        by_key = {field.key: field for field in fields}
        if "width" in by_key or "height" in by_key:
            steps = [("width", columns), ("height", rows)]
        elif "length" in by_key:
            steps = [("length", columns + rows)]
        else:
            steps = [("low-length", columns), ("high-length", rows)]
        edited = record
        for key, delta in steps:
            field = by_key.get(key)
            if field is not None and delta:
                edited = field.applied(edited, field.value(edited) + delta)
        if edited is not record:
            self._commit(self._doc.replaced(record.uid, edited))

    def reorder_selection(self, delta: int) -> None:
        """Bring everything held one step forward, or send it one step back.

        Order is depth: the loader writes objects in stream order and each
        overwrites what the last one put there, and the sprite list is drawn the
        same way.
        """
        if self._doc is not None and self._selection:
            self._commit(self._doc.reordered(self._selection, delta))

    # -- the world map mode ---------------------------------------------------
    #
    # The canvas is shared between the two documents, so every mode-sensitive
    # gesture arrives at one of these dispatchers and is forwarded whole: to
    # the level handlers exactly as before, or to `self._world`, which owns
    # everything the world map is. The mode question lives here and in the
    # few window services below that answer differently per mode -- undo,
    # save, the title -- and nowhere else.

    def _canvas_clicked(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.clicked(pos, modifiers)
        elif self._painting:
            self._bg_clicked(pos, modifiers)
        else:
            self._select_at(pos, modifiers)

    def _canvas_clicked_away(self, modifiers: Qt.KeyboardModifier) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.clicked_away(modifiers)
        elif self._painting:
            # The surround means the same thing to both editing modes:
            # "nothing here", unless shift says "as well as". Putting the
            # selection down is also what sets a floating paste.
            if not modifiers & Qt.KeyboardModifier.ShiftModifier:
                self._bg_hand.land()
                self._bg_select(frozenset())
        else:
            self._clicked_away(modifiers)

    def _canvas_middle_clicked(
        self, pos: QPoint, modifiers: Qt.KeyboardModifier
    ) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.middle_clicked(pos, modifiers)
        elif self._mode is EditorMode.LEVEL:
            self._set_test_start(pos)

    def _canvas_right_clicked(self, image: QPoint | None, at: QPoint) -> None:
        """Put down what is in hand -- and with nothing in hand, offer the
        context menu for the spot.

        Two meanings on one button, decided by whether anything is armed:
        cancelling a placement is the gesture everyone reaches for mid-tool
        and is kept exactly as it was, and the menu takes the presses that
        used to mean nothing. A menu that also opened over an armed tool
        would need a "cancel" row for what one press already does.
        """
        if self._mode is EditorMode.WORLD:
            if self._world.right_clicked():
                return
        elif self._placing is not None or self._bg_placing is not None:
            self._stop_all_placing()
            return
        self._show_context_menu(image, at)

    # -- the context menu -----------------------------------------------------
    #
    # A second handle on gestures the editor already has, found under the
    # pointer: the Edit menu's own actions for the clipboard, the eyedropper,
    # the properties panel's buttons, the middle click's test-run setup, and
    # the ways from a record to the level it names. Nothing here is a new
    # edit -- see shiny_mushroom.ui.context_menu for the shape, and
    # docs/editor/context-menu.md for the rows each mode offers and why.

    @property
    def context_menu(self) -> QMenu | None:
        """The context menu last popped up. The window's own state, for
        tests: a menu is shown without blocking, so its rows can be read."""
        return self._context_menu

    def _show_context_menu(self, image: QPoint | None, at: QPoint) -> None:
        """Pop up the menu for image pixel ``image`` -- ``None`` off the
        picture -- anchored at widget position ``at``.

        What is under the pointer is selected first, unless it is held
        already, so the rows are about the thing the menu was opened over
        and the panel describes it. ``popup`` rather than ``exec``: the menu
        must not run a nested event loop the suite cannot get out of, and
        nothing here needs its answer.
        """
        if self._context_menu is not None:
            self._context_menu.deleteLater()
            self._context_menu = None
        rows = self._context_rows(image)
        menu = build(self, rows)
        if menu is None:
            return
        self._context_menu = menu
        menu.popup(self.canvas.mapToGlobal(at))

    def _context_rows(self, image: QPoint | None) -> list[Row | QAction | None]:
        """The rows for a right click at ``image``, by what the canvas is
        editing -- one list per editing environment, with the clipboard
        group shared."""
        if self._mode is EditorMode.WORLD:
            return self._world_context_rows(image)
        if self._doc is None:
            return []
        if self._painting:
            return self._layer2_context_rows(image)
        return self._record_context_rows(image)

    def _clipboard_rows(
        self, image: QPoint | None, *, records: bool
    ) -> list[Row | QAction | None]:
        """Cut, Copy, Paste, Delete -- and Duplicate and the reorder rows
        where the selection is records -- as the Edit menu's own actions,
        which keep their keys and their greying. Paste alone is the menu's
        own row, because the pointer left the picture for the menu and the
        paste has to land where the click was rather than where the pointer
        went."""
        rows = self.menu_actions
        paste = Row(
            "Paste",
            lambda: self._paste_at(image),
            enabled=rows.paste.isEnabled(),
            shortcut=rows.paste.shortcut().toString(),
        )
        group: list[Row | QAction | None] = [rows.cut, rows.copy, paste]
        if records:
            group.append(rows.duplicate)
        group.append(rows.delete)
        group.append(SEPARATOR)
        if records:
            group += [rows.forward, rows.back, SEPARATOR]
        return group

    def _paste_at(self, image: QPoint | None) -> None:
        """Paste, landing at ``image`` where there is one -- the place the
        menu was opened over, re-noted as the pointer because the paste
        reads the pointer and the pointer is on the menu."""
        if image is not None:
            if self._mode is EditorMode.WORLD:
                self._world.note_pointer(image)
            else:
                self._note_pointer(image)
        self.paste()

    def _record_context_rows(self, image: QPoint | None) -> list[Row | QAction | None]:
        """The records mode's rows: the clipboard and the order, the
        eyedropper, the level a screen exit names, the test start and the
        header."""
        assert self._doc is not None
        stack = [] if image is None else self._stack_at(image)
        if stack and not any(record.uid in self._selection for record in stack):
            # As a plain click selects: the topmost thing there. A selection
            # already under the pointer is kept whole, so a group is not
            # collapsed to the one record the menu was opened over.
            self._select({stack[0].uid})
        rows = self._clipboard_rows(image, records=True)
        rows.append(
            Row(
                "Pick",
                lambda: None if image is None else self._pick_up_record(image),
                enabled=bool(stack),
                shortcut="Alt+click",
            )
        )
        rows.append(SEPARATOR)
        # A screen exit names a level: the row opens it, through the gate
        # every other way of asking for a level goes through.
        held = self._doc.records(self._selection)
        if len(held) == 1 and isinstance(held[0], LevelObject):
            fields = held[0].fields(self._doc.fg_bg_tileset, self._doc.shape)
            destination = next(
                (found for found in fields if found.key == "destination"), None
            )
            if destination is not None:
                level = destination.value(held[0])
                rows.append(
                    Row(
                        f"Open level {hexnum(level, 3)}",
                        lambda: self._level_file_followed(level),
                    )
                )
        rows.append(SEPARATOR)
        rows += self._level_rows(image)
        return rows

    def _layer2_context_rows(self, image: QPoint | None) -> list[Row | QAction | None]:
        """The painting mode's rows: the clipboard over blocks, the
        eyedropper, the test start and the header."""
        if image is not None:
            block = (image.x() // BLOCK, image.y() // BLOCK)
            if block not in self._bg_selection:
                self._bg_clicked(image, Qt.KeyboardModifier.NoModifier)
        rows = self._clipboard_rows(image, records=False)
        rows.append(
            Row(
                "Pick",
                lambda: None if image is None else self._bg_pick_up(image),
                enabled=image is not None,
                shortcut="Alt+click",
            )
        )
        rows.append(SEPARATOR)
        rows += self._level_rows(image)
        return rows

    def _level_rows(self, image: QPoint | None) -> list[Row | QAction | None]:
        """What a level offers wherever it is right-clicked: the test start
        under the pointer, the header, and the load path."""
        rows: list[Row | QAction | None] = []
        if image is not None and self._snapshot is not None and self._level is not None:
            # The middle click's own arithmetic, so the caption says what the
            # click would do: clear the mark it is on, or set one.
            block_x = (image.x() // BLOCK) * BLOCK
            floor_y = (image.y() // BLOCK) * BLOCK + BLOCK
            here = PlayerPosition.standing_on(block_x, floor_y)
            rows.append(
                Row(
                    "Test runs start at the level's own entrance"
                    if self._player_at() == here
                    else "Start test runs here",
                    lambda: self._set_test_start(image),
                    shortcut="Middle-click",
                )
            )
        rows += [
            SEPARATOR,
            self.menu_actions.header,
            self.menu_actions.graphics_row,
            self.menu_actions.load_path,
        ]
        return rows

    def _world_context_rows(self, image: QPoint | None) -> list[Row | QAction | None]:
        """The world map's rows: the clipboard, the mode's own rows, and the
        level a selected tile loads."""
        if not self._world.ready:
            return []
        if image is not None:
            self._world.select_under(image)
        rows = self._clipboard_rows(image, records=False)
        rows += self._world.context_rows(image)
        rows.append(SEPARATOR)
        level, _cell, _reading, _world_mode = self._load_path_subject()
        if level is not None:
            rows.append(
                Row(
                    f"Open level {hexnum(level, 3)}",
                    lambda: self._load_path_level_edit(OPEN_LEVEL, 1),
                )
            )
            rows.append(self.menu_actions.load_path)
        return rows

    def _pick_up_record(self, pos: QPoint) -> None:
        """The eyedropper over records: arm the create panel with the thing
        under ``pos``, so the next click places another one.

        The held record when it is under the pointer -- the one reached by
        clicking down through a stack -- and the topmost otherwise, which is
        what a click there would take. The entry is the catalogue's own for
        the record's key, so what is armed is exactly what the panel offers,
        and a record the catalogue does not offer -- an unnamed object
        number, a screen jump -- says so rather than arming a guess.
        """
        stack = self._stack_at(pos)
        if not stack:
            return
        record = next(
            (found for found in stack if found.uid in self._selection), stack[0]
        )
        key = key_of(record)
        entry = next(
            (found for found in self.create.catalog(key[0]) if found.key == key),
            None,
        )
        if entry is None:
            self.statusBar().showMessage(
                "The Create panel does not offer this one", EDIT_REFUSED_MS
            )
            return
        self.create.show_tab(entry.stream)
        # Through the panel's own arming, so the highlight, the hint line and
        # the ghost all follow as they do for a row picked by hand.
        self.create.arm(entry)

    # -- the canvas's gestures, forwarded by mode -----------------------------
    #
    # Where the dispatchers above resume, after the menu the right button
    # opens. Same rule: the mode question is asked once, here, and each
    # gesture goes whole to the level's handler or to `self._world`.

    def _canvas_drag_begun(self, pos: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.drag_begun(pos, modifiers)
        elif self._painting:
            self._bg_drag_begun(pos, modifiers)
        else:
            self._drag_begun(pos, modifiers)

    def _canvas_drag_moved(self, pos: QPoint) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.drag_moved(pos)
        elif self._painting:
            self._bg_drag_moved(pos)
        else:
            self._drag_moved(pos)

    def _canvas_drag_ended(self, pos: QPoint) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.drag_ended(pos)
        elif self._painting:
            self._bg_drag_ended(pos)
        else:
            self._drag_ended(pos)

    def _canvas_cursor_moved(self, pos: QPoint) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.cursor_moved(pos)
            return
        self._show_position(pos)
        if self._painting:
            self._bg_track(pos)
            # A paste lands where the pointer is in this mode too.
            self._note_pointer(pos)
            return
        self._show_grip(pos)
        self._track_placement(pos)
        # Where a paste would land. Followed continuously rather than asked
        # for when Ctrl+V arrives, because by then the answer is a question
        # for the canvas about a cursor that may not be over it.
        self._note_pointer(pos)

    def _canvas_cursor_left(self) -> None:
        if self._mode is EditorMode.WORLD:
            self._world.cursor_left()
            return
        self._clear_position()
        self._drop_grip()
        self._drop_placement()
        self._forget_pointer()

    def _position_label_text(self, text: str) -> None:
        """The world map mode's status readout, as the callable it was handed."""
        self._position_label.setText(text)

    def _status_message(self, text: str, msecs: int = 0) -> None:
        """The status bar, as the callable a collaborator was handed."""
        self.statusBar().showMessage(text, msecs)

    # -- the world map's chrome ------------------------------------------------
    #
    # Entering and leaving the mode, and everything the window puts up or
    # takes down with it: the bars, the menu rows, the panels' turns, the
    # capture the mode is waiting on, and the map's own Save.

    def _world_changed(self) -> None:
        """The world map's document or selection moved: keep the chrome true."""
        self.sync_edit_actions()
        self._update_title()
        # Focusing an event turns the events view on inside the mode; the
        # menu toggle and the bar's box follow rather than lead. Re-checking
        # an already-checked action emits nothing, so this cannot loop.
        if self._mode is EditorMode.WORLD:
            self.menu_actions.world_events.setChecked(self._world.events_view)
        # The sheet can go up or down inside the mode -- a tab switch, a new
        # map -- so the dock's button and the map's chrome follow it here,
        # the way the event box follows the events view.
        self.tile_palette.set_sheet_editing(self._world.sheet_view)
        self._sync_world_bar_reach()
        self.world_bar.set_event(self._world_event_pick())
        # Auto-select framing moves the map inside the mode; the bar's map
        # and palette boxes follow rather than lead, as the event box does.
        self.world_bar.set_submap(self._world.submap)
        self.world_bar.set_palette(self._world.palette_index)
        # The panel is the framed submap's colours, so a framing that moved the
        # palette moves it too -- the bar's own palette box reaches
        # `_show_palette` directly, but framing a submap does not. Only when
        # the palette has actually moved: this hook fires on every placement,
        # and rebuilding 256 swatches and the file's named runs under an
        # unchanged palette buys nothing.
        if self._world.palette_index != self._world_palette_shown:
            self._show_palette()
        # A table editor is a view of the same document, so every commit, undo
        # and destination pick lands in its rows too. The event and silent
        # tables also follow the Event box's focus, which arrives through this
        # same hook.
        self.world_tables.refresh()
        self._refresh_load_path()

    def _go_to_submap(self, submap: int) -> None:
        """The world bar's pick: frame the submap, palette following.

        Framing reports nothing back -- unlike the auto-frame a gesture makes,
        which goes through `_world_changed` -- so the bar's palette box and the
        panel's colours are moved here.
        """
        self._world.go_to_submap(submap)
        self.world_bar.set_palette(self._world.palette_index)
        self._show_palette()

    def _world_layer_picked(self, index: int) -> None:
        """The world bar's layer pick: move the palette to that tab, which
        owns what a layer switch means for the selection and the hand. The
        Events row stands for both stamp tabs -- it keeps the one already
        open, and opens the 2x2 sheet otherwise."""
        tabs = EDIT_ROWS[index][1]
        tab = self.tile_palette.tab if self.tile_palette.tab in tabs else tabs[0]
        self.tile_palette.set_tab(tab)

    def set_world_editing(self, index: int) -> None:
        """The Edit menu's Overworld Editing row, or its digit key: edit that
        part of the map. The bar's box and the menu are two handles on the
        palette's tab, so both take the same route to it."""
        self._world_layer_picked(index)

    def _world_layer_changed(self, tab: object) -> None:
        """The palette switched tabs -- by click, eyedropper, the bar or a
        digit: keep the bar's box and the Editing rows saying the same thing.

        The rows are checked rather than triggered, so mirroring the tab does
        not ask for it back.
        """
        assert isinstance(tab, PaletteTab)
        self.world_bar.set_layer(tab)
        row = edit_row_of(tab)
        for editing in self.menu_actions.world_editing.actions():
            editing.setChecked(editing.data() == row)

    def _world_sheet_asked(self, on: bool) -> None:
        """The stamp tab's button: put that sheet on the canvas, or give the
        canvas back to the map. Which sheet is the open tab's."""
        if self._mode is not EditorMode.WORLD:
            return
        self._world.set_sheet_view(
            on, small=self.tile_palette.tab is PaletteTab.STAMPS_2X2
        )
        self._sync_world_bar_reach()

    def _sync_world_bar_reach(self) -> None:
        """Grey what describes a map while a sheet holds the canvas.

        The map is untouched behind the sheet -- every box and toggle comes
        back saying exactly what it said -- but a pick would move a picture
        nobody can see. The Editing rows stay live: picking another layer is
        how the sheet is left, and the Palette box too, since the sheet is
        drawn under the framed map's colours like every other offer.
        """
        on_map = self._mode is EditorMode.WORLD and not self._world.sheet_view
        self.world_bar.set_map_reach(on_map)
        for row in self.menu_actions.world_views:
            row.setEnabled(on_map)

    def _world_event_picked(self, pick: int) -> None:
        """The world bar's event pick: isolate one event on the events view
        -- that event alone replayed and focused -- or show every event, or
        none: the base map, the view down."""
        if not self._world.ready:
            return
        if pick >= 0:
            self._world.set_focus_event(pick)
            return
        self._world.set_events_view(pick == EVERY_EVENT)
        if pick == EVERY_EVENT:
            self._world.set_focus_event(None)

    def _world_event_pick(self) -> int:
        """The bar's Event box row for the mode's state: the focused event,
        every event, or -- the view down -- none."""
        if self._world.focus_event is not None:
            return self._world.focus_event
        return EVERY_EVENT if self._world.events_view else NO_EVENTS

    def toggle_world_map(self, checked: bool) -> None:
        """The Go menu's checkable row: enter the mode, or come back."""
        if checked:
            self._enter_world()
        else:
            self._leave_world()

    def set_world_events(self, on: bool) -> None:
        """The View toggle: the world map with every event replayed."""
        if self._mode is EditorMode.WORLD:
            self._world.set_events_view(on)

    def set_world_layer1(self, on: bool) -> None:
        """The View toggle: the world map with Layer 1 in or out."""
        if self._mode is EditorMode.WORLD:
            self._world.set_layer1_shown(on)

    def set_world_layer2(self, on: bool) -> None:
        """The View toggle: the world map with Layer 2 in or out."""
        if self._mode is EditorMode.WORLD:
            self._world.set_layer2_shown(on)

    def set_world_sprites(self, on: bool) -> None:
        """The View toggle: the world map's sprite markers in or out."""
        if self._mode is EditorMode.WORLD:
            self._world.set_sprites_shown(on)

    def set_world_frame(self, on: bool) -> None:
        """The View toggle: the framed map's box and border mask in or out."""
        if self._mode is EditorMode.WORLD:
            self._world.set_frame_shown(on)

    def set_world_tile_marks(self, on: bool) -> None:
        """The View toggle: the tile-function marks in or out."""
        if self._mode is EditorMode.WORLD:
            self._world.set_tile_marks_shown(on)

    def _enter_world(self) -> None:
        """Put the world map on the canvas, fetching it first if need be."""
        if self._mode is EditorMode.WORLD:
            return
        # Not during a load -- a replacing one holds the lock, and even a
        # refresh is about to paint the *level's* picture onto the canvas
        # this mode is taking over.
        if (
            self._path is None
            or self._loader is None
            or self._replacing
            or self._loading
        ):
            self.menu_actions.world_map.setChecked(False)
            return
        # And not over an edited level without saying so: the title's mark is
        # the canvas's, so the level's work has to be settled before the map
        # takes the canvas from it.
        if not self._may_leave_level_for_map():
            self.menu_actions.world_map.setChecked(False)
            return
        # A gesture cannot cross the mode boundary: what is armed belongs to
        # the level, and the marquee's arithmetic to its picture.
        self._stop_all_placing()
        self._drop_grip()
        # So Alt+Left after coming back returns to this view rather than to
        # the level's own opening position.
        if self._snapshot is not None:
            self._note_where_we_are_looking()
        self._level_look = self.view.looking_at
        self._mode = EditorMode.WORLD
        self._show_world_chrome(True)
        # The panel shows the colours of whatever is on the canvas, so the mode
        # is what moves it: the map's, and named for the map. A capture still
        # in flight leaves it empty until `_show_overworld` calls back -- which
        # is the truth, the level's colours no longer being on screen.
        self._show_palette()
        if self._world.ready and not self._world_stale:
            self._world.activate()
            self._world_changed()
            self.sync_go_menu()
        else:
            self._request_overworld()
        self._refresh_load_path()
        # The title names the mode and marks the mode's own unsaved work, so
        # it changes on the way in whether or not a map is here to show yet.
        self._update_title()

    def _leave_world(self, ask: bool = True) -> None:
        """Give the canvas back to the level, exactly as it was left.

        ``ask`` is the map's half of the unsaved-work question, and is off for
        the two unwinds that come through here -- a capture that could not be
        made a document, and one that never arrived. Neither is a way *out* of
        the mode the user chose: the map on the canvas failed to be one, and
        there is nothing to offer to save.
        """
        if self._mode is EditorMode.LEVEL:
            return
        if ask and not self._may_leave_map_for_level():
            self.menu_actions.world_map.setChecked(True)
            return
        self._world.stop_placing()
        # A sheet on the canvas goes down with the mode: the canvas is about
        # to be the level's, and coming back should show the map.
        self._world.set_sheet_view(False)
        # The events view goes down *before* the mode flips: the uncheck
        # routes through :meth:`set_world_events`, whose world-mode guard
        # would drop it a line later -- leaving the mode showing the events
        # twin against an unchecked toggle the next time the map comes up.
        self.menu_actions.world_events.setChecked(False)
        self._mode = EditorMode.LEVEL
        self.menu_actions.world_map.setChecked(False)
        self._show_world_chrome(False)
        if self._snapshot is not None and self._shape is not None:
            if self._level_stale:
                # A layer toggle moved while the map held the canvas, so the
                # buffered pixels are of layers no longer asked for.
                self._draw_level()
            else:
                self._show_picture()
            self._show_screen_grid(self._shape)
            self._show_screen_exits()
            self._draw_overlays()
            # The panel is the world map's, and the held set never moved while
            # the map was up -- so it is re-described rather than re-selected:
            # `_select` repaints only on a change, and a stale world panel over
            # the level routes its edits through the level's record machinery.
            self._describe_selection()
            # Both sprite toggles may have gone off over the map, leaving a
            # selected sprite that is no longer in the picture.
            self._drop_a_hidden_sprite()
            if self._level_look is not None:
                self.view.center_on(self._level_look)
        else:
            self.canvas.set_overlays(())
            self.canvas.set_screen_size(QSize())
            self.canvas.set_screen_notes({})
            self.properties.show_nothing(NO_LEVEL)
        # The panel was the map's, colours and name both; the canvas is the
        # level's again, so it is too.
        self._show_palette()
        self._refresh_load_path()
        self.sync_edit_actions()
        self.sync_go_menu()
        self._update_title()

    def _show_world_chrome(self, on: bool) -> None:
        """Swap the level-only chrome for the world map's, or back.

        The toolbars swap as one registry -- each is declared level-owned,
        world-owned or shared where it is built, and :attr:`toolbars` puts up
        the mode's set. The docks, which genuinely take turns in one spot, are
        :meth:`_apply_editing_chrome`'s: the map is one of the three editing
        environments, with its own arrangement of them.
        """
        # Each environment's menu rows go with it, rather than sitting in the
        # menus greyed: see :attr:`menus.Actions.world_rows`, which is where
        # the two sets are gathered. The arming below is the other question --
        # whether what is here can be acted on -- and the two do not fight:
        # Qt holds a hidden row disabled whatever its enabled state says, and
        # hands that state back when the row returns.
        for row in self.menu_actions.world_rows:
            row.setVisible(on)
        for row in self.menu_actions.level_rows:
            row.setVisible(not on)
        self.toolbars.enter(EditorMode.WORLD if on else EditorMode.LEVEL)
        # What the mode puts up may still have nothing to offer: the level
        # bar needs a cart to ask, and the world bar a captured map --
        # entering ahead of the capture leaves it dead until
        # `_show_overworld` fills it.
        self.world_bar.setEnabled(on and self._world.ready)
        self._apply_editing_chrome()
        # And the Window rows for the two panels that just swapped: the one
        # this environment does not place from is not the user's to put up,
        # because the next mode switch would take it away again.
        self.menu_actions.create_panel.setEnabled(not on)
        self.menu_actions.tile_panel.setEnabled(on)
        # The events view means nothing off the world map. :meth:`_leave_world`
        # already unchecked the action while the mode could still act on it;
        # this uncheck is the backstop for any other path into level chrome.
        if not on:
            self.menu_actions.world_events.setChecked(False)
        # The map's own toggles go dead with it, but stay checked as they
        # are: layer visibility survives a trip out of the mode, and the
        # mode's picture holds the same answer. The level's go dead the other
        # way for a second reason: the two sets carry the same Shift+digits,
        # so exactly one of them may be armed -- see :attr:`menus.Actions
        # .world_views`, which is where the two sets are named.
        for row in self.menu_actions.world_views:
            row.setEnabled(on)
        for row in self.menu_actions.level_views:
            row.setEnabled(not on)
        # Not the screen grid: it is one action in both rows -- the page grid
        # is the world map's screens -- so it has one key and no mode to be
        # dead in.
        #
        # The editing rows carry the bare digits, so they are armed only where
        # a digit can mean a layer: over the level those keys belong to the
        # level's own rows, which `_sync_level_editing_offer` puts down here.
        # Entering mirrors the palette's tab, which survives a trip out of the
        # mode along with everything else it holds.
        self.menu_actions.world_editing.setEnabled(on)
        self._sync_level_editing_offer()
        if on:
            self._world_layer_changed(self.tile_palette.tab)
        # The table editors edit the world document, so they arm with the
        # mode and go down with it -- a modeless dialog left open over the
        # level would commit into a picture the canvas is not showing.
        for row in self.menu_actions.world_dialogs:
            row.setEnabled(on)
        if not on:
            self.world_tables.close()
        # Test follows the mode the way Save does: same action, same shortcut,
        # testing whatever is being edited -- see :meth:`test_level`.
        self.menu_actions.test.setText("&Test World Map" if on else "&Test Level")
        # The header dialog acts on the *level*, and a header edit ends in a
        # refresh that would repaint the canvas with the level's picture -- so
        # its key goes dead here and comes back exactly as level-armed as it
        # was. Test stays armed: the play window is its own surface, and
        # either kind of run works over the map.
        self.sync_level_rows()
        # A screen of the *level*: over the map the same boxes number the two
        # picture pages, which nothing here has anything to say about.
        self._sync_screen_selecting()
        # Save and Revert answer per mode -- both their labels and whether
        # they can be reached at all. See :meth:`sync_save_rows`.
        self.sync_save_rows()

    def _request_overworld(self) -> None:
        """Ask the loader for the world map, under the replacing-load lock.

        The same lock a level switch takes, for the same reason: between the
        request and the reply the canvas is about to be replaced, and an edit
        made in the gap would land in a document on its way out.

        The request carries the project's edited graphics files, and only
        those: the map loads its files out of the image the way a level does,
        so an edited one shows only in a capture run over the patched image.
        The colours are recoloured on this side (:meth:`_recoloured_world`)
        and the map's own tables are the document's, so neither rides along.
        """
        self._awaiting_world = True
        self._world_stale = False
        self.statusBar().showMessage("Loading the world map...")
        self._lock(self._loading_dialog.begin_overworld)
        self.overworld_requested.emit(
            cart_patches.saved_graphics_patch(
                self._project, self._rom, self._addresses, self._status_message
            )
        )

    def _show_overworld(self, snapshot) -> None:  # noqa: ANN001 - a queued signal
        self._awaiting_world = False
        self._unlock_after_load()
        self.statusBar().clearMessage()
        if self._mode is not EditorMode.WORLD:
            # The mode was left while the capture ran -- the cartridge was
            # closed, or the fetch failed the toggle back. The snapshot is
            # kept by the worker either way, so nothing is lost.
            return
        if self._world.ready:
            # A map already up, captured again over the graphics as they now
            # stand: a redraw under the new capture, not a reload -- the
            # document, its history and the selection stay, exactly as they
            # do under a colour edit.
            self._world.recolour(self._recoloured_world(snapshot))
            self._world.activate()
            self._world_changed()
            self.sync_go_menu()
            self._recapture_stale_world()
            return
        tiles = layer2 = stamps = stamp_props = sprites = None
        # The parts the project keeps as editable asm regions, each under the
        # name :meth:`OverworldMode.show` takes it as. One table --
        # :data:`~shiny_mushroom.project_overworld.OVERWORLD_PARTS`, the same one the
        # save writes them through -- so a part cannot be saveable and reopen
        # as something else, and a thirteenth cannot be added to one and not
        # the other.
        saved: dict[str, object] = dict.fromkeys(part.name for part in OVERWORLD_PARTS)
        if self._project is not None:
            # Per part, because the parts fail separately: a project with a
            # saved Layer 1 and no Layer 2 baselines still opens with the
            # saved half. What a project cannot say, the capture already
            # holds.
            try:
                tiles = self._project.overworld_tiles()
            except (ProjectError, OSError):
                tiles = None
            try:
                layer2 = self._project.overworld_layer2()
            except (ProjectError, packed.PackedError, OSError):
                layer2 = None
            try:
                stamps = self._project.overworld_stamps()
                stamp_props = self._project.overworld_stamp_props()
            except (ProjectError, packed.PackedError, OSError):
                stamps = stamp_props = None
            try:
                sprites = self._project.overworld_sprites()
            except (ProjectError, OSError):
                sprites = None
            unreadable: list[str] = []
            for part in OVERWORLD_PARTS:
                try:
                    region_for(part.region, self._project.cartridge_base)
                except AsmRegionError:
                    # A feature's own table on a cartridge without the
                    # feature -- the translevel remap's. Nothing assembles
                    # it, so there is nothing to read and nothing to report.
                    continue
                try:
                    saved[part.name] = part.from_model(
                        self._project.asm_rows(part.region)
                    )
                except (ProjectError, AsmRegionError, OSError) as error:
                    saved[part.name] = None
                    unreadable.append(str(error))
            if unreadable:
                # The message is the only thing that names the file and the
                # line, and the map opens on the cartridge's own bytes either
                # way -- so saying nothing would leave somebody looking at a
                # table their edit is missing from with no way to find out why.
                self._status_message(
                    f"{len(unreadable)} saved overworld table"
                    f"{'' if len(unreadable) == 1 else 's'} could not be read: "
                    f"{'; '.join(unreadable)}",
                    12000,
                )
        # The captured name words are the editable region's format only on
        # the targets whose build assembles that fragment -- J's are its own
        # routine's, and the document honestly carries nothing there.
        if saved["level_names"] is None and region_for(
            OVERWORLD_NAMES_REGION
        ).applies_to(self._target_id):
            saved["level_names"] = snapshot.level_names or None
        snapshot = self._recoloured_world(snapshot)
        try:
            self._world.show(
                snapshot,
                tiles,
                layer2,
                stamps,
                stamp_props,
                sprites,
                shape=self._map_shape,
                **saved,
            )
        except ValueError as error:
            # A part that is not this cartridge's shape: a capture of a
            # cartridge whose tables its build's record disagrees about, or a
            # saved fragment from before a feature grew one. Refused with the
            # table named rather than opened at the wrong length, which is what
            # would edit some rows and write the rest off the end.
            self._leave_world(ask=False)
            self._alert(
                "The world map does not match what this cartridge was built as.",
                detail=f"{error}. Rebuild and reopen its ROM to put the two "
                f"back in step; the levels are unaffected.",
            )
            return
        # The toggle may have been checked while the capture was in flight;
        # the mode only applies a view it was ready for.
        self._world.set_events_view(self.menu_actions.world_events.isChecked())
        # The map arriving is what gives the world bar something to frame.
        self.world_bar.set_palettes(self._world.palette_cgrams)
        self.world_bar.set_submap(self._world.submap)
        self.world_bar.set_auto_select(self._world.auto_select)
        self.world_bar.set_palette(self._world.palette_index)
        # After the map is up, not before: the panel shows the framed submap's
        # colours, and which submap that is, is the mode's to say.
        self._show_palette()
        self._world_layer_changed(self.tile_palette.tab)
        self.world_bar.set_event(self._world_event_pick())
        self.world_bar.setEnabled(True)
        self.sync_go_menu()
        # The map arriving is what makes Ctrl+S mean something here.
        self.sync_save_rows()
        self._recapture_stale_world()

    def _recapture_stale_world(self) -> None:
        """Ask for the map again when a graphics change overtook the capture
        that just arrived -- it was requested over files the project no
        longer has. Once the reply is in, so a capture is never in flight
        twice."""
        if self._world_stale and self._mode is EditorMode.WORLD:
            self._request_overworld()

    def _forget_overworld(self) -> None:
        """Drop the world map with the cartridge it came from."""
        self.world_tables.close()
        if self._mode is EditorMode.WORLD:
            self._mode = EditorMode.LEVEL
            self._show_world_chrome(False)
        self.menu_actions.world_map.setChecked(False)
        self.menu_actions.world_map.setEnabled(False)
        self._awaiting_world = False
        self._world_stale = False
        self._level_look = None
        self._level_stale = False
        self._world.forget()
        # After the forget, so re-checking cannot re-render a dropped map:
        # the mode's guards answer "not ready" and only the actions move.
        self.menu_actions.world_layer1.setChecked(True)
        self.menu_actions.world_layer2.setChecked(True)
        self.menu_actions.world_sprites.setChecked(True)
        self.menu_actions.world_frame.setChecked(True)
        self.menu_actions.world_tile_marks.setChecked(False)
        self.world_bar.set_palettes(())
        self.world_bar.set_submap(0)
        self.world_bar.setEnabled(False)

    def save_current(self) -> bool:
        """Ctrl+S: save whichever document the canvas is showing."""
        if self._editing_palettes():
            return self.save_palettes()
        if self._mode is EditorMode.WORLD:
            return self.save_world_map()
        return self.save_level()

    def revert_current(self) -> None:
        """The Revert row: put back whichever document has the focus.

        The world map has no revert in this phase, which is why its row is
        greyed (:meth:`sync_save_rows`) -- and why the mode is answered here
        as well: reaching this over the map would put back the *level*, which
        is not the document the row names.
        """
        if self._editing_palettes():
            self.revert_palettes()
            return
        if self._mode is EditorMode.WORLD:
            return
        self.revert_level()

    def _price_world_room(self, document: WorldMap, region_id: str) -> Room | None:
        """The world map mode's pricer: what ``region_id``'s run has to spare
        with ``document``'s rows in it, and whether the cartridge's tables
        already sit in the expansion bank -- or ``None`` for a cartridge
        with no project or no build to price against, which is the answer
        that holds the mode to the stock shape."""
        if self._project is None:
            return None
        try:
            if self._world_runs is None:
                self._world_runs = asm_runs(self._project)
            spare = world_map_room(
                self._project,
                world_region_models(document),
                self._world_runs,
                region_id,
            )
        except (BuildError, ProjectError, AsmRegionError, KeyError, OSError):
            return None
        return Room(spare, OVERWORLD_TABLES_RELOCATED.id in self._features)

    def save_world_map(self) -> bool:
        """Write the world map into the project, reporting success."""
        if not self._have_somewhere_to_save():
            return False
        if not self._world.ready:
            return False
        document = self._world.document
        # The asm-region parts, as the models the save will build from them
        # -- so what needs a budget can be decided here: only a table that
        # differs from the disassembly's own rows is priced, and a map whose
        # tables are stock saves without a build.
        models = world_region_models(document)
        runs: dict[str, Run] | None = None
        try:
            changed = [
                region_id
                for region_id, model in models.items()
                if (stock := self._project.asm_region_stock(region_id)) is not None
                and model != stock
            ]
            if changed:
                runs = asm_runs(self._project)
            self._project.save_world_map(
                tiles=document.tiles,
                layer2=document.layer2 or None,
                stamps=document.stamps or None,
                stamp_props=document.stamp_props or None,
                sprites=document.sprites or None,
                directions=document.directions or None,
                level_events=document.level_events or None,
                level_names=document.level_names or None,
                translevel_levels=document.translevel_levels or None,
                events=document.events or None,
                silent=document.silent or None,
                destroy=document.destroy or None,
                subs=document.subs or None,
                swaps=document.swaps or None,
                warps=document.warps or None,
                exits=document.exits or None,
                sprite_disable=document.sprite_disable,
                asm_runs=runs,
            )
        except AsmRegionFull as error:
            self._alert(
                "The world map could not be saved: its event placements no "
                "longer fit their run of ROM.",
                detail=f"{error.used:,} bytes against {error.room:,} - "
                f"{error.used - error.room:,} must come back out. "
                f"Nothing was saved.",
            )
            return False
        except HandEditedRegion as error:
            # Refused rather than overwritten: the table was edited by hand
            # past what the editor can read, so what it holds is not in this
            # document and saving would throw it away.
            self._alert(
                "The world map could not be saved: one of its tables has been "
                "edited by hand past what the editor can read.",
                detail=f"{error.reason}. Fix {error.path} by hand, or revert "
                f"it from Project > Source Files. Nothing was saved.",
            )
            return False
        except BuildError as error:
            # The runs come from the project's own build; without one an
            # edited asm table cannot be priced, so nothing is saved.
            self._alert(
                "The world map could not be saved: the project has no build "
                "to price its edited overworld tables against.",
                detail=str(error),
            )
            return False
        except packed.RegionFull as error:
            # Not a ProjectError, and worth its own words: the map did not
            # fit, and the way out is taking bytes back out of it.
            what = "Layer 2" if error.region == packed.OVERWORLD_LAYER2 else "event"
            self._alert(
                f"The world map could not be saved: its {what} data no "
                f"longer fits its run of ROM.",
                detail=f"{error.used:,} bytes compressed against "
                f"{error.budget:,} - {error.used - error.budget:,} must "
                f"come back out. Nothing was saved.",
            )
            return False
        except (AsmRegionError, ProjectError, OSError) as error:
            # The asm-region half is the pricing: the runs are read off this
            # build's own symbol file, and a label it has no answer for stops
            # the save rather than moving a row into a run nobody measured.
            self._alert(
                "The world map could not be saved.",
                detail=_rebuild_detail(str(error)),
            )
            return False
        self._world.saved()
        # The overworld's tables went into the overlay, so a memory map on
        # screen is showing the rows they held before this save.
        self._refresh_memory_map()
        # Refresh the build-needed reading against the open cartridge: the
        # save itself always lands (a build re-places what grew), but a part
        # past its in-place slot cannot preview until a rebuild.
        self._world_map_patch()
        said = f"Saved the world map to {self._project.name}"
        if self._project.build_needed:
            said += (
                f" -- {', '.join(self._project.build_needed)} "
                f"need{'s' if len(self._project.build_needed) == 1 else ''} "
                f"a build to preview"
            )
        self.statusBar().showMessage(said, 5000)
        return True

    # -- starting a project --------------------------------------------------

    def require_setup(self) -> bool:
        """Get the editor to a state where a level can be edited and kept, or
        report that it could not be.

        **The setup is not optional and it is not partially completable.** Each
        of the states short of :attr:`~shiny_mushroom.setup.Stage.READY` is
        degenerate rather than merely lesser: without a cartridge the emulator
        cannot boot, so there is no picture to edit, and without a project an
        edit is work with nowhere to go that looks exactly like work being kept.
        The app has nothing useful to do in either, so it does not offer to sit
        in one.

        So this loops rather than falling through. Every pass re-asks what is
        missing, because the answer moves: extracting a cartridge is a minute
        during which a project folder can appear, and a dialog can fail without
        the person having chosen to stop. It ends only when the state is
        ``READY``, or when the answer to a step is the one that ends the
        session -- and it says which by returning ``False``, so
        :func:`~shiny_mushroom.app.main` can close without ever showing a window
        that does not work.

        Called before the window is shown, which is what makes "cannot be used"
        literal instead of a matter of greyed-out menus.
        """
        while True:
            where = readiness()
            if where.stage is Stage.READY and self._project is not None:
                return True
            if not where.has_assets:
                if self.choose_cartridge() is None:
                    return False
                continue
            if not self._resolve_project():
                return False

    def _resolve_project(self) -> bool:
        """Open or make the project to work in. False to end the session.

        A returning person is offered the one they were last in, preselected --
        which is nearly always the answer, and is why the last project is
        remembered at all. With none on disk there is nothing to choose between
        and the naming dialog is the whole question.
        """
        existing = projects()
        if not existing:
            return self.new_project() is not None
        answer = ChooseProjectDialog.ask(
            tuple(existing),
            load_str_setting(PROJECT_KEY) or None,
            self,
        )
        if answer is None:
            return False
        if answer is True:
            # "New Project..." from inside the chooser. Backing out of the name
            # is not the end of the session -- there are projects to choose from,
            # so the loop simply asks again and the chooser is there to pick one.
            self.new_project()
            return True
        chosen = next((found for found in existing if found.name == answer), None)
        if chosen is None:
            return True  # vanished between listing and choosing; ask again
        self.use_project(chosen)
        return True

    def choose_cartridge(self, wanted: str | None = None) -> str | None:
        """Ask for a reference cartridge and extract its assets.

        Reachable from the menu as well as from the first run, because the
        assets can be deleted, an extraction can be interrupted, and a second
        release can be added beside the first -- each release's graphics have
        their own set, so a new cartridge adds to what is on disk. Any release
        is taken unless ``wanted`` names one, which is refused by
        :func:`~shiny_mushroom.setup.inspect` for any other, saying why.
        """
        version = CartridgeDialog.run(self, wanted)
        if version is not None:
            self.statusBar().showMessage(
                f"Extracted the {version} cartridge's graphics, music and samples",
                6000,
            )
        return version

    def new_project(self) -> Project | None:
        """Make a project and open it."""
        if not self._may_discard():
            return None
        existing = projects()
        answer = NameDialog.ask(
            unused_name(), tuple(found.name for found in existing), self
        )
        if answer is None:
            return None
        name, base_id, target_id = answer
        try:
            # The base and target are fixed here and never again: an overlay is
            # written in its base's own paths and read against its target's
            # asset set, so there is no later setting that could change either
            # without being a migration. See `docs/smw/rom-bases.md`.
            project = start_project(name, base_id=base_id, target_id=target_id)
        except (SetupError, ProjectError, BaseError, OSError) as error:
            self._alert("The project could not be created.", detail=str(error))
            return None
        self.use_project(project)
        self.statusBar().showMessage(
            f"Created project {project.name} on {project.spec}{self._base_caveat()}",
            8000,
        )
        return project

    def open_project(self, project: Project) -> None:
        """Switch to ``project``, asking about unsaved work first.

        Reopened from its folder rather than taken as handed in, so a project
        naming a ROM base this build does not have is refused by the model --
        with the base named -- instead of being laid over the default and
        quietly assembling stock levels. See
        :meth:`~shiny_mushroom.project.Project.open`.
        """
        if project.root == (self._project.root if self._project else None):
            return
        if not self._may_discard():
            return
        try:
            opened = Project.open(project.root)
        except ProjectError as error:
            self._alert(f"{project.name} could not be opened.", detail=str(error))
            return
        self.use_project(opened)
        self.statusBar().showMessage(
            f"Opened project {opened.name} on {opened.spec}{self._base_caveat()}",
            8000,
        )

    def reveal_projects(self) -> None:
        """Show the projects folder in the desktop's file manager.

        The one place the editor says where its projects actually are: the
        folder is under the platform's application-data directory, which is
        somewhere nobody navigates to by hand on any of the three.
        """
        if not open_projects_folder():
            self._alert(
                "The projects folder could not be opened.",
                detail=str(projects_root()),
            )

    def fill_project_menu(self) -> None:
        """Rebuild the Open Project submenu from what is on disk.

        As it opens rather than when a project is made, because a project folder
        is an ordinary folder: one can appear or vanish while the app is running,
        and a list built once would offer to open something that is gone.
        """
        menu = self.menu_actions.open_projects
        menu.clear()
        found = projects()
        if not found:
            empty = menu.addAction("No projects yet")
            empty.setEnabled(False)
            return
        for project in found:
            # The base beside the name, in the `<base>/<target>` spelling: two
            # projects on different bases build different cartridges, and the
            # name alone does not say which is which.
            action = menu.addAction(f"{project.name}\t{project.spec}")
            action.setCheckable(True)
            action.setChecked(
                self._project is not None and project.root == self._project.root
            )
            # A base this build does not have is shown and disabled rather than
            # left out: the project exists, and a menu it is missing from reads
            # as work that has gone.
            action.setEnabled(project.buildable)
            if not project.buildable:
                action.setToolTip(
                    f"This build does not have the ROM base {project.base_id!r}."
                )
            action.triggered.connect(
                lambda _checked=False, chosen=project: self.open_project(chosen)
            )

    def sync_file_menu(self) -> None:
        """Put the File menu's rows in step with what is open.

        The two exports arm on whether there is a project to build -- not on
        whether a cartridge is open. What an export writes is the *project's*
        build, and the image on the canvas may be a byte map or a file handed
        in on the command line, neither of which this offers to copy anywhere.
        """
        exportable = self._project is not None and self._project.buildable
        self.menu_actions.export.setEnabled(exportable)
        self.menu_actions.export_headered.setEnabled(exportable)
        self.sync_save_rows()

    def sync_save_rows(self) -> None:
        """Name Save and Revert after the document they act on, and arm them.

        The one authority on both. They carry keys as well as rows -- Ctrl+S
        among them -- so this is called when what is being edited changes and
        not only when the menu opens.
        """
        # The panel's own Save button answers with the same truth, whichever
        # surface Ctrl+S means at the moment.
        self.palette_dock.set_unsaved(self._palette_unsaved)
        if self._editing_palettes():
            # The panel with the focus is the document Ctrl+S means -- see
            # :meth:`_edit_surface`, which routes Undo the same way.
            self.menu_actions.save.setText("&Save Palettes")
            self.menu_actions.revert.setText("Re&vert Palettes")
            self.menu_actions.save.setEnabled(self._palette_unsaved)
            self.menu_actions.revert.setEnabled(
                self._project is not None and self._project.palette_edited
            )
            return
        world = self._mode is EditorMode.WORLD
        self.menu_actions.save.setText("&Save World Map" if world else "&Save Level")
        self.menu_actions.revert.setText(
            "Re&vert World Map" if world else "Re&vert Level"
        )
        if world:
            # Ctrl+S saves the world map here, and there is no revert for it
            # in this phase -- the row says which document it would put back
            # all the same, so a greyed row is not a row about some other one.
            self.menu_actions.save.setEnabled(
                self._project is not None and self._world.ready
            )
            self.menu_actions.revert.setEnabled(False)
        else:
            self.menu_actions.save.setEnabled(
                self._project is not None and self._doc is not None
            )
            self.menu_actions.revert.setEnabled(
                self._project is not None and self._level is not None
            )

    def sync_project_menu(self) -> None:
        """Arm the open project's settings on whether there is one to set."""
        self._sync_rom_size_menu()

    def _sync_rom_size_menu(self) -> None:
        """Grey the ROM Size row out when the size is not this window's to
        change: whenever there is no project, since the size is a project's
        setting rather than the application's, and on a base that offers one."""
        project = self._project
        self.menu_actions.rom_sizes.setEnabled(
            project is not None
            and project.buildable
            and rom_base(project.base_id).expandable
        )
        # Patches are a project's setting by the same reasoning, but need no
        # room of their own -- an org-only patch fits a stock cartridge.
        self.menu_actions.patches.setEnabled(project is not None and project.buildable)
        # The features are that build's too: what a switch does is decided
        # against the project's base, its cartridge size and its overlay.
        self.menu_actions.features.setEnabled(project is not None and project.buildable)
        # The Level Data window only reads, so any project will do -- its rows
        # are the project's tree through the overlay, buildable or not.
        self.menu_actions.level_data.setEnabled(project is not None)
        # And the memory map for the same reason. It shows less without a
        # build -- the tables are the symbol file's to place -- but the banks,
        # the level data and the padding are read from the source and are as
        # true before a first build as after one.
        self.menu_actions.memory_map.setEnabled(project is not None)
        # The strings are the project's overlay, so they need one too.
        self.menu_actions.strings.setEnabled(project is not None)
        # The Map16 editor draws in a level's graphics, so it needs one open.
        self.menu_actions.map16.setEnabled(
            project is not None and self._snapshot is not None
        )
        # The secondary entrances are the project's overlay, like the strings:
        # the tables are read out of its tree and saved back into it.
        self.menu_actions.secondary_entrances.setEnabled(project is not None)
        # Hand editing needs a base tree to copy files out of, which is what
        # buildable answers: an overlay over a base this build has not got can
        # be listed but nothing can be added to it.
        self.menu_actions.source_files.setEnabled(
            project is not None and project.buildable
        )
        # The graphics files are a reading of the project's set, built or not.
        self.menu_actions.graphics_files.setEnabled(project is not None)
        self._sync_rebuild_action()

    def _sync_rebuild_action(self) -> None:
        """Arm Rebuild on whether the project's next build has anything to do.

        :func:`~shiny_mushroom.build.needs_build` is the authority and is asked
        where it is decisive and cheap: as a project opens, once its build has
        had its chance. From then on the answer can only turn back to yes, and
        every way it does is known here -- an edit saved into the overlay,
        which rewrites the project's record (:func:`_project_stamp`); a part a
        test run could not carry;
        a hand-edited overlay file or the disassembly moving on disk, both of
        which arrive through :meth:`_note_skipped` -- so the row follows the
        project without a merge per title change and without waiting for the
        menu it lives in to be opened, which its shortcut cannot.

        Greyed out, then, exactly when a build would say "already up to date",
        and a project that cannot build at all has nothing to arm.
        """
        project = self._project
        wanted = project is not None and project.buildable
        if wanted and self._build_current and not project.build_needed:
            wanted = _project_stamp(project) != self._built_stamp
        self.menu_actions.rebuild.setEnabled(wanted)

    def fill_rom_size_menu(self) -> None:
        """Rebuild the ROM Size submenu from the open project's **base**.

        As it opens rather than once at construction, because the sizes on offer
        are the base's own and the two bases do not agree: there is no 512 KB
        SA-1 cartridge and no 8 MB LoROM one, and the row a project needs
        checked may not exist in the other's ladder at all. See
        :attr:`smw_tools.bases.RomBase.sizes`.

        Each row says what the size *buys* rather than only how long it is, and
        that is a base question too -- ``sa1``'s stock cartridge is already a
        megabyte, so 2 MB adds half of what it adds on ``vanilla``.
        """
        menu = self.menu_actions.rom_sizes
        menu.clear()
        project = self._project
        if project is None or not project.buildable:
            return
        base = rom_base(project.base_id)
        group = QActionGroup(menu)
        group.setExclusive(True)
        group.triggered.connect(lambda chosen: self.set_rom_size(chosen.data()))
        for size_id in base.sizes:
            row = menu.addAction(base.size_summary(size_id))
            row.setCheckable(True)
            row.setChecked(size_id == project.rom_size_id)
            row.setData(size_id)
            group.addAction(row)

    def set_rom_size(self, rom_size_id: str) -> None:
        """Build this project into a cartridge of a different size.

        Nothing in the overlay moves -- see
        :meth:`~shiny_mushroom.project.Project.set_rom_size` -- but the ROM is
        assembled again and reloaded, so the level in hand goes back to what the
        project last saved. That is the same trade opening a project makes, and
        it is asked about the same way.
        """
        project = self._project
        if project is None or project.rom_size_id == rom_size_id:
            return
        # The click has already moved the check mark, so every path out from
        # here rebuilds the rows rather than leaving one lit that is not what
        # the project builds.
        if not self._may_discard():
            self.fill_rom_size_menu()
            return
        try:
            resized = project.set_rom_size(rom_size_id)
        except (ProjectError, BaseError, OSError) as error:
            self._alert("The ROM size could not be changed.", detail=str(error))
            self.fill_rom_size_menu()
            return
        if not self.use_project(resized):
            return
        base = rom_base(resized.base_id)
        extra = base.room(resized.rom_size_id)
        room = (
            "its base's stock cartridge"
            if not extra
            else f"{bytes_label(extra)} more than stock, free for patches"
        )
        self.statusBar().showMessage(
            f"{resized.name} now builds a {resized.rom_size.label} cartridge - {room}",
            8000,
        )

    def edit_patches(self) -> None:
        """The project's asm patches: toggle, order, add, import, remove.

        The dialog writes through to the project as changes are made -- the
        manifest and the files are the state -- so what is decided here is
        only what happens after: a change to what the build applies leaves the
        cartridge on the canvas stale, and closing the dialog rebuilds and
        reloads exactly the way changing the ROM size does. Declining that --
        there is unsaved work on the canvas -- leaves the change recorded, and
        the next build picks it up.
        """
        project = self._project
        if project is None:
            return
        dialog = PatchesDialog(project, self)
        dialog.exec()
        if not dialog.applied_changed:
            return
        if not self._may_discard():
            self.statusBar().showMessage("Patch changes apply at the next build.", 8000)
            return
        self.use_project(project)

    def edit_features(self) -> None:
        """What this project's cartridge is assembled with beyond the stock
        game: turn a feature on or off, migration and all.

        The dialog writes through as a box is ticked, so what is decided here
        is only what happens after -- and it is the same thing a patch change
        decides: the cartridge on the canvas no longer matches what the
        project would build, so closing rebuilds and reloads.

        The project handed back may not be the one that went in. A feature
        that needs an expansion bank raises the cartridge size on the way on,
        and :class:`~shiny_mushroom.project.Project` is frozen, so the window
        has to take the one the dialog is holding or carry on building the
        cartridge from before.
        """
        project = self._project
        if project is None:
            return
        dialog = FeaturesDialog(project, self)
        dialog.exec()
        if dialog.project is not project:
            self._project = dialog.project
            self.sync_project_menu()
        if not dialog.applied_changed:
            return
        if dialog.notes:
            self.statusBar().showMessage(dialog.notes[-1], 8000)
        if not self._may_discard():
            self.statusBar().showMessage(
                "Feature changes apply at the next build.", 8000
            )
            return
        self.use_project(dialog.project)

    def rebuild_project(self) -> bool:
        """Assemble the project again and open what came out.

        **The one door for a change the editor did not make.** Everything the
        editor writes for itself is previewed in place -- a saved level or
        world map is patched over the emulator's copy of the cartridge in a
        third of a second -- but nothing can preview a change to the *code*.
        A hand-edited routine is only in the cartridge once asar has run, and
        only on the canvas once that cartridge is open: the sprite artwork a
        capture reads comes from running the game's own sprite code, so
        editing that code and expecting the picture to follow means running
        the new one.

        :meth:`use_project` is the whole of it, because reopening the built
        cartridge is what refreshes everything derived from one --
        :meth:`load_file` releases the emulator loader, resolves the addresses
        again, re-reads the palettes, drops the level and world map the old
        cartridge answered for and indexes the new image. So this needs no
        list of what an asm change might touch, which is the point: such a
        list could only ever be wrong.

        Offered only while there is something to build -- see
        :meth:`_sync_rebuild_action`; a cartridge that is current is reopened
        by opening the project again, not by a rebuild that would be skipped.
        """
        project = self._project
        if project is None or not project.buildable:
            return False
        # The rebuilt cartridge replaces the level on the canvas, so the same
        # question every other replacement asks is asked here.
        if not self._may_discard():
            return False
        return self.use_project(project)

    def edit_source_files(self) -> None:
        """The files the project holds of its own, for editing by hand.

        Closing rebuilds and reloads exactly as :meth:`edit_patches` does, and
        for the same reason: a file added to or taken out of the overlay is a
        file the build reads differently, so the cartridge on the canvas is
        stale.
        """
        project = self._project
        if project is None:
            return
        dialog = SourceFilesDialog(project, self)
        dialog.exec()
        # A file edited through the dialog's own Open button was edited while
        # the *dialog* held the focus, so the window's activation check never
        # ran for it. Asking here is what keeps such an edit from being
        # quietly absorbed as the new baseline.
        self._check_source_files()
        if not dialog.overlay_changed:
            return
        if not self._may_discard():
            self.statusBar().showMessage(
                "Source file changes apply at the next build.",
                8000,
            )
            return
        self.use_project(project)

    def edit_graphics_files(self) -> None:
        """Open the project's graphics files -- a sheet per file, PNG in and
        out, the tile-editor handover -- or bring the window forward.

        Kept, like the Level Data window, and closed with the project. It
        draws under the level on screen's colours, which
        :meth:`_show_palette` keeps handing it as levels come and go.
        """
        if self._project is None:
            return
        if self._graphics_files is None:
            self._graphics_files = GraphicsDialog(self._project, self)
            self._graphics_files.overlay_changed.connect(self._graphics_changed)
            self._graphics_files.feature_needed.connect(self._graphics_feature_needed)
            self._graphics_files.project_replaced.connect(
                self._graphics_project_replaced
            )
        # A feature switch whose rebuild was declined leaves the window
        # holding a project the dialog has not seen: the same folder, and
        # the one whose settings the next save is priced by.
        self._graphics_files.adopt(self._project)
        self._graphics_files.set_cgram(
            self._snapshot.cgram if self._snapshot is not None else None
        )
        self._graphics_files.show()
        self._graphics_files.raise_()
        self._graphics_files.activateWindow()
        # Now that somebody is working in here, keep what a swap needs: a save
        # then reaches the canvas without asking the game for the level again.
        self._capture_slot_files()

    def _close_graphics_files(self) -> None:
        """Put the window away with the project it was reading."""
        if self._graphics_files is not None:
            self._graphics_files.close()
            self._graphics_files.deleteLater()
            self._graphics_files = None
        # And stop paying for what only that window's saves used.
        self._capture_slot_files()

    def _graphics_feature_needed(self, gesture: str, number: int) -> None:
        """An add, a duplicate or a delete in the Graphics window needs the managed
        graphics banks: offer the feature the way the first level-file add
        does (:meth:`add_level_file`) -- asked first, then the Features
        dialog's own switch, rebuild and reopen -- and finish the gesture.

        The reopen puts the Graphics window away with the outgoing cartridge,
        so the gesture is finished on the one :meth:`edit_graphics_files`
        brings back, over the project the switch handed out. A no, or a
        refused switch, ends here: the dialog asked nothing yet.
        """
        if not self._want_feature(MANAGED_GRAPHICS_MEMORY.id):
            return
        self.edit_graphics_files()
        dialog = self._graphics_files
        if dialog is None:
            return
        if gesture == graphics_dialog.ADD:
            dialog.add_file()
        elif gesture == graphics_dialog.DUPLICATE:
            dialog.duplicate_file(number)
        elif gesture == graphics_dialog.DELETE:
            dialog.delete_file(number)

    def _graphics_project_replaced(self, project: Project, note: str) -> None:
        """A graphics save took a bank, and the project that builds the grown
        cartridge is a new one: hold it, as :meth:`edit_features` holds the
        one a switch hands back, and say what the save did. Rebuild follows
        through :meth:`sync_project_menu`, and the reload the dialog asks
        for next arms it again over the new project."""
        self._project = project
        self.sync_project_menu()
        if note:
            self.statusBar().showMessage(note, 8000)

    def _graphics_changed(self) -> None:
        """A graphics file moved in the overlay: the level on the canvas is
        loaded again so the relocation preview shows it -- the reload a
        reverted level file gets (:meth:`_level_files_changed`), through the
        same unsaved-work question -- and the build-needed reading follows.

        The world map goes the same way, since it loads graphics too. A held
        capture is marked stale, so the next entry to the mode captures the
        map again rather than showing it; a map on screen is captured again
        now, and shown under the new capture with its edits kept
        (:meth:`_show_overworld`). A capture already in flight is left to
        land -- the stale mark has it asked for again on arrival.
        """
        self._check_source_files()
        self._sync_rebuild_action()
        # The managed graphics runs are drawn from the packing, which an
        # added or grown file moved.
        self._refresh_memory_map()
        if self._world.ready or self._awaiting_world:
            self._world_stale = True
        # The canvas first, where the swap can carry it: a repainted file the
        # level loads is written over the capture's VRAM and the picture is
        # right at once. Only then is the reload weighed, since what the swap
        # settled is what the reload no longer has to.
        moved = (
            self._graphics_swap_covers()
            if self._captured_slot_vram is not None
            else None
        )
        if moved is not None:
            self._sync_graphics()
            self._absorb_graphics(moved)
        else:
            self._reload_the_canvas_level(ask=True)
        if self._mode is EditorMode.WORLD and not self._awaiting_world:
            self._recapture_stale_world()

    def view_level_exits(self) -> None:
        """Open the Level Exits window, or bring it forward.

        Every screen of the open level that leads out of it, as rows: where it
        goes, whether it arrives through the destination's secondary entrance,
        and the two ways out of the row -- open the level it names, or take the
        exit away. Kept and refreshed like the Level Data window, and its cells
        land in :meth:`commit_screen_field`, which is where the canvas's own
        number boxes land too.
        """
        self._level_exits.open()

    # -- keeping the work ----------------------------------------------------

    @property
    def project(self) -> Project | None:
        """The project a save goes into, or ``None`` when none is open."""
        return self._project

    def use_project(self, project: Project | None, build: bool = True) -> bool:
        """Open ``project``, or close whichever one is open.

        **Opening one means opening its cartridge.** A project is not a folder
        that happens to be selected -- it *is* a ROM, assembled from the
        disassembly, the extracted assets and its own overlay. So this builds it
        if anything has moved since last time and hands the result to
        :meth:`load_file`, which is the same door a cart opened by hand comes
        through.

        Reports whether that worked. A build that fails leaves the project
        selected and nothing loaded, which is a state the caller has to be able
        to see rather than one to paper over.

        **A project whose release has not been extracted asks for that
        cartridge first**, and is not opened if the answer is no. Its build
        reads its target's graphics set, so without one it would fail half a
        minute in with asar naming a file it could not find -- a puzzle, where
        the missing step is a known thing the person can go and get. A project
        made here cannot be in that state, but one copied from another machine
        can, and so can any project once the assets folder has been emptied.

        ``build`` is for a caller that has already built -- there is exactly one,
        the setup -- so the work is not done twice.
        """
        if project is not None and not assets_ready(project.target_id):
            if self.choose_cartridge(wanted=project.target_id) is None:
                return False
        # The viewer reads the outgoing project's tree, so it goes first --
        # whether this is a close or a switch, its rows are about to be wrong.
        self._close_level_data()
        self._close_graphics_files()
        self._close_strings()
        self._close_map16()
        self._close_secondary_entrances()
        self._close_memory_map()
        self._project = project
        # Nothing is known about the incoming cartridge until its build has run.
        self._build_current = False
        # And nothing is known about what the incoming project has saved: that
        # reading is remembered until the project is written to, so what was
        # read of the last one -- or of this one, before somebody edited its
        # tree in another program -- is dropped here.
        cart_patches.forget_saved()
        # The colours are the project's, and there is one document for all of
        # them: opening a project is where it is read and its undo stack begins.
        self._read_palette()
        # The arrival tables are the project's too, and a screen exit's
        # destination picker names their rows.
        self._read_entrances()
        # The picker names its rows after containers, and which container a
        # level resolves to is the project's tree and release to say.
        self._name_levels()
        # Remembered so a later session offers it first, which is nearly always
        # the answer. Per person rather than per cartridge: it is where their
        # work is, not a property of the file they opened.
        #
        # Only ever *set*, never cleared: what it holds is the last project
        # worked in, and closing one does not change which that was.
        if project is not None:
            save_str_setting(PROJECT_KEY, project.name)
        self._update_title()
        # Rebuild carries a shortcut, so its answer has to follow the project
        # rather than wait for the menu it lives in to be opened.
        self.sync_project_menu()
        if project is None:
            self._source_stamps = {}
            self._build_current = False
            return True
        if build and BuildDialog.run(project, self) is None:
            self._build_current = False
            return False
        # After the build, so what the cartridge was assembled from is the
        # baseline an external edit is noticed against -- and the build put
        # every one of them in, so the reading clears with it.
        self._source_stamps = source_files.stamps(project)
        self._note_skipped(SOURCE_FILES, [])
        self.load_file(rom_path(project))
        # Whether that cartridge is the one the next build would make: the
        # merge it costs is a moment against the build that just ran, and it
        # is the one reading Rebuild's row is armed on.
        self._build_current = not needs_build(project)
        self._built_stamp = _project_stamp(project)
        # And the other half of what the build read. A build that ran cleared
        # this too; one that was skipped, refused or failed is exactly when
        # the symbol file on disk describes a tree that has moved on. After
        # the load, whose own readout would otherwise land on top of this
        # one's.
        self._check_disassembly()
        self._sync_rebuild_action()
        return True

    @property
    def unsaved(self) -> bool:
        """Whether what is on the canvas has been changed and not written.

        The title's dot marks the view it sits over, so the canvas's own
        document is what counts: the level in :attr:`EditorMode.LEVEL`, the
        world map in :attr:`EditorMode.WORLD`, and never the other one. The
        map survives level switches and mode exits where a level does not,
        so an edited map put away behind a level would otherwise light the
        dot over every level opened afterwards -- with nothing on screen the
        dot could be pointing at.

        Neither is left behind silently: the mode boundary asks, in both
        directions -- :meth:`_may_leave_level_for_map` and
        :meth:`_may_leave_map_for_level` -- so reaching the map with an
        unsaved level, or a level with an unsaved map, takes aiming at
        Discard. What keeps that work from being *lost* is still
        :meth:`_may_discard`, asked at the doors that close the cartridge,
        not the dot.

        The level in hand counts as unsaved the moment the history says it
        has been edited, and every way of replacing it asks first --
        :meth:`_may_replace` -- so no level is ever left behind with work
        outstanding.

        The colours count in either mode, being one document rather than one
        per view: the panel shows the colours of whatever is on the canvas,
        and they are edited from wherever the canvas happens to be. The
        strings are not here at all -- the Strings window marks its own title
        (:func:`~shiny_mushroom.ui.dialogs.mark_unsaved`), so a dot on this
        one would answer for a document that is not under it.

        Without a project there is nowhere for anything to be saved *to*, so
        nothing is unsaved -- the work is in memory and that is what was asked
        for.
        """
        if self._project is None:
            return False
        return self._canvas_unsaved or self._palette_unsaved

    @property
    def _canvas_unsaved(self) -> bool:
        """Whether the document the mode is showing has outstanding edits."""
        if self._mode is EditorMode.WORLD:
            return self._world.edited
        return self._level_unsaved

    @property
    def _strings_unsaved(self) -> bool:
        """Whether the Strings window is holding text it has not written.

        Not part of :attr:`unsaved`: the window wears its own dot. This is
        what :meth:`_may_discard` and :meth:`_may_replace` ask at the doors
        that close the cartridge, where the text would otherwise be lost
        without being offered.
        """
        return self._strings is not None and self._strings.unsaved

    @property
    def _level_unsaved(self) -> bool:
        return self._history is not None and self._history.edited

    def save_level(self) -> bool:
        """Write the level on the canvas into the project, reporting success.

        The level's header goes with the object stream because the two are one
        region of the container -- see :mod:`shiny_mushroom.mwl` -- so a header
        edit is saved by this too, and there is no separate way to save one.

        A level that shares its container with others says so. ``$015``, ``$016``
        and ``$017`` are one level with three numbers, not copies, and being told
        afterwards that two other levels changed is worse than being told at all.

        **A Layer 2 object stream is a third file and a second kind of
        sharing.** It lives in whichever container the Layer 2 pointer names --
        for eight levels one they take nothing else from -- and the numbers
        reading it are not the numbers sharing Layer 1, so the readout says
        both.

        Unsaved custom level palettes ride along too -- the tick and a blob's
        colours are level state however they were edited -- while the shared
        file's edits stay the palette surface's own save.
        """
        if not self._have_somewhere_to_save():
            return False
        if self._doc is None or self._snapshot is None or self._level is None:
            return False
        objects, sprites = self._doc.streams()
        background = self._background_to_save()
        if background is NOWHERE_TO_FILE:
            return False
        # The other kind of Layer 2. Passed whenever the level has one rather
        # than only when it was edited: the region is rewritten from what the
        # build would read, so writing back what is already there costs a
        # byte-identical container and keeps one path for both cases.
        layer2 = (
            (self._doc.layer2_header, self._doc.layer2_stream())
            if self._doc.layer2_records
            else None
        )
        # The secondary header rides along the same way: whenever the document
        # carries one, with the runs computed only when a row actually changed
        # -- a byte-identical save prices nothing and needs no build.
        secondary = self._doc.secondary or None
        try:
            runs: dict[str, Run] | None = None
            if secondary is not None and secondary != self._project.secondary_header(
                self._level
            ):
                runs = asm_runs(self._project)
            written = self._project.save_level(
                self._level,
                self._doc.header + objects,
                sprites,
                background=background,
                layer2=layer2,
                secondary=secondary,
                asm_runs=runs,
                # The graphics row rides along too, always: an empty row
                # deletes the level's file, which is what a row set back to
                # the tileset's means.
                graphics=self._doc.graphics,
            )
        except packed.RegionFull as error:
            # The background's region is packed to the byte, so this is a
            # real answer: the pattern compresses larger than its group has
            # room for, and another background must shrink to pay for it.
            self._alert(
                "The Layer 2 background no longer fits its run of ROM, so "
                "the level was not saved.",
                detail=f"{error} The backgrounds share one region; longer runs "
                "of one tile compress smaller.",
            )
            return False
        except BuildError as error:
            # The runs come from the project's own build; without one an
            # edited secondary header cannot be priced, so nothing is saved.
            self._alert(
                "The level could not be saved: the project has no build to "
                "price its edited secondary header against.",
                detail=str(error),
            )
            return False
        except HandEditedRegion as error:
            self._alert(
                "The level could not be saved: a secondary-header table has "
                "been edited by hand past what the editor can read.",
                detail=f"{error.reason}. Fix {error.path} by hand, or revert "
                f"it from Project > Source Files. Nothing was saved.",
            )
            return False
        except (AsmRegionError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(self._level, 3)} could not be saved.",
                detail=_rebuild_detail(str(error)),
            )
            return False
        # Saved is the new baseline, and the stack is left alone: undo has to
        # keep working across a save, because "save, then realise, then undo" is
        # an ordinary sequence.
        self._history.saved()
        # The level palettes ride the level's save: the tick and every colour
        # of a level's own blob are level state, whatever surface they were
        # edited on -- Save Level leaving them behind reads as the save not
        # having worked. Only that half moves; the shared file's edits stay
        # the palette surface's own save, so its history is rebased rather
        # than marked saved whole.
        dressed = ""
        palette_base = self._palette_history.base
        if palette_base.levels != self._level_palettes:
            try:
                self._project.save_level_palettes(self._level_palettes.as_mapping)
            except (ProjectError, PaletteError, OSError) as error:
                self._alert(
                    "The custom level palettes could not be saved.",
                    detail=str(error),
                )
            else:
                self._palette_history.rebase(
                    palette_base.with_levels(self._level_palettes)
                )
                self.sync_save_rows()
                dressed = " - the custom level palettes with it"
        self._update_title()
        # The container's sizes just moved, and the viewer is a view of them.
        self._refresh_level_data()
        self._refresh_memory_map()
        also = self._project.also_changes(self._level)
        shared = (
            ""
            if not also
            else " - which is also " + " and ".join(hexnum(n, 3) for n in also)
        )
        if background is not None and self._rom is not None:
            others = levels_sharing_layer2(
                self._rom, self._level, where=self._addresses
            )
            if others:
                shared += (
                    f" - its Layer 2 background is shared with "
                    f"{_plural(others, 'other level')}"
                )
        if layer2 is not None:
            # The pointer table's answer rather than the ROM's, because it is
            # the tree being written that decides who reads this stream.
            try:
                borrowers = self._project.levels_sharing_layer2(self._level)
            except (Layer2TableError, ProjectError, OSError):
                borrowers = ()
            if borrowers:
                shared += (
                    " - its Layer 2 is also "
                    + " and ".join(hexnum(n, 3) for n in borrowers)
                    + "'s"
                )
        self.statusBar().showMessage(
            f"Saved level {hexnum(self._level, 3)} to {self._project.name}{shared}"
            f"{dressed} ({_plural(len(written), 'file')})",
            5000,
        )
        return True

    def _background_to_save(self) -> tuple[Path, bytes] | None | object:
        """The Layer 2 background part of a save, if this save carries one.

        ``None`` for the common case -- no background, or one that already
        matches what the project holds. :data:`NOWHERE_TO_FILE` when the
        background *is* edited but cannot be filed: the cartridge's streams
        match none of the project's background files, so there is no name to
        save the edit under, and saving the rest silently would drop it.
        """
        if (
            self._project is None
            or self._doc is None
            or not self._doc.layer2
            or self._snapshot is None
            or not self._snapshot.layer2_background
        ):
            return None
        edited = self._history is not None and (
            self._doc.layer2 != self._history.base.layer2
        )
        key = None
        if self._rom is not None and self._addressable and self._level is not None:
            base = layer2_background_base(self._rom, self._level, where=self._addresses)
            if base is not None:
                try:
                    key = self._project.background_key(self._rom, base)
                except (ProjectError, OSError):
                    key = None
        if key is None:
            if edited:
                self._alert(
                    "The Layer 2 background matches none of the project's "
                    "background files, so its edit has nowhere to go.",
                    detail="The cartridge's Layer 2 streams are not the "
                    "project base's -- a hack rearranged bank $0C. The "
                    "level's own streams were not saved either.",
                )
                return NOWHERE_TO_FILE
            return None
        try:
            # The pattern alone: a shipped file can carry one junk byte past
            # it, which is not a difference worth a save.
            if self._project.raw(key)[: len(self._doc.layer2)] == self._doc.layer2:
                return None
        except (ProjectError, OSError):
            pass
        return (key, self._doc.layer2)

    def revert_level(self) -> None:
        """Put the level on the canvas back to what the project last saved.

        Which for a level nobody has saved is the disassembly's own. Deleting
        the overlay's file *is* the revert -- there is no separate record to
        keep in step -- and the level is then loaded again from what the project
        now reads.
        """
        if self._project is None or self._level is None:
            return
        if not self._confirm(
            f"Revert level {hexnum(self._level, 3)}?",
            "Everything changed since the last save is lost, and so is the "
            "undo history.",
        ):
            return
        try:
            self._project.revert_level(self._level)
        except (Layer2TableError, ProjectError, OSError) as error:
            # Files come out of the overlay and a borrowed Layer 2 is rewritten
            # in place, so this reads and writes the tree -- and says so rather
            # than raising out of the menu row the way every other revert does.
            self._alert(
                f"Level {hexnum(self._level, 3)} could not be reverted.",
                detail=str(error),
            )
            return
        self._refresh_level_data()
        self._refresh_memory_map()
        self.load_level(self._level)

    def _may_lose_level(self, detail: str) -> bool:
        """Put the unsaved-work question and act on the answer. True to go on.

        Save writes the level before whatever was asked for happens, and a write
        that failed says so and stops -- going ahead anyway would throw the work
        away *after* being told to keep it.

        One message, like :meth:`_may_lose_world`'s: the question is only ever
        about the level in hand, and ``detail`` is what going ahead would cost,
        which is what differs between the askers.
        """
        answer = self._ask_to_save(
            f"Level {hexnum(self._level, 3)} has unsaved changes.", detail
        )
        if answer is Choice.CANCEL:
            return False
        return True if answer is Choice.DISCARD else self.save_level()

    def _may_lose_world(self, detail: str) -> bool:
        """:meth:`_may_lose_level`'s twin for the world map, saving through
        :meth:`save_world_map`. One message, because there is one world map
        and the question is only ever about it; ``detail`` is what going ahead
        would cost, which is what differs between the askers."""
        answer = self._ask_to_save("The world map has unsaved changes.", detail)
        if answer is Choice.CANCEL:
            return False
        return True if answer is Choice.DISCARD else self.save_world_map()

    def _may_lose_palettes(self, detail: str) -> bool:
        """:meth:`_may_lose_world`'s twin for the colours, saving through
        :meth:`save_palettes`. The shared file's edits and the levels' own
        palettes are one document, so one question covers both."""
        answer = self._ask_to_save("The colours have unsaved changes.", detail)
        if answer is Choice.CANCEL:
            return False
        return True if answer is Choice.DISCARD else self.save_palettes()

    def _may_close_palettes(self) -> bool:
        """Settle unsaved colours before the panel closes. True lets it go.

        Beside :meth:`_may_lose_palettes`, with one difference: there Discard
        means "go ahead without saving", because what follows -- a close, a
        reopen -- is what takes the work. Closing the panel takes nothing by
        itself, so Discard here has to do the discarding, or the panel would
        close over edits still colouring the canvas with no surface left
        showing them.
        """
        if not self._palette_unsaved:
            return True
        answer = self._ask_to_save(
            "The colours have unsaved changes.",
            "Discarding reverts to the last save.",
        )
        if answer is Choice.CANCEL:
            return False
        if answer is Choice.DISCARD:
            self._discard_palettes()
            return True
        return self.save_palettes()

    def _may_leave_level_for_map(self) -> bool:
        """Ask before the map takes the canvas from an edited level.

        True to go on. **Discard here keeps the work**, unlike the question
        :meth:`_may_discard` puts at the cartridge's doors: the document is
        held while the map is up and :meth:`_leave_world` gives it back
        untouched, so there is nothing for going ahead to throw away and
        nothing for discarding to undo. What the question is for is that the
        title's mark answers for the view it sits over -- see :attr:`unsaved`
        -- so without it an edited level would go quietly dark behind the map.
        """
        if self._project is None or self._level is None or not self._level_unsaved:
            return True
        return self._may_lose_level(
            "The map takes the canvas. Going on keeps them as they are; "
            "only Save puts them in the project."
        )

    def _may_leave_map_for_level(self) -> bool:
        """:meth:`_may_leave_level_for_map`'s twin, asked on the way back.

        The same question for the same reason, and the map keeps its work the
        same way: the document outlives the mode, and coming back finds it.
        """
        if self._project is None or not self._world.edited:
            return True
        return self._may_lose_world(
            "The level takes the canvas. Going on keeps them as they are; "
            "only Save puts them in the project."
        )

    def _may_replace(self, level: int) -> bool:
        """Ask before a load puts ``level`` where the level in hand is.

        **The gesture asks, not :meth:`load_level`.** Every way of asking for a
        level comes through here first -- the picker, the trail, a search result
        -- because cancelling has to leave the gesture's own state alone as well:
        the picker back on the level actually held, the trail's finger where it
        was. By the time a load has been asked for, those have already moved.

        Answered for a reload of the same level too. It replaces the document
        exactly as a switch does, so the work goes the same way.
        """
        if self._project is None or self._level is None or not self._level_unsaved:
            return True
        return self._may_lose_level(
            "Loading it again reverts to the last save."
            if level == self._level
            else f"The editor holds one level, so {hexnum(level, 3)} takes its place."
        )

    def _may_leave_for(self, place: Place | None) -> bool:
        """Whether the trail may step to ``place``. True to go ahead.

        A step within the level in hand is a scroll and costs nothing; only one
        that lands in another level replaces the document.
        """
        if place is None or place.level == self._level:
            return True
        return self._may_replace(place.level)

    def _have_somewhere_to_save(self) -> bool:
        """Whether there is a project to write into, saying so when there is
        not. What each of the three Save routes asks first: the work is in
        memory and stays there, which is worth saying rather than a row that
        quietly does nothing."""
        if self._project is not None:
            return True
        self._alert(
            "There is no project open to save into.",
            detail="Project > New Project makes one; the work stays in "
            "memory until then.",
        )
        return False

    def _confirm(self, message: str, detail: str = "") -> bool:
        """Ask before something that cannot be taken back. True to go ahead.

        Beside :meth:`_alert` and for the same reason: one surface the tests
        replace, rather than a scattering of ``QMessageBox`` calls that each
        hang the suite under Qt's offscreen platform.
        """
        return ask(self, message, detail)

    def _ask_to_save(self, message: str, detail: str = "") -> Choice:
        """Offer to save work about to be lost. Beside :meth:`_confirm`, and the
        seam the tests replace for the same reason."""
        return ask_to_save(self, message, detail)

    def _may_export(self) -> bool:
        """Offer to save work an export would otherwise leave out. True to go on.

        A build reads the project's overlay off disk, so anything unsaved is
        simply not in the cartridge that gets written -- and all four documents
        are saved into that overlay, so all four are asked about, exactly as
        :meth:`_may_discard` asks. That is the one way this differs from it:
        nothing is lost by going ahead, so Discard here means "export what the
        project last saved" rather than "throw this away".
        """
        if self._project is None:
            return True
        missing = "Not in the project yet, so the export leaves them out."
        if self._level_unsaved and not self._may_lose_level(missing):
            return False
        if self._world.edited and not self._may_lose_world(missing):
            return False
        if self._palette_unsaved and not self._may_lose_palettes(missing):
            return False
        return not self._strings_unsaved or self._may_lose_strings(missing)

    def _may_discard(self) -> bool:
        """Ask about unsaved work before something outside the level takes it.

        True to go ahead. Closing, opening a project and resizing the cartridge
        all end with the level in hand gone; :meth:`_may_replace` is the same
        question asked by a load.

        One question per unsaved document, because they are saved separately
        and an answer about one says nothing about the other.
        """
        if self._project is not None and self._level_unsaved:
            if not self._may_lose_level("Discarding reverts to the last save."):
                return False
        if (
            self._project is not None
            and self._world.edited
            and not self._may_lose_world("Discarding reverts to the last save.")
        ):
            return False
        # The colours too: a reopened cartridge re-reads the palette document
        # (`_read_palette`), so an unticked question here was a recolour -- or
        # a level's freshly ticked palette -- silently thrown away.
        if (
            self._project is not None
            and self._palette_unsaved
            and not self._may_lose_palettes("Discarding reverts to the last save.")
        ):
            return False
        # And the strings: their window goes with the project, and a window
        # torn down with the work in it would take the edits silently.
        if (
            self._project is not None
            and self._strings_unsaved
            and not self._may_lose_strings("Discarding reverts to the last save.")
        ):
            return False
        # And the Map16 tables, which their window asks about itself.
        if self._map16 is not None and not self._map16.may_close():
            return False
        # And the secondary entrances, which ask the same way.
        if self._secondary_entrances is not None and (
            not self._secondary_entrances.may_close()
        ):
            return False
        return True

    def _may_lose_strings(self, detail: str) -> bool:
        """:meth:`_may_lose_palettes`' twin for the text, saving through
        :meth:`save_strings`."""
        answer = self._ask_to_save("The strings have unsaved changes.", detail)
        if answer is Choice.CANCEL:
            return False
        return True if answer is Choice.DISCARD else self.save_strings()

    # -- searching ----------------------------------------------------------

    def focus_find(self) -> None:
        """Ctrl+F: show the search bar if it is hidden, and type into it.

        Unhiding is part of the gesture rather than a separate step - the bar
        can be switched off from the View menu, and a shortcut that focused
        something invisible would read as doing nothing at all.
        """
        # Search is over levels, and the world map is not one: focusing a bar
        # whose every result would load a level over the map means nothing.
        if self._mode is EditorMode.WORLD:
            return
        self.find_bar.setVisible(True)
        self.find_bar.focus_query()

    def jump_to(self, where: Occurrence) -> None:
        """Go and look at a search result: its level, selected and in view.

        Two paths, and which one is taken is the whole of the complication. When
        the occurrence is in the level already on the canvas there is nothing to
        wait for and it is revealed here. When it is not, the level has to be
        loaded first -- which is an emulator round trip on another thread -- so
        the occurrence is *held* and revealed when the load comes back.

        Only one is ever held. A second jump before the first arrives replaces
        it, which is what someone leaning on Next means: they want where they
        are going, not every place they passed through.
        """
        if self._rom is None:
            return
        # F3 reaches the bar's methods whatever the toolbars' enablement, and
        # a jump is a level load: over the world map it would repaint the
        # canvas with a level while the mode still says otherwise.
        if self._mode is EditorMode.WORLD:
            return
        if where.level == self._level and self._snapshot is not None:
            self._pending = None
            self._reveal(where)
            return
        if not self._may_replace(where.level):
            return
        self._pending = where
        self.load_level(where.level)

    def _reveal(self, where: Occurrence) -> None:
        """Select the record ``where`` names in the level now held, and show it.

        Matched by **stream offset**, which is what identifies a record: two
        identical records in a level are two things, and neither position nor
        contents tells them apart. So the search selects the one it found rather
        than the first that looks like it.

        A record that is not there is not an error worth a dialog. The index is
        of the file on disk and the held level can have been edited since -- a
        header change re-reads the streams -- so the honest answer is to go to
        the place and say nothing was found at it.
        """
        # The index is of Layer 1's objects and the sprite list, so a jump
        # into a level being edited on Layer 2 has to come back to the mode
        # that holds what was found -- the ants would otherwise mark a record
        # this mode does not draw outlines for.
        if self._on_layer2:
            self.set_level_editing(0)
        found = self._record_at(where)
        if found is not None:
            self._select({found.uid})
        self.view.center_on(block_center(where.column, where.row))

    def _record_at(self, where: Occurrence) -> LevelObject | Sprite | None:
        """The held level's own record for an occurrence, by stream offset."""
        # Layer 1's objects, not :attr:`_objects`: an occurrence's offset is
        # an offset into the stream the index walked, and that is Layer 1's.
        records = (
            self._sprites
            if where.kind is SearchKind.SPRITE
            else (() if self._doc is None else self._doc.objects)
        )
        for record in records:
            if record.offset == where.offset:
                return record
        return None

    def _serve_pending(self) -> None:
        """Reveal the search result the level that just arrived was loaded for.

        Guarded on the level actually matching: a load can also be asked for by
        the level picker while a jump is outstanding, and revealing a record
        from a different level would select whatever happened to share its
        offset.
        """
        pending, self._pending = self._pending, None
        if pending is not None and pending.level == self._level:
            self._reveal(pending)

    # -- what is held, and the panel that describes it ------------------------
    #
    # The selection is ids rather than records -- every edit rewrites both
    # streams, so the objects are replaced wholesale and only an id survives it.
    # Everything below either turns a pixel into ids, changes which ids are
    # held, or puts what they name in front of the properties panel.

    def _stack_at(self, pos: QPoint) -> list[LevelObject | Sprite]:
        """Everything the clicked pixel covers, topmost first.

        Sprites first, and only while they are shown - as artwork or as a box,
        either being enough. A sprite stands *in front of* the level, so the
        first click on one is a click on the sprite and not on the ledge behind
        it; the ledge is the next step of the cycle. Switching the layer off
        still takes the sprites out of reach entirely: what is in the picture is
        what can be picked out of it, and an outline with the artwork hidden is
        still something in the picture to click.
        """
        # In pixels for the sprites, because their boxes are their artwork's; in
        # blocks for the objects, because the tilemap is. Each is asked in its
        # own units.
        # And not while Layer 2's records are what a gesture works: a sprite
        # belongs to the other editing mode -- the Editing box says so in as
        # many words -- so it is drawn there and not picked out of the picture.
        sprites = (
            sprite_stack_at(self._sprites, pos.x(), pos.y(), self._sprite_art)
            if self.options.any_sprites and not self._on_layer2
            else []
        )
        # A click lands on any tile the object drew, not just the one its record
        # names -- keyed by uid, the same map `_draw_overlays` outlines from, so
        # what a click reaches is what the eye sees. An object the trace said
        # nothing about is absent from it and falls back to its record's own
        # rectangle rather than becoming unclickable.
        objects = object_stack_at(
            self._objects, pos.x() // BLOCK, pos.y() // BLOCK, drawn=self._drawn
        )
        return [*sprites, *objects]

    def _select(self, selection: Collection[int], redraw: bool = True) -> None:
        """Make ``selection`` what is held: the panel, the outlines, the readout.

        Repaints only when the selection actually changed - a second click on the
        same object should cost nothing, and the panel should not flicker through
        its own contents. ``redraw`` is what a marquee turns off: it re-selects
        on every frame of the drag and repaints once itself, and doing it twice
        per frame is visible at a quarter zoom over a whole level.

        Records that are no longer in the level drop out rather than lingering,
        which is what makes this safe to call after an undo: the ids that survive
        are the ones the level still has.
        """
        held = frozenset(selection)
        if self._doc is not None:
            held = frozenset(uid for uid in held if self._doc.record(uid) is not None)
        if held:
            # A record and a screen are not both held: the panel describes one
            # thing, and the ants mark what it describes. Cleared here rather
            # than at each call site so that anything that selects a record --
            # a click, a marquee, a search result, a paste -- takes the screen
            # down by doing so.
            self._drop_screen()
        if held == self._selection:
            return
        self._selection = held
        self._describe_selection()
        # Delete and the two reorder rows act on what is held, and Delete is a
        # key as well as a menu row -- so this is where it is armed and
        # disarmed.
        self.sync_edit_actions()
        if redraw:
            self._draw_overlays()

    def _select_screen(self, screen: int | None) -> None:
        """Hold ``screen``, or nothing with ``None``.

        The other half of :meth:`_select`, over the one thing in a level that
        is not a record. What it holds is the *screen*, not the exit on it: a
        screen with no exit is exactly the case worth selecting -- it is where
        an exit is added from -- and a screen that has one is described through
        it (:func:`~shiny_mushroom.level_exits.screen_fields`).

        Both handles land here: a click on the number box on the canvas, and a
        row selected in the Level Exits window. The window is told either way,
        so the two never disagree about what is held.
        """
        if self._doc is None and screen is not None:
            return
        if screen == self._screen_selected:
            return
        self._screen_selected = screen
        if screen is not None:
            # Exclusive, the same way round as `_select`'s clause.
            self._select(frozenset())
        self._level_exits.show_screen(screen)
        self._describe_selection()
        self._draw_overlays()

    def _drop_screen(self) -> None:
        """Take the screen selection down without describing anything: what
        :meth:`_select` calls on its way to describing a record."""
        if self._screen_selected is None:
            return
        self._screen_selected = None
        self._level_exits.show_screen(None)

    @property
    def _screen_record(self) -> ScreenExit | None:
        """The held screen as the record its fields are read off, or ``None``
        when a record is held instead."""
        if self._doc is None or self._screen_selected is None or self._selection:
            return None
        return ScreenExit(
            self._doc,
            self._screen_selected,
            self._level_choices,
            self._entrances_offered(),
        )

    def _screen_overlays(self) -> list[Overlay]:
        """The ants around the held screen, or nothing."""
        record = self._screen_record
        if record is None or self._shape is None:
            return []
        columns, rows = self._shape.screen
        along = record.screen * (rows if self._shape.vertical else columns)
        left, top = (0, along) if self._shape.vertical else (along, 0)
        return screen_overlays(
            QRect(left * BLOCK, top * BLOCK, columns * BLOCK, rows * BLOCK)
        )

    def _selected_fields(self) -> tuple[Record, list[Field]] | None:
        """The one held record and the fields it offers, if exactly one is held.

        An object needs the level's tileset to say what it is and a sprite does
        not, which is the whole of the difference between the two here: both
        hand back a record and a list of descriptors, and the panel has never
        known which kind of thing it is describing.
        """
        if self._doc is None:
            return None
        records = self._doc.records(self._selection)
        if len(records) != 1:
            return None
        thing = records[0]
        if isinstance(thing, Sprite):
            return thing, thing.fields(self._doc.shape)
        return thing, thing.fields(self._doc.fg_bg_tileset, self._doc.shape)

    def _refresh_properties(self) -> None:
        """Put the held record's current values back into the panel's widgets.

        Called after an edit rather than after a selection change: the record
        is a different object every time -- every edit is a rewrite -- and the
        rows have to follow it without the panel being rebuilt under the
        keyboard. A selection that is no longer one record falls back to
        describing it from scratch.
        """
        screen = self._screen_record
        if screen is not None:
            # The rows change with the screen -- adding an exit swaps one set
            # for the other -- and the panel rebuilds itself when the keys no
            # longer match, so a refresh is all this has to say either way.
            self.properties.refresh(screen_fields(screen), screen)
            return
        found = self._selected_fields()
        if found is None:
            self._describe_selection()
            return
        record, fields = found
        self.properties.refresh(fields, record)

    def _commit_field(self, key: str, value: int) -> None:
        """Apply one committed property-panel field, wherever it belongs."""
        self._edit_surface().commit_field(key, value)

    def _commit_record_field(self, key: str, value: int) -> None:
        """Apply one committed property-panel field to whatever is held.

        A held **screen** takes the whole of the panel, so it takes the whole
        of this too -- see :meth:`commit_screen_field`, which is also where the
        Level Exits window's cells land.

        The panel says which field and what value; what that *means* is the
        field descriptor's, and where it lands is the document's. Nothing here
        knows what a column or a settings byte is, which is what lets a new
        property be one descriptor in :mod:`shiny_mushroom.objects` and nothing
        in this file.
        """
        if self._screen_selected is not None and not self._selection:
            self.commit_screen_field(self._screen_selected, key, value)
            return
        found = self._selected_fields()
        if self._doc is None or found is None:
            return
        record, fields = found
        for field in fields:
            if field.key != key:
                continue
            edited = field.applied(record, value)
            if edited is record:
                # The value is what it already was, or the field cannot be
                # written. Either way there is no edit, and pushing one would
                # put a step in the undo stack for tabbing through a box.
                self._refresh_properties()
                return
            if not self._commit(self._doc.replaced(record.uid, edited)):
                # Refused, or nothing changed once the streams were rewritten.
                # The widget is showing a value the record does not have, so
                # put the record's own back.
                self._refresh_properties()
            return

    def _describe_selection(self) -> None:
        """Put what is held into the properties panel.

        One record is described in full through its own fields, because that is
        what the panel is for. Several are counted instead: the fields of six
        objects laid end to end answer no question anyone asked, and what a
        group selection needs to say is how big it is and what is in it.
        """
        if self._doc is None:
            return
        screen = self._screen_record
        if screen is not None:
            self.properties.show_fields(
                screen_heading(screen), screen_fields(screen), screen
            )
            return
        records = self._doc.records(self._selection)
        if not records:
            self.properties.show_nothing()
            return
        if len(records) == 1:
            found = self._selected_fields()
            if found is not None:
                record, fields = found
                heading = (
                    record.describe()
                    if isinstance(record, Sprite)
                    else record.describe(self._doc.fg_bg_tileset)
                )
                self.properties.show_fields(heading, fields, record)
            return
        objects = sum(1 for record in records if isinstance(record, LevelObject))
        sprites = len(records) - objects
        parts = []
        if objects:
            parts.append(_plural(objects, "object"))
        if sprites:
            parts.append(_plural(sprites, "sprite"))
        rows = [("Selected", " and ".join(parts))]
        box = bounding_blocks(records)
        if box is not None:
            left, top, right, bottom = box
            rows.append(("Covering", f"{right - left + 1} x {bottom - top + 1} blocks"))
            rows.append(("From", f"{hexnum(left)}, {hexnum(top)}"))
        self.properties.show_properties(f"{len(records)} records selected", rows)

    # -- a screen's exit ------------------------------------------------------
    #
    # One screen, one exit, and three ways to reach it: the number box on the
    # canvas, the properties panel it fills, and the Level Exits window's rows.
    # All three land in `commit_screen_field`, which is why an add made in one
    # of them shows in the other two without any of them telling each other --
    # they are views of the document, and `_settle` refreshes every view there
    # is. See docs/editor/level-exits.md.

    def commit_screen_field(self, screen: int, key: str, value: int) -> None:
        """Apply one committed field of ``screen``'s exit.

        The two :class:`~shiny_mushroom.fields.Action` keys are edits of their
        own -- an exit is added and removed rather than written -- and the rest
        go through the descriptor, exactly as a record's do. A write that hands
        the record back unchanged is a refusal rather than a no-op only for the
        screen column, which is the one field that can be turned away, so that
        is the one this says anything about.
        """
        if self._doc is None:
            return
        if key == EXIT_ADD:
            self._add_exit(screen)
            return
        if key == EXIT_REMOVE:
            edited = without_exit(self._doc, screen)
            if edited is not None:
                self._commit(edited)
            return
        record = ScreenExit(
            self._doc, screen, self._level_choices, self._entrances_offered()
        )
        if key == EXIT_FOLLOW:
            self._follow_screen_exit(record)
            return
        for field in screen_fields(record) + exit_columns(record):
            if field.key != key:
                continue
            edited = field.applied(record, value)
            if edited is record:
                if key == EXIT_SCREEN and value != screen:
                    self._status_message(OCCUPIED, EDIT_REFUSED_MS)
                self._refresh_properties()
                return
            if self._commit(edited.document) and key == EXIT_SCREEN:
                # The record moved, so what is held is the screen it moved to
                # -- otherwise the panel would go on describing a screen that
                # no longer has an exit while the ants sat on the new one.
                self._select_screen(edited.screen)
            return

    def _follow_screen_exit(self, record: ScreenExit) -> None:
        """Open the level ``record``'s exit leads to.

        Which for an exit marked secondary is what the *arrival tables* say
        rather than the number in the record, that number being a row of
        those tables (:attr:`~shiny_mushroom.level_exits.ScreenExit.landings`).

        A byte both halves of the tables have an entrance written in lands in
        two levels, and a button can only open one: it opens the half the
        open level is in, which is the same reading of a number the whole
        editor takes -- ``$000``-``$0FF`` is the main map's and ``$100``-
        ``$1FF`` a submap's -- and says the other one out loud, because the
        thing that actually decides is which overworld map the player walked
        in from and no table here holds that.
        """
        landings = record.landings
        if not landings:
            self._status_message(
                f"Entrance {hexnum(record.entrance)} is not written in: there is "
                "nothing to open.",
                EDIT_REFUSED_MS,
            )
            return
        here, said = 0, ""
        if len(landings) > 1:
            submap = (
                self._level is not None and self._level >= secondary_entrances.SUBMAP
            )
            here = 1 if submap else 0
            said = (
                f"Entrance {hexnum(record.entrance)} leads to "
                f"{hexnum(landings[here], 3)} from this half of the tables and "
                f"{hexnum(landings[1 - here], 3)} from the other."
            )
        # The rows the levels came out of, in the same order, so the one that
        # was chosen also says where in that level the player lands. Empty for
        # an ordinary exit, which has no row and arrives through the
        # destination's own entrance.
        arrivals = record.arrivals
        self.follow_exit(
            landings[here], arrivals[here] if here < len(arrivals) else None
        )
        # After the load rather than before it, which posts a line of its own:
        # this is the one worth leaving on screen, and it says nothing about
        # whether the load happened.
        if said:
            self._status_message(said, EDIT_REFUSED_MS)

    def follow_exit(
        self, level: int, arrival: secondary_entrances.SecondaryEntrance | None
    ) -> None:
        """Open ``level`` and look at where an exit through ``arrival`` lands.

        The load is asynchronous, so where to look is held rather than acted
        on -- :meth:`_serve_arrival` is the other half. Held before the load
        is asked for and guarded on the level when it comes back, which is
        what a load this one refused leaves behind: an arrival nothing serves
        until that same level is opened again.

        Also the Secondary Entrances window's Go to, which is this gesture
        with the row already in hand rather than found through an exit.
        """
        self._arriving_at = (level, arrival)
        self._level_file_followed(level)

    def _serve_arrival(self) -> None:
        """Look at where the exit the level that just arrived was followed for
        lands.

        Two answers, and the difference is which of them the cartridge has
        already worked out. An exit through a **secondary entrance** names a
        row of the arrival tables, and the destination was loaded through its
        own entrance rather than through that row -- so where the row lands is
        read off it here (:func:`~shiny_mushroom.rom_patches.entrance_position`),
        and the level opens looking at a place the load itself never went. An
        **ordinary** exit arrives where the load already put the player, so
        the spawn the snapshot came back with is the answer and no table is
        read.

        Guarded on the level for :meth:`_serve_pending`'s reason: the picker
        can ask for a level while a follow is outstanding, and a view centred
        on another level's arrival would be a scroll nobody asked for.
        """
        arriving, self._arriving_at = self._arriving_at, None
        if arriving is None or self._snapshot is None:
            return
        level, arrival = arriving
        if level != self._level:
            return
        landed = self._snapshot.spawn
        if arrival is not None and self._rom is not None and self._shape is not None:
            try:
                landed = entrance_position(
                    self._rom,
                    arrival.screen,
                    arrival.x_index,
                    arrival.y_index,
                    self._shape.vertical,
                    where=self._addresses,
                )
            except IndexError:
                # An image too short to hold the position tables cannot say
                # where a row lands, and the spawn above is what is left --
                # the fallback :meth:`_level_shape` makes, for its reason.
                pass
        self.view.center_on(QPoint(landed.x, landed.y))

    def _screen_activated(self, screen: int) -> None:
        """A double click on ``screen``'s number box: take the exit it holds.

        The box is the screen's handle, and the only thing a screen holds that
        is somewhere else is its exit -- so the second click is the panel's and
        the window's "Open level" row, reached through the same dispatch rather
        than by loading a level from here. A screen with no exit leads nowhere,
        and the double click is then the click that held it and nothing more.
        """
        if self._doc is None or ScreenExit(self._doc, screen).record is None:
            return
        self.commit_screen_field(screen, EXIT_FOLLOW, 0)

    def add_screen_exit(self) -> None:
        """Put an exit on the lowest screen that has none -- the Level Exits
        window's footer.

        The lowest rather than the held one: the footer is a table-level
        gesture with no row behind it, and a level whose every screen already
        leads somewhere has nowhere for it to go, which it says instead of
        doing nothing.
        """
        if self._doc is None:
            return
        screen = free_screen(self._doc)
        if screen is None:
            self._status_message(
                "Every screen of this level already has an exit", EDIT_REFUSED_MS
            )
            return
        self._add_exit(screen)

    def _add_exit(self, screen: int) -> None:
        """Add an exit on ``screen`` and hold that screen, so the panel and the
        window are both describing what was just made."""
        if self._doc is None:
            return
        if self._commit(with_exit(self._doc, screen)):
            self._select_screen(screen)

    # -- the level's own settings -------------------------------------------

    def edit_header(self) -> None:
        """Edit the loaded level's header.

        **An edit like any other**, and that is the whole of what this method
        is: the header is part of the document, so the dialog's five bytes go
        through :meth:`_commit` exactly as a dragged object does. One undo step,
        the same save, and the picture a round trip later -- because a header is
        the one thing that changes what the *game* draws, and the only honest
        way to see a level under a different tileset is to hand the loader the
        different tileset and ask again.

        An accept that also repointed Layer 2 is still one undo step, but a
        different one: the header rides into the repoint's reload as part of
        the held document instead of committing first, and the step the reload
        commits carries both -- see :meth:`_repoint_layer2`.

        The level's own graphics row is a dialog of its own
        (:meth:`edit_level_graphics`): it is not the game's level record, and
        the cartridge only has room for it under a feature.

        That is a change of footing worth stating, because it used to be the
        opposite. The header was held beside the document, so an edit to it
        re-read the level in place: instant, and drawing the new screen count
        out of the **old** load's graphics and tilemap. A tileset changed that
        way showed a picture the game would never produce, and one made a screen
        longer showed whatever the old tilemap held past its end. It is a fifth
        of a second slower now and it is what the cartridge does.

        The shape is worked out here rather than by the document, which has no
        cartridge to ask -- see :meth:`_shape_for` -- and goes in with the bytes
        so the two can never arrive separately.

        **The four palette settings are shown while the dialog is open**, on
        the canvas behind it rather than only as swatches in the form: a set is
        the same twelve colours read from another place in the same file, so
        moving one is arithmetic over the capture and costs a repaint. The
        other nine fields wait for the reload, for the reason above. See
        :meth:`preview_header`.
        """
        if self._doc is None or self._snapshot is None:
            return
        try:
            result = HeaderDialog.edit(
                self,
                self._doc.header,
                layer2=self._layer2_options(),
                colours=self._header_colours,
                gap=self._layer2_gap_for_level,
                preview=self.preview_header,
            )
        finally:
            # The picture goes back to the document's header whichever way the
            # dialog closed, exactly as the graphics dialog's does: an accept
            # reloads onto the same colours, and a cancel is the level as it
            # was. Before the accept is acted on, so nothing below is reading
            # a canvas still wearing a preview.
            self.preview_header(None)
        if result is None:
            return
        edited, repointed = result
        if repointed is not None:
            # One accept, one undo step. The header bytes are not committed on
            # their own: they ride into the repoint's reload as part of the
            # held document, so the step the reload commits carries both and
            # one undo takes the whole dialog back.
            doc = self._doc
            if edited != doc.header:
                changed = doc.with_header(edited, self._shape_for(edited))
                if changed is not None:
                    doc = changed
            self._repoint_layer2(repointed, carrying=doc)
            return
        changed = self._doc
        if edited != changed.header:
            changed = changed.with_header(edited, self._shape_for(edited))
        if changed is not None and changed is not self._doc and self._commit(changed):
            self.statusBar().showMessage(
                f"Level header is now {format_bytes(edited)}", 5000
            )

    def edit_level_graphics(self) -> None:
        """Edit the loaded level's own graphics row.

        **An edit like any other**, the way the header is: the row is part of
        the document, so an accept is one undo step, the same save, and the
        picture a round trip later -- which the row needs, since which file a
        slot loads is decided by the loader and not by anything the canvas
        could recolour in place.

        Two things make it a dialog of its own rather than the header's
        second page. It is not the game's level record: a stock cartridge has
        nowhere to keep it, and it reaches one only through the
        ``level-graphics`` feature -- which is why an accept whose row first
        names a file offers that feature the way the palette tick does. And
        it is read *against* the header rather than being part of it: each
        slot's first entry is the file the header's tileset loads there,
        which is what makes a row of "the tileset's" a row that follows the
        header rather than a copy of it.

        A no to the feature keeps the row as it was, rather than one the save
        would write and no build would read. A yes rebuilds and reopens the
        cartridge, which drops the document, so the accept waits for the
        reload and commits onto what it brings -- see
        :attr:`_pending_graphics_edit`.
        """
        if self._doc is None or self._snapshot is None:
            return
        level = self._snapshot.level
        choices = self._graphics_choices()
        if not choices:
            self._status_message(NO_GRAPHICS_ROW, 8000)
            return
        try:
            graphics = LevelGraphicsDialog.edit(
                self,
                self._doc.header,
                self._doc.graphics,
                choices=choices,
                animated=level_graphics.animated_choices(self._project),
                tileset_rows=self._tileset_rows_for,
                vram=self.graphics_vram,
                preview=self.preview_graphics,
            )
        finally:
            # The picture goes back to the document's row whichever way the
            # dialog closed: an accept commits below and lands on the same
            # picture, and a cancel is the level exactly as it was.
            self.preview_graphics(None)
        if graphics is None or graphics == self._doc.graphics:
            return
        if not level_graphics.is_inherit(graphics) and not self._want_feature(
            LEVEL_GRAPHICS.id
        ):
            self._status_message(
                f"Level {hexnum(level, 3)}'s graphics were left as they were: "
                f"the {LEVEL_GRAPHICS.name} feature is off.",
                8000,
            )
            return
        if self._doc is None:
            # A yes rebuilt and reopened the cartridge, and the document went
            # with it: the accept waits for the reload and commits onto the
            # document it brings.
            self._pending_graphics_edit = (level, graphics)
            return
        if self._commit(self._doc.with_graphics(graphics)):
            self.statusBar().showMessage(
                f"Level {hexnum(level, 3)}'s graphics are now "
                f"{format_bytes(graphics) if graphics else TILESETS_OWN}",
                5000,
            )

    def _apply_pending_graphics_edit(self, graphics: bytes) -> None:
        """Commit a graphics-dialog accept that waited for a reopen -- see
        :attr:`_pending_graphics_edit` -- onto the document just read, and ask
        for the picture the new row draws."""
        if self._doc is None or self._history is None:
            return
        changed = self._doc.with_graphics(graphics)
        if changed is self._doc or not self._history.commit(changed):
            return
        self._doc = changed
        self._refresh_picture()

    def _graphics_choices(self) -> list[tuple[int, str, str]]:
        """What the graphics dialog offers each slot, or nothing -- no dialog
        -- without a project to save a row into, or over an image whose
        tileset lists cannot be read."""
        if self._project is None or self._rom is None or not self._addressable:
            return []
        try:
            if gfx_list_rows(self._rom, where=self._addresses) is None:
                return []
            return level_graphics.choices(self._project)
        except (ProjectError, ValueError, OSError):
            return []

    def _tileset_rows_for(self, header: bytes) -> tuple[bytes, bytes] | None:
        """The four files each of ``header``'s two tilesets loads, off the
        cartridge, for the Graphics page's first entries; ``None`` where the
        image cannot say."""
        if self._rom is None or not self._addressable:
            return None
        try:
            return level_graphics.tileset_rows(
                self._rom,
                self._addresses,
                field_value(header, "sprite_tileset"),
                field_value(header, "fg_bg_tileset"),
            )
        except ValueError:
            return None

    def _layer2_options(self) -> Layer2Options | None:
        """What the header dialog's Layer 2 subsection should offer.

        ``None`` -- no subsection -- without a project to write a repoint
        into, and for a tree or a level number the table cannot answer for; a
        header edit works in memory alone, but a pointer edit has nowhere to
        live except the project's copy of ``levels/pointers/layer2.asm``.
        """
        if self._project is None or self._level is None:
            return None
        try:
            table = self._project.layer2_table()
            offered = self._project.layer2_choices()
        except (Layer2TableError, ProjectError, OSError):
            return None
        if self._level >= len(table.entries) or not offered:
            return None
        return Layer2Options(choices=offered, current=table.entry(self._level))

    def _layer2_gap_for_level(
        self, header: bytes, entry: Layer2Entry
    ) -> Layer2Gap | None:
        """The header dialog's check, bound to the open level: whether these
        five bytes over that entry would hang the load. ``None`` without a
        project, which is the same dialog with no Layer 2 subsection."""
        if self._project is None or self._level is None:
            return None
        try:
            return self._project.layer2_gap(self._level, entry=entry, header=header)
        except (Layer2TableError, ProjectError, MwlError, OSError):
            # A tree that cannot answer is not a level that will not load.
            return None

    def _repoint_layer2(
        self, entry: Layer2Entry, carrying: Level | None = None
    ) -> None:
        """Write the level's Layer 2 pointer into the project, and reload.

        A reload rather than a redraw, because whether Layer 2 is a background
        decides the level's *shape* -- how every object and sprite record is
        read -- so the document has to be rebuilt from a load made under the
        new pointer.

        **One undo step, all the same.** The reload replaces the document, but
        it commits onto the level's history rather than starting one -- the
        arriving document is pushed with a :class:`RepointMark`, which is what
        lets a walk back across it rewrite the table and put the replaced
        document back. :meth:`_walk_repoint` is the other half.

        **And it carries the work in hand.** ``carrying`` -- the held document,
        with whatever the dialog changed beside the pointer -- is written over
        the image the reload draws from, so unsaved edits come through the
        replacement instead of being discarded by it. That is why nothing asks
        about unsaved work here any more: what survives the reload needs no
        question, and what a kind flip cannot carry (the other kind's Layer 2)
        is one Ctrl+Z away.
        """
        if self._project is None or self._level is None:
            return
        try:
            before = self._project.layer2_table().entry(self._level)
            self._project.save_layer2_pointer(
                self._level, entry, header=None if carrying is None else carrying.header
            )
        except (Layer2TableError, ProjectError, OSError) as error:
            self._alert(
                f"Level {hexnum(self._level, 3)}'s Layer 2 could not be repointed.",
                detail=str(error),
            )
            return
        self._pending_repoint = (
            self._level,
            RepointMark(before, entry),
            None if carrying is None else carrying.graphics,
        )
        pointer = self._repointed_layer2(entry)
        try:
            patches = pointer | self._level_document_patch(carrying)
        except ValueError as error:
            # A cartridge with nowhere to put a stream that has grown: the
            # reload shows what the project holds, and the held edits are on
            # the undo stack rather than in the picture.
            self.statusBar().showMessage(
                f"The held edits could not ride the reload: {error}", 8000
            )
            patches = self._project_patches() | pointer
        self.load_level(self._level, patches)

    def _repointed_layer2(self, entry: Layer2Entry) -> dict[int, bytes]:
        """Everything a rewritten Layer 2 pointer changes besides the level:
        the viewers reading the table, and the standing build-needed reading.

        The gather is run for its ``note`` as much as for its bytes: the note
        is what says whether the entry now written can be made to show without
        a build -- and what clears the reading when a repoint is taken back,
        rather than leaving ``[build needed]`` standing over a stock table.
        The bytes go back to the caller with a reload to feed them into.
        """
        pointer = self._layer2_pointer_patch()
        self._refresh_level_data()
        self._refresh_memory_map()
        self.statusBar().showMessage(
            f"Level {hexnum(self._level, 3)}'s Layer 2 now reads {entry.describe()}",
            5000,
        )
        return pointer

    def _shape_for(self, header: bytes) -> Geometry:
        """The shape a level with these header bytes would have.

        Three inputs, and only one of them is simply a header field:

        - **The screen count** is header byte 0, stored minus one.
        - **Whether it runs down** is not in the header at all. Byte 1 holds a
          level *mode*, and whether that mode is vertical is a byte of the
          cartridge's ``VerticalTable`` -- so it is asked of the ROM, through
          the same lookup the game's own header parser makes. While the mode has
          not changed, the snapshot's answer is preferred: that is the flags
          byte the game wrote on the machine that ran the load, which is a
          better answer than re-reading the table it came from.
        - **Whether Layer 2 is a background** is a property of the level rather
          than of its header -- it is the level's Layer 2 pointer -- so it comes
          from the load unchanged and no header *bytes* can move it. Repointing
          Layer 2 (:meth:`_repoint_layer2`) changes it by reloading the level,
          which is what keeps this answer the load's alone.

        An image too short to hold the table is answered with what the load
        said, for the reason :meth:`test_patches` gives: reading off the end of
        a stub is worse than a stale answer about a level it cannot draw.
        """
        vertical = self._snapshot.vertical
        mode = header[1] & 0x1F
        if self._rom is not None and mode != self._snapshot.level_mode:
            try:
                vertical = vertical_level(self._rom, mode, where=self._addresses)
            except IndexError:
                pass
        return level_shape(
            screen_count=(header[0] & 0x1F) + 1,
            vertical=vertical,
            layer2_background=self._snapshot.layer2_background,
        )

    # -- where each colour on screen came from --------------------------------

    def _palette_under(self, patches: dict[int, bytes]) -> bytes | None:
        """The palette file a load carrying ``patches`` boots wearing.

        **Read off the patches themselves**, not off which call site built
        them. A canvas refresh reloads through :meth:`test_patches`, which
        carries :meth:`_palette_patch` so a test run boots the right colours --
        and the capture that comes back is then wearing them too. A capture
        checked against the cartridge's own file instead fails every offset
        that was edited, dropping them to ``UNMAPPED`` and leaving the colour
        just changed hatched and unpickable.

        The cartridge's own colours when a load carries no palette, which is
        every load but a refresh -- and the world map, which takes no patches
        at all. Per table, because the patches are: a run that recoloured a
        boss fade and nothing else carries that table, and the other two are
        the cartridge's.

        Over the document the image was **read** as, not over a fresh read of
        it: a refresh keeps the capture the level already had, so what that
        capture was taken under has to be the same buffer it was measured
        against.
        """
        if self._rom_palette is None:
            return None
        return cart_patches.palette_over(self._rom_palette, patches, self._addresses)

    def _read_provenance(self, snapshot) -> None:  # noqa: ANN001 - a snapshot
        """Work out where this level's colours came from, and keep the capture.

        Kept beside the snapshot because the snapshot's own CGRAM stops being
        the capture the moment a colour is edited.
        """
        self._captured_cgram = snapshot.cgram
        self._captured_backdrop = snapshot.back_area_color
        self._captured_level = snapshot.level
        self._captured_header = snapshot.header
        self._captured_vram = snapshot.vram
        # What the load actually put in VRAM: the document's row is what
        # `level_document_patch` wrote into the image it booted. Where it could
        # not -- no rows in the cartridge -- this claims files the capture does
        # not hold, and the tile-by-tile compare in `vram_with_graphics` then
        # matches nothing and writes nothing, which is the same "shows after a
        # build" answer the row's own arm gives.
        self._captured_graphics = self._effective_graphics(
            snapshot.header, self._doc.graphics if self._doc is not None else b""
        )
        # And which animated tiles it was loaded under, so the next sync
        # measures a move from here rather than from the level before it --
        # see `_weigh_the_animated_tiles`.
        self._synced_animated = level_graphics.animated_file(
            self._doc.graphics if self._doc is not None else b""
        )
        self._capture_slot_files()
        # The capture is here, so what it was made under is now settled: what a
        # recolour still has to write onto it is measured against that.
        self._remeasure_palette()
        self._compute_provenance()

    def _compute_provenance(self) -> None:
        """Where each colour on screen came from, under the document as it
        stands.

        Derived from the kept capture rather than taken once beside it,
        because the answer moves without the canvas moving: ticking a level
        into a palette of its own turns the whole scene into that blob's
        bytes, and unticking hands it back to the loader model. So
        :meth:`_palette_changed` recomputes it on every document step.
        """
        self._provenance = None
        self._backdrop_offset = None
        if self._captured_cgram is None or self._captured_header is None:
            return
        level = self._captured_level
        if level is not None and self._level_palettes.get(level) is not None:
            # The level wears its own palette: colour n of the screen is word
            # n of the blob, no model and nothing to confirm. The player's
            # colours stay the shared file's -- the game re-uploads them every
            # frame over whatever the blob put there -- so their swatches keep
            # pointing at the file, exactly as they do under the loader model.
            found = level_palettes.provenance(level)
            blob = self._capture_palette
            if blob is not None:
                run = palette_map.player_run(blob, self._captured_cgram)
                if run is not None:
                    for index, offset in enumerate(
                        palette_map.provenance(blob, self._captured_cgram, (run,))
                    ):
                        if offset != palette_map.UNMAPPED:
                            found[index] = offset
            self._provenance = found
            self._backdrop_offset = level_palettes.backdrop_offset(level)
            return
        blob = self._capture_palette
        if blob is None:
            return
        try:
            self._provenance = palette_map.level_provenance(
                blob,
                self._captured_cgram,
                background=field_value(self._captured_header, "background_palette"),
                foreground=field_value(self._captured_header, "foreground_palette"),
                sprite=field_value(self._captured_header, "sprite_palette"),
            )
            offset = palette_map.back_area_offset(
                field_value(self._captured_header, "back_area_color")
            )
        except PaletteError:
            return
        # The backdrop is the PPU's fixed colour rather than a CGRAM entry, so
        # it is verified on its own: the sky set has to hold the colour the
        # capture is showing before an edit to it is offered.
        if palettes.color(blob, offset) == self._captured_backdrop:
            self._backdrop_offset = offset

    def _recoloured(self, snapshot):  # noqa: ANN001, ANN202 - a snapshot
        """``snapshot`` as the palette document has it, under the header in
        force.

        Handed back unchanged when no edit reaches it, so a caller can tell a
        recolour from a redraw with nothing to do.
        """
        if self._captured_cgram is None or self._provenance is None:
            return snapshot
        cgram = palette_map.recolored(
            self._captured_cgram, self._provenance, self._palette_over_capture
        )
        backdrop = self._captured_backdrop
        if self._backdrop_offset is not None:
            backdrop = self._palette_over_capture.get(self._backdrop_offset, backdrop)
        cgram, backdrop = self._under_previewed_header(cgram, backdrop)
        if cgram is snapshot.cgram and backdrop == snapshot.back_area_color:
            return snapshot
        return replace(snapshot, cgram=cgram, back_area_color=backdrop)

    def _under_previewed_header(
        self, cgram: bytes, backdrop: int | None
    ) -> tuple[bytes, int | None]:
        """``cgram`` and the backdrop with the previewed header's palette
        settings in place of the captured header's.

        Both handed straight back while nothing is being previewed, which is
        every call but the ones a header dialog makes -- so the load path and
        every colour edit go through this untouched.
        """
        header = self._previewed_header
        blob = self._capture_palette
        if header is None or self._captured_header is None or blob is None:
            return cgram, backdrop
        if self._provenance is None:
            return cgram, backdrop
        try:
            moved = palette_map.with_header_sets(
                cgram,
                blob,
                self._provenance,
                held=_palette_sets(self._captured_header),
                wanted=_palette_sets(header),
                edits=self._palette_over_capture,
            )
            if self._backdrop_offset is not None:
                offset = palette_map.back_area_offset(
                    field_value(header, "back_area_color")
                )
                backdrop = self._palette_over_capture.get(
                    offset, palettes.color(blob, offset)
                )
        except PaletteError:
            return cgram, backdrop
        return moved, backdrop

    def _effective_graphics(self, header: bytes, row: bytes) -> tuple[int, ...] | None:
        """The eight files a level with this header and this row loads, or
        ``None`` where the cartridge cannot say which files its tilesets name.

        The stubs' own arithmetic
        (:func:`smw_tools.level_graphics.effective`), over the two tileset
        rows read off the image for ``header``.
        """
        rows = self._tileset_rows_for(header)
        if rows is None:
            return None
        sprite_row, fgbg_row = rows
        try:
            record = decode_graphics(row) if row else None
            return effective_graphics(record, sprite_row=sprite_row, fgbg_row=fgbg_row)
        except (level_graphics.LevelGraphicsError, ValueError):
            return None

    def _graphics_file_vram(self, number: int, tileset: int) -> bytes | None:
        """File ``number`` in the form the uploader would put it in VRAM, or
        ``None`` where it cannot be read or has no slot of that shape.

        The project's own copy, overlay first -- so a repainted file previews
        as repainted, and a row is only ever previewed where there is a project
        to have one.

        **Remembered against the file's own stamp**, not the project's write
        count: a save moves one file, and keying on the project would throw
        away the seven that did not move and cost the whole 160 ms again on
        every save. The stamp comes from the reading
        :meth:`_graphics_swap_covers` has just taken, so the file that moved
        misses and the rest hit; a stock file the overlay does not hold has no
        stamp and never changes.
        """
        if self._project is None:
            return None
        try:
            stamp = self._graphics_stamps.get(graphics.raw_path(self._project, number))
        except (ProjectError, GraphicsError):
            stamp = None
        key = (str(self._project.root), stamp, number, tileset)
        held = self._graphics_vram.get(key)
        if held is None:
            try:
                held = codec.vram_bytes(number, self._project.graphics(number), tileset)
            except (ProjectError, GraphicsError, OSError):
                held = b""
            if len(self._graphics_vram) > 128:  # a redraw asks for a handful
                self._graphics_vram.clear()
            self._graphics_vram[key] = held
        return held or None

    def _regraphicsed(self, snapshot, row=None):  # noqa: ANN001, ANN202 - a snapshot
        """``snapshot`` as ``row`` has it -- the document's graphics row, or
        what a dialog is previewing over it, where ``row`` is ``None``.

        The colours' trick applied to the tiles. The canvas draws every tile
        out of the VRAM the capture was taken with, so a slot pointed at
        another file needs that file's bytes written where the old one's are
        -- not a level load, which is the 195 ms the picture would otherwise
        wait for a dropdown. What the capture was booted with is
        :attr:`_captured_graphics`; what the document now wants is the same
        arithmetic over the row it holds.

        Handed back unchanged when no slot moved, so a caller can tell a
        regraphic from a redraw with nothing to do -- :meth:`_recoloured`'s
        identity, for the same reason.

        A ``row`` is passed only by :meth:`graphics_vram`, which is asking
        what a row *would* look like rather than showing the one in force.
        """
        if self._captured_vram is None or self._captured_graphics is None:
            return snapshot
        if self._doc is None:
            return snapshot
        if row is None:
            row = (
                self._doc.graphics
                if self._previewed_graphics is None
                else self._previewed_graphics
            )
        wanted = self._effective_graphics(self._doc.header, row)
        if wanted is None:
            return snapshot
        tileset = field_value(self._doc.header, "fg_bg_tileset")
        swaps = []
        for slot, (was, now) in enumerate(
            zip(self._captured_graphics, wanted, strict=True)
        ):
            # What the slot held when the capture was taken. Kept outright
            # while the Graphics window is open, which is what lets a file
            # *repainted* since be swapped as well as a slot pointed
            # elsewhere; worked out from the file otherwise, which is right
            # exactly while its pixels have not moved.
            if self._captured_slot_vram is not None:
                held = self._captured_slot_vram[slot]
            elif was == now:
                continue
            else:
                held = self._graphics_file_vram(was, tileset)
            fresh = self._graphics_file_vram(now, tileset)
            if held is None or fresh is None or held == fresh:
                continue
            swaps.append((slot, held, fresh))
        # **Always built from the capture**, never from the snapshot in hand:
        # a row put back -- an undo, or a dialog cancelled -- wants the files
        # the level loaded with, and the snapshot on screen is wearing the ones
        # it is being asked to drop.
        vram = (
            self._captured_vram
            if not swaps
            else vram_with_graphics(self._captured_vram, swaps)
        )
        if vram == snapshot.vram:
            return snapshot
        return replace(snapshot, vram=vram)

    def _graphics_window_open(self) -> bool:
        """Whether somebody is working in the Graphics window right now."""
        return self._graphics_files is not None and self._graphics_files.isVisible()

    def _capture_slot_files(self) -> None:
        """Work out each slot's file as the capture holds it, or drop it.

        **The cost is paid only while the Graphics window is open.** Swapping a
        *repainted* file into the picture needs that file's bytes as of the
        capture -- the capture alone cannot tell a tile the file put there from
        one the animated tiles or the player wrote over it -- and working the
        eight out costs about 150 ms, most of it decompressing shipped
        streams. That is more than a level load can afford on the redraw path,
        which is every object dragged; it is nothing against opening a window,
        and it is exactly then that a save wants to reach the canvas without a
        195 ms reload. So the window's being open is the switch.

        Without them a slot is still swapped when the *row* points it at
        another file, which needs no such baseline -- see :meth:`_regraphicsed`.
        """
        self._graphics_stamps = self._raw_graphics_stamps()
        if not self._graphics_window_open() or self._captured_graphics is None:
            self._captured_slot_vram = None
            return
        tileset = (
            0
            if self._captured_header is None
            else field_value(self._captured_header, "fg_bg_tileset")
        )
        found = [
            self._graphics_file_vram(number, tileset)
            for number in self._captured_graphics
        ]
        self._captured_slot_vram = (
            None if any(one is None for one in found) else tuple(found)
        )

    def _raw_graphics_stamps(self) -> dict[Path, tuple[int, int]]:
        """What the overlay's raw graphics files are now -- a stat apiece over
        the files the project has edited, and none at all for one that has
        edited nothing."""
        if self._project is None:
            return {}
        try:
            return graphics.stamps(self._project)
        except (ProjectError, OSError):
            return {}

    def _graphics_swap_covers(self) -> frozenset[int] | None:
        """Which files moved since the last reading, when the swap can carry
        all of them -- or ``None`` when the game has to be asked again.

        The swap reaches the eight slots and nothing else, so a file uploaded
        elsewhere -- `GFX32`, `GFX33`, the Layer 3 files -- or one this level
        does not load at all leaves the picture to a reload, as does a change
        this cannot account for. Reading it moves the baseline on, so it is
        asked once per change.
        """
        if self._project is None or self._captured_graphics is None:
            return None
        now = self._raw_graphics_stamps()
        before, self._graphics_stamps = self._graphics_stamps, now
        moved = {
            path for path in set(before) | set(now) if before.get(path) != now.get(path)
        }
        if not moved:
            return None
        try:
            slots = {
                graphics.raw_path(self._project, number): number
                for number in self._captured_graphics
            }
        except (ProjectError, GraphicsError):
            return None
        if not moved <= set(slots):
            return None
        return frozenset(slots[path] for path in moved)

    def _sync_graphics(self) -> None:
        """Put the picture in the graphics the level's row names.

        The colours' path (:meth:`_palette_changed`) for the tiles: the
        snapshot is re-made over the capture and the layers repainted, with no
        second opinion asked of the emulator. Cheap enough to run on every
        document step and on every slot a dialog moves -- a swap is a couple of
        milliseconds of decoding and a repaint, against the 195 ms a level load
        costs.
        """
        if self._snapshot is None:
            return
        regraphicsed = self._regraphicsed(self._snapshot)
        if regraphicsed is not self._snapshot:
            self._snapshot = regraphicsed
            self._redraw_layers()
        self._weigh_the_animated_tiles()

    def _weigh_the_animated_tiles(self) -> None:
        """Ask for the picture again when the level's **animated tiles** have
        moved, since the swap above cannot carry them.

        The other eight slots are a file's bytes written into the capture's
        VRAM, which is why a dropdown costs milliseconds. The ninth is not:
        the animated tiles are decompressed and expanded into a WRAM buffer on
        the way into the level and reach VRAM three four-tile blocks at a
        time, so what a new file looks like is the game's own answer and there
        is no shortcut to it -- :func:`~shiny_mushroom.level_graphics.animated_file`.

        **The document's row, and on the move.** A row a dialog is only
        previewing is deliberately not read here: a load per dropdown is what
        the swap exists to avoid, so the ninth row waits for the accept, which
        is a commit like any other. And it is the *change* that asks, not the
        difference, so an image that cannot show it yet -- no rows in the
        cartridge until a build -- is asked once and not once per edit.
        """
        if self._doc is None or self._captured_vram is None:
            return
        wanted = level_graphics.animated_file(self._doc.graphics)
        before, self._synced_animated = self._synced_animated, wanted
        if before != wanted:
            self._refresh_picture()

    def graphics_vram(self, row: bytes) -> tuple[bytes, bytes] | None:
        """What a level whose graphics row is ``row`` is drawn out of: its
        VRAM and its CGRAM, or ``None`` with no capture.

        The capture with that row's slots swapped into it
        (:meth:`_regraphicsed`) -- what the Level Graphics dialog draws its
        panel of slots from, and the same bytes the canvas beside it is
        wearing. Asked *about* a row rather than told one, so the panel and
        the canvas's own preview (:meth:`preview_graphics`) can be driven by
        the same signal in either order.
        """
        if self._snapshot is None:
            return None
        held = self._regraphicsed(self._snapshot, row)
        return held.vram, held.cgram

    def _absorb_graphics(self, moved: frozenset[int]) -> None:
        """Make what is on the canvas the capture the next swap measures from.

        A repainted file reaches the picture by being written over the capture
        -- so once it is there, *that* is what the level is wearing, and a
        second save of the same file has to be measured against it rather than
        against the bytes the game uploaded.

        ``moved`` is the files that changed, and only their slots are worked
        out again: the other seven are what they were, and re-deriving them
        would cost the whole 160 ms the window paid once on the way in.
        """
        if self._snapshot is None or self._doc is None:
            return
        self._captured_vram = self._snapshot.vram
        wanted = self._effective_graphics(self._doc.header, self._doc.graphics)
        if wanted is not None:
            self._captured_graphics = wanted
        if self._captured_slot_vram is None or wanted is None:
            self._capture_slot_files()
            return
        tileset = field_value(self._doc.header, "fg_bg_tileset")
        held = list(self._captured_slot_vram)
        for slot, number in enumerate(wanted):
            if number not in moved:
                continue
            fresh = self._graphics_file_vram(number, tileset)
            if fresh is None:
                # Nothing to measure the next save against: fall back to
                # working the eight out, and to a reload if even that cannot.
                self._capture_slot_files()
                return
            held[slot] = fresh
        self._captured_slot_vram = tuple(held)

    def preview_graphics(self, row: bytes | None) -> None:
        """Show ``row`` on the canvas without committing it -- what the Level
        Graphics dialog drives while it is open, and ``None`` to go back to
        the document's own row, which is what closing it does either way."""
        if row == self._previewed_graphics:
            return
        self._previewed_graphics = None if row is None else bytes(row)
        self._sync_graphics()

    def preview_header(self, header: bytes | None) -> None:
        """Show ``header``'s colours on the canvas without committing them --
        what the Level Header dialog drives while it is open, and ``None`` to
        go back to the document's own header, which is what closing it does
        either way.

        **The four palette fields, and deliberately nothing else.** A set is
        twelve colours read from another place in the same file, so moving one
        is arithmetic over the capture and the picture is exact
        (:func:`~shiny_mushroom.palette_map.with_header_sets`). The rest of the
        header is not: a tileset decides which graphics load *and* which Map16
        definitions the tiles come out of and what each object number means, a
        level mode decides the geometry, and a screen count decides how much
        tilemap there is -- none of which a repaint over the capture can
        follow. Those are what the accept's reload is for
        (:meth:`edit_header`), and showing a half-answer for them would be the
        picture the game never produces that the reload exists to avoid.
        """
        held = None if header is None else bytes(header)
        if held == self._previewed_header:
            return
        self._previewed_header = held
        if self._snapshot is None:
            return
        recoloured = self._recoloured(self._snapshot)
        if recoloured is not self._snapshot:
            self._snapshot = recoloured
            self._redraw_layers()

    def _recoloured_world(self, snapshot):  # noqa: ANN001, ANN202 - a snapshot
        """The world map's capture as the palette document has it.

        One CGRAM per submap, each with a palette of its own, so each is
        accounted for separately -- and each is checked against the file the
        same way a level's is.
        """
        cgrams = list(snapshot.submap_cgram or (snapshot.cgram,))
        self._world_captured = tuple(cgrams)
        self._world_provenance = []
        blob = self._rom_palette
        if blob is not None:
            for submap, cgram in enumerate(cgrams):
                try:
                    self._world_provenance.append(
                        palette_map.overworld_provenance(blob, cgram, submap)
                    )
                except PaletteError:
                    self._world_provenance.append(None)
        return self._recoloured_submaps(snapshot)

    def _recoloured_submaps(self, snapshot):  # noqa: ANN001, ANN202 - a snapshot
        """``snapshot`` as the palette document has it, one CGRAM per submap.

        Handed back unchanged when it already wears these colours, exactly as
        :meth:`_recoloured` is -- and, like it, measured against **what the
        snapshot holds** rather than against the captures the colours are built
        from. Comparing against the captures answered the wrong question: with
        the document edited back to stock every recolour is the capture itself,
        so the comparison held, this returned the snapshot it was given -- which
        was still the *recoloured* one -- and `OverworldMode.recolour` then
        dropped it for being the snapshot it already had. Undo and "Put All
        Back" left the map wearing colours the document no longer carried.
        """
        # One provenance per capture, which `_recoloured_world` builds together.
        # A pair that does not line up would recolour some submaps and drop the
        # rest, which is worse than leaving the map as it is.
        if len(self._world_captured) != len(self._world_provenance):
            return snapshot
        found = [
            palette_map.recolored(cgram, prov, self._palette_over_rom)
            if prov is not None
            else cgram
            for cgram, prov in zip(
                self._world_captured, self._world_provenance, strict=True
            )
        ]
        if not found:
            return snapshot
        held = list(snapshot.submap_cgram or (snapshot.cgram,))
        if found == held:
            return snapshot
        return replace(
            snapshot,
            cgram=found[0],
            submap_cgram=tuple(found) if snapshot.submap_cgram else (),
        )

    def _world_parts(self) -> cart_patches.WorldParts:
        """The overworld tables a test run must agree with.

        The in-memory document wins where there is one -- saved or not, it is
        what the visuals show -- and the project's saved overlay answers when
        the mode was never opened.
        """
        if not self._world.ready:
            return cart_patches.world_parts_from_project(
                self._project,
                lambda parts: self._note_skipped(WORLD_TABLES, parts),
            )
        return cart_patches.world_parts_from_map(self._world.document)

    def _palette_patch(self) -> dict[int, bytes]:
        """The game's colours as the editor holds them, over the image's own."""
        if self._palette_base is None:
            return {}
        try:
            blob = self._palette.image(self._palette_base)
        except PaletteError:
            return {}
        return cart_patches.palette_patch(blob, self._rom, self._addresses)

    def _level_palette_patch(self) -> dict[int, bytes]:
        """The canvas level's own palette, over the blob a build placed.

        The blob lives in the bank the level-custom-palettes feature reserves
        (``Config/LevelCustomPalettes.asm``), placed wherever the blobs before
        it ended, so unlike the shared tables there is only somewhere to patch
        **after a build has placed it**: the label is read out of the project
        build's own symbol file. A
        palette the image has no room for yet is reported like every other
        part a gather skips -- the run opens wearing the cartridge's colours
        for this level, and the title says a build is owed.

        The other direction too: a level unticked since the last build still
        has its pointer row set in the image, so the row is patched back to
        zero -- three bytes -- rather than letting the run dress the level in
        a palette the document no longer holds.
        """
        if self._snapshot is None or self._rom is None or not self._addressable:
            return {}
        level = self._snapshot.level
        blob = self._level_palettes.get(level)
        symbols = self._build_symbols()
        found = (
            symbols.by_name.get(level_palettes.data_label(level))
            if symbols is not None
            else None
        )
        if blob is None:
            self._note_skipped(LEVEL_PALETTE, [])
            if found is None or symbols is None:
                return {}
            pointers = symbols.by_name.get(level_palettes.POINTERS_LABEL)
            if pointers is None:
                return {}
            at = self._addresses.offset(pointers.addr) + level * 3
            if at + 3 > len(self._rom):
                return {}
            row = self._rom[at : at + 3]
            return {at: b"\x00\x00\x00"} if row != b"\x00\x00\x00" else {}
        if found is None:
            self._note_skipped(LEVEL_PALETTE, [LEVEL_PALETTE])
            return {}
        at = self._addresses.offset(found.addr)
        if at + len(blob) > len(self._rom):
            self._note_skipped(LEVEL_PALETTE, [LEVEL_PALETTE])
            return {}
        self._note_skipped(LEVEL_PALETTE, [])
        return {at: blob} if self._rom[at : at + len(blob)] != blob else {}

    def _world_map_patch(self) -> dict[int, bytes]:
        """The world map as the editor holds it, over the image's own tables."""
        return cart_patches.world_map_patch(
            self._world_parts(),
            self._rom,
            self._addresses,
            self._status_message,
            lambda parts: self._note_skipped(WORLD_PARTS, parts),
        )

    # -- shutting the machinery down -------------------------------------------
    #
    # The emulator loader, and the unwind for a load that never arrived. It
    # owns a thread and a child process, so it is put away deliberately rather
    # than left to Qt's teardown -- as is the test window, in
    # :mod:`shiny_mushroom.ui.window.testing`.

    def _level_failed(self, message: str) -> None:
        # A world map capture reports failure on the same signal, and its
        # unwind is different: back out of the mode, whose canvas never got a
        # picture, rather than re-arming the level chrome.
        if self._awaiting_world:
            self._awaiting_world = False
            self.statusBar().clearMessage()
            self._unlock_after_load()
            self._leave_world(ask=False)
            self._alert("The world map could not be loaded.", detail=message)
            return
        self.statusBar().clearMessage()
        # A jump whose level never arrived is over. Held, it would fire on
        # whatever level was loaded next and scroll it to a record from a
        # different one.
        self._pending = None
        self._going_to = None
        # And so is a repoint's own reload: the table is written either way,
        # but the undo step belongs to the document that never came -- as
        # does a header accept waiting on a reopen.
        self._pending_repoint = None
        self._pending_graphics_edit = None
        # And the load that failed was not a refresh of anything any more --
        # including one waiting behind it, which would ask the same dead loader
        # the same question and raise a second dialog over this one.
        self._refreshing = False
        self._loading = False
        self._refresh_pending = False
        # Which is what puts the level bar back within reach.
        self.sync_level_rows()
        # Nor is anything still waiting on the probe behind a load that did not
        # arrive: the level it needed to run in never came up, and a lock held
        # for a reply that cannot come is the unusable state again.
        self._awaiting_player_art = False
        self._unlock_after_load()
        self._alert("The level could not be loaded.", detail=message)

    def _release_loader(self) -> None:
        """Shut the emulator down and forget it. Safe with none running.

        **Both directions, every signal.** A request already sent has a reply
        queued for this thread, and a queued reply is delivered whatever the
        loader is doing by then -- so a reply left connected across a close or
        an open lands a document the window has no cartridge for, or shows the
        outgoing cart's level as the incoming one's.
        """
        if self._loader is None:
            return
        loader, self._loader = self._loader, None
        self.level_requested.disconnect(loader.load)
        self.player_art_requested.disconnect(loader.player_art)
        self.overworld_requested.disconnect(loader.load_overworld)
        loader.loaded.disconnect(self._show_level)
        loader.player_art_ready.disconnect(self._hold_player_art)
        loader.failed.disconnect(self._level_failed)
        loader.overworld_loaded.disconnect(self._show_overworld)
        self._catalog.catalog_requested.disconnect(loader.probe_catalog)
        self._catalog.sprite_art_requested.disconnect(loader.probe_sprite_art)
        loader.catalog_probed.disconnect(self._catalog.probed)
        loader.sprite_art_ready.disconnect(self._catalog.sprite_art)
        loader.shutdown()
        loader.deleteLater()

    # -- view ---------------------------------------------------------------

    def zoom_reset(self) -> None:
        self.view.set_zoom(RESET_ZOOM)

    def set_grid(self, mode: GridMode) -> None:
        self.canvas.set_grid(mode)
        save_enum_setting(menus.GRID_KEY, mode)

    def set_theme(self, theme: Theme) -> None:
        apply_theme(theme)
        save_enum_setting(THEME_KEY, theme)

    # -- readouts -----------------------------------------------------------

    def _note_skipped(self, source: str, parts: list[str]) -> None:
        """Keep what a patch gatherer could not make the image carry.

        Recorded by source, because two of them report and they report in the
        same breath: the level document's background arm and the world map's
        tables both run while a test run's patches are gathered, and a
        gatherer with nothing to skip must clear its own reading rather than
        the other's.

        What comes of it is the test window's notice -- see
        :meth:`_show_play`, and it is the reason this is kept at all rather
        than only said in the status bar -- and, where there is a project to
        persist it in, the title's ``[build needed]``.
        """
        if parts:
            self._skipped[source] = list(parts)
        else:
            self._skipped.pop(source, None)
        if self._project is None:
            return
        before = self._project.build_needed
        self._project.note_build_needed(self._skipped_parts())
        if self._project.build_needed != before:
            self._update_title()
        self._sync_rebuild_action()

    def _skipped_parts(self) -> list[str]:
        """Every part the last gather could not carry, in a settled order."""
        return [
            part for source in sorted(self._skipped) for part in self._skipped[source]
        ]

    def _update_title(self) -> None:
        """The window's title: what is open, in what, and whether it is saved.

        The dot for unsaved work is the platform-neutral spelling of the same
        thing every editor says with a dot or an asterisk. It is only ever shown
        when there is a project, because without one there is nowhere for
        anything to be unsaved *to*.
        """
        if self._path is None:
            self.setWindowTitle(APP_NAME)
            return
        if self._mode is EditorMode.WORLD:
            what = "World Map - "
        else:
            what = f"{hexnum(self._level, 3)} - " if self._level is not None else ""
        project = f"{self._project.name} - " if self._project is not None else ""
        if self._project is not None and self._project.build_needed:
            project = f"{self._project.name} [build needed] - "
        mark = "* " if self.unsaved else ""
        self.setWindowTitle(f"{mark}{what}{project}{self._path.name} - {APP_NAME}")
        # A save is what most often changes the title, and a save is what most
        # often makes a build worth offering.
        self._sync_rebuild_action()

    def _show_position(self, pos: QPoint) -> None:
        # Blocks and hex, not pixels and decimal, because that is the form
        # every other reading of the level is in: an object record names a
        # block, a screen exit is indexed by screen, and both are written the
        # way the ROM writes them. A pixel coordinate would have to be divided
        # and converted before it could be compared with anything.
        column, row = pos.x() // BLOCK, pos.y() // BLOCK
        text = f"{hexnum(column)}, {hexnum(row)}"
        # A byte map has no screens in it, so there is no screen to name.
        if self._shape is not None:
            text += f"    screen {hexnum(self._shape.screen_of(column, row))}"
        self._position_label.setText(text)
        # Identify whatever is under the cursor even with the markers hidden:
        # the sprite is still there, and hiding the outline is about seeing the
        # tiles, not about pretending the level is empty. In pixels, not blocks,
        # so what answers is whatever the cursor is actually over - the same box
        # that is outlined.
        sprite = at(self._sprites, pos.x(), pos.y(), self._sprite_art)
        self._sprite_label.setText(sprite.describe() if sprite else "")

    def _clear_position(self) -> None:
        self._position_label.clear()
        self._sprite_label.clear()

    def _show_zoom(self, zoom: float) -> None:
        """Put the zoom in effect on the toolbar's box, and remember it.

        Driven by the canvas's signal rather than by the places a zoom is asked
        for, which is what makes this the one funnel: a zoom can arrive from the
        toolbar, the menu, Ctrl and the wheel, or a level load, and only the
        canvas sees all four. The toolbar's spin is therefore told rather than
        asked.

        Remembered per person, not per file: the zoom someone works at is a
        property of their eyes and their screen, and it should be there again
        next launch whatever they open.
        """
        self.zoom_bar.set_zoom(zoom)
        save_int_setting(ZOOM_KEY, as_percent(zoom))

    def show_shortcuts(self) -> None:
        """Help > Shortcuts: every key this window answers to, on one page.

        The guide is built from the menu bar as it stands when it is asked for,
        so it is read rather than remembered -- see
        :mod:`shiny_mushroom.ui.help_dialogs`.
        """
        ShortcutGuide(shortcut_sections(self), self).exec()

    def show_about(self) -> None:
        AboutDialog(self).exec()

    def _alert(self, message: str, *, title: str = APP_NAME, detail: str = "") -> None:
        """The window's one modal failure surface (see the module docstring)."""
        warn(self, message, title=title, detail=detail)

    # -- session ------------------------------------------------------------

    def _restore_geometry(self) -> None:
        """Put the window back where it was, or size it for the default view.

        The fallback is derived rather than picked: a full byte-map row at the
        canvas's default zoom, plus room for the chrome, so a first launch opens
        showing a whole row instead of a horizontal scrollbar.
        """
        # Where the docks and the toolbar sit is stored separately from the
        # window's own frame, and is restored whether or not the frame was:
        # a first run on a new screen still gets the panel arrangement back.
        # One arrangement per editing environment: `_apply_editing_chrome`
        # puts up the one this window is opening in, and the other two wait
        # for their environment to come round.
        for chrome, key in CHROME_STATE_KEYS.items():
            stored = load_bytes_setting(key)
            if stored is not None:
                self._layouts[chrome] = stored
        # A remembered arrangement can resurrect either mode's dock or
        # toolbars; what is visible follows the *mode*, not the last
        # session's layout.
        self._apply_editing_chrome()
        self.toolbars.reassert()
        stored = load_bytes_setting(GEOMETRY_KEY)
        if stored is None or not self.restoreGeometry(stored):
            self.resize(DEFAULT_WIDTH * DEFAULT_ZOOM + 80, 800)
        self._hold_floating_panels()

    def _hold_floating_panels(self) -> None:
        """Keep panels left undocked off screen until the window itself is up.

        A dock or toolbar left floating is a window in its own right, so Qt puts
        it on screen the moment the arrangement is restored -- which is here, in
        the constructor, before :meth:`require_setup` has asked anything. That
        would show a stray panel beside the project chooser, which is meant to
        be the only thing on screen while a project is being chosen.
        :meth:`showEvent` puts them back, at the geometry they were restored to.
        """
        if self.isVisible():
            return
        panels = (*self.findChildren(QDockWidget), *self.findChildren(QToolBar))
        # `isHidden` rather than `isVisible`: what is being held back is the
        # panel's own answer to whether it should be up, and that is what
        # `showEvent` has to hand back.
        self._held_panels = [
            panel for panel in panels if panel.isFloating() and not panel.isHidden()
        ]
        for panel in self._held_panels:
            panel.hide()

    def showEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().showEvent(event)
        for panel in self._held_panels:
            panel.show()
        self._held_panels = []

    def changeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().changeEvent(event)
        # Coming back from the editor the file was handed to is exactly when a
        # hand edit has just happened, and is the one moment worth asking at.
        if event.type() == QEvent.Type.ActivationChange and self.isActiveWindow():
            self._check_source_files()

    def _check_source_files(self) -> None:
        """Say so when a file the project holds of its own has moved on disk.

        Nothing watches the overlay: a hand edit is made in somebody else's
        editor, and the build's fingerprint is what actually decides whether
        asar runs again -- so this changes no outcome and only keeps the window
        honest about one. Reported as a part needing a build, because that is
        precisely what it is: the file is in the *next* cartridge, not the one
        on the canvas.

        A walk of the overlay and a stat or two a file -- what
        :func:`~shiny_mushroom.source_files.stamps` costs, classifying each
        file and reading none -- which is why this can run on every activation
        where :func:`~shiny_mushroom.build.needs_build`, eleven megabytes of
        fingerprint, could not. Not the cheaper
        :func:`~shiny_mushroom.source_files.overlay_stamps`, which is the
        wrong question here: it counts the files the editor writes for itself
        too, and those move whenever the editor saves.
        """
        project = self._project
        if project is None:
            return
        found = source_files.stamps(project)
        if found == self._source_stamps:
            return
        moved = sorted(
            str(relative)
            for relative, stamp in found.items()
            if self._source_stamps.get(relative) != stamp
        )
        self._source_stamps = found
        if not moved:
            # Only removals, which the dialog already accounted for.
            return
        self._note_skipped(SOURCE_FILES, moved)
        self.statusBar().showMessage(
            f"{'; '.join(moved)} changed on disk -- Project > Rebuild (F5) "
            f"puts {'them' if len(moved) > 1 else 'it'} in the cartridge.",
            8000,
        )

    def _check_disassembly(self) -> None:
        """Say so when the cartridge was built before the disassembly moved.

        The same reading :meth:`_check_source_files` makes, of the other half
        of what a build reads -- so both arrive as the one notion of stale, the
        title's ``[build needed]`` and a line in the status bar.

        It is worth making on its own because what a symbol file predating the
        source costs is invisible until something asks it for a label the
        rename took away: a strings save refused naming a pool bound, a world
        map priced against the stock run instead of the expansion bank it was
        moved to, a memory map drawing a bank as empty. Each of those is one
        rebuild away, and none of them says so.

        On opening a project, where the build has just had its chance: a walk
        of the whole source tree and a stat on each of its ``.asm``, which is
        nothing beside the merge that ran a moment ago and several times what
        the overlay's own check costs -- too much to repeat on every
        activation the way that one is.
        """
        project = self._project
        if project is None:
            return
        stale = stale_disassembly(project)
        self._note_skipped(DISASSEMBLY, [DISASSEMBLY] if stale else [])
        if not stale:
            return
        self.statusBar().showMessage(
            f"The disassembly has changed since {project.name}'s cartridge was "
            f"built ({_plural(len(stale), 'file')}, starting with {stale[0]}) "
            f"-- Project > Rebuild (F5) builds it against the source in hand.",
            8000,
        )

    def closeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        # Asked before anything is torn down, so cancelling leaves a window that
        # is still working rather than one whose emulator has already gone.
        if not self._may_discard():
            event.ignore()
            return
        # Asked and answered: a floating palette panel torn down with the
        # window must not ask its own question on the way out.
        self.palette_dock.set_close_guard(None)
        save_bytes_setting(GEOMETRY_KEY, self.saveGeometry())
        # The one on screen has not been kept since it was entered, so it is
        # taken here; the other two were kept as they were left.
        self._layouts[self._chrome] = self.saveState()
        for chrome, key in CHROME_STATE_KEYS.items():
            state = self._layouts.get(chrome)
            if state is not None:
                save_bytes_setting(key, state)
        # Before the window goes, not after: each of these owns a thread and a
        # child process, and neither is reachable once this object is gone.
        self._close_play()
        self._release_loader()
        super().closeEvent(event)
