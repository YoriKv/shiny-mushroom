"""The canvas: the editor's primary surface, and what the window is built
around.

A fixed-size widget, shown through a
:class:`~shiny_mushroom.ui.canvas_view.CanvasView` - which is where scrolling,
panning and the wheel live. **It owns no model.** It is handed a ready
:class:`QImage` and only scales, paints and measures it, reporting the mouse in
*image-pixel* coordinates so that whatever ends up owning the document can
decide what a gesture means. Keeping it model-free is what lets it be tested by
handing it an image and reading pixels back, with no application behind it.

What it does own is everything that is a property of the *picture* rather than
of the document: the zoom (:data:`ZOOM_LEVELS`), the two grids and the screen
labels, the marks it is handed to stroke over the picture
(:class:`Overlay` -- geometry and colours, never a record), and which gesture a
press turned out to be (:data:`DRAG_THRESHOLD`, measured on the screen because
what it measures is a hand). None of that needs a level to be true of a
picture, which is why none of it is upstairs.

Zoom is a **ladder of fixed steps**, never a continuous scale: whole multiples
to magnify, and halvings below 1:1 to read a whole level at once. Nothing in
between, in either direction. A scale like 1.5 or a third lands source pixels on
uneven numbers of device pixels, so a row of identical tiles renders with
visibly uneven gutters; a whole multiple gives every source pixel the same size
as its neighbours, and a halving gives every *surviving* pixel the same size.
Halving is also the only reduction nearest-neighbour can do evenly - it keeps
one pixel in two, or one in four, rather than inventing an average of them.

Being powers of two, the fractional steps are exact in binary floating point, so
the geometry below is exact rather than merely close: the widget's size, the
mapping back to an image pixel and the grid's spacing all come out whole.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from enum import Enum
from math import ceil, floor

from PySide6.QtCore import QPoint, QPointF, QRect, QSize, Qt, Signal
from PySide6.QtGui import (
    QColor,
    QFont,
    QFontMetrics,
    QImage,
    QMouseEvent,
    QPainter,
    QPainterPath,
    QPaintEvent,
    QPen,
    QPolygonF,
)
from PySide6.QtWidgets import QWidget

# The zoom ladder, in device pixels per image pixel. Every step, no gaps: a
# level is thousands of pixels wide, so the useful range is the low end of it -
# 1x to see a whole level, 5x to place a single block - and a ladder that
# reached the magnifications a tile editor wants would spend most of its steps
# above anything the canvas is used for.
#
# The two reductions are what a *level* needs and a byte map does not: 4096
# pixels of level is wider than any window at 1:1, and at a quarter the whole of
# even the widest one fits on screen at once, which is the view its structure -
# where the ground runs, where the screens fall - is read in.
ZOOM_LEVELS: tuple[float, ...] = (0.25, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0)
DEFAULT_ZOOM = 4.0

# Where "Reset Zoom" goes: 1:1, one device pixel per image pixel. Reset means
# "put the picture back to what it actually is", and that is the only level on
# the ladder that neither magnifies nor drops pixels. It is also the level a
# whole screen of level is read at, which is what the reset is reached for after
# a magnified look at one corner of it.
RESET_ZOOM = 1.0


def zoom_level_after(zoom: float, steps: int = 0) -> float:
    """The level ``steps`` along the ladder from ``zoom``, clamped to its ends.

    Stepping walks the list rather than adding to the value, so the gap under 1
    is one step like every other and zooming out from 1x lands on 0.5x instead
    of on nothing. With ``steps`` left at zero this is the snap: an off-ladder
    number - a typed one, or a remembered one from a build with a different
    ladder - becomes the nearest level, the lower one when it falls exactly
    between two.
    """
    at = min(range(len(ZOOM_LEVELS)), key=lambda i: (abs(ZOOM_LEVELS[i] - zoom), i))
    return ZOOM_LEVELS[max(0, min(len(ZOOM_LEVELS) - 1, at + steps))]


# The app *talks* in percent - the control, the readout and the remembered
# preference are all "25%", "400%" - while the canvas *works* in the multiplier,
# because that is what every line of geometry below multiplies by. These two
# functions are the whole of the boundary between the two, and every level is a
# whole number of percent, so the round trip is lossless in both directions.


def as_percent(zoom: float) -> int:
    """A zoom multiplier as the percentage the app shows and stores."""
    return round(zoom * 100)


def from_percent(percent: int) -> float:
    """A percentage back to the multiplier the canvas scales by."""
    return percent / 100


# The neutral surround behind the image: a fixed mid-gray rather than a theme
# color, so it never biases how the artwork's own colors read. The canvas paints
# it wherever the widget is larger than the image.
CANVAS_BACKGROUND = QColor(0x80, 0x80, 0x80)

# The grid's two levels, by role rather than by size - which is what makes the
# lattice readable without being told what it is counting. A neutral light gray
# for the **fine** level (the unit being worked in) and a saturated blue for the
# **structural** one above it (the group that unit sits inside).
#
# Hue, not two opacities of white, is what separates a gridline from the artwork
# at a glance: white lines vanish into white pixels, which is most of what a
# bright sprite is, while nothing in a console palette reads as this blue.
GRID_FINE_COLOR = QColor(0xC8, 0xC8, 0xC8)
GRID_STRUCTURE_COLOR = QColor(0x00, 0x00, 0xFF)

# 1:1 and up. Below it the picture is being *reduced*, so a one-device-pixel
# line falls between cells that are no longer whole pixels apart: the lattice
# lands on rounded positions over pixels the rescale has already dropped, which
# reads as an uneven grid rather than as structure. Suppressed there rather than
# drawn into mush. At 1x and above every step of the ladder is a whole multiple,
# so the spacing comes out exact.
MIN_GRID_ZOOM = 1

# The screen grid is a different instrument from the lattice above and is drawn
# in a different key. A screen is 256 pixels of level rather than a unit of
# artwork, so its lines are sparse enough to be dark and translucent instead of
# bright: they mark a boundary the level data cares about without competing with
# the picture at any zoom. Each screen is labelled with its own number, because
# that number is what the object stream, the screen exits and the properties
# panel all count in - a boundary with no number on it leaves the reader
# counting screens by hand.
SCREEN_LINE_COLOR = QColor(33, 33, 33, 181)
SCREEN_LABEL_COLOR = QColor(255, 255, 255, 214)

# A screen carrying a note - a screen exit - is called out rather than merely
# labelled: the note is what makes that screen different from its neighbours.
SCREEN_NOTE_COLOR = QColor(239, 140, 41, 214)

# Label geometry, in device pixels and therefore the same size at every zoom.
# The number is a readout about the level, not part of the picture, so it should
# not grow with it - at 5x a label drawn in image pixels would be four times the
# height of a block.
LABEL_PADDING = 2
LABEL_POINT_SIZE = 8

# The hairline under a filled mark -- an `Overlay.wedge`. Black, because that is
# the understroke every stroked mark already wears here and in the tile palette:
# a fill of any hue lands on artwork of the same hue sooner or later, and the
# outline is what keeps its shape readable when it does.
MARK_OUTLINE = QColor(0x00, 0x00, 0x00)

# The wedge's smallest legs in device pixels, and how small it may get and
# still wear the outline: three pixels is the least that still reads as a
# triangle rather than as a dot, and under six the hairline is most of what
# is drawn.
WEDGE_FLOOR = 3.0
WEDGE_OUTLINED = 6.0

# The smallest radius a line's endcap is drawn at, in device pixels. A
# reducing zoom takes an `Overlay.line_cap` down with the picture like any
# other image-pixel extent, and under this it stops reading as a ring at the
# end of the line and becomes a thickening of it -- so this is where it stops
# shrinking.
CAP_FLOOR = 2.0

# How far the pointer has to travel, in **device** pixels, before a press stops
# being a click and becomes a drag.
#
# Device rather than image pixels, because what this measures is a hand: the
# wobble in a click is the same few pixels of desk whether the picture is
# magnified five times or reduced to a quarter, and a threshold in image pixels
# would be four times as forgiving at 4x as at 1x. It is also why the canvas
# owns the number at all - which gesture a press turned into is a fact about the
# pointer, not about the document.
DRAG_THRESHOLD = 4

#: The mouse's two side buttons, which mean Back and Forward everywhere a
#: browser is involved and mean nothing to the picture. Named here because the
#: canvas is where they have to be *declined*: an event a widget accepts stops
#: there, so the buttons only reach the window that walks the trail by being
#: left alone on the way past.
SIDE_BUTTONS = frozenset({Qt.MouseButton.BackButton, Qt.MouseButton.ForwardButton})


def label_box(
    metrics,  # noqa: ANN001 - Qt's QFontMetrics, passed through
    text: str,
    edge_x: int,
    edge_y: int,
    bottom: bool = False,
    right: bool = False,
) -> QRect:
    """Where :func:`draw_label` would put its box, in device pixels.

    Its own function because the box is also a *target*: a screen's label can
    be clicked, and the only thing that knows how big it is is the font it is
    drawn in. One piece of arithmetic, so what is drawn and what is aimed at
    cannot drift apart.
    """
    height = metrics.height()
    width = metrics.horizontalAdvance(text) + LABEL_PADDING * 2
    return QRect(
        edge_x - width if right else edge_x + 1,
        edge_y - height if bottom else edge_y + 1,
        width,
        height,
    )


def draw_label(
    painter: QPainter,
    text: str,
    edge_x: int,
    edge_y: int,
    fill: QColor,
    metrics=None,  # noqa: ANN001 - Qt's QFontMetrics, passed through
    bottom: bool = False,
    right: bool = False,
) -> None:
    """A filled text box just inside a corner, at the labels' fixed device
    size -- what the screen numbers draw, shared with the
    :attr:`Overlay.label` marks and with the same mark drawn into a list
    row's icon
    (:func:`shiny_mushroom.ui.overworld_transfers.mark_image`).

    ``edge_x`` and ``edge_y`` are the edges the box hangs from -- the
    rectangle's left and top, or with ``right`` and ``bottom`` its right and
    bottom. The box's own width and height are the font's and are only known
    here, which is why the corner is chosen here rather than by the caller
    passing a smaller rectangle.
    """
    if metrics is None:
        font = painter.font()
        font.setPointSize(LABEL_POINT_SIZE)
        painter.setFont(font)
        metrics = painter.fontMetrics()
    box = label_box(metrics, text, edge_x, edge_y, bottom=bottom, right=right)
    painter.fillRect(box, fill)
    painter.setPen(SCREEN_LABEL_COLOR)
    painter.drawText(box, Qt.AlignmentFlag.AlignCenter, text)


@dataclass(frozen=True)
class Overlay:
    """One rectangle stroked over the picture, in **image-pixel** coordinates.

    The canvas is handed geometry, never a model: a box is a rectangle and a
    colour, and what it stands for - an object, a sprite, the selection - is the
    caller's business. That is what keeps the canvas testable by handing it
    rectangles and reading pixels back, and what lets the same three fields
    carry every overlay the editor draws.

    The line never scales with the zoom -- **one device pixel** unless
    :attr:`width` says otherwise. An overlay is a readout about the picture
    rather than part of it: at 4x a line scaled with the artwork would be four
    pixels of furniture over every object in the level, and at a quarter it
    would be three quarters of a pixel, which nearest-neighbour renders as
    nothing at all.

    ``dash`` is in image pixels and *is* scaled, so a magnified overlay keeps
    the rhythm it has at 1:1 - but it is not allowed to scale away, and stays
    legible at the reducing zooms. ``inset`` is in device pixels and is not
    scaled at all: it separates two lines of one mark, which is a fact about
    lines rather than about the picture.
    """

    rect: QRect
    color: QColor
    #: Run length of the dashes, or 0 for a solid line.
    dash: int = 0
    #: The stroke's width in **device pixels** -- like the line itself it does
    #: not scale with the picture, and the default is the one-pixel line every
    #: other overlay draws. A wider stroke under a narrower one is how an
    #: arrow gets the halo the ants get from their two lines.
    width: float = 1.0
    #: A direction to draw as a small arrow instead of stroking :attr:`rect`:
    #: shaft and open head filling the rectangle, pointing along this
    #: ``(dx, dy)`` vector, antialiased -- vector art in the overlay's key,
    #: not artwork's. Still geometry: what the arrow *means*, and which way
    #: is worth pointing, is the caller's business.
    arrow: tuple[float, float] | None = None
    #: A segment to draw instead of stroking :attr:`rect`: this ``(dx, dy)``
    #: extent in **image pixels**, centred in the rectangle, antialiased at
    #: the overlay's fixed stroke weight. The extent scales with the picture
    #: the way the rectangle does, so a diagonal drawn at 1:1 stays that
    #: diagonal at every zoom.
    line: tuple[float, float] | None = None

    #: A filled right triangle to draw in :attr:`rect`'s top-right corner
    #: instead of stroking it: this leg length in **image pixels**, scaled
    #: with the picture the way :attr:`line` is and held to a floor so a
    #: reduced map keeps a mark rather than a speck. Filled in :attr:`color`
    #: over a black outline, the understroke every other mark wears. A corner
    #: rather than the middle, where a mark sits over the artwork itself.
    #: Still geometry: what the wedge *means* is the caller's business.
    wedge: float = 0.0

    #: How a :attr:`line` ends: a ring of this radius in **image pixels**
    #: around the segment's far end -- the ``(dx, dy)`` end, not the one it
    #: starts from -- in the same stroke of the same pen. An **endcap**, not a
    #: second mark: one overlay draws both, so the ring is where the line
    #: stops rather than something drawn near where it stops.
    #:
    #: The radius scales with the picture the way :attr:`line` does, and is
    #: held to :data:`CAP_FLOOR` so a reduced picture keeps a ring rather than
    #: a blot. Ignored without a :attr:`line` to end. Still geometry: what
    #: the line and its end stand for is the caller's business.
    line_cap: float = 0.0

    #: Text to draw instead of stroking :attr:`rect`: a small filled box in
    #: the rectangle's top-left corner, in the screen labels' treatment and
    #: at their fixed device size -- a readout about the spot, not artwork.
    #: :attr:`color` fills the box. What the text says is the caller's
    #: business, exactly as a screen note's is.
    label: str = ""
    #: Which corner the :attr:`label` sits in: the rectangle's top-left, or
    #: the corner these two move it to. Several readouts about one rectangle
    #: have to sit at different corners to all be read, and a corner is
    #: where a label hides the least of what it is a readout about.
    label_bottom: bool = False
    label_right: bool = False
    #: How far inside ``rect`` to draw, in **device pixels** -- which is how a
    #: two-tone outline is drawn: the same rectangle twice, an inset of one
    #: putting the second line immediately inside the first.
    #:
    #: Device rather than image pixels, and so **not** scaled, for the reason
    #: the line itself is not: the two lines are one mark, and a gap between
    #: them that grows with the zoom turns a hairline understroke into a band
    #: of artwork with a stripe on either side.
    inset: int = 0

    #: Blocks to trace the outline *of*, instead of stroking :attr:`rect`. Given
    #: them, the canvas strokes the boundary of their union: interior edges
    #: cancel, so an L-shaped object is outlined as an L and a slope as a slope
    #: rather than as the box that contains them both. :attr:`rect` is still the
    #: bounding box, and is what culling uses.
    #:
    #: Still geometry and still no model: these are rectangles, and what they add
    #: up to is the caller's business.
    cells: tuple[QRect, ...] = ()

    #: A picture to draw into :attr:`rect`, under the line, at the same
    #: nearest-neighbour scale the canvas draws everything else at.
    #:
    #: Still no model. This is pixels and a rectangle to put them in, exactly as
    #: :meth:`Canvas.set_image` is -- what the picture is *of* is the caller's
    #: business, and the canvas cannot tell a ghosted object from a sprite from
    #: an arbitrary bitmap.
    #:
    #: :attr:`opacity` is what makes it read as a ghost rather than as part of
    #: the level, and it is the caller's number for the same reason the colours
    #: are.
    image: QImage | None = None
    opacity: float = 1.0


class GridMode(Enum):
    """What the grid counts. ``value`` is the stable string persisted in app
    settings."""

    OFF = "off"
    TILE = "tile"  # 8x8, the console's native tile
    BLOCK = "block"  # 16x16, four tiles - what the game's level data addresses

    @property
    def levels(self) -> tuple[tuple[int, QColor], ...]:
        """The lattices to draw, as ``(cell side in image pixels, color)``, in
        paint order.

        Coarsest last: where two levels coincide the structural line is the one
        that has to survive, and painting it over the fine one is cheaper than
        skipping those cells in the fine pass.
        """
        if self is GridMode.BLOCK:
            return ((8, GRID_FINE_COLOR), (16, GRID_STRUCTURE_COLOR))
        if self is GridMode.TILE:
            return ((8, GRID_FINE_COLOR),)
        return ()


class Canvas(QWidget):
    """Paints an image at a zoom off the ladder, with an optional two-level
    grid."""

    #: The mouse moved over image pixel ``(x, y)``. Not emitted while the cursor
    #: is over the surround, so a reader can treat every emission as a real
    #: coordinate rather than re-checking bounds.
    cursor_moved = Signal(QPoint)
    #: The mouse left the image (either the widget or just the painted area).
    cursor_left = Signal()
    #: A button was pressed and released on image pixel ``(x, y)`` without the
    #: pointer travelling far enough to be a drag, with the modifiers held at the
    #: press.
    #:
    #: The modifiers are part of the gesture rather than something the listener
    #: fetches afterwards: by the time a click is handled the key may have been
    #: let go, and a shift-click that arrives as a plain one replaces a selection
    #: instead of adding to it. What shift *means* is still nothing to do with
    #: the canvas.
    clicked = Signal(QPoint, Qt.KeyboardModifier)
    #: A press travelled far enough to be a drag. Carries where it **began** -
    #: not where the pointer is now - because that is the point the gesture is
    #: measured from, and by the time the threshold is crossed the press is
    #: several pixels in the past.
    drag_begun = Signal(QPoint, Qt.KeyboardModifier)
    #: The drag reached image pixel ``(x, y)``, clamped into the picture so a
    #: gesture that leaves it still has somewhere to be.
    drag_moved = Signal(QPoint)
    #: The drag ended there. Always follows a :attr:`drag_begun`, so a listener
    #: can hold state between the two without checking whether it is in one.
    drag_ended = Signal(QPoint)
    #: The **middle** button was pressed on image pixel ``(x, y)``.
    #:
    #: Its own signal rather than a button argument on :attr:`clicked`, because
    #: what the two mean has nothing in common: a left click is about the
    #: document and this one is about a test run. Keeping them apart is also
    #: what lets everything already listening to `clicked` stay unchanged.
    middle_clicked = Signal(QPoint, Qt.KeyboardModifier)
    #: The **right** button was pressed: on image pixel ``(x, y)``, or on the
    #: surround with ``None`` for the pixel. The second point is where it was
    #: pressed in **widget** coordinates, which is where a menu is anchored.
    #:
    #: Reported wherever it lands, because part of what it says means the same
    #: thing everywhere: "put down whatever is in hand" cancels a placement
    #: from the gray as well as from over the level. With nothing in hand it
    #: asks for the context menu, and that is why it carries a place -- the
    #: menu is about what is under the pointer.
    right_clicked = Signal(object, QPoint)
    #: A button was pressed **off** the picture - on the gray the image is
    #: surrounded by, or on the sliver of widget a fractional zoom leaves beyond
    #: its last column.
    #:
    #: No position, because there is nothing there to have a position in: what
    #: the surround says is "not the level", which is what makes it the place to
    #: click to mean nothing in particular. The modifiers come along because a
    #: shift-press on the surround still begins a gesture - a marquee dragged in
    #: from outside the level is an ordinary way to catch its first column.
    clicked_away = Signal(Qt.KeyboardModifier)
    #: A screen's own number box was clicked, while the labels are targets --
    #: see :meth:`set_screens_selectable`. Its own signal rather than a
    #: :attr:`clicked` on the pixel underneath, because the two say different
    #: things: the picture is the level's artwork, and the box in its corner is
    #: a handle on the *screen*, which is what an exit is indexed by.
    screen_clicked = Signal(int)
    #: A screen's number box was **double** clicked, while the labels are
    #: targets. The box is the screen's handle, and double clicking a handle is
    #: the ordinary way to say "open what this names" -- what a screen names,
    #: and whether it names anything at all, being the document's business
    #: rather than the picture's.
    screen_activated = Signal(int)
    #: The zoom settled on a new level. Anything displaying the zoom listens for
    #: this rather than reading it back after calling a zoom method: the canvas
    #: snaps and clamps what it is given, so the caller's number is not
    #: necessarily the one in effect, and a caller that never went through the
    #: window at all would leave a readout stale.
    zoom_changed = Signal(float)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._image = QImage()
        self._zoom = DEFAULT_ZOOM
        self._grid = GridMode.OFF
        # A screen is a property of the picture, not of the document: the canvas
        # is told how big the cells are and what to write in them, and never
        # what a screen means. An invalid size is "this picture has none",
        # which is the byte map's answer.
        self._screen = QSize()
        self._screen_notes: dict[int, str] = {}
        self._screen_labels = True
        self._screens_selectable = False
        self._show_screens = False
        self._overlays: tuple[Overlay, ...] = ()
        # The gesture in progress: where the left button went down, in widget
        # coordinates, what was held with it, and whether it has travelled far
        # enough to be a drag. All of it is cleared on release, so "no press"
        # is one state rather than several that can disagree.
        self._press: QPoint | None = None
        # And where it went down in the *picture*, resolved at the press rather
        # than at the release -- refused off the picture, and clamped into it
        # for the drag that must answer either way. Resolved then because the
        # zoom can change under a held button, Ctrl+wheel, and a widget position
        # mapped through the new one names a block nobody pressed.
        self._press_at: QPoint | None = None
        self._press_within = QPoint()
        self._modifiers = Qt.KeyboardModifier.NoModifier
        self._dragging = False
        # Hover coordinates arrive only with a button held unless tracking is on,
        # and the status bar has to follow a bare cursor.
        self.setMouseTracking(True)
        # paintEvent fills its whole exposed rect before doing anything else, so
        # Qt can skip erasing the widget first - one less full-width fill per
        # repaint, and no flicker between the erase and the image.
        self.setAttribute(Qt.WidgetAttribute.WA_OpaquePaintEvent, True)
        self._resize()

    # -- what is shown ------------------------------------------------------

    @property
    def image(self) -> QImage:
        return self._image

    def set_image(self, image: QImage) -> None:
        """Show ``image``. An empty image clears the canvas."""
        self._image = image
        self._resize()
        self.update()

    @property
    def zoom(self) -> float:
        return self._zoom

    def set_zoom(self, zoom: float) -> None:
        """Set the zoom, snapped to the nearest level on :data:`ZOOM_LEVELS`."""
        zoom = zoom_level_after(zoom)
        if zoom == self._zoom:
            return
        self._zoom = zoom
        self._resize()
        self.update()
        self.zoom_changed.emit(zoom)

    def zoom_in(self) -> None:
        self.set_zoom(zoom_level_after(self._zoom, +1))

    def zoom_out(self) -> None:
        self.set_zoom(zoom_level_after(self._zoom, -1))

    @property
    def overlays(self) -> tuple[Overlay, ...]:
        return self._overlays

    def set_overlays(self, overlays: Sequence[Overlay]) -> None:
        """Stroke ``overlays`` over the picture, replacing whatever was there.

        The whole set at once, in paint order, because that is how the caller
        thinks about them: which box wins where two coincide is a decision about
        what they mean, and the canvas has no way to make it.

        Cheap enough to re-send on every selection change - the picture itself is
        untouched, so nothing is re-rendered and nothing is copied.
        """
        self._overlays = tuple(overlays)
        self.update()

    @property
    def grid(self) -> GridMode:
        return self._grid

    def set_grid(self, mode: GridMode) -> None:
        if mode is self._grid:
            return
        self._grid = mode
        self.update()

    # -- screens ------------------------------------------------------------

    @property
    def screen_size(self) -> QSize:
        """The screen cell in image pixels, or an invalid size for none."""
        return self._screen

    def set_screen_size(self, size: QSize, labels: bool = True) -> None:
        """Divide the picture into cells of ``size`` for the screen grid.

        Cells are numbered left to right, then top to bottom - which is the
        level's own numbering either way round, because a level is one cell tall
        when it runs sideways and one cell wide when it runs down.

        ``labels`` is whether each cell carries that number in its corner. A
        picture whose cells are not screens -- a stamp sheet's blocks -- wants
        the same division without the counting, and says so here rather than
        leaving a number nobody addresses anything by over the artwork.
        """
        self._screen = size
        self._screen_labels = labels
        self.update()

    @property
    def screen_labels(self) -> bool:
        """Whether a cell of the screen grid carries its number."""
        return self._screen_labels

    @property
    def screens(self) -> bool:
        return self._show_screens

    def set_screens(self, shown: bool) -> None:
        if shown is self._show_screens:
            return
        self._show_screens = shown
        self.update()

    @property
    def screen_notes(self) -> dict[int, str]:
        """What each noted screen says, by screen number -- a copy, so a
        reader cannot edit the canvas's own."""
        return dict(self._screen_notes)

    def set_screen_notes(self, notes: dict[int, str]) -> None:
        """Extra text for particular screens, by screen number.

        A noted screen's label is called out in :data:`SCREEN_NOTE_COLOR`. What
        is worth noting is the caller's business; the canvas only knows that
        some screens have something to say.
        """
        self._screen_notes = dict(notes)
        self.update()

    @property
    def screens_selectable(self) -> bool:
        """Whether a click on a screen's number box is a gesture."""
        return self._screens_selectable

    def set_screens_selectable(self, selectable: bool) -> None:
        """Make the screen labels targets: a click on one emits
        :attr:`screen_clicked` and reaches nothing under it.

        Off by default, and it has to be asked for rather than assumed. A label
        sits over the top-left corner of every screen, which is a part of the
        picture like any other -- so an environment that has nothing to say
        about a screen must keep those pixels clickable, or a level would have
        sixteen small holes in it where a gesture goes nowhere.
        """
        self._screens_selectable = selectable

    def screen_at_label(self, pos: QPoint) -> int | None:
        """Which screen's number box covers widget position ``pos``, or
        ``None`` -- for a position on no box, and for a picture whose labels
        are not being drawn at all.

        Measured from the same font and the same arithmetic that draws them
        (:func:`label_box`), because a target the eye cannot see is worse than
        no target: the box is only a handle if it is exactly the thing that
        looks like one.
        """
        if not (self._show_screens and self._screen_labels and self._screen.isValid()):
            return None
        if not self.rect().contains(pos):
            return None
        step_x = max(1, round(self._screen.width() * self._zoom))
        step_y = max(1, round(self._screen.height() * self._zoom))
        left = (pos.x() // step_x) * step_x
        top = (pos.y() // step_y) * step_y
        screen = (top // step_y) * self._screens_across(step_x) + left // step_x
        box = label_box(
            self._label_metrics(), self._screen_label_text(screen), left, top
        )
        return screen if box.contains(pos) else None

    def _screens_across(self, step_x: int) -> int:
        """Screens per row of the picture, which is how a cell's column and row
        become the one number the level counts in."""
        return max(1, -(-self.width() // step_x))

    def _label_metrics(self) -> QFontMetrics:
        """The font the labels are drawn in, measured. The widget's own at the
        labels' fixed point size -- what a painter would hand back, asked for
        without one."""
        font = QFont(self.font())
        font.setPointSize(LABEL_POINT_SIZE)
        return QFontMetrics(font)

    def _screen_label_text(self, screen: int) -> str:
        """What one screen's box says: its number, and its note where it has
        one."""
        note = self._screen_notes.get(screen)
        return f"{screen:02X}" if note is None else f"{screen:02X} {note}"

    # -- geometry -----------------------------------------------------------

    def _resize(self) -> None:
        """Re-fix the widget to the image's size at the current zoom.

        Fixed, not a size *hint*: the scroll area sizes its scrollbars from the
        widget's actual geometry, and a hint alone leaves the canvas stretched to
        the viewport with the image floating in a corner.

        Rounded **up**, which only matters at a reducing zoom: half of an odd
        width is not a whole number of device pixels, and rounding down would
        leave the image's last column with nowhere to be drawn.
        """
        self.setFixedSize(
            QSize(
                max(1, ceil(self._image.width() * self._zoom)),
                max(1, ceil(self._image.height() * self._zoom)),
            )
        )

    def image_pos(self, pos: QPoint) -> QPoint | None:
        """Map a widget position to an image pixel, or ``None`` if it is outside
        the painted area.

        At a reducing zoom several image pixels share one device pixel, and this
        answers with the first of them - the one actually painted there, since
        nearest-neighbour keeps that one and drops the rest.
        """
        x, y = floor(pos.x() / self._zoom), floor(pos.y() / self._zoom)
        if 0 <= x < self._image.width() and 0 <= y < self._image.height():
            return QPoint(x, y)
        return None

    def image_pos_within(self, pos: QPoint) -> QPoint:
        """The same, held inside the picture instead of refused.

        What a *drag* needs, and the reason the two are separate: a press has to
        be able to say "not on the level", while a gesture already under way has
        to keep answering after the pointer has left it. Dragging a selection
        box off the right-hand edge should catch the last column, not stop.

        An empty image has no pixel to clamp to, and answers with its origin.
        """
        return QPoint(
            max(0, min(self._image.width() - 1, floor(pos.x() / self._zoom))),
            max(0, min(self._image.height() - 1, floor(pos.y() / self._zoom))),
        )

    def _device_rect(self, source: QRect) -> QRect:
        """A rectangle of image pixels, as the device rectangle it covers.

        Each edge is rounded on its own and the far one is derived from the near
        one, so a fractional zoom cannot round one rectangle's width up while its
        neighbour's near edge rounds down and leave a seam between two repaints.
        """
        left = round(source.left() * self._zoom)
        top = round(source.top() * self._zoom)
        return QRect(
            left,
            top,
            round((source.left() + source.width()) * self._zoom) - left,
            round((source.top() + source.height()) * self._zoom) - top,
        )

    # -- painting -----------------------------------------------------------

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        painter.fillRect(event.rect(), CANVAS_BACKGROUND)
        if self._image.isNull():
            return
        # Nearest-neighbour, stated rather than assumed. Qt's default happens to
        # be off, but a smoothed upscale of pixel art is wrong in a way that is
        # easy to introduce and hard to notice in a screenshot, so the canvas
        # does not rely on the default staying put. It is also what makes the
        # reducing levels honest: half a picture of pixel art is every other
        # pixel of it, not an average that shows colours the artwork never had.
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        # Draw only the exposed region, scaled from the source rectangle it came
        # from. Blitting the whole image on every partial repaint costs the full
        # rescale for a few dirty rows.
        target = event.rect().intersected(self.rect())
        source = QRect(
            floor(target.left() / self._zoom),
            floor(target.top() / self._zoom),
            ceil(target.width() / self._zoom) + 1,
            ceil(target.height() / self._zoom) + 1,
        ).intersected(self._image.rect())
        painter.drawImage(self._device_rect(source), self._image, source)
        if self._zoom >= MIN_GRID_ZOOM:
            self._draw_grid(painter, target)
        if self._show_screens and self._screen.isValid():
            self._draw_screens(painter, target)
        # Last, over both grids: an overlay marks one particular thing in the
        # level, and a lattice line through the box around it would read as part
        # of the box.
        if self._overlays:
            self._draw_overlays(painter, target)

    def _draw_grid(self, painter: QPainter, area: QRect) -> None:
        """Draw the current mode's lattices over the exposed rect."""
        for cell, color in self._grid.levels:
            # Whole device pixels: the lattice is only drawn from 1x up, where
            # the zoom is a whole multiple, but a line is placed by counting and
            # counting is done in integers.
            step = round(cell * self._zoom)
            painter.setPen(QPen(color, 1))
            self._draw_lattice(painter, area, step, step)

    def _draw_lattice(
        self, painter: QPainter, area: QRect, step_x: int, step_y: int
    ) -> None:
        """Rule the exposed rect every ``step_x`` and ``step_y`` device pixels,
        in whatever pen the painter is holding.

        Starts at the first line inside ``area`` rather than at zero: on a large
        image most of the lattice is scrolled out of view. The lines *on* the
        widget's own edges are skipped -- there is nothing on the far side of
        one to separate it from.
        """
        width, height = self.width(), self.height()
        for x in range(area.left() - area.left() % step_x, area.right() + 1, step_x):
            if 0 < x < width:
                painter.drawLine(x, area.top(), x, area.bottom())
        for y in range(area.top() - area.top() % step_y, area.bottom() + 1, step_y):
            if 0 < y < height:
                painter.drawLine(area.left(), y, area.right(), y)

    def _draw_overlays(self, painter: QPainter, area: QRect) -> None:
        """Stroke each overlay's rectangle over the exposed rect.

        Pens are one device pixel wide and are never scaled, which is the whole
        point of drawing these here rather than into the picture: an outline
        painted into the image at 1:1 loses three quarters of itself the moment
        the picture is drawn at a quarter, and the zoom that fits a whole level
        on screen is exactly the one an object box is wanted at.
        """
        for overlay in self._overlays:
            # Device pixels, unscaled: an inset separates the two lines of one
            # mark, and a magnified gap between them is not that mark magnified.
            inset = overlay.inset
            # Qt strokes a rectangle *through* the far edge of the QRect it is
            # given, one pixel past the box; taking that pixel back keeps the
            # outline inside the thing it is outlining.
            rect = self._device_rect(overlay.rect).adjusted(
                inset, inset, -inset - 1, -inset - 1
            )
            if rect.width() < 0 or rect.height() < 0 or not rect.intersects(area):
                continue
            if overlay.image is not None and not overlay.image.isNull():
                # Under the line, so an outline is never half-hidden by the
                # picture it surrounds. Nearest-neighbour and stated, for the
                # reason `paintEvent` states it for the level itself.
                painter.setOpacity(overlay.opacity)
                painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
                painter.drawImage(self._device_rect(overlay.rect), overlay.image)
                painter.setOpacity(1.0)
            if overlay.label:
                draw_label(
                    painter,
                    overlay.label,
                    rect.right() if overlay.label_right else rect.left(),
                    rect.bottom() if overlay.label_bottom else rect.top(),
                    overlay.color,
                    bottom=overlay.label_bottom,
                    right=overlay.label_right,
                )
                continue
            pen = QPen(overlay.color, overlay.width)
            if overlay.dash:
                # In pen widths, which is device pixels here, so the pattern is
                # the same rhythm wherever the picture is scrolled to.
                dash = self._overlay_scale(overlay.dash, floor=2)
                pen.setDashPattern((dash, dash))
                pen.setCapStyle(Qt.PenCapStyle.FlatCap)
            painter.setPen(pen)
            if overlay.wedge:
                self._draw_wedge(
                    painter,
                    overlay.wedge * self._zoom,
                    self._device_rect(overlay.rect),
                    overlay.color,
                )
            elif overlay.arrow is not None:
                self._draw_arrow(
                    painter, overlay.arrow, self._device_rect(overlay.rect)
                )
            elif overlay.line is not None:
                self._draw_segment(
                    painter, overlay.line, overlay.rect, overlay.line_cap
                )
            elif overlay.cells:
                painter.drawPath(self._outline_of(overlay.cells))
            else:
                painter.drawRect(rect)

    def _draw_segment(
        self,
        painter: QPainter,
        extent: tuple[float, float],
        rect: QRect,
        cap: float = 0.0,
    ) -> None:
        """A straight stroke of ``extent`` image pixels through ``rect``'s
        centre -- an :attr:`Overlay.line` -- ending in a ring of ``cap``
        image pixels where it stops.

        Antialiased for the arrow's reason: most of what this draws is
        diagonal. The ring is drawn here, in the pen and the pass the line
        is, because it is the line's **end** rather than a mark beside it:
        the two share a centre by construction, and nothing can order them
        apart or give one a colour the other has not got.
        """
        device = self._device_rect(rect)
        center = QPointF(
            device.x() + device.width() / 2, device.y() + device.height() / 2
        )
        half_x = extent[0] * self._zoom / 2
        half_y = extent[1] * self._zoom / 2
        pen = painter.pen()
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)
        painter.setPen(pen)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)
        far = QPointF(center.x() + half_x, center.y() + half_y)
        painter.drawLine(QPointF(center.x() - half_x, center.y() - half_y), far)
        if cap:
            reach = max(CAP_FLOOR, cap * self._zoom)
            painter.setBrush(Qt.BrushStyle.NoBrush)
            painter.drawEllipse(far, reach, reach)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, False)

    @staticmethod
    def _draw_wedge(
        painter: QPainter, reach: float, rect: QRect, color: QColor
    ) -> None:
        """A filled right triangle in ``rect``'s top-right corner, its legs
        ``reach`` device pixels long -- an :attr:`Overlay.wedge`.

        The same treatment the tile palette paints into a thumbnail's corner,
        so one shape means one thing in both keys: the fill over a hairline
        black outline, which is what keeps it read over artwork of any
        colour. Antialiased for the arrow's reason -- the hypotenuse is a
        diagonal.

        Held to a floor so a reduced map keeps a mark rather than a speck --
        and the outline goes at that size, where a hairline around three
        pixels of triangle is most of the triangle: what has to survive the
        reducing zooms is the hue, not the edge around it.
        """
        reach = max(WEDGE_FLOOR, min(reach, rect.width(), rect.height()))
        right, top = rect.right() + 1.0, float(rect.top())
        wedge = QPolygonF(
            [
                QPointF(right - reach, top),
                QPointF(right, top),
                QPointF(right, top + reach),
            ]
        )
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)
        painter.setPen(
            QPen(MARK_OUTLINE, 1.0) if reach >= WEDGE_OUTLINED else Qt.PenStyle.NoPen
        )
        painter.setBrush(color)
        painter.drawPolygon(wedge)
        painter.setBrush(Qt.BrushStyle.NoBrush)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, False)

    @staticmethod
    def _draw_arrow(
        painter: QPainter, direction: tuple[float, float], rect: QRect
    ) -> None:
        """A small vector arrow filling ``rect``: a shaft with an open head,
        pointing along ``direction``.

        Antialiased, unlike the rectangle strokes: a diagonal head stroke
        aliases into stairsteps at the one-pixel weights overlays draw at,
        where a rectangle's axis-aligned lines cannot. The geometry scales
        with the picture -- the rect is image pixels like every overlay's --
        while the stroke keeps the overlay's fixed weight, which is what
        makes it read as a mark about the map rather than pixels in it.
        """
        dx, dy = direction
        length = (dx * dx + dy * dy) ** 0.5
        if not length:
            return
        dx, dy = dx / length, dy / length
        center = QPointF(rect.x() + rect.width() / 2, rect.y() + rect.height() / 2)
        # Held to a floor so the reducing zooms leave a mark, not a speck.
        half = max(2.5, min(rect.width(), rect.height()) / 2)
        tip = QPointF(center.x() + dx * half, center.y() + dy * half)
        pen = painter.pen()
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)
        painter.setPen(pen)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)
        painter.drawLine(QPointF(center.x() - dx * half, center.y() - dy * half), tip)
        # The head: the tip's two strokes, swept 45 degrees back from it.
        sweep = half * 0.65
        for side in (-1.0, 1.0):
            painter.drawLine(
                tip,
                QPointF(
                    tip.x() + (-dx + side * dy) * sweep,
                    tip.y() + (-dy - side * dx) * sweep,
                ),
            )
        painter.setRenderHint(QPainter.RenderHint.Antialiasing, False)

    def _outline_of(self, cells: tuple[QRect, ...]) -> QPainterPath:
        """The boundary of a set of blocks, in device pixels.

        United as a path rather than stroked cell by cell, so the edges two
        neighbouring blocks share are not drawn: a run of forty ledge blocks is
        one outline, not forty boxes. ``simplified`` is what merges them.

        The line lands on the union's outer edge rather than one pixel inside
        it, unlike a rectangle overlay -- which is the right reading for an
        outline that surrounds a region rather than marking one rectangle.
        """
        path = QPainterPath()
        for cell in cells:
            path.addRect(self._device_rect(cell))
        return path.simplified()

    def _overlay_scale(self, length: int, floor: int = 1) -> int:
        """An overlay length in image pixels, in device pixels.

        Scaled with the picture so a magnified overlay keeps its proportions,
        but never below ``floor``: the reducing zooms would otherwise round a
        dash away to nothing, which is the failure this whole path exists to
        avoid.
        """
        return max(floor, round(length * self._zoom)) if length else 0

    def _draw_screens(self, painter: QPainter, area: QRect) -> None:
        """Draw the screen boundaries, and their numbers if the cells carry
        them, over the exposed rect.

        Not suppressed at low zoom, unlike the lattice: one line every 256
        pixels of level is still sparse at a quarter, and the zooms that fit a
        whole level on screen are exactly where its boundaries matter most.
        """
        # A screen is 256 pixels, so even the quarter step leaves 64 device
        # pixels between lines - room for the label, and never the zero that
        # would make the counting below a division by nothing.
        step_x = max(1, round(self._screen.width() * self._zoom))
        step_y = max(1, round(self._screen.height() * self._zoom))

        painter.setPen(QPen(SCREEN_LINE_COLOR, 1))
        self._draw_lattice(painter, area, step_x, step_y)
        if not self._screen_labels:
            return

        across = self._screens_across(step_x)
        font = painter.font()
        font.setPointSize(LABEL_POINT_SIZE)
        painter.setFont(font)
        metrics = painter.fontMetrics()
        lefts = range(area.left() - area.left() % step_x, area.right() + 1, step_x)
        tops = range(area.top() - area.top() % step_y, area.bottom() + 1, step_y)
        for left in lefts:
            for top in tops:
                screen = (top // step_y) * across + left // step_x
                self._draw_screen_label(painter, metrics, screen, left, top)

    def _draw_screen_label(
        self, painter: QPainter, metrics, screen: int, left: int, top: int
    ) -> None:
        """One screen's number, in a filled box in its top-left corner.

        The box sits just inside the boundary rather than on it, so the line and
        the label read as one object without the label hiding the corner the
        eye is using to place it.
        """
        note = self._screen_notes.get(screen)
        draw_label(
            painter,
            self._screen_label_text(screen),
            left,
            top,
            SCREEN_LINE_COLOR if note is None else SCREEN_NOTE_COLOR,
            metrics=metrics,
        )
        painter.setPen(QPen(SCREEN_LINE_COLOR, 1))

    # -- input --------------------------------------------------------------

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        self.move_to(event.position().toPoint())

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        # The two side buttons are nobody's here: they walk the trail, which is
        # the window's, and are left *ignored* so Qt carries them up to it
        # rather than stopping them on the picture.
        if event.button() in SIDE_BUTTONS:
            event.ignore()
            return
        self.press_at(event.position().toPoint(), event.button(), event.modifiers())

    def mouseDoubleClickEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        # Declined here for the reason a press is, and it is the *second* tap
        # of a hurried pair that arrives as this: swallowing it would make the
        # second one go nowhere.
        if event.button() in SIDE_BUTTONS:
            event.ignore()
            return
        self.double_click_at(
            event.position().toPoint(), event.button(), event.modifiers()
        )

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        self.release_at(event.position().toPoint())

    # The three below are public because the widget is not the whole surface: the
    # canvas is exactly as big as its image, so the gray around a level belongs
    # to the view, which hands gestures made there to these in the canvas's own
    # coordinates. One surface, and one place that decides what a press, a drag
    # and a release on it amount to.

    def press_at(
        self,
        pos: QPoint,
        button: Qt.MouseButton,
        modifiers: Qt.KeyboardModifier = Qt.KeyboardModifier.NoModifier,
    ) -> None:
        """Begin a gesture at widget position ``pos``, wherever it was made.

        Nothing is emitted yet for a left press, because what it *is* is not
        known until it ends: a press that stays put is a click and one that
        travels is a drag, and the difference is only visible in hindsight. The
        other two buttons have no such ambiguity and are reported at once.

        A middle click off the picture is dropped rather than reported: it names
        a place to put something, and there is no place out there. A right press
        is reported wherever it lands, with no pixel when it has none: putting
        something down means the same thing everywhere.
        """
        if button == Qt.MouseButton.MiddleButton:
            image = self.image_pos(pos)
            if image is not None:
                self.middle_clicked.emit(image, modifiers)
            return
        if button == Qt.MouseButton.RightButton:
            self.right_clicked.emit(self.image_pos(pos), pos)
            return
        if button != Qt.MouseButton.LeftButton:
            return
        self._press = pos
        self._press_at = self.image_pos(pos)
        self._press_within = self.image_pos_within(pos)
        self._modifiers = modifiers
        self._dragging = False

    def double_click_at(
        self,
        pos: QPoint,
        button: Qt.MouseButton = Qt.MouseButton.LeftButton,
        modifiers: Qt.KeyboardModifier = Qt.KeyboardModifier.NoModifier,
    ) -> None:
        """The second click of a double click, at widget position ``pos``.

        Only the number boxes answer to it, and only while they are targets: a
        box is a handle on its screen, and a double click on a handle opens
        what the handle names. The click that came first has already held the
        screen, so the pair reads as one gesture -- hold it, then go where it
        leads.

        Everywhere else the second click is another click, which is what Qt
        makes it by default and what a repeated placement or a repeated
        selection needs it to stay.
        """
        if button == Qt.MouseButton.LeftButton and self._screens_selectable:
            screen = self.screen_at_label(pos)
            if screen is not None:
                self.screen_activated.emit(screen)
                return
        self.press_at(pos, button, modifiers)

    def move_to(self, pos: QPoint) -> None:
        """Follow the pointer to widget position ``pos``.

        Two things at once, because one movement is both: the hover readout
        every listener already had, and the drag that a held button turns it
        into. A drag begins the moment the pointer has travelled
        :data:`DRAG_THRESHOLD`, and from then on the position is **clamped into
        the picture** -- a marquee dragged past the edge of the level should
        reach the edge rather than stop reporting.
        """
        image = self.image_pos(pos)
        if image is None:
            self.cursor_left.emit()
        else:
            self.cursor_moved.emit(image)
        if self._press is None:
            return
        if not self._dragging:
            travelled = pos - self._press
            if max(abs(travelled.x()), abs(travelled.y())) < DRAG_THRESHOLD:
                return
            self._dragging = True
            self.drag_begun.emit(self._press_within, self._modifiers)
        self.drag_moved.emit(self.image_pos_within(pos))

    def release_at(self, pos: QPoint) -> None:
        """End the gesture: a drag if it travelled, and a click if it did not."""
        press, dragging, image = self._press, self._dragging, self._press_at
        self._press, self._press_at, self._dragging = None, None, False
        if press is None:
            return
        if dragging:
            self.drag_ended.emit(self.image_pos_within(pos))
            return
        # A click is reported from where it was *pressed*, not released: within
        # the threshold the two are the same block anyway, and the press is the
        # position the person aimed at.
        if self._screens_selectable:
            screen = self.screen_at_label(press)
            if screen is not None:
                self.screen_clicked.emit(screen)
                return
        if image is None:
            self.clicked_away.emit(self._modifiers)
        else:
            self.clicked.emit(image, self._modifiers)

    def leaveEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        self.cursor_left.emit()
        super().leaveEvent(event)
