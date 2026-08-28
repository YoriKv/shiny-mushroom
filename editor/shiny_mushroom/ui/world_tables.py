"""The world map's nine table editors, and the map's cross-checks.

Each table is a view of the same world document: a committed cell goes through
the mode's history like any other edit, and every table open at the time
follows on the mode's changed hook. That choreography -- open lazily, keep the
one dialog, re-show its rows, put it away with the cartridge -- is the same for
every one of them, so it lives once in :class:`_Table` and each table says only
what its rows and columns are.

Three of them -- the event rows, the silent slots and the substitution rows --
show either one event's rows or every event's by the toolbar's focus; the
all-events view leads with an Event column. A column set can only be swapped
by re-showing the rows, so those tables (:attr:`_Table.follows_focus`) track
which view they are on and re-show when it changes.

Six of them grow. The event rows, the silent slots, the substitution pairs,
the warps, the path exits and -- on a cartridge whose build binds its scan to
the table -- the destroyed tiles add through a footer action and delete
through a column, and each add is priced against the cartridge's room by the
mode before it lands -- the tables only ask; what fits is the mode's to say,
and the window's to price.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from PySide6.QtWidgets import QWidget

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld import (
    MapShape,
    world_checks,
)
from shiny_mushroom.overworld_fields import (
    DESTROY_ROW_DELETE,
    EVENT_ROW_DELETE,
    EVENT_ROW_EVENT,
    EXIT_ROW_DELETE,
    SILENT_ROW_DELETE,
    SWAP_ROW_DELETE,
    WARP_ROW_DELETE,
    ExitEntry,
    WarpEntry,
    all_event_placement_rows,
    all_event_row_fields,
    all_silent_row_fields,
    all_subs_row_fields,
    destroy_row_fields,
    destroy_rows,
    event_placement_rows,
    event_row_fields,
    exit_trigger_fields,
    exit_trigger_rows,
    level_row_fields,
    level_rows,
    ruin_row_fields,
    ruin_rows,
    silent_row_fields,
    silent_rows,
    subs_row_fields,
    subs_rows,
    swap_row_fields,
    swap_rows,
    warp_trigger_fields,
    warp_trigger_rows,
)
from shiny_mushroom.ui.dialogs import inform, warn
from shiny_mushroom.ui.table_editor import TableEditorDialog

if TYPE_CHECKING:
    from collections.abc import Callable

    from shiny_mushroom.ui.overworld_mode import OverworldMode, Refusal

#: The footer actions of the tables whose rows add -- dialog-level keys, not
#: a field's, so they live with the dialogs' owner rather than in the field
#: module. The deletes are columns, and so are the field module's.
EVENT_ROW_ADD = "event-row-add"
SILENT_ROW_ADD = "silent-row-add"
SWAP_ROW_ADD = "swap-row-add"
DESTROY_ROW_ADD = "destroy-row-add"
WARP_ROW_ADD = "warp-row-add"
EXIT_ROW_ADD = "exit-row-add"


class _Table:
    """One table editor over the world document.

    Subclasses say what the rows and the columns are. Everything else -- the
    single kept dialog, the guard that nothing opens without a map, the
    re-show that swaps a column set -- is the same for every table.
    """

    #: The dialog's title and the note above its rows.
    title: str
    note: str
    #: Footer buttons, whether rows can be dragged into a new order, and
    #: whether a row can be selected by its index column.
    actions: tuple[tuple[str, str], ...] = ()
    reorderable: bool = False
    selectable: bool = False
    #: Whether the table shows one event's rows or every event's by the
    #: toolbar's focus -- the two views carry different columns, so a focus
    #: change crossing the line re-shows the rows rather than refreshing them.
    follows_focus: bool = False

    def __init__(self, tables: WorldTables) -> None:
        self._tables = tables
        self.dialog: TableEditorDialog | None = None
        #: Which view the shown columns are of, for the tables that have two.
        #: Only meaningful where :meth:`heading` answers.
        self._all_view = False

    @property
    def _world(self) -> OverworldMode:
        return self._tables.world

    # -- what this table is, per subclass ------------------------------------

    def offered(self) -> bool:
        """Whether the document carries anything for this table to show."""
        return True

    def records(self) -> list:
        """The rows, over the document as it stands."""
        raise NotImplementedError

    def fields(self):  # noqa: ANN201 - a fields mapping, shaped per table
        """The columns for the view the table is on."""
        raise NotImplementedError

    def heading(self) -> str | None:
        """What the rows are of, or ``None`` for a table with none to say."""
        return None

    def all_view(self) -> bool:
        """Whether the table is showing every event's rows rather than one's
        -- meaningful where :attr:`follows_focus`."""
        return self._world.focus_event is None

    def commit(self, row: int, key: str, value: int) -> None:
        """Apply a committed cell through the mode."""
        if not self._world.ready:
            return
        records = self.records()
        if not 0 <= row < len(records):
            return
        self._world.commit_table_field(records[row], self.fields(), key, value)

    def wire(self, dialog: TableEditorDialog) -> None:
        """Connect whatever this table offers beyond editing a cell."""

    def _refused(self, refusal: Refusal | None) -> None:
        """A footer add the mode refused: say why where the click was, and
        what would help -- the status line has it too, but a button that
        does nothing is a question, and this is the answer."""
        if refusal is not None and self.dialog is not None:
            warn(self.dialog, refusal.headline, detail=refusal.remedy)

    # -- the choreography, once ----------------------------------------------

    def open(self) -> None:
        """Show the table, or bring the one already up forward."""
        if not self._world.ready or not self.offered():
            return
        if self.dialog is None:
            self.dialog = TableEditorDialog(
                self.title,
                note=self.note,
                actions=self.actions,
                reorderable=self.reorderable,
                selectable=self.selectable,
                parent=self._tables.parent,
            )
            self.dialog.edited.connect(self.commit)
            self.wire(self.dialog)
            self._tables.adopt(self.dialog)
        self._all_view = self.all_view()
        self._show_heading()
        self.dialog.show_rows(self.fields(), self.records())
        self.dialog.show()
        self.dialog.raise_()
        self.dialog.activateWindow()

    def refresh(self) -> None:
        """Follow the document: every commit, undo and destination pick lands
        in these rows too. A focus change swaps the whole row set -- and,
        crossing the all-events boundary, the column set, which only
        :meth:`TableEditorDialog.show_rows` can."""
        if self.dialog is None or not self._world.ready:
            return
        self._show_heading()
        if self.follows_focus and self.all_view() != self._all_view:
            self._all_view = self.all_view()
            self.dialog.show_rows(self.fields(), self.records())
            return
        self.dialog.refresh(self.records())

    def close(self) -> None:
        """Put the table away with the mode or the cartridge."""
        if self.dialog is not None:
            self.dialog.close()

    def _show_heading(self) -> None:
        heading = self.heading()
        if heading is not None and self.dialog is not None:
            self.dialog.set_heading(heading)


class _WarpTable(_Table):
    title = "Overworld Warp Triggers"
    note = (
        "Where each star and pipe warp triggers. The map column is the game's "
        "own byte: overlapping submap viewports mean it cannot be read off "
        "the cell. The search walks the tables from the last entry down, so "
        "entries add and delete. Clicking a row's index selects its trigger "
        "cell on the map."
    )
    selectable = True
    actions = ((WARP_ROW_ADD, "Add entry"),)

    def records(self) -> list:
        return warp_trigger_rows(self._world.document)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return warp_trigger_fields

    def heading(self) -> str | None:
        entries = self._world.document.shape.warps
        return f"{entries} warp{'' if entries == 1 else 's'}, the last tried first"

    def commit(self, row: int, key: str, value: int) -> None:
        """Keyed by row rather than by record: a row is an entry. The delete
        column renumbers the entries after it, so the mode commits it itself
        and keeps a canvas selection and the Warps/Exits tab honest."""
        if not self._world.ready:
            return
        if key == WARP_ROW_DELETE:
            self._world.delete_warp_row(row)
            return
        record = WarpEntry(self._world.document, row)
        self._world.commit_table_field(record, warp_trigger_fields, key, value)

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.selected.connect(self._selected)
        dialog.acted.connect(self._acted)

    def _acted(self, key: str) -> None:
        """The footer: append a copy of the last entry."""
        if key == WARP_ROW_ADD and self._world.ready:
            self._refused(self._world.add_warp_row())

    def _selected(self, row: object) -> None:
        """A selected row shows its trigger on the map: the cell wears the
        ants and the view centres on it. The selection going down leaves the
        map where it is -- it goes down with any click elsewhere, and taking
        the canvas selection with it would fight the click that took it."""
        if row is None or not self._world.ready:
            return
        assert isinstance(row, int)
        self._world.show_warp_trigger(row)


class _ExitTable(_Table):
    title = "Overworld Path Exits"
    note = (
        "Where each path exit triggers -- the cell a walking player is "
        "carried from -- its map, and where it lands. The game matches the "
        "player's exact pixel, so an entry keeps its own sub-cell offsets and "
        "a new one copies the last's; Set destination on the trigger cell's "
        "panel retargets the landing. The search walks the tables from the "
        "last entry down, so entries add and delete. Clicking a row's index "
        "selects its trigger cell on the map."
    )
    selectable = True
    actions = ((EXIT_ROW_ADD, "Add entry"),)

    def offered(self) -> bool:
        return bool(self._world.document.exits)

    def records(self) -> list:
        return exit_trigger_rows(self._world.document)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return exit_trigger_fields

    def heading(self) -> str | None:
        entries = self._world.document.shape.exits
        return f"{entries} path exit{'' if entries == 1 else 's'}, the last tried first"

    def commit(self, row: int, key: str, value: int) -> None:
        """Keyed by row, as the warp table is, and the delete the mode's."""
        if not self._world.ready:
            return
        if key == EXIT_ROW_DELETE:
            self._world.delete_exit_row(row)
            return
        record = ExitEntry(self._world.document, row)
        self._world.commit_table_field(record, exit_trigger_fields, key, value)

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.selected.connect(self._selected)
        dialog.acted.connect(self._acted)

    def _selected(self, row: object) -> None:
        """A selected row shows its trigger cell on the map, on
        :class:`_WarpTable`'s terms."""
        if row is None or not self._world.ready:
            return
        assert isinstance(row, int)
        self._world.show_exit_trigger(row)

    def _acted(self, key: str) -> None:
        if key == EXIT_ROW_ADD and self._world.ready:
            self._refused(self._world.add_exit_row())


