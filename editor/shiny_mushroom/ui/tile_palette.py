"""The world map's tile palette: what can be placed, one of which is in hand.

The create panel's little sibling and the offer dock's second page
(:mod:`shiny_mushroom.ui.offer_dock`), under the same contract: it emits
:attr:`TilePalette.armed` with what was picked, and that is all it does.
It does not place anything, does not hold a document, and does not know a
canvas exists -- what a click on the map *means* belongs to whoever owns the
world map document.

Six tabs. Five are placeable parts of the map. **Layer 1** is the
overworld's 193 Map16 tiles, a fixed grid of thumbnails handed in by
:meth:`set_tiles`, each wearing what the walker does with it -- its path
step, its warp box, its level badge -- in the map's own key
(:mod:`shiny_mushroom.ui.world_marks`), under a checkbox that takes the
marks back off when it is the artwork being picked from. **Layer 2** is the
8x8 chars the tilemap entry can name,
with the entry's other bits -- palette row, the two flips, priority -- as
controls under the list; the panel assembles the full 16-bit word and nobody
downstream learns the bit layout. **2x2** and **6x6** are the event stamp
sheets, one block per row, drawn from the document's own bytes; a pick is
bound for the focused event as a new placement; the sheets' own contents are
drawn in the Tilemap editor, which a button under either tab opens on that
sheet. **Sprites** is the
overworld's sprite numbers, each bound for the first empty slot. What is
armed is a typed payload -- :class:`Layer1Tile`, :class:`Layer2Word`,
:class:`StampBlock` or :class:`SpritePick` -- so the mode dispatches on what
it is handed rather than on which tab happened to be open.

**Warps/Exits** is the sixth and arms nothing. It offers the map's two
tables that carry the player off a cell -- the star and pipe warps, and the
path exits -- and how many of either a cartridge has is baked into its search
code, so there is no such thing as placing one: the tab is the two tables
themselves, one row per entry, and a pick **selects** that entry on the map
through :attr:`TilePalette.transfer_picked` rather than putting anything
in hand. It is how an entry parked under an event stamp, or a page away on
the shared submap half, is found at all. Which table a row belongs to is what
:class:`TransferRow` carries, and the row's own glyph is drawn in that
table's hue.

No search, no categories, no async previews: everything on offer has a
picture the moment the snapshot exists.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass
from enum import Enum

from PySide6.QtCore import QModelIndex, Qt, Signal
from PySide6.QtGui import QImage, QPainter, QPen
from PySide6.QtWidgets import (
    QCheckBox,
    QLabel,
    QListView,
    QListWidgetItem,
    QPushButton,
    QStyle,
    QStyledItemDelegate,
    QStyleOptionViewItem,
    QTabBar,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld import SHEET_6X6_SIZE, SPRITE_NAMES
from shiny_mushroom.tile_clipboard import GridStamp
from shiny_mushroom.ui.layer2_attributes import Layer2Attributes
from shiny_mushroom.ui.lists import TileGrid, add_tile
from shiny_mushroom.ui.palette_grid import Swatch
from shiny_mushroom.ui.world_marks import marked_tile, tile_note

#: What the strip is for. A palette row is a number in the control above it and
#: a set of colours on the map; the panel that changes one is elsewhere.
ROW_COLOURS_TIP = (
    "Colours of this palette row. Double-click one to open it in the Palettes panel."
)

#: What the hint line says with nothing to offer, with nothing in hand, and
#: with something in hand, per tab.
NO_MAP = "Open the world map to place tiles."
NOTHING_ARMED = "Pick a tile, then click the world map to place it."
NOTHING_ARMED_LAYER2 = (
    "Pick an 8x8 tile; the controls below set its palette row and flips."
)
NOTHING_ARMED_SPRITES = (
    "Pick a sprite, then click the world map to put it in an empty slot."
)
NOTHING_ARMED_STAMPS = (
    "Pick a stamp block, then click the map to add it to the focused event."
)
#: The stamp tabs' way into the sheet's own artwork: the offer shows what a
#: block looks like, and the Tilemap editor is where its cells are drawn.
EDIT_SHEET = "Edit Sheet in Tilemap Editor"
EDIT_SHEET_TIP = "Open this stamp sheet in the Tilemap editor"
#: The Warps/Exits tab's line: it offers no hand, so it says what the mode's
#: gestures are instead.
TRANSFERS_HINT = (
    "Pick a warp or path exit; drag its trigger to move it. Set "
    "destination... moves where it lands."
)
NO_TRANSFERS = "Open the world map to edit its warp and exit triggers."
ARMED = "Placing tile {what}. Click places it; Shift keeps it; Esc puts it down."
ARMED_SPRITE = (
    "Placing {what}. Click fills an empty slot; Shift keeps it; Esc puts it down."
)
ARMED_STAMP = (
    "Placing stamp {what}. Click adds it to the focused event; Shift keeps "
    "it; Esc puts it down."
)
ARMED_SILENT = (
    "Silent slot in hand ({what}). Click the map to add one there; Esc puts it down."
)
ARMED_REGION = (
    "Placing a {w}x{h} grabbed region. Click stamps it; a drag paints with "
    "it; Esc puts it down."
)

#: Thumbnails at twice the console's pixels, like the create panel's previews.
ICON = 32

#: The 6x6 stamp blocks at the console's own pixels -- 48 wide already, so
#: doubling them would crowd the panel for no added legibility.
STAMP_ICON = 48

#: How many 8x8 chars the Layer 2 tab offers: every one a tilemap entry can
#: name that the background graphics actually fill.
LAYER2_CHARS = 0x200

#: The picked tile's outline, in pixels of pen.
OUTLINE = 2


class OutlinedSelection(QStyledItemDelegate):
    """Selection as an outline in the theme's highlight colour.

    The style's own treatment washes the cell -- and the icon -- with the
    highlight, which on a grid of abutting thumbnails recolours the one tile
    being chosen. A frame says "this one" and leaves the pixels alone. The
    sprites tab keeps the stock delegate: its rows carry text, and a washed
    row is exactly how a list says "selected". The level palette's grid is
    the same kind of library and borrows this.
    """

    def paint(
        self,
        painter: QPainter,
        option: QStyleOptionViewItem,
        index: QModelIndex,
    ) -> None:
        selected = bool(option.state & QStyle.StateFlag.State_Selected)
        plain = QStyleOptionViewItem(option)
        plain.state = plain.state & ~QStyle.StateFlag.State_Selected
        super().paint(painter, plain, index)
        if not selected:
            return
        pen = QPen(option.palette.highlight().color(), OUTLINE)
        pen.setJoinStyle(Qt.PenJoinStyle.MiterJoin)
        painter.save()
        painter.setPen(pen)
        inset = OUTLINE // 2
        painter.drawRect(option.rect.adjusted(inset, inset, -inset, -inset))
        painter.restore()


class PaletteTab(Enum):
    """Which of the map's parts the panel is offering."""

    LAYER1 = "Layer 1"
    LAYER2 = "Layer 2"
    STAMPS_2X2 = "2x2"
    STAMPS_6X6 = "6x6"
    SPRITES = "Sprites"
    TRANSFERS = "Warps/Exits"


