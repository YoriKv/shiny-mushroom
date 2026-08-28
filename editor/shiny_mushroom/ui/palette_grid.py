"""A grid of colours, painted rather than assembled.

Every palette the editor shows is a rectangle of flat colours, and Qt's item
views are the wrong shape for it: an icon per swatch is a scaled pixmap, a
layout pass and a delegate for what is one ``fillRect``, and the column count
would follow the dock's width rather than the palette's own -- so CGRAM's
sixteen columns would reflow to fourteen when the panel narrowed, and a row of
colours would stop being a row.

So this paints. It is handed swatches and draws them, and what a click on one
*means* belongs to whatever owns the document -- the same division the canvas
keeps ([`architecture`](../../../docs/editor/architecture.md)). Which makes it
testable by handing it colours and asking what is where, with no palette file,
no project and no emulator behind it.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass

from PySide6.QtCore import QRect, QSize, Qt, Signal
from PySide6.QtGui import QColor, QMouseEvent, QPainter, QPaintEvent, QPen
from PySide6.QtWidgets import QToolTip, QWidget

from shiny_mushroom.level import snes_color
from shiny_mushroom.ui.hatching import hatch
from shiny_mushroom.ui.zoomed_grid import ZoomedGrid

#: A swatch's side, in device-independent pixels. Big enough to tell two dark
#: colours apart at a glance, small enough that CGRAM's sixteen columns fit a
#: dock without one.
CELL = 20

#: How wide the row-number gutter is when there is one, and the gap between it
#: and the first column.
GUTTER = 22


@dataclass(frozen=True)
class Swatch:
    """One colour on offer.

    ``offset`` is the byte in the palette file this colour comes out of, and
    ``None`` means it does not come out of one -- a colour the game's code
    writes itself, or one the capture would not confirm. Those are drawn
    hatched and are not pickable, which is the whole of what "not editable
    here" has to look like.
    """

    color: int
    offset: int | None = None
    tip: str = ""


class SwatchGrid(ZoomedGrid):
    """A rectangle of colours. Owns no palette.

    A grid whose cell is already in widget pixels, so its zoom stays 1: what
    it takes from :class:`~shiny_mushroom.ui.zoomed_grid.ZoomedGrid` is the
    row-and-column arithmetic every painted grid here shares.
    """

    #: A colour was selected: its index into the swatches. ``-1`` when the
    #: selection was cleared.
    picked = Signal(int)

    #: A colour was asked to be changed -- a double-click, or Return on the
    #: selected one. Only ever an editable swatch.
    activated = Signal(int)

    def __init__(
        self,
        columns: int = 16,
        *,
        numbered: bool = False,
        cell: int = CELL,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(columns, cell, gutter=GUTTER if numbered else 0, parent=parent)
        self._swatches: tuple[Swatch, ...] = ()
        self._selected = -1
        self.setMouseTracking(True)
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    # -- what is on offer ----------------------------------------------------

    def set_swatches(self, swatches: Sequence[Swatch]) -> None:
        """Offer these colours, in this order.

        The selection is kept where the swatch under it is still editable and
        dropped where it is not, so a level change that takes a colour out of
        the picture cannot leave the panel pointing at it.
        """
        self._swatches = tuple(swatches)
        self._count = len(self._swatches)
        if not self._editable(self._selected):
            self.select(-1)
        self.updateGeometry()
        self.update()

    @property
    def swatches(self) -> tuple[Swatch, ...]:
        return self._swatches

    # -- what is selected ----------------------------------------------------

    @property
    def selected(self) -> int:
        """The selected swatch's index, or ``-1``."""
        return self._selected

    @property
    def selected_offset(self) -> int | None:
        """Where the selected colour lives in the palette file."""
        return (
            self._swatches[self._selected].offset
            if self._editable(self._selected)
            else None
        )

    def select(self, index: int) -> None:
        """Select ``index``, announcing it. A swatch that is not editable, and
        anything out of range, clears the selection instead."""
        wanted = index if self._editable(index) else -1
        if wanted == self._selected:
            return
        self._selected = wanted
        self.update()
        self.picked.emit(wanted)

    def select_offset(self, offset: int) -> bool:
        """Select the first swatch reading ``offset``, saying whether there was
        one -- how a panel elsewhere in the window points this at a colour."""
        for index, swatch in enumerate(self._swatches):
            if swatch.offset == offset:
                self.select(index)
                return True
        return False

    def _editable(self, index: int) -> bool:
        return (
            0 <= index < len(self._swatches)
            and self._swatches[index].offset is not None
        )

    # -- where things are ----------------------------------------------------

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        """One row tall even with nothing on offer: a dock whose palette has
        not arrived yet is a gap where the colours will be, not nothing."""
        return QSize(
            self._gutter + self._columns * self.scale, max(1, self.rows) * self.scale
        )

    # -- gestures ------------------------------------------------------------

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if event.button() is Qt.MouseButton.LeftButton:
            self.select(self.index_at(event.position().toPoint()))
        super().mousePressEvent(event)

    def mouseDoubleClickEvent(  # noqa: N802 - Qt override
        self, event: QMouseEvent
    ) -> None:
        index = self.index_at(event.position().toPoint())
        if event.button() is Qt.MouseButton.LeftButton and self._editable(index):
            self.select(index)
            self.activated.emit(index)
        super().mouseDoubleClickEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        index = self.index_at(event.position().toPoint())
        tip = self._swatches[index].tip if 0 <= index < len(self._swatches) else ""
        QToolTip.showText(event.globalPosition().toPoint(), tip, self)
        super().mouseMoveEvent(event)

    def keyPressEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        step = {
            Qt.Key.Key_Left: -1,
            Qt.Key.Key_Right: 1,
            Qt.Key.Key_Up: -self._columns,
            Qt.Key.Key_Down: self._columns,
        }.get(Qt.Key(event.key()))
        if step is not None and self._swatches:
            self._step(step)
            event.accept()
            return
        if event.key() in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            if self._editable(self._selected):
                self.activated.emit(self._selected)
            event.accept()
            return
        super().keyPressEvent(event)

    def _step(self, by: int) -> None:
        """Move the selection ``by`` swatches, skipping over the ones that are
        not editable -- an arrow key that stopped on a hatched swatch would
        take two presses to get anywhere."""
        start = self._selected if self._selected >= 0 else -by
        index = start + by
        while 0 <= index < len(self._swatches):
            if self._editable(index):
                self.select(index)
                return
            index += by

    # -- painting ------------------------------------------------------------

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        colors = self.palette()
        if self._gutter:
            painter.setPen(colors.windowText().color())
            for row in range(self.rows):
                painter.drawText(
                    QRect(0, row * self._cell, self._gutter - 4, self._cell),
                    Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter,
                    f"{row:X}",
                )
        for index, swatch in enumerate(self._swatches):
            where = self.rect_of(index)
            red, green, blue = snes_color(swatch.color)
            painter.fillRect(where, QColor(red, green, blue))
            if swatch.offset is None:
                # What "not editable here" looks like everywhere it is said
                # (:mod:`shiny_mushroom.ui.hatching`).
                hatch(painter, where)
            painter.setPen(QPen(colors.mid().color(), 1))
            painter.drawRect(where.adjusted(0, 0, -1, -1))
        if 0 <= self._selected < len(self._swatches):
            where = self.rect_of(self._selected)
            # Two rings, light over dark: one colour of outline disappears into
            # whichever swatch it lands on, and a palette holds every colour.
            painter.setPen(QPen(QColor(0, 0, 0), 1))
            painter.drawRect(where.adjusted(0, 0, -1, -1))
            painter.setPen(QPen(QColor(255, 255, 255), 1))
            painter.drawRect(where.adjusted(1, 1, -2, -2))
