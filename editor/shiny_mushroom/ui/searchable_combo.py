"""A dropdown with section headings and a search field.

A plain :class:`QComboBox` answers a list of five hundred entries with one
unbroken column: finding a level whose number you half-remember means scrolling
past four hundred you do not want, and there is nowhere to say that the last
seventy-four are a different kind of thing from the rest.

So this adds the two things such a list needs and Qt's own popup has nowhere to
put -- a **search field** and **section headings** -- by replacing the popup
rather than the widget. :class:`SearchableComboBox` is still a ``QComboBox``:
the items live in its own model, ``currentData`` / ``findData`` /
``setCurrentIndex`` and the ``activated`` / ``currentIndexChanged`` signals all
behave as before, so a caller that fills one and reads it back needs to know
nothing about any of this.

A row may carry a **detail** (:data:`DETAIL_ROLE`): words the popup shows
beside the row and the search looks through, which the closed button does not.
That is what lets the level picker read ``$009`` on a toolbar the width of a
level number and still show, and be found by, the file that level comes out of.
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence
from typing import cast

from PySide6.QtCore import QEvent, QModelIndex, QObject, QPoint, Qt
from PySide6.QtGui import QKeyEvent, QStandardItem, QStandardItemModel
from PySide6.QtWidgets import (
    QAbstractItemView,
    QComboBox,
    QFrame,
    QLineEdit,
    QListView,
    QVBoxLayout,
    QWidget,
)

#: Marks a row as a heading rather than a choosable entry. A private sentinel
#: rather than ``None``, because ``None`` is a *value* a picker may store, and a
#: heading answering to ``findData(None)`` would have that selected onto it.
_HEADING = object()

#: The popup row's index back into the combo's own model. The two lists differ
#: whenever a search is narrowing the popup, so a picked row has to say which
#: entry it stands for rather than being trusted as a position.
_SOURCE_ROW = Qt.ItemDataRole.UserRole + 1

#: A row's detail: shown after its text in the popup, searched along with it,
#: and absent from the closed button -- which reads as the row's text alone.
DETAIL_ROLE = Qt.ItemDataRole.UserRole + 2

#: What separates a row's text from its detail in the popup. Wide enough to
#: read as two columns rather than one run-on label.
DETAIL_GAP = "   "

#: How many rows the popup shows before it scrolls. Sixteen is about a third of
#: a 1080p screen: enough that a short list never scrolls at all, short enough
#: that a long one still reads as a dropdown rather than a second window.
MAX_VISIBLE_ROWS = 16

#: Below this many entries the popup is Qt's own. A search field over six items
#: costs a row of space and a keystroke to skip. The threshold is on the *item*
#: count; a list with headings always gets ours, since Qt's popup has nowhere to
#: draw them.
SEARCH_THRESHOLD = 8


def matches_search(text: str, needles: Sequence[str]) -> bool:
    """Whether ``text`` contains every word of the search, in any order.

    Word-wise rather than one substring so "donut 2" finds
    "Level009_DonutPlains2_Main": a name puts the place, the number and which
    room it is in an order the reader has no reason to have memorised, and a
    literal-substring search makes them reproduce it.
    """
    lowered = text.lower()
    return all(needle in lowered for needle in needles)


def _as_heading(item: QStandardItem) -> QStandardItem:
    """Make ``item`` a section title, and hand it back.

    Bold, and disabled -- so it cannot be clicked or arrowed onto, Qt's own
    keyboard and wheel stepping do not stop on it, and the style greys it, which
    is the whole of the visual distinction a heading needs. Said once for the
    two lists a heading appears in: the combo's own model and the popup's copy
    of it.
    """
    font = item.font()
    font.setBold(True)
    item.setFont(font)
    item.setFlags(Qt.ItemFlag.NoItemFlags)
    return item


class SearchableComboBox(QComboBox):
    """A combo whose popup carries a search field and section headings.

    Fill it with :func:`fill_sections`, or with :meth:`add_heading` and the
    ordinary ``addItem``, which is what that does. A heading is an item like any
    other so the model stays one flat list -- it is simply not selectable, and
    every path that could land on one steps over it: :meth:`add_heading` refuses
    to leave one current, Qt's arrow-key and wheel stepping passes over disabled
    items, and the popup's list cannot select one.

    The popup is a top-level ``Qt.Popup`` rather than Qt's combo view, because
    the search field has to live *inside* the thing that closes when you click
    away. Clicking outside dismisses it, as it would Qt's own.
    """

    def __init__(
        self, offers_search: bool = True, parent: QWidget | None = None
    ) -> None:
        super().__init__(parent)
        #: Whether a long list opens the search popup or Qt's own. True is the
        #: whole point of this widget; false is for a caller that wants a
        #: picker of this class over a list nobody would search. A list
        #: carrying headings opens the search popup either way, since Qt's own
        #: has nowhere to put them -- and so keeps the details with them.
        self.offers_search = offers_search
        self._popup: QFrame | None = None
        self._search: QLineEdit | None = None
        self._list: QListView | None = None
        self._popup_model: QStandardItemModel | None = None
        # Where the popup was anchored, so a rebuild that changes its height
        # grows it away from the combo rather than sliding it over the control.
        self._flipped_above = False
        self._has_headings = False

    # -- filling -------------------------------------------------------------

    def add_heading(self, title: str) -> None:
        """Append a heading; the items added after it fall under it.

        The heading also has to not be *selected*: a combo auto-selects the
        first item inserted into an empty one, so a list whose first row is a
        heading would open reading its own section name -- hence the
        deselection below, undone by the first real item that follows.
        """
        self.addItem(title, _HEADING)
        row = self.count() - 1
        item = self._model_item(row)
        if item is not None:
            _as_heading(item)
        if self.currentIndex() == row:
            self.setCurrentIndex(-1)
        self._has_headings = True

    def clear(self) -> None:  # noqa: N802 - Qt's name
        super().clear()
        self._has_headings = False

    def is_heading(self, row: int) -> bool:
        """Whether ``row`` is a section heading rather than a choice."""
        return self.itemData(row) is _HEADING

    def first_choice(self) -> int:
        """The first row that is an actual choice, or -1 when there is none.

        The fallback for "select something": a list's first row may be a
        heading, so ``setCurrentIndex(0)`` is not the safe default it was.
        """
        return next(
            (row for row in range(self.count()) if not self.is_heading(row)), -1
        )

    def step_from(self, row: int, delta: int) -> int:
        """The row ``delta`` choices along from ``row``, or -1 past the end.

        What a Previous/Next pair outside the widget needs: the rows between two
        choices may be headings, and stepping onto one would select a title.
        """
        while True:
            row += delta
            if row < 0 or row >= self.count():
                return -1
            if not self.is_heading(row):
                return row

    def _model_item(self, row: int) -> QStandardItem | None:
        model = self.model()
        return model.item(row) if isinstance(model, QStandardItemModel) else None

    def _detail(self, row: int) -> str:
        """The words a row carries beyond its text, or empty."""
        return self.itemData(row, DETAIL_ROLE) or ""

    def _popup_label(self, row: int) -> str:
        """How the popup writes a row: its text, then its detail."""
        detail = self._detail(row)
        return (
            f"{self.itemText(row)}{DETAIL_GAP}{detail}"
            if detail
            else self.itemText(row)
        )

    # -- the popup -----------------------------------------------------------

    def showPopup(self) -> None:  # noqa: N802 - Qt's name
        """Open the search popup -- or Qt's own, for a list too short to search."""
        if self._popup is not None:
            return
        if not self._has_headings and (
            not self.offers_search or self.count() < SEARCH_THRESHOLD
        ):
            super().showPopup()
            return
        self._build_popup()
        self._rebuild("")
        self._place_popup()
        assert self._popup is not None and self._search is not None
        self._popup.show()
        self._search.setFocus(Qt.FocusReason.PopupFocusReason)

    def hidePopup(self) -> None:  # noqa: N802 - Qt's name
        self._close_popup()
        super().hidePopup()

    def _build_popup(self) -> None:
        popup = QFrame(self, Qt.WindowType.Popup)
        popup.setFrameShape(QFrame.Shape.StyledPanel)
        column = QVBoxLayout(popup)
        column.setContentsMargins(2, 2, 2, 2)
        column.setSpacing(2)

        search = QLineEdit()
        search.setPlaceholderText("Search")
        search.setClearButtonEnabled(True)
        search.textChanged.connect(self._rebuild)
        search.returnPressed.connect(self._activate_current)
        # The arrow keys have to reach the list while the text cursor stays in
        # the field, so they are intercepted rather than routed by focus.
        search.installEventFilter(self)
        column.addWidget(search)

        view = QListView()
        view.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        view.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        view.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        model = QStandardItemModel(view)
        view.setModel(model)
        view.clicked.connect(self._on_row_clicked)
        column.addWidget(view)

        # Qt closes a popup on a click outside without going through hidePopup,
        # so the teardown hangs off the hide itself or the widget leaks and the
        # next open would find a stale one.
        popup.installEventFilter(self)
        self._popup, self._search, self._list, self._popup_model = (
            popup,
            search,
            view,
            model,
        )

    def _close_popup(self) -> None:
        popup, self._popup = self._popup, None
        self._search = self._list = self._popup_model = None
        if popup is not None:
            popup.removeEventFilter(self)
            popup.hide()
            popup.deleteLater()

    def _rebuild(self, text: str) -> None:
        """Refill the popup's list for the current search text.

        A heading is emitted only once one of its items has survived the search,
        which is what stops a narrowed list from being a column of empty
        sections -- and why the source list is walked in order rather than
        filtered and regrouped.
        """
        view, model = self._list, self._popup_model
        if view is None or model is None:
            return
        needles = text.lower().split()
        model.clear()
        pending = -1
        for row in range(self.count()):
            if self.is_heading(row):
                pending = row
                continue
            if not matches_search(self._popup_label(row), needles):
                continue
            if pending >= 0:
                model.appendRow(self._popup_heading(pending))
                pending = -1
            item = QStandardItem(self._popup_label(row))
            item.setData(row, _SOURCE_ROW)
            tip = self.itemData(row, Qt.ItemDataRole.ToolTipRole)
            if tip:
                item.setData(tip, Qt.ItemDataRole.ToolTipRole)
            model.appendRow(item)
        self._select_popup_row(self._popup_row_for(self.currentIndex()))
        self._resize_list()

    def _popup_heading(self, source_row: int) -> QStandardItem:
        """The popup's copy of the heading at ``source_row``.

        Its tooltip comes with it. A heading that says what its section *means*
        is read here or nowhere: a list long enough to be searched never opens
        Qt's own popup, which is the only other place these rows are shown.
        """
        item = _as_heading(QStandardItem(self.itemText(source_row)))
        tip = self.itemData(source_row, Qt.ItemDataRole.ToolTipRole)
        if tip:
            item.setData(tip, Qt.ItemDataRole.ToolTipRole)
        return item

    def _popup_row_for(self, source_row: int) -> int:
        """Where ``source_row`` sits in the popup now, or the first choice."""
        model = self._popup_model
        if model is None:
            return -1
        first = -1
        for row in range(model.rowCount()):
            data = model.item(row).data(_SOURCE_ROW)
            if data is None:
                continue
            if first < 0:
                first = row
            if data == source_row:
                return row
        return first

    def _select_popup_row(self, row: int) -> None:
        view, model = self._list, self._popup_model
        if view is None or model is None or row < 0 or row >= model.rowCount():
            return
        index = model.index(row, 0)
        view.setCurrentIndex(index)
        view.scrollTo(index, QAbstractItemView.ScrollHint.EnsureVisible)

    def _step_popup_row(self, delta: int) -> None:
        """Move the highlight ``delta`` choices along, stepping over headings."""
        view, model = self._list, self._popup_model
        if view is None or model is None:
            return
        row = view.currentIndex().row()
        row = row if row >= 0 else -1 if delta > 0 else model.rowCount()
        while True:
            row += delta
            if row < 0 or row >= model.rowCount():
                return
            if model.item(row).data(_SOURCE_ROW) is not None:
                self._select_popup_row(row)
                return

    def _resize_list(self) -> None:
        """Fit the popup to what the search left, up to :data:`MAX_VISIBLE_ROWS`.

        Re-measured per keystroke so a narrowed list is a small box rather than
        one mostly empty, and re-anchored the way the popup opened: a popup that
        had to flip above the combo keeps its *bottom* edge on the control, so
        the frame never slides across the picker it belongs to.
        """
        view, model, popup = self._list, self._popup_model, self._popup
        if view is None or model is None or popup is None:
            return
        # The edge to anchor to, read before anything can move the frame -- see
        # the activate() below, which does exactly that.
        bottom = popup.geometry().bottom()
        rows = model.rowCount()
        unit = view.sizeHintForRow(0) if rows else view.fontMetrics().height() + 4
        shown = max(1, min(rows, MAX_VISIBLE_ROWS))
        view.setFixedHeight(shown * unit + 2 * view.frameWidth())
        # The popup is a top-level, so its layout pins the window's *minimum*
        # size to the layout's own -- but only when the layout next activates,
        # which is otherwise a posted event away. Left until then, the geometry
        # below is clamped to the previous, taller list's minimum: the frame
        # keeps its height and the layout spreads the search field and the
        # shrunken list through the excess, so a search that matched nothing
        # reads as a lone field adrift in an empty panel.
        layout = popup.layout()
        if layout is not None:
            layout.activate()
        # One setGeometry rather than a resize and a move, using the height we
        # asked for rather than one read back: raising a window's minimum resizes
        # it there and then, so by this point the frame may already have grown.
        height = popup.sizeHint().height()
        y = bottom - height + 1 if self._flipped_above else popup.y()
        popup.setGeometry(popup.x(), y, popup.width(), height)

    def _place_popup(self) -> None:
        """Size the popup to its content and put it under (or over) the combo."""
        popup, view = self._popup, self._list
        if popup is None or view is None:
            return
        # The button may be narrower than the longest item, so the popup is
        # widened back to the content -- the same trade Qt's own popup gets
        # there, for the same reason.
        width = max(
            self.width(),
            view.sizeHintForColumn(0) + view.verticalScrollBar().sizeHint().width() + 8,
        )
        popup.resize(width, popup.sizeHint().height())
        below = self.mapToGlobal(self.rect().bottomLeft())
        screen = self.screen().availableGeometry()
        x = max(screen.left(), min(below.x(), screen.right() - popup.width() + 1))
        y = below.y()
        self._flipped_above = False
        if y + popup.height() > screen.bottom():
            above = self.mapToGlobal(self.rect().topLeft()).y() - popup.height()
            if above >= screen.top():
                y, self._flipped_above = above, True
            else:
                y = max(screen.top(), screen.bottom() - popup.height() + 1)
        popup.move(QPoint(x, y))

    # -- choosing ------------------------------------------------------------

    def _on_row_clicked(self, index: QModelIndex) -> None:
        source = index.data(_SOURCE_ROW)
        if source is not None:
            self._choose(int(source))

    def _activate_current(self) -> None:
        view, model = self._list, self._popup_model
        if view is None or model is None:
            return
        row = view.currentIndex().row()
        if 0 <= row < model.rowCount():
            source = model.item(row).data(_SOURCE_ROW)
            if source is not None:
                self._choose(int(source))

    def _choose(self, source_row: int) -> None:
        """Commit ``source_row`` as the selection, exactly as Qt's popup would.

        ``activated`` fires even when the same entry is re-picked -- that is the
        signal's contract, and the level picker is wired to it precisely because
        re-choosing the level already shown is a meaningful gesture there.
        ``currentIndexChanged`` comes first and only on a real change, which
        ``setCurrentIndex`` takes care of.
        """
        self._close_popup()
        self.setCurrentIndex(source_row)
        self.activated.emit(source_row)
        self.textActivated.emit(self.itemText(source_row))

    # -- events --------------------------------------------------------------

    def eventFilter(self, watched: QObject, event: QEvent) -> bool:  # noqa: N802
        if watched is self._popup and event.type() == QEvent.Type.Hide:
            # Clicked away: Qt hid the popup behind our back, so tear it down
            # here or the next open finds a stale one.
            self._close_popup()
            return False
        if watched is self._search and event.type() == QEvent.Type.KeyPress:
            # The type guarantee is the event *type* check above, not the static
            # annotation: Qt hands every filtered event over as a base QEvent.
            return self._on_search_key(cast(QKeyEvent, event))
        return super().eventFilter(watched, event)

    def _on_search_key(self, event: QKeyEvent) -> bool:
        """Steer the list from the search field; True when the key was ours."""
        key = event.key()
        if key in (Qt.Key.Key_Down, Qt.Key.Key_Up):
            self._step_popup_row(1 if key == Qt.Key.Key_Down else -1)
            return True
        if key in (Qt.Key.Key_PageDown, Qt.Key.Key_PageUp):
            step = 1 if key == Qt.Key.Key_PageDown else -1
            for _ in range(MAX_VISIBLE_ROWS):
                self._step_popup_row(step)
            return True
        if key == Qt.Key.Key_Escape:
            self._close_popup()
            return True
        return False


def fill_sections(
    combo: SearchableComboBox,
    rows: Iterable[tuple[str, str, object, str]],
    selected: object = None,
) -> None:
    """Refill ``combo`` from ``(section, label, data, detail)`` rows, in order.

    A heading is emitted whenever the section changes, so the caller's order is
    the whole of the grouping; a row with an empty section gets no heading.
    ``detail`` is what the popup writes beside the row and the search looks
    through -- empty for a row that is only its label.

    ``selected`` is snapped to when the refilled list still holds it, and
    otherwise falls back to the first real choice. It is applied at the end
    rather than per-item because a heading must never be left current, and the
    first row inserted into an empty combo *is* current until something says
    otherwise.

    Signals are the caller's to block: which repopulations are a user change and
    which are a restore is a question only the caller can answer.
    """
    combo.clear()
    heading = None
    for section, label, data, detail in rows:
        if section and section != heading:
            combo.add_heading(section)
        heading = section
        combo.addItem(label, data)
        if detail:
            combo.setItemData(combo.count() - 1, detail, DETAIL_ROLE)
    index = combo.findData(selected)
    combo.setCurrentIndex(index if index >= 0 else combo.first_choice())