#: The two stamp tabs, which the world bar's Editing box shows as one row.
STAMP_TABS = (PaletteTab.STAMPS_2X2, PaletteTab.STAMPS_6X6)


@dataclass(frozen=True)
class Layer1Tile:
    """A Layer 1 placement in hand: one Map16 tile number."""

    number: int


@dataclass(frozen=True)
class TransferRow:
    """One row of the Warps/Exits tab: which of the map's two transfer tables,
    and which entry of it.

    Not a payload in hand -- there is no placing a trigger -- but the same
    kind of typed answer, so what a pick *means* is read off the row rather
    than off which half of the list it came from. ``exits`` rather than a
    table descriptor, because the panel draws the rows and holds no reader of
    the document.
    """

    exits: bool
    entry: int


@dataclass(frozen=True)
class SpritePick:
    """A sprite placement in hand: one overworld sprite number, bound for
    the first empty slot."""

    sprite_id: int


@dataclass(frozen=True)
class StampBlock:
    """A stamp placement in hand: one sheet block by its start offset,
    bound for the focused event as a new entry-table row."""

    sheet: int

    @property
    def small(self) -> bool:
        return self.sheet >= SHEET_6X6_SIZE

    @property
    def side(self) -> int:
        return 2 if self.small else 6

    @property
    def block(self) -> int:
        """The block's index within its own sheet."""
        if self.small:
            return (self.sheet - SHEET_6X6_SIZE) // 4
        return self.sheet // 36


