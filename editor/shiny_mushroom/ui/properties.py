"""The properties panel: what the selected thing is, and where it is edited.

A dock rather than a floating inspector because it is a *readout* of the
selection and belongs beside the picture, and on the right because that is the
side the eye is not using while working leftward through a level.

It knows nothing about objects or sprites. What a record holds, which of its
fields can be changed and what a changed one produces is declared by
:mod:`shiny_mushroom.fields` descriptors that :mod:`shiny_mushroom.objects` and
:mod:`shiny_mushroom.sprites` hand over -- so a new property, or a new *kind* of
thing to describe, appears here without this file changing. That is the whole
point of the split: the format's rules are Qt-free and testable by reading a
list back, and this is a widget factory.

**A gesture applies at once; a typed number waits until it is finished.** A
commit costs a level rebuild and a re-render through the emulator, so the two
halves of a value box are wired differently and deliberately:

- **The arrows apply immediately** -- the step buttons, Up and Down, the wheel
  in a box that has the keyboard. Each is a whole gesture that says a whole
  number, and an editor that made you press Enter after clicking an up arrow
  would be asking twice.
- **The keyboard applies when the number is done**, on Enter or on the way out
  of the box. Otherwise typing "12" into a column would move the record to
  column 1 on the way past, putting a step in the undo stack that nobody asked
  for -- and a half-typed value is meant to be harmless.

Both fall out of ``valueChanged`` with keyboard tracking off: Qt then reads the
box when the value is *interpreted*, which is every step as it happens and a
typed one only once it is committed. A dropdown has no half-typed state and so
applies on the choice.

**The panel is rebuilt only when the selection changes.** A commit changes the
record under the widgets, and tearing them down inside their own signal takes
the focus out of the box the user is still in. :meth:`PropertiesDock.refresh`
puts new values into the widgets that are already there.
"""

from __future__ import annotations

from collections.abc import Callable, MutableMapping, Sequence

