"""The eight graphics slots as a picture: a sheet apiece, outlined and named.

What VRAM holds where, for a reader deciding which slot to point somewhere
else. One column, the eight in the order the row itself is in -- FG1, FG2,
BG1, FG3, then SP1-SP4 -- each sheet its 128 tiles sixteen to a row, the
shape the Graphics window draws a file in, so a file looks the same in both
windows. A column rather than a grid because the sheets are wide and the
window they sit in is not: what scrolls is the list of slots.

Handed images and captions and paints them, exactly as
:mod:`shiny_mushroom.ui.tile_sheet` is
([`architecture`](../../../docs/editor/architecture.md)): what a slot is,
which file is in it and what VRAM says belong to whoever owns the row. That
is what lets this be tested by handing it eight pictures and reading pixels
back, with no capture behind it.

A :class:`~shiny_mushroom.ui.zoomed_grid.ZoomedPicture`, so the shared picker
and Ctrl with the wheel drive it as they drive the tile sheet and the Map16
grids.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass

from PySide6.QtCore import QRect, QSize, Qt
from PySide6.QtGui import QColor, QImage, QPainter, QPaintEvent, QPen, QRegion
from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.hatching import hatch
from shiny_mushroom.ui.tables import note_ink
from shiny_mushroom.ui.zoomed_grid import ZoomedPicture

#: The gaps between a caption and the sheet under it, and between one band
#: and the next, in widget pixels -- not scaled by the zoom, which is the
#: picture's.
CAPTION_GAP = 2
ROW_GAP = 8

#: How wide a band's outline is, and so how much room the widget leaves for
#: it on either side of a sheet and under the last one: the outline sits
#: *around* the picture rather than over its edge pixels, which it can only
#: do if there is a pixel there to sit in. The one above a sheet sits in
#: :data:`CAPTION_GAP`.
EDGE = 1

#: A tile's side in the sheet, before the zoom. The band's own picture says
#: how many columns it is cut into, so nothing here is a second opinion about
#: the sheet's shape.
TILE = 8


@dataclass(frozen=True)
class Slot:
    """One slot's band of the picture: what to call it, what is in it, and
    where in VRAM it is."""

    #: ``FG1``, ``SP4`` -- the slot's own name.
    name: str
    #: The file in it, ``GFX14``, or empty where the cartridge cannot say.
    file: str
    #: Its VRAM word address, ``$0000``, written at the end of the caption in
    #: the ink a note is written in.
    address: str
    #: The 128 tiles VRAM holds there, sixteen to a row.
    sheet: QImage
    #: Which of those tiles are not the slot's file's to give -- hatched, the
    #: way an uneditable swatch is (:mod:`shiny_mushroom.ui.hatching`). Empty
    #: for a slot whose whole run is its file's.
    spoken_for: frozenset[int] = frozenset()


class VramSlots(ZoomedPicture):
    """Eight slots, one under the next. Handed :class:`Slot` bands by
    :meth:`set_slots` and painting them at :attr:`zoom`."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent=parent)
        self._slots: tuple[Slot, ...] = ()

    # -- what is shown --------------------------------------------------------

    def set_slots(self, slots: Sequence[Slot]) -> None:
        """Show these bands, in order. Fewer than eight is drawn as far as it
        goes; none is an empty widget, which is what a project with no capture
        behind it has to show."""
        self._slots = tuple(slots)
        self._resized()

    @property
    def slots(self) -> tuple[Slot, ...]:
        return self._slots

    # -- geometry -------------------------------------------------------------

    @property
    def caption_height(self) -> int:
        return self.fontMetrics().height()

    def _sheet_size(self) -> QSize:
        """One sheet at this zoom. The first band's picture decides it -- they
        are all one slot's worth of tiles -- and an empty widget has none."""
        if not self._slots:
            return QSize(0, 0)
        return self._slots[0].sheet.size() * self._zoom

    def band_height(self, zoom: int | None = None) -> int:
        """How tall one band is at ``zoom``, or at this widget's -- its
        caption, the gap and the sheet. For a caller sizing the window onto
        this one, which is a window onto a column that scrolls."""
        if not self._slots:
            return 0
        held = self._zoom if zoom is None else zoom
        return self.caption_height + CAPTION_GAP + self._slots[0].sheet.height() * held

    def tile_rect(self, index: int, tile: int) -> QRect:
        """Where one tile of band ``index`` is, in widget pixels. The band's
        picture decides the columns -- its width over :data:`TILE` -- so a
        sheet cut some other way still lands its tiles in the right place."""
        where = self.rect_of(index)
        columns = max(1, self._slots[index].sheet.width() // TILE)
        side = TILE * self._zoom
        return QRect(
            where.left() + (tile % columns) * side,
            where.top() + (tile // columns) * side,
            side,
            side,
        )

    def rect_of(self, index: int) -> QRect:
        """Where a band's *sheet* is, in widget pixels; its caption sits in
        the :attr:`caption_height` above, and its outline in the
        :data:`EDGE` around it."""
        sheet = self._sheet_size()
        top = self.caption_height + CAPTION_GAP
        return QRect(
            EDGE,
            index * (top + sheet.height() + ROW_GAP) + top,
            sheet.width(),
            sheet.height(),
        )

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        if not self._slots:
            return QSize(0, 0)
        band = self.band_height()
        return QSize(
            self._sheet_size().width() + 2 * EDGE,
            len(self._slots) * (band + ROW_GAP) - ROW_GAP + EDGE,
        )

    # -- painting -------------------------------------------------------------

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        ink = self.palette().windowText().color()
        note = note_ink(self.palette())
        edge = self.palette().mid().color()
        # Every tile of every band that is not its file's to give, gathered
        # into one region: hatching it in a single pass rather than per tile
        # is both the cheaper drawing -- a slot may hold 76 of them -- and the
        # one whose diagonals run on across a run of tiles rather than
        # restarting at each.
        spoken_for = QRegion()
        for index, slot in enumerate(self._slots):
            where = self.rect_of(index)
            painter.drawImage(where, slot.sheet)
            for tile in slot.spoken_for:
                spoken_for = spoken_for.united(self.tile_rect(index, tile))
            # The outline sits *around* the sheet rather than over its edge
            # pixels: what it marks is where one slot's tiles stop. Grown at
            # the near corner alone -- `drawRect` already draws the far two
            # sides a pixel past the rectangle's own size.
            painter.setPen(QPen(edge, EDGE))
            painter.drawRect(where.adjusted(-EDGE, -EDGE, 0, 0))
            self._caption(painter, where, slot, ink, note)
        if not spoken_for.isEmpty():
            # Over the picture rather than into it: the sheet is the level's
            # own VRAM and stays readable under the mark, and the mark stays
            # one pixel wide at every zoom.
            hatch(painter, spoken_for)
        painter.end()

    def _caption(
        self, painter: QPainter, where: QRect, slot: Slot, ink: QColor, note: QColor
    ) -> None:
        """``FG1 · GFX14`` at the left of the band, its VRAM address at the
        right in the note ink -- two draws on one line, so the eye reads a
        column of names and a column of addresses rather than a sentence."""
        line = QRect(
            where.left(),
            where.top() - self.caption_height - CAPTION_GAP,
            where.width(),
            self.caption_height,
        )
        painter.setPen(QPen(ink, 1))
        named = f"{slot.name} · {slot.file}" if slot.file else slot.name
        painter.drawText(line, Qt.AlignmentFlag.AlignLeft, named)
        painter.setPen(QPen(note, 1))
        painter.drawText(line, Qt.AlignmentFlag.AlignRight, slot.address)


__all__ = ["EDGE", "Slot", "VramSlots"]