@dataclass(frozen=True)
class SilentPick:
    """A silent slot in hand, copied off one on the map by the eyedropper:
    its layer byte, its tile -- a Map16 number, or a sheet block's start --
    and the event it came from. A click adds a slot like it where the
    pointer is, for the focused event, or for its own event without one.
    The palette offers no row for it; it is only ever picked up."""

    layer: int
    tile: int
    event: int

    @property
    def stamped(self) -> bool:
        """Whether the slot writes a Layer 2 sheet block rather than one
        Layer 1 cell."""
        return bool(self.layer & 1)

    @property
    def side(self) -> int:
        """The footprint's side in the layer's own grain: 8x8 tiles for a
        stamp, one cell for a Layer 1 write."""
        if not self.stamped:
            return 1
        return 2 if self.tile >= SHEET_6X6_SIZE else 6


@dataclass(frozen=True)
class Layer2Word:
    """A Layer 2 placement in hand: one full 16-bit tilemap entry --
    ``YXPCCCTT TTTTTTTT``, attributes included."""

    word: int

    @property
    def char(self) -> int:
        return self.word & 0x3FF

    @property
    def palette_row(self) -> int:
        return (self.word >> 10) & 0x07

    @property
    def priority(self) -> bool:
        return bool(self.word & 0x2000)

    @property
    def x_flip(self) -> bool:
        return bool(self.word & 0x4000)

    @property
    def y_flip(self) -> bool:
        return bool(self.word & 0x8000)


def sprite_name(number: int) -> str:
    """What to call sprite ``number``: the disassembly's name for it, or the
    number itself past the end of the table -- a capture can bring back a
    number the names do not reach."""
    return SPRITE_NAMES[number] if number < len(SPRITE_NAMES) else hexnum(number)


