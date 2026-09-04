"""The asm tables a project may edit, and the fragments that carry them.

Levels and graphics reach the build as *files*, so a project overlays them by
shadowing a path. A data table inside a bank is not a file -- until it is: each
region here is a table (or a group of tables one routine owns) split out of its
bank macro into a fragment under ``overworld/tables/``, ``incsrc``'d from the
exact spot the lines came from. The overlay then shadows the fragment like any
other file, and the build needs no new mechanism at all.

This module is the registry that says which fragments exist and what is in
them, and the codec that joins their three forms:

``model``
    Plain tuples an editor holds -- the rows of the table.
``bytes``
    Per-section ROM images, for pricing a save and for patching a preview
    cartridge. Derived tables (the event pointer table) are computed here, so
    they cannot desync from the data they index.
``asm``
    The fragment text. :meth:`AsmRegion.emit` writes one small grammar --
    labels, ``db``/``dw`` rows, the ``base $000000`` sublabel idiom -- and
    :meth:`AsmRegion.parse` reads only that grammar. The shipped fragments
    happen to be inside it too, which is what lets a parse of the checkout be
    cross-checked against the cartridge; anything outside it is refused by
    name and line rather than guessed at.

**Three modules under this one.** :mod:`smw_tools.asm_codec` holds
:class:`~smw_tools.asm_codec.AsmRegion` itself -- the interface and the small
grammar every region shares. :mod:`smw_tools.asm_strings` holds the two regions
whose model is the game's text rather than tuples of numbers.
:mod:`smw_tools.asm_room` measures how much ROM a fragment has to grow into,
off the build's own symbol file. This module is the registry: which fragments
exist, what is in them, and the tables whose rows are numbers.
"""

from __future__ import annotations

from dataclasses import dataclass, replace
from pathlib import Path
from typing import TYPE_CHECKING

from .asm_codec import (
    AsmRegion,
    AsmRegionError,
    _comment_stripped,
    _rows,
    _values,
)
from .asm_strings import (
    FONT_HEADER,
    MESSAGE_LABELS,
    MESSAGE_LINES,
    MESSAGE_WIDTH,
    NAME_LABELS,
    STRINGS_DIR,
    MessageTables,
    TerminatedStrings,
)
from .symbols import SymbolTable

if TYPE_CHECKING:
    from .bases import RomBase


#: Where every table fragment lives, under the base's game folder.
TABLES_DIR = Path("overworld/tables")