class _LevelTable(_Table):
    title = "Overworld Level Table"
    note = (
        "Every numbered level's walk directions and event, one row each in "
        "the scan's own order. Rows are keyed by cell, so renumbering the "
        "levels re-derives every row rather than shifting the table."
    )

    def offered(self) -> bool:
        return bool(self._world.document.directions)

    def records(self) -> list:
        """The rows with the events the panel would quote -- the document's
        table where carried, the capture's otherwise."""
        events = self._world.document.level_events
        if not events and self._world.snapshot is not None:
            events = self._world.snapshot.level_events
        return level_rows(self._world.document, events, self._world.levels)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return level_row_fields


class _EventTable(_Table):
    title = "Overworld Event Rows"
    note = (
        "The entry-table rows in reveal order -- that order is the animation, "
        "and dragging a row's handle moves it. With an event focused, "
        "clicking a handle previews the animation stopped after that row; "
        "clicking again shows the event whole. The toolbar's Event box picks "
        "whose rows are shown."
    )
    actions = ((EVENT_ROW_ADD, "Add row"),)
    reorderable = True
    selectable = True
    follows_focus = True

    def offered(self) -> bool:
        return bool(self._world.document.events)

    def records(self) -> list:
        """The focused event's placements, or -- with no event focused --
        every event's, for the all-events view."""
        if not self._world.document.events:
            return []
        event = self._world.focus_event
        if event is None:
            return all_event_placement_rows(self._world.document)
        return event_placement_rows(self._world.document, event)

    def fields(self):  # noqa: ANN201 - a fields mapping
        if self._world.focus_event is None:
            return all_event_row_fields
        return event_row_fields

    def heading(self) -> str:
        if not self._world.document.events:
            return "This map carries no event placements."
        meter = self._world.stamp_meter()
        event = self._world.focus_event
        if event is None:
            return (
                f"All events -- {meter}. Focus one in the toolbar's Event box "
                f"to work on its rows alone."
            )
        rows = len(self._world.document.events[event])
        return f"Event {hexnum(event)} -- {rows} row{'' if rows == 1 else 's'}; {meter}"

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.acted.connect(self._acted)
        dialog.reordered.connect(self._reordered)
        dialog.selected.connect(self._selected)

    def refresh(self) -> None:
        """The mode owns the step preview, so a refresh that finds it down
        -- a focus change or the events view going away put it down -- takes
        the row selection with it, and the highlight never outlives the
        preview it raised."""
        if (
            self.dialog is not None
            and self._world.ready
            and self._world.preview_step is None
        ):
            self.dialog.select_row(None)
        super().refresh()

    def _selected(self, row: object) -> None:
        """A selected row previews the animation stopped after it; the
        selection going down -- a click off the table included -- shows the
        event whole again. The preview reads one focused event's animation,
        so the all-events view refuses with a pointer at the Event box."""
        if not self._world.ready:
            return
        if row is None:
            self._world.preview_event_step(None)
            return
        if self._world.focus_event is None:
            if self.dialog is not None:
                self.dialog.select_row(None)
            self._tables.status(
                "Focus an event in the toolbar's Event box to preview its animation",
                5000,
            )
            return
        records = self.records()
        if 0 <= row < len(records):
            self._world.preview_event_step(records[row].entry)

    def commit(self, row: int, key: str, value: int) -> None:
        """The delete column renumbers the rows the records were built over,
        and the Event column moves one to another event's end, so the mode
        commits both itself and keeps the canvas selection honest;
        everything else takes the generic field path. The record carries its
        own event, so both views dispatch the same way."""
        if not self._world.ready:
            return
        records = self.records()
        if not 0 <= row < len(records):
            return
        record = records[row]
        if key == EVENT_ROW_DELETE:
            self._world.delete_event_row(record.event, record.entry)
            return
        if key == EVENT_ROW_EVENT:
            self._world.rehome_event_row(record.event, record.entry, value)
            return
        self._world.commit_table_field(record, self.fields(), key, value)

    def _reordered(self, row: int, to: int) -> None:
        """A row handle dragged to a new place: reveal order is the table's row
        order, so the drag is the reorder. Through the mode, which renumbers
        the canvas selection with the rows. In the all-events view a drag stays
        within its event -- the Event column is what moves a row between
        events."""
        if not self._world.ready:
            return
        records = self.records()
        if not (0 <= row < len(records) and 0 <= to < len(records)):
            return
        grabbed, landing = records[row], records[to]
        if grabbed.event != landing.event:
            self._tables.status(
                "A drag reorders within its event -- the Event column moves a "
                "row to another one",
                5000,
            )
            return
        self._world.reorder_event_row(grabbed.event, grabbed.entry, landing.entry)

    def _acted(self, key: str) -> None:
        """The footer: add a row to the focused event."""
        if key != EVENT_ROW_ADD or not self._world.ready:
            return
        event = self._world.focus_event
        if event is None:
            self._tables.status("Focus an event in the toolbar's Event box first", 0)
            return
        self._refused(self._world.add_event_row(event))


