"""The Features dialog: what this cartridge is, and which of it is a choice.

A view over :mod:`shiny_mushroom.features`, writing through as a box is
ticked. There is no OK/Cancel pair for the same reason the Patches dialog has
none -- ``project.json`` and the overlay are the state, and a dialog that held
the change until the end would have to hold a half-run migration with it.

**A row that cannot move says why, rather than going quiet.** Every feature
this build declares gets a row, and each one is asked what standing in its way
-- a base built with it, a patch that provides it, a world map grown past what
the stock tables hold. The reason and its remedy are under the list, so the
greyed checkbox is never the whole message.

The list and that pane share a splitter, so the reader decides how much of
each they want. The pane paints what fits and cuts off the rest: a long
description takes the height it was given rather than taking it from the list.

What the window needs afterwards is :attr:`FeaturesDialog.applied_changed` --
whether the next build makes a different cartridge, asked of the project
against how it was found rather than of how many boxes were clicked -- and
:attr:`FeaturesDialog.project`, which is not always the one that went in: a
feature needing an expansion bank raises the cartridge size on the way on, and
a project is frozen.
"""

from __future__ import annotations

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
    QSizePolicy,
    QSplitter,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import features
from shiny_mushroom.project import Project, ProjectError
from smw_tools.features import FeatureError

#: The item data slot holding the feature's id.
_ID_ROLE = Qt.ItemDataRole.UserRole

#: The smallest either half of the splitter may be dragged to, in pixels --
#: enough of the list to read a row, and enough of the pane to read a line.
_LIST_FLOOR = 80
_DETAIL_FLOOR = 28

#: The pane's share when the dialog opens, against the list's floor: room for
#: the longest description a feature declares, before anyone drags it.
_DETAIL_SHARE = 130

#: What the list says when this build declares no features at all. The honest
#: answer for a disassembly that has not grown one yet, and not an error: the
#: registry is meant to be empty until a patch or a define earns an entry.
NOTHING_DECLARED = (
    "This build declares no features. One appears here as soon as the "
    "disassembly carries it."
)