class TilePalette(QWidget):
    """The map's placeable offers, one of which can be in hand."""

    #: Something was picked: put it in hand. Carries a :class:`Layer1Tile`,
    #: a :class:`Layer2Word`, a :class:`StampBlock` or a :class:`SpritePick`.
    armed = Signal(object)

    #: The offer switched layers. Carries the :class:`PaletteTab`. A switch
    #: also puts down whatever was in hand -- a tool belongs to the tab it
    #: came from.
    tab_changed = Signal(object)

    #: A transfer entry's row was picked: select that entry on the map.
    #: Carries the :class:`TransferRow`. Not :attr:`armed` -- both counts are
    #: code-bound, so there is nothing to place and nothing to hold; picking
    #: a row is a way of *finding* an entry, the way a table's row click is.
    transfer_picked = Signal(object)

    #: A colour of the row being placed under was asked to be changed: its byte
    #: offset in the palette file. The panel does not edit it -- what a colour
    #: change means belongs to the window, which owns the palette document.
    colour_activated = Signal(int)

    #: The open stamp sheet was asked to be edited: ``True`` for the 2x2
    #: sheet, ``False`` for the 6x6. Nothing is placed and nothing changes
    #: here -- the window opens the sheet in the Tilemap editor.
    edit_sheet_asked = Signal(bool)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        # The offer dock takes its title from the page it turns to.
        self.setWindowTitle("Tiles")

        self._held: (
            Layer1Tile
            | Layer2Word
            | StampBlock
            | SpritePick
            | SilentPick
            | GridStamp
            | None
        ) = None
        self._layer1: list[QImage] = []
        #: The sprite offer: ``(number, image)`` pairs, in the order shown.
        self._sprites: list[tuple[int, QImage]] = []
        #: The transfer offer: ``(row, label, image)``, the warps in table
        #: order then the path exits in theirs. The label is the mode's --
        #: where the entry triggers and lands -- so a move rewrites it and the
        #: panel stays free of the document.
        self._transfers: list[tuple[TransferRow, str, QImage]] = []
        #: How the Layer 2 thumbnails are drawn: handed the composed words,
        #: answers their pictures. Handed in rather than imported, because
        #: drawing needs the snapshot and the dock must not hold a model.
        self._draw_layer2: Callable[[Sequence[int]], list[QImage]] | None = None
        #: How the stamp blocks are drawn: handed ``small``, answers one
        #: picture per block of that sheet -- the same contract, over the
        #: document's own stamp bytes.
        self._draw_stamps: Callable[[bool], list[QImage]] | None = None
        self._tabs = QTabBar()
        for tab in PaletteTab:
            self._tabs.addTab(tab.value)
        self._tabs.currentChanged.connect(self._switched)

        # Layer 1's own option, under its tab rather than in the View menu:
        # it is about this offer, not about the map, and the map's tile marks
        # are switched separately. On by default, because what a tile *does*
        # is most of why one is picked over another that looks the same.
        self._marks = QCheckBox("Tile marks")
        self._marks.setToolTip("Draw each tile's path, warp and level function over it")
        self._marks.setChecked(True)
        self._marks.toggled.connect(self._marks_toggled)

        self._list = TileGrid(ICON)
        #: The stock delegate for the sprites tab's text rows; the tile grids
        #: swap in the outline treatment -- see :meth:`_refill`.
        self._plain_delegate = self._list.itemDelegate()
        self._outline_delegate = OutlinedSelection(self._list)
        self._list.itemClicked.connect(self._picked)
        # Enter means "this one" as well, and arming is idempotent, so the two
        # paths cannot fight over a single row.
        self._list.itemActivated.connect(self._picked)
        # The right button works on the offer as it does on the canvas: a
        # right click picks exactly as a left one, and a right drag grabs a
        # rectangle of the grid as a stamp.
        self._list.right_picked.connect(self._picked)
        self._list.region_grabbed.connect(self._region_grabbed)

        # The Layer 2 entry's other bits, as tool settings, and the sixteen
        # colours the row being placed under is drawn from -- the same widget
        # the Map16 VRAM dock places its words with.
        self._attributes = Layer2Attributes(ROW_COLOURS_TIP)
        self._attributes.changed.connect(self._attributes_changed)
        self._attributes.colour_activated.connect(self.colour_activated)

        # The stamp tabs' one button: the blocks are drawn in the Tilemap
        # editor, and this is the way there from the sheet being picked out
        # of. Like the colour strip's double-click, the panel only asks --
        # what opening an environment means belongs to the window.
        self._edit_sheet = QPushButton(EDIT_SHEET)
        self._edit_sheet.setToolTip(EDIT_SHEET_TIP)
        self._edit_sheet.clicked.connect(self._edit_sheet_clicked)

        self._hint = QLabel()
        self._hint.setWordWrap(True)

        layout = QVBoxLayout(self)
        layout.addWidget(self._tabs)
        layout.addWidget(self._marks)
        layout.addWidget(self._list, 1)
        layout.addWidget(self._attributes)
        layout.addWidget(self._edit_sheet)
        layout.addWidget(self._hint)

        self._refill()

    # -- what is on offer ----------------------------------------------------

    @property
    def tab(self) -> PaletteTab:
        """Which layer's tiles are being offered."""
        return list(PaletteTab)[max(0, self._tabs.currentIndex())]

    def set_tab(self, tab: PaletteTab) -> None:
        """Switch to ``tab``, exactly as clicking it would -- the toolbar's
        layer picker's entry. A real switch disarms and announces itself
        through :attr:`tab_changed`; asking for the open tab does nothing."""
        self._tabs.setCurrentIndex(list(PaletteTab).index(tab))

    def set_tiles(self, images: Sequence[QImage]) -> None:
        """Offer one Layer 1 item per image, in tile-number order; empty is
        "no map"."""
        self._layer1 = list(images)
        self._held = None
        self._refill()

    def set_layer2(self, draw: Callable[[Sequence[int]], list[QImage]] | None) -> None:
        """Turn the Layer 2 tab on, with ``draw`` answering thumbnails for
        composed words. ``None`` turns it back off."""
        self._draw_layer2 = draw
        self._held = None
        self._refill()

    def set_stamps(self, draw: Callable[[bool], list[QImage]] | None) -> None:
        """Turn the stamp tabs on, with ``draw`` answering one thumbnail per
        block of the asked-for sheet. ``None`` turns them back off."""
        self._draw_stamps = draw
        self._held = None
        self._refill()

    def refresh_stamps(self) -> None:
        """Redraw the open stamp tab's thumbnails -- a stamp edit changed
        the artwork behind them. The hand keeps what it holds, and the held
        block keeps its row."""
        if self.tab not in STAMP_TABS:
            return
        self._refill()
        self._select_held_row()

    def set_sprites(self, offers: Sequence[tuple[int, QImage]]) -> None:
        """Offer one sprite per ``(number, image)`` pair; empty is "no
        map". The images are the markers' own -- captured artwork where the
        cartridge answered, the numbered glyph where it did not."""
        self._sprites = list(offers)
        self._held = None
        self._refill()

    def set_transfers(self, offers: Sequence[tuple[TransferRow, str, QImage]]) -> None:
        """Offer one transfer entry per ``(row, label, image)`` -- the warps
        then the path exits, each in its table's order; empty is "no map".

        Re-offered after every edit that moves a trigger or its landing:
        the label names both, so the rows are a readout as much as a way in.
        The picked row survives the rebuild, since the entry it names does.
        """
        held = self._list.currentRow() if self.tab is PaletteTab.TRANSFERS else -1
        self._transfers = list(offers)
        self._refill()
        if 0 <= held < self._list.count():
            self._list.setCurrentRow(held)

    @property
    def count(self) -> int:
        """How many tiles are on offer. The panel's own state, for tests."""
        return self._list.count()

    @property
    def hint(self) -> str:
        """What the hint line says. The panel's own state, for tests."""
        return self._hint.text()

    @property
    def tile_marks(self) -> bool:
        """Whether the Layer 1 thumbnails wear what their tiles do."""
        return self._marks.isChecked()

    def set_tile_marks(self, on: bool) -> None:
        """Show the marks, or take them off -- exactly as the checkbox
        does."""
        self._marks.setChecked(on)

    # -- what is in hand -----------------------------------------------------

    @property
    def held(
        self,
    ) -> (
        Layer1Tile
        | Layer2Word
        | StampBlock
        | SpritePick
        | SilentPick
        | GridStamp
        | None
    ):
        """What is in hand, exactly as :attr:`armed` said it."""
        return self._held

    @property
    def armed_tile(self) -> int | None:
        """The Layer 1 tile number in hand, if that is what is held."""
        return self._held.number if isinstance(self._held, Layer1Tile) else None

    def arm(
        self,
        payload: Layer1Tile
        | Layer2Word
        | StampBlock
        | SpritePick
        | SilentPick
        | GridStamp
        | int
        | None,
    ) -> None:
        """Put ``payload`` in hand, or ``None`` to put down what is there.

        A bare int is a Layer 1 tile number -- the phase-one spelling, kept
        because it is also the natural one for a test. Idempotent, like the
        create panel's: a click and a press of Enter can both arrive at the
        same row without the second undoing the first.
        """
        if isinstance(payload, int):
            payload = Layer1Tile(payload)
        if payload == self._held:
            return
        self._held = payload
        self._show_state()
        if payload is not None:
            self.armed.emit(payload)

    def disarm(self) -> None:
        """Put down what is in hand, **without saying so** -- the window calls
        this once a placement has been made or cancelled, and already knows."""
        self._held = None
        self._list.clearSelection()
        self._list.setCurrentItem(None)
        self._show_state()

    def hold(self, payload: object) -> None:
        """Put ``payload`` back in hand **without saying so**, and put the
        selection back on its row.

        :meth:`disarm`'s opposite, and for the same kind of caller: one that
        already knows, so announcing would be telling it what it just said.
        What a **redraw** of the offers uses -- the same tiles, sprites and
        words in new colours -- because :meth:`set_tiles` and its siblings
        drop the hand, which is right when the offer itself changed and
        wrong when only its pixels did.
        """
        self._held = payload
        self._select_held_row()
        self._show_state()

    def pickup(
        self, payload: Layer1Tile | Layer2Word | StampBlock | SpritePick | SilentPick
    ) -> None:
        """The eyedropper's entry: select ``payload``'s row, set the controls
        to its attributes, and arm it -- whatever tab was open. A silent slot
        has no row; it stays on the stamp tab it was picked from."""
        if isinstance(payload, Layer1Tile):
            wanted = PaletteTab.LAYER1
        elif isinstance(payload, SpritePick):
            wanted = PaletteTab.SPRITES
        elif isinstance(payload, StampBlock):
            wanted = PaletteTab.STAMPS_2X2 if payload.small else PaletteTab.STAMPS_6X6
        elif isinstance(payload, SilentPick):
            wanted = self.tab if self.tab in STAMP_TABS else PaletteTab.STAMPS_2X2
        else:
            wanted = PaletteTab.LAYER2
        if self.tab is not wanted:
            self._tabs.setCurrentIndex(list(PaletteTab).index(wanted))
        if isinstance(payload, Layer2Word):
            self._set_attributes(payload)
            self._refill()
        # Asked after the tab switch above, since a row belongs to a tab.
        row = self._row_of(payload)
        if row is not None and 0 <= row < self._list.count():
            self._list.setCurrentRow(row)
            # Centered, not merely scrolled into view: the eyedropper's pick
            # should be findable at a glance, not sitting at the list's edge.
            self._list.scrollToItem(
                self._list.item(row), QListView.ScrollHint.PositionAtCenter
            )
        self.arm(payload)

    # -- internals -----------------------------------------------------------

    def _row_of(self, payload: object) -> int | None:
        """Which row of the **open tab** offers ``payload``, if one does.

        A payload belonging to another tab has no row here, and a grabbed
        region is not a row at all -- it is a rectangle of them.
        """
        if isinstance(payload, Layer1Tile):
            return payload.number if self.tab is PaletteTab.LAYER1 else None
        if isinstance(payload, SpritePick):
            if self.tab is not PaletteTab.SPRITES:
                return None
            return next(
                (
                    index
                    for index, (number, _) in enumerate(self._sprites)
                    if number == payload.sprite_id
                ),
                None,
            )
        if isinstance(payload, StampBlock):
            return payload.block if self.tab in STAMP_TABS else None
        if isinstance(payload, Layer2Word):
            return payload.char if self._offering_words else None
        return None

    def _select_held_row(self) -> None:
        """Put the selection back on the row of whatever is in hand.

        What every redraw of the offer needs: the list was cleared and
        refilled, and a hand that survived that should still be pointing at
        the row it holds.
        """
        row = self._row_of(self._held)
        if row is not None and 0 <= row < self._list.count():
            self._list.setCurrentRow(row)

    def _edit_sheet_clicked(self) -> None:
        """The Edit Sheet button: ask for the open stamp sheet, by which one
        it is. Guarded, because the button is only ever up on those tabs."""
        if self.tab in STAMP_TABS:
            self.edit_sheet_asked.emit(self.tab is PaletteTab.STAMPS_2X2)

    def _marks_toggled(self, _on: bool) -> None:
        """The marks went on or off: redraw the offer, keeping the row in
        hand selected -- the picture changed, not the pick."""
        if self.tab is not PaletteTab.LAYER1:
            return
        self._refill()
        self._select_held_row()

    def _switched(self, _index: int) -> None:
        # A tool in hand belongs to the tab it came from.
        self.disarm()
        self._refill()
        self.tab_changed.emit(self.tab)

    @property
    def _offering_words(self) -> bool:
        """Whether the open tab is offering 16-bit tilemap words -- the
        Layer 2 tab."""
        return self.tab is PaletteTab.LAYER2

    def _picked(self, item: QListWidgetItem) -> None:
        number = item.data(Qt.ItemDataRole.UserRole)
        if self.tab is PaletteTab.TRANSFERS:
            # Nothing goes in hand: there is no placing a trigger, so the row
            # is a way of reaching the entry that is already on the map. The
            # row's position is its identity here, since the two tables number
            # their entries from zero apiece.
            picked = self._list.row(item)
            if 0 <= picked < len(self._transfers):
                self.transfer_picked.emit(self._transfers[picked][0])
            return
        if self.tab is PaletteTab.LAYER1:
            self.arm(Layer1Tile(number))
        elif self.tab is PaletteTab.SPRITES:
            self.arm(SpritePick(number))
        elif self._offering_words:
            self.arm(Layer2Word(self._composed(number)))
        else:
            # The rows carry their block's sheet start offset directly.
            self.arm(StampBlock(number))

    def _region_grabbed(
        self, entries: list[tuple[int, int, int]], width: int, height: int
    ) -> None:
        """A right drag swept a rectangle of the offer: arm it whole, as the
        stamp the same drag would grab off the map.

        Only the tabs whose rows are placeable tile material answer -- the
        Layer 1 tiles, and the chars wherever words are on offer. A sprite,
        a stamp block or a transfer row is a record-shaped thing, and a
        rectangle of those means nothing. A one-cell drag never reaches
        here -- the grid degrades it to a pick.
        """
        if self.tab is PaletteTab.LAYER1:
            leaves = tuple((dx, dy, Layer1Tile(number)) for dx, dy, number in entries)
        elif self._offering_words:
            leaves = tuple(
                (dx, dy, Layer2Word(self._composed(number)))
                for dx, dy, number in entries
            )
        else:
            return
        self.arm(GridStamp(leaves, width, height))

    def _composed(self, char: int) -> int:
        return self._attributes.composed(char)

    def _attributes_changed(self) -> None:
        """The tool settings moved: redraw the offer and re-arm what is held
        under the new attributes."""
        if not self._offering_words:
            return
        self._refill()
        held = self._held
        if isinstance(held, Layer2Word):
            self._held = None  # so arm() sees a change and says so
            self.arm(Layer2Word(self._composed(held.char)))
            if 0 <= held.char < self._list.count():
                self._list.setCurrentRow(held.char)

    def _set_attributes(self, word: Layer2Word) -> None:
        self._attributes.show_word(word)

    def set_palette_rows(self, rows: Sequence[Sequence[Swatch]]) -> None:
        """Offer the colours of each of the eight background rows."""
        self._attributes.set_palette_rows(rows)

    def _refill(self) -> None:
        self._list.clear()
        on_sprites = self.tab is PaletteTab.SPRITES
        on_transfers = self.tab is PaletteTab.TRANSFERS
        on_stamps = self.tab in STAMP_TABS
        on_layer1 = self.tab is PaletteTab.LAYER1
        on_words = self._offering_words
        self._attributes.setVisible(on_words)
        self._marks.setVisible(on_layer1)
        self._edit_sheet.setVisible(on_stamps)
        self._edit_sheet.setEnabled(self._draw_stamps is not None)
        self._attributes.set_controls_enabled(
            on_words and self._draw_layer2 is not None
        )
        # The tile and stamp tabs are a tight grid of pictures; the sprites
        # read as rows, because a sprite's name is half of what tells them
        # apart. The 6x6 blocks get the one larger cell.
        size = STAMP_ICON if self.tab is PaletteTab.STAMPS_6X6 else ICON
        # The transfer rows read as rows for the sprites' reason and one
        # more: what tells two entries apart is where they go, which is words.
        rows = on_sprites or on_transfers
        self._list.setViewMode(
            QListView.ViewMode.ListMode if rows else QListView.ViewMode.IconMode
        )
        self._list.set_cell(size, grid=not rows)
        self._list.setItemDelegate(
            self._plain_delegate if rows else self._outline_delegate
        )
        if on_transfers:
            for row, label, image in self._transfers:
                what = "Path exit" if row.exits else "Warp"
                self._add(image, row.entry, f"{what} {hexnum(row.entry)}", text=label)
            self._list.setEnabled(bool(self._transfers))
        elif on_sprites:
            for number, image in self._sprites:
                self._add(
                    image, number, f"Sprite {hexnum(number)}", text=sprite_name(number)
                )
            self._list.setEnabled(bool(self._sprites))
        elif on_words:
            if self._draw_layer2 is not None:
                words = [self._composed(char) for char in range(LAYER2_CHARS)]
                for char, image in enumerate(self._draw_layer2(words)):
                    self._add(image, char, f"Tile {hexnum(char, 3)}")
            self._list.setEnabled(self._draw_layer2 is not None)
        elif on_stamps:
            if self._draw_stamps is not None:
                small = self.tab is PaletteTab.STAMPS_2X2
                base = SHEET_6X6_SIZE if small else 0
                stride = 4 if small else 36
                for block, image in enumerate(self._draw_stamps(small)):
                    offset = base + block * stride
                    self._add(image, offset, f"Stamp {hexnum(offset, 3)}", size=size)
            self._list.setEnabled(self._draw_stamps is not None)
        else:
            marks = self._marks.isChecked()
            for number, image in enumerate(self._layer1):
                tooltip = f"Tile {hexnum(number)}"
                if marks:
                    tooltip = f"{tooltip} - {tile_note(number)}"
                self._add(image, number, tooltip, mark=marks)
            self._list.setEnabled(bool(self._layer1))
        self._show_state()

    def _add(
        self,
        image: QImage,
        number: int,
        tooltip: str,
        text: str = "",
        size: int = ICON,
        mark: bool = False,
    ) -> None:
        add_tile(
            self._list,
            image,
            number,
            tooltip,
            size=size,
            text=text,
            decorate=marked_tile if mark else None,
        )

    def _show_state(self) -> None:
        if self.tab is PaletteTab.TRANSFERS:
            # The one tab with no hand: its line is about the map's gestures
            # whatever is picked, so it is answered before the hand is asked.
            self._hint.setText(TRANSFERS_HINT if self._transfers else NO_TRANSFERS)
        elif not self._list.count():
            self._hint.setText(NO_MAP)
        elif self._held is None:
            if self.tab is PaletteTab.SPRITES:
                self._hint.setText(NOTHING_ARMED_SPRITES)
            elif self._offering_words:
                self._hint.setText(NOTHING_ARMED_LAYER2)
            elif self.tab in STAMP_TABS:
                self._hint.setText(NOTHING_ARMED_STAMPS)
            else:
                self._hint.setText(NOTHING_ARMED)
        elif isinstance(self._held, Layer1Tile):
            self._hint.setText(ARMED.format(what=hexnum(self._held.number)))
        elif isinstance(self._held, StampBlock):
            self._hint.setText(ARMED_STAMP.format(what=hexnum(self._held.sheet, 3)))
        elif isinstance(self._held, SpritePick):
            self._hint.setText(
                ARMED_SPRITE.format(what=sprite_name(self._held.sprite_id))
            )
        elif isinstance(self._held, SilentPick):
            what = (
                f"stamp {hexnum(self._held.tile, 3)}"
                if self._held.stamped
                else f"tile {hexnum(self._held.tile)}"
            )
            self._hint.setText(ARMED_SILENT.format(what=what))
        elif isinstance(self._held, GridStamp):
            self._hint.setText(
                ARMED_REGION.format(w=self._held.width, h=self._held.height)
            )
        else:
            self._hint.setText(ARMED.format(what=hexnum(self._held.char, 3)))