class _SilentTable(_Table):
    title = "Overworld Silent Tiles"
    note = (
        "The tiles a flagged event places offscreen with no animation. The "
        "game scans the block whole, so a slot added here is scanned up to "
        "the $80 its scan reaches, and a deleted one closes the rest up. The "
        "toolbar's Event box picks whose slots are shown."
    )
    actions = ((SILENT_ROW_ADD, "Add slot"),)
    follows_focus = True

    def offered(self) -> bool:
        return bool(self._world.document.silent)

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.acted.connect(self._acted)

    def _acted(self, key: str) -> None:
        """The footer: append a slot, parked on the focused event."""
        if key == SILENT_ROW_ADD and self._world.ready:
            self._refused(self._world.add_silent_row())

    def commit(self, row: int, key: str, value: int) -> None:
        """The delete column renumbers the slots the records were built over,
        so the mode commits it itself and keeps a canvas selection honest;
        everything else takes the generic field path."""
        if not self._world.ready:
            return
        records = self.records()
        if not 0 <= row < len(records):
            return
        if key == SILENT_ROW_DELETE:
            self._world.delete_silent_row(records[row].slot)
            return
        self._world.commit_table_field(records[row], self.fields(), key, value)

    def records(self) -> list:
        """The focused event's slots, or all $2C."""
        if not self._world.document.silent:
            return []
        return silent_rows(self._world.document, self._world.focus_event)

    def fields(self):  # noqa: ANN201 - a fields mapping
        if self._world.focus_event is None:
            return all_silent_row_fields
        return silent_row_fields

    def heading(self) -> str:
        if not self._world.document.silent:
            return "This map carries no silent-tiles block."
        slots = self._world.document.shape.silent
        event = self._world.focus_event
        if event is None:
            return (
                f"All events -- every slot of the block, {slots} of them. "
                f"Focus one in the toolbar's Event box to see its slots alone."
            )
        count = len(self.records())
        return (
            f"Event {hexnum(event)} -- {count} silent slot{'' if count == 1 else 's'} "
            f"of the block's {slots}"
        )


