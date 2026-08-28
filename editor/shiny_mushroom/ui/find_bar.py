"""The search bar: find an object or a sprite anywhere in the cartridge.

Along the bottom of the window rather than in a dialog, because a search here is
not a question asked once -- it is stepped through. Every answer moves the
canvas to a different level, and a modal that had to be dismissed to see what it
found and reopened to find the next one would be in the way of the only thing
anybody does with it.

The bar owns **where in the results you are** and nothing else. It is handed a
:class:`~shiny_mushroom.index.LevelIndex`, works out which occurrences match,
and asks for one; getting there -- loading a level, selecting the record,
scrolling to it -- belongs to whoever owns the document, exactly as picking a
level does in :mod:`~shiny_mushroom.ui.level_bar`.

Three kinds, because an id means three different things: ``$0E`` is a tileset
object, an extended object and a sprite at once, and none of the three is in the
same place as the others.
"""

from __future__ import annotations

from PySide6.QtCore import QRegularExpression, Qt, Signal
from PySide6.QtGui import QRegularExpressionValidator
from PySide6.QtWidgets import QComboBox, QLabel, QLineEdit, QToolBar, QWidget

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.index import LevelIndex, Occurrence, SearchKind
from shiny_mushroom.ui.toolbars import add_action

#: What may be typed in the id box: two hex digits, with the ``$`` the rest of
#: the app writes them with allowed and ignored. A validator rather than a
#: complaint on submit -- the field is two characters wide and there is nothing
#: to explain about a keystroke that simply does not appear.
ID_PATTERN = r"\$?[0-9A-Fa-f]{0,2}"

#: Wide enough for ``$FF`` and no wider. The box is a two-digit number, and one
#: stretched across a toolbar reads as somewhere to type a sentence.
ID_WIDTH = 56

#: What the readout says with nothing being searched for. Not blank: the bar is
#: visible whether or not it is in use, and an empty strip beside two dead
#: buttons reads as broken rather than as idle.
IDLE = "Type an id to search"


def parse_id(text: str) -> int | None:
    """The number ``text`` names, or ``None`` if it names none.

    Hex without being asked, because every id in this application is written in
    hex: an object is ``$1F``, a sprite is ``$C7``, and a search box that read
    ``19`` as nineteen would find the wrong thing silently.
    """
    text = text.strip().removeprefix("$")
    try:
        return int(text, 16)
    except ValueError:
        return None


