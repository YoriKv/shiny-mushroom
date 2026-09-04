"""The create panel: what can be put into the level, and picking one up.

A page of the offer dock (:mod:`shiny_mushroom.ui.offer_dock`) beside the
properties panel, and the two are deliberately a pair: this
one says what a level *could* contain and that one says what one record in it
does. Neither of them knows what an object or a sprite is -- the catalogue
(:mod:`shiny_mushroom.catalog`) decides what is offered and what placing one
produces, and this is a widget factory over it, exactly as
:class:`~shiny_mushroom.ui.properties.PropertiesDock` is a widget factory over
field descriptors.

**Picking a row arms it; it does not place anything.** The panel emits
:attr:`CreatePanel.armed` and stops there. Where a thing goes is a gesture on the
picture, which is the window's business -- and keeping the two apart is what lets
one entry be placed six times without the panel knowing it happened, and what
lets the panel be tested without a canvas behind it.

**Three tabs, because a level has three placeable things.** Two of them are
record streams, and a record cannot change which one it is in -- the two are
written separately, so one that changed sides would be dropped from one and
never reach the other -- so that is the division the format itself makes. The
screen exit sits with the objects because that is what it is, rather than in a
tab of its own.

The third is the **Layer 2 background**, which is no catalogue at all: a page
of Map16 blocks offered by :mod:`shiny_mushroom.ui.level_palette`, shown in
place of the searchable list. It is here rather than in a panel of its own
because it answers the same question the other two do -- what can I put into
this level -- and because two panels taking turns in one spot is a spot whose
size belongs to neither. Picking it is picking an **editing mode**: the tab and
the level bar's Editing box are two handles on one choice, and the panel says
which was picked (:attr:`CreatePanel.editing_picked`) rather than deciding it.

**The category filter's words come from the catalogue, not from here.**
``standard`` / ``extended`` / ``command`` for objects, which is the branch
:class:`~shiny_mushroom.objects.ObjectKind` reads out of the loader; ``enemy`` /
``powerup`` / ``platform`` and ten more for sprites, which is
:class:`~shiny_mushroom.sprites.SpriteCategory` and is the one judgement in the
metadata. See :mod:`shiny_mushroom.catalog`. The rows are whatever the entries
carry, so the panel gains a category the moment the catalogue does.
"""

from __future__ import annotations

from collections.abc import Collection, Mapping, Sequence

