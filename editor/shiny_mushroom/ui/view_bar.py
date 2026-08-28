"""The view bars: the View toggles as rows of square icon buttons.

The same :class:`~PySide6.QtGui.QAction` objects the menu shows, added to a
toolbar -- which is the whole design. A button and its menu row check, uncheck,
enable and disable together because they *are* one action, so there is no state
here to keep in step and nothing for the window to sync.

**Each editing environment gets a bar of its own.** The level's toggles mean
nothing over the world map -- they are preferences about a picture that is not
on the canvas -- so the window builds one bar per environment from the rows
declared here (:data:`LEVEL_BUTTONS`, :data:`WORLD_BUTTONS`) and its toolbar
registry swaps them with the rest of the mode's chrome -- see
:mod:`shiny_mushroom.ui.toolbars`. The screens toggle appears in both rows,
because the page grid is the world map's screens.

The icons are drawn here, not shipped: each is a few strokes in the palette's
button-text color, repainted when the palette changes so a theme switch
recolors them like every other widget. The menu rows stay text-only
(``setIconVisibleInMenu(False)``) -- no other row there has an icon.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence

from PySide6.QtCore import QEvent, QPointF, QRectF, QSize, Qt
from PySide6.QtGui import (
    QAction,
    QColor,
    QIcon,
    QKeySequence,
    QPainter,
    QPalette,
    QPen,
    QPixmap,
)
from PySide6.QtWidgets import QToolBar, QWidget

from shiny_mushroom.ui.menus import Actions

#: The glyph's logical size. The buttons are a touch larger and square.
ICON = 20
BUTTON = 28

#: One pictogram: handed a painter whose pen is already the theme's ink, and
#: the box to draw in.
Glyph = Callable[[QPainter, QRectF], None]


def _numbered_layer(numeral: str) -> Glyph:
    """A framed numeral: the layer's number is what tells 2 from 3, and a digit
    survives 20 pixels better than a third stacked rectangle would."""

    def draw(painter: QPainter, rect: QRectF) -> None:
        painter.drawRect(rect)
        font = painter.font()
        font.setBold(True)
        font.setPixelSize(round(rect.height() * 0.75))
        painter.setFont(font)
        painter.drawText(rect, Qt.AlignmentFlag.AlignCenter, numeral)

    return draw


def _sprite(painter: QPainter, rect: QRectF) -> None:
    """A filled round face: the artwork itself, as against its outline."""
    painter.setBrush(painter.pen().color())
    painter.drawEllipse(rect.adjusted(1, 1, -1, -1))
    # The eyes are punched out rather than painted, so they read in any theme.
    painter.setCompositionMode(QPainter.CompositionMode.CompositionMode_Clear)
    center = rect.center()
    eye = rect.width() * 0.12
    for side in (-1, +1):
        painter.drawEllipse(
            QPointF(
                center.x() + side * rect.width() * 0.18,
                center.y() - rect.height() * 0.1,
            ),
            eye,
            eye,
        )


def _dashed(painter: QPainter) -> None:
    pen = painter.pen()
    pen.setStyle(Qt.PenStyle.DashLine)
    painter.setPen(pen)


def _sprite_outline(painter: QPainter, rect: QRectF) -> None:
    """The dashed box with something in it: an outline around a sprite."""
    _dashed(painter)
    painter.drawRect(rect)
    painter.setBrush(painter.pen().color())
    painter.drawEllipse(rect.center(), rect.width() * 0.18, rect.height() * 0.18)


def _object_outline(painter: QPainter, rect: QRectF) -> None:
    """The dashed box alone: an outline around whatever an object drew."""
    _dashed(painter)
    painter.drawRect(rect)


def _screens(painter: QPainter, rect: QRectF) -> None:
    """A strip divided into screens."""
    painter.drawRect(rect)
    for fraction in (1 / 3, 2 / 3):
        x = rect.left() + rect.width() * fraction
        painter.drawLine(QPointF(x, rect.top()), QPointF(x, rect.bottom()))


def _frame(painter: QPainter, rect: QRectF) -> None:
    """A window in a screen: the border mask around the framed map."""
    painter.drawRect(rect)
    inset_x, inset_y = rect.width() * 0.22, rect.height() * 0.22
    painter.drawRect(rect.adjusted(inset_x, inset_y, -inset_x, -inset_y))


def _walks(painter: QPainter, rect: QRectF) -> None:
    """An arrow: the tile marks -- walk arrows, path steps, warp boxes."""
    mid = rect.center().y()
    painter.drawLine(QPointF(rect.left(), mid), QPointF(rect.right(), mid))
    head = rect.width() * 0.4
    for side in (-1, +1):
        painter.drawLine(
            QPointF(rect.right(), mid),
            QPointF(rect.right() - head, mid + side * head),
        )


#: Each toggle's pictogram, by its :class:`Actions` field name.
GLYPHS: dict[str, Glyph] = {
    "layer1": _numbered_layer("1"),
    "layer2": _numbered_layer("2"),
    "layer3": _numbered_layer("3"),
    "sprites": _sprite,
    "sprite_outlines": _sprite_outline,
    "objects": _object_outline,
    "screens": _screens,
    "world_layer1": _numbered_layer("1"),
    "world_layer2": _numbered_layer("2"),
    "world_sprites": _sprite,
    "world_tile_marks": _walks,
    "world_frame": _frame,
}

#: The rows the window builds its bars from: one per editing environment,
#: each entry an :class:`Actions` field name with a glyph in :data:`GLYPHS`.
#: In the order their Shift+digits count -- see :func:`menus.build` -- so a
#: button's place in the row is the number that reaches it. The map's row
#: skips Shift+3, whose key is the events view: it has a handle in the world
#: bar's Event box already, and renumbering around it would cost the two rows
#: their shared counting.
LEVEL_BUTTONS = (
    "layer1",
    "layer2",
    "layer3",
    "sprites",
    "sprite_outlines",
    "objects",
    "screens",
)
WORLD_BUTTONS = (
    "world_layer1",
    "world_layer2",
    "world_sprites",
    "world_tile_marks",
    "world_frame",
    "screens",
)


class ViewBar(QToolBar):
    """One environment's view options, as square buttons. Owns no state of its
    own: every button is one of the window's menu actions."""

    def __init__(
        self,
        actions: Actions,
        buttons: Sequence[str],
        title: str,
        name: str,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(title, parent)
        # Named so Qt can save and restore it with the window state, like the
        # other bars.
        self.setObjectName(name)
        self.setMovable(False)
        self.setIconSize(QSize(ICON, ICON))
        self.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonIconOnly)

        self._row: tuple[tuple[QAction, Glyph], ...] = tuple(
            (getattr(actions, field), GLYPHS[field]) for field in buttons
        )
        for action, _ in self._row:
            action.setIconVisibleInMenu(False)
            # The button has no text, so the tooltip carries the shortcut too
            # -- once, though an action shared between bars passes here twice.
            keys = action.shortcut()
            if not keys.isEmpty() and not action.property("tooltip-keyed"):
                native = keys.toString(QKeySequence.SequenceFormat.NativeText)
                action.setToolTip(f"{action.toolTip()} ({native})")
                action.setProperty("tooltip-keyed", True)
            self.addAction(action)
            button = self.widgetForAction(action)
            if button is not None:
                button.setFixedSize(BUTTON, BUTTON)
        self._paint_icons()

    def changeEvent(self, event: QEvent) -> None:  # noqa: N802 - Qt override
        super().changeEvent(event)
        # A theme switch hands every widget a new palette; the icons are the
        # one part of this bar Qt cannot recolor by itself.
        if event.type() == QEvent.Type.PaletteChange:
            self._paint_icons()

    def _paint_icons(self) -> None:
        palette = self.palette()
        normal = palette.color(
            QPalette.ColorGroup.Active, QPalette.ColorRole.ButtonText
        )
        disabled = palette.color(
            QPalette.ColorGroup.Disabled, QPalette.ColorRole.ButtonText
        )
        for action, glyph in self._row:
            icon = QIcon()
            icon.addPixmap(self._pixmap(glyph, normal))
            icon.addPixmap(self._pixmap(glyph, disabled), QIcon.Mode.Disabled)
            action.setIcon(icon)

    def _pixmap(self, glyph: Glyph, color: QColor) -> QPixmap:
        ratio = self.devicePixelRatio() or 1.0
        pixmap = QPixmap(round(ICON * ratio), round(ICON * ratio))
        pixmap.setDevicePixelRatio(ratio)
        pixmap.fill(Qt.GlobalColor.transparent)
        painter = QPainter(pixmap)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        pen = QPen(color)
        pen.setWidthF(1.4)
        painter.setPen(pen)
        painter.setBrush(Qt.BrushStyle.NoBrush)
        # Inset on the half-pixel, so a one-and-a-half-pixel stroke lands crisp.
        glyph(painter, QRectF(2.5, 2.5, ICON - 5, ICON - 5))
        painter.end()
        return pixmap
