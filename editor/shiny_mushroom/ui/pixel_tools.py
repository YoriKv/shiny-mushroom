"""The pixel editor's tools: what each one is, and the rail that picks one.

One table, :data:`TOOL_SPECS`, is what the rail draws, what the number keys
pick and what a gesture does -- so a tool is added in one place. Its order is
the rail's top-to-bottom order *and* the ``1``-``9`` keys, so a button's place
in the column is its key and the two cannot drift apart.

A tool is a **gesture** and, for the shape tools, a rasterizer out of
:mod:`shiny_mushroom.pixel_edit`: the pencil paints under the pointer and
joins the samples, a shape tool anchors on the press and rubber-bands to the
pointer, the fill floods on a click, the eyedropper samples, and the marquee
selects. The rail owns none of that: it shows one button a tool and says
which was pressed (:attr:`ToolRail.tool_selected`), and the editor drives
:meth:`ToolRail.set_tool` back when a key picks one.

The three tools that are a picture of a thing wear marks from the icon font;
the six that are a shape draw their own face, a line being its own best icon.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum

from PySide6.QtCore import QEvent, QRect, QRectF, QSize, Qt, Signal
from PySide6.QtGui import QColor, QIcon, QPainter, QPalette, QPen, QPixmap
from PySide6.QtWidgets import (
    QButtonGroup,
    QSizePolicy,
    QToolButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import pixel_edit
from shiny_mushroom.ui.icon_font import palette_icon
from shiny_mushroom.ui.icons import Icon
from shiny_mushroom.ui.tips import wrap_tip

#: A tool button's side, and the face drawn inside it.
BUTTON = 30
FACE = 20


class Gesture(Enum):
    """How a tool reads the mouse."""

    #: Paint under the pointer, joining one sample to the next.
    FREEHAND = "freehand"
    #: Anchor on the press, rubber-band a shape to the pointer, commit on
    #: the release.
    SHAPE = "shape"
    #: A click floods the region under it.
    FILL = "fill"
    #: A click takes the colour under it; nothing is painted.
    SAMPLE = "sample"
    #: A drag selects a rectangle of pixels.
    MARQUEE = "marquee"


class Tool(Enum):
    """The tools, ``value`` the key they are remembered under."""

    SELECT = "select"
    PENCIL = "pencil"
    EYEDROPPER = "eyedropper"
    FILL = "fill"
    LINE = "line"
    RECT = "rect"
    RECT_FILLED = "rect_filled"
    ELLIPSE = "ellipse"
    ELLIPSE_FILLED = "ellipse_filled"


#: Two corners to the pixels between them.
Rasterize = Callable[[int, int, int, int], list[pixel_edit.Coord]]


@dataclass(frozen=True)
class ToolSpec:
    """One tool: its name, its key, how it reads the mouse, and its face --
    an ``icon`` from the font or a ``shape`` the rail paints itself."""

    tool: Tool
    label: str
    tip: str
    key: str
    gesture: Gesture
    rasterize: Rasterize | None = None
    icon: Icon | None = None
    shape: str | None = None


TOOL_SPECS: tuple[ToolSpec, ...] = (
    ToolSpec(
        Tool.SELECT,
        "Select",
        "Select a rectangle of pixels; drag from inside it to move them, "
        "double-click for the whole tile, Shift for a square.",
        "1",
        Gesture.MARQUEE,
        shape="marquee",
    ),
    ToolSpec(
        Tool.PENCIL,
        "Pencil",
        "Paint freehand.",
        "2",
        Gesture.FREEHAND,
        pixel_edit.line,
        icon=Icon.PENCIL,
    ),
    ToolSpec(
        Tool.EYEDROPPER,
        "Eyedropper",
        "Take the colour under the pointer. Right-click does this with any tool.",
        "3",
        Gesture.SAMPLE,
        icon=Icon.EYEDROPPER,
    ),
    ToolSpec(
        Tool.FILL,
        "Fill",
        "Flood the region under the pointer.",
        "4",
        Gesture.FILL,
        icon=Icon.FILL,
    ),
    ToolSpec(
        Tool.LINE,
        "Line",
        "Draw a line.",
        "5",
        Gesture.SHAPE,
        pixel_edit.line,
        shape="line",
    ),
    ToolSpec(
        Tool.RECT,
        "Rectangle",
        "Draw a rectangle's outline.",
        "6",
        Gesture.SHAPE,
        pixel_edit.rect_outline,
        shape="rect",
    ),
    ToolSpec(
        Tool.RECT_FILLED,
        "Filled Rectangle",
        "Draw a filled rectangle.",
        "7",
        Gesture.SHAPE,
        pixel_edit.rect_filled,
        shape="rect_filled",
    ),
    ToolSpec(
        Tool.ELLIPSE,
        "Ellipse",
        "Draw an ellipse's outline.",
        "8",
        Gesture.SHAPE,
        pixel_edit.ellipse_outline,
        shape="ellipse",
    ),
    ToolSpec(
        Tool.ELLIPSE_FILLED,
        "Filled Ellipse",
        "Draw a filled ellipse.",
        "9",
        Gesture.SHAPE,
        pixel_edit.ellipse_filled,
        shape="ellipse_filled",
    ),
)

SPEC_BY_TOOL: dict[Tool, ToolSpec] = {spec.tool: spec for spec in TOOL_SPECS}
TOOL_BY_KEY: dict[str, Tool] = {spec.key: spec.tool for spec in TOOL_SPECS}


class ToolRail(QWidget):
    """One column of tool buttons, exactly one of them down. Owns no tool:
    it says which button was pressed and is told which to show."""

    tool_selected = Signal(object)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._buttons: dict[Tool, QToolButton] = {}
        self._group = QButtonGroup(self)
        self._group.setExclusive(True)
        self.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Maximum)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(2, 2, 2, 2)
        layout.setSpacing(2)
        for spec in TOOL_SPECS:
            button = QToolButton()
            button.setToolTip(wrap_tip(f"{spec.label} ({spec.key}). {spec.tip}"))
            button.setText(spec.label)
            button.setAccessibleName(spec.label)
            button.setCheckable(True)
            button.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonIconOnly)
            button.setFixedSize(BUTTON, BUTTON)
            button.setIconSize(QSize(FACE, FACE))
            button.setFocusPolicy(Qt.FocusPolicy.NoFocus)
            button.clicked.connect(lambda _=False, tool=spec.tool: self._pick(tool))
            self._group.addButton(button)
            layout.addWidget(button)
            self._buttons[spec.tool] = button
        self._bake()

    def _pick(self, tool: Tool) -> None:
        self.tool_selected.emit(tool)

    @property
    def tool(self) -> Tool:
        for tool, button in self._buttons.items():
            if button.isChecked():
                return tool
        return Tool.PENCIL

    def set_tool(self, tool: Tool) -> None:
        """Show ``tool`` down, without announcing it."""
        button = self._buttons[tool]
        if not button.isChecked():
            button.setChecked(True)

    def changeEvent(self, event: QEvent) -> None:  # noqa: N802 - Qt override
        super().changeEvent(event)
        if event.type() in (
            QEvent.Type.PaletteChange,
            QEvent.Type.DevicePixelRatioChange,
        ):
            self._bake()

    def _bake(self) -> None:
        """Draw every face in the palette's ink at the screen's ratio -- both
        are in the pixmap, so a theme switch or a move to another screen
        draws them again."""
        palette = self.palette()
        ink = palette.color(QPalette.ColorGroup.Active, QPalette.ColorRole.ButtonText)
        ratio = self.devicePixelRatioF() or 1.0
        for spec in TOOL_SPECS:
            if spec.icon is not None:
                icon = QIcon(palette_icon(spec.icon, palette, QSize(FACE, FACE), ratio))
            else:
                assert spec.shape is not None
                icon = QIcon(shape_face(spec.shape, ink, ratio))
            self._buttons[spec.tool].setIcon(icon)


def shape_face(shape: str, ink: QColor, ratio: float) -> QPixmap:
    """A shape tool's face, ``FACE`` logical pixels square: the shape it
    draws, in ``ink``, on nothing."""
    size = round(FACE * ratio)
    pixmap = QPixmap(size, size)
    pixmap.setDevicePixelRatio(ratio)
    pixmap.fill(Qt.GlobalColor.transparent)
    painter = QPainter(pixmap)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, shape.startswith("ellipse"))
    pen = QPen(ink, 2)
    pen.setCapStyle(Qt.PenCapStyle.RoundCap)
    painter.setPen(pen)
    painter.setBrush(ink if shape.endswith("filled") else Qt.BrushStyle.NoBrush)
    inset = 3
    box = QRect(inset, inset, FACE - 2 * inset, FACE - 2 * inset)
    if shape == "line":
        painter.drawLine(box.bottomLeft(), box.topRight())
    elif shape.startswith("rect"):
        painter.drawRect(box)
    elif shape.startswith("ellipse"):
        painter.drawEllipse(QRectF(box))
    elif shape == "marquee":
        pen = QPen(ink, 2)
        pen.setStyle(Qt.PenStyle.DashLine)
        pen.setDashPattern([2, 2])
        painter.setPen(pen)
        painter.drawRect(box)
    painter.end()
    return pixmap


__all__ = [
    "SPEC_BY_TOOL",
    "TOOL_BY_KEY",
    "TOOL_SPECS",
    "Gesture",
    "Tool",
    "ToolRail",
    "ToolSpec",
    "shape_face",
]