@dataclass(frozen=True)
class FixedTables(AsmRegion):
    """Labelled ``db``/``dw`` tables whose entry counts are the format.

    The counts are indexed by things that cannot renumber -- translevels,
    events, warp entries -- so a save neither grows nor shrinks one: the
    count *is* the check, and no padding is ever needed.

    **Unless the scan follows the rows.** A table whose reader takes its bound
    as an assembler expression over the fragment's own labels -- the silent
    tiles, the Layer 1 swap pairs, the warps -- is scanned whole however many
    rows it has, so a save may add and delete rows: :attr:`growable`, and on
    the base in hand :attr:`grows`. Then :attr:`counts` is the *stock*
    cartridge's shape, what an unedited one holds and what a caller with no
    build to ask reads, and the codec accepts any count from one to
    :attr:`capacity` for the :attr:`scanned` sections, every one of them the
    same length -- one loop indexes them all. What a cartridge *currently*
    holds is measured off its build's symbol file, :func:`measured_counts`.
    """

    #: Bytes per value, one per section: 1 emits ``db``, 2 emits ``dw``.
    widths: tuple[int, ...] = ()
    #: One entry count per section.
    counts: tuple[int, ...] = ()

    def __post_init__(self) -> None:
        if self.growable and len(self.sections) < 2:
            # A count is measured off the distance between two labels, and a
            # fragment of one table has no second label to measure to.
            raise AsmRegionError(
                f"{self.id}: a growable region needs two sections to measure"
            )
        if any(role not in self.sections for role in self.scanned):
            raise AsmRegionError(f"{self.id}: a scanned section is not a section")

    @property
    def strides(self) -> tuple[int, ...]:
        return self.widths

    def entry_counts(self) -> dict[str, int]:
        return dict(zip(self.sections, self.counts, strict=True))

    def _with_counts(self, counts: dict[str, int]) -> FixedTables:
        return replace(self, counts=tuple(counts[role] for role in self.sections))

    def decode(self, images: dict[str, bytes]) -> tuple[tuple[int, ...], ...]:
        out = []
        for role, width, count in zip(
            self.sections, self.widths, self.counts, strict=True
        ):
            image = images[role][: count * width]
            if len(image) != count * width:
                raise AsmRegionError(
                    f"{self.id} ({role}): {count * width:#x} bytes expected, "
                    f"got {len(image):#x}"
                )
            out.append(
                tuple(
                    int.from_bytes(image[i : i + width], "little")
                    for i in range(0, len(image), width)
                )
            )
        return tuple(out)

    def _check(self, model: tuple[tuple[int, ...], ...]) -> None:
        if len(model) != len(self.sections):
            raise AsmRegionError(
                f"{self.id} has {len(self.sections)} sections, got {len(model)}"
            )
        grown = set(self.scanned_sections) if self.grows else set()
        if grown:
            held = {
                len(values)
                for role, values in zip(self.sections, model, strict=True)
                if role in grown
            }
            if len(held) != 1:
                raise AsmRegionError(
                    f"{self.id}: every scanned section holds the same number of "
                    f"entries, got {sorted(held)}"
                )
            (entries,) = held
            if not self.allows(entries):
                raise AsmRegionError(
                    f"{self.id} holds 1 to {self.capacity} entries, got {entries}"
                    if self.capacity is not None
                    else f"{self.id} holds at least one entry, got {entries}"
                )
        for role, width, count, values in zip(
            self.sections, self.widths, self.counts, model, strict=True
        ):
            if role not in grown and len(values) != count:
                raise AsmRegionError(
                    f"{self.id} ({role}) holds {count} entries, got {len(values)}"
                )
            limit = 1 << (width * 8)
            if any(not 0 <= v < limit for v in values):
                raise AsmRegionError(f"{self.id} ({role}): a value is out of range")

    def used(self, model: tuple[tuple[int, ...], ...]) -> dict[str, int]:
        """The model's own rows, priced -- so a grown table is priced at
        what it holds, not at the count the region was resolved with."""
        self._check(model)
        return {
            role: len(values) * width
            for role, values, width in zip(
                self.sections, model, self.widths, strict=True
            )
        }

    def encode(
        self, model: tuple[tuple[int, ...], ...], room: int | None = None
    ) -> dict[str, bytes]:
        self.fits(model, room)
        return {
            role: b"".join(v.to_bytes(width, "little") for v in values)
            for role, width, values in zip(
                self.sections, self.widths, model, strict=True
            )
        }

    def emit(
        self,
        model: tuple[tuple[int, ...], ...],
        room: int | None,
        base: RomBase,
    ) -> str:
        self.fits(model, room)
        lines = [f"; {self.id} -- written by the editor; rows are the table."]
        for role, width, values in zip(self.sections, self.widths, model, strict=True):
            lines += ["", self.label(base, role) + ":"]
            lines += _rows(list(values), "db" if width == 1 else "dw", 8, width)
        return "\n".join(lines) + "\n"

    def parse(self, text: str, base: RomBase) -> tuple[tuple[int, ...], ...]:
        found: list[list[int]] = [[] for _ in self.sections]
        name = str(self.path)
        for current, line, number in self._data_rows(text, base):
            directive = "db" if self.widths[current] == 1 else "dw"
            if not line.startswith(directive + " "):
                raise AsmRegionError(f"{name}:{number}: {line!r} is off-grammar")
            found[current] += _values(line[len(directive) :], name, number)
        model = tuple(tuple(values) for values in found)
        self._check(model)
        return model


