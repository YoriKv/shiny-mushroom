"""The cartridge's memory map, one bar per bank.

A report and nothing else: it reads :mod:`shiny_mushroom.memory_map` and paints
it, and no gesture here changes anything. What it is *for* is the question a
full region raises -- where would another hundred bytes go? -- so the picture is
arranged around room rather than around contents: every bank is the same width
whatever is in it, and the eye is meant to go to the gaps.

**The bar is drawn back to front.** A bank is painted flat in the "other"
colour first and the things the editor owns are laid over it, which is what
lets a fourteen-byte table still be a visible mark: a segment is never narrower
than a pixel, and the run it overwrites was the same colour as everything
around it anyway. Sizing each of the seventy-odd placements in a bank
proportionally instead would round most of them to nothing and lose exactly the
ones worth seeing.

**An editable segment is drawn twice**: its whole run in a pale wash, its used
bytes solid over that. So a full table and an empty one are the same size on
screen and different colours inside, and how full something is takes no reading
at all.

**The picture is lent out.** :class:`BudgetBar` draws a single run the same
way -- washed, filled, and said in bytes -- so a byte budget shown anywhere
else in the editor reads as the thing the map already taught.

Colours are derived from the application palette at paint time rather than held,
so a theme switch needs nothing but the repaint Qt already sends -- the same
reasoning :mod:`shiny_mushroom.ui.tables` gives for deriving instead of
tabulating, without the machinery, because there is no third-party widget here
to hand a palette to.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtCore import QEvent, QRect, QSize, Qt, Signal
from PySide6.QtGui import QColor, QMouseEvent, QPainter, QPaintEvent, QPalette
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QFrame,
    QHBoxLayout,
    QLabel,
    QScrollArea,
    QSizePolicy,
    QSplitter,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memory_map import (
    DATA_TABLE,
    FREE,
    GRAPHICS,
    LEVEL_DATA,
    OTHER,
    Bank,
    MemoryMap,
    Segment,
)
from shiny_mushroom.ui.tables import note_ink
from smw_tools.rom_sizes import bytes_label

TITLE = "Memory Map"

#: What the window is, in one paragraph, above the banks.
HINT = (
    "Every bank of the cartridge, to scale. Coloured runs are the ones the "
    "editor writes: used solid, free washed out. Hover one to see what it is."
)

#: What is said instead of a table's numbers when the project has never been
#: built. The banks and the level data are read from the source and are exact
#: either way; where the tables landed is the build's own record.
UNPRICED = (
    "This project has no build yet, so its data tables are not shown. Build "
    "it (Project > Rebuild) to see them."
)

#: What is said about a cartridge longer than plain LoROM can address. The
#: banks past 4 MB are reached through the SA-1 patch's own bank switching,
#: which nothing here models -- so they are left out and said to be, rather
#: than drawn at addresses that would be somebody else's.
UNMAPPED = (
    "Only the first {shown} is shown: past that the SA-1 patch's own bank "
    "switching addresses the cartridge."
)

#: How tall one bank's bar is, in device-independent pixels. Tall enough that
#: the wash and the solid inside one segment read as two tones rather than as a
#: hairline, short enough that sixteen of them are a page.
BAR_HEIGHT = 26

#: How tall the foot under the banks starts out: the legend, and room under
#: it for a readout of three wrapped lines. A height the window keeps rather
#: than one fitted to the run named, because the cursor crossing the bars
#: would otherwise shove every bank up and down under it.
FOOT_HEIGHT = 96

#: The narrowest a segment may be painted. Bank $00 has five runs of padding
#: between them worth 119 bytes -- four thousandths of the bank, and a
#: hairline at any honest scale. They are the point of the picture, so they
#: get a mark wide enough to have a colour.
MINIMUM_WIDTH = 3

#: How far an editable segment's unused part is washed toward the surface
#: behind it. Far enough to read as empty, near enough to keep its hue.
WASH = 0.72

#: How far the flat "other" tone sits from the surface it is drawn on. Enough
#: to be a shape rather than a background, little enough that the coloured runs
#: over it are the only things with a hue.
OTHER_GREY = 0.22

#: The hues, and the one rule behind them: what you can put bytes in is green,
#: what already holds your bytes is coloured, and what is not yours is grey.
#: Chosen to hold up against both the light and the dark surface, since the bar
#: is painted on the window rather than over the game's own artwork.
KIND_COLORS = {
    LEVEL_DATA: QColor(0x3D, 0x7F, 0xC8),
    DATA_TABLE: QColor(0xC2, 0x7B, 0x2E),
    GRAPHICS: QColor(0x8E, 0x5B, 0xC4),
    FREE: QColor(0x46, 0x9E, 0x5E),
}

#: What each kind is called, in the legend and in the readout.
KIND_NAMES = {
    LEVEL_DATA: "level data",
    DATA_TABLE: "data table",
    GRAPHICS: "graphics",
    FREE: "free",
    OTHER: "other",
}

#: The kinds the summary and the bank notes count, each with its noun.
COUNTED = (
    (DATA_TABLE, "data table"),
    (LEVEL_DATA, "level region"),
    (GRAPHICS, "graphics run"),
)


def _blended(over: QColor, under: QColor, amount: float) -> QColor:
    """``over`` mixed ``amount`` of the way onto ``under``, opaque."""
    return QColor(
        *(
            round(below + (above - below) * amount)
            for above, below in (
                (over.red(), under.red()),
                (over.green(), under.green()),
                (over.blue(), under.blue()),
            )
        )
    )


def kind_color(kind: str, palette: QPalette) -> QColor:
    """The solid colour one kind of run is painted in.

    ``other`` is derived rather than written down: it is the *surface* seen
    from a little way off, and a literal grey that reads right against the
    light window is a smear against the dark one.
    """
    if kind in KIND_COLORS:
        return KIND_COLORS[kind]
    return _blended(
        palette.color(QPalette.ColorRole.WindowText),
        palette.color(QPalette.ColorRole.Base),
        OTHER_GREY,
    )


def wash(kind: str, palette: QPalette) -> QColor:
    """The colour an editable run's *unused* bytes are painted in."""
    return _blended(
        palette.color(QPalette.ColorRole.Base),
        kind_color(kind, palette),
        WASH,
    )


