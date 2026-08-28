"""The level header editor: a modal over the five header bytes.

Modal because a header is a small, self-contained set of decisions about the
level as a whole -- there is nothing on the canvas to point at while making
them, and nothing else to do until they are made or abandoned. Cancel has to
mean the level is exactly as it was, which a docked panel editing in place
cannot promise.

The dialog holds an edited copy and hands it back on accept; it never touches
the cartridge, and neither does the window it belongs to. What each field *is*
lives in :mod:`shiny_mushroom.header`, so a field added there appears here
without this file changing.

**The Layer 2 subsection is a passenger, and says so.** What a level's Layer 2
shows is not in the header at all -- it is the level's slot in the game's
Layer 2 pointer table -- but the header dialog is where every other
whole-level decision is made, so the pointer is offered here rather than
behind a menu row nobody would find. It is drawn under its own rule and its
own caption precisely because its scope differs: the five bytes go into the
document alone, while a repoint is written to the project the moment the
dialog is accepted. Both land on the same undo stack -- the repoint as a step
that rewrites the table on the way back
(:meth:`~shiny_mushroom.ui.main_window.MainWindow._walk_repoint`).

**Which is also why one check lives here rather than in either half.** The
level mode and the Layer 2 entry are the two halves of a pair that hangs the
cartridge -- a mode that reads Layer 2 as objects over an entry that is a
background image -- and this is the one place both can move at once. So the
check weighs the *edited* header against the *chosen* entry and holds OK shut
on the pair, which lets a mode edited out of the way in the same accept be
the fix rather than a second refusal.

**The level's own graphics row is not here**, though the header decides what
it is laid over: it is eight bytes the cartridge only has room for under a
feature, and it has a dialog of its own
(:mod:`shiny_mushroom.ui.level_graphics_dialog`). What the two share is the
header -- a slot left on "the tileset's" follows the two tileset fields
edited here, which is why that dialog reads the header rather than holding
one.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import TYPE_CHECKING

from PySide6.QtCore import QSize
from PySide6.QtGui import QFont
from PySide6.QtWidgets import (
    QApplication,
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QFrame,
    QHBoxLayout,
    QLabel,
    QScrollArea,
    QStyle,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.header import (
    FIELDS,
    FIELDS_BY_KEY,
    HeaderField,
    field_value,
    format_bytes,
)
from shiny_mushroom.layer2_table import Layer2Entry
from shiny_mushroom.ui.dialogs import ChoiceBox, NumberBox, selectable_label
from shiny_mushroom.ui.palette_grid import Swatch, SwatchGrid
from shiny_mushroom.ui.tips import wrap_tip

if TYPE_CHECKING:
    from shiny_mushroom.project_levels import Layer2Gap

TITLE = "Level Header"

#: Shown under the fields. A header is five bytes and an editor for it should
#: say which five: it is what a hex editor, the disassembly and any other tool
#: will show, and the only way to check an edit against them.
BYTES_LABEL = "Bytes"

#: The one thing the dialog promises about scope. Stated in the dialog rather
#: than only in a status message, because "did this write to my ROM?" is the
#: first question an editor has to answer without being asked.
SCOPE_NOTE = "Changes apply in memory. The cartridge is not written."

#: How much of the screen the dialog may open across. The fields scroll, so a
#: dialog that would be taller than this opens at this height with the rest one
#: scroll away rather than off the bottom edge.
SCREEN_SHARE = 0.9

#: How big a swatch is in the colour preview beside a palette field. Smaller
#: than the palette panel's, because these are here to be compared at a glance
#: rather than picked from.
PREVIEW_CELL = 12

#: Said of the previews. They are not editable here for the dialog's own
#: reason: Cancel has to mean the level is exactly as it was, and a colour is
#: not part of the level -- it is the game's, shared by every level that reads
#: the same set.
PREVIEW_TIP = "What this setting looks like. Colours are edited in the Palettes panel."

#: The fields worth showing colours beside, and how many colours each stands
#: for: twelve for the three that select a set -- the two rows of six the
#: loader writes -- and one for the backdrop, which is not a CGRAM entry at all.
#: The count is the strip's width, so a one-colour field does not reserve a
#: row of twelve to draw one swatch in.
PREVIEW_FIELDS = {
    "background_palette": 12,
    "foreground_palette": 12,
    "sprite_palette": 12,
    "back_area_color": 1,
}

#: The Layer 2 subsection's caption and its own scope note -- the opposite
#: promise from :data:`SCOPE_NOTE`, which is why it is stated separately: the
#: pointer is not part of the header, and choosing another writes the project's
#: copy of the pointer table when the dialog is accepted.
LAYER2_TITLE = "Layer 2"
LAYER2_NOTE = (
    "Not part of the header: the level's Layer 2 pointer. Changing it "
    "repoints this level alone, and reloads it on OK."
)


@dataclass(frozen=True)
class Layer2Options:
    """What the Layer 2 dropdown offers, and where the level points today.

    Built by the window from the open project -- see
    :meth:`~shiny_mushroom.project.Project.layer2_choices` -- and absent
    entirely when there is no project to write a repoint into, which is what
    keeps the dialog's own promise ("the cartridge is not written") honest
    for everything it actually shows.
    """

    choices: tuple[Layer2Entry, ...]
    current: Layer2Entry


class HeaderDialog(QDialog):
    """Edit a level header. :attr:`header` is the edited copy."""

    def __init__(
        self,
        header: bytes,
        parent: QWidget | None = None,
        layer2: Layer2Options | None = None,
        colours: Callable[[str, int], Sequence[int]] | None = None,
        gap: Callable[[bytes, Layer2Entry], Layer2Gap | None] | None = None,
        preview: Callable[[bytes | None], None] | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self._header = bytes(header)
        self._editors: dict[str, QWidget] = {}
        self._layer2 = layer2
        self._layer2_pick: QComboBox | None = None
        #: :meth:`~shiny_mushroom.project.Project.layer2_gap` bound to this
        #: level, asked of the pair in hand. Left out -- by a test standing
        #: the form up on its own, or by a dialog with no Layer 2 subsection
        #: -- the check is not made here and the save still refuses.
        self._gap = gap
        self._gap_note: QLabel | None = None
        #: What a palette field's setting looks like, asked of the window --
        #: which is where the palette file and the build's symbols are. Absent
        #: without a project, and then no preview is drawn at all.
        self._colours = colours
        #: The canvas behind the dialog, told the edited header on every
        #: change -- :meth:`~shiny_mushroom.ui.main_window.MainWindow.preview_header`,
        #: which shows the part of it a repaint can answer for. Absent in a
        #: test standing the form up on its own, and then nothing is shown.
        self._preview = preview

        self._previews: dict[str, SwatchGrid] = {}

        form = QFormLayout()
        for field in FIELDS:
            editor = self._editor_for(field)
            editor.setToolTip(f"{wrap_tip(field.description)}\n\n{_position(field)}")
            self._editors[field.key] = editor
            label = QLabel(f"{field.name}:")
            label.setToolTip(editor.toolTip())
            form.addRow(label, self._with_preview(field.key, editor))

        # Monospace, because the point of the readout is that the five bytes
        # line up with the same five in a hex editor -- which is also what makes
        # it worth being able to drag out of.
        self._bytes = selectable_label(font=QFont("monospace"))
        form.addRow(f"{BYTES_LABEL}:", self._bytes)

        note = QLabel(SCOPE_NOTE)
        note.setWordWrap(True)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)

        page = QVBoxLayout()
        page.setContentsMargins(0, 0, 0, 0)
        page.addLayout(form)
        page.addWidget(note)
        if layer2 is not None:
            self._build_layer2(page, layer2)
        page.addStretch(1)

        # **The fields scroll, and the buttons do not.** Thirteen rows, a
        # wrapped scope note and the Layer 2 subsection under it come to more
        # than a short screen has room for, and the level mode's own note
        # appears and disappears under them -- so what does not fit is reached
        # by scrolling rather than by squeezing every row above it. OK and
        # Cancel stay outside the area, because a dialog whose accept can
        # scroll out of sight is a dialog with no way out.
        body = QWidget()
        body.setLayout(page)
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QScrollArea.Shape.NoFrame)
        scroll.setWidget(body)
        self._scroll = scroll

        layout = QVBoxLayout(self)
        layout.addWidget(scroll, 1)
        layout.addWidget(buttons)
        self._ok = buttons.button(QDialogButtonBox.StandardButton.Ok)

        self._show_bytes()
        self._weigh_the_pair()
        self.resize(self._opening_size(body, buttons))

    def _opening_size(self, body: QWidget, buttons: QWidget) -> QSize:
        """Big enough for every field, and no bigger than the screen.

        A scroll area asks for very little, so the size is taken from what is
        *inside* it: left to its own hint the dialog would open a few rows tall
        with every field to be scrolled to. Clamped to the screen at the other
        end, which is the case the area is here for -- past that the rows would
        be off the bottom edge rather than one scroll away.
        """
        layout = self.layout()
        margins = layout.contentsMargins()
        wanted = QSize(
            body.sizeHint().width() + margins.left() + margins.right(),
            body.sizeHint().height()
            + margins.top()
            + margins.bottom()
            + layout.spacing()
            + buttons.sizeHint().height(),
        )
        screen = self.screen() or QApplication.primaryScreen()
        if screen is None:
            return wanted
        room = screen.availableGeometry()
        height = min(wanted.height(), int(room.height() * SCREEN_SHARE))
        width = wanted.width()
        if height < wanted.height():
            # Held to the screen, so the scroll bar is there and takes its
            # width out of the fields -- which would put a horizontal bar under
            # them for the sake of a dozen pixels.
            width += self.style().pixelMetric(
                QStyle.PixelMetric.PM_ScrollBarExtent, None, self
            )
        return QSize(min(width, int(room.width() * SCREEN_SHARE)), height)

    # -- what is being edited -----------------------------------------------

    @property
    def header(self) -> bytes:
        """The edited header. Equal to the one passed in until something moves."""
        return self._header

    @property
    def layer2(self) -> Layer2Entry | None:
        """Where the level's Layer 2 should now point -- ``None`` while the
        pick is where it started, or when the section was never offered, so a
        caller acts only on an actual decision."""
        if self._layer2 is None or self._layer2_pick is None:
            return None
        chosen = self._layer2_pick.currentData()
        return None if chosen == self._layer2.current else chosen

    def set_field(self, key: str, value: int) -> None:
        """Set one field by name, driving the widget rather than going round it.

        The widget is the single source of the value -- its own signal writes
        the byte -- so setting it here keeps the readout, the bytes and the
        control in step however the change arrived.
        """
        editor = self._editors[key]
        if isinstance(editor, QComboBox):
            # By the value meant, as every other way in takes it: the rows are
            # the stored values, so an offset field's row is not its value.
            editor.setCurrentIndex(value - FIELDS_BY_KEY[key].offset)
        else:
            editor.setValue(value)

    def set_layer2(self, entry: Layer2Entry) -> None:
        """Pick a Layer 2 entry, driving the widget as :meth:`set_field` does."""
        if self._layer2_pick is not None:
            self._layer2_pick.setCurrentIndex(self._offered(entry))

    def _offered(self, entry: Layer2Entry) -> int:
        """Which row of the dropdown is ``entry``, or ``-1``.

        Asked of the choices rather than of ``QComboBox.findData``, which
        compares a Python payload by **identity**: every entry the window hands
        in is read from its own parse of the pointer table, so it is never the
        same object as the equal one in the list, and the dropdown came up
        blank on a level whose pointer it was showing.
        """
        if self._layer2 is None:
            return -1
        return next(
            (row for row, held in enumerate(self._layer2.choices) if held == entry),
            -1,
        )

    # -- construction --------------------------------------------------------

    def _editor_for(self, field: HeaderField) -> QWidget:
        """A combo box where the value is one of a named set, a spin box where
        it is a number."""
        if field.choices is not None:
            box = ChoiceBox()
            # Padded to the field's own width in hex digits, so the numbers down
            # a five-bit field's list line up rather than stepping from "F" to
            # "10". Every narrower field is one digit and reads as it always did.
            digits = -(-field.bits // 4)
            for value, name in enumerate(field.choices):
                box.addItem(f"{value:0{digits}X} - {name}", value)
            box.setCurrentIndex(field.get(self._header) - field.offset)
            box.currentIndexChanged.connect(
                lambda index, f=field: self._changed(f, index + f.offset)
            )
            return box
        spin = NumberBox()
        spin.setRange(field.minimum, field.maximum)
        spin.setValue(field.get(self._header))
        # Hex, because every other tool that will ever show this field does.
        spin.setDisplayIntegerBase(16)
        spin.setPrefix("$")
        # Committed on Enter, focus-out or a step, not per digit: a header of
        # `$1` on the way to `$18` is a level the user never asked for, and the
        # byte readout underneath is there to be read while it is typed at.
        spin.setKeyboardTracking(False)
        spin.valueChanged.connect(lambda value, f=field: self._changed(f, value))
        return spin

    def _build_layer2(self, layout: QVBoxLayout, options: Layer2Options) -> None:
        """The Layer 2 subsection: a rule, a caption, one dropdown, its note.

        Visibly a different compartment from the header fields above it,
        because it *is* one -- see the module docstring for the scope split
        the separation is stating.
        """
        rule = QFrame()
        rule.setFrameShape(QFrame.Shape.HLine)
        rule.setFrameShadow(QFrame.Shadow.Sunken)
        layout.addWidget(rule)

        caption = QLabel(LAYER2_TITLE)
        bold = caption.font()
        bold.setBold(True)
        caption.setFont(bold)
        layout.addWidget(caption)

        pick = ChoiceBox()
        for entry in options.choices:
            pick.addItem(entry.describe(), entry)
        pick.setCurrentIndex(self._offered(options.current))
        pick.setToolTip(wrap_tip(LAYER2_NOTE))
        pick.currentIndexChanged.connect(self._weigh_the_pair)
        self._layer2_pick = pick
        form = QFormLayout()
        label = QLabel("Layer 2 data:")
        label.setToolTip(wrap_tip(LAYER2_NOTE))
        form.addRow(label, pick)
        layout.addLayout(form)

        note = QLabel(LAYER2_NOTE)
        note.setWordWrap(True)
        layout.addWidget(note)

        self._gap_note = QLabel()
        self._gap_note.setWordWrap(True)
        self._gap_note.hide()
        layout.addWidget(self._gap_note)

    def _changed(self, field: HeaderField, value: int) -> None:
        self._header = field.set(self._header, value)
        self._show_bytes()
        self._show_preview(field.key)
        # Every field, not only the ones the canvas can answer for: which those
        # are is the window's to know, and it is the cheap comparison there.
        if self._preview is not None:
            self._preview(self._header)
        # The level mode is the header's half of the pair below; no other
        # field can put the dialog in or out of that state.
        if field.key == "level_mode":
            self._weigh_the_pair()

    def _weigh_the_pair(self) -> None:
        """Say whether the header and the Layer 2 entry in hand would load,
        and hold OK shut while they would not.

        Both halves as they stand in the dialog, not as the project holds
        them: a level mode moved out of the way here is the fix, and refusing
        it for the mode still in the container would be refusing the answer.
        """
        gap = None
        if self._gap is not None and self._layer2_pick is not None:
            gap = self._gap(self._header, self._layer2_pick.currentData())
        self._ok.setEnabled(gap is None)
        if self._gap_note is None:
            return
        self._gap_note.setText("" if gap is None else gap.refusing_a_repoint)
        self._gap_note.setVisible(gap is not None)

    def _show_bytes(self) -> None:
        self._bytes.setText(format_bytes(self._header))

    # -- the colours a setting stands for -------------------------------------

    def _with_preview(self, key: str, editor: QWidget) -> QWidget:
        """``editor``, with the colours its setting selects beside it.

        A number is not a palette. Which of eight background sets a level loads
        is a decision about what it *looks* like, and picking it by number and
        finding out afterwards is a round trip through a level load.
        """
        if self._colours is None or key not in PREVIEW_FIELDS:
            return editor
        preview = SwatchGrid(PREVIEW_FIELDS[key], cell=PREVIEW_CELL)
        preview.setEnabled(False)
        preview.setToolTip(wrap_tip(PREVIEW_TIP))
        self._previews[key] = preview
        row = QHBoxLayout()
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(editor)
        row.addWidget(preview)
        row.addStretch(1)
        holder = QWidget()
        holder.setLayout(row)
        self._show_preview(key)
        return holder

    def _show_preview(self, key: str) -> None:
        preview = self._previews.get(key)
        if preview is None or self._colours is None:
            return
        found = self._colours(key, field_value(self._header, key))
        # No offsets: these are a picture of the setting, not somewhere to
        # edit. See :data:`PREVIEW_TIP`.
        preview.set_swatches([Swatch(colour) for colour in found])

    # -- opening it ----------------------------------------------------------

    @classmethod
    def edit(
        cls,
        parent: QWidget | None,
        header: bytes,
        layer2: Layer2Options | None = None,
        colours: Callable[[str, int], Sequence[int]] | None = None,
        gap: Callable[[bytes, Layer2Entry], Layer2Gap | None] | None = None,
        preview: Callable[[bytes | None], None] | None = None,
    ) -> tuple[bytes, Layer2Entry | None] | None:
        """Show the dialog; return what was decided, or ``None`` if cancelled.

        One entry point rather than a build-exec-read dance at the call site,
        so that "cancel changes nothing" is a property of this method instead
        of something every caller has to remember. The pair is the edited
        header and the Layer 2 repoint, ``None`` when the pointer was left
        alone, which is most accepts.
        """
        dialog = cls(
            header, parent, layer2=layer2, colours=colours, gap=gap, preview=preview
        )
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return None
        return dialog.header, dialog.layer2


def _position(field: HeaderField) -> str:
    """Where the field lives, for the tooltip: byte and bits."""
    high = field.shift + field.bits - 1
    bits = f"bit {field.shift}" if field.bits == 1 else f"bits {high}-{field.shift}"
    return f"Header byte {field.byte}, {bits}."
