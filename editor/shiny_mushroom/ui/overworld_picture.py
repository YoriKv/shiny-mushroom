"""The world map's pixels, behind the mode.

One place that owns the RGB buffers and the ``QImage`` made of them, with two
verbs per buffer: render the whole map, or patch a handful of cells. The mode
decides *what* to draw -- which document, which cells changed -- and this
holds the result, which is what keeps the picture bookkeeping out of the
gesture machine.

There are two buffers: the **base** map as the document draws it, and the
**events** twin with every event replayed over it. :meth:`show_events` picks
which one :attr:`image` answers with, so the toggle costs nothing once both
are drawn; the mode keeps whichever exists patched as edits land.

:class:`SheetPicture` is the same job for one stamp sheet drawn whole -- a
separate class rather than a third buffer here, because it is a picture of a
different thing at a different size, and the map's verbs (layers, the events
twin, cells) mean nothing over it.
"""

from __future__ import annotations

from collections.abc import Iterable

from PySide6.QtGui import QImage

from shiny_mushroom.level import BLOCK, TILE, Blocks
from shiny_mushroom.overworld import (
    COLUMNS,
    ROWS,
    WorldMap,
    WorldPainters,
    render_sheet,
    render_world,
    sheet_grid,
    sheet_runs,
    world_runs,
)
from shiny_mushroom.overworld_snapshot import OverworldSnapshot
from shiny_mushroom.ui.render import pixels_to_image


class WorldPicture:
    """The map's picture as it stands, and how to keep it standing."""

    def __init__(self) -> None:
        self._pixels = bytearray()
        self._image: QImage | None = None
        self._event_pixels = bytearray()
        self._event_image: QImage | None = None
        self._showing_events = False
        self._show_layer1 = True
        self._show_layer2 = True

    @property
    def image(self) -> QImage | None:
        """The active picture, or ``None`` before anything was rendered."""
        if self._showing_events and self._event_image is not None:
            return self._event_image
        return self._image

    @property
    def showing_events(self) -> bool:
        return self._showing_events

    @property
    def layer1_shown(self) -> bool:
        return self._show_layer1

    @property
    def layer2_shown(self) -> bool:
        return self._show_layer2

    def set_layers(self, layer1: bool, layer2: bool) -> None:
        """Which layers the next render draws.

        Held here rather than passed per call so a patch can never disagree
        with the render it lands on; the mode re-renders after changing them.
        """
        self._show_layer1 = layer1
        self._show_layer2 = layer2

    @property
    def has_events(self) -> bool:
        """Whether the events twin has been rendered."""
        return self._event_image is not None

    def show_events(self, on: bool) -> QImage | None:
        """Pick which buffer :attr:`image` answers with, and answer it.

        Turning the view on before :meth:`render_events` has drawn the twin
        answers the base picture -- the caller renders first, then toggles.
        """
        self._showing_events = on
        return self.image

    def render(
        self,
        snapshot: OverworldSnapshot,
        tiles: bytes,
        layer2: bytes | None,
        painter: Blocks | WorldPainters,
    ) -> QImage:
        """Draw the whole base map from the document's parts.

        A full render invalidates the events twin: it is a picture *of* the
        parts just drawn, and the mode re-renders it from the replayed parts
        when the view needs it again.
        """
        picture = render_world(
            snapshot,
            tiles,
            layer2=layer2,
            painter=painter,
            show_layer1=self._show_layer1,
            show_layer2=self._show_layer2,
        )
        self._pixels = bytearray(picture.pixels)
        self._image = pixels_to_image(self._pixels, picture.width, picture.height)
        self._event_pixels = bytearray()
        self._event_image = None
        return self._image

    def render_events(
        self,
        snapshot: OverworldSnapshot,
        tiles: bytes,
        layer2: bytes | None,
        painter: Blocks | WorldPainters,
    ) -> QImage:
        """Draw the whole events twin -- ``tiles`` and ``layer2`` are the
        *replayed* parts, which the mode computes."""
        picture = render_world(
            snapshot,
            tiles,
            layer2=layer2,
            painter=painter,
            show_layer1=self._show_layer1,
            show_layer2=self._show_layer2,
        )
        self._event_pixels = bytearray(picture.pixels)
        self._event_image = pixels_to_image(
            self._event_pixels, picture.width, picture.height
        )
        return self._event_image

    def patch(
        self,
        snapshot: OverworldSnapshot,
        tiles: bytes,
        layer2: bytes | None,
        cells: Iterable[int],
        painter: Blocks | WorldPainters,
    ) -> QImage | None:
        """Redraw just these cells of the base map -- what an edit costs.

        The same inputs as :meth:`render`, so the mode speaks one vocabulary
        whichever verb it needs. ``None`` before a render, which is also the
        honest answer: there is nothing to patch.
        """
        if self._image is None:
            return None
        for offset, pixels in world_runs(
            snapshot,
            tiles,
            cells,
            layer2=layer2,
            painter=painter,
            show_layer1=self._show_layer1,
            show_layer2=self._show_layer2,
        ):
            self._pixels[offset : offset + len(pixels)] = pixels
        self._image = pixels_to_image(self._pixels, COLUMNS * BLOCK, ROWS * BLOCK)
        return self._image

    def patch_events(
        self,
        snapshot: OverworldSnapshot,
        tiles: bytes,
        layer2: bytes | None,
        cells: Iterable[int],
        painter: Blocks | WorldPainters,
    ) -> QImage | None:
        """Redraw just these cells of the events twin, from replayed parts."""
        if self._event_image is None:
            return None
        for offset, pixels in world_runs(
            snapshot,
            tiles,
            cells,
            layer2=layer2,
            painter=painter,
            show_layer1=self._show_layer1,
            show_layer2=self._show_layer2,
        ):
            self._event_pixels[offset : offset + len(pixels)] = pixels
        self._event_image = pixels_to_image(
            self._event_pixels, COLUMNS * BLOCK, ROWS * BLOCK
        )
        return self._event_image

    def forget_events(self) -> None:
        """Drop the events twin, keeping the base picture.

        For a change that leaves the twin wrong but is not worth redrawing it
        over -- a palette pick while the base map is the one on screen. The
        mode renders it again when the view asks for it.
        """
        self._event_pixels = bytearray()
        self._event_image = None

    def forget(self) -> None:
        """Drop the pictures with the map they were of."""
        self._pixels = bytearray()
        self._image = None
        self._event_pixels = bytearray()
        self._event_image = None
        self._showing_events = False
        self._show_layer1 = True
        self._show_layer2 = True


