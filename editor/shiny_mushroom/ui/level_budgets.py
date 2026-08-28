"""What the level banks hold, run by run: the foot of the Level Data window.

A reading of :class:`~shiny_mushroom.memory_map.LevelBudgets` and nothing
else -- the runs the streams are written into, how full each is, and the one
fact that decides what a level growing costs. It shares nothing with the
three tables it sits under but the splitter between them, so it is a widget
of its own rather than five methods on that dialog, and it draws its bars
with the memory map's own :class:`~shiny_mushroom.ui.memory_map_dialog.
BudgetBar` so a run looks the same in both windows.

The widget owns no document: it is handed budgets and draws them
([`architecture`](../../../docs/editor/architecture.md)). How much of the
window it is worth is the reader's, and that is the splitter's -- so the
height it *wants* is answered here (:meth:`wanted_height`) and acted on by
whoever holds the handle.
"""

from __future__ import annotations

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QFrame,
    QGridLayout,
    QLabel,
    QScrollArea,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memory_map import LEVEL_DATA, LevelBudgets, Segment
from shiny_mushroom.ui.memory_map_dialog import BudgetBar, describe, spare_note
from shiny_mushroom.ui.tables import style_note

#: What the foot says under the tabs, above the bars, by whether the level
#: banks are packed -- the one fact that decides what a level growing costs.
PACKED_NOTE = (
    "The level banks are packed end to end (Growable levels), so a stream "
    "that grows takes room from the others."
)
STOCK_NOTE = (
    "Each run is packed on its own, so a level that grows is paid for by "
    "another in it. Growable levels (Project > Features) packs the banks end "
    "to end."
)

#: How tall one run's bar is. Shorter than the memory map's, because eight of
#: them sit under a window that is mostly table.
BUDGET_HEIGHT = 20

#: The widest a run's name is drawn, in pixels; longer ones are elided and
#: said in full in the row's tooltip.
NAME_WIDTH = 210


def budget_summary(budgets: LevelBudgets) -> str:
    """The runs in one line, and what makes a level growing cost what it does."""
    runs = len(budgets.runs)
    return (
        f"Level data lives in {runs} run{'' if runs == 1 else 's'} of ROM: "
        f"{budgets.used:,} of {budgets.size:,} bytes"
        f"   ·   {spare_note(budgets.spare)}\n"
        + (PACKED_NOTE if budgets.packed else STOCK_NOTE)
    )


def budget_text(one: Segment) -> str:
    """What is written across one run's bar."""
    if one.spare is None:
        return f"{one.size:,} bytes"
    return f"{one.used:,} of {one.size:,} bytes   ·   {spare_note(one.spare)}"


class LevelBudgetFoot(QWidget):
    """The runs the level streams are written into: a line about all of them,
    and a bar apiece. Handed budgets by :meth:`show_budgets`."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 6, 0, 0)
        layout.setSpacing(4)
        self._note = QLabel(self)
        style_note(self._note)
        layout.addWidget(self._note)

        self._rows = held = QWidget(self)
        self._grid = QGridLayout(held)
        self._grid.setContentsMargins(0, 0, 0, 0)
        self._grid.setHorizontalSpacing(8)
        self._grid.setVerticalSpacing(2)
        self._grid.setColumnStretch(2, 1)
        # Scrolled, so a base with more runs than the window has room for is
        # reachable rather than cut off.
        scroll = QScrollArea(self)
        scroll.setWidget(held)
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.Shape.NoFrame)
        layout.addWidget(scroll, 1)
        self._runs = 0

    # -- what is shown --------------------------------------------------------

    def show_budgets(self, budgets: LevelBudgets | None) -> int:
        """Draw ``budgets``, saying how many runs there were.

        Rebuilt rather than updated in place: the runs themselves change with
        the Growable levels feature -- three packed ones for eight bank
        macros -- so there is no row to keep. Nothing to price hides the foot
        altogether, which is what an unreadable container and a bare window
        both have.
        """
        self.setVisible(budgets is not None and bool(budgets.runs))
        while self._grid.count():
            taken = self._grid.takeAt(0)
            if (widget := taken.widget()) is not None:
                widget.deleteLater()
        self._runs = 0
        if budgets is None or not budgets.runs:
            self._note.clear()
            return 0
        self._note.setText(budget_summary(budgets))
        for row, one in enumerate(budgets.runs):
            for column, widget in enumerate(self._run_row(one)):
                widget.setToolTip(describe(one))
                self._grid.addWidget(widget, row, column)
        self._runs = len(budgets.runs)
        return self._runs

    def _run_row(self, one: Segment) -> tuple[QWidget, QWidget, QWidget]:
        """One run: what it is called, where it is, and how full it is."""
        name = QLabel(self)
        name.setText(
            name.fontMetrics().elidedText(
                one.name, Qt.TextElideMode.ElideRight, NAME_WIDTH
            )
        )
        where = QLabel(
            f"{hexnum(one.start, 6)}–{hexnum(one.start + one.size - 1, 6)}",
            self,
        )
        style_note(where)
        bar = BudgetBar(LEVEL_DATA, self, height=BUDGET_HEIGHT)
        bar.show_budget(one.used or 0, one.size, budget_text(one))
        return name, where, bar

    # -- what it says ---------------------------------------------------------

    @property
    def runs(self) -> int:
        """How many runs are drawn."""
        return self._runs

    @property
    def summary(self) -> str:
        """The line above the bars."""
        return self._note.text()

    @property
    def rows(self) -> tuple[tuple[QWidget, QWidget, BudgetBar], ...]:
        """Every run's three widgets, in order -- its name, where it is, and
        its bar."""
        return tuple(
            tuple(
                self._grid.itemAtPosition(row, column).widget() for column in range(3)
            )
            for row in range(self._runs)
        )

    def wanted_height(self, width: int) -> int:
        """What the foot wants inside a window ``width`` across: its note, and
        every run's bar under it.

        Off the rows rather than this widget's own hint, because the rows are
        inside a scroll area, whose hint is what it can be squeezed to rather
        than what it holds.
        """
        return (
            self._rows.sizeHint().height()
            + self._note.heightForWidth(max(width - 24, 200))
            + 16
        )


__all__ = [
    "BUDGET_HEIGHT",
    "NAME_WIDTH",
    "PACKED_NOTE",
    "STOCK_NOTE",
    "LevelBudgetFoot",
    "budget_summary",
    "budget_text",
]