@dataclass(frozen=True)
class PathExits(AsmRegion):
    """The path-exit tables: trigger and landing positions, and the landing's
    grid pair.

    The model is three tuples of :data:`COUNT` rows each -- the first two
    sections hold ``(pixel Y, pixel X, submap)`` records, five bytes in ROM,
    and the last the landing's ``(grid row, grid column)`` byte pairs. The
    grid pair is data rather than a derivation of the landing pixels: the
    shipped table deviates from ``pixel >> 4`` where a landing sits mid-walk.
    """

    #: How many entries every section holds on a stock cartridge.
    #:
    #: One number for the three tables, because one loop indexes all of them:
    #: a base that grew this table declares the same count for every section,
    #: and :meth:`_with_counts` refuses a set that disagrees rather than
    #: picking one and writing three tables the game reads past. The search
    #: takes its bound from the fragment's own labels, so the table is
    #: :attr:`growable` and a saved fragment may hold another count.
    COUNT: int = 14

    @property
    def strides(self) -> tuple[int, ...]:
        # Five bytes a position row -- two words and the submap byte -- and
        # two for the landing's grid pair.
        return (5, 5, 2)

    def entry_counts(self) -> dict[str, int]:
        return {role: self.COUNT for role in self.sections}

    def _with_counts(self, counts: dict[str, int]) -> PathExits:
        wanted = {counts[role] for role in self.sections}
        if len(wanted) != 1:
            listed = ", ".join(f"{role} {counts[role]}" for role in self.sections)
            raise AsmRegionError(
                f"{self.id}'s tables are scanned by one bound, so they cannot "
                f"hold different numbers of entries: {listed}"
            )
        return replace(self, COUNT=wanted.pop())

    def _positions(self) -> tuple[str, ...]:
        return self.sections[:-1]

    def decode(self, images: dict[str, bytes]):  # noqa: ANN201 - mixed row shapes
        out: list[tuple[tuple[int, ...], ...]] = []
        for role in self._positions():
            image = images[role][: self.COUNT * 5]
            if len(image) != self.COUNT * 5:
                raise AsmRegionError(f"{self.id} ({role}): a short image")
            out.append(
                tuple(
                    (
                        int.from_bytes(image[i : i + 2], "little"),
                        int.from_bytes(image[i + 2 : i + 4], "little"),
                        image[i + 4],
                    )
                    for i in range(0, len(image), 5)
                )
            )
        cells_role = self.sections[-1]
        image = images[cells_role][: self.COUNT * 2]
        if len(image) != self.COUNT * 2:
            raise AsmRegionError(f"{self.id} ({cells_role}): a short image")
        out.append(tuple((image[i], image[i + 1]) for i in range(0, len(image), 2)))
        return tuple(out)

    def _check(self, model) -> None:  # noqa: ANN001 - the decode's shape
        if len(model) != len(self.sections):
            raise AsmRegionError(f"{self.id}: {len(self.sections)} sections expected")
        held = {len(rows) for rows in model}
        if len(held) != 1:
            raise AsmRegionError(
                f"{self.id}: every section holds the same number of entries, "
                f"got {sorted(held)}"
            )
        (entries,) = held
        if not self.allows(entries):
            raise AsmRegionError(
                f"{self.id} holds 1 to {self.capacity} entries, got {entries}"
                if self.grows
                else f"{self.id} holds {self.COUNT} entries, got {entries}"
            )
        for role, rows in zip(self._positions(), model[:-1], strict=True):
            for y, x, submap in rows:
                if not (0 <= y <= 0xFFFF and 0 <= x <= 0xFFFF and 0 <= submap <= 0xFF):
                    raise AsmRegionError(f"{self.id} ({role}): a value is out of range")
        for row, column in model[-1]:
            if not (0 <= row <= 0xFF and 0 <= column <= 0xFF):
                raise AsmRegionError(
                    f"{self.id} ({self.sections[-1]}): a value is out of range"
                )

    def used(self, model) -> dict[str, int]:  # noqa: ANN001 - the decode's shape
        self._check(model)
        return {
            role: len(rows) * stride
            for role, rows, stride in zip(
                self.sections, model, self.strides, strict=True
            )
        }

    def encode(self, model, room: int | None = None) -> dict[str, bytes]:  # noqa: ANN001
        self.fits(model, room)
        images = {
            role: b"".join(
                y.to_bytes(2, "little") + x.to_bytes(2, "little") + bytes([submap])
                for y, x, submap in rows
            )
            for role, rows in zip(self._positions(), model[:-1], strict=True)
        }
        images[self.sections[-1]] = b"".join(
            bytes([row, column]) for row, column in model[-1]
        )
        return images

    def emit(self, model, room: int | None, base: RomBase) -> str:  # noqa: ANN001
        self.fits(model, room)
        lines = [f"; {self.id} -- written by the editor; rows are the table."]
        for role, rows in zip(self._positions(), model[:-1], strict=True):
            lines += ["", self.label(base, role) + ":"]
            lines += [
                f"\tdw ${y:04X},${x:04X} : db ${submap:02X}" for y, x, submap in rows
            ]
        lines += ["", self.label(base, self.sections[-1]) + ":"]
        lines += [f"\tdb ${row:02X},${column:02X}" for row, column in model[-1]]
        return "\n".join(lines) + "\n"

    def parse(self, text: str, base: RomBase):  # noqa: ANN201 - the decode's shape
        found: list[list[tuple[int, ...]]] = [[] for _ in self.sections]
        name = str(self.path)
        for current, line, number in self._data_rows(text, base):
            if current < len(self.sections) - 1:
                words, sep, tail = line.partition(":")
                tail = tail.strip()
                if not (words.startswith("dw ") and sep and tail.startswith("db ")):
                    raise AsmRegionError(f"{name}:{number}: {line!r} is off-grammar")
                position = _values(words[2:], name, number)
                submap = _values(tail[2:], name, number)
                if len(position) != 2 or len(submap) != 1:
                    raise AsmRegionError(
                        f"{name}:{number}: a position row is two words and a byte"
                    )
                found[current].append((position[0], position[1], submap[0]))
            else:
                if not line.startswith("db "):
                    raise AsmRegionError(f"{name}:{number}: {line!r} is off-grammar")
                pair = _values(line[2:], name, number)
                if len(pair) != 2:
                    raise AsmRegionError(
                        f"{name}:{number}: a landing cell is two bytes"
                    )
                found[current].append((pair[0], pair[1]))
        model = tuple(tuple(rows) for rows in found)
        self._check(model)
        return model


