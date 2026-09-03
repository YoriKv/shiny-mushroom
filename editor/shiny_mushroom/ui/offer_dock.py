"""The offer dock: what the environment on the canvas can place, one page
per environment.

The level's catalogue, the world map's tile palette and the Map16
environment's VRAM chars are one question asked three ways -- what can go
onto this picture -- and one dock answers it, turning to the page for the
picture in front. One dock rather than three taking turns in a spot, for
the reason the level's own three offers are tabs of one panel
(:mod:`shiny_mushroom.ui.create`): a spot shared by turns has a size that
belongs to nobody, and a panel dragged wider in one environment came back
at whatever the next left it at. So there is one arrangement of the docks
to remember rather than one per environment, and one Window row.

The dock owns nothing but the turn. Each page keeps its own signals and its
own tabs, and the window connects to the pages as it always did; the
dock's title is the page's, so the Window row -- the dock's own toggle
action -- reads Create, Tiles or VRAM without being told.
"""

from __future__ import annotations

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QDockWidget, QStackedWidget, QWidget

from shiny_mushroom.ui.create import CreatePanel
from shiny_mushroom.ui.map16_panel import Map16Panel
from shiny_mushroom.ui.tile_palette import TilePalette

#: The create panel's name, kept: it is the dock's, and an arrangement
#: saved when the level's panel was the dock puts this one where it was.
OBJECT_NAME = "create"


class OfferDock(QDockWidget):
    """One dock, three pages; the current one is the environment's."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Create", parent)
        self.setObjectName(OBJECT_NAME)
        self.setAllowedAreas(
            Qt.DockWidgetArea.RightDockWidgetArea | Qt.DockWidgetArea.LeftDockWidgetArea
        )
        self.create = CreatePanel()
        self.tile_palette = TilePalette()
        self.map16_panel = Map16Panel()
        self._pages = QStackedWidget()
        for page in (self.create, self.tile_palette, self.map16_panel):
            self._pages.addWidget(page)
        self.setWidget(self._pages)

    @property
    def page(self) -> QWidget:
        """The page in front."""
        return self._pages.currentWidget()

    def turn_to(self, page: QWidget) -> None:
        """Bring ``page`` to the front and wear its name."""
        self._pages.setCurrentWidget(page)
        self.setWindowTitle(page.windowTitle())
