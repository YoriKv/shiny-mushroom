"""`Level > Level Exits`: every screen the open level leads out of, as rows.

A table editor over :mod:`shiny_mushroom.level_exits`, on the same terms as the
world map's nine (:mod:`shiny_mushroom.ui.world_tables`): the dialog owns no
document, a committed cell is a *question* for the window, and the rows are
re-shown whenever the level changes under them -- a commit, an undo, a level
opened, a screen's exit added from the canvas.

**It is the same record the properties panel describes.** Clicking a row's index
selects that screen on the canvas, which puts its number box in the ants and
fills the panel; clicking a screen's number box on the canvas fills this row's
selection from the other end. One idea, two handles -- see
[`docs/editor/level-exits.md`](../../../docs/editor/level-exits.md).
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from shiny_mushroom.level_exits import ScreenExit, exit_columns, exit_rows
from shiny_mushroom.ui.table_editor import TableEditorDialog

if TYPE_CHECKING:
    from collections.abc import Callable

    from PySide6.QtWidgets import QWidget

    from shiny_mushroom.edit import Level
    from shiny_mushroom.fields import Choice
    from shiny_mushroom.secondary_entrances import Entrances

#: The footer's own key -- a dialog-level action rather than a field's, so it
#: lives with the dialog's owner exactly as the world tables' adds do.
EXIT_TABLE_ADD = "exit-table-add"

TITLE = "Level Exits"

NOTE = (
    "Where each of this level's screens leads -- one exit per screen. "
    "Clicking a row's index selects that screen on the canvas, and the other "
    "way round."
)


class LevelExits:
    """The Level Exits window, opened lazily and kept for the session.

    Built like a world table and for the same reasons: the one dialog is kept
    so reopening lands where it was left, and every hook the window has -- a
    settled edit, a level closed -- goes through :meth:`refresh` or
    :meth:`close` rather than through the widget.
    """

    def __init__(
        self,
        parent: QWidget,
        document: Callable[[], Level | None],
        levels: Callable[[], tuple[Choice, ...]],
        entrances: Callable[[], Entrances | None],
        adopt: Callable[[QWidget], None],
        commit: Callable[[int, str, int], None],
        add: Callable[[], None],
        select: Callable[[int | None], None],
    ) -> None:
        self._parent = parent
        #: The level as it now stands, asked for rather than held: every edit
        #: is a rewrite, so a held one would be the level as it was.
        self._document = document
        #: What each row's destination picker offers -- the cartridge's levels
        #: named by their containers, asked for rather than held for
        #: ``document``'s reason: a project remapping a level renames its row.
        self._levels = levels
        #: The arrival tables, which is what a row marked Secondary entrance
        #: offers and where it leads. Asked for the same way and for the same
        #: reason: the Secondary Entrances window can rewrite one while this
        #: is up.
        self._entrances = entrances
        self._adopt = adopt
        #: What a committed cell, the footer and a selected row mean. All three
        #: belong to the window: this dialog owns no document and no canvas.
        self._commit = commit
        self._add = add
        self._select = select
        self.dialog: TableEditorDialog | None = None
        #: Set while a selection is being written *into* the table from the
        #: canvas, so the echo does not travel back out and re-select the
        #: screen that caused it.
        self._echoing = False

    # -- the window ---------------------------------------------------------

    def open(self) -> None:
        """Show the table, or bring the one already up forward."""
        if self._document() is None:
            return
        if self.dialog is None:
            self.dialog = TableEditorDialog(
                TITLE,
                note=NOTE,
                actions=((EXIT_TABLE_ADD, "Add exit"),),
                selectable=True,
                parent=self._parent,
            )
            self.dialog.edited.connect(self._edited)
            self.dialog.acted.connect(self._acted)
            self.dialog.selected.connect(self._selected)
            self._adopt(self.dialog)
        self._show()
        self.dialog.show()
        self.dialog.raise_()
        self.dialog.activateWindow()

    def refresh(self) -> None:
        """Follow the document: a commit, an undo and a level opened all land
        in these rows.

        Re-shown rather than refreshed whenever the *count* changes -- which is
        what an add and a remove are -- and that is
        :meth:`TableEditorDialog.refresh`'s own rule, so this only has to hand
        over the rows as they now stand.
        """
        if self.dialog is None or self._document() is None:
            return
        self._show()

    def close(self) -> None:
        """Put the table away with the level or the cartridge."""
        if self.dialog is not None:
            self.dialog.close()

    def show_screen(self, screen: int | None) -> None:
        """Mark the row for ``screen`` as selected, or clear the selection.

        The canvas's side of the same idea: a screen selected there is the row
        being described here. A screen with no exit has no row, so its
        selection clears this one rather than leaving a stale row lit.
        """
        if self.dialog is None:
            return
        rows = self._rows()
        found = next(
            (index for index, row in enumerate(rows) if row.screen == screen), None
        )
        self._echoing = True
        try:
            self.dialog.select_row(found)
        finally:
            self._echoing = False

    # -- what it says -------------------------------------------------------

    def _rows(self) -> list[ScreenExit]:
        """The level's exits as rows, or none where there is no level."""
        document = self._document()
        if document is None:
            return []
        return exit_rows(document, self._levels(), self._entrances())

    def _show(self) -> None:
        assert self.dialog is not None
        document = self._document()
        assert document is not None
        rows = self._rows()
        self.dialog.set_heading(_heading(len(rows), document.shape.screens))
        self.dialog.show_rows(exit_columns, rows)

    # -- what a gesture in it means -----------------------------------------

    def _edited(self, row: int, key: str, value: int) -> None:
        """A committed cell, keyed by *screen* rather than by row: the rows are
        re-derived from the document on every refresh, so the row index is a
        fact about the table on screen and the screen is a fact about the
        level."""
        rows = self._rows()
        if 0 <= row < len(rows):
            self._commit(rows[row].screen, key, value)

    def _acted(self, key: str) -> None:
        if key == EXIT_TABLE_ADD:
            self._add()

    def _selected(self, row: object) -> None:
        """A selected row shows its screen on the canvas, and the selection
        going down puts the canvas's down with it -- the world tables' rule on
        their own triggers."""
        if self._echoing:
            return
        if row is None:
            self._select(None)
            return
        assert isinstance(row, int)
        rows = self._rows()
        if 0 <= row < len(rows):
            self._select(rows[row].screen)


def _heading(exits: int, screens: int) -> str:
    """What the rows are of: how many of the level's screens lead out of it."""
    if not exits:
        return f"No exits -- {_plural(screens, 'screen')}, none of them leading out"
    return f"{_plural(exits, 'exit')} over {_plural(screens, 'screen')}"


def _plural(count: int, what: str) -> str:
    return f"{count} {what}{'' if count == 1 else 's'}"