@dataclass(frozen=True)
class EventStamps(AsmRegion):
    """The Layer 2 event data: entries plus the pointer table derived from them.

    The model is one list of ``(sheet, destination)`` word pairs per usable
    event. The pointer table is never part of the model: the encoded image
    computes it from the entries, which is what makes the desync the two tables
    allow at the byte level unwritable here.

    **The pointer table is not in this fragment.** It is a sibling source file,
    ``overworld/layer2-event-pointers.asm``, whose every row names one of the
    entry table's ``base $000000`` sublabels -- so it needs no editing and
    carries no data, and the two can be placed apart. That is what lets the
    entry table have room above it: a section's budget is the distance to the
    next symbol, and while the pointer table sat directly on top of the entries
    there was none. A fragment that still holds a ``Ptrs:`` block was written
    before the split, and is refused rather than assembled into a second
    definition of a label the tree already has.

    The last pointer is a shared end marker rather than an event -- event
    ``$78`` has no end of its own, which upstream marks as a crash -- so
    ``EVENTS`` is one less than ``POINTERS``.
    """

    #: How many pointer-table entries there are.
    POINTERS: int = 0x79
    #: How many events have a start *and* an end. Derived from the above and
    #: kept as a field so both read as plain numbers; :meth:`_with_counts` is
    #: the only thing that moves them, and moves them together.
    EVENTS: int = 0x78

    def entry_counts(self) -> dict[str, int]:
        # The entry table's row count is priced against a budget rather than
        # declared, so only the pointer table has a count to report.
        return {self.pointers_role: self.POINTERS}

    def _with_counts(self, counts: dict[str, int]) -> EventStamps:
        # The event count follows the pointer count rather than being declared
        # beside it: the last pointer is a shared end marker, so the two are
        # one number and a base that could state them apart could state a
        # cartridge that cannot exist.
        pointers = counts[self.pointers_role]
        if pointers < 2:
            raise AsmRegionError(
                f"{self.id} needs a pointer table of at least one event and "
                f"its end marker, got {pointers}"
            )
        return replace(self, POINTERS=pointers, EVENTS=pointers - 1)

    @property
    def entries_role(self) -> str:
        return self.sections[0]

    @property
    def pointers_role(self) -> str:
        return self.sections[1]

    @property
    def emitted_sections(self) -> tuple[str, ...]:
        # The divider table is a sibling file of derived rows -- see the class
        # docstring -- so a fragment written here holds the entries alone.
        return (self.entries_role,)

    def decode(
        self, images: dict[str, bytes]
    ) -> tuple[tuple[tuple[int, int], ...], ...]:
        raw_ptrs = images[self.pointers_role]
        if len(raw_ptrs) < self.POINTERS * 2:
            raise AsmRegionError(f"{self.id}: pointer table is short")
        ptrs = [
            int.from_bytes(raw_ptrs[i * 2 : i * 2 + 2], "little")
            for i in range(self.POINTERS)
        ]
        entries = images[self.entries_role]
        if ptrs != sorted(ptrs) or ptrs[-1] * 4 > len(entries):
            raise AsmRegionError(f"{self.id}: pointers are not a partition")
        events = []
        for n in range(self.EVENTS):
            events.append(
                tuple(
                    (
                        int.from_bytes(entries[i : i + 2], "little"),
                        int.from_bytes(entries[i + 2 : i + 4], "little"),
                    )
                    for i in range(ptrs[n] * 4, ptrs[n + 1] * 4, 4)
                )
            )
        return tuple(events)

    def _check(self, model: tuple[tuple[tuple[int, int], ...], ...]) -> None:
        if len(model) != self.EVENTS:
            raise AsmRegionError(
                f"{self.id} holds {self.EVENTS} events, got {len(model)}"
            )
        for event in model:
            if any(not (0 <= a <= 0xFFFF and 0 <= b <= 0xFFFF) for a, b in event):
                raise AsmRegionError(f"{self.id}: a word is out of range")

    def used(self, model: tuple[tuple[tuple[int, int], ...], ...]) -> dict[str, int]:
        # Four bytes an entry, and two a pointer including the shared end
        # marker. Only the entries are this fragment's -- see
        # `emitted_sections` -- so only they are priced against its run.
        self._check(model)
        return {
            self.entries_role: 4 * sum(len(event) for event in model),
            self.pointers_role: 2 * self.POINTERS,
        }

    def encode(
        self,
        model: tuple[tuple[tuple[int, int], ...], ...],
        room: int | None = None,
    ) -> dict[str, bytes]:
        self.fits(model, room)
        entries = bytearray()
        ptrs = []
        for event in model:
            ptrs.append(len(entries) // 4)
            for sheet, destination in event:
                entries += sheet.to_bytes(2, "little")
                entries += destination.to_bytes(2, "little")
        ptrs.append(len(entries) // 4)
        return {
            self.entries_role: bytes(entries),
            self.pointers_role: b"".join(p.to_bytes(2, "little") for p in ptrs),
        }

    def emit(
        self,
        model: tuple[tuple[tuple[int, int], ...], ...],
        room: int | None,
        base: RomBase,
    ) -> str:
        self.fits(model, room)
        entries_label = self.label(base, self.entries_role)
        lines = [
            f"; {self.id} -- written by the editor. The divider table that",
            "; slices these rows is overworld/layer2-event-pointers.asm, whose",
            "; every row names one of the .Event sublabels below.",
            "",
            entries_label + ":",
            "base $000000",
        ]
        for n, event in enumerate(model):
            lines.append(f".Event{n:02X}")
            lines += [f"\tdw ${a:04X},${b:04X}" for a, b in event]
        lines.append(f".Event{self.EVENTS:02X}")
        lines.append("base off")
        return "\n".join(lines) + "\n"

    def parse(
        self, text: str, base: RomBase
    ) -> tuple[tuple[tuple[int, int], ...], ...]:
        entries_label = self.label(base, self.entries_role)
        pointers_label = self.label(base, self.pointers_role)
        events: list[list[tuple[int, int]]] = []
        current: list[tuple[int, int]] | None = None
        seen = 0  # sublabels so far; the last one is the shared end marker
        name = str(self.path)
        for number, raw in enumerate(text.split("\n"), start=1):
            line = _comment_stripped(raw)
            if not line:
                continue
            if line in ("base $000000", "base off"):
                continue
            if line == entries_label + ":":
                continue
            if line == pointers_label + ":":
                raise AsmRegionError(
                    f"{name}:{number}: the divider table moved out of this "
                    f"fragment into overworld/layer2-event-pointers.asm -- "
                    f"delete the {pointers_label} block and the rows under it"
                )
            if line.startswith("."):
                expected = f".Event{seen:02X}"
                if line != expected:
                    raise AsmRegionError(
                        f"{name}:{number}: {line} where {expected} belongs"
                    )
                seen += 1
                current = [] if seen <= self.EVENTS else None
                if current is not None:
                    events.append(current)
                continue
            if line.startswith("dw "):
                if current is None:
                    if seen <= self.EVENTS:
                        raise AsmRegionError(f"{name}:{number}: data before .Event00")
                    # After the end marker only padding may follow.
                    if any(_values(line[2:], name, number)):
                        raise AsmRegionError(
                            f"{name}:{number}: data after the end marker"
                        )
                    continue
                values = _values(line[2:], name, number)
                if len(values) != 2:
                    raise AsmRegionError(
                        f"{name}:{number}: an entry is two words, got {len(values)}"
                    )
                current.append((values[0], values[1]))
                continue
            raise AsmRegionError(f"{name}:{number}: {line!r} is off-grammar")
        model = tuple(tuple(event) for event in events)
        self._check(model)
        return model


REGIONS: tuple[AsmRegion, ...] = (
    FixedTables(
        id="overworld.walk_directions",
        path=TABLES_DIR / "walk-directions.asm",
        namespace="SMW_LoadOverworldLayer1AndEvents",
        owner="overworld",
        sections=("overworld_level_directions",),
        widths=(1,),
        counts=(0x71,),
    ),
    FixedTables(
        id="overworld.level_events",
        path=TABLES_DIR / "level-events.asm",
        namespace="SMW_SpecifySublevelToLoad",
        owner="overworld",
        sections=("overworld_level_events",),
        widths=(1,),
        counts=(0x60,),
    ),
    FixedTables(
        id="overworld.level_names",
        path=TABLES_DIR / "level-names.asm",
        namespace="SMW_LevelNames",
        owner="overworld",
        sections=("overworld_level_names",),
        widths=(2,),
        counts=(93,),
        # The Japanese build decodes level names with its own routine and
        # word format; its payload is `overworld/levelnames-j.asm`, outside
        # this region, and a fragment saved for it would assemble to nothing.
        excluded_targets=("J",),
    ),
    FixedTables(
        id="overworld.event_tile_locations",
        path=TABLES_DIR / "layer1-event-locations.asm",
        namespace="SMW_ChangingLayer1OverworldTiles",
        owner="overworld",
        sections=("overworld_event_layer1_locations",),
        widths=(2,),
        counts=(0x70,),
    ),
    FixedTables(
        id="overworld.event_tile_swaps",
        path=TABLES_DIR / "layer1-event-swaps.asm",
        namespace="SMW_ChangingLayer1OverworldTiles",
        owner="overworld",
        sections=("overworld_event_layer1_from", "overworld_event_layer1_to"),
        widths=(1, 1),
        counts=(22, 22),
        # All three scans take the last pair as `TilesToBecome -
        # TilesThatChange - 1`, a 16-bit index walked down with BPL, so the
        # rows bound the scan and nothing but room bounds the rows. Pair $15
        # stays the one that writes two cells: that compare is a literal of
        # the routine's, and a grown table's new pairs are ordinary.
        growable=True,
    ),
    FixedTables(
        id="overworld.destroyed_tiles",
        path=TABLES_DIR / "destroyed-tiles.asm",
        namespace="SMW_CheckIfDestroyTileEventIsActive",
        owner="overworld",
        # The five tables in ROM order: what a ruin looks like, then which
        # event ruins which cell. The scan walks $18 event numbers over a
        # $10-entry table -- the shipped off-by-$8 -- so the count here is
        # what the table *holds*, not what the game reads.
        sections=(
            "overworld_destroy_before",
            "overworld_destroy_top",
            "overworld_destroy_bottom",
            "overworld_destroy_locations",
            "overworld_destroy_events",
        ),
        widths=(1, 1, 1, 2, 1),
        counts=(5, 5, 5, 0x10, 0x10),
        # The scan walks the two slot tables in an 8-bit X with BPL, so $80
        # is where the first index turns negative. On a stock build its bound
        # is the literal $17 -- eight entries past the sixteen, read out of
        # the save-prompt tiles the ROM map placed next -- and the table
        # cannot move or grow; a build that binds it to the labels
        # (the relocation's `label_bound_scans`) reads the table whole and
        # nothing past it, and then it does both.
        growable=True,
        scanned=("overworld_destroy_locations", "overworld_destroy_events"),
        overread=8,
        capacity=0x80,
    ),
    FixedTables(
        id="overworld.silent_tiles",
        path=TABLES_DIR / "silent-tiles.asm",
        namespace="SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent",
        owner="overworld",
        sections=(
            "overworld_silent_tiles",
            "overworld_silent_layers",
            "overworld_silent_locations",
            "overworld_silent_tile_numbers",
        ),
        widths=(1, 1, 2, 2),
        counts=(0x2C, 0x2C, 0x2C, 0x2C),
        # The one scan takes the last slot as `TileLayer - EventNum - 1` in an
        # 8-bit X walked down with BPL: $80 slots is where the first index
        # turns negative and the loop falls through untried.
        growable=True,
        capacity=0x80,
    ),
    FixedTables(
        id="overworld.star_pipe_warps",
        path=TABLES_DIR / "star-pipe-warps.asm",
        namespace="SMW_HandleOverworldStarPipeWarp",
        owner="overworld",
        sections=(
            "overworld_warp_trigger_columns",
            "overworld_warp_trigger_rows",
            "overworld_warp_landings_x",
            "overworld_warp_landings_y",
        ),
        widths=(2, 2, 2, 2),
        counts=(27, 27, 27, 27),
        # `GetIndex` takes the last entry as `TriggerRow - TriggerColumnAndMap
        # - 2` in an 8-bit Y stepped down by two with BPL: 64 entries is where
        # the first index turns negative.
        growable=True,
        capacity=64,
    ),
    FixedTables(
        id="overworld.sprite_submaps",
        path=TABLES_DIR / "sprite-submaps.asm",
        namespace="SMW_CheckIfXIsAllowedOnYSubmap",
        owner="overworld",
        sections=("overworld_sprite_submap_disable",),
        widths=(1,),
        counts=(10,),
    ),
    # The translevel-remap feature's own table: which level number each
    # translevel loads, one word per translevel, replacing the arithmetic in
    # SMW_SpecifySublevelToLoad. Only on a cartridge built with the feature
    # (`feature=`): the stock game has no such table, the fragment is emitted
    # only under the define, and its role is declared by the feature rather
    # than by rom_tables.
    FixedTables(
        id="overworld.translevel_levels",
        path=TABLES_DIR / "translevel-levels.asm",
        namespace="SMW_TranslevelRemap",
        owner="overworld",
        sections=("overworld_translevel_levels",),
        widths=(2,),
        counts=(0x60,),
        feature="translevel-remap",
    ),
    PathExits(
        id="overworld.path_exits",
        path=TABLES_DIR / "path-exits.asm",
        namespace="SMW_HandleOverworldPathExits",
        owner="overworld",
        sections=(
            "overworld_exit_triggers",
            "overworld_exit_landings",
            "overworld_exit_landing_cells",
        ),
        # `Main` takes the last entry as `LandingPositions - TriggerPositions
        # - 5` in an 8-bit Y stepped down by five with BPL, and the landing
        # cells' cursor as the same count doubled: 26 entries is where the
        # first index turns negative.
        growable=True,
        capacity=26,
    ),
    # The four secondary-header tables: one byte per level each, indexed by
    # the level number -- the per-level half of the load path, beside the
    # per-translevel tables above. Bank $05 places SecondaryEntrance1 directly
    # after them, so each fragment's run is exactly its $200 rows.
    FixedTables(
        id="levels.secondary_header_1",
        path=Path("levels/properties/1.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_header_scroll_and_entrance_y",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_header_2",
        path=Path("levels/properties/2.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_header_layer3_and_entrance_x",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_header_3",
        path=Path("levels/properties/3.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_header_initial_camera_y",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_header_4",
        path=Path("levels/properties/4.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_header_intro_and_entrance_screen",),
        widths=(1,),
        counts=(0x200,),
    ),
    # The four secondary-entrance tables, in the same shape again but indexed
    # by the secondary entrance number rather than by the level. Bank $05
    # places them straight after the four above, the last of them reaching the
    # end of the bank, so each fragment's run is exactly its $200 rows.
    FixedTables(
        id="levels.secondary_entrance_1",
        path=Path("levels/properties/5.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_entrance_destination_level",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_entrance_2",
        path=Path("levels/properties/6.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_entrance_camera_and_entrance_y",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_entrance_3",
        path=Path("levels/properties/7.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_entrance_entrance_x_and_screen",),
        widths=(1,),
        counts=(0x200,),
    ),
    FixedTables(
        id="levels.secondary_entrance_4",
        path=Path("levels/properties/8.asm"),
        namespace="SMW_SpecifySublevelToLoad",
        owner="levels",
        sections=("secondary_entrance_action",),
        widths=(1,),
        counts=(0x200,),
    ),
    # The four tables the lunar-magic-levels feature adds to the secondary
    # header: one byte per level each, in the same shape as the four above,
    # and only on a cartridge built with the feature (`feature=`) -- the
    # stock game has no such tables, the fragments are emitted only under the
    # define, and their roles are declared by the feature. The placement
    # asserts each fragment's run is exactly its $200 rows.
    *(
        FixedTables(
            id=region_id,
            path=path,
            namespace="SMW_LunarMagicLevels",
            owner="levels",
            sections=(role,),
            widths=(1,),
            counts=(0x200,),
            feature="lunar-magic-levels",
        )
        for region_id, path, role in zip(
            (
                "levels.lunar_magic_entrance",
                "levels.lunar_magic_scroll",
                "levels.lunar_magic_entrance_y",
                "levels.lunar_magic_background",
            ),
            (
                Path("levels/properties/lunar-magic-entrance.asm"),
                Path("levels/properties/lunar-magic-scroll.asm"),
                Path("levels/properties/lunar-magic-entrance-y.asm"),
                Path("levels/properties/lunar-magic-background.asm"),
            ),
            (
                "lunar_magic_entrance",
                "lunar_magic_scroll",
                "lunar_magic_entrance_y",
                "lunar_magic_background",
            ),
            strict=True,
        )
    ),
    # The four tables the layer3-settings feature adds: one byte per level
    # each, the same shape again, and only on a cartridge built with it.
    *(
        FixedTables(
            id=region_id,
            path=path,
            namespace="SMW_Layer3Settings",
            owner="levels",
            sections=(role,),
            widths=(1,),
            counts=(0x200,),
            feature="layer3-settings",
        )
        for region_id, path, role in zip(
            (
                "levels.layer3_horizontal",
                "levels.layer3_vertical",
                "levels.layer3_offset_x",
                "levels.layer3_offset_y",
            ),
            (
                Path("levels/properties/layer3-horizontal.asm"),
                Path("levels/properties/layer3-vertical.asm"),
                Path("levels/properties/layer3-offset-x.asm"),
                Path("levels/properties/layer3-offset-y.asm"),
            ),
            (
                "layer3_horizontal",
                "layer3_vertical",
                "layer3_offset_x",
                "layer3_offset_y",
            ),
            strict=True,
        )
    ),
    EventStamps(
        id="overworld.layer2_events",
        path=TABLES_DIR / "layer2-events.asm",
        namespace="SMW_Layer2EventData",
        owner="overworld",
        sections=("overworld_event_tile_entries", "overworld_event_pointers"),
    ),
    # The game's text. Both are strings under the standard font whose last
    # tile carries bit 7, bounded by the bytes the shipped ones occupy: the
    # pointers into them are assembler-computed offsets, so a string may
    # grow while another shrinks and the total is what has to fit.
    MessageTables(
        id="strings.level_messages",
        # The index the bank incsrc's, which puts the font in force; the
        # messages themselves are one file each, the slot tables another,
        # and those are what a save writes. The Japanese build has its own
        # files in its own format, and the arcade build rewords one message
        # under a version `if` the emitter does not write -- so both are
        # refused.
        path=STRINGS_DIR / "LevelMessageText_SMW_U.asm",
        namespace="SMW_DisplayMessage",
        owner="strings",
        sections=(
            "level_message_levels",
            "level_message_pointers",
            "level_message_text",
        ),
        slots_file=STRINGS_DIR / "MessageSlots_SMW_U.asm",
        labels=MESSAGE_LABELS,
        lines=MESSAGE_LINES,
        line_width=MESSAGE_WIDTH,
        header=FONT_HEADER,
        entry_files=tuple(
            STRINGS_DIR / "messages" / "SMW_U" / f"{label}.asm"
            for label in MESSAGE_LABELS
        ),
        excluded_targets=("J", "SS"),
    ),
    TerminatedStrings(
        id="strings.level_names",
        path=STRINGS_DIR / "LevelNameStrings.asm",
        namespace="SMW_UpdateLevelName",
        owner="strings",
        sections=("overworld_level_name_strings",),
        labels=NAME_LABELS,
        header=FONT_HEADER,
        # The Japanese build draws its names out of its own kana blob, in a
        # format of its own, through its own routine.
        excluded_targets=("J",),
    ),
)


def regions(base: RomBase | None = None) -> dict[str, AsmRegion]:
    """Every editable region ``base``'s cartridge has, keyed by id, as that
    cartridge has them.

    ``None`` is the stock format, which is what a caller with no cartridge in
    hand is entitled to -- see :meth:`AsmRegion.for_base`. A region that is a
    *feature's* own table (:attr:`AsmRegion.feature`) is answered only for a
    base carrying the feature: on any other cartridge the fragment assembles
    to nothing and its role resolves to nothing, so offering the region would
    be offering a table the cartridge has not got.
    """
    held = () if base is None else base.features
    return {
        region.id: region.for_base(base)
        for region in REGIONS
        if region.feature is None or region.feature in held
    }


def region_for(region_id: str, base: RomBase | None = None) -> AsmRegion:
    try:
        return regions(base)[region_id]
    except KeyError:
        raise AsmRegionError(f"{region_id} is not an editable asm region") from None


def declared_region(region_id: str) -> AsmRegion:
    """``region_id`` as declared, whatever cartridge is in hand.

    :func:`region_for` is the availability question -- a feature's own region
    is withheld from a base without the feature. This is the *format*
    question: what shape the region's rows are, which a codec packing a part
    it already holds may ask of any region the registry declares.
    """
    for region in REGIONS:
        if region.id == region_id:
            return region
    raise AsmRegionError(f"{region_id} is not an editable asm region")


def entry_count(role: str, base: RomBase | None = None) -> int:
    """How many entries the table filed under ``role`` holds on ``base``.

    **The registry is the one owner of a table's shape.** Everything that
    reads, sizes or guards one of these tables asks here, so the stock count
    lives in exactly one place -- the region that writes the table -- and a
    shape no region declares (a table priced against a budget, or one that is
    not an editable region at all) is a loud error rather than a zero.

    A base that a feature grew a table on answers with the grown count, and
    only for the roles that feature named. ``None`` is the stock format.
    """
    for region in REGIONS:
        found = region.for_base(base).entry_counts().get(role)
        if found is not None:
            return found
    raise AsmRegionError(f"no region declares an entry count for {role}")


def measured_counts(
    region: AsmRegion, symbols: SymbolTable, base: RomBase
) -> dict[str, int]:
    """How many entries each of ``region``'s sections holds on the build
    ``symbols`` describe, by role.

    A table's count is not declared anywhere once its scan bound is the
    table's own length -- so it is read the way an address is: off the
    build's own symbol file. The scanned tables of one fragment are parallel
    and emitted back to back, so each runs from its label to the next
    section's, and one that nothing follows holds as many as the rest. A
    region that does not grow on ``base`` answers its declared counts, so a
    caller can ask of every region alike.

    The build the symbols describe must be the build being read -- the same
    freshness :func:`run_for` asks of its caller.
    """
    region = region.for_base(base)
    if not region.grows:
        return region.entry_counts()
    starts = []
    for role in region.sections:
        label = base.table(role).label
        found = symbols.by_name.get(label)
        if found is None:
            raise AsmRegionError(f"{label} is not in the symbol file")
        starts.append(found.addr)
    scanned = set(region.scanned_sections)
    measured = set()
    for role, stride, first, after in zip(
        region.sections, region.strides, starts, starts[1:], strict=False
    ):
        if role not in scanned:
            continue
        span = after - first
        if span <= 0 or span % stride:
            raise AsmRegionError(
                f"{region.id} ({role}): {span:#x} bytes between its label and "
                f"the next is not a whole number of {stride}-byte entries"
            )
        measured.add(span // stride)
    if len(measured) != 1:
        raise AsmRegionError(
            f"{region.id}: its sections measure {sorted(measured)} entries, "
            f"and one loop indexes them all"
        )
    (entries,) = measured
    if not region.allows(entries):
        raise AsmRegionError(
            f"{region.id} measures {entries} entries, past what its scan reaches"
        )
    counts = region.entry_counts()
    counts.update(dict.fromkeys(scanned, entries))
    return counts