class _DestroyTable(_Table):
    title = "Overworld Destroyed Tiles"
    note = (
        "Which event crushes the castle, fortress or switch palace at which "
        "cell, at every overworld load. The scan walks the event numbers from "
        "the top down, so where two slots name one event the higher-numbered "
        "one wins. A stock cartridge scans a fixed 24 slots -- eight past the "
        "table's 16 -- so a slot is retargeted, not added or removed; with "
        "the overworld tables relocated, slots add and delete. What a cell "
        "turns into comes from the Ruin Tiles table. Clicking a row's index "
        "selects its cell on the map."
    )
    selectable = True
    actions = ((DESTROY_ROW_ADD, "Add slot"),)

    def offered(self) -> bool:
        return bool(self._world.document.destroy)

    def records(self) -> list:
        if not self._world.document.destroy:
            return []
        return destroy_rows(self._world.document)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return destroy_row_fields

    def heading(self) -> str | None:
        if not self._world.document.destroy:
            return "This map carries no destroyed-tiles block."
        slots = self._world.document.shape.destroy
        return f"{slots} slot{'' if slots == 1 else 's'}, the last tried first"

    def commit(self, row: int, key: str, value: int) -> None:
        """The delete column renumbers the slots after it, so the mode commits
        it itself -- and refuses it where this cartridge's scan does not
        follow the rows."""
        if not self._world.ready:
            return
        records = self.records()
        if not 0 <= row < len(records):
            return
        if key == DESTROY_ROW_DELETE:
            self._refused(self._world.delete_destroy_row(records[row].slot))
            return
        self._world.commit_table_field(records[row], self.fields(), key, value)

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.selected.connect(self._selected)
        dialog.acted.connect(self._acted)

    def _acted(self, key: str) -> None:
        if key == DESTROY_ROW_ADD and self._world.ready:
            self._refused(self._world.add_destroy_row())

    def _selected(self, row: object) -> None:
        """A selected row shows the cell it crushes, on :class:`_WarpTable`'s
        terms: the selection going down leaves the map where it is."""
        if row is None or not self._world.ready:
            return
        assert isinstance(row, int)
        records = self.records()
        if 0 <= row < len(records):
            record = records[row]
            self._world.show_cell(record.document.destroy_entry(record.slot)[1])


