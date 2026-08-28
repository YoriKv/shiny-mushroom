"""The interface every editable asm region wears.

:class:`AsmRegion` is the codec :mod:`smw_tools.asm_regions` builds its
registry out of: one fragment's file, its sections, and the three forms it
joins -- the model an editor holds, the per-section ROM image a save is priced
against, and the fragment text the build assembles. A region whose model is
text rather than numbers is in :mod:`smw_tools.asm_strings`; how much ROM a
fragment has to grow into is :mod:`smw_tools.asm_room`.
"""

from __future__ import annotations

from collections.abc import Callable, Iterable, Iterator, Mapping
from dataclasses import dataclass, replace
from pathlib import Path
from typing import TYPE_CHECKING

from .codegraph import strip_comment

if TYPE_CHECKING:
    from .bases import RomBase


class AsmRegionError(ValueError):
    """A fragment or model that is not what the registry says it is."""


class AsmRegionFull(AsmRegionError):
    """A fragment's rows no longer fit the run of ROM it assembles into.

    The whole fragment rather than one of its tables: they are emitted back to
    back and move each other, so which one is "over" is not a fact -- only the
    total is.
    """

    def __init__(self, region: str, used: int, room: int) -> None:
        self.region = region
        self.used = used
        self.room = room
        super().__init__(
            f"{region} needs {used:,} bytes and has {room:,}: {used - room:,} too many"
        )


def _joined(texts: Iterable[str]) -> str:
    """Several files as one text, each ended by a newline whether or not it
    carried one: a file the assembler splices in ends at its last byte, and
    the next label must not land on that line."""
    return "".join(text if text.endswith("\n") else text + "\n" for text in texts)


def _comment_stripped(line: str) -> str:
    """One fragment line without its trailing comment, and without indentation.

    Quote-aware, through the assembly reader the rest of the package uses: a
    `;` inside a string is part of the string, and cutting there would turn a
    row into a parse error rather than reading it.
    """
    return strip_comment(line).strip()


#: The literal forms a fragment may spell a value in, by their prefix: what
#: :meth:`AsmRegion.emit` writes is always hexadecimal, but a shipped
#: fragment whose table is bit flags is written in binary where that is what
#: the bits mean, and the parse has to read the checkout as it stands.
_RADICES = {"$": (16, "hexadecimal"), "%": (2, "binary")}


def _values(payload: str, path: str, number: int) -> list[int]:
    out = []
    for piece in payload.split(","):
        piece = piece.strip()
        held = _RADICES.get(piece[:1])
        if held is None:
            raise AsmRegionError(
                f"{path}:{number}: {piece!r} is not a $- or %-prefixed value"
            )
        radix, kind = held
        try:
            out.append(int(piece[1:], radix))
        except ValueError:
            raise AsmRegionError(f"{path}:{number}: {piece!r} is not {kind}") from None
    return out


def _rows(values: list[int], directive: str, per_line: int, width: int) -> list[str]:
    fmt = f"${{:0{width * 2}X}}"
    return [
        "\t{} {}".format(
            directive, ",".join(fmt.format(v) for v in values[i : i + per_line])
        )
        for i in range(0, len(values), per_line)
    ]