from PySide6.QtCore import QSize, Qt, Signal
from PySide6.QtGui import QFontMetrics, QStandardItem, QStandardItemModel, QValidator
from PySide6.QtWidgets import (
    QCheckBox,
    QComboBox,
    QDockWidget,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QScrollArea,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.fields import (
    SEPARATOR,
    Action,
    Choice,
    Choices,
    Field,
    Flags,
    Number,
    Readout,
    Switch,
    grouped,
    label_of,
)
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.ui.searchable_combo import DETAIL_ROLE, SearchableComboBox
from shiny_mushroom.ui.tips import wrap_tip

#: Set so that the window can save and restore where the dock is.
OBJECT_NAME = "properties"

#: Shown when there is nothing to describe. Two states, because "no level" and
#: "no selection" are different situations and only one of them is fixed by
#: clicking something.
NO_LEVEL = "Load a level to see what is in it."
NOTHING_SELECTED = "Click an object or a sprite to see its properties."

#: How wide a picker is, in pixels: a stated number rather than a measurement
#: of what is in the list, because these are one kind of control and a panel of
#: them should read as a column -- what the longest name in a particular tileset
#: happens to be is not a reason for one row to be wider than another. It takes
#: the type pickers, the object's and the sprite's, whose entries are `$XX` and
#: a name; measured, those asked for 268 and 301 px.
PICKER_WIDTH = 120

#: The narrowest a picker gets. A column of pickers should read as a column, so
#: a two-word list is not sized down to the words in it.
SHORT_LIST_WIDTH = 60

#: A list of no more than this many entries is sized to **itself** between
#: :data:`SHORT_LIST_WIDTH` and :data:`PICKER_WIDTH` -- so the column still
#: lines up, a short list still cannot run away with it, and a picker is never
#: narrower than its own entry, one elided being a value the panel is hiding.
#: A pair here is a pair of *answers* -- "Layer 1" and "Layer 2"; a yes and a
#: no is a :class:`~shiny_mushroom.fields.Switch` and is not a picker at all.
SHORT_LIST_OPTIONS = 2

#: Room a popup row needs beyond its text: the item's own margins either side.
#: Measured against what Qt sizes the list to when it is left to itself.
POPUP_PADDING = 12

#: Room either side of the comma between two fields sharing a row, in pixels.
#: Enough to read as "one, the other" rather than as one long value, and not so
#: much that the pair stops reading as one row.
SEPARATOR_GAP = 6

#: The narrowest a value box gets: room for a byte, written the way the format
#: writes one. Sized to its own range, a box for a level of sixteen columns came
#: out 8 px narrower than the one under it and the panel read as a ragged edge
#: rather than a column. Anything that needs more still gets it -- a nine-bit
#: destination is ``$105`` and is given the room for it.
NARROWEST_VALUE = "$XX"


class PanelSpinBox(QSpinBox):
    """A value box in the panel: stepped now, typed later, and never narrower
    than a byte.

    The three decisions that are the panel's rather than Qt's, all of them about
    *when a number is meant*. What one is worth once it is meant belongs to the
    descriptor behind it.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        # Keyboard tracking off is the whole of the typed-versus-stepped split:
        # with it on, ``valueChanged`` fires per digit. See the module docstring.
        self.setKeyboardTracking(False)
        # No focus by wheel, and no stepping by one either (below): this panel
        # lives in a scroll area, and a value that moved because somebody
        # scrolled past it is an edit nobody made.
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    def wheelEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        """Step on the wheel only while this box has the keyboard; otherwise let
        it through, so the panel scrolls under the pointer as it would over any
        other row."""
        if self.hasFocus():
            super().wheelEvent(event)
        else:
            event.ignore()

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return self._at_least_a_byte(super().sizeHint())

    def minimumSizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return self._at_least_a_byte(super().minimumSizeHint())

    def _at_least_a_byte(self, hint: QSize) -> QSize:
        """``hint``, widened to :data:`NARROWEST_VALUE` if it is narrower.

        The box's furniture -- its frame, margins and the arrows -- is whatever
        of the hint is not the widest value it can show, so asking for a
        different text is that number plus the same furniture. Measured from
        this box rather than stated, because it is the style's and the font's.
        """
        metrics = self.fontMetrics()
        shown = max(
            metrics.horizontalAdvance(self.textFromValue(value))
            for value in (self.minimum(), self.maximum())
        )
        furniture = hint.width() - shown
        floor = metrics.horizontalAdvance(NARROWEST_VALUE) + furniture
        hint.setWidth(max(hint.width(), floor))
        return hint


def _typed(text: str) -> int:
    """What was typed into a hex box, read back -- ``$1F``, ``1f``, ``#1F`` and
    ``-$40`` all being the number they look like.

    The leading sign is taken before the ``$`` is, because that is where
    :func:`~shiny_mushroom.hexnum.hexnum` puts it and so where a value the box
    itself wrote comes back with it.
    """
    stripped = text.strip()
    sign = -1 if stripped.startswith("-") else 1
    digits = stripped.lstrip("-").lstrip("$").lstrip("#")
    return sign * int(digits or "0", 16)


class HexSpinBox(PanelSpinBox):
    """A value box that reads and writes ``$XX``.

    The format is written in hex everywhere -- object numbers, settings bytes,
    screens, the positions in every other editor for this game -- so showing a
    settings byte as ``34`` when the record says ``$22`` would make the panel
    the one place the user has to convert. The width is the field's own, so a
    nine-bit destination reads ``$105`` rather than ``$0105``.

    Rendered by :func:`~shiny_mushroom.hexnum.hexnum`, the one place a number is
    written in this notation, so a box and the readout of the same field cannot
    read differently. A field whose range reaches below zero -- an overworld
    sprite's position -- shows and takes ``-$040``, with the sign outside the
    ``$``, because that is the number it is rather than the word it is stored
    as.
    """

    def __init__(self, digits: int, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._digits = digits

    def textFromValue(self, value: int) -> str:  # noqa: N802 - Qt's name
        return hexnum(value, self._digits)

    def valueFromText(self, text: str) -> int:  # noqa: N802 - Qt's name
        try:
            return _typed(text)
        except ValueError:
            return self.value()

    def validate(  # noqa: N802 - Qt's name
        self, text: str, position: int
    ) -> tuple[QValidator.State, str, int]:
        # Deliberately permissive: an empty box is Intermediate rather than
        # Invalid, so a value can be cleared and retyped instead of having to be
        # edited digit by digit. Nothing out of range can get through -- the
        # committed value goes through valueFromText and then the field's own
        # clamp.
        stripped = text.strip().lstrip("-").lstrip("$").lstrip("#")
        if not stripped:
            return (QValidator.State.Intermediate, text, position)
        try:
            int(stripped, 16)
        except ValueError:
            return (QValidator.State.Invalid, text, position)
        return (QValidator.State.Acceptable, text, position)


class CompactComboBox(SearchableComboBox):
    """A picker of a stated width, whatever is in its list.

    A stock combo reserves room for the longest thing in it, and these lists are
    the disassembly's own names: measured, the object picker asked for 268 px
    and the sprite picker 301, against 55 for the widest of every other row in
    the panel. So the picker alone decided how wide the dock opened -- a panel
    of two-digit numbers in a column sized for "$50 Line Guide Bottom Right
    Quarter Large Circle" -- and it decided it differently for each list.

    A number rather than a measurement, because these are one kind of control
    and a panel of them should read as a column; what the longest entry in a
    particular tileset happens to be is not a reason for one row to be wider
    than another.

    Only the *hints* are narrowed, so the field still stretches to fill a dock
    the user has widened, and the popup keeps the full width of its entries --
    a name is chosen from the list, and a list of elided names is not a choice.
    The button elides what it cannot fit; the width is in device-independent
    pixels and does not follow the font, which is the trade a stated number
    makes and what the popup re-widening is there to soften.

    Built on :class:`~shiny_mushroom.ui.searchable_combo.SearchableComboBox`
    rather than on a bare combo, so a list that *is* worth searching -- the 512
    levels a screen exit can lead to -- gets the level picker's own popup
    without a second picker class existing. ``offers_search`` is off by default:
    the panel's other lists are dozens of names read straight down, and a
    search field over one costs a row of space and a keystroke to skip. Which
    lists are worth it is the descriptor's answer
    (:attr:`~shiny_mushroom.fields.Choices.searchable`).
    """

    def __init__(
        self,
        width: int | None = PICKER_WIDTH,
        offers_search: bool = False,
        parent: QWidget | None = None,
    ):
        super().__init__(offers_search, parent)
        #: The stated width, or ``None`` for Qt's own held between
        #: :data:`SHORT_LIST_WIDTH` and :data:`PICKER_WIDTH` -- see
        #: :data:`SHORT_LIST_OPTIONS`.
        self._width = width
        # No AdjustToContents: it exists to re-query the hint when the model
        # changes, and the hint no longer depends on the model.
        # No focus by wheel, and no stepping by one either (below), for
        # :class:`PanelSpinBox`'s reason -- see :meth:`wheelEvent`.
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    def wheelEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        """Change the choice on the wheel only while this box has the keyboard;
        otherwise let it through, so the panel scrolls under the pointer as it
        would over any other row.

        :class:`PanelSpinBox`'s guard, and needed harder: Qt's combo emits
        ``activated`` for a wheel step, which is the signal a choice is
        committed on -- so a scroll down a panel of these would rewrite the
        record once per row it passed and leave an undo step for each.
        """
        if self.hasFocus():
            super().wheelEvent(event)
        else:
            event.ignore()

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return self._stated(super().sizeHint())

    def minimumSizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return self._stated(super().minimumSizeHint())

    def _stated(self, hint: QSize) -> QSize:
        """``hint`` at the width asked for. The height stays Qt's own."""
        hint.setWidth(
            self._width
            if self._width is not None
            else min(max(hint.width(), SHORT_LIST_WIDTH), PICKER_WIDTH)
        )
        return hint

    def showPopup(self) -> None:  # noqa: N802 - Qt's name
        """Widen the list to its own contents before dropping it down.

        A style that sizes the popup to the button would otherwise elide every
        entry in it, which is the one place the full name is needed. Measured
        from the font rather than asked of the view: ``sizeHintForColumn``
        samples the rows it has laid out, and these lists are 256 long.
        """
        view = self.view()
        metrics = QFontMetrics(view.font())
        widest = max(
            (
                metrics.horizontalAdvance(self.itemText(row))
                for row in range(self.count())
            ),
            default=0,
        )
        room = view.verticalScrollBar().sizeHint().width() + POPUP_PADDING
        view.setMinimumWidth(max(self.width(), widest + room))
        super().showPopup()


class SharedRow(QWidget):
    """Several fields side by side in one row's field, separated by a comma.

    What a :attr:`~shiny_mushroom.fields.Field.group` looks like. A column and a
    row are one position, and two rows for it is two rows saying half a thing
    each -- so the descriptors say they belong together and this is the whole of
    what the panel does about it. Which fields those are stays the format's
    business; this knows only that it was handed more than one widget.

    Reads as one value: :meth:`text` joins them with the same separator
    :func:`~shiny_mushroom.fields.pairs` writes between them, so the panel and
    every readout say a position the same way.
    """

    def __init__(self, widgets: Sequence[QWidget], parent: QWidget | None = None):
        super().__init__(parent)
        self._widgets = list(widgets)
        layout = QHBoxLayout(self)
        # No margins and no spacing of its own: the row's spacing is the form's,
        # and the only gap inside it is the one either side of the comma. A
        # container that added its own would sit a row taller than its
        # neighbours and break the column the panel reads as.
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        for index, widget in enumerate(self._widgets):
            if index:
                # The comma goes against the value it follows, as it would in a
                # sentence; the gap is on the far side of it.
                layout.addWidget(QLabel(SEPARATOR.strip()))
                layout.addSpacing(SEPARATOR_GAP)
            layout.addWidget(widget)

    def text(self) -> str:
        """The row as one value, the way a readout writes it."""
        return SEPARATOR.join(_text_of(widget) for widget in self._widgets)


class SwitchBox(QCheckBox):
    """A :class:`~shiny_mushroom.fields.Switch` field: one box, ticked or not.

    No caption of its own -- the row's label is already the question, and a box
    that also said "Yes" beside itself would answer it twice. What the row
    *reads* as is :meth:`state_text`, so a readout of the panel says "Yes" and
    "No" where the box shows a tick.

    Part-filled where the value is neither, which is a multi-record selection
    whose records disagree. That is a state the box is put **into** and never
    one a click puts it back into: :meth:`nextCheckState` goes straight to the
    answer, because "leave them as they were" is not something a tick can say.
    """

    def __init__(
        self,
        found: Field,
        record: object,
        edited: Callable[[str, int], None],
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        assert isinstance(found.kind, Switch)
        self._field = found
        self._edited = edited
        # No focus by wheel, for :class:`PanelSpinBox`'s reason: this panel is
        # a scroll area, and a box that toggled because somebody scrolled past
        # it is an edit nobody made.
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        # Filled before it is connected, because putting the record's own
        # answer into the box showing it is not the user answering.
        self.fill(found, record)
        # The state rather than ``toggled``: Qt counts a part-filled box as
        # checked, so the click that decides one changes no ``checked`` and
        # would commit nothing.
        self.checkStateChanged.connect(
            lambda state, key=found.key: self._answered(key, state)
        )

    def _answered(self, key: str, state: Qt.CheckState) -> None:
        """Commit the answer the box now shows. Part-filled is not one: it is
        put there by a fill, which happens with the signals blocked."""
        if state != Qt.CheckState.PartiallyChecked:
            self._edited(key, 1 if state == Qt.CheckState.Checked else 0)

    def nextCheckState(self) -> None:  # noqa: N802 - Qt's name
        """Tick or untick, never part-fill.

        Qt's three-state cycle would offer "neither" as an answer, and it is
        only ever a report. A part-filled box ticks, because a click on records
        that disagree is a click that decides them.

        **The state is set, never the tick.** ``setChecked`` publishes the new
        state -- which is what emits ``checkStateChanged`` -- only while
        ``blockRefresh`` is down, and the mouse-release path raises it around
        this call; ``QCheckBox`` compensates by publishing the state itself,
        which is exactly the half an override replaces. ``setCheckState``
        publishes its own, so the box says what it now shows however the click
        arrived: by hand, by :meth:`~PySide6.QtWidgets.QAbstractButton.click`,
        or off the keyboard.
        """
        checked = self.checkState() != Qt.CheckState.Checked
        self.setCheckState(
            Qt.CheckState.Checked if checked else Qt.CheckState.Unchecked
        )

    def fill(self, found: Field, record: object) -> None:
        """Put the record's answer into the box, without committing it."""
        self._field = found
        value = found.value(record)
        self.setEnabled(found.editable)
        # Tristate only while it is showing one: left on, a click could cycle
        # back through the part-filled state.
        self.setTristate(value not in (0, 1))
        if value in (0, 1):
            self.setChecked(bool(value))
        else:
            self.setCheckState(Qt.CheckState.PartiallyChecked)

    def state_text(self) -> str:
        """The row as one value, the way a readout writes it."""
        assert isinstance(self._field.kind, Switch)
        state = self.checkState()
        if state == Qt.CheckState.PartiallyChecked:
            return self._field.kind.text_for(-1)
        return self._field.kind.text_for(1 if state == Qt.CheckState.Checked else 0)


class FlagBoxes(QWidget):
    """A :class:`~shiny_mushroom.fields.Flags` field: one checkbox per named
    bit, stacked under the row's one label.

    A box commits the **whole value** the row would have with that one bit
    moved, bits the field does not name included untouched: a field's write
    takes a number, and half a byte is not one. Stacked rather than side by
    side because the names here are map names and a row of seven would be
    wider than the dock.

    Reads as one value, like :class:`SharedRow`: :meth:`text` is what the
    field's own :meth:`~shiny_mushroom.fields.Field.text` says, so the panel
    and every readout describe the bits the same way.
    """

    def __init__(
        self,
        found: Field,
        record: object,
        edited: Callable[[str, int], None],
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        assert isinstance(found.kind, Flags)
        self._field = found
        self._value = 0
        self._boxes: list[tuple[int, QCheckBox]] = []
        layout = QVBoxLayout(self)
        # No margins, for the reason SharedRow has none: the spacing between
        # rows is the form's, and a container with its own would sit the row
        # off the column its neighbours line up in.
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)
        for mask, name in found.kind.bits:
            box = QCheckBox(name)
            box.toggled.connect(
                lambda on, bit=mask: edited(self._field.key, self._with(bit, on))
            )
            layout.addWidget(box)
            self._boxes.append((mask, box))
        self.fill(found, record)

    def _with(self, bit: int, on: bool) -> int:
        """The value every box is showing, with ``bit`` set or cleared."""
        held = self._held
        return held | bit if on else held & ~bit

    @property
    def _held(self) -> int:
        """What the boxes are showing, plus the bits the field does not name
        -- carried from the record, since nothing here may drop them."""
        assert isinstance(self._field.kind, Flags)
        value = self._value & ~self._field.kind.mask
        for mask, box in self._boxes:
            if box.isChecked():
                value |= mask
        return value

    def fill(self, found: Field, record: object) -> None:
        """Put the record's value into the boxes, without committing it."""
        self._field = found
        self._value = found.value(record)
        for mask, box in self._boxes:
            # Blocked, because setting a box to what the record says is not
            # the user saying it: the toggle would commit straight back.
            box.blockSignals(True)
            box.setChecked(bool(self._value & mask))
            box.setEnabled(found.editable)
            box.blockSignals(False)

    def text(self) -> str:
        """The row as one value, the way a readout writes it."""
        assert isinstance(self._field.kind, Flags)
        return self._field.kind.text_for(self._held)


class PropertiesDock(QDockWidget):
    """A titled list of rows for the current selection, editable where the
    record is.

    Emits :attr:`edited` with the field's key and its new value. It does not
    apply the edit: what a level *is* belongs to the window's document, and a
    panel that wrote into records directly would be a second place edits happen
    and a second place undo has to be remembered.
    """

    #: ``(key, value)`` for a field the user committed.
    edited = Signal(str, int)

    #: Escape was pressed in one of the fields: the user is done with the panel
    #: and wants the picture back. The window decides what that means, because
    #: what has the keyboard next is not the panel's business.
    dismissed = Signal()

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Properties", parent)
        self.setObjectName(OBJECT_NAME)
        self.setAllowedAreas(
            Qt.DockWidgetArea.RightDockWidgetArea | Qt.DockWidgetArea.LeftDockWidgetArea
        )

        self._heading = QLabel()
        self._heading.setWordWrap(True)
        font = self._heading.font()
        font.setBold(True)
        self._heading.setFont(font)

        self._form = QFormLayout()
        self._form.setLabelAlignment(Qt.AlignmentFlag.AlignRight)
        # Rows are label/value pairs of unpredictable width; letting the fields
        # grow rather than wrap keeps a long name from stretching the dock.
        self._form.setFieldGrowthPolicy(
            QFormLayout.FieldGrowthPolicy.ExpandingFieldsGrow
        )

        body = QWidget()
        layout = QVBoxLayout(body)
        layout.addWidget(self._heading)
        layout.addLayout(self._form)
        layout.addStretch(1)

        # Scrolled, because the number of rows is the format's business and a
        # short window must not clip the last one.
        scroll = QScrollArea()
        scroll.setWidget(body)
        scroll.setWidgetResizable(True)
        self.setWidget(scroll)

        #: The fields on show, by key, beside the widget showing each -- what
        #: :meth:`refresh` writes into and what a commit is looked up in.
        self._fields: dict[str, tuple[Field, QWidget]] = {}
        #: The keys in the order they were shown, which is the order the
        #: descriptors came in.
        self._order: list[str] = []

        self.show_nothing(NO_LEVEL)

    # -- what it shows ------------------------------------------------------

    def show_nothing(self, message: str = NOTHING_SELECTED) -> None:
        """Empty the panel, saying why it is empty."""
        self._heading.setText(message)
        self._clear()

    def show_properties(self, heading: str, rows: list[tuple[str, str]]) -> None:
        """Replace the panel's contents with plain label/value rows.

        What a multi-record selection gets, and what anything without a record
        behind it gets: there is nothing to edit, so there is nothing to
        describe with descriptors.
        """
        self._heading.setText(heading)
        self._clear()
        for label, value in rows:
            self._form.addRow(f"{label}:", self._label(value))

    def show_fields(
        self, heading: str, fields: Sequence[Field], record: object
    ) -> None:
        """Show one record through its own field descriptors.

        Rebuilds the rows, so it is called when the *selection* changes and not
        when a value does -- :meth:`refresh` is for that.

        One row per *group* rather than per field: fields the format says are
        one thing share a row under one label, which is how a column and a row
        become "Pos". See :class:`SharedRow`.
        """
        self._heading.setText(heading)
        self._clear()
        for row in grouped(fields):
            widgets = []
            for found in row:
                widget = self._widget_for(found, record)
                self._fields[found.key] = (found, widget)
                self._order.append(found.key)
                if found.hint:
                    widget.setToolTip(wrap_tip(found.hint))
                widgets.append(widget)
            label = QLabel(f"{label_of(row)}:")
            # A grouped label names the pair and cannot explain either half, so
            # the hints stay on the boxes, where the answer to "which of these
            # is the column" is one hover away.
            if len(row) == 1 and row[0].hint:
                label.setToolTip(wrap_tip(row[0].hint))
            self._form.addRow(
                label, widgets[0] if len(widgets) == 1 else SharedRow(widgets)
            )
        self._align_value_boxes()

    def refresh(self, fields: Sequence[Field], record: object) -> None:
        """Put a record's current values back into the widgets already shown.

        After a commit the record is a different object -- every edit is a
        rewrite -- and the rows have to follow it: a resize changes the settings
        byte, a move changes the screen, and every rewrite changes the record's
        own bytes. Doing that without rebuilding is what keeps the keyboard in
        the box the user is working in.

        Falls back to a rebuild when the fields on show are no longer the ones
        the record has -- other rows, or a row whose control changed under its
        key, which is the table editor's rule too: a value cannot be refreshed
        into the wrong control. See :func:`control_changed`.
        """
        if [found.key for found in fields] != self._order or any(
            control_changed(self._fields[found.key][0], found) for found in fields
        ):
            self.show_fields(self._heading.text(), fields, record)
            return
        for found in fields:
            refill_field(self._fields, found.key, found, record)
        # A descriptor's bounds are the record's -- a wider object can be
        # resized further -- so what the boxes need can change without the rows
        # changing.
        self._align_value_boxes()

    def _align_value_boxes(self) -> None:
        """Give every value box the width of the widest of them.

        A form of numbers reads as a column, and Qt sizes each box to its own
        range: in a level sixteen columns wide that put an 8 px step between one
        row's box and the next's, a ragged edge saying nothing about either
        field. They share the widest instead, because the alternative is a box
        too narrow for the value in it. It shows most on a row two boxes share,
        where two different widths sit a comma apart.
        """
        boxes = [
            widget
            for _found, widget in self._fields.values()
            if isinstance(widget, PanelSpinBox)
        ]
        if not boxes:
            return
        width = max(box.sizeHint().width() for box in boxes)
        for box in boxes:
            box.setMinimumWidth(width)

    # -- turning a descriptor into a widget ---------------------------------

    def _widget_for(self, found: Field, record: object) -> QWidget:
        return field_widget(found, record, self.edited.emit)

    def keyPressEvent(self, event) -> None:  # noqa: ANN001, N802 - a QKeyEvent
        """Escape hands the keyboard back to the picture.

        A panel is somewhere the keyboard goes and has to be somewhere it can
        leave: without this, tabbing into a field to change one number strands
        the arrow keys in a spin box, and the way back is the mouse. Escape is
        what it is bound to because that is what Escape already means over the
        canvas -- put the thing in hand down -- and because every other editor
        for this game uses it that way.

        The value being typed is committed on the way out, by the focus change
        Escape causes. Abandoning it instead would be the other defensible
        rule, and is not this one: a number typed into a box is a number the
        user meant, and undo is what takes it back.
        """
        if event.key() == Qt.Key.Key_Escape:
            self.dismissed.emit()
            event.accept()
            return
        super().keyPressEvent(event)

    @staticmethod
    def _label(value: str) -> QLabel:
        field = QLabel(value)
        # Selectable so a byte sequence can be copied out; a readout nobody can
        # copy from is a screenshot.
        field.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        field.setWordWrap(True)
        return field

    # -- what is on show ----------------------------------------------------

    @property
    def rows(self) -> list[tuple[str, str]]:
        """What is on show, as pairs. The panel's own state, for tests and for
        anything that wants to copy it.

        A widget's text rather than the record's, deliberately: this is what the
        panel is *showing*, which is the thing a test about the panel should be
        asking about.
        """
        pairs = []
        for row in range(self._form.rowCount()):
            label = self._form.itemAt(row, QFormLayout.ItemRole.LabelRole)
            field = self._form.itemAt(row, QFormLayout.ItemRole.FieldRole)
            pairs.append((label.widget().text().rstrip(":"), _text_of(field.widget())))
        return pairs

    @property
    def heading(self) -> str:
        return self._heading.text()

    def widget_for(self, key: str) -> QWidget | None:
        """The widget showing one field, by its key. For tests and for anything
        that wants to put the keyboard in a particular box."""
        found = self._fields.get(key)
        return None if found is None else found[1]

    def _clear(self) -> None:
        # Rows are taken out and their widgets deleted **later**, never in
        # place: a rebuild can arrive from inside one of these widgets' own
        # signals -- a spin box committing a value that changes what is
        # selected -- and `removeRow`'s immediate delete would destroy the
        # emitter under Qt's feet, which crashes when its event handling
        # resumes. Deferred deletion still leaves nothing behind: without
        # it the panel leaks a row per selection, and a level's worth of
        # clicking is thousands of them.
        while self._form.rowCount():
            taken = self._form.takeRow(0)
            for item in (taken.labelItem, taken.fieldItem):
                widget = None if item is None else item.widget()
                if widget is not None:
                    widget.hide()
                    widget.deleteLater()
        self._fields.clear()
        self._order.clear()


#: Marks a list model as the shared one, so :func:`fill_field_widget` knows
#: to take a copy of it before adding a row.
_SHARED_LIST = "shared-list"

#: The shared list model of each option set met so far -- see
#: :func:`_shared_list_model`.
_LIST_MODELS: dict[tuple[Choice, ...], QStandardItemModel] = {}


def _list_model(
    options: tuple[Choice, ...], parent: QWidget | None
) -> QStandardItemModel:
    """``options`` as a picker's list, in the shape a combo box reads: the
    label to show, and the value under ``UserRole`` where ``findData`` and
    ``currentData`` look for it."""
    model = QStandardItemModel(len(options), 1, parent)
    for row, choice in enumerate(options):
        item = QStandardItem(choice.label)
        item.setData(choice.value, Qt.ItemDataRole.UserRole)
        if choice.detail:
            # Beside the label in the search popup, and searched with it; the
            # closed box shows the label alone -- see :data:`DETAIL_ROLE`.
            item.setData(choice.detail, DETAIL_ROLE)
        item.setFlags(Qt.ItemFlag.ItemIsEnabled | Qt.ItemFlag.ItemIsSelectable)
        model.setItem(row, 0, item)
    return model


def _shared_list_model(options: tuple[Choice, ...]) -> QStandardItemModel:
    """The one list every picker offering ``options`` is shown.

    A picker's list belongs to the *field*, not to the row showing it, and a
    table puts hundreds of rows of one field on screen at once: the event-row
    grid builds a block picker of 320 entries per row, and filling each of
    those entry by entry is the most expensive thing the grid does. So the
    list is built once per option set and kept for the session.

    A combo box holds its own current index and its own popup, so sharing
    costs a picker nothing. What sharing does mean is that nothing may
    *write* to one of these -- :func:`fill_field_widget` is the only place
    that ever wants to, and takes a copy instead.
    """
    model = _LIST_MODELS.get(options)
    if model is None:
        # No parent: the list outlives every picker built from it, and a
        # parent would be whichever picker happened to be built first.
        model = _list_model(options, None)
        model.setProperty(_SHARED_LIST, True)
        _LIST_MODELS[options] = model
    return model


def field_widget(
    found: Field, record: object, edited: Callable[[str, int], None]
) -> QWidget:
    """One field as the widget that shows and edits it.

    The factory behind every editable row in the editor -- the properties
    panel's and the table editor's alike -- so a walk direction reads and
    commits the same way wherever it is shown. ``edited`` is called with the
    field's key and the committed value, on the panel's own terms: a step or
    a choice at once, a typed number when it is finished.
    """
    if isinstance(found.kind, Action):
        # A button, wired through the same signal a committed value takes:
        # the owner dispatches on the key, and the 1 is only the shape.
        button = QPushButton(found.kind.caption)
        button.clicked.connect(lambda _checked=False, key=found.key: edited(key, 1))
        return button
    if isinstance(found.kind, Readout) or not found.editable:
        label = QLabel(found.text(record))
        # Selectable so a byte sequence can be copied out; a readout nobody
        # can copy from is a screenshot.
        label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        label.setWordWrap(True)
        return label
    if isinstance(found.kind, Switch):
        return SwitchBox(found, record, edited)
    if isinstance(found.kind, Flags):
        return FlagBoxes(found, record, edited)
    if isinstance(found.kind, Choices):
        # By how many entries it offers, which is the difference between the
        # two kinds of list this panel has: a couple of hundred names to
        # find one of, or a yes and a no.
        box = CompactComboBox(
            None if len(found.kind.options) <= SHORT_LIST_OPTIONS else PICKER_WIDTH,
            offers_search=found.kind.searchable,
        )
        box.setModel(_shared_list_model(found.kind.options))
        # Committed on activation rather than on any index change, so
        # refilling the box after an edit does not read as another edit.
        box.activated.connect(
            lambda _index, key=found.key, widget=box: edited(key, widget.currentData())
        )
        fill_field_widget(found, box, record)
        return box
    assert isinstance(found.kind, Number)
    spin = HexSpinBox(found.kind.digits) if found.kind.hexadecimal else PanelSpinBox()
    spin.setSingleStep(found.kind.step)
    # Filled before it is connected, because putting the record's own value
    # into the box it is shown in is not an edit of it.
    fill_field_widget(found, spin, record)
    # `valueChanged` with keyboard tracking off is "a number the user has
    # finished saying": every step as it happens, and a typed one when it is
    # interpreted on Enter or on the way out. See the module docstring.
    spin.valueChanged.connect(lambda value, key=found.key: edited(key, value))
    return spin


def fill_field_widget(found: Field, widget: QWidget, record: object) -> None:
    """Put a field's current value into the widget showing it.

    The range comes with it, because a descriptor's bounds are the record's:
    a runaway extent is floored at two unless the record is already below
    that, and the floor has to come back the moment an edit takes it there.
    A box left on the range it was built with would offer a step nothing
    else in the editor allows.

    **Nothing at all where the widget is not the control this field builds.**
    A field can swap its kind under a key, and the rebuild that answers that
    (:func:`control_changed`) does not always land first: the table's rows say
    so through ``dataChanged``, which reaches the editors still standing on
    the old kind. Filling one would read the new field through the wrong
    control, and for a picker it would write a bogus row into the list model
    every other picker of that option set is sharing.
    """
    if isinstance(widget, QSpinBox):
        if not isinstance(found.kind, Number):
            return
        widget.setRange(found.kind.minimum, found.kind.maximum)
        widget.setValue(found.value(record))
    elif isinstance(widget, QComboBox):
        if not isinstance(found.kind, Choices):
            return
        value = found.value(record)
        index = widget.findData(value)
        if index < 0:
            # A value no list entry has. Kept selectable rather than
            # snapped onto a neighbour: the name tables are the
            # disassembly's and are not a statement about what is legal.
            # The list is shared with every other picker offering it, so
            # the box takes a copy of its own first -- one record's odd
            # value is not an entry in everyone else's list.
            if widget.model().property(_SHARED_LIST):
                widget.setModel(_list_model(found.kind.options, widget))
            widget.addItem(found.text(record), value)
            index = widget.count() - 1
        widget.setCurrentIndex(index)
    elif isinstance(widget, SwitchBox):
        if not isinstance(found.kind, Switch):
            return
        widget.fill(found, record)
    elif isinstance(widget, FlagBoxes):
        widget.fill(found, record)
    elif isinstance(widget, QLabel):
        widget.setText(found.text(record))


def control_changed(before: Field, after: Field) -> bool:
    """Whether a field's widget has to be built again rather than refilled.

    The rule the properties panel and the table editor share, because both
    keep a control per key across an edit and both have rows whose control is
    decided by another value on the record:

    - **The kind changed.** A silent slot's tile column is a spin box on one
      layer and a block picker on the other.
    - **A picker's options changed.** A screen exit's destination is the
      cartridge's levels or its secondary entrances depending on one flag
      beside it, and a combo box is filled from a list model built once per
      list -- so a box left on the old one goes on offering the old names
      whatever is refilled into it.

    A :class:`~shiny_mushroom.fields.Number`'s *bounds* are deliberately not
    in this: they are the record's, they move under an ordinary edit, and
    :func:`fill_field_widget` puts them back without taking the keyboard out
    of the box being typed in.
    """
    if type(before.kind) is not type(after.kind):
        return True
    if isinstance(before.kind, Choices) and isinstance(after.kind, Choices):
        return before.kind.options != after.kind.options
    return False


def refill_field[K](
    held: MutableMapping[K, tuple[Field, QWidget]],
    key: K,
    found: Field,
    record: object,
) -> None:
    """Put ``record``'s value for ``found`` back into the widget already
    showing it, in ``held``.

    The panel and the table both refresh this way rather than rebuilding, which
    is what keeps the keyboard in the box being typed in. Two things go with it,
    and both are the reason this is one function rather than two loops:

    - **The descriptor is replaced, the widget kept.** Descriptors are rebuilt
      with the record -- they close over it for their bounds and their options
      -- so the stored one is stale the moment an edit lands.
    - **Signals are blocked for the fill**, because writing a record's own value
      into the box it is shown in is not an edit of it.

    Whether the widgets on show are still the right ones stays the caller's
    question: what a mismatch means differs between a panel of one record and a
    grid of many.
    """
    widget = held[key][1]
    held[key] = (found, widget)
    widget.blockSignals(True)
    try:
        fill_field_widget(found, widget, record)
    finally:
        widget.blockSignals(False)


def _text_of(widget: QWidget) -> str:
    """What a row is showing, whatever kind of widget is showing it."""
    if isinstance(widget, SharedRow | FlagBoxes):
        return widget.text()
    if isinstance(widget, SwitchBox):
        return widget.state_text()
    if isinstance(widget, QComboBox):
        return widget.currentText()
    if isinstance(widget, QSpinBox):
        return widget.text()
    if isinstance(widget, QLineEdit | QLabel | QPushButton):
        return widget.text()
    return ""
