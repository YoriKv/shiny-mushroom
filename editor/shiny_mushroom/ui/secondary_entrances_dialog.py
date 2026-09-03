"""`Project > Secondary Entrances`: the cartridge's arrivals, as rows.

A table editor over :mod:`shiny_mushroom.secondary_entrances`, on the world
tables' terms -- a grid whose columns are field descriptors and whose rows
are records -- but over a document of the **project's** rather than of a
level: the four tables are indexed by the entrance number and belong to no
level, so nothing here follows what is on the canvas.

**The window owns its document**, like the Map16 editor and for the same
reason ([undo-redo.md](../../../docs/editor/undo-redo.md) gives every
document a stack of its own): the tables are read out of the project when
the window opens, edited in place on a :class:`~shiny_mushroom.edit.History`
of the window's own, and written back by Save. Revert takes the project's
fragments out and re-reads the disassembly's. Closing over unsaved edits
asks Save, Discard or Cancel through :meth:`_ask_to_save`, the seam the
suite replaces.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from PySide6.QtCore import QEvent, Signal
from PySide6.QtGui import QKeySequence, QShortcut

from shiny_mushroom.build import BuildError, asm_runs
from shiny_mushroom.edit import History
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.project import HandEditedRegion, ProjectError
from shiny_mushroom.secondary_entrances import (
    COUNT,
    FOLLOW,
    REGION_IDS,
    Entrances,
    EntrancesError,
    SecondaryEntrance,
    entrance_columns,
    entrance_rows,
    used_entrances,
)
from shiny_mushroom.ui.dialogs import Choice as Answer
from shiny_mushroom.ui.dialogs import ask, ask_to_save, mark_unsaved, warn
from shiny_mushroom.ui.table_editor import TableEditorDialog
from smw_tools.asm_codec import AsmRegionError, AsmRegionFull

if TYPE_CHECKING:
    from collections.abc import Callable

    from PySide6.QtWidgets import QWidget

    from shiny_mushroom.fields import Choice
    from shiny_mushroom.project import Project

TITLE = "Secondary Entrances"

#: Found by name in tests.
OBJECT_NAME = "secondary-entrances-window"

#: The footer's own keys -- window-level actions rather than a field's.
SAVE = "secondary-entrances-save"
REVERT = "secondary-entrances-revert"

#: The filter over the table: the rows an entrance number has been written
#: into, rather than all 512 of them.
ONLY_USED = "secondary-entrances-only-used"

ONLY_USED_HINT = (
    "Hide every entrance whose four bytes are all zero -- on when the window "
    "opens. Uncheck to reach a blank row and fill one in."
)

#: What the heading says while the filter is on. The count is of the rows the
#: table holds, not of the rows edited since: the filter is asked when it is
#: switched, so a row blanked afterwards is still on show.
SHOWING = "Showing the {shown} entrances in use, of {total}."

NOTE = (
    "Where a screen exit marked Secondary entrance lands. The row sets both "
    "the level loaded and where the player arrives. $000-$0FF are reached "
    "from the main map, $100-$1FF from a submap."
)

REVERT_TIP = (
    "Take the saved secondary entrances out and read the disassembly's tables again."
)
SAVE_TIP = "Write the tables into the project."

#: The keys a cell's control would otherwise keep for its own typing --
#: see :meth:`SecondaryEntrancesDialog.eventFilter`.
UNDO_KEYS = (QKeySequence.StandardKey.Undo, QKeySequence.StandardKey.Redo)


class SecondaryEntrancesDialog(TableEditorDialog):
    """The Secondary Entrances window: the four tables, one row per entrance.

    A :class:`~shiny_mushroom.ui.table_editor.TableEditorDialog` that owns
    the document it shows. The base class is a view and applies nothing --
    this subclass is the owner, so a committed cell is applied here,
    committed to the history and shown again, exactly as the main window
    does for a level's rows.
    """

    #: The tables changed under whoever else is reading them -- an edit, an
    #: undo, a revert. A screen exit marked Secondary entrance is offered
    #: these rows and resolved through them, so the canvas's screen labels
    #: and the properties panel follow this rather than going stale until the
    #: level is next touched.
    changed = Signal()

    def __init__(
        self,
        project: Project,
        levels: Callable[[], tuple[Choice, ...]],
        open_level: Callable[[SecondaryEntrance], None],
        parent: QWidget | None = None,
    ) -> None:
        # The entrance numbers on show, one per row, filled by `_refill`
        # before anything is shown. Made here and handed to the index column
        # as a list rather than as this dialog, and mutated in place ever
        # after: Qt paints a header from the model long after the dialog's
        # own C++ object is gone, and a label that reached back into the
        # widget would go with it.
        shown: list[int] = []
        super().__init__(
            TITLE,
            note=NOTE,
            actions=((SAVE, "&Save"), (REVERT, "&Revert")),
            toggles=((ONLY_USED, "Only entrances in &use", ONLY_USED_HINT),),
            # The row *is* the entrance number, which is written in hex
            # wherever else it appears -- in the note above the table, in a
            # destination, in the exit record that names it. Filtered, the
            # rows are no longer the numbers, which is the other half of why
            # the index column is asked rather than counted.
            index_label=lambda row: (
                hexnum(shown[row], 3) if 0 <= row < len(shown) else ""
            ),
            parent=parent,
        )
        self._shown = shown
        self.setObjectName(OBJECT_NAME)
        self._project = project
        #: What each row's destination picker offers, asked for rather than
        #: held: a project that renames a level renames its option.
        self._levels = levels
        self._open_level = open_level
        self._history: History[Entrances] = History(self._read())
        #: Whether the project holds saved tables -- what arms Revert when
        #: nothing is in hand. Read at the moments it can change rather than
        #: per edit: it is four stats, and the title follows every keystroke.
        self._saved_any = any(
            project.asm_region_edited(region_id) for region_id in REGION_IDS
        )
        # The window opens filtered: the cartridge writes a few dozen of the
        # 512 rows, and the rest are blank. Switched before the handler is
        # connected, so the `_show` below is the only pass over the rows.
        self.set_toggle(ONLY_USED, True)
        self.edited.connect(self._cell_edited)
        self.acted.connect(self._acted)
        self.switched.connect(self._toggled)
        QShortcut(QKeySequence.StandardKey.Save, self, self._save_if_lit)
        QShortcut(QKeySequence.StandardKey.Close, self, self.close)
        QShortcut(QKeySequence.StandardKey.Undo, self, self.undo)
        QShortcut(QKeySequence.StandardKey.Redo, self, self.redo)
        self.set_action_enabled(SAVE, False)
        self._show()

    # -- what it holds ------------------------------------------------------

    @property
    def document(self) -> Entrances:
        """The tables as they now stand."""
        return self._history.level

    @property
    def unsaved(self) -> bool:
        """Whether anything has been edited since the last save."""
        return self._history.edited

    def records(self) -> list[SecondaryEntrance]:
        """The records on show, in number order -- every entrance, or the
        ones the filter left.

        Not ``rows``, which the base class keeps for the table's model."""
        return entrance_rows(self.document, self._levels(), self._shown)

    def _read(self) -> Entrances:
        """The project's tables, as the build would read them."""
        return Entrances.read(
            {
                region_id: self._project.asm_rows(region_id)[0]
                for region_id in REGION_IDS
            }
        )

    def _show(self) -> None:
        """Pick the rows the table holds and put them up, with the state of
        the window's buttons."""
        self._refill()
        self.show_rows(entrance_columns, self.records())
        self._sync_buttons()
        self.changed.emit()

    def _refill(self) -> None:
        """Decide which entrances the table holds, and say so above it.

        **Only here**, which is the filter being switched and the tables
        being read -- never on an edit. A row edited to blank would otherwise
        be taken out from under the hand that blanked it, and the number
        column would renumber itself mid-keystroke; the filter is a question
        asked when it is asked, and asking it again is one click.
        """
        used = used_entrances(self.document)
        filtered = self.toggle_checked(ONLY_USED)
        self._shown[:] = used if filtered else range(COUNT)
        self.set_heading(
            SHOWING.format(shown=len(used), total=COUNT) if filtered else ""
        )

    def _toggled(self, key: str, _checked: bool) -> None:
        if key == ONLY_USED:
            self._show()

    def _settle(self) -> None:
        """Follow an edit: the rows keep their controls, the buttons follow
        the history."""
        self.refresh(self.records())
        self._sync_buttons()
        self.changed.emit()

    def _sync_buttons(self) -> None:
        self.set_action_enabled(SAVE, self.unsaved)
        self.set_action_enabled(REVERT, self._saved_any or self.unsaved)
        mark_unsaved(self, TITLE, self.unsaved)

    # -- the edits ----------------------------------------------------------

    def _cell_edited(self, row: int, key: str, value: int) -> None:
        """One committed cell: the Go to column opens a level, and every
        other column writes its field through the record.

        Through :meth:`~shiny_mushroom.fields.Field.applied`, so a value past
        the end of a field's range is clamped rather than written, and a
        commit of an untouched box is not a step. The rows are shown again
        either way: what was refused has to leave the control it was typed
        into.
        """
        records = self.records()
        if not 0 <= row < len(records):
            return
        record = records[row]
        if key == FOLLOW:
            # The whole row rather than the level it names: where in that
            # level this entrance lands is the other half of following it.
            self._open_level(record)
            return
        found = next((one for one in entrance_columns(record) if one.key == key), None)
        if found is None:
            return
        self._history.commit(found.applied(record, value).document)
        self._settle()

    def undo(self) -> None:
        if self._history.undo():
            self._settle()

    def redo(self) -> None:
        if self._history.redo():
            self._settle()

    def _acted(self, key: str) -> None:
        if key == SAVE:
            self.save()
        elif key == REVERT:
            self.revert()

    # -- the keyboard -------------------------------------------------------

    def _open_editor(self, index) -> None:  # noqa: ANN001 - the base's index
        """A live control on one cell, watched for the keys below."""
        super()._open_editor(index)
        editor = self._view.indexWidget(index)
        if editor is not None:
            editor.installEventFilter(self)

    def eventFilter(self, watched, event) -> bool:  # noqa: N802, ANN001 - Qt override
        """Settle who owns undo while a cell's control has the keyboard.

        A spin box claims Ctrl+Z for its own one-line typing history at the
        ``ShortcutOverride`` offer; declining it on the control's behalf is
        what lets this window's undo run instead -- the tables', which is the
        document a hand here is editing, and never the level's. This window
        carries no menu action of the main window's, so nothing else is
        listening for the key.
        """
        if event.type() == QEvent.Type.ShortcutOverride:
            pressed = QKeySequence(event.keyCombination())
            if any(pressed in QKeySequence.keyBindings(key) for key in UNDO_KEYS):
                event.ignore()
                return True
        return super().eventFilter(watched, event)

    # -- saving -------------------------------------------------------------

    def save(self) -> bool:
        """Write the tables into the project, reporting success."""
        models = self.document.models()
        try:
            changed = {
                region_id: model
                for region_id, model in models.items()
                if model != self._project.asm_region_stock(region_id)
                or self._project.asm_region_edited(region_id)
            }
            runs = asm_runs(self._project, changed) if changed else {}
            self._project.save_asm_regions(models, runs)
        except AsmRegionFull as error:
            # The tables are a fixed count of fixed-width rows, so this is a
            # run somebody else's fragment has grown into rather than
            # anything an edit here did.
            self._warn(
                "The secondary entrances could not be saved: the tables no "
                "longer fit their run of ROM.",
                f"{error.used:,} bytes against {error.room:,}. Nothing was saved.",
            )
            return False
        except HandEditedRegion as error:
            self._warn(
                "The secondary entrances could not be saved over a "
                "hand-edited fragment.",
                str(error),
            )
            return False
        except (BuildError, ProjectError, AsmRegionError, OSError) as error:
            self._warn("The secondary entrances could not be saved.", str(error))
            return False
        self._history.saved()
        self._saved_any = any(
            self._project.asm_region_edited(region_id) for region_id in REGION_IDS
        )
        self._sync_buttons()
        return True

    def _save_if_lit(self) -> None:
        if self.action_enabled(SAVE):
            self.save()

    def revert(self) -> None:
        """Take the project's fragments out and read the disassembly's."""
        if not self._confirm(
            "Revert the secondary entrances?",
            "Every saved edit is taken out of the project, every edit in "
            "hand is lost, and so is the undo history.",
        ):
            return
        try:
            for region_id in REGION_IDS:
                self._project.revert_asm_region(region_id)
            document = self._read()
        except (ProjectError, AsmRegionError, EntrancesError, OSError) as error:
            self._warn(
                "The secondary entrances could not be reverted.",
                str(error),
            )
            return
        self._saved_any = False
        self._history = History(document)
        self._show()

    # -- closing ------------------------------------------------------------

    def _warn(self, message: str, detail: str = "") -> None:
        """The seam the suite replaces: offscreen, a modal never returns.

        The main window's ``_alert`` is the application's failure surface;
        a window that owns a document of its own reports its own failures,
        as the Map16 editor does.
        """
        warn(self, message, detail=detail)

    def _confirm(self, message: str, detail: str = "") -> bool:
        """The seam the suite replaces: offscreen, a modal never returns."""
        return ask(self, message, detail)

    def _ask_to_save(self, message: str, detail: str = "") -> Answer:
        """The same seam for the unsaved-work question."""
        return ask_to_save(self, message, detail)

    def may_close(self) -> bool:
        """Ask about unsaved edits and act on the answer. True to go on --
        what the window asks before the project goes, and what closing
        asks."""
        if not self.unsaved:
            return True
        answer = self._ask_to_save(
            "The secondary entrances have unsaved changes.",
            "Discarding reverts to the last save.",
        )
        if answer is Answer.CANCEL:
            return False
        if answer is Answer.DISCARD:
            self.discard()
            return True
        return self.save()

    def discard(self) -> None:
        """Put the tables back to what the project last held, and forget the
        steps that led away from it."""
        self._history = History(self._history.base)
        self._show()

    def closeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if not self.may_close():
            event.ignore()
            return
        super().closeEvent(event)