@dataclass(frozen=True)
class AsmRegion:
    """One editable fragment: its file, its sections, and their codec."""

    #: The region's name, ``<owner>.<what>``.
    id: str
    #: The fragment, relative to the base's game folder.
    path: Path
    #: The namespace the bank macro opens around the fragment. A section's
    #: label inside the fragment is its rom_tables label with this prefix off.
    namespace: str
    #: The editor tool whose save writes this region.
    owner: str
    #: rom_tables roles for each labelled table, in ROM order. The first is
    #: where the fragment starts.
    sections: tuple[str, ...]

    #: Targets whose build routes around this fragment -- a version `if` in
    #: the including bank picks a different payload there. A fragment saved
    #: for one of these would assemble to nothing, the silent stock-build
    #: failure the overlay must never allow, so consumers gate every read
    #: and write on :meth:`applies_to`.
    excluded_targets: tuple[str, ...] = ()

    #: The feature whose build assembles this fragment at all, or ``None`` for
    #: a table the stock game has. The fragment of a feature's own table is
    #: emitted only under that feature's define, its role is declared only by
    #: the feature, and a base without it has no label to price against -- so
    #: :func:`regions` answers with the region only for a base that carries
    #: the feature, exactly as :attr:`excluded_targets` withholds a fragment
    #: from the build that routes around it.
    feature: str | None = None

    #: Whether the game's scan of this table can follow the rows -- its bound
    #: is an assembler expression over the fragment's own labels, so a saved
    #: fragment may add and delete rows: the silent tiles, the swap pairs, the
    #: warps, the path exits, and the destroyed tiles on a build whose scan is
    #: rewritten that way (:attr:`overread`). A region that is not growable
    #: holds exactly its declared counts, which are the format.
    growable: bool = False
    #: The most entries a growable table's reader can scan -- the index
    #: register's width, or the branch that ends the loop -- beyond which
    #: rows are dead bytes. ``None`` bounds it by room alone.
    capacity: int | None = None
    #: Entries the scan reads **past** the table's last row on a build whose
    #: bound is still a literal -- the destroyed-tiles scan's shipped eight.
    #: Zero where the scan follows the rows, which :meth:`for_base` answers
    #: for a base whose build rewrote the bound
    #: (:attr:`~smw_tools.bases.RomBase.label_bound_scans`); so a region
    #: :attr:`grows` on a base exactly when it is growable and reads nothing
    #: past its rows there.
    overread: int = 0
    #: The sections the scan's count walks -- the parallel tables one loop
    #: indexes. Empty means every section; the destroyed-tiles fragment's
    #: three ruin-kind tables are scanned by their own literal and stay put
    #: while its two slot tables grow.
    scanned: tuple[str, ...] = ()

    @property
    def grows(self) -> bool:
        """Whether this region's table grows on the base it was resolved
        for: the scan follows the rows, and reads nothing past them."""
        return self.growable and self.overread == 0

    @property
    def scanned_sections(self) -> tuple[str, ...]:
        """The sections whose count the scan follows -- :attr:`scanned`, or
        every section where it names none."""
        return self.scanned or self.sections

    @property
    def strides(self) -> tuple[int, ...]:
        """Bytes an entry, per section -- what a section's label-to-label
        distance is divided by to measure its count."""
        raise NotImplementedError

    def within_reach(self, entries: int) -> bool:
        """Whether a growable table's reader could scan ``entries`` rows once
        its bound follows them: at least one, and no more than
        :attr:`capacity` -- the format's answer, whatever this base's build
        does. A table that is not growable reaches its declared count alone."""
        if not self.growable:
            return entries == self.entry_counts()[self.scanned_sections[0]]
        return 1 <= entries and (self.capacity is None or entries <= self.capacity)

    def allows(self, entries: int) -> bool:
        """Whether the scanned tables may hold ``entries`` rows on this base:
        :meth:`within_reach` where the table grows here, exactly the declared
        count otherwise -- a literal scan reads that many, whatever is saved."""
        if not self.grows:
            return entries == self.entry_counts()[self.scanned_sections[0]]
        return self.within_reach(entries)

    def applies_to(self, target_id: str) -> bool:
        """Whether ``target_id``'s build assembles this region's fragment."""
        return target_id not in self.excluded_targets

    @property
    def files(self) -> tuple[Path, ...]:
        """Every file the fragment is spelled across, relative to the base's
        game folder, in ROM order.

        One file for nearly every region -- :attr:`path` itself. A region
        whose rows are *content*, authored one at a time, keeps them one file
        each (the level messages), and then :attr:`path` is the index that
        ``incsrc``'s them while these are what the overlay shadows: a save
        writes the files whose entries changed and no other, so the overlay
        stays the diff at the granularity the tree was split at.
        """
        return (self.path,)

    def read(self, read_text: Callable[[Path], str]) -> str:
        """The fragment's text, through ``read_text`` for each of its files
        -- the overlay's or the base tree's, whichever the caller means --
        joined in ROM order. A region whose file set is not fixed (the
        messages, once they may grow) finds its files here rather than
        listing them."""
        return _joined(read_text(path) for path in self.files)

    def owns(self, path: Path) -> bool:
        """Whether ``path`` (relative to the game folder) is a file this
        region writes -- one of :attr:`files`, or for a region whose set may
        grow, any file of its shape.

        A region that overrides this to accept a file :attr:`files` does not
        list says so through :attr:`fixed_files` as well; the two are one
        statement about the same set.
        """
        return path in self.files

    @property
    def fixed_files(self) -> bool:
        """Whether :attr:`files` is every file this region could own.

        True by default, and true wherever :meth:`owns` is the default: a
        path is this region's exactly when it is one of the listed files, so
        a caller looking for the region's files in an overlay has them
        already and needs no directory walk to find more. **A region whose
        set may grow answers False** -- the messages, one file an entry, of
        which a saved cartridge may hold more than the disassembly ships --
        and then only a walk can say what is there.
        """
        return True

    def scanned_count(self, model) -> int:
        """How many entries the model holds in the scanned tables -- what a
        switch compares against the count a literal scan reads."""
        first = self.sections.index(self.scanned_sections[0])
        return len(model[first])

    def emit_files(
        self, model, room: int | None, base: RomBase, stock=None
    ) -> dict[Path, str]:
        """The model as the files a save writes, by path.

        :meth:`emit` for a region of one file. ``stock`` is the disassembly's
        own model where the caller holds it, so a region of several files can
        answer with only the ones whose entries differ -- the rest stay the
        base tree's, unshadowed.
        """
        return {self.path: self.emit(model, room, base)}

    @property
    def emitted_sections(self) -> tuple[str, ...]:
        """The sections :meth:`emit` writes into the fragment.

        Every one, except where a section's table is *derived* and so lives in
        a sibling source file that needs no editing -- see :class:`EventStamps`.
        The rest of :attr:`sections` is still the region's: priced, decoded and
        patched into a preview here, just not written back as text.
        """
        return self.sections

    def label(self, base: RomBase, role: str) -> str:
        """``role``'s label as the fragment spells it -- without the namespace."""
        flat = base.table(role).label
        prefix = self.namespace + "_"
        if not flat.startswith(prefix):
            raise AsmRegionError(f"{flat} is not in namespace {self.namespace}")
        return flat[len(prefix) :]

    def entry_counts(self) -> dict[str, int]:
        """The entry count per role, for the sections whose count is declared.

        Empty by default: a section priced against a budget rather than a
        declared count -- the stamp entry table -- has no count to report.

        **This region's own**, which for one resolved through :func:`region_for`
        with a base is that cartridge's -- see :meth:`for_base`. Nothing here
        answers two numbers at once: a region is the shape of one table, and a
        caller holding one that is not its cartridge's would be wrong in a way
        no error could catch.
        """
        return {}

    def for_base(self, base: RomBase | None = None) -> AsmRegion:
        """This region as ``base``'s cartridge has it.

        A base departs from the stock format only where a feature grew a table
        (:attr:`~smw_tools.bases.RomBase.entry_counts`) or bound a scan to its
        table's labels (:attr:`~smw_tools.bases.RomBase.label_bound_scans`),
        so the answer is ``self`` for every base that has not -- which is the
        stock base, and is why nothing pays for this.

        The count is amended *here*, on the region, rather than being passed to
        each codec call: the count is part of the table's shape, and a region
        whose shape is the cartridge's cannot be used with the wrong one by
        forgetting an argument.
        """
        region = self
        if base is not None and base.entry_counts:
            region = region.with_entry_counts(base.entry_counts)
        if base is not None and self.id in base.label_bound_scans and region.overread:
            # The build bound the scan to the labels: nothing is read past the
            # rows, and the table grows on this cartridge.
            region = replace(region, overread=0)
        return region

    def with_entry_counts(self, counts: Mapping[str, int]) -> AsmRegion:
        """This region at ``counts`` entries, by role -- and so its codec.

        The other way a grown count arrives. :meth:`for_base` takes one a base
        *declares*; this takes one a caller *measured*, off data already in
        hand -- a part read from a cartridge is as long as that cartridge's
        table, and decoding it at the stock count would read the wrong number
        of rows and call the rest a short image. Both land here, so a region
        whose shape came from a measurement is the same kind of thing as one
        whose shape came from a base, and every codec below reads its count in
        one place.

        Roles this region declares no count for are ignored rather than
        refused, because the map a base hands over spans every region and each
        one takes only its own. A count that could not be a table is refused,
        and amending nothing answers ``self`` -- the identity
        :meth:`for_base` rests on.
        """
        stock = self.entry_counts()
        wanted = {role: counts[role] for role in stock if role in counts}
        for role, count in wanted.items():
            if count < 0:
                raise AsmRegionError(f"{self.id} ({role}) cannot hold {count} entries")
        if all(stock[role] == count for role, count in wanted.items()):
            return self
        return self._with_counts({**stock, **wanted})

    def _with_counts(self, counts: dict[str, int]) -> AsmRegion:
        """This region with ``counts`` as its entry counts, by role.

        Where each kind keeps its counts is its own business -- a tuple per
        section, one number shared by three tables -- so the policy above is
        written once and the mechanics live with the shape they change.
        """
        raise AsmRegionError(f"{self.id} declares no entry count to change")

    # -- the codec, overridden per region kind -------------------------------

    def decode(self, images: dict[str, bytes]):
        """Per-section ROM images to the model."""
        raise NotImplementedError

    def encode(self, model, room: int | None = None) -> dict[str, bytes]:
        """The model to per-section ROM images.

        ``room`` is the fragment's run of ROM, from :func:`room`, and is only
        used to price the rows: ``None`` encodes without asking whether they
        fit, which is what :meth:`used` and a caller that has already priced
        want.
        """
        raise NotImplementedError

    def used(self, model) -> dict[str, int]:
        """How many bytes each section's rows need.

        The question to ask when the room is what is in doubt. Two readings of
        it price one layout against another: the rows a project has saved need
        :meth:`used` of *its* model, and what the stock cartridge gives them is
        :meth:`used` of the disassembly's own, since a shipped fragment is
        exactly the bytes between its label and whatever the ROM map placed
        after it.

        Per section rather than one total, because the sections of one region
        are not always one fragment -- see :attr:`emitted_sections`.
        """
        raise NotImplementedError

    def fits(self, model, room: int | None) -> int:
        """The bytes this fragment needs, or :class:`AsmRegionFull` if too many.

        The one place the total is formed, so every codec prices the same way:
        the sections this fragment *emits*, summed, against the run of ROM it
        assembles into. ``room`` of ``None`` prices nothing and just answers.
        """
        sizes = self.used(model)
        needed = sum(sizes[role] for role in self.emitted_sections)
        if room is not None and needed > room:
            raise AsmRegionFull(self.id, needed, room)
        return needed

    def emit(self, model, room: int | None, base: RomBase) -> str:
        """The model as fragment text, in the grammar :meth:`parse` reads.

        ``room`` prices the rows before any text exists, exactly as
        :meth:`encode` does; ``None`` writes them unpriced.
        """
        raise NotImplementedError

    def parse(self, text: str, base: RomBase):
        """Fragment text back to the model. Refuses anything off-grammar."""
        raise NotImplementedError

    def _data_rows(self, text: str, base: RomBase) -> Iterator[tuple[int, str, int]]:
        """Every data line of ``text`` as ``(section, line, line number)``.

        The half of the grammar every labelled fragment shares: a top-level
        ``Label:`` opens the section it names, blank and comment-only lines are
        nothing, and each remaining line is a row of whichever section is open.
        A label the registry does not declare and data before any label are
        refused here, by name and line. What a *row* is stays with the region,
        which is the half that differs.
        """
        labels = [self.label(base, role) for role in self.sections]
        name = str(self.path)
        current: int | None = None
        for number, raw in enumerate(text.split("\n"), start=1):
            line = _comment_stripped(raw)
            if not line:
                continue
            if line.endswith(":") and not line.startswith("."):
                label = line[:-1]
                if label not in labels:
                    raise AsmRegionError(f"{name}:{number}: unexpected label {label}")
                current = labels.index(label)
                continue
            if current is None:
                raise AsmRegionError(f"{name}:{number}: data before any label")
            yield current, line, number