class FeaturesDialog(QDialog):
    """One project's features. Construct, ``exec``, then read
    :attr:`applied_changed` and :attr:`project`."""

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        #: The project as it now is. Re-read after every switch, because a
        #: migration may have handed back a different one.
        self.project = project
        #: Whether the next build would make a different cartridge.
        self.applied_changed = False
        #: What the migrations said, oldest first -- the window shows the last.
        self.notes: list[str] = []
        #: The switches as they stood when the dialog opened, to answer
        #: :attr:`applied_changed` against. A box ticked and unticked again
        #: leaves the project where it was found, and nothing owes a build.
        #: As a set: the build reads the ids, never the order they were
        #: recorded in, and switching one off and on again moves it to the end.
        self._opened_with = frozenset(project.feature_state)
        self._rows: tuple[features.FeatureRow, ...] = ()
        self.setWindowTitle("Features")
        self.setMinimumSize(480, 360)

        layout = QVBoxLayout(self)
        hint = QLabel(
            "Ticked features are built in at the next build. One that cannot "
            "be switched says why below."
        )
        hint.setWordWrap(True)
        layout.addWidget(hint)

        self._list = QListWidget()
        self._list.setMinimumHeight(_LIST_FLOOR)
        self._list.itemChanged.connect(self._toggled)
        self._list.currentRowChanged.connect(lambda _row: self._describe())

        self._detail = QLabel()
        self._detail.setWordWrap(True)
        self._detail.setAlignment(
            Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop
        )
        # The pane is whatever height the reader dragged it to, and the label
        # is painted into it: a description longer than that is cut off rather
        # than pushing the list out of the window. Ignored is what frees the
        # splitter to go under the label's own wrapped height.
        self._detail.setSizePolicy(
            QSizePolicy.Policy.Ignored, QSizePolicy.Policy.Ignored
        )
        pane = QWidget()
        pane.setMinimumHeight(_DETAIL_FLOOR)
        inside = QVBoxLayout(pane)
        inside.setContentsMargins(0, 0, 0, 0)
        inside.addWidget(self._detail)

        self._split = QSplitter(Qt.Orientation.Vertical)
        self._split.setChildrenCollapsible(False)
        self._split.addWidget(self._list)
        self._split.addWidget(pane)
        self._split.setStretchFactor(0, 1)
        self._split.setStretchFactor(1, 0)
        self._split.setSizes([_LIST_FLOOR * 3, _DETAIL_SHARE])
        layout.addWidget(self._split)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

        self._refill()

    # -- the list ------------------------------------------------------------

    def _refill(self) -> None:
        chosen = self._current_id()
        self._list.blockSignals(True)
        self._list.clear()
        self._rows = features.rows(self.project)
        for row in self._rows:
            item = QListWidgetItem(_title(row))
            item.setData(_ID_ROLE, row.feature.id)
            flags = item.flags() | Qt.ItemFlag.ItemIsUserCheckable
            if not row.movable:
                # The tick is taken away, not the row. A greyed-out row could
                # not be selected, and selecting it is how the reason it
                # cannot move is read -- which is the half that matters.
                flags &= ~Qt.ItemFlag.ItemIsUserCheckable
            item.setFlags(flags)
            item.setCheckState(
                Qt.CheckState.Checked if row.on else Qt.CheckState.Unchecked
            )
            item.setToolTip(_summary(row))
            self._list.addItem(item)
            if row.feature.id == chosen:
                self._list.setCurrentItem(item)
        self._list.blockSignals(False)
        if not self._rows:
            self._detail.setText(NOTHING_DECLARED)
            return
        if self._list.currentRow() < 0:
            self._list.setCurrentRow(0)
        self._describe()

    def _describe(self) -> None:
        """Say what the selected feature is, and what stands in its way.

        The feature's own half is :class:`~smw_tools.features.Described` and is
        rendered rather than assembled -- see :func:`_summary`. What is added
        here is everything that is true of this *project* rather than of the
        feature: which way the switch is waiting to move, what refuses to move
        it, and what the last migration did.
        """
        row = self._selected()
        if row is None:
            self._detail.setText(NOTHING_DECLARED if not self._rows else "")
            return
        lines = list(row.feature.described.lines)
        if row.stale:
            lines.append(
                "In the cartridge at the next build."
                if row.on
                else "Out of the cartridge at the next build."
            )
        for limit in row.limits:
            lines.append(limit.reason + (f" {limit.remedy}" if limit.remedy else ""))
        if self.notes:
            lines.append(self.notes[-1])
        self._detail.setText("\n".join(lines))

    def _selected(self) -> features.FeatureRow | None:
        chosen = self._current_id()
        return next((row for row in self._rows if row.feature.id == chosen), None)

    def _current_id(self) -> str | None:
        item = self._list.currentItem()
        return item.data(_ID_ROLE) if item is not None else None

    # -- what a tick does ------------------------------------------------------

    def _toggled(self, item: QListWidgetItem) -> None:
        """Switch the feature the box belongs to, and say what that did.

        Every path out refills the list, which is what puts a refused tick
        back: the boxes are drawn from what the project says rather than from
        what was clicked.
        """
        feature_id = item.data(_ID_ROLE)
        wanted = item.checkState() == Qt.CheckState.Checked
        switch = features.enable if wanted else features.disable
        try:
            done = switch(self.project, feature_id)
        except features.FeatureBlocked as blocked:
            self._refuse(feature_id, blocked)
            self._refill()
            return
        except (FeatureError, ProjectError, OSError) as error:
            QMessageBox.warning(self, "Features", str(error))
            self._refill()
            return
        self.project = done.project
        self.notes += done.notes
        # Asked of the project rather than latched: the switches are compared
        # against the ones the dialog opened on, so ticking a box and
        # unticking it again owes no build. A migration is the exception it
        # has to carry -- growing the cartridge or re-fitting a table is not
        # undone by moving the switch back, so having said anything at all is
        # a change in its own right.
        self.applied_changed = bool(self.notes) or (
            frozenset(self.project.feature_state) != self._opened_with
        )
        self._refill()

    def _refuse(self, feature_id: str, blocked: features.FeatureBlocked) -> None:
        listed = "\n\n".join(
            limit.reason + (f"\n{limit.remedy}" if limit.remedy else "")
            for limit in blocked.limits
        )
        QMessageBox.information(self, f"{feature_id} cannot be switched", listed)


def _title(row: features.FeatureRow) -> str:
    """The row's one line: the name, and where it comes from when that is not
    this project's own choice."""
    if row.held_by == features.BY_BASE:
        return f"{row.feature.name}  (built into the ROM base)"
    if row.held_by == features.BY_PATCH and row.on:
        return f"{row.feature.name}  (added by a patch)"
    if row.stale:
        return f"{row.feature.name}  (at the next build)"
    return row.feature.name


def _summary(row: features.FeatureRow) -> str:
    """The row's tooltip: the feature named, then what it is.

    :attr:`~smw_tools.features.Described.brief` rather than a second reading
    of the declaration, so this and the detail pane render one description and
    a fact added to the declaration reaches both. Only the paragraph differs.
    """
    described = row.feature.described
    lines = [f"{described.name} ({described.id})", *described.brief]
    lines += [limit.reason for limit in row.limits]
    return "\n".join(lines)
