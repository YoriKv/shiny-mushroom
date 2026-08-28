"""List widgets shared across the editor's panels.

One home for behaviour every tile-grid-shaped list wants, so a new panel
gets it by construction rather than by copying. :class:`RowScrollList` is
the ready-made widget and :class:`TileGrid` the grid of pictures every tile
palette in the editor is; :func:`scroll_by_rows` is the same wheel treatment
as a function, for a view that must subclass something else, and
:func:`add_tile` puts one picture in a grid.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtCore import QSize, Qt
from PySide6.QtGui import QIcon, QImage, QPixmap, QWheelEvent
from PySide6.QtWidgets import QListView, QListWidget, QListWidgetItem


def scroll_by_rows(view: QListView, event: QWheelEvent) -> bool:
    """Scroll ``view`` one row per wheel notch, saying whether it applied.

    Qt scrolls by the device's own pixel delta whenever one is reported --
    a high-resolution wheel creeps a few pixels a notch over a grid
    hundreds of rows tall. The angle delta is the honest notch count, so
    the wheel is translated here: a notch is a row, scaled proportionally
    for smooth-scrolling devices that report fractions of one. The row is
    the grid's height, or the first row's own where there is no grid.

    ``False`` -- a horizontal wheel, or a view with nothing to measure a
    row by -- means the caller should fall back to Qt's own scrolling. The
    view wants ``ScrollPerPixel`` vertical scroll mode, so the translation
    lands where it says.
    """
    notches = event.angleDelta().y()
    row = view.gridSize().height()
    if row <= 0:
        model = view.model()
        if model is not None and model.rowCount():
            row = view.sizeHintForRow(0)
    if notches == 0 or row <= 0:
        return False
    bar = view.verticalScrollBar()
    bar.setValue(bar.value() - notches * row // 120)
    event.accept()
    return True


class RowScrollList(QListWidget):
    """A ``QListWidget`` scrolling one row per wheel notch.

    Vertical scrolling is put in per-pixel mode at construction --
    :func:`scroll_by_rows` needs it to move by exactly the rows it says.
    """

    def __init__(self, parent=None) -> None:  # noqa: ANN001 - QWidget
        super().__init__(parent)
        self.setVerticalScrollMode(QListView.ScrollMode.ScrollPerPixel)

    def wheelEvent(self, event: QWheelEvent) -> None:  # noqa: N802 - Qt override
        if not scroll_by_rows(self, event):
            super().wheelEvent(event)


class TileGrid(RowScrollList):
    """A list laid out as a tight grid of pictures, a cell to a tile.

    Every tile palette in the editor is one of these. IconMode's own layout
    reserves a text line under each icon and margins around it, and these
    items are only their picture -- so the cells are exactly the icon and
    the tiles abut, like the map or the sheet they were cut from. The
    scrollbar's arrows move a row too, matching the wheel.
    """

    def __init__(self, size: int, parent=None) -> None:  # noqa: ANN001 - QWidget
        super().__init__(parent)
        self.setViewMode(QListView.ViewMode.IconMode)
        self.setResizeMode(QListView.ResizeMode.Adjust)
        self.setMovement(QListView.Movement.Static)
        self.setUniformItemSizes(True)
        self.setSpacing(0)
        self.set_cell(size)

    def set_cell(self, size: int, *, grid: bool = True) -> None:
        """Lay the view out for icons ``size`` px square.

        With ``grid`` off there is no cell size and the items size themselves,
        which is what a palette wants on a page that reads as rows of named
        things rather than as a grid of pictures.
        """
        self.setIconSize(QSize(size, size))
        self.setGridSize(QSize(size, size) if grid else QSize())
        self.verticalScrollBar().setSingleStep(size)


def add_tile(
    view: QListWidget,
    image: QImage,
    number: int,
    tooltip: str,
    *,
    size: int,
    text: str = "",
    decorate: Callable[[QImage, int], QImage] | None = None,
) -> QListWidgetItem:
    """Append one tile to ``view`` and hand its item back.

    ``image`` is scaled into a ``size`` square, ``number`` rides along in
    ``UserRole`` -- which is what a click on the row is read back as -- and
    ``tooltip`` is what a hover says.

    ``decorate`` is handed the scaled picture and the number, for a grid that
    draws something of its own over its tiles. After the scale, so its strokes
    land at the weight they are drawn at rather than being magnified with the
    artwork.

    A row with no ``text`` is given a size hint of exactly the icon: the
    default pads it out, which shows as a stripe of background between rows
    that are meant to abut.
    """
    scaled = image.scaled(size, size, Qt.AspectRatioMode.KeepAspectRatio)
    if decorate is not None:
        scaled = decorate(scaled, number)
    item = QListWidgetItem(QIcon(QPixmap.fromImage(scaled)), text)
    if not text:
        item.setSizeHint(QSize(size, size))
    item.setData(Qt.ItemDataRole.UserRole, number)
    item.setToolTip(tooltip)
    view.addItem(item)
    return item