class FindBar(QToolBar):
    """Steps through every place an id occurs. Owns no level and no cartridge."""

    #: Go and look at this occurrence. Whoever is listening decides what that
    #: costs -- it is usually a level load.
    jump_requested = Signal(object)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Find", parent)
        self.setObjectName("find-bar")
        self.setMovable(False)

        self._index = LevelIndex()
        self._matches: tuple[Occurrence, ...] = ()
        # Which match is being shown, or -1 for "the search has not been stepped
        # yet". Distinct from 0 on purpose: the first Next should show the first
        # match rather than the second, and a plain counter cannot say that.
        self._at = -1

        self._kinds = QComboBox()
        for kind in SearchKind:
            self._kinds.addItem(kind.label, kind)
        self._kinds.activated.connect(lambda _index: self._search())

        self._id = QLineEdit()
        self._id.setValidator(
            QRegularExpressionValidator(QRegularExpression(ID_PATTERN), self)
        )
        self._id.setFixedWidth(ID_WIDTH)
        self._id.setPlaceholderText("$00")
        self._id.textChanged.connect(lambda _text: self._search())
        # Enter steps rather than re-searching: by the time it is pressed the
        # search has already run on the keystrokes, so the only thing left to
        # ask for is the next one.
        self._id.returnPressed.connect(self.find_next)

        # What the id is called, where that can be said at all. A standard
        # object's name is a property of the level's tileset and a search spans
        # every tileset in the cartridge, so there is no answer for one -- see
        # SearchKind.name_of.
        self._name = QLabel()
        self._name.setTextFormat(Qt.TextFormat.PlainText)

        self.addWidget(QLabel("Find "))
        self.addWidget(self._kinds)
        self.addWidget(QLabel(" id "))
        self.addWidget(self._id)
        self.addWidget(self._name)
        self._previous = add_action(self, "&Previous", self.find_previous)
        self._next = add_action(self, "&Next", self.find_next)

        self._readout = QLabel()
        self.addWidget(self._readout)

        self.setEnabled(False)
        self._update()

    # -- what is being searched ---------------------------------------------

    @property
    def kind(self) -> SearchKind:
        """Which of the three streams is being searched."""
        return self._kinds.currentData()

    @property
    def number(self) -> int | None:
        """The id typed, or ``None`` while the box does not name one."""
        return parse_id(self._id.text())

    @property
    def matches(self) -> tuple[Occurrence, ...]:
        """Everywhere the current id occurs, in level order."""
        return self._matches

    @property
    def at(self) -> int:
        """Which match was last asked for, or ``-1`` before any was."""
        return self._at

    def set_index(self, index: LevelIndex) -> None:
        """Search this cartridge from now on.

        An empty index switches the bar off rather than leaving it answering
        "no matches" for everything -- there is nothing loaded to search, which
        is a different statement.
        """
        self._index = index
        self.setEnabled(bool(index))
        self._search()

    def set_kind(self, kind: SearchKind) -> None:
        """Search this stream, without asking for anything."""
        found = self._kinds.findData(kind)
        if found >= 0:
            self._kinds.setCurrentIndex(found)
            self._search()

    def set_number(self, number: int) -> None:
        """Put an id in the box, as the rest of the app writes one."""
        self._id.setText(hexnum(number))

    def focus_query(self) -> None:
        """Put the keyboard in the id box, with what is there selected.

        Selected rather than appended to, because reaching for the search a
        second time almost always means looking for something else -- and a
        field that has to be cleared first is one that quietly searches for
        ``$1F1E``.
        """
        self._id.setFocus(Qt.FocusReason.ShortcutFocusReason)
        self._id.selectAll()

    # -- stepping through it -------------------------------------------------

    def find_next(self) -> None:
        self._step(+1)

    def find_previous(self) -> None:
        self._step(-1)

    def _step(self, direction: int) -> None:
        """Move to the next match along and ask for it.

        Wraps, in both directions. A search is a ring rather than a list with
        ends: the whole point is to visit every place an object occurs, and
        stopping at the last one would mean starting over by hand.

        The first step forwards lands on the **first** match and the first step
        backwards on the **last**, which is what ``_at == -1`` buys: without it a
        fresh search would either skip its own first result or need the cursor
        seeded differently depending on which button was pressed.
        """
        if not self._matches:
            return
        if self._at < 0:
            self._at = 0 if direction > 0 else len(self._matches) - 1
        else:
            self._at = (self._at + direction) % len(self._matches)
        self._update()
        self.jump_requested.emit(self._matches[self._at])

    def _search(self) -> None:
        """Re-run the search and forget where in the last one we were.

        Called on every keystroke, which it can afford to be: the index is a
        dictionary and this is one lookup. The cursor is reset because a
        different search has different results, and keeping the position would
        mean "the third one" pointing at something nobody looked for.
        """
        number = self.number
        kind = self.kind
        if number is None or number >= kind.limit:
            self._matches = ()
        else:
            self._matches = self._index.find(kind, number)
        self._at = -1
        self._update()

    def _update(self) -> None:
        """Put the search's state on the bar: the name, the count, the buttons."""
        number = self.number
        self._name.setText("" if number is None else f" {self.kind.name_of(number)} ")
        found = bool(self._matches)
        self._previous.setEnabled(found)
        self._next.setEnabled(found)
        self._readout.setText(self._readout_text())

    def _readout_text(self) -> str:
        """The one line that says what was found and where you are in it.

        Both halves earn their place: the count is the answer to "is this
        anywhere", and the position is the answer to "have I been round yet" --
        which is the only thing that distinguishes the second lap of a search
        from the first.
        """
        number = self.number
        if number is None:
            return f"  {IDLE}"
        if number >= self.kind.limit:
            return f"  {hexnum(number)} is not a {self.kind.value} id"
        if not self._matches:
            return f"  {hexnum(number)} is in no level"
        levels = len({match.level for match in self._matches})
        found = f"{len(self._matches)} in {levels} levels"
        if self._at < 0:
            return f"  {found}"
        where = self._matches[self._at]
        seen = f"{self._at + 1} of {len(self._matches)}"
        return f"  {seen}: {where.describe()}"