def describe(segment: Segment) -> str:
    """One line about a run of ROM: where it is, what it is, what is left."""
    where = hexnum(segment.start, 6)
    what = f"{KIND_NAMES.get(segment.kind, segment.kind)} · {segment.name}"
    sized = f"{segment.size:,} bytes"
    if segment.kind == FREE:
        parts = [where, what, f"{sized} free"]
    elif segment.spare is None:
        parts = [where, what, sized]
    else:
        parts = [where, what, f"{segment.used:,} of {sized}", spare_note(segment.spare)]
    if segment.detail:
        parts.append(segment.detail)
    return "   ·   ".join(parts)


def spare_note(spare: int) -> str:
    """How a run's remaining bytes are put -- including when there are fewer
    than none, which is an overlay the next build will refuse."""
    if spare < 0:
        return f"{-spare:,} over"
    return f"{spare:,} to spare"


class BankBar(QWidget):
    """One bank, painted to scale, with the run under the cursor pickable."""

    #: A run was hovered, or ``None`` when the cursor left the bar.
    hovered = Signal(object)
    #: A run was clicked.
    picked = Signal(object)

    def __init__(self, bank: Bank, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.bank = bank
        self._selected: Segment | None = None
        self.setMouseTracking(True)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        self.setMinimumHeight(BAR_HEIGHT)

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return QSize(480, BAR_HEIGHT)

    def select(self, segment: Segment | None) -> None:
        """Outline ``segment``, or nothing. Given a run in another bank this
        clears its own, which is what makes one selection span the window."""
        wanted = next((one for one in self.bank.segments if one is segment), None)
        if wanted is not self._selected:
            self._selected = wanted
            self.update()

    def segment_at(self, x: int) -> Segment | None:
        """Which run a point along the bar is in.

        Off the *address* rather than off the painted rectangles, so a segment
        too narrow to have been drawn at its true width is still picked where
        it really is -- the picture rounds, and this must not.
        """
        width = max(self.width(), 1)
        offset = min(int(x * self.bank.size / width), self.bank.size - 1)
        if offset < 0:
            return None
        seen = 0
        for one in self.bank.segments:
            seen += one.size
            if offset < seen:
                return one
        return None

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        palette = self.palette()
        area = self.rect()

        # The flat tone first, so every run the editor does not own is already
        # painted and only the ones it does have to be placed.
        painter.fillRect(area, kind_color(OTHER, palette))

        for one, box in self._boxes(area):
            if one.kind == OTHER:
                continue
            if one.spare is None or one.kind == FREE:
                painter.fillRect(box, kind_color(one.kind, palette))
                continue
            # Whole run washed, used bytes solid over it: the same rectangle
            # says how big the run is and how much of it is gone.
            painter.fillRect(box, wash(one.kind, palette))
            used = round(box.width() * min(one.used / max(one.size, 1), 1.0))
            if used:
                painter.fillRect(
                    QRect(box.left(), box.top(), used, box.height()),
                    kind_color(one.kind, palette),
                )

        if self._selected is not None:
            self._outline(painter, palette)
        painter.setPen(kind_color(OTHER, palette).darker(140))
        painter.drawRect(area.adjusted(0, 0, -1, -1))

    def _boxes(self, area: QRect) -> list[tuple[Segment, QRect]]:
        """Every run and the rectangle it gets, in order.

        Both edges are rounded from the same running offset, so neighbouring
        runs share an edge exactly and the bar has no seams -- and a run that
        rounds to nothing is widened to :data:`MINIMUM_WIDTH` rather than
        dropped. Widening overlaps the next run by a pixel, which costs nothing:
        the flat tone is painted underneath everything anyway, and a segment
        that needed the widening was too small to have an inside.
        """
        made = []
        offset = 0
        for one in self.bank.segments:
            left = round(offset * area.width() / self.bank.size)
            offset += one.size
            right = round(offset * area.width() / self.bank.size)
            width = max(right - left, MINIMUM_WIDTH)
            made.append((one, QRect(left, area.top(), width, area.height())))
        return made

    def _outline(self, painter: QPainter, palette: QPalette) -> None:
        """Ring the selected run. Drawn last and over everything, because what
        it has to be legible against is whatever it happens to sit on."""
        for one, box in self._boxes(self.rect()):
            if one is not self._selected:
                continue
            painter.setPen(palette.color(QPalette.ColorRole.WindowText))
            painter.drawRect(box.adjusted(0, 0, -1, -1))
            return

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        found = self.segment_at(event.position().toPoint().x())
        self.setToolTip(describe(found) if found is not None else "")
        self.hovered.emit(found)

    def leaveEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        self.hovered.emit(None)
        super().leaveEvent(event)

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        found = self.segment_at(event.position().toPoint().x())
        if found is not None:
            self.picked.emit(found)


class BudgetBar(QWidget):
    """How full one run of ROM is, in the picture a bank's segments are drawn
    in: the whole run washed, the bytes used solid over it, and how many of
    them across the middle.

    Flat and still on purpose. A styled progress bar animates, and an animated
    bar says something is *happening*; this one says how much room is left,
    which is a fact about the project and not an event.
    """

    def __init__(
        self,
        kind: str = DATA_TABLE,
        parent: QWidget | None = None,
        height: int = BAR_HEIGHT,
    ) -> None:
        super().__init__(parent)
        self._kind = kind
        self._height = height
        self._filled = 0.0
        self._text = ""
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        self.setMinimumHeight(height)

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return QSize(240, self._height)

    @property
    def text(self) -> str:
        """What is written across the bar."""
        return self._text

    def show_budget(self, used: int, room: int | None, text: str) -> None:
        """Fill the bar for ``used`` of ``room`` bytes and write ``text`` on it.

        A ``room`` of ``None`` -- nothing to price against -- fills it whole:
        there is no proportion to draw, and an empty bar under a byte count
        would read as room to spare that nobody has counted.
        """
        self._filled = 1.0 if not room else min(used / room, 1.0)
        self._text = text
        self.update()

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        palette = self.palette()
        area = self.rect()
        painter.fillRect(area, wash(self._kind, palette))
        filled = round(area.width() * self._filled)
        if filled:
            painter.fillRect(
                QRect(area.left(), area.top(), filled, area.height()),
                kind_color(self._kind, palette),
            )
        painter.setPen(kind_color(OTHER, palette).darker(140))
        painter.drawRect(area.adjusted(0, 0, -1, -1))
        painter.setPen(palette.color(QPalette.ColorRole.WindowText))
        painter.drawText(area, Qt.AlignmentFlag.AlignCenter, self._text)

    def changeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        """Repaint on a theme change, for :class:`_Swatch`'s reason: the
        colours are derived here rather than held, so nothing about the widget
        is content Qt could notice going stale."""
        if event.type() == QEvent.Type.PaletteChange:
            self.update()
        super().changeEvent(event)


class MemoryMapDialog(QDialog):
    """The project's cartridge, bank by bank.

    Held open by the window rather than run modally, the way the level-file
    viewer is: it is something to keep beside the work while making room, not a
    question to answer. :meth:`show_map` is what puts a fresh reading in it, so
    the window can refresh one that is already open.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self.setModal(False)
        self._bars: list[BankBar] = []
        self._selected: Segment | None = None

        layout = QVBoxLayout(self)
        self._hint = QLabel(HINT)
        self._hint.setWordWrap(True)
        layout.addWidget(self._hint)

        self._summary = QLabel()
        self._summary.setWordWrap(True)
        layout.addWidget(self._summary)

        self._banks = QWidget()
        self._bank_layout = QVBoxLayout(self._banks)
        self._bank_layout.setContentsMargins(0, 0, 0, 0)
        self._bank_layout.setSpacing(10)

        self._bank_scroll = QScrollArea()
        self._bank_scroll.setWidget(self._banks)
        self._bank_scroll.setWidgetResizable(True)
        self._bank_scroll.setFrameShape(QFrame.Shape.NoFrame)

        # The banks and the foot in a splitter: a foot whose height the window
        # keeps is one that does not shove the banks about as the cursor
        # crosses them, and the height it keeps is the reader's to set.
        split = QSplitter(Qt.Orientation.Vertical, self)
        split.setChildrenCollapsible(False)
        split.addWidget(self._bank_scroll)

        foot = QWidget(split)
        foot_layout = QVBoxLayout(foot)
        foot_layout.setContentsMargins(0, 6, 0, 0)
        foot_layout.addWidget(self._legend())

        # One readout for the whole window, under the banks: a run named here
        # rather than in sixteen places keeps the bars free of text they have
        # no room for. Scrolled inside the foot, so a long one is reachable at
        # whatever height the foot has been dragged to.
        self._readout = QLabel()
        self._readout.setWordWrap(True)
        self._readout.setAlignment(
            Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft
        )
        self._readout.setTextInteractionFlags(
            Qt.TextInteractionFlag.TextSelectableByMouse
        )
        held = QScrollArea(foot)
        held.setWidget(self._readout)
        held.setWidgetResizable(True)
        held.setFrameShape(QFrame.Shape.NoFrame)
        foot_layout.addWidget(held, 1)

        split.addWidget(foot)
        split.setStretchFactor(0, 1)
        split.setStretchFactor(1, 0)
        split.setSizes([560, FOOT_HEIGHT])
        layout.addWidget(split, 1)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)
        self.resize(880, 720)

    def show_map(self, laid_out: MemoryMap) -> None:
        """Draw ``laid_out``, replacing whatever was shown before."""
        self._selected = None
        while self._bank_layout.count():
            taken = self._bank_layout.takeAt(0)
            if (widget := taken.widget()) is not None:
                widget.deleteLater()
        self._bars = []

        for bank in laid_out.banks:
            self._bank_layout.addWidget(self._bank_row(bank))
        self._bank_layout.addStretch(1)

        self._summary.setText(_summary(laid_out))
        self._summary.setVisible(True)
        self._show(None)

    def _bank_row(self, bank: Bank) -> QWidget:
        """One bank: what is in it in words, and the bar under that."""
        row = QWidget()
        stacked = QVBoxLayout(row)
        stacked.setContentsMargins(0, 0, 0, 0)
        stacked.setSpacing(3)

        header = QHBoxLayout()
        name = QLabel(f"<b>Bank {bank.label}</b>   {_bank_note(bank)}")
        header.addWidget(name)
        header.addStretch(1)
        header.addWidget(
            _Note(f"{hexnum(bank.start, 6)}–{hexnum(bank.start + bank.size - 1, 6)}")
        )
        stacked.addLayout(header)

        bar = BankBar(bank, row)
        bar.hovered.connect(self._hovered)
        bar.picked.connect(self._picked)
        self._bars.append(bar)
        stacked.addWidget(bar)
        return row

    def _legend(self) -> QWidget:
        """The five tones and what each means."""
        row = QWidget()
        layout = QHBoxLayout(row)
        layout.setContentsMargins(0, 0, 0, 0)
        for kind in (LEVEL_DATA, DATA_TABLE, GRAPHICS, FREE, OTHER):
            layout.addWidget(_Swatch(kind, row))
            layout.addWidget(QLabel(KIND_NAMES[kind]))
            layout.addSpacing(12)
        layout.addStretch(1)
        return row

    def _hovered(self, segment: Segment | None) -> None:
        """Name what the cursor is over, and fall back to the selection when it
        leaves -- so moving off a bar does not blank the readout that was
        deliberately put there."""
        self._show(segment if segment is not None else self._selected)

    def _picked(self, segment: Segment) -> None:
        self._selected = segment
        for bar in self._bars:
            bar.select(segment)
        self._show(segment)

    def _show(self, segment: Segment | None) -> None:
        self._readout.setText(
            describe(segment) if segment is not None else "Hover a run to name it."
        )


class _Note(QLabel):
    """A label in the greyed ink a note is written in.

    Its own class because the ink is *derived* from the surface behind it
    (:func:`~shiny_mushroom.ui.tables.note_ink`), so it has to be derived again
    when that surface changes -- which is what a stylesheet colour would not
    do, and what makes this ten lines instead of one.
    """

    def __init__(self, text: str, parent: QWidget | None = None) -> None:
        super().__init__(text, parent)
        self._inking = False
        self._ink()

    def _ink(self) -> None:
        """Grey this label's ink against the *application's* colours.

        Against the application's rather than its own, and guarded against
        itself, because both ways round this eats its own tail: setting a
        palette sends the widget a ``PaletteChange`` synchronously, and a
        greying derived from the colour it just set would step toward the
        surface every time until the text was the surface.
        :class:`shiny_mushroom.ui.tables._Restyled` guards the same trap for
        the same reason.
        """
        if self._inking:
            return
        self._inking = True
        try:
            palette = self.palette()
            palette.setColor(QPalette.ColorRole.WindowText, note_ink())
            self.setPalette(palette)
        finally:
            self._inking = False

    def changeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if event.type() == QEvent.Type.PaletteChange:
            self._ink()
        super().changeEvent(event)


class _Swatch(QWidget):
    """A block of one kind's colour, for the legend. A widget rather than a
    coloured character so it follows the theme with everything else."""

    SIDE = 12

    def __init__(self, kind: str, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._kind = kind
        self.setFixedSize(self.SIDE, self.SIDE)

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        painter.fillRect(self.rect(), kind_color(self._kind, self.palette()))

    def changeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        """Repaint when the theme moves. Asked for explicitly because the only
        thing this widget draws is a colour it derives itself: nothing about it
        is content Qt could notice going stale."""
        if event.type() == QEvent.Type.PaletteChange:
            self.update()
        super().changeEvent(event)


def _summary(laid_out: MemoryMap) -> str:
    """The whole cartridge in one line, plus a word about what is missing.

    Two totals rather than one, because they answer different questions: the
    padding is room anything may take, and the larger figure is that plus what
    the editable runs have left, which only the thing already in each of them
    can use.
    """
    segments = [one for bank in laid_out.banks for one in bank.segments]
    counted = [_counted(segments, kind, noun) for kind, noun in COUNTED]
    line = "   ·   ".join(
        (
            f"{bytes_label(laid_out.size)} cartridge",
            f"{laid_out.padding:,} bytes of padding",
            f"{laid_out.free:,} including what the editable runs have to spare",
            *counted,
        )
    )
    notes = [] if laid_out.priced else [UNPRICED]
    if laid_out.mapped < laid_out.size:
        notes.append(UNMAPPED.format(shown=bytes_label(laid_out.mapped)))
    return "\n".join([line, *notes])


def _bank_note(bank: Bank) -> str:
    """What one bank holds, for the line above its bar."""
    parts = [f"{bank.padding:,} bytes of padding"]
    for kind, noun in COUNTED:
        if any(one.kind == kind for one in bank.segments):
            parts.append(_counted(bank.segments, kind, noun))
    return "   ·   ".join(parts)


def _counted(segments: Sequence[Segment], kind: str, noun: str) -> str:
    """``3 data tables``, and ``1 data table`` when that is what there is."""
    count = sum(1 for one in segments if one.kind == kind)
    return f"{count} {noun}" if count == 1 else f"{count} {noun}s"