class SheetPicture:
    """One stamp sheet's picture as it stands, and how to keep it standing.

    :class:`WorldPicture`'s contract over a different buffer: render the
    whole sheet, or patch the offsets an edit moved. Which sheet is drawn
    rides in the picture, so a patch can never land on the other one's
    pixels -- the two are different sizes.
    """

    def __init__(self) -> None:
        self._pixels = bytearray()
        self._image: QImage | None = None
        self._small = False

    @property
    def image(self) -> QImage | None:
        """The sheet's picture, or ``None`` before anything was rendered."""
        return self._image

    @property
    def small(self) -> bool:
        """Which sheet is drawn: the 2x2 sheet when true, the 6x6 otherwise.
        Meaningless before a render."""
        return self._small

    def render(
        self,
        document: WorldMap,
        snapshot: OverworldSnapshot,
        *,
        small: bool,
        painter: Blocks | None = None,
    ) -> QImage:
        """Draw one whole sheet from the document's own bytes."""
        picture = render_sheet(document, snapshot, small=small, painter=painter)
        self._pixels = bytearray(picture.pixels)
        self._image = pixels_to_image(self._pixels, picture.width, picture.height)
        self._small = small
        return self._image

    def patch(
        self,
        document: WorldMap,
        snapshot: OverworldSnapshot,
        offsets: Iterable[int],
        painter: Blocks | None = None,
    ) -> QImage | None:
        """Redraw just these sheet offsets -- what an edit costs.

        The sheet is the one this picture holds; offsets belonging to the
        other are skipped by :func:`~shiny_mushroom.overworld.sheet_runs`.
        ``None`` before a render, which is also the honest answer: there is
        nothing to patch.
        """
        if self._image is None:
            return None
        for offset, pixels in sheet_runs(
            document, snapshot, offsets, small=self._small, painter=painter
        ):
            self._pixels[offset : offset + len(pixels)] = pixels
        columns, rows = sheet_grid(small=self._small)
        self._image = pixels_to_image(self._pixels, columns * TILE, rows * TILE)
        return self._image

    def forget(self) -> None:
        """Drop the picture with the map it was of."""
        self._pixels = bytearray()
        self._image = None
        self._small = False