class _RuinTable(_Table):
    title = "Overworld Ruin Tiles"
    note = (
        "What a crushed tile looks like: the Map16 tile a destroy slot has to "
        "find, and the pair it writes. One row per ruin kind, so an edit here "
        "changes every ruin of that kind at once. Which kinds are two cells "
        "tall is the routine's, not the table's."
    )

    def offered(self) -> bool:
        return bool(self._world.document.destroy)

    def records(self) -> list:
        if not self._world.document.destroy:
            return []
        return ruin_rows(self._world.document)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return ruin_row_fields


class _SubsTable(_Table):
    title = "Overworld Tile Substitutions"
    note = (
        "Where each event's pass-1 tile substitution aims: one cell per "
        "event, swapped at every overworld load once the event has run. What "
        "appears there is what the Substitution Pairs table maps the cell's "
        "current tile onto -- a cell matching no pair changes nothing, and "
        "location 0 is idle. The toolbar's Event box picks whose row is "
        "shown. Clicking a row's index selects its cell on the map."
    )
    selectable = True
    follows_focus = True

    def offered(self) -> bool:
        return bool(self._world.document.subs)

    def records(self) -> list:
        if not self._world.document.subs:
            return []
        return subs_rows(self._world.document, self._world.focus_event)

    def fields(self):  # noqa: ANN201 - a fields mapping
        if self._world.focus_event is None:
            return all_subs_row_fields
        return subs_row_fields

    def heading(self) -> str | None:
        if not self._world.document.subs:
            return "This map carries no substitution tables."
        event = self._world.focus_event
        if event is None:
            return (
                "All events -- one substitution row each. Focus one in the "
                "toolbar's Event box to see its row alone."
            )
        return f"Event {hexnum(event)} -- where its tile substitution aims"

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.selected.connect(self._selected)

    def _selected(self, row: object) -> None:
        """A selected row shows the cell it aims at, on :class:`_WarpTable`'s
        terms: the selection going down leaves the map where it is."""
        if row is None or not self._world.ready:
            return
        assert isinstance(row, int)
        records = self.records()
        if 0 <= row < len(records):
            record = records[row]
            self._world.show_cell(record.document.subs_cell(record.event))


