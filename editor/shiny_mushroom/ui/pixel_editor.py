"""The pixel editor: a window that paints a :class:`~shiny_mushroom.pixel_edit.Surface`.

Opened over a surface by whoever owns the picture -- the Level Graphics
dialog's Level Tiles page today -- with a ``save`` that writes the surface
wherever its tiles live. The window knows nothing about files: it holds the
surface as a document under :class:`~shiny_mushroom.edit.History`, turns
gestures into new surfaces, and hands the one that stands to ``save`` on
Ctrl+S or on the way out. That is what lets the same window edit anything
that is a surface of tiles.

**Every stroke is one step.** A gesture works on a copy of the surface it
began over -- the pencil paints into it sample by sample, a shape tool
redraws it from the anchor -- and the canvas shows the working copy live;
the release commits it, or nothing if it changed nothing. A fill is a click
and a commit. Undo walks the surfaces.

**A selection is a mask and a handle.** While a marquee is up every tool
paints only inside it, and the fill's walk stops at its edge. Pressing
inside it with the Select tool lifts its pixels into the air: the source
shows blank and the pixels follow the pointer, and they come down -- one
commit, the hole and the landing together -- when the selection is dropped
or replaced, when a tool paints, and before a save. Nothing is written while
they hover, and the history carries them anyway: a drag of the float, a
paste, and a landing are each a step whose mark is the selection as it
stood -- marquee, or pixels in the air -- so an undo of a landing lifts the
same pixels back up, still owing the same hole, and an undo of a drag puts
them back where they hovered before (:class:`_Selection`,
:meth:`~shiny_mushroom.edit.History.note`).

**Right-click is the eyedropper on every tool**, as it is on every canvas
here ([right-click.md](../../../docs/editor/right-click.md)): it takes the
colour under the pointer and its row, and the swatch grid follows it.

**The colours are part of the picture.** A double-click on a swatch puts the
colour picker up, the surface is recoloured live as the picker moves, and
OK is one step like a stroke: the palette rides the surface
(:meth:`~shiny_mushroom.pixel_edit.Surface.with_colour`), so it is undone,
saved and discarded with the pixels. Which colours may be changed is the
owner's to say (``colour_editable``); a save hands the owner the surface,
palette included.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass

from PySide6.QtCore import QMimeData, QRect, QSize, Qt, Signal
from PySide6.QtGui import (
    QAction,
    QCloseEvent,
    QColor,
    QGuiApplication,
    QImage,
    QKeyEvent,
    QKeySequence,
)
from PySide6.QtWidgets import (
    QColorDialog,
    QDialog,
    QHBoxLayout,
    QLabel,
    QMenuBar,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import pixel_edit
from shiny_mushroom.edit import History
from shiny_mushroom.graphics import GraphicsError, redmean, snes_value
from shiny_mushroom.level import snes_color
from shiny_mushroom.pixel_edit import Region, Surface
from shiny_mushroom.ui.dialogs import Choice, ChoiceBox, ask_to_save, warn
from shiny_mushroom.ui.palette_grid import Swatch, SwatchGrid
from shiny_mushroom.ui.pixel_canvas import GridMode, PixelCanvas
from shiny_mushroom.ui.pixel_tools import (
    SPEC_BY_TOOL,
    TOOL_BY_KEY,
    Gesture,
    Tool,
    ToolRail,
)
from shiny_mushroom.ui.render import paletted_to_image
from shiny_mushroom.ui.settings import (
    load_enum_setting,
    load_int_setting,
    save_enum_setting,
    save_int_setting,
)
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tips import wrap_tip
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker
from smw_tools.graphics import TILE_SIDE

TITLE = "Mushroom Paint"

#: The clipboard's own spelling of a region: ``width, height`` as two
#: little-endian words, then the indices. Beside it goes a picture, so any
#: other program receives one; a paste back here reads the indices exactly.
PIXELS_MIME = "application/x-shiny-mushroom-pixels"

#: The zooms on offer, and the one the editor opens at: a pixel is the unit
#: here, so the ladder goes further than a sheet's.
ZOOMS: tuple[int, ...] = (1, 2, 3, 4, 6, 8, 12, 16)
DEFAULT_ZOOM = 4

TOOL_KEY = "pixel_editor/tool"
ZOOM_KEY = "pixel_editor/zoom"
GRID_KEY = "pixel_editor/grid"

#: What the swatch grid is, said once above it.
PALETTE_HINT = (
    "Each cell draws through its own row; the pen is a colour index. "
    "Double-click a swatch to change the colour."
)

#: Why a swatch cannot be recoloured here, in its tip.
NOT_RECOLOURABLE = "not a colour this picture can change"

#: The grid's three states, in the order G cycles them, and their labels.
GRID_LABELS = {
    GridMode.NONE: "None",
    GridMode.TILES: "Tiles",
    GridMode.PIXELS: "Pixels",
}

Describe = Callable[[int], str]
Save = Callable[[Surface], str]
ColourEditable = Callable[[int, int], bool]


@dataclass(frozen=True)
class _Float:
    """Pixels in the air: the region, where its top-left hovers, and the
    hole it owes -- the rectangle a move lifted it from, or ``None`` for a
    paste, which removed nothing."""

    region: Region
    x: int
    y: int
    source: QRect | None

    @property
    def rect(self) -> QRect:
        return QRect(self.x, self.y, self.region.width, self.region.height)


@dataclass(frozen=True)
class _Selection:
    """The selection as it stands at one moment: a marquee, or pixels in the
    air, or neither -- what a step's mark carries, so a walk of the history
    puts back both the surface and what was held over it."""

    marquee: QRect | None = None
    floating: _Float | None = None


class PixelEditor(QDialog):
    """Paint a surface. Construct with the surface and a ``save`` that
    writes one and hands back a note for the status line -- or raises a
    :class:`GraphicsError`, worded for a message box."""

    #: A save went through, with the note ``save`` handed back.
    saved = Signal(str)

    def __init__(
        self,
        surface: Surface,
        save: Save,
        *,
        title: str = TITLE,
        describe: Describe | None = None,
        colour_editable: ColourEditable | None = None,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        # The ``[*]`` is where Qt shows the unsaved mark.
        self.setWindowTitle(f"{title}[*]")
        self.setWindowFlag(Qt.WindowType.WindowMaximizeButtonHint, True)
        self._save = save
        self._describe = describe
        #: Which palette entries a double-click may recolour; every one,
        #: for an owner that does not say.
        self._colour_editable = colour_editable or (lambda row, index: True)
        #: What the canvas's marks were last built from, so a repaint on
        #: every pointer move rebuilds neither the swatches nor the hatch.
        self._shown_palette: object = None
        self._shown_cells: object = None
        self._history: History[Surface] = History(surface)
        self._tool = load_enum_setting(TOOL_KEY, Tool.PENCIL)
        self._pen = 1
        self._pen_row = 0
        #: The selection, in image pixels, and the corner it grew from.
        self._marquee: QRect | None = None
        self._anchor: tuple[int, int] = (0, 0)
        #: A stroke under way: the surface it began over and the working copy.
        self._stroke: Surface | None = None
        self._stroke_base: Surface | None = None
        self._last: tuple[int, int] = (0, 0)
        #: Pixels in the air, and where in them the pointer took hold.
        self._float: _Float | None = None
        self._grab: tuple[int, int] = (0, 0)
        #: The selection as it stood when the press on it began -- what the
        #: drag's step is undone back to.
        self._before = _Selection()

        self._build()
        self._pick_first_pen()
        self._show()
        self._sync_actions()

    # -- construction -----------------------------------------------------------

    def _build(self) -> None:
        layout = QVBoxLayout(self)
        layout.setMenuBar(self._build_menus())

        top = QHBoxLayout()
        zoom_label = QLabel("&Zoom:")
        top.addWidget(zoom_label)
        self._zoom = ZoomPicker(ZOOMS, load_int_setting(ZOOM_KEY, DEFAULT_ZOOM))
        zoom_label.setBuddy(self._zoom)
        self._zoom.zoom_changed.connect(lambda z: save_int_setting(ZOOM_KEY, z))
        top.addWidget(self._zoom)
        grid_label = QLabel("&Grid:")
        top.addWidget(grid_label)
        self._grid = ChoiceBox()
        for mode in GridMode:
            self._grid.addItem(GRID_LABELS[mode], mode)
        grid_label.setBuddy(self._grid)
        self._grid.setToolTip(
            "What is drawn over the picture: nothing, the tiles, or every pixel (G)."
        )
        self._grid.setCurrentIndex(
            list(GridMode).index(load_enum_setting(GRID_KEY, GridMode.PIXELS))
        )
        self._grid.currentIndexChanged.connect(lambda _i: self._grid_picked())
        top.addWidget(self._grid)
        top.addStretch(1)
        self._save_button = QPushButton("&Save")
        self._save_button.setToolTip(
            wrap_tip("Write the picture into its tiles (Ctrl+S).")
        )
        self._save_button.clicked.connect(self.save)
        top.addWidget(self._save_button)
        close = QPushButton("&Close")
        close.clicked.connect(self.close)
        top.addWidget(close)
        layout.addLayout(top)

        middle = QHBoxLayout()
        self._rail = ToolRail()
        self._rail.set_tool(self._tool)
        self._rail.tool_selected.connect(self._tool_picked)
        rail_column = QVBoxLayout()
        rail_column.addWidget(self._rail)
        rail_column.addStretch(1)
        middle.addLayout(rail_column)

        self._canvas = PixelCanvas(self._zoom.zoom)
        self._canvas.set_grid(self.grid)
        self._canvas.pixel_pressed.connect(self._pressed)
        self._canvas.pixel_moved.connect(self._moved)
        self._canvas.pixel_released.connect(self._released)
        self._canvas.pixel_double_clicked.connect(self._double_clicked)
        self._canvas.hovered.connect(self._hovered)
        self._area = ZoomedArea(self._canvas, self._zoom)
        middle.addWidget(self._area, 1)

        side = QVBoxLayout()
        hint = QLabel(PALETTE_HINT)
        hint.setWordWrap(True)
        hint.setMaximumWidth(16 * 20 + 22)
        style_note(hint)
        side.addWidget(hint)
        self._swatches = SwatchGrid(pixel_edit.ROW_COLOURS, numbered=True)
        self._swatches.picked.connect(self._swatch_picked)
        self._swatches.activated.connect(self._swatch_activated)
        side.addWidget(self._swatches)
        side.addStretch(1)
        middle.addLayout(side)
        layout.addLayout(middle, 1)

        self._note = QLabel("")
        self._note.setWordWrap(True)
        style_note(self._note)
        layout.addWidget(self._note)
        self.resize(960, 640)

    def _build_menus(self) -> QMenuBar:
        bar = QMenuBar(self)
        bar.setNativeMenuBar(False)
        file_menu = bar.addMenu("&File")
        self._save_action = self._action(
            file_menu, "&Save", self.save, QKeySequence.StandardKey.Save
        )
        self._action(file_menu, "&Close", self.close, QKeySequence.StandardKey.Close)

        edit = bar.addMenu("&Edit")
        self._undo = self._action(
            edit, "&Undo", self.undo, QKeySequence.StandardKey.Undo
        )
        self._redo = self._action(edit, "&Redo", self.redo, "Ctrl+Y")
        edit.addSeparator()
        self._cut = self._action(edit, "Cu&t", self.cut, QKeySequence.StandardKey.Cut)
        self._copy = self._action(
            edit, "&Copy", self.copy, QKeySequence.StandardKey.Copy
        )
        self._paste = self._action(
            edit, "&Paste", self.paste, QKeySequence.StandardKey.Paste
        )
        self._delete = self._action(
            edit, "&Delete", self.delete, QKeySequence.StandardKey.Delete
        )
        self._action(
            edit, "Select &All", self.select_all, QKeySequence.StandardKey.SelectAll
        )
        edit.addSeparator()
        self._flip_h = self._action(edit, "Flip &Horizontal", self.flip_horizontal, "H")
        self._flip_v = self._action(edit, "Flip &Vertical", self.flip_vertical, "V")
        self._rotate_cw = self._action(edit, "Rotate Ri&ght", self.rotate_right, "C")
        self._rotate_ccw = self._action(edit, "Rotate &Left", self.rotate_left, "X")

        view = bar.addMenu("&View")
        # Ctrl+= rather than the platform's Ctrl++: it is the key the plus is
        # printed on, and asking for the shift that changes nothing is not a
        # rule anyone would guess.
        self._action(view, "Zoom &In", lambda: self._area.zoom_by(1), "Ctrl+=")
        self._action(
            view,
            "Zoom &Out",
            lambda: self._area.zoom_by(-1),
            QKeySequence.StandardKey.ZoomOut,
        )
        self._grid_action = self._action(view, "&Grid", self.cycle_grid, "G")
        return bar

    def _action(
        self,
        menu,
        text: str,
        slot: Callable[[], object],
        keys,  # noqa: ANN001
    ) -> QAction:
        action = QAction(text, self)
        action.setShortcut(QKeySequence(keys))
        action.setShortcutContext(Qt.ShortcutContext.WindowShortcut)
        action.triggered.connect(lambda _checked=False: slot())
        menu.addAction(action)
        return action

    # -- what stands -----------------------------------------------------------------

    @property
    def surface(self) -> Surface:
        """The picture as it stands -- floating pixels not yet in it."""
        return self._history.level

    @property
    def edited(self) -> bool:
        """Whether anything is unsaved: a step since the save, or pixels in
        the air that will land as one."""
        return self._history.edited or self._float is not None

    @property
    def tool(self) -> Tool:
        return self._tool

    @property
    def pen(self) -> int:
        """The index the pen writes."""
        return self._pen

    @property
    def marquee(self) -> QRect | None:
        """The selection, in image pixels: the floating pixels' rectangle
        while any are up."""
        return self._float.rect if self._float is not None else self._marquee

    @property
    def floating(self) -> Region | None:
        return None if self._float is None else self._float.region

    @property
    def canvas(self) -> PixelCanvas:
        return self._canvas

    @property
    def swatches(self) -> SwatchGrid:
        return self._swatches

    @property
    def note(self) -> str:
        return self._note.text()

    def set_surface(self, surface: Surface) -> None:
        """Take ``surface`` as what is now on disk: the picture the owner
        re-read after a save. The history is dropped with the old one."""
        self._history = History(surface)
        self._float = None
        self._marquee = None
        self._show()
        self._sync_actions()

    def _state(self) -> _Selection:
        """The selection as it stands, for a step's mark."""
        return _Selection(
            None if self._marquee is None else QRect(self._marquee), self._float
        )

    def _restore(self, state: object) -> None:
        """Put a step's mark back: the marquee, or the pixels in the air."""
        if isinstance(state, _Selection):
            self._marquee = None if state.marquee is None else QRect(state.marquee)
            self._float = state.floating
        else:
            self._marquee = None
            self._float = None

    # -- showing ---------------------------------------------------------------------

    def _shown(self, surface: Surface | None = None) -> Surface:
        """The surface as the canvas shows it: what stands -- or ``surface``
        in its place -- with a float's hole blanked and its pixels laid over,
        the very picture landing would write."""
        if surface is None:
            surface = self.surface
        held = self._float
        if held is None:
            return surface
        if held.source is not None:
            s = held.source
            surface = surface.cleared(s.x(), s.y(), s.width(), s.height())
        return surface.blitted(held.region, held.x, held.y)

    def _show(self, surface: Surface | None = None) -> None:
        if surface is None:
            surface = self._shown()
        self._canvas.set_image(
            paletted_to_image(
                surface.paletted(),
                surface.width,
                surface.height,
                surface.colour_table(),
            )
        )
        if surface.cells is not self._shown_cells:
            self._shown_cells = surface.cells
            self._canvas.set_locked(
                [
                    QRect(
                        (n % surface.columns) * TILE_SIDE,
                        (n // surface.columns) * TILE_SIDE,
                        TILE_SIDE,
                        TILE_SIDE,
                    )
                    for n, cell in enumerate(surface.cells)
                    if not cell.editable
                ]
            )
        self._canvas.set_marquee(self.marquee)
        if surface.palette is not self._shown_palette:
            self._shown_palette = surface.palette
            self._swatches.set_swatches(
                [
                    Swatch(snes_value(colour), n, self._swatch_tip(n))
                    for n, colour in enumerate(surface.colour_table())
                ]
            )
        self._sync_preview()

    def _swatch_tip(self, n: int) -> str:
        row, index = divmod(n, pixel_edit.ROW_COLOURS)
        tip = f"Row {row}, colour {index}"
        if not self._colour_editable(row, index):
            tip += f" ({NOT_RECOLOURABLE})"
        return tip

    def _sync_actions(self) -> None:
        self._undo.setEnabled(self._history.can_undo)
        self._redo.setEnabled(self._history.can_redo)
        self._undo.setText("&Undo" if not self._history.can_undo else "&Undo Stroke")
        held = self.marquee is not None
        for action in (self._cut, self._copy, self._delete, self._flip_h, self._flip_v):
            action.setEnabled(held)
        square = held and self.marquee.width() == self.marquee.height()
        self._rotate_cw.setEnabled(square)
        self._rotate_ccw.setEnabled(square)
        self._save_action.setEnabled(self.edited)
        self._save_button.setEnabled(self.edited)
        self.setWindowModified(self.edited)

    @property
    def grid(self) -> GridMode:
        return GridMode(self._grid.currentData())

    def set_grid(self, mode: GridMode) -> None:
        self._grid.setCurrentIndex(list(GridMode).index(mode))

    def cycle_grid(self) -> None:
        """G: none, tiles, pixels, and round again."""
        self.set_grid(self.grid.next())

    def _grid_picked(self) -> None:
        save_enum_setting(GRID_KEY, self.grid)
        self._canvas.set_grid(self.grid)

    # -- the pen ------------------------------------------------------------------

    def _pick_first_pen(self) -> None:
        """Open with the pen on colour 1 of the first paintable cell's row,
        so the first stroke lands in colours the picture already uses."""
        for cell in self.surface.cells:
            if cell.editable:
                self._pen_row = cell.row
                break
        self._pen = 1

    def _swatch_picked(self, n: int) -> None:
        if n < 0:
            return
        self._pen_row, self._pen = divmod(n, pixel_edit.ROW_COLOURS)
        self._sync_preview()

    def _select_swatch(self) -> None:
        self._swatches.select(self._pen_row * pixel_edit.ROW_COLOURS + self._pen)

    # -- the colours ------------------------------------------------------------

    def _swatch_activated(self, n: int) -> None:
        """Double-click, or Return, on a swatch: the colour picker over it,
        the picture following the picker live, and OK one step."""
        row, index = divmod(n, pixel_edit.ROW_COLOURS)
        self.recolour(row, index)

    def recolour(self, row: int, index: int) -> None:
        if not self._colour_editable(row, index):
            self._say(f"Row {row}, colour {index} is {NOT_RECOLOURABLE}.")
            return
        self._land()
        before = self.surface
        dialog = QColorDialog(QColor(*before.colour(row, index)), self)
        dialog.setOption(QColorDialog.ColorDialogOption.ShowAlphaChannel, False)
        dialog.currentColorChanged.connect(
            lambda colour: self._show(
                self._shown(before.with_colour(row, index, _stored(colour)))
            )
        )
        try:
            if dialog.exec():
                if self._commit(
                    before.with_colour(row, index, _stored(dialog.selectedColor()))
                ):
                    self._say(f"Row {row}, colour {index} changed.")
            else:
                self._show()
        finally:
            dialog.deleteLater()

    def set_pen(self, index: int, row: int | None = None) -> None:
        """Put the pen on ``index``, shown under ``row`` where one is given."""
        self._pen = index
        if row is not None:
            self._pen_row = row
        self._select_swatch()
        self._sync_preview()

    def _sync_preview(self) -> None:
        """Arm the canvas's one-pixel preview for a tool that paints."""
        if SPEC_BY_TOOL[self._tool].gesture in (
            Gesture.FREEHAND,
            Gesture.SHAPE,
            Gesture.FILL,
        ):
            colour = self.surface.colour(self._pen_row, self._pen)
            self._canvas.set_preview(QColor(*colour))
        else:
            self._canvas.set_preview(None)

    def _tool_picked(self, tool: Tool) -> None:
        self._tool = tool
        save_enum_setting(TOOL_KEY, tool)
        self._rail.set_tool(tool)
        self._sync_preview()

    def set_tool(self, tool: Tool) -> None:
        self._tool_picked(tool)

    # -- the mouse --------------------------------------------------------------------

    def _pressed(self, x: int, y: int, button: Qt.MouseButton) -> None:
        spec = SPEC_BY_TOOL[self._tool]
        if button is Qt.MouseButton.RightButton or spec.gesture is Gesture.SAMPLE:
            self._eyedrop(x, y)
            return
        if button is not Qt.MouseButton.LeftButton:
            return
        if spec.gesture is Gesture.MARQUEE:
            self._marquee_press(x, y)
            return
        # Painting under pixels in the air would paint beneath them: they
        # come down first, and the selection they land on stays as the mask.
        self._land(keep_selection=True)
        if spec.gesture is Gesture.FILL:
            self._fill(x, y)
        else:
            self._begin_stroke(x, y)

    def _moved(self, x: int, y: int) -> None:
        if self._stroke is not None:
            self._paint_stroke(x, y)
        elif self._float is not None:
            gx, gy = self._grab
            held = self._float
            self._float = _Float(held.region, x - gx, y - gy, held.source)
            self._show()
        elif self._marquee is not None and self._tool is Tool.SELECT:
            self._marquee_drag(x, y)

    def _released(self, x: int, y: int) -> None:
        if self._stroke is not None:
            self._end_stroke(x, y)
        elif self._float is not None:
            self._park_float()
        elif self._marquee is not None and self._tool is Tool.SELECT:
            self._marquee_release()

    def _double_clicked(self, x: int, y: int) -> None:
        """Double-click with Select: take the whole tile the pixel is in."""
        if self._tool is not Tool.SELECT:
            return
        self._land()
        surface = self.surface
        rect = QRect(
            (x // TILE_SIDE) * TILE_SIDE,
            (y // TILE_SIDE) * TILE_SIDE,
            TILE_SIDE,
            TILE_SIDE,
        ).intersected(QRect(0, 0, surface.width, surface.height))
        self._marquee = rect
        self._canvas.set_marquee(rect)
        self._sync_actions()
        self._say("Selected the tile.")

    def _hovered(self, x: int, y: int) -> None:
        surface = self.surface
        if x < 0 or not surface.contains(x, y):
            self._say("")
            return
        n = surface.cell_index(x, y)
        cell = surface.cells[n]
        where = self._describe(n) if self._describe is not None else f"cell {n}"
        held = f"({x}, {y}) colour {surface.get(x, y)} of row {cell.row}"
        shown = f"{where}: {held}" if where else held
        if not cell.editable:
            shown += " (not a file's; takes no paint)"
        elif cell.allowed is not None and self._pen not in cell.allowed:
            lands = surface.landing_index(cell, self._pen)
            shown += f"; the pen lands as colour {lands} here"
        self._say(shown)

    def _say(self, text: str) -> None:
        self._note.setText(text)

    # -- strokes -----------------------------------------------------------------------

    def _mask(self, pixels: list[pixel_edit.Coord]) -> list[pixel_edit.Coord]:
        """``pixels`` inside the selection, where there is one: the one rule
        every tool's paint goes through."""
        mask = self._marquee
        if mask is None:
            return pixels
        return [(x, y) for x, y in pixels if mask.contains(x, y)]

    def _begin_stroke(self, x: int, y: int) -> None:
        self._stroke_base = self.surface
        self._stroke = self._stroke_base
        self._anchor = self._last = (x, y)
        self._paint_stroke(x, y)

    def _paint_stroke(self, x: int, y: int) -> None:
        spec = SPEC_BY_TOOL[self._tool]
        assert spec.rasterize is not None and self._stroke is not None
        assert self._stroke_base is not None
        if spec.gesture is Gesture.FREEHAND:
            lx, ly = self._last
            self._stroke = self._stroke.filled(
                self._mask(spec.rasterize(lx, ly, x, y)), self._pen
            )
        else:
            ax, ay = self._anchor
            self._stroke = self._stroke_base.filled(
                self._mask(spec.rasterize(ax, ay, x, y)), self._pen
            )
        self._last = (x, y)
        self._show(self._stroke)

    def _end_stroke(self, x: int, y: int) -> None:
        self._paint_stroke(x, y)
        stroke = self._stroke
        self._stroke = self._stroke_base = None
        assert stroke is not None
        self._commit(stroke)

    def _fill(self, x: int, y: int) -> None:
        surface = self.surface
        bounds = None
        if self._marquee is not None:
            m = self._marquee
            bounds = (m.left(), m.top(), m.right(), m.bottom())
        self._commit(
            surface.filled(pixel_edit.flood_fill(surface, x, y, bounds), self._pen)
        )

    def _commit(self, surface: Surface, before: _Selection | None = None) -> bool:
        """Make ``surface`` the present, remembering the selection it was
        made under -- ``before``, else the one that stands -- so an undo puts
        both back."""
        changed = self._history.commit(
            surface, self._state() if before is None else before
        )
        self._show()
        self._sync_actions()
        return changed

    def _eyedrop(self, x: int, y: int) -> None:
        surface = self._shown()
        if not surface.contains(x, y):
            return
        self.set_pen(surface.get(x, y), surface.cell_at(x, y).row)
        self._say(f"Picked colour {self._pen} of row {self._pen_row}.")

    # -- the selection, and pixels in the air -----------------------------------------

    def _marquee_press(self, x: int, y: int) -> None:
        held = self.marquee
        if held is not None and held.contains(x, y):
            # What the drag that follows is undone back to: a marquee, when
            # this press lifts the pixels; the float where it hovered, when
            # it takes hold of one already up.
            self._before = self._state()
            if self._float is None:
                self._lift()
            assert self._float is not None
            self._grab = (x - self._float.x, y - self._float.y)
            return
        self._land()
        self._anchor = (x, y)
        self._marquee = QRect(x, y, 1, 1)
        self._canvas.set_marquee(self._marquee)

    def _marquee_drag(self, x: int, y: int) -> None:
        ax, ay = self._anchor
        # Asked of the keyboard rather than of the last event: the event
        # record is whatever the last key event in this process said, and a
        # shift released over another window leaves it saying shift.
        if QGuiApplication.queryKeyboardModifiers() & Qt.KeyboardModifier.ShiftModifier:
            side = max(abs(x - ax), abs(y - ay))
            x = ax + (side if x >= ax else -side)
            y = ay + (side if y >= ay else -side)
            surface = self.surface
            x = max(0, min(x, surface.width - 1))
            y = max(0, min(y, surface.height - 1))
        self._marquee = QRect(min(ax, x), min(ay, y), abs(x - ax) + 1, abs(y - ay) + 1)
        self._canvas.set_marquee(self._marquee)

    def _marquee_release(self) -> None:
        """A bare click -- a selection that never grew -- is a deselect."""
        if self._marquee is not None and self._marquee.size() == QSize(1, 1):
            self._marquee = None
            self._canvas.set_marquee(None)
        self._sync_actions()

    def _lift(self) -> None:
        """Pick the selection's pixels up. Nothing is written until they land."""
        rect = self._marquee
        if rect is None:
            return
        region = self.surface.region(rect.x(), rect.y(), rect.width(), rect.height())
        self._float = _Float(region, rect.x(), rect.y(), QRect(rect))
        self._marquee = None
        self._show()

    def _park_float(self) -> None:
        """The drag ends with the pixels still in the air: nothing is written,
        and the drag is a step of its own, so an undo puts the float back
        where it hovered before -- or, for the press that lifted it, back
        down as the marquee it was lifted from. A press that never moved the
        pixels is no step: they are where they were, lifted or not."""
        held = self._float
        assert held is not None
        before = self._before
        was = before.floating.rect if before.floating is not None else before.marquee
        if was != held.rect:
            self._history.note(before)
        self._sync_actions()

    def _land(self, *, keep_selection: bool = False) -> None:
        """Set floating pixels down where they hover: the hole a move owes and
        the pixels over whatever is under them, as one step whose mark is the
        float itself -- so undoing a landing lifts the same pixels back up,
        still owing the same hole. A landing that changes no pixel is still
        the step that took them out of the air."""
        held = self._float
        if held is None:
            return
        before = self._state()
        landed = self._shown()
        self._float = None
        self._marquee = QRect(held.rect) if keep_selection else None
        if not self._history.commit(landed, before):
            self._history.note(before)
        self._show()
        self._sync_actions()

    def clear_selection(self) -> None:
        """Escape: land a float, else drop the selection."""
        if self._float is not None:
            self._land()
            return
        self._marquee = None
        self._canvas.set_marquee(None)
        self._sync_actions()

    def select_all(self) -> None:
        self._land()
        surface = self.surface
        self._marquee = QRect(0, 0, surface.width, surface.height)
        self._canvas.set_marquee(self._marquee)
        self._sync_actions()

    def select(self, rect: QRect | None) -> None:
        """Select ``rect`` -- image pixels -- outright."""
        self._land()
        self._marquee = None if rect is None else QRect(rect)
        self._canvas.set_marquee(self._marquee)
        self._sync_actions()

    # -- the clipboard ---------------------------------------------------------------

    def _selected_region(self) -> Region | None:
        if self._float is not None:
            return self._float.region
        rect = self._marquee
        if rect is None:
            return None
        return self.surface.region(rect.x(), rect.y(), rect.width(), rect.height())

    def copy(self) -> None:
        region = self._selected_region()
        if region is None:
            return
        rect = self.marquee
        assert rect is not None
        shown = self._shown()
        picture = paletted_to_image(
            shown.paletted(), shown.width, shown.height, shown.colour_table()
        ).copy(rect)
        mime = QMimeData()
        mime.setData(
            PIXELS_MIME,
            region.width.to_bytes(2, "little")
            + region.height.to_bytes(2, "little")
            + region.pixels,
        )
        mime.setImageData(picture.convertToFormat(QImage.Format.Format_RGB32))
        QGuiApplication.clipboard().setMimeData(mime)
        self._say(f"Copied {region.width}x{region.height} pixels.")

    def cut(self) -> None:
        if self.marquee is None:
            return
        self.copy()
        self.delete()

    def delete(self) -> None:
        """Blank the selection. Floating pixels are simply never set down;
        only the hole a move owed is written -- and the step carries the
        float, so an undo puts the deleted pixels back in the air."""
        held = self._float
        if held is not None:
            before = self._state()
            self._float = None
            self._marquee = None
            written = False
            if held.source is not None:
                s = held.source
                written = self._history.commit(
                    self.surface.cleared(s.x(), s.y(), s.width(), s.height()), before
                )
            if not written:
                self._history.note(before)
            self._show()
            self._sync_actions()
            return
        rect = self._marquee
        if rect is None:
            return
        self._marquee = None
        self._commit(
            self.surface.cleared(rect.x(), rect.y(), rect.width(), rect.height())
        )

    def paste(self) -> None:
        """Bring the clipboard in as floating pixels, with the Select tool
        armed to drag them: into the selection where one is up of the
        pasted picture's own size, which is a place the user has already
        chosen, and centred on the view otherwise."""
        region = self._clipboard_region()
        if region is None:
            self._say("The clipboard holds no picture to paste.")
            return
        held = self.marquee
        self._land()
        before = self._state()
        surface = self.surface
        if held is not None and held.size() == QSize(region.width, region.height):
            x, y = held.x(), held.y()
        else:
            centre = self._area.viewport().rect().center()
            cx = (self._area.horizontalScrollBar().value() + centre.x()) // (
                self._zoom.zoom
            )
            cy = (self._area.verticalScrollBar().value() + centre.y()) // (
                self._zoom.zoom
            )
            x = max(0, min(cx - region.width // 2, surface.width - region.width))
            y = max(0, min(cy - region.height // 2, surface.height - region.height))
        self._float = _Float(region, x, y, None)
        self._marquee = None
        # A paste is a step: an undo takes the pixels back out of the air.
        self._history.note(before)
        self._tool_picked(Tool.SELECT)
        self._show()
        self._sync_actions()
        self._say("Pasted: drag the pixels into place; they land when deselected.")

    def _clipboard_region(self) -> Region | None:
        mime = QGuiApplication.clipboard().mimeData()
        if mime is None:
            return None
        if mime.hasFormat(PIXELS_MIME):
            data = bytes(mime.data(PIXELS_MIME))
            if len(data) >= 4:
                width = int.from_bytes(data[0:2], "little")
                height = int.from_bytes(data[2:4], "little")
                if len(data) == 4 + width * height:
                    return Region(width, height, data[4:])
        image = QGuiApplication.clipboard().image()
        if image.isNull():
            return None
        return self._matched(image)

    def _matched(self, image: QImage) -> Region:
        """Any other program's picture as indices: each pixel the nearest
        colour of the row the cell under its place would draw it through,
        a transparent one colour 0."""
        rgba = image.convertToFormat(QImage.Format.Format_RGBA8888)
        width, height = rgba.width(), rgba.height()
        surface = self.surface
        raw = bytes(rgba.constBits())
        stride = rgba.bytesPerLine()
        out = bytearray(width * height)
        nearest: dict[tuple[int, tuple[int, int, int]], int] = {}
        for y in range(height):
            for x in range(width):
                at = y * stride + x * 4
                r, g, b, a = raw[at], raw[at + 1], raw[at + 2], raw[at + 3]
                if a == 0:
                    continue
                row = (
                    surface.cell_at(x, y).row
                    if surface.contains(x, y)
                    else self._pen_row
                )
                key = (row, (r, g, b))
                index = nearest.get(key)
                if index is None:
                    colours = surface.palette[row]
                    index = nearest[key] = min(
                        range(len(colours)),
                        key=lambda i: redmean((r, g, b), colours[i]),
                    )
                out[y * width + x] = index
        return Region(width, height, bytes(out))

    # -- transforms --------------------------------------------------------------------

    def _transform(self, op: Callable[[Region], Region], said: str) -> None:
        held = self._float
        if held is not None:
            self._history.note(self._state())
            self._float = _Float(op(held.region), held.x, held.y, held.source)
            self._show()
            self._sync_actions()
            self._say(f"{said} the floating pixels.")
            return
        rect = self._marquee
        if rect is None:
            return
        region = op(
            self.surface.region(rect.x(), rect.y(), rect.width(), rect.height())
        )
        if self._commit(self.surface.blitted(region, rect.x(), rect.y())):
            self._say(f"{said} the selection.")

    def flip_horizontal(self) -> None:
        self._transform(Region.flipped_h, "Flipped")

    def flip_vertical(self) -> None:
        self._transform(Region.flipped_v, "Flipped")

    def rotate_right(self) -> None:
        if self._rotate_cw.isEnabled():
            self._transform(Region.rotated_cw, "Rotated")

    def rotate_left(self) -> None:
        if self._rotate_ccw.isEnabled():
            self._transform(Region.rotated_ccw, "Rotated")

    # -- history ---------------------------------------------------------------

    def undo(self) -> None:
        self._walk(back=True)

    def redo(self) -> None:
        self._walk(back=False)

    def _walk(self, *, back: bool) -> None:
        """Step the history, carrying the selection both ways: the step being
        stepped off records what stands now, for the walk back, and what it
        restores is put back -- a float included, since one writes nothing
        until it lands and the pixels are still on the surface it hovers."""
        mark = self._state()
        walked = self._history.undo(mark) if back else self._history.redo(mark)
        if walked:
            self._restore(self._history.mark)
        self._show()
        self._sync_actions()

    # -- saving, and leaving ----------------------------------------------------------

    def save(self) -> bool:
        """Land any float and write the picture. ``True`` when it went."""
        self._land()
        try:
            note = self._save(self.surface)
        except GraphicsError as error:
            self._warn(f"The picture could not be saved: {error}")
            return False
        self._history.saved()
        self._sync_actions()
        self._say(note or "Saved.")
        self.saved.emit(note)
        return True

    def _warn(self, message: str) -> None:
        warn(self, message, title=TITLE)

    def _ask_to_save(self, message: str, detail: str = "") -> Choice:
        """The seam the tests answer through, as the window's is."""
        return ask_to_save(self, message, detail)

    def _may_close(self) -> bool:
        if not self.edited:
            return True
        choice = self._ask_to_save(
            "The picture has unsaved changes.",
            "Save writes them into the graphics files; Discard throws them away.",
        )
        if choice is Choice.SAVE:
            return self.save()
        return choice is Choice.DISCARD

    def reject(self) -> None:  # Qt override: Escape, and the dialog's own close
        if self._may_close():
            super().reject()

    def closeEvent(self, event: QCloseEvent) -> None:  # noqa: N802 - Qt override
        """The window's close: asked once here rather than through Qt's own
        close-is-reject, which would ask again on the way through
        :meth:`reject`. ``done`` is what tells the owner the window went."""
        if not self._may_close():
            event.ignore()
            return
        self.done(QDialog.DialogCode.Rejected)
        event.accept()

    def showEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        # The picture is what the window is for, so the keys go to it from
        # the first moment: space pans, and the tool keys reach the editor.
        super().showEvent(event)
        self._area.setFocus(Qt.FocusReason.OtherFocusReason)

    def keyPressEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        key = event.key()
        modifiers = event.modifiers()
        if (
            modifiers & Qt.KeyboardModifier.ControlModifier
            or modifiers & Qt.KeyboardModifier.AltModifier
        ):
            super().keyPressEvent(event)
            return
        if key == Qt.Key.Key_Escape and self.marquee is not None:
            self.clear_selection()
            event.accept()
            return
        tool = TOOL_BY_KEY.get(event.text())
        if tool is not None:
            self._tool_picked(tool)
            event.accept()
            return
        super().keyPressEvent(event)


def _stored(colour: QColor) -> tuple[int, int, int]:
    """A picked colour as the console will hold it: five bits a channel, so
    what the picture shows is what a save will write."""
    red, green, blue = snes_color(
        snes_value((colour.red(), colour.green(), colour.blue()))
    )
    return red, green, blue


__all__ = [
    "DEFAULT_ZOOM",
    "GRID_LABELS",
    "NOT_RECOLOURABLE",
    "PIXELS_MIME",
    "TITLE",
    "ZOOMS",
    "PixelEditor",
]
