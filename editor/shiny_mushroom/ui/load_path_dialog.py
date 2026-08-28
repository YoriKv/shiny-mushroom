"""The Level Load Path window: one level's chain, top to bottom.

Modeless and kept, like the level files viewer: the owner builds the
sections -- the overworld cell, the translevel's tables, the level's files
and Layer 2, the entrance -- and this renders them as field rows, exactly
the rows the properties panel would draw. It owns no document and applies
nothing: an edit or a pressed action is emitted with its section's key, and
what it *means* -- a world-map commit, a level-document commit, a repoint,
a mode switch -- belongs to the window that opened this one.

The sections change shape with the editor's state -- the world rows are
editable over the map and readouts over a level -- so :meth:`refresh`
refills the widgets in place while the shape holds and rebuilds when it
does not, deferred out of the committing widget's own signal.
"""

from __future__ import annotations

from dataclasses import dataclass
from dataclasses import field as dataclass_field

from PySide6.QtCore import Qt, QTimer, Signal
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QGroupBox,
    QLabel,
    QScrollArea,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.fields import Field
from shiny_mushroom.ui.properties import (
    control_changed,
    field_widget,
    refill_field,
)
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tips import wrap_tip

TITLE = "Level Load Path"


@dataclass
class Section:
    """One box of the path: its stable key, its title, its rows, and the
    record the rows read. ``note`` is one quiet line under the title --
    "shown read-only over a level", "no overworld tile" -- and a section
    of note alone is a fact with no rows."""

    key: str
    title: str
    fields: list[Field] = dataclass_field(default_factory=list)
    record: object = None
    note: str = ""


def _same_shape(before: list[Section], after: list[Section]) -> bool:
    """Whether the widgets on show may be refilled rather than rebuilt.

    The same sections in the same order, the same rows in each, each still
    editable or not -- and each row's control still the one that would be
    built for it. That last is
    :func:`~shiny_mushroom.ui.properties.control_changed`, the rule the
    properties panel and the table editor share: a picker whose *options*
    moved needs a new box, since a combo is filled from a list model built
    once per list and refilling one leaves the old names on offer.
    """
    if len(before) != len(after):
        return False
    for was, now in zip(before, after, strict=True):
        if (was.key, was.title, was.note) != (now.key, now.title, now.note):
            return False
        if len(was.fields) != len(now.fields):
            return False
        for old, new in zip(was.fields, now.fields, strict=True):
            if (old.key, old.editable) != (new.key, new.editable):
                return False
            if control_changed(old, new):
                return False
    return True


class LoadPathDialog(QDialog):
    """The chain as boxes of rows. Emits :attr:`edited` and nothing else."""

    #: A committed value or a pressed action: the section's key, the field's
    #: key, and the value (1 for an action).
    edited = Signal(str, str, int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self.setMinimumSize(380, 480)
        self._sections: list[Section] = []
        self._widgets: dict[tuple[str, str], tuple[Field, QWidget]] = {}
        self._rebuild_queued = False

        layout = QVBoxLayout(self)
        self._heading = QLabel("")
        style_note(self._heading)
        layout.addWidget(self._heading)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QScrollArea.Shape.NoFrame)
        self._column = QWidget()
        self._column_layout = QVBoxLayout(self._column)
        self._column_layout.addStretch(1)
        scroll.setWidget(self._column)
        layout.addWidget(scroll, 1)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    # -- filling it ----------------------------------------------------------

    def show_path(self, heading: str, sections: list[Section]) -> None:
        """Replace everything: the heading and every section box."""
        self._heading.setText(heading)
        self._sections = sections
        self._widgets.clear()
        while self._column_layout.count() > 1:
            item = self._column_layout.takeAt(0)
            if item.widget() is not None:
                item.widget().deleteLater()
        for at, section in enumerate(sections):
            self._column_layout.insertWidget(at, self._box(section))

    def refresh(self, heading: str, sections: list[Section]) -> None:
        """Bring the rows up to date, keeping the widgets where the shape
        allows -- which is what keeps the keyboard in the box being typed
        in. A changed shape rebuilds, deferred out of the committing
        widget's own signal stack."""
        # A queued rebuild owns the next draw: the widgets on show are still
        # the old shape's, so a refill against them would miss -- the fresh
        # sections just ride along for the rebuild to render.
        if self._rebuild_queued or not _same_shape(self._sections, sections):
            self._sections = sections
            self._heading.setText(heading)
            if not self._rebuild_queued:
                self._rebuild_queued = True
                QTimer.singleShot(0, self._rebuild)
            return
        self._heading.setText(heading)
        self._sections = sections
        for section in sections:
            for found in section.fields:
                refill_field(
                    self._widgets, (section.key, found.key), found, section.record
                )

    def _rebuild(self) -> None:
        self._rebuild_queued = False
        self.show_path(self._heading.text(), self._sections)

    def _box(self, section: Section) -> QGroupBox:
        box = QGroupBox(section.title)
        form = QFormLayout(box)
        form.setFieldGrowthPolicy(QFormLayout.FieldGrowthPolicy.ExpandingFieldsGrow)
        if section.note:
            note = QLabel(section.note)
            style_note(note)
            note.setWordWrap(True)
            form.addRow(note)
        for found in section.fields:
            widget = field_widget(
                found,
                section.record,
                lambda key, value, section_key=section.key: self.edited.emit(
                    section_key, key, value
                ),
            )
            if isinstance(widget, QLabel):
                # A readout takes the row's width and wraps into it; left to
                # its own hint the form clips a long value to one short line.
                widget.setSizePolicy(
                    QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred
                )
            widget.setToolTip(wrap_tip(found.hint))
            self._widgets[(section.key, found.key)] = (found, widget)
            if found.label:
                label = QLabel(found.label)
                label.setToolTip(wrap_tip(found.hint))
                form.addRow(label, widget)
            else:
                form.addRow(widget)
        return box

    def keyPressEvent(self, event) -> None:  # noqa: ANN001, N802 - a QKeyEvent
        """Escape closes the window rather than being swallowed by a box --
        the dialog's own meaning for it, same as the Close button."""
        if event.key() == Qt.Key.Key_Escape:
            self.reject()
            return
        super().keyPressEvent(event)
