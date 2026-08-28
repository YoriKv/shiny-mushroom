"""One level's road from the world map into its data -- the load path.

The Level Load Path window shows a single level's whole chain: the overworld
tile, the translevel the scan hands it, the level number that resolves to,
the files its streams live in, the Layer 2 its pointer names, and the
secondary header that places the player. Most of those facts already have
owners -- the world document, the project, the level document -- so this
module holds only what the window needs on top: the resolution between a
level number and its cell, and the level-side records the window renders as
field rows.

The cell and translevel halves are :class:`~shiny_mushroom.overworld_fields.CellWalk`
rows -- the same record the cell panel and the overworld level table edit, so
the window cannot describe a level differently than they do. What is here is
the *level* half, which no world record carries.

No Qt: records in, fields out, exactly as :mod:`shiny_mushroom.objects` does
for its streams.
"""

from __future__ import annotations

from dataclasses import dataclass, replace

from shiny_mushroom.fields import Action, Field, choices, readout
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld import (
    PAGE_ROWS,
    cell_at,
    level_number,
    scan_translevels,
)

#: The field keys the window's owner dispatches on rather than applying to a
#: record: each asks for a change of place or a dialog, not a value.
SHOW_ON_MAP = "show-on-map"
OPEN_LEVEL = "open-level"
EDIT_HEADER = "edit-header"
#: And the one owner-dispatched *value*: a Layer 2 repoint, which is a
#: project write and a level reload rather than a document edit.
LAYER2_ENTRY = "layer2-entry"


def cell_for_level(level: int, tiles: bytes, levels: bytes = b"") -> int | None:
    """The tilemap cell whose translevel loads ``level``, or ``None``.

    Derived exactly the way the game derives the forward direction: the scan
    hands out translevels, and each cell's page decides the submap bit -- or,
    on a cartridge carrying the translevel-remap table, the row ``levels``
    holds for it. A sublevel -- reachable only through screen exits and
    secondary entrances -- has no cell, and that ``None`` is the window's cue
    to say so.
    """
    translevels = scan_translevels(tiles)
    for index, translevel in enumerate(translevels):
        if (
            translevel
            and level_number(translevel, cell_at(index)[1] >= PAGE_ROWS, levels)
            == level
        ):
            return index
    return None


def cell_level(index: int, tiles: bytes, levels: bytes = b"") -> int | None:
    """The level the tile at ``index`` loads, or ``None`` for no level --
    ``levels`` on :func:`cell_for_level`'s terms."""
    translevel = scan_translevels(tiles)[index]
    if not translevel:
        return None
    return level_number(translevel, cell_at(index)[1] >= PAGE_ROWS, levels)


@dataclass(frozen=True)
class LevelInfo:
    """The level half of the path, as the window's owner assembled it.

    Everything here is a *reading* -- of the project's tree, the pointer
    table, the header -- so the rows are readouts and actions, except the
    Layer 2 pick, which the owner commits as a repoint. ``None`` for a fact
    the session cannot answer (no project open, say) drops the row rather
    than showing an empty one.
    """

    level: int
    #: Whether this level is the one open on the canvas -- which decides
    #: between offering its dialogs and offering to open it.
    current: bool = False
    #: The container file(s) the level's streams live in, as displayable
    #: names -- ``levels/105.mwl``, with the split levels naming two.
    files: str | None = None
    #: The other level numbers whose pointer entries read the same
    #: container(s), formatted for the row; empty string for none.
    shared: str | None = None
    #: What the Layer 2 pointer names, as the pick list the project offers
    #: and which entry this level holds. ``options`` empty means the fact is
    #: shown as text (``layer2``) rather than offered.
    layer2: str | None = None
    layer2_options: tuple[str, ...] = ()
    layer2_current: int = -1
    #: Who else reads the same Layer 2 stream, formatted; empty for nobody.
    layer2_shared: str | None = None
    #: The primary header, described in one line.
    header: str | None = None


def level_info_fields(record: LevelInfo) -> list[Field]:
    """The level section's rows, top to bottom."""
    rows = [
        readout(
            "Level",
            lambda r: hexnum(r.level, 3),
            hint="The number the translevel resolves to.",
        ),
    ]
    if not record.current:
        rows.append(
            Field(
                key=OPEN_LEVEL,
                label="",
                kind=Action("Open this level"),
                hint="Open the level on the canvas.",
            )
        )
    if record.files is not None:
        rows.append(
            readout(
                "Data files",
                lambda r: r.files,
                hint="The .mwl container(s) the level's streams live in.",
            )
        )
    if record.shared:
        rows.append(
            readout(
                "Shared with",
                lambda r: r.shared,
                hint="Other level numbers reading the same container; saving "
                "changes them too.",
            )
        )
    if record.layer2_options:
        rows.append(
            Field(
                key=LAYER2_ENTRY,
                label="Layer 2",
                kind=choices(tuple(enumerate(record.layer2_options))),
                read=lambda r: r.layer2_current,
                write=lambda r, value: replace(r, layer2_current=value),
                hint="What the level's Layer 2 pointer names. A repoint saves "
                "at once and reloads the level.",
            )
        )
    elif record.layer2 is not None:
        rows.append(
            readout(
                "Layer 2",
                lambda r: r.layer2,
                hint="What the level's Layer 2 pointer names.",
            )
        )
    if record.layer2_shared:
        rows.append(
            readout(
                "Layer 2 shared",
                lambda r: r.layer2_shared,
                hint="Other levels pointing at the same Layer 2; an edit "
                "changes all of them.",
            )
        )
    if record.header is not None:
        rows.append(
            readout(
                "Header",
                lambda r: r.header,
                hint="The five primary header bytes.",
            )
        )
    if record.current:
        rows.append(
            Field(
                key=EDIT_HEADER,
                label="",
                kind=Action("Level header..."),
                hint="The whole-level settings: mode, music, tilesets and palettes.",
            )
        )
    return rows


def frozen_fields(rows: list[Field]) -> list[Field]:
    """``rows`` with every write stripped -- how a section is shown where
    its owner is not in reach: the world rows while the level editor is up,
    the entrance rows while it is not. The actions stay actions."""
    return [row if row.write is None else replace(row, write=None) for row in rows]