class _SwapsTable(_Table):
    title = "Overworld Substitution Pairs"
    note = (
        "What a substituted tile turns into: the Map16 tile a substitution "
        "has to find, and the tile it writes. One row per pair, so an edit "
        "here changes every substitution landing on that tile at once. The "
        "scans walk the table from the last pair down, so an added pair is "
        "tried first and a deleted one closes the rest up. Which place writes "
        "two cells is the routine's, not the table's."
    )
    actions = ((SWAP_ROW_ADD, "Add pair"),)

    def offered(self) -> bool:
        return bool(self._world.document.subs)

    def records(self) -> list:
        if not self._world.document.subs:
            return []
        return swap_rows(self._world.document)

    def fields(self):  # noqa: ANN201 - a fields mapping
        return swap_row_fields

    def heading(self) -> str | None:
        if not self._world.document.subs:
            return "This map carries no substitution tables."
        pairs = self._world.document.shape.swaps
        return f"{pairs} pair{'' if pairs == 1 else 's'}, the last tried first"

    def wire(self, dialog: TableEditorDialog) -> None:
        dialog.acted.connect(self._acted)

    def _acted(self, key: str) -> None:
        """The footer: append an idle pair, to be aimed by editing."""
        if key == SWAP_ROW_ADD and self._world.ready:
            self._refused(self._world.add_swap_row())

    def commit(self, row: int, key: str, value: int) -> None:
        """The delete column renumbers the pairs the records were built over,
        so the mode commits it itself; everything else takes the generic
        field path."""
        if not self._world.ready:
            return
        records = self.records()
        if not 0 <= row < len(records):
            return
        if key == SWAP_ROW_DELETE:
            self._world.delete_swap_row(records[row].pair)
            return
        self._world.commit_table_field(records[row], self.fields(), key, value)


class WorldTables:
    """The nine table editors over the world map, and the map's cross-checks.

    Held by the window for the life of the session; the dialogs themselves are
    built on first open and kept, so reopening one lands where it was left.
    """

    def __init__(
        self,
        world: OverworldMode,
        parent: QWidget,
        adopt: Callable[[QWidget], None],
        status: Callable[[str, int], None],
        shape: Callable[[], MapShape],
    ) -> None:
        self.world = world
        self.parent = parent
        #: Lends the window's shortcuts to a dialog, so the level keys keep
        #: working while a table has focus.
        self.adopt = adopt
        self.status = status
        #: The open cartridge's table shape, asked for rather than held: it is
        #: read off each build, and the checks must use the current one.
        self.shape = shape
        self.warps = _WarpTable(self)
        self.exits = _ExitTable(self)
        self.levels = _LevelTable(self)
        self.events = _EventTable(self)
        self.silent = _SilentTable(self)
        self.destroy = _DestroyTable(self)
        self.ruins = _RuinTable(self)
        self.subs = _SubsTable(self)
        self.swaps = _SwapsTable(self)

    @property
    def _all(self) -> tuple[_Table, ...]:
        return (
            self.warps,
            self.exits,
            self.levels,
            self.events,
            self.silent,
            self.destroy,
            self.ruins,
            self.subs,
            self.swaps,
        )

    def refresh(self) -> None:
        """Follow the document, for whichever tables are open."""
        for table in self._all:
            table.refresh()

    def close(self) -> None:
        """Put every table away with the mode or the cartridge."""
        for table in self._all:
            table.close()

    def check(self) -> None:
        """Run the world map's cross-checks and report the findings.

        On demand rather than live: the checks replay events per level and per
        event, and the answer is a reading of the whole map -- a dialog to work
        through, not a status to glance at.
        """
        if not self.world.ready or self.world.snapshot is None:
            return
        found = world_checks(self.world.document, self.world.snapshot, self.shape())
        if not found:
            inform(
                self.parent,
                "The world map checks out.",
                title="World Map Checks",
                detail="The level count fits the save data and the names "
                "table, every clear walks onto something walkable, event "
                "numbering has no collisions, and no event is orphaned or "
                "empty.",
            )
            return
        inform(
            self.parent,
            f"{len(found)} finding{'' if len(found) == 1 else 's'}:",
            title="World Map Checks",
            detail="\n".join(found),
        )