from PySide6.QtCore import QPoint, QRect, Qt, QTimer, Signal
from PySide6.QtGui import QCursor, QImage
from PySide6.QtWidgets import (
    QCheckBox,
    QComboBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QStackedWidget,
    QTabBar,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.catalog import ART_LABELS, Art, CatalogKey, Entry, Stream
from shiny_mushroom.ui.custom_tiles_page import NO_FEATURE, CustomTilesPage
from shiny_mushroom.ui.hover_preview import REST_MS, HoverPreview
from shiny_mushroom.ui.level_palette import NO_LAYER2, LevelPalette
from shiny_mushroom.ui.tips import wrap_tip

#: The tabs, in order, as ``(label, stream)``. A tuple rather than the
#: :class:`~shiny_mushroom.catalog.Stream` enum's own order, because what the
#: tabs are called and what order they sit in is a decision about the panel and
#: not about the format. The object stream is labelled by the layer it lands on
#: rather than by what the format calls it, so that the panel and the level
#: bar's Editing box -- "Layer 1 & Sprites" against "Layer 2" -- name the same
#: division in the same words.
#:
#: Two of them carry no stream. The Layer 2 background is a tilemap and not a
#: record stream, so there is nothing in :class:`~shiny_mushroom.catalog.Stream`
#: for it to be; the Custom Tiles tab does place objects, but from a page and
#: not from the catalogue, so it is named here as the tab bar's own -- see
#: :data:`CUSTOM_TAB`. It sits beside Layer 1 because what it places lands
#: there, and the two are reached one after the other.
TABS: tuple[tuple[str, Stream | None], ...] = (
    ("Layer 1", Stream.OBJECT),
    ("Custom Tiles", None),
    ("Sprites", Stream.SPRITE),
    ("Layer 2", None),
)

#: Which of them Layer 2's is. There are two pages behind the tab bar and not
#: three: the two record streams share the catalogue page -- same search box,
#: same filters, a different list -- and the background has its own.
#:
#: **Which page this tab shows depends on the level**, and that is the whole of
#: what "an alternate pathway" means here. A level whose Layer 2 is a
#: background gets the palette page; one whose Layer 2 is an *object stream*
#: gets the catalogue page filled with objects, because on such a level Layer 2
#: is placed exactly as Layer 1 is. Same tab, same key, same mode -- see
#: :meth:`CreatePanel.offer_layer2`.
LAYER2_TAB = 3

#: The second tab: a Map16 page's blocks, placed on Layer 1 as Lunar Magic's
#: direct-tile objects (:mod:`shiny_mushroom.ui.custom_tiles_page`). Its
#: page is the panel's third; it places in the records' mode, so its entries
#: arm exactly as the catalogue's do.
#:
#: **Greyed on a cartridge without the custom-tiles feature**, which is what
#: :meth:`CreatePanel.offer_custom` says: the four direct-tile objects come
#: with the feature, so without it the tab could place nothing at all -- see
#: :data:`~shiny_mushroom.ui.custom_tiles_page.NO_FEATURE`.
CUSTOM_TAB = 1
CUSTOM_PAGE = 2

#: The record streams, in tab order -- the catalogue page's two, without the
#: tabs that carry no stream and no catalogue.
STREAMS: tuple[Stream, ...] = tuple(
    stream for _label, stream in TABS if stream is not None
)

#: The editing mode each tab places in, as the level bar's Editing row index.
#: Two tabs meaning one mode is the point: Layer 1 and the sprites are placed
#: and selected together, which is what makes them one half of a level.
TAB_EDITING: tuple[int, ...] = (0, 0, 0, 1)

#: The category filter's "no filter" row. It carries the empty string, so
#: filtering is one comparison with no special case for "everything".
ALL_CATEGORIES = "All categories"

#: What the hint line says when there is nothing to place into, and when there
#: is but nothing has been picked. Two messages, like the properties panel's,
#: because "no level" and "nothing in hand" are different situations and only
#: one of them is fixed by clicking a row.
NO_LEVEL = "Load a level to place things in it."
NOTHING_ARMED = "Pick an object or a sprite, then click the level to place it."

#: ...and when something is in hand. It names the two gestures that are not the
#: obvious one, because neither is guessable: that placing normally puts the
#: tool back down, and how to put it down without placing anything.
ARMED = "Placing {what} - click to place; Shift keeps it; right-click stops."

#: Said after the hint when every row has been filtered away. Worth its own
#: sentence: an empty list under three filters reads as a broken panel, and the
#: difference between "nothing matches" and "nothing is offered" is the whole
#: question the reader has.
NO_MATCHES = "  Nothing matches."

#: ...and when the graphics filter is what is holding rows back. A count rather
#: than silence: a list quietly two thirds shorter than the catalogue is a panel
#: that looks like it is missing things, and the number is what says it is not.
HIDDEN = "  {count} hidden -- no graphics for them here."


class CreatePanel(QWidget):
    """What can be put into the level: a searchable catalogue per record
    stream, and the Layer 2 background's page of blocks.

    Emits :attr:`armed` with the :class:`~shiny_mushroom.catalog.Entry` that was
    picked. It does not place it, does not touch the document, and does not know
    that a canvas exists: what an armed entry *becomes* is :meth:`Entry.at`'s
    answer, and where it goes is a click on the picture. The background's page
    is :attr:`layer2` and says the same thing on its own signal, because what it
    offers is a block number and not an entry.
    """

    #: An entry was picked: put this in hand. Carries the ``Entry``.
    armed = Signal(object)

    #: A tab belonging to a different editing mode was opened. Carries that
    #: mode as the level bar's Editing row index -- 0 for the records, 1 for
    #: the Layer 2 background. What the mode *is* stays the window's: the panel
    #: says which tab was picked and waits to be told which tab to show, exactly
    #: as the Editing box does.
    editing_picked = Signal(int)

    #: The pointer has rested on a row that has no picture yet. Carries the
    #: ``Entry``. Whether one can be made, and what it costs, is the window's
    #: business -- the panel only says which row is being looked at, and says it
    #: once per row rather than once per mouse event.
    wants_preview = Signal(object)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        # The offer dock takes its title from the page it turns to.
        self.setWindowTitle("Create")

        #: The catalogue on offer, by stream. Empty until a level arrives, which
        #: is also what "there is nothing to place" means.
        self._catalog: dict[Stream, tuple[Entry, ...]] = {
            stream: () for stream in STREAMS
        }
        #: Which entries the loaded level already holds, as :attr:`Entry.key`s --
        #: what the "already in this level" filter asks. Keys rather than
        #: records, so the panel never has to look at one.
        self._used: frozenset[CatalogKey] = frozenset()
        #: The chosen category per tab. Per tab rather than shared, because the
        #: two tabs' categories are different words: a sprite's filter left over
        #: on the object tab would match nothing and read as an empty catalogue.
        self._categories: dict[Stream, str] = {stream: "" for stream in STREAMS}
        #: Whether each entry's graphics will be loaded where it is being placed,
        #: by :attr:`Entry.key`. Handed in rather than worked out here: it needs
        #: the cartridge index and the level's *sprite* tileset, neither of which
        #: is the panel's. Anything missing reads as
        #: :attr:`~shiny_mushroom.catalog.Art.SETTLED`, which is what every
        #: object is and what a panel with no cartridge behind it should show.
        self._art: dict[CatalogKey, Art] = {}
        self._hidden = 0
        self._armed: Entry | None = None
        #: A picture of each entry, by :attr:`Entry.key`. Rendered where the
        #: level's own memories could answer for it and simply absent otherwise
        #: -- an entry with no render gets no popup rather than an empty frame.
        self._previews: dict[CatalogKey, QImage] = {}
        self._preview = HoverPreview(self)
        # The row the pointer is on, and the timer that decides it has *rested*
        # there. A picture already in hand goes up the moment the row is
        # entered; the timer gates only asking the game for one that is not,
        # because sweeping down two hundred names is not two hundred requests to
        # probe an emulator.
        self._resting: Entry | None = None
        self._rest = QTimer(self)
        self._rest.setSingleShot(True)
        self._rest.setInterval(REST_MS)
        self._rest.timeout.connect(self._ask_for_preview)

        self._tabs = QTabBar()
        for label, _stream in TABS:
            self._tabs.addTab(label)
        # Why each is greyed, where a greyed tab is the only thing to ask.
        # Both start greyed: neither a Layer 2 nor the custom-tiles feature is
        # something a panel with no cartridge behind it can offer.
        self._tabs.setTabToolTip(LAYER2_TAB, NO_LAYER2)
        self._tabs.setTabEnabled(LAYER2_TAB, False)
        self._tabs.setTabToolTip(CUSTOM_TAB, NO_FEATURE)
        self._tabs.setTabEnabled(CUSTOM_TAB, False)
        #: The record tab to come back to when the editing mode does. Which of
        #: the two was last open is a choice the user made and the Editing box
        #: never touched, so returning to "Layer 1 & Sprites" returns to it.
        self._records_tab = 0
        #: Whether the Layer 2 tab places *records* rather than painting a
        #: pattern -- see :data:`LAYER2_TAB`. Set by the window per level.
        self._layer2_records = False

        self._search = QLineEdit()
        self._search.setPlaceholderText("Search name, id or category...")
        self._search.setClearButtonEnabled(True)
        self._search.textChanged.connect(lambda _text: self._refill())

        self._category = QComboBox()
        self._category.activated.connect(lambda _index: self._chose_category())

        self._used_only = QCheckBox("In this level")
        self._used_only.setToolTip("Only what the loaded level already contains.")
        self._used_only.toggled.connect(lambda _on: self._refill())

        # On by default, and it is the one filter that is. Measured on the stock
        # cart, 109 of the 206 sprites offered are never shipped under sprite
        # tileset $00 -- so left off, more than half the list would carry a
        # warning badge, which is the same as none of it carrying one. On, the
        # list is what will work and the toggle is how you see the rest.
        self._with_art = QCheckBox("Graphics here")
        self._with_art.setToolTip(
            wrap_tip(
                "Hide sprites this tileset never places: their artwork is "
                "probably not loaded."
            )
        )
        self._with_art.setChecked(True)
        self._with_art.toggled.connect(lambda _on: self._refill())

        filters = QWidget()
        row = QHBoxLayout(filters)
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(self._category, 1)
        row.addWidget(self._used_only)
        row.addWidget(self._with_art)

        self._list = QListWidget()
        # Every row is one line of text, so Qt can size the view from the first
        # of them instead of measuring a few hundred.
        self._list.setUniformItemSizes(True)
        # `itemEntered` only fires with tracking on, and it is set on the
        # viewport rather than the list because that is the widget the mouse
        # events actually arrive at.
        self._list.viewport().setMouseTracking(True)
        self._list.itemEntered.connect(self._hovered)
        self._list.itemClicked.connect(self._picked)
        # Enter and a double click both mean "this one" as well, and arming is
        # idempotent, so the two paths cannot fight over a single row.
        self._list.itemActivated.connect(self._picked)

        self._hint = QLabel()
        self._hint.setWordWrap(True)

        catalogue = QWidget()
        page = QVBoxLayout(catalogue)
        page.setContentsMargins(0, 0, 0, 0)
        page.addWidget(self._search)
        page.addWidget(filters)
        page.addWidget(self._list, 1)
        page.addWidget(self._hint)

        #: The background's page of blocks -- the level's third placeable
        #: thing, and the one the window reads and fills directly.
        self.layer2 = LevelPalette()
        #: A Map16 page's blocks as direct-tile objects -- the fourth, filled
        #: by the window the same way, and armed as an entry.
        self.custom = CustomTilesPage()
        self.custom.armed.connect(self._custom_armed)

        # The tab bar switches the page under it. Three pages and four tabs:
        # the search box and the filters belong to both record streams, and
        # rebuilding them for each would be two descriptions of one thing.
        self._pages = QStackedWidget()
        self._pages.addWidget(catalogue)
        self._pages.addWidget(self.layer2)
        self._pages.addWidget(self.custom)

        layout = QVBoxLayout(self)
        layout.addWidget(self._tabs)
        layout.addWidget(self._pages, 1)

        # Connected last: the handler shows a page and fills a list, so it must
        # not be reachable before there is either.
        self._tabs.currentChanged.connect(self._tab_changed)

        self.set_catalog({})

    # -- what is on offer ---------------------------------------------------

    @property
    def stream(self) -> Stream | None:
        """Which record stream's tab is open, or ``None`` on a Layer 2 tab that
        is offering a tilemap's blocks and so has no stream to be.

        The Layer 2 tab answers :attr:`~shiny_mushroom.catalog.Stream.OBJECT`
        on a level whose Layer 2 is an object stream: it is the same catalogue,
        offered for the same reason, and *which layer a placement lands on* is
        the window's question rather than the panel's.
        """
        index = max(0, self._tabs.currentIndex())
        if index == LAYER2_TAB and self._layer2_records:
            return Stream.OBJECT
        if index == CUSTOM_TAB:
            # A direct-tile object is an object: the tab places into that
            # stream, from a page rather than a list.
            return Stream.OBJECT
        return TABS[index][1]

    @property
    def editing(self) -> int:
        """The editing mode the open tab places in, as the level bar's Editing
        row index."""
        return TAB_EDITING[max(0, self._tabs.currentIndex())]

    def catalog(self, stream: Stream) -> tuple[Entry, ...]:
        """Everything offered for ``stream``, whatever the filters are showing.

        The list the *window* has to answer questions about -- which graphics
        are loaded for which entry -- and deliberately not :attr:`entries`,
        which is what survived the filters and would make an answer depend on
        what was typed in the search box.
        """
        return self._catalog[stream]

    @property
    def entries(self) -> tuple[Entry, ...]:
        """What the list is showing, in the order it is showing it."""
        return tuple(
            self._list.item(row).data(Qt.ItemDataRole.UserRole)
            for row in range(self._list.count())
        )

    @property
    def armed_entry(self) -> Entry | None:
        """What is in hand, or ``None`` when nothing is."""
        return self._armed

    @property
    def hint(self) -> str:
        """What the hint line says. The panel's own state, for tests."""
        return self._hint.text()

    def show_tab(self, stream: Stream | None) -> None:
        """Open a particular stream's tab -- ``None`` for the Layer 2 one,
        which offers no stream. What a click on the tab does, and refused the
        same way: a greyed tab does not open.

        Refused here rather than left to Qt, which switches to a disabled tab
        when it is asked to -- so the panel would show the page a click on it
        cannot reach, and say it had been picked.

        The Custom Tiles tab carries no stream either and is skipped: it is
        reached by clicking it, never by asking for a stream, and ``None``
        means Layer 2 to every caller.
        """
        for index, (_label, offered) in enumerate(TABS):
            if offered is stream and index != CUSTOM_TAB:
                self._open(index)
                return

    @property
    def offers_layer2(self) -> bool:
        """Whether the Layer 2 tab can be opened at all. The panel's own
        state, for tests."""
        return self._tabs.isTabEnabled(LAYER2_TAB)

    @property
    def offers_custom(self) -> bool:
        """Whether the Custom Tiles tab can be opened at all. The panel's own
        state, for tests."""
        return self._tabs.isTabEnabled(CUSTOM_TAB)

    def set_editing(self, index: int) -> None:
        """Show the tab that places in editing mode ``index``, without asking.

        The Editing box's twin: the window decides what the mode is, and both
        handles are told. Mode 0 goes back to whichever record tab was last
        open rather than to the first, because which of the two is in front is
        the user's choice and the Editing box was never asked about it.

        A greyed tab is refused here as it is in :meth:`show_tab`: a level
        whose Layer 2 is an object stream has no background mode to be put in.

        A tab already placing in ``index``'s mode stays: the Custom Tiles tab
        places in the records' mode without being a record tab, and being
        told "mode 0" is not being told to leave it.
        """
        current = max(0, self._tabs.currentIndex())
        if TAB_EDITING[current] == index and self._tabs.isTabEnabled(current):
            return
        self._open(LAYER2_TAB if index == 1 else self._records_tab)

    def _open(self, index: int) -> None:
        """Show tab ``index``, unless it is greyed."""
        if self._tabs.isTabEnabled(index):
            self._tabs.setCurrentIndex(index)

    def offer_layer2(self, editable: bool, records: bool = False) -> None:
        """Arm or grey the Layer 2 tab, and say which page it opens.

        ``records`` is the alternate pathway: the level's Layer 2 is an object
        stream, so the tab offers the object catalogue rather than a page of
        background blocks. Greyed only when the level has neither -- a Layer 2
        background this editor could not read.
        """
        self._layer2_records = records
        self._tabs.setTabEnabled(LAYER2_TAB, editable)
        if self._tabs.currentIndex() == LAYER2_TAB:
            # The kind can change under an open tab: switching to a level whose
            # Layer 2 is the other sort keeps the mode and has to swap the
            # page. The page only -- nothing was *picked*, so this must not go
            # back to the window as a mode the user asked for.
            self._show_page(LAYER2_TAB)

    def offer_custom(self, available: bool) -> None:
        """Arm or grey the Custom Tiles tab -- :meth:`offer_layer2`'s twin for
        the cartridge's side of the question.

        Greyed means the loaded cartridge does not carry the custom-tiles
        feature, and so has none of the four objects the tab places with.
        Greying it while it is open steps back to the record tab last in
        front: the page behind a greyed tab is one no click could have
        reached, and leaving it there would offer placements the cartridge
        cannot draw.

        Both the tab and the record it should return to are read before the
        greying, because disabling the open tab makes Qt move to whichever
        neighbour is enabled -- the sprites, from here -- and that move
        arrives as a tab the user picked and takes :attr:`_records_tab` with
        it.
        """
        open_here = self._tabs.currentIndex() == CUSTOM_TAB
        records = self._records_tab
        self._tabs.setTabEnabled(CUSTOM_TAB, available)
        if not available and open_here:
            self._open(records)

    def pick_up_custom(self, entry: Entry, tile: int) -> None:
        """Open the Custom Tiles tab on ``tile`` and put ``entry`` in hand:
        the eyedropper over a direct-tile object already in the level.

        Through the page's own pick-up, so the grid, the hint line and the
        panel's hand all say what a pick by hand would say. Refused where
        the tab is greyed, exactly as :meth:`show_tab` refuses: a cartridge
        without the feature cannot place one of these.
        """
        if not self.offers_custom:
            return
        self._open(CUSTOM_TAB)
        self.custom.pick_up(entry, tile)

    def _custom_armed(self, entry: Entry) -> None:
        """The Custom Tiles page armed an entry: it is the panel's hand now,
        said on the one signal every placement arrives on."""
        self._armed = entry
        self._list.clearSelection()
        self.armed.emit(entry)

    def _tab_changed(self, index: int) -> None:
        """The open tab moved: show its page, and say what it places.

        Said on every switch rather than only on the ones that cross the
        editing boundary, because "which mode does this tab place in" is the
        one question the window has to answer and answering it twice for the
        same mode costs a comparison it already makes.
        """
        if index not in (LAYER2_TAB, CUSTOM_TAB):
            self._records_tab = index
        self._show_page(index)
        self.editing_picked.emit(TAB_EDITING[max(0, index)])

    def _show_page(self, index: int) -> None:
        """Put the page tab ``index`` offers behind the tab bar, and fill it.

        Two tabs and sometimes three share the catalogue page -- see
        :data:`LAYER2_TAB` -- so which page a tab shows is a question about the
        level as well as about the tab.
        """
        if index == CUSTOM_TAB:
            self._pages.setCurrentIndex(CUSTOM_PAGE)
            return
        catalogue = index != LAYER2_TAB or self._layer2_records
        if catalogue:
            self._refill()
        self._pages.setCurrentIndex(0 if catalogue else 1)

    def set_catalog(self, catalog: dict[Stream, Sequence[Entry]]) -> None:
        """Offer this catalogue, replacing whatever was there.

        Handed in rather than built here, because an object list belongs to a
        **tileset** -- the same number is a different object in a different one
        -- and which tileset is in front of you is the window's to know. An empty
        catalogue switches the panel off, which is what having no level open
        means.
        """
        self._catalog = {stream: tuple(catalog.get(stream, ())) for stream in STREAMS}
        loaded = any(self._catalog.values())
        self.setEnabled(loaded)
        if not loaded:
            # Nothing to place, so nothing may stay in hand: an entry armed
            # against the last level's tileset is an object number that means
            # something else now.
            self.disarm()
        self._refill()

    def set_used(self, keys: Collection[CatalogKey]) -> None:
        """Which entries the loaded level already holds.

        Re-sent as the level is edited, since placing the first Chuck in a level
        is exactly what makes the answer change. The list is only rebuilt when
        the filter that reads this is on, because otherwise nothing on screen
        depends on it.
        """
        used = frozenset(keys)
        if used == self._used:
            return
        self._used = used
        if self._used_only.isChecked():
            self._refill()

    def set_art(self, verdicts: Mapping[CatalogKey, Art]) -> None:
        """Whether each entry's graphics will be loaded where it is placed.

        Handed in for the reason the catalogue is: the answer needs the whole
        cartridge's index and the level's *sprite* tileset -- a different header
        field from the one that picked the objects -- and neither belongs to a
        panel. Entries not named are settled, which is every object.
        """
        art = dict(verdicts)
        if art == self._art:
            return
        self._art = art
        self._refill()

    # -- what is in hand ----------------------------------------------------

    def arm(self, entry: Entry | None) -> None:
        """Put ``entry`` in hand, or ``None`` to put down what is there.

        Idempotent, which is what lets a double click and a press of Enter both
        arrive at the same row without the second one undoing the first.
        """
        if entry == self._armed:
            return
        self._armed = entry
        self._show_state()
        if entry is not None:
            self.armed.emit(entry)

    def rearm(self, entry: Entry) -> None:
        """Hold ``entry`` in place of what is in hand, **without saying so**:
        the same row, its placement reshaped by the keys. The window did
        the reshaping and already knows; the row stays highlighted."""
        self._armed = entry
        self._show_state()

    def disarm(self) -> None:
        """Put down what is in hand, **without saying so**.

        What the window calls once a placement has been made or cancelled: it
        already knows, and an :attr:`armed` round trip back into it would be the
        panel telling it what it had just decided. The row is unhighlighted here,
        because the highlight is the panel's own way of saying what is in hand.
        """
        self._armed = None
        self._list.clearSelection()
        self._list.setCurrentItem(None)
        self.custom.disarm()
        self._show_state()

    def focus_search(self) -> None:
        """Put the keyboard in the search box, with what is there selected.

        Selected rather than appended to, for
        :meth:`~shiny_mushroom.ui.find_bar.FindBar.focus_query`'s reason -- the
        box here is the one that would quietly search for ``koopachuck``.
        """
        self._search.setFocus(Qt.FocusReason.ShortcutFocusReason)
        self._search.selectAll()

    # -- filling the list ---------------------------------------------------

    def _chose_category(self) -> None:
        self._categories[self.stream] = self._category.currentData()
        self._refill()

    def _refill(self) -> None:
        """Rebuild the list from the catalogue and the three filters.

        Whole rather than incremental: it is a few hundred rows of one-line text,
        the filters change together as often as they change at all, and a diff
        would be a second description of what is on show that could disagree with
        the first.

        **The search box is not cleared on a tab switch.** Someone who has typed
        "koopa" and switches tabs is asking the same question of the other
        stream, and a box that emptied itself would be answering a different one.

        The armed row keeps its highlight where it survives the filters, and
        **stays armed where it does not**: what is in hand is not a property of
        what the list happens to be showing, and a search typed after picking
        something up must not put it down.
        """
        stream = self.stream
        if stream is None:
            # The background's page is not filled from a catalogue, and the
            # filters above the list are not on screen to have moved.
            return
        entries = self._catalog[stream]
        self._offer_categories(entries)
        category = self._categories[stream]
        query = self._search.text()
        self._list.clear()
        self._hidden = 0
        for entry in entries:
            if category and entry.category != category:
                continue
            if self._used_only.isChecked() and entry.key not in self._used:
                continue
            if not entry.matches(query):
                continue
            art = self._art.get(entry.key, Art.SETTLED)
            # Counted before it is dropped, and only when it passed everything
            # else: "12 hidden" has to mean twelve rows this filter took, not
            # twelve the search did not match.
            if art is Art.ELSEWHERE and self._with_art.isChecked():
                self._hidden += 1
                continue
            self._list.addItem(self._row(entry, art))
            # By key: what is in hand may carry a picked-up record's
            # properties, and it is still this row.
            if self._armed is not None and entry.key == self._armed.key:
                self._list.setCurrentItem(self._list.item(self._list.count() - 1))
        self._show_state()

    def _row(self, entry: Entry, art: Art) -> QListWidgetItem:
        """One list row: the entry, and its badge where it has something to say.

        The badge is part of the text rather than a second widget. A row is one
        line either way, and a delegate drawing a coloured pill would be a lot of
        painting for a word that is on at most a handful of rows once the filter
        above has done its work.
        """
        badge = ART_LABELS.get(art)
        item = QListWidgetItem(
            entry.label if badge is None else f"{entry.label}   [{badge[0]}]"
        )
        item.setData(Qt.ItemDataRole.UserRole, entry)
        tip = f"{entry.name} ({entry.id_text}) - {entry.category}"
        item.setToolTip(tip if badge is None else f"{tip}\n\n{badge[1]}")
        return item

    def _offer_categories(self, entries: Sequence[Entry]) -> None:
        """Put this tab's categories in the filter box, keeping its choice.

        Read off the catalogue rather than off the enums, so a tileset whose
        objects happen to be all of one kind offers one row and not three that
        find nothing -- and so the sprite tab offers only the thirteen
        categories its entries actually use.

        Rebuilt only when the list actually changes -- a tab switch, a
        new cartridge -- rather than on every keystroke in the search box, which
        is what calls the filler this sits in.
        """
        categories = sorted({entry.category for entry in entries})
        chosen = self._categories[self.stream]
        offered = [
            self._category.itemData(row) for row in range(self._category.count())
        ]
        if offered != ["", *categories]:
            self._category.blockSignals(True)
            self._category.clear()
            self._category.addItem(ALL_CATEGORIES, "")
            for name in categories:
                self._category.addItem(name, name)
            self._category.blockSignals(False)
        found = self._category.findData(chosen)
        self._category.setCurrentIndex(max(0, found))
        if found < 0:
            # A category this tab does not offer. Dropped rather than kept
            # sight, so the box and the list cannot disagree about what is being
            # filtered.
            self._categories[self.stream] = ""

    def _picked(self, item: QListWidgetItem) -> None:
        self.arm(item.data(Qt.ItemDataRole.UserRole))

    # -- the hover preview --------------------------------------------------

    def set_previews(
        self,
        previews: Mapping[CatalogKey, QImage],
        keep_showing: bool = False,
    ) -> None:
        """A picture of each entry, by :attr:`Entry.key`.

        Rendered by the window out of the level's own memories, because that is
        where the graphics are -- see :mod:`shiny_mushroom.preview`.

        Replacing the set puts down whatever is on screen: the pictures belong
        to a level, and one left up over the next level's catalogue would be of
        the last one's graphics.

        ``keep_showing`` is what an *arrival* passes. A picture the pointer is
        waiting for lands here a round trip after it was asked for, and taking
        the popup down at that moment would be hiding the very thing that has
        just turned up. The row under the pointer is re-shown instead.
        """
        self._previews = dict(previews)
        if not keep_showing:
            self._hide_preview()
        elif self._resting is not None:
            self._show_preview()

    @property
    def preview(self) -> HoverPreview:
        """The popup, for tests and for anything that needs to place it."""
        return self._preview

    def _hovered(self, item: QListWidgetItem) -> None:
        """The pointer moved onto a row: show its picture, now.

        **Nothing waits on a timer.** Every picture the panel can show is
        already rendered and in hand -- it is handed the whole set, see
        :meth:`set_previews` -- so a delay before showing one would be a delay
        and nothing else, paid again on every row of a list somebody is reading
        down.

        The popup is replaced in one move rather than hidden and shown again,
        which is what keeps moving along the list from strobing; a row with no
        picture takes it down, so the pointer is never beside a picture of
        something it is no longer on.
        """
        entry = item.data(Qt.ItemDataRole.UserRole)
        if entry == self._resting:
            return
        self._resting = entry
        self._show_preview()

    def _show_preview(self) -> None:
        """Show what there is for the row under the pointer, if there is
        anything.

        Nothing at all for an entry with no render, rather than an empty frame:
        the panel's job here is to show a picture, and "there is no picture of
        this" is said by there being no popup.
        """
        if self._resting is None or not self.isVisible():
            return
        image = self._previews.get(self._resting.key)
        if image is None:
            # Nothing rendered for this row. Ask for one -- but only once the
            # pointer has stayed, because that ask costs an emulator round trip
            # and a pointer crossing the list on its way somewhere else is not a
            # request for two hundred of them. Nothing on screen in the
            # meantime, which is what a row with no picture looks like anyway.
            self._preview.hide()
            self._rest.start()
            return
        self._rest.stop()
        # The panel's own rectangle in screen coordinates, so the popup can pin
        # itself to the edge of the dock rather than to the list inside it --
        # and the pointer, whose y is the only part that decides the height.
        self._preview.show_image(
            image, QRect(self.mapToGlobal(QPoint(0, 0)), self.size()), QCursor.pos()
        )

    def _ask_for_preview(self) -> None:
        """The pointer has stayed on a row that has nothing to show. Ask.

        Said once per row rather than once per mouse event, and only about a row
        still under the pointer: the timer outlives a pointer that has moved on,
        and the row it moved on to has already asked for itself.
        """
        if self._resting is None or not self.isVisible():
            return
        if self._resting.key not in self._previews:
            self.wants_preview.emit(self._resting)

    def _hide_preview(self) -> None:
        """Put the popup down, and forget the row -- so an ask that was pending
        for it does not go out after the pointer has left."""
        self._rest.stop()
        self._resting = None
        self._preview.hide()

    def leaveEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        """The pointer left the panel: there is no row under it any more."""
        self._hide_preview()
        super().leaveEvent(event)

    def hideEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        """...and a popup must not outlive the panel it belongs to -- closing
        the dock or switching to the properties tab would otherwise leave a
        frameless window on the screen with nothing to dismiss it."""
        self._hide_preview()
        super().hideEvent(event)

    def _show_state(self) -> None:
        """Put what is in hand, or what is missing, on the hint line."""
        if not any(self._catalog.values()):
            self._hint.setText(NO_LEVEL)
            return
        if self._armed is None:
            note = "" if self._list.count() else NO_MATCHES
            if self._hidden:
                note += HIDDEN.format(count=self._hidden)
            self._hint.setText(NOTHING_ARMED + note)
            return
        self._hint.setText(ARMED.format(what=self._armed.label))
