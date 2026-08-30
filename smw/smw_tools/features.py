"""What a cartridge has that the stock game has not, and what that changes.

A **feature** is a capability built on top of a base: more sprite slots, a
warp table with room for more entries, an object loop moved into freespace.
Nothing here describes what a feature *does* -- that is the patch's job. What
it declares is what the feature **moved**, because every address, bank range
and RAM location the editor reads is a fact about the cartridge in hand, and
adding a capability is exactly the thing that makes one of those facts wrong.

**A feature is a declaration, exactly as a base is.** The same reasoning as
:class:`~smw_tools.bases.RomBase`: an address held rather than discovered is
one a test can check and a reader can argue with, and nothing has to run to
know it. A feature declares only the kinds of fact something already reads --
tables, the traced code ranges, the RAM map, the driven paths -- so a
declaration cannot be written that nothing honours.

**Where a feature comes from, and why the three are the same thing.** A base
may be *built with* one (:attr:`~smw_tools.bases.RomBase.features`), the way a
coprocessor base is built with its pack's sprite engine; a project may *add*
one, through an asm patch that says which feature it provides; and the
disassembly may carry one itself, behind a define a build switches on --
:attr:`Feature.defines`, which is the only provenance a project can turn on
and off for itself. Downstream none of the three is distinguishable from the
others, which is the point: the editor asks what the cartridge is, not how it
got that way.

**A bank a feature needs and a bank it can do without are different
declarations.** :attr:`Feature.min_rom_size` is a requirement -- the data has
nowhere else to go, and the build refuses a cartridge the bank is not in.
:attr:`Feature.bank_rom_size` is room: the feature is built at any size, uses
the bank where the cartridge has one, and packs into what the game's own banks
leave where it has not. Which of the two is true of a feature decides whether
the cartridge size is a requirement or a choice, and
:data:`MANAGED_LEVEL_MEMORY` is the one that makes it a choice -- at the price
of keeping every address it must be able to name in a bank every cartridge
has.

**What a feature costs to build is declared here; what it costs a *project* is
not.** The defines that switch one on and the cartridge it needs room in are
facts about the assembly, so they sit beside the facts about the cartridge. The
data migration turning one on or off asks of an overlay, and the limitation
that refuses to turn one off while the work would not fit back, belong to
whoever owns that overlay -- ``shiny_mushroom.features`` in the editor. Nothing
in this package knows what a project is.

**Applying one amends the base.** :func:`applied` hands back a
:class:`~smw_tools.bases.RomBase` with the feature's facts folded in, so
nothing downstream learns a new type -- ``Addresses``, ``asm_regions`` and the
build all keep taking a base, and a base with features is still a base.

**Every fact a feature declares replaces one**, entry counts included: a table
holds the number of entries the cartridge's code scans, and that is one number
however many patches had a hand in it. A feature that grows a table to 64
entries declares 64 rather than "+37" -- it had to write the new bound into the
game's search code, so it knows the total, and a relative figure would depend on
what it was applied over. Replacement is also what makes applying an
already-present feature a no-op rather than a doubling.

**Two features that change the same fact are refused**, by fact and by name.
Nothing here can know which of them the cartridge ended up with -- they were
applied in some order by asar, and the last writer won -- so the honest answer
is to refuse the pair rather than to pick one. A feature that deliberately
supersedes another says so in :attr:`Feature.conflicts`, which refuses earlier
and with a better message.

**How a feature says what it is, is a format rather than a habit.** Three
fields carry it -- :attr:`Feature.name`, the capability in the words someone
would pick it by; :attr:`Feature.summary`, one line of what it is;
:attr:`Feature.detail`, the paragraph for whoever is deciding whether to turn
it on -- and every other fact a reader gets is *derived* from the declaration
below it. :attr:`Feature.described` assembles the lot into a
:class:`Described`, which is what a dialog, a tooltip or a command line
renders. Nothing writes a description twice, and a new kind of fact reaches
every surface by being added there once. :meth:`Feature.__post_init__`
refuses a declaration that would not render -- an unusable id, a missing
name, a summary punctuated as though it were a sentence -- at the moment it
is written rather than the moment it is shown.

**Three features share one reserved run**, and that is what makes the room in
it fungible: :data:`TRANSLEVEL_REMAP`, :data:`OVERWORLD_TABLES_RELOCATED` and
:data:`STRING_TABLES_RELOCATED` pack into the bank ``Config/ReservedBank.asm``
sets aside, in that order (:data:`RESERVED_RUN`), so text that shrank pays for
an overworld table that grew. Each is switched on by itself, so each declares
its tables **as though it were the only occupant** and says how big a block it
occupies unedited (:attr:`Feature.block_bytes`, declared once in
``SMW/Config/PackedRuns.asm`` and read from it); :func:`applied` moves a
feature's tables past whichever occupants ahead of it the cartridge also has.
That is the whole of what sharing one run costs the reading side, and it is
why the order is a declaration rather than an implementation detail.

**The block is declared once and the shift is derived**, because they are one
fact read two ways and a run's occupants must not be able to disagree about
it -- nor with the assembler, which is why the declaration is the asm's.
:meth:`Feature.shifts_by` is how far this feature's block moves whatever the
run puts behind it -- nothing at all for the run's last occupant, which owes
nobody anything -- and :meth:`Feature.block` is what the block costs the run,
which the Features dialog prices a switch by. Both come out of the one
declaration, so a block declared as a zero because nothing is read past it
would be a run priced as though it were free.

**Seven features are declared** -- the three above; :data:`LEVEL_GRAPHICS`,
:data:`LEVEL_CUSTOM_PALETTES` and :data:`MANAGED_LEVEL_MEMORY`, which share
the *level bank* beside the reserved run (:data:`LEVEL_BANK`,
``Config/LevelBank.asm``): the level graphics' fixed-size rows at its head,
the palettes behind them and shifted by them exactly as the reserved run's
occupants shift one another, the level streams that outgrew the stock level
banks behind those -- with the level number stash the first two read laid
down by the bank in front of all of them, so no occupant's block depends on
which others the cartridge has; and :data:`MANAGED_GRAPHICS_MEMORY`, which packs the
graphics files into the *graphics banks* above both, the last reservation and
the one that grows
upward -- and everything below is the contract they and the next one answer
to: what a feature may claim, what it is checked against, and what happens
when two of them disagree. Every default here is what the code does for a base
nobody applied one to -- a base with no features is the base.
"""

from __future__ import annotations

import re
from collections.abc import Iterable
from dataclasses import dataclass, field, replace

from .asm_defines import block
from .bases import RESERVATION_BANK, DrivenPaths, RomBase, TablePool, TracedCode
from .ram_map import RamMap
from .rom_sizes import ROM_SIZES, RomSize
from .rom_tables import VANILLA_TABLES, RomTable

#: What a feature id may look like. The patch ids that provide them follow the
#: same rules for the same reason -- an id is a token in JSON, in a message and
#: in a filename -- but they are separate namespaces: several patches may
#: provide one feature, and a patch that provides none is the ordinary case.
#: The editor's project-name rule (``shiny_mushroom.project.NAME_PATTERN``)
#: states the same expression for its own reasons; a test on that side pins
#: the two equal rather than one importing the other, so this module's import
#: graph stays its own.
ID_PATTERN = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")

#: How many facts :attr:`Feature.changed_summary` names outright before it
#: counts them instead. Three is what a line of a detail pane holds; the
#: relocation's twenty-three are what it is for.
LISTED_CHANGES = 3


class FeatureError(Exception):
    """A feature that cannot be applied to the base it was asked for."""


@dataclass(frozen=True)
class Detail:
    """One labelled fact about a feature, as a reader is shown it.

    The heading is half the sentence, so the body is a **phrase**: no leading
    capital and no full stop, which is what lets a surface render the pair as
    ``Needs: a 1 MB cartridge or larger`` or lay the heading out beside it.
    """

    #: The word in front of it -- ``Changes``, ``Needs``, ``Built on``.
    heading: str

    #: The fact itself.
    body: str

    def __str__(self) -> str:
        return f"{self.heading}: {self.body}"


@dataclass(frozen=True)
class Described:
    """Everything a reader is told about one feature, in reading order.

    **The one place a presentation surface asks.** The Features dialog's list
    row, its detail pane and its tooltip were each assembling this by hand out
    of whichever fields their author remembered, which is why the tooltip
    named the cartridge a feature needs and the pane did not. A surface now
    renders what it is handed, and a *new* fact about features reaches every
    surface by being added to :attr:`Feature.described` -- once.

    Ordered, because reading order is part of the format: the name, the line
    under it, the paragraph under that, then the labelled facts. A surface
    with room for one line takes :attr:`Described.summary`; one with room for
    a paragraph takes :attr:`lines`.

    Nothing project-specific is here. Whether a feature is *on*, whose switch
    it is and what refuses to move are facts about a project, and this package
    does not know what a project is -- ``shiny_mushroom.features`` adds those
    to what this hands it.
    """

    #: The feature's :attr:`Feature.id`, for a surface that shows it.
    id: str

    #: :attr:`Feature.name`.
    name: str

    #: :attr:`Feature.summary`.
    summary: str

    #: :attr:`Feature.detail`.
    detail: str

    #: The labelled facts, in reading order.
    facts: tuple[Detail, ...]

    @property
    def lines(self) -> tuple[str, ...]:
        """The description as text, one line each, empties dropped.

        The name is **not** among them: a surface that shows this has a title
        of its own to put it in, and a pane repeating the row above it is the
        one thing every hand-rolled version of this got wrong.
        """
        return self._said(self.detail)

    @property
    def brief(self) -> tuple[str, ...]:
        """:attr:`lines` without the paragraph -- what a tooltip has room for.

        The facts stay: they are a line each and they are the half a reader
        hovers to find. Only the prose goes, and the pane behind the hover is
        where that is waiting.
        """
        return self._said("")

    def _said(self, detail: str) -> tuple[str, ...]:
        said = (self.summary, detail, *(str(fact) for fact in self.facts))
        return tuple(line for line in said if line)


@dataclass(frozen=True)
class Feature:
    """One capability, and every fact about a cartridge it changes.

    A field left at its default is a fact the feature **does not touch**, which
    is the common case: a feature that only grows a table moves no code, and
    one that relocates the object loop moves no RAM. Absent is not "unknown" --
    a feature whose effect on a fact has not been established declares nothing
    and the base's answer stands, which is the same stance
    :class:`~smw_tools.bases.DrivenPaths` takes for a path nobody has measured.
    """

    #: Short id, as stored in a project and named by a patch.
    id: str

    #: What it is called wherever a person reads it: a list row, a refusal, a
    #: menu path. ``name`` rather than ``label`` deliberately -- a
    #: :class:`~smw_tools.rom_tables.RomTable`'s ``label`` is an assembler
    #: symbol, and this module spends ``label`` on those.
    #:
    #: Names the **capability**, not the mechanism: what having it lets a
    #: person do, in the words they would use for it. Where the tables went is
    #: :attr:`summary`'s to say and :attr:`tables`' to declare.
    name: str

    #: One line saying what the capability **is** -- not what it moves, which
    #: is the rest of this class and is derived. A phrase a caller punctuates,
    #: so no full stop: see :meth:`__post_init__`.
    summary: str = ""

    #: The paragraph under the line, for a reader deciding whether to turn it
    #: on: what the stock game does instead, what it costs, and what it does
    #: *not* change. Prose, so it ends in a full stop. Optional -- a feature
    #: whose line says the whole of it leaves this empty rather than padding.
    detail: str = ""

    #: Tables this feature moves or adds, by role. Merged over the base's, so
    #: a role it does not name keeps the base's declaration. A *new* role is
    #: how a feature's own table becomes readable: nothing else can introduce
    #: one, since :mod:`rom_tables` describes the stock game.
    tables: dict[str, RomTable] = field(default_factory=dict)

    #: How many entries a table holds, by role, where this feature grew or
    #: shrank one -- the count :mod:`smw_tools.asm_regions` declares as the
    #: table's stock format, replaced. The **whole** number, not the increase;
    #: see the module docstring.
    #:
    #: A table's count is baked into the game's search code
    #: (``docs/smw/overworld.md``), so declaring one is a claim about *both*
    #: halves: the rows are there and the code scans them. A feature that grew
    #: the rows and left the scan alone has not grown the table, and nothing
    #: here can tell the difference -- which is why the count is declared
    #: beside the relocation rather than measured.
    #:
    #: A table that outgrows the run of ROM its fragment assembles into has to
    #: move as well, which is a :attr:`tables` entry in the same feature: the
    #: two travel together and the save prices itself against the new label.
    entry_counts: dict[str, int] = field(default_factory=dict)

    #: Where the feature's cartridge keeps the code the captures trace, when it
    #: moved it -- see :class:`~smw_tools.bases.TracedCode`. The motivating
    #: case for this module: a bank range has no label to resolve through, so a
    #: patch that relocates a sprite GFX routine out of banks ``$01``-``$03``
    #: can only be followed by saying so.
    traced: TracedCode | None = None

    #: Where it keeps work RAM, when it moved it -- a sprite engine with more
    #: slots than vanilla's twelve is the archetype. Whole rather than
    #: per-entry, because a :class:`~smw_tools.ram_map.RamMap` answers by rule
    #: and not by table.
    ram_map: RamMap | None = None

    #: Which of the editor's driven paths still work -- see
    #: :class:`~smw_tools.bases.DrivenPaths`. A feature that hijacks a routine
    #: the editor calls declares what that costs, and an unmeasured path is
    #: declared off rather than left to be discovered.
    driven: DrivenPaths | None = None

    #: The asar defines a **source build** switches this on with, as the
    #: ``(name, value)`` pairs :func:`smw_tools.build.build_rom` takes.
    #:
    #: This is the one provenance a project can choose for itself. A feature
    #: the base is built with, or one an asm patch writes into the cartridge
    #: after the fact, arrives whole and declares nothing here -- there is no
    #: switch to throw, and the way to be without it is to build another base
    #: or to turn the patch off. So an empty tuple is also the answer to "can
    #: this be toggled", which is what :attr:`switchable` says out loud.
    #:
    #: The define lives in the disassembly under ``Config/``, guarded so that
    #: ``--define`` wins, which is what lets one tree assemble both ways.
    defines: tuple[tuple[str, str], ...] = ()

    #: The asar define naming which expansion bank to reserve, for a feature
    #: that reserves a whole one.
    #:
    #: The *name* only. Which bank is free is a fact about the cartridge and is
    #: answered by :attr:`~smw_tools.bases.RomBase.reservation_bank`, so a
    #: feature that named one here would be wrong on every base whose ``$10``
    #: is already spoken for -- ``sa1``, whose pack lands its own code there.
    #: :func:`build_defines` fills the value in from the base it is building.
    #:
    #: The addresses in :attr:`tables` are declared in
    #: :data:`~smw_tools.bases.RESERVATION_BANK`, the bank a plain build
    #: reserves; :func:`applied` moves them to whichever bank the base answers
    #: with. They are the same slots either way -- what the reservation buys is
    #: a run with nothing around it to shift.
    bank_define: str | None = None

    #: How many banks past the base's reservation bank this feature's own
    #: bank sits, for a feature that reserves a whole bank *beside* the
    #: reservation rather than the reservation itself. Zero -- the
    #: reservation bank -- is every :data:`RESERVED_RUN` occupant's answer,
    #: that run being the reservation; the custom level palettes reserve the
    #: next one up, so any combination of the features is collision-free on
    #: every base. :func:`build_defines` adds it to the
    #: base's bank before filling :attr:`bank_define` in, and the
    #: :attr:`tables` declared in the offset bank shift with the base exactly
    #: as the reservation's do -- see :func:`_in_bank`, whose shift is the
    #: same for every bank.
    bank_offset: int = 0

    #: The smallest cartridge this can be built into, as a
    #: :mod:`smw_tools.rom_sizes` id -- ``None`` where the stock 512 KB image
    #: has room for it.
    #:
    #: A feature that relocates data into an expansion bank cannot be
    #: assembled below the size that bank exists at, and the disassembly says
    #: so with an ``error`` rather than letting the image quietly double. This
    #: is the same fact, early enough to grey a row out and to offer the
    #: resize instead of failing the build.
    min_rom_size: str | None = None

    #: The cartridge this feature's expansion bank appears at, where the
    #: feature is built either way -- ``None`` for one that needs no bank, or
    #: whose bank it cannot do without (:attr:`min_rom_size`, which refuses
    #: below it instead).
    #:
    #: The two are alternatives, not a pair: a feature declares whichever
    #: sentence is true of it. A bank it *needs* is a requirement and the size
    #: is not a choice; a bank it can do **without** is room, and the size is
    #: the project's -- the feature is assembled at any size, uses the bank
    #: where the cartridge has one, and packs into what the game's own banks
    #: leave where it has not. :data:`MANAGED_LEVEL_MEMORY` is the second
    #: kind, and the disassembly asks the same question with
    #: ``%SMW_ExpansionBankExists``.
    #:
    #: What such a feature may **not** do is keep anything it must be able to
    #: name in that bank: an address that exists only on the larger cartridge
    #: is no address at all on the smaller one. :data:`MANAGED_LEVEL_MEMORY`
    #: keeps its one table at the top of bank ``$07`` for exactly that reason.
    bank_rom_size: str | None = None

    #: Runs of ROM this feature's fragments share -- see
    #: :class:`~smw_tools.bases.TablePool`. Added to the base's rather than
    #: replacing them: two features that pool different fragments disagree
    #: about nothing. A region named by two pools is refused, because nothing
    #: could then say which run bounds it.
    pools: tuple[TablePool, ...] = ()

    #: Editable regions whose table scan this feature's build bounds by the
    #: fragment's own labels where the stock build reads a literal number of
    #: rows -- :attr:`~smw_tools.bases.RomBase.label_bound_scans`. The rows
    #: then bound the scan: the table grows, and nothing past it is read --
    #: which for the destroyed-tiles scan is also the end of its shipped
    #: over-read into the table after it.
    label_bound_scans: tuple[str, ...] = ()

    #: Bytes this feature's block occupies in its packed run on an
    #: **unedited** cartridge with that run to itself, for an occupant of one
    #: of :data:`PACKED_RUNS` -- the shared reserved run, or the level bank's
    #: packed head. Every occupant declares one and nothing else does, which
    #: :func:`_check_packed_runs` refuses a declaration over.
    #:
    #: A feature declares its own tables as though the run were empty in
    #: front of it, and :func:`applied` moves them past the occupants ahead
    #: of it this cartridge also has. Unedited, because that is what a
    #: declared address is -- a project that reworded a message reads its
    #: build's own symbol file, and every address here is what the cartridge
    #: holds before anyone touched it.
    #:
    #: The whole block, not the rows: the stubs a feature emits beside its
    #: tables take room in the run and move the fragments behind them exactly
    #: as its rows do.
    #:
    #: **Read from the assembler's own declaration**, never restated here:
    #: ``SMW/Config/PackedRuns.asm`` states every block and each occupant
    #: asserts what it emitted against its own figure there, so the number
    #: this side prices a run by is the number the build checks
    #: (:mod:`smw_tools.asm_defines`). The two blocks that are editable data all
    #: through -- the relocated overworld tables and the relocated text --
    #: cannot be asserted, and a build test measures those instead.
    #:
    #: **Read it through :meth:`block` or :meth:`shifts_by`**, never raw: the
    #: first is what the block costs this cartridge's run, the second how far
    #: it moves what the run puts behind it. They are one fact read two ways,
    #: and this is the one place it is written.
    #:
    #: **One figure for every target**, which is safe only because of where the
    #: order puts the occupant it is wrong for: the relocated text is the one
    #: whose length a release decides -- the arcade wording measures ``0xEE3``
    #: against the ``0xF05`` declared for ``U`` -- and it is last, so nothing
    #: is read past it. Nothing may be placed behind the text until this is
    #: per-target, and ``smw/tests/test_reserved_bank.py`` pins that.
    block_bytes: int = 0

    #: Features this one needs under it. Satisfied by the base being built
    #: with one as readily as by another patch providing it.
    requires: tuple[str, ...] = ()

    #: Features this one cannot be combined with. Symmetry is not assumed --
    #: either side naming the other refuses the pair.
    conflicts: tuple[str, ...] = ()

    @property
    def switchable(self) -> bool:
        """Whether a project can turn this on and off itself.

        True exactly when there are :attr:`defines` to throw. Everything else
        is a property of the cartridge that was handed over -- a base built
        with the feature, or a patch that writes it in -- and the way to be
        without one of those is not a switch.
        """
        return bool(self.defines)

    @property
    def needs(self) -> RomSize | None:
        """:attr:`min_rom_size` as a size rather than a name."""
        return None if self.min_rom_size is None else ROM_SIZES[self.min_rom_size]

    @property
    def uses(self) -> RomSize | None:
        """:attr:`bank_rom_size` as a size rather than a name."""
        return None if self.bank_rom_size is None else ROM_SIZES[self.bank_rom_size]

    def shifts_by(self) -> int:
        """How far this feature's block moves the occupants its packed run
        puts **behind** it.

        Its :attr:`block_bytes`, or nothing at all where the run puts nothing
        behind it: a run's last occupant owes nobody anything, and its block
        is never in a shift. Said here rather than declared as a zero
        block, because the block is real either way and the run is priced by
        it.

        A block is one size on every cartridge, which is what makes this a
        question about the run rather than about a cartridge: the one piece
        two occupants ever shared -- the level number stash -- is laid down
        by the level bank in front of all of them
        (``Config/LevelNumberStash.asm``).
        """
        return self.block_bytes if _run_behind(self.id) else 0

    @property
    def changes(self) -> tuple[str, ...]:
        """Every fact this feature replaces, named the way a refusal says it.

        One entry per table role rather than one for "tables": two features may
        move different tables without disagreeing about anything, and only the
        roles they share are a conflict.
        """
        named = [f"the {role} table" for role in sorted(self.tables)]
        named += [f"the {role} entry count" for role in sorted(self.entry_counts)]
        named += [
            f"the {region} scan bound" for region in sorted(self.label_bound_scans)
        ]
        if self.traced is not None:
            named.append("the traced code ranges")
        if self.ram_map is not None:
            named.append("the RAM map")
        if self.driven is not None:
            named.append("the driven paths")
        return tuple(named)

    @property
    def changed_summary(self) -> str:
        """:attr:`changes` as one line for a reader.

        The same facts, counted rather than named once there are more of them
        than a line holds: the relocation replaces twenty-three, and a list of
        that many role ids is a wall nobody reads to the end of. A refusal
        still names the one fact two features disagree about, which is where
        the role id earns being spelled out.
        """
        if len(self.changes) <= LISTED_CHANGES:
            return ", ".join(self.changes)
        counted = [
            said
            for said in (
                _counted(len(self.tables), "table"),
                _counted(len(self.entry_counts), "entry count"),
                _counted(len(self.label_bound_scans), "scan bound"),
            )
            if said
        ]
        counted += [
            said
            for said, moved in (
                ("the traced code ranges", self.traced is not None),
                ("the RAM map", self.ram_map is not None),
                ("the driven paths", self.driven is not None),
            )
            if moved
        ]
        return ", ".join(counted)

    @property
    def described(self) -> Described:
        """This feature as a reader is shown it -- see :class:`Described`.

        Every fact here is derived from the declaration above, so a feature
        earns its whole description by being declared: there is no second
        place to write one, and none to forget.
        """
        wanted = self.needs
        needs = "" if wanted is None else f"a {wanted.label} cartridge or larger"
        room = self.uses
        uses = (
            ""
            if room is None
            else f"an expansion bank on a {room.label} cartridge or larger, "
            f"and what the game's own banks leave on a smaller one"
        )
        facts = [
            Detail(heading, body)
            for heading, body in (
                ("Changes", self.changed_summary),
                ("Needs", needs),
                ("Uses", uses),
                ("Built on", _named(self.requires)),
                ("Conflicts with", _named(self.conflicts)),
            )
            if body
        ]
        return Described(
            id=self.id,
            name=self.name,
            summary=self.summary,
            detail=self.detail,
            facts=tuple(facts),
        )

    def __post_init__(self) -> None:
        """Refuse a declaration nothing could show properly.

        Checked here rather than by a test over the registry, because a
        feature is declared by whoever adds one -- in this module, in a test
        fixture, or one day in a plugin -- and the contract has to hold
        wherever that is. The wording rules are the ones a *caller* depends
        on: :attr:`name` and :attr:`summary` are dropped into sentences that
        punctuate them (``f"{summary}. Turning it on..."``), so a full stop
        already on the end is a doubled one on screen.
        """
        if not ID_PATTERN.match(self.id):
            raise FeatureError(
                f"{self.id!r} is not a usable feature id: lowercase letters, "
                f"digits, '-' and '_', starting with a letter or digit"
            )
        if not self.name:
            raise FeatureError(f"{self.id} has no name to show")
        for named, text in (("name", self.name), ("summary", self.summary)):
            if text.endswith("."):
                raise FeatureError(
                    f"{self.id}'s {named} ends in a full stop; it is a phrase "
                    f"a caller punctuates, not a sentence"
                )
        if self.detail and not self.detail.endswith("."):
            raise FeatureError(
                f"{self.id}'s detail is prose and wants a full stop on the end"
            )
        if self.bank_rom_size is not None and self.min_rom_size is not None:
            raise FeatureError(
                f"{self.id} both needs a {self.min_rom_size} cartridge and "
                f"does without one; a bank is a requirement or it is room"
            )


def _named(ids: tuple[str, ...]) -> str:
    """``ids`` as the names a reader knows them by, or nothing for none.

    An id this build does not declare is shown as the id: it reached a
    project or a patch manifest somehow, and a description that dropped it
    would be a shorter lie than one that spells it out.
    """
    return ", ".join(
        FEATURES[held].name if held in FEATURES else held for held in sorted(ids)
    )


def _counted(many: int, noun: str) -> str:
    """``N nouns``, or nothing at all where there are none."""
    return "" if not many else f"{many} {noun}{'' if many == 1 else 's'}"


def _moved(role: str, address: int) -> RomTable:
    """One stock table, at the address a relocated cartridge keeps it.

    Only the address is stated: relocating a table renames nothing, so the role
    and the label are read back off :data:`~smw_tools.rom_tables.VANILLA_TABLES`
    rather than repeated here, and a rename on that side cannot leave a stale
    copy on this one.

    The same address on every target, and no ``per_target`` map. The stock
    addresses differ by release because version conditionals shift the bytes
    around them; a slot in an expansion bank has nothing around it to shift.
    """
    stock = VANILLA_TABLES[role]
    return RomTable(role=role, label=stock.label, address=address)


#: The overworld's tables, moved into an expansion bank.
#:
#: A table's room is the distance to whatever the ROM map placed after it, and
#: for the overworld that distance is nothing -- the Layer 2 event entries fill
#: their 1,484 bytes exactly, and so does every other fragment fill its own run.
#: The cartridge has nowhere to put the overflow either: its own padding totals
#: 27,543 bytes across 46 runs and not one of them adjoins a table this moves.
#: So the tables move to a bank an expanded cartridge adds, where each gets a
#: slot with room after it.
#:
#: Eight of the overworld's eleven editable fragments, twenty-two tables between
#: them -- nine placements, the Layer 2 event pointers and entries being placed
#: separately. The three that stay are named in ``Config/OverworldTableRelocation.asm``
#: with the reason each one is better off where it is. The destroyed-tiles
#: tables move only because the same build binds their scan to the table's
#: labels: the stock scan reads eight entries past the table into whatever
#: follows, so the table could not move alone -- :attr:`label_bound_scans`.
#:
#: **These are where an unedited cartridge keeps them.** The fragments share one
#: run with nothing between, so one that grows pushes the rest along -- and what
#: a project reads them at comes from its own build's symbols, not from here.
#: See :attr:`~smw_tools.rom_tables.RomTable.address`.
#:
#: **And they are in bank $10 because that is the bank a plain build reserves.**
#: Which bank it is belongs to the base -- ``sa1``'s ``$10`` is its pack's, so
#: it reserves ``$11`` -- and :attr:`Feature.bank_define` is how the same number
#: reaches the assembler and the reading side both.
#:
#: **Declared at the run's head, because every occupant declares its addresses
#: as though nothing were in front of it.** They are in fact the run's second
#: occupant, so on a cartridge with the translevel remap as well every address
#: here is 218 bytes further on --
#: which :func:`applied` works out from :data:`RESERVED_RUN` rather than
#: leaving it to be discovered.
#:
#: **No entry count is declared**, which is the honest reading rather than an
#: omission: the scans are still the shipped ones, so the cartridge holds the
#: same twenty-seven warps and fourteen exits it always did. Raising one means
#: changing the code that searches it, is a feature of its own -- see the note on
#: :attr:`Feature.entry_counts` -- and *that* feature declares where it pushed
#: the fragments above it to. The tables whose scans follow their rows (the
#: silent tiles, the Layer 1 swap pairs, the warps and the path exits,
#: :mod:`smw_tools.asm_regions`' ``growable`` regions -- and, on this build,
#: the destroyed tiles) declare nothing here for the opposite reason: their
#: count is whatever the fragment holds, and the relocation is what gives it
#: room to be more.
OVERWORLD_TABLES_RELOCATED = Feature(
    id="overworld-tables-relocated",
    name="Growable overworld tables",
    summary="Room to add overworld warps, events, paths and exits",
    detail="Without it every overworld table is packed to the byte and none "
    "can gain a row. Here they share one run and grow into whatever the "
    "others leave.",
    defines=(("Define_SMW_RelocateOverworldTables", "1"),),
    bank_define="Define_SMW_ReservedBank",
    min_rom_size="1mb",
    # The eight fragments and the divider table, from the run's head to the
    # first byte the next occupant may have.
    block_bytes=block("RelocatedOverworldTables"),
    # The destroyed-tiles scan, bound to the table's own labels on this build:
    # the shipped over-read ends, and the table can move and grow.
    label_bound_scans=("overworld.destroyed_tiles",),
    # The shared run, bounded by the labels the reservation emits. What any
    # occupant does not use, the others may -- see
    # :class:`~smw_tools.bases.TablePool` and ``docs/smw/table-relocation.md``.
    pools=(
        TablePool(
            start_label="SMW_ReservedBankStart",
            end_label="SMW_ReservedBankEnd",
            # The Layer 2 divider table is placed in this run and is nobody's
            # fragment: two bytes an entry, including the shared end marker.
            reserved=2 * 0x79,
            regions=(
                "overworld.star_pipe_warps",
                "overworld.path_exits",
                "overworld.walk_directions",
                "overworld.event_tile_locations",
                "overworld.event_tile_swaps",
                "overworld.layer2_events",
                "overworld.destroyed_tiles",
                "overworld.silent_tiles",
            ),
        ),
    ),
    tables={
        table.role: table
        for table in (
            _moved("overworld_warp_trigger_columns", 0x108008),
            _moved("overworld_warp_trigger_rows", 0x10803E),
            _moved("overworld_warp_landings_x", 0x108074),
            _moved("overworld_warp_landings_y", 0x1080AA),
            _moved("overworld_exit_triggers", 0x1080E0),
            _moved("overworld_exit_landings", 0x108126),
            _moved("overworld_exit_landing_cells", 0x10816C),
            _moved("overworld_level_directions", 0x108188),
            _moved("overworld_event_layer1_locations", 0x1081F9),
            _moved("overworld_event_layer1_from", 0x1082D9),
            _moved("overworld_event_layer1_to", 0x1082EF),
            _moved("overworld_event_tile_entries", 0x108305),
            _moved("overworld_event_pointers", 0x1088D1),
            _moved("overworld_destroy_before", 0x1089C3),
            _moved("overworld_destroy_top", 0x1089C8),
            _moved("overworld_destroy_bottom", 0x1089CD),
            _moved("overworld_destroy_locations", 0x1089D2),
            _moved("overworld_destroy_events", 0x1089F2),
            _moved("overworld_silent_tiles", 0x108A02),
            _moved("overworld_silent_layers", 0x108A2E),
            _moved("overworld_silent_locations", 0x108A5A),
            _moved("overworld_silent_tile_numbers", 0x108AB2),
        )
    },
)


#: Which level number each overworld tile loads, as a table instead of
#: arithmetic.
#:
#: The stock game stores nothing per tile: the overworld scan hands out
#: translevels positionally, and ``SMW_SpecifySublevelToLoad`` *computes* the
#: level number from the translevel -- minus ``$24`` past the main map's
#: range, plus ``$100`` on a submap -- so which level a tile loads is a
#: function of its position among the map's level tiles and nothing else
#: (``docs/smw/overworld.md``). Under this feature the computation for the
#: overworld-tile path is a table lookup instead, one word per translevel,
#: and remapping a tile's level is editing its row. The intro-override path
#: through the same routine keeps the arithmetic: its values are not scan
#: translevels and the table does not speak for them.
#:
#: Translevels themselves stay derived -- every per-translevel table (the
#: names, the events, the walks, the save flags) is indexed as it always was,
#: and the editor's translevel machinery holds. Only the last hop moves.
#:
#: The table is the first occupant of the run the growable features share
#: (:data:`RESERVED_RUN`), placed from the head of each ROM map before
#: anything else emits into it (``Config/TranslevelRemap.asm``). The head is
#: its place because its rows are the one count in that run a project cannot
#: change -- one word per translevel -- so it gains nothing from the growing
#: end and everything behind it is spared knowing whether it is there. The
#: pool declared here names the same run by the same labels, which
#: :func:`applied` merges into one, so a save of any fragment in the bank is
#: priced against all of them. The declared address is the unedited
#: cartridge's, like every address above.
#:
#: The stock rows reproduce the arithmetic for the shipped tilemap --
#: translevels ``$01``-``$24`` are levels ``$001``-``$024``, ``$25``-``$5C``
#: are ``$101``-``$138`` -- so the feature with an unedited table loads
#: exactly what the arithmetic loads. Rows ``$5D``-``$5F`` continue the
#: submap pattern and row ``$00`` is zero: no tile scans to translevel zero.
TRANSLEVEL_REMAP = Feature(
    id="translevel-remap",
    name="Per-tile level numbers",
    summary="Each overworld tile names the level it loads",
    detail="Without it a tile loads the level its place on the map spells. "
    "The table ships holding exactly that, so nothing changes until a tile "
    "is remapped.",
    defines=(("Define_SMW_TranslevelRemap", "1"),),
    # The same bank define as the rest of the run, deliberately: build_defines
    # tolerates two features naming one define at one value.
    bank_define="Define_SMW_ReservedBank",
    min_rom_size="1mb",
    # The 26-byte lookup stub and the 96 rows behind it.
    block_bytes=block("TranslevelRemap"),
    tables={
        "overworld_translevel_levels": RomTable(
            role="overworld_translevel_levels",
            label="SMW_TranslevelRemap_LevelNumbers",
            address=0x108022,
        )
    },
    pools=(
        TablePool(
            start_label="SMW_ReservedBankStart",
            end_label="SMW_ReservedBankEnd",
            # The 26-byte lookup stub emitted beside the table -- code,
            # nobody's rows, declared the way the relocation declares the
            # divider table.
            reserved=26,
            regions=("overworld.translevel_levels",),
        ),
    ),
)


#: A level's own graphics files, one row of eight per level number in the
#: level bank, laid over what its tilesets would load.
#:
#: A stock build decides a level's eight graphics files from two header
#: fields, each a tileset number indexing a 26-row list in
#: ``SMW_UploadGraphicsFiles`` -- so a level loads one of sixteen fixed
#: combinations per list, all of stock files. Under this feature a level may
#: carry a row of eight file numbers of its own, one per VRAM slot in the
#: order FG1, FG2, BG1, FG3, SP1, SP2, SP3, SP4, ``$FF`` keeping the tileset's
#: file for that slot; two same-size hooks where the uploader reads the two
#: lists lay the loading level's row over the four files each list gave
#: (``Config/LevelGraphics.asm``). The level number is the word the feature
#: stashes at every sublevel load, shared with the custom level palettes
#: (``Config/LevelNumberStash.asm``). The header's tilesets keep deciding
#: everything else -- Map16 pages, object set, behaviour -- and an added file
#: (:data:`MANAGED_GRAPHICS_MEMORY`) becomes loadable by being named here,
#: though the feature needs nothing else: a level may remix stock files on a
#: cartridge without it.
#:
#: The rows are the **first packed occupant of the level bank**
#: (:data:`LEVEL_BANK`, ``Config/LevelBank.asm``): ``$200`` rows of eight
#: bytes at the packed head, then the stubs, one block of
#: :attr:`Feature.block_bytes` whatever else the cartridge has -- which is
#: what the custom level palettes behind it are shifted by when both are on,
#: and what :func:`applied` works out. The level number stash the rows are
#: indexed by is not in that block: the bank lays it down in front of every
#: occupant (``Config/LevelNumberStash.asm``). The rows are the
#: fragment ``graphics/levels/level-graphics.asm`` the editor regenerates
#: (:mod:`smw_tools.level_graphics` is its grammar), shipped naming no level,
#: so the feature with an unedited table loads exactly what the stock
#: cartridge loads.
LEVEL_GRAPHICS = Feature(
    id="level-graphics",
    name="Per-level graphics",
    summary="A level names its own graphics files, slot by slot, over its "
    "tilesets' -- and its own animated tiles",
    detail="Without it a level's eight graphics files come from its two "
    "tilesets and nothing else, and its animated tiles are the one set every "
    "level shares. A level set here takes the file it names in each slot and "
    "the tileset's in the rest -- the only way an added graphics file is "
    "loaded -- and the animated tiles it names, which needs the growable "
    "graphics for a file of that shape. Tilesets still decide Map16 pages, "
    "objects and behaviour.",
    defines=(("Define_SMW_LevelGraphics", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    min_rom_size="1mb",
    block_bytes=block("LevelGraphics"),
    tables={
        "level_graphics_rows": RomTable(
            role="level_graphics_rows",
            label="SMW_LevelGraphics_Rows",
            address=0x118011,
        )
    },
)


#: A palette a level wears whole, instead of the shared tables.
#:
#: The stock game assembles every level's colours out of the global tables by
#: header setting (``SMW_BufferPalettesRoutines_Levels``), so recolouring a
#: setting recolours every level that picks it. Under this feature a level may
#: carry a 514-byte blob of its own -- its back area colour, then the whole
#: palette mirror -- copied over what the stock buffering built, at the two
#: seams Lunar Magic marks for its own version of the capability
#: (``Config/LevelCustomPalettes.asm``).
#:
#: The pointer table and the blobs go in the **level bank**
#: (``Config/LevelBank.asm``), a whole expansion bank **one past the
#: base's reservation bank** -- ``$11`` on a plain build, ``$12`` on ``sa1``,
#: whose pack holds ``$10`` and whose relocated tables hold ``$11`` -- which
#: is what :attr:`Feature.bank_offset` says. Fixed and distinct from the
#: relocation's bank on every base, so any combination of the features is
#: collision-free, and independent of the relocation: neither requires the
#: other. The bank's other occupants are :data:`LEVEL_GRAPHICS`, whose
#: fixed-size block goes in front of the table when that feature is on, and
#: :data:`MANAGED_LEVEL_MEMORY`, which packs level streams behind the blobs;
#: :data:`LEVEL_BANK` is the order.
#:
#: The pointer table sits at the run's head -- or the level graphics' block
#: behind it, which :func:`applied` works out -- so its address is declared
#: the way every relocated table's is: as though nothing were in front of it.
#: The blobs after the stubs are named by its rows and read through the
#: build's own symbol file, like any grown fragment. The editor regenerates
#: both fragments from the project's saved palettes
#: (``shiny_mushroom.level_palettes``), and the shipped rows are all zero --
#: the feature with an unedited table loads exactly what the stock cartridge
#: loads.
#:
#: **Its block is the head**: the pointer table and the stubs, up to the
#: first blob. Being the packed head's last occupant it shifts nothing, but
#: the block is real and the bank is priced by it -- which is exactly the
#: case a zero block would get wrong.
LEVEL_CUSTOM_PALETTES = Feature(
    id="level-custom-palettes",
    name="Custom level palettes",
    summary="A level can wear a palette of its own, over the shared colours",
    detail="Without it every level's colours come from shared tables, so "
    "recolouring one setting recolours every level that uses it. A level "
    "dressed here changes alone. Room for 60 palettes, fewer where the "
    "per-level graphics lead the same bank or growable levels have "
    "overflowed into it.",
    defines=(("Define_SMW_LevelCustomPalettes", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    min_rom_size="1mb",
    # The pointer table -- three bytes a level -- and the stubs the config
    # budgets, from the run's head to the first blob.
    block_bytes=block("LevelCustomPalettes"),
    tables={
        "level_palette_pointers": RomTable(
            role="level_palette_pointers",
            label="SMW_LevelCustomPalettes_Pointers",
            address=0x118011,
        )
    },
)


def _moved_text(role: str, address: int) -> RomTable:
    """:func:`_moved`, keeping the stock declaration's absent targets: a text
    table the Japanese build assembles in its own format is absent from the
    relocated cartridge for the same reason it is absent from the stock one."""
    stock = VANILLA_TABLES[role]
    return RomTable(
        role=role,
        label=stock.label,
        address=address,
        absent_targets=stock.absent_targets,
    )


#: Where the relocated text lands with nothing in front of it: the stubs at
#: the head of the shared reserved run, then the level-name tables out of
#: bank $04 and the message tables out of bank $05, packed --
#: ``Config/StringTableRelocation.asm``.
#:
#: The text is the run's **last** occupant, so on a cartridge that also has
#: the translevel remap or the relocated overworld tables every address below
#: is that much further on, which :func:`applied` works out from
#: :data:`RESERVED_RUN`. Last is the place for it: the block's length is the
#: one in that run a release decides, and behind it there is nothing for that
#: to move.
_STRINGS_RUN = 0x108008 + 0x144

STRING_TABLES_RELOCATED = Feature(
    id="string-tables-relocated",
    name="Growable strings",
    summary="Room to lengthen message boxes and level names",
    detail="Without it the messages and the level-name parts are packed to "
    "the byte, so one grows only by what another shrank. Here they share one "
    "run and grow into whatever the others leave.",
    defines=(("Define_SMW_RelocateStringTables", "1"),),
    # The same bank define as the run's other occupants: one reservation, and
    # build_defines tolerates two features naming one define at one value.
    bank_define="Define_SMW_ReservedBank",
    min_rom_size="1mb",
    # The stubs, both sets of tables and what the assembler derives beside
    # them -- the whole block, as the run's last occupant leaves it.
    block_bytes=block("RelocatedStrings"),
    # The relocated search takes the slot tables' own length, and the two
    # state-picked pointers sit past the level slots wherever they end: the
    # slots and the messages may be added to and taken from on this build.
    label_bound_scans=("strings.level_messages",),
    # The shared run, named by the same labels as its other occupants, which
    # applied() merges into one. Three things this feature puts in it are
    # nobody's fragment: the three stubs (324 bytes), the message lines' VRAM
    # positions (16) and the three name offset tables (118), the last two
    # derived by the assembler from the strings' labels.
    pools=(
        TablePool(
            start_label="SMW_ReservedBankStart",
            end_label="SMW_ReservedBankEnd",
            reserved=0x144 + 16 + 2 * (31 + 15 + 13),
            regions=("strings.level_names", "strings.level_messages"),
        ),
    ),
    tables={
        table.role: table
        for table in (
            _moved_text("overworld_level_name_strings", _STRINGS_RUN),
            _moved_text("overworld_level_name_part1", _STRINGS_RUN + 460),
            _moved_text("overworld_level_name_part2", _STRINGS_RUN + 460 + 62),
            _moved_text("overworld_level_name_part3", _STRINGS_RUN + 460 + 62 + 30),
            _moved_text("level_message_levels", _STRINGS_RUN + 578 + 16),
            _moved_text("level_message_pointers", _STRINGS_RUN + 578 + 16 + 23),
            _moved_text("level_message_text", _STRINGS_RUN + 578 + 16 + 23 + 50),
        )
    },
)


#: The level banks packed end to end and overflowing into the level bank, so
#: a level grows into whatever the others leave -- and the room the project's
#: own level files take.
#:
#: A stock build inserts the level streams through seven bank macros in banks
#: ``$06`` and ``$07``, each placed at a literal address and packed to the
#: byte against the padding after it, so a level's room is its macro's and
#: the 8,991 bytes of padding the two banks hold are room for nothing.
#: Under this feature the streams are emitted back to back in ROM-map order
#: into three runs -- bank ``$06`` whole, bank ``$07`` up to its sprite
#: routines, and that bank's tail -- with a stream that reaches the end of a
#: run placed at the start of the next, and every pointer-table row recomputed
#: from the labels (``Config/ManagedLevelMemory.asm``). A cartridge of
#: :attr:`~Feature.bank_rom_size` or larger adds a fourth: the *level bank*
#: behind the custom level palettes' blobs (:data:`LEVEL_BANK`,
#: ``Config/LevelBank.asm``), which nothing reaches until the two stock banks
#: are full. **The bank is room rather than a requirement** -- on a 512 KB
#: cartridge the feature is built all the same, and what it buys there is the
#: padding those two banks hold, made fungible across every level.
#:
#: Two same-size hooks in the loader supply what the packing takes away: each
#: sprite list's bank, read off a table of one byte per level in place of the
#: hardcoded ``$07``, and each Chocolate Island 2 sub-level's bank.
#:
#: The containers a project *adds* are packed after the banks' own streams,
#: out of an editor-regenerated fragment (``levels/added/added-levels.asm``)
#: under the labels the pointer tables name, so adding a level file needs
#: this feature and nothing else -- no freespace, no reservation of its own.
#: Room for them is what the runs have left and what a *deleted* level gives
#: back: a stream the project deletes (``levels/deleted-levels.asm``) is
#: inserted as the empty level under its own label, which holds on a stock
#: build too.
#:
#: **No stream has an address to declare.** They are read where the
#: assembler put them, through the pointer tables and the build's own symbol
#: file, exactly as on a stock cartridge; what changes is where a save is
#: priced -- :func:`smw_tools.levels.pack` is the packer's own arithmetic --
#: and the editor reads that off the feature's presence. The one table
#: declared is the sprite-bank table at the **fixed tail**, the ``$200``
#: bytes below the end of bank ``$07``: the same slot on every cartridge and
#: every base, which is what lets SA-1 Pack's patch pass read the bank of
#: every sprite list off it by address, after this source has assembled and
#: before any symbol of ours is in reach. In one of the game's own banks
#: rather than in the expansion bank, because that bank is room this feature
#: may not have and an address only the larger cartridge has is no address at
#: all -- it is the one thing :attr:`~Feature.bank_rom_size` forbids.
MANAGED_LEVEL_MEMORY = Feature(
    id="managed-level-memory",
    name="Growable levels",
    summary="Room for levels to grow, and for levels the project adds",
    detail="Without it the levels are packed to the byte in fixed groups, so "
    "an object added to one is paid for by another in the same group. Here "
    "the levels are one sequence packed into whatever the two level banks "
    "leave, and added levels pack after the game's own. A 1 MB cartridge "
    "gives that sequence an expansion bank to overflow into as well. Nothing "
    "moves until a level grows.",
    defines=(("Define_SMW_ManagedLevelMemory", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    bank_rom_size="1mb",
    tables={
        "level_sprite_banks": RomTable(
            role="level_sprite_banks",
            label="SMW_ManagedLevelMemory_SpriteBanks",
            address=0x07FE00,
        )
    },
)


#: The graphics files packed end to end and overflowing into the graphics
#: banks, so a redrawn file grows into whatever the others leave, files can
#: be added up to ``$FE``, and an added file can be 4bpp.
#:
#: A stock build inserts the 52 compressed graphics files through one bank
#: macro in banks ``$08``-``$0B``, packed to the byte against the fitted
#: padding behind it, and reads them through three fifty-row pointer tables
#: in bank ``$00``, a bank packed to the byte -- so a file's room is what the
#: others leave and no file can be added at all. Under this feature the
#: placement is a sequence (``Config/ManagedGraphicsMemory.asm``): the files
#: are emitted back to back into runs -- the stock four banks whole, then
#: the *graphics banks* (``Config/GraphicsBank.asm``), one run each -- a file
#: that reaches the end of a run placed at the start of the next, every
#: label following its file. The files a project *adds* are packed after the
#: game's own out of an editor-regenerated fragment
#: (``graphics/added/added-graphics.asm``), and their formats out of another
#: (``graphics/added/formats.asm``).
#:
#: Two same-size hooks in bank ``$00``, both inside the stretch SA-1 Pack
#: leaves alone, read the fixed head of the first graphics bank: the
#: decompressor takes every file's pointer off a 256-row table there in
#: place of the stock tables, and the uploader reads a format byte per file
#: and copies a 4bpp file to VRAM whole in place of the 3bpp expansion.
#: The upload cache's "no file" sentinel becomes ``$FF`` so that ``$80`` is a
#: file. **No stream has an address to declare**: they are read where the
#: assembler put them, through the pointer table and the build's own symbol
#: file, and :func:`smw_tools.graphics_memory.pack` is the packer's own
#: arithmetic for pricing a save. The two tables declared are the head's.
#:
#: The graphics banks are **two past the base's reservation bank** -- one
#: past the level bank; ``$12`` on a plain build, ``$13`` on ``sa1`` -- which
#: is what :attr:`Feature.bank_offset` says, and how many the run takes is a
#: build define beside the bank's (``Define_SMW_GraphicsBankCount``,
#: :func:`smw_tools.graphics_memory.bank_count_define`), not a fact declared
#: here: the count is the project's, and :func:`smw_tools.graphics_memory.rom_size_for`
#: is the cartridge it needs. Graphics is the **last** reservation, because
#: it is the one with an unbounded appetite: nothing may ever reserve above
#: it, and a future fixed-appetite feature reserves below and bumps its
#: bank. One bank needs the 1 MB cartridge the feature declares; a count
#: that runs past bank ``$1F`` needs more, which the size function says.
MANAGED_GRAPHICS_MEMORY = Feature(
    id="managed-graphics-memory",
    name="Growable graphics",
    summary="Room for graphics files to grow, and for files the project "
    "adds, 4bpp included",
    detail="Without it the 52 graphics files fill four banks to the byte and "
    "none can be added. Here they are one sequence that overflows into as "
    "many expansion banks as the project asks for, and files up to $FE can "
    "be added, each 3bpp or 4bpp. Nothing moves until a file grows.",
    defines=(("Define_SMW_ManagedGraphicsMemory", "1"),),
    bank_define="Define_SMW_GraphicsBank",
    bank_offset=2,
    min_rom_size="1mb",
    tables={
        "graphics_pointers": RomTable(
            role="graphics_pointers",
            label="SMW_ManagedGraphics_Pointers",
            address=0x128008,
        ),
        "graphics_formats": RomTable(
            role="graphics_formats",
            label="SMW_ManagedGraphics_Formats",
            address=0x128308,
        ),
    },
)


#: **Per-level code**: a level runs 65816 of its own, once a frame, called
#: from the fork every running level frame passes through
#: (``Config/LevelCode.asm``). The level number is the word the load stashed,
#: shared with the per-level graphics and the custom level palettes
#: (``Config/LevelNumberStash.asm``).
#:
#: **Four entry points**, in the order a level reaches them: ``load``
#: before its objects are drawn -- which is what makes writing the Map16
#: table possible at all -- ``init`` once it is prepared, ``main`` once a
#: frame while it runs, and ``nmi`` in the VBlank handler's own time. One
#: table each, so a level may have any of the four and pay for none of the
#: others.
#:
#: The tables are the level bank's **second packed occupant**
#: (:data:`LEVEL_BANK`): four ``$200``-row tables of two bytes behind the
#: per-level graphics' block, then the dispatch and the entry stubs, then the
#: levels' own routines. Words rather than long pointers because every
#: routine is in this one bank, so the bank byte is known when the tables are
#: assembled; the dispatch builds the long pointer from the row and the bank
#: define. A zero row is a level that runs nothing at that moment, which is
#: every row as shipped.
#:
#: **In front of the palettes, not behind them.** The palettes' blobs are the
#: packed head's growing end, so nothing may declare an address past them --
#: which is what fixes this occupant's place rather than leaving it to taste.
LEVEL_CODE = Feature(
    id="level-code",
    name="Per-level code",
    summary="A level runs 65816 of its own, as it loads and as it runs",
    detail="Without it a level does only what its header, objects and "
    "sprites say, so two levels wanting different behaviour need different "
    "data. A level given code here can write its own Map16 tiles before its "
    "objects are placed, set itself up once it is prepared, and run every "
    "frame it is on screen -- in a boss room as readily as in an ordinary "
    "level. A level given none runs exactly what the stock cartridge runs.",
    defines=(("Define_SMW_LevelCode", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    min_rom_size="1mb",
    # The four tables and the entry stubs behind them, from the occupant's
    # head to the first level's own routine.
    block_bytes=block("LevelCode"),
    tables={
        f"level_code_{when}_rows": RomTable(
            role=f"level_code_{when}_rows",
            label=f"SMW_LevelCode_{when.capitalize()}Rows",
            address=0x118011 + index * 0x400,
        )
        for index, when in enumerate(("load", "init", "main", "nmi"))
    },
)


#: **UberASM Tool compatibility**: the defines a routine written for that
#: tool expects, and a shared library it may call into
#: (``Config/UberASM.asm``). Switched apart from the features that say a
#: project *has* code, because one writing its own in this source's idiom
#: wants neither -- and would rather not have ``!addr`` and ``!14C8``
#: defined over its head. It names none of them in
#: :attr:`Feature.requires`: any one of the three will do, which that field
#: cannot say, so the assembler is what refuses a cartridge carrying a
#: library nothing can call.
#:
#: **It moves nothing and declares nothing**, which is why it has no block
#: and no tables: the defines emit no bytes, and the library is assembled
#: with the levels' own routines, behind the packed head where nothing
#: declares an address. What it costs is what the library holds -- every
#: file in it, whether a level calls it or not, since nothing can know which
#: labels a routine will reach for.
UBERASM = Feature(
    id="uberasm",
    name="UberASM Tool compatibility",
    summary="A level's code written the way UberASM Tool writes it, and a "
    "library it can call",
    detail="Without it a level's code is written in this disassembly's own "
    "terms. Here it also gets that tool's defines and macros -- !addr, "
    "!sprite_slots, the sprite tables it names after themselves -- so a "
    "routine published for it assembles unchanged, a macro library of the "
    "project's own read once, and a shared library whose files are reached "
    "by filename. Every library file is assembled whether a level calls it "
    "or not.",
    defines=(("Define_SMW_UberASM", "1"),),
)


#: **Per-game-mode code**: a mode runs 65816 of its own around the game's
#: own routine for it (``Config/GameModeCode.asm``): ``init`` on its first
#: frame, ``main`` on every frame after, ``end`` after the game's routine.
#:
#: **It declares no table the editor reads and no block.** Its three
#: mode-indexed tables and the modes' routines sit behind the packed head
#: with the levels' own code, where nothing declares an address, and the
#: hook is the main loop's call to the game mode -- the site the global
#: main routine already displaces -- so nothing is written into the game's
#: own banks and the game's pointer table is untouched.
#:
#: **One byte of RAM**, the mode the last frame ran, decides which frame is
#: a mode's first (``!RAM_SMW_GameModeCode_LastMode``). That is the tool
#: this copies' answer too, and the one that is right for every mode.
GAMEMODE_CODE = Feature(
    id="gamemode-code",
    name="Per-game-mode code",
    summary="A game mode runs 65816 of its own, before the game's",
    detail="Without it a game mode does what the game's own routine does "
    "and nothing else. A mode given code here runs it on the mode's first "
    "frame, on every frame after, or after the game's own routine each "
    "frame -- and a routine can be given to every mode at once. Which frame "
    "is a mode's first is one byte of RAM the stock game never touches, "
    "$7E010F, holding the last frame's mode; a patch that takes the same "
    "byte makes a mode's first frame every frame, or none.",
    defines=(("Define_SMW_GameModeCode", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    min_rom_size="1mb",
)


#: **Global and status bar code**: the tool's ``global:`` and ``statusbar:``
#: tags, which belong to no level and no game mode
#: (``Config/GlobalCode.asm``). Three entry points, none dispatched through
#: anything -- there is one of each, so there is nothing to index.
#:
#: **Its routines return with ``RTS``**, which is that tool's convention for
#: these two tags and the reason they cannot go through the dispatch the
#: levels' and the game modes' code goes through: an ``RTS`` returns within
#: the program bank it was called in, so the call is made from the bank the
#: routine is in. The stubs exist for exactly that.
#:
#: **A hook is only planted if the project wrote that entry point.** The
#: fragment naming them is read with the defines rather than with the code,
#: so each hook in ``Banks/`` asks whether its own is there -- a project with
#: only status bar code has no frame hook at all, not a branch and not a
#: byte. The tool this copies installs every hook always, having no way to
#: know what will be added after it has run. The frame hook is shared with
#: the game modes' code, which wants it whatever the project wrote.
#:
#: No tables and no block: one routine per entry point, placed behind the
#: packed head with the levels' own code.
GLOBAL_CODE = Feature(
    id="global-code",
    name="Global and status bar code",
    summary="Code that runs every frame, at boot, or when the status bar is "
    "drawn",
    detail="Without it a project's own code belongs to a level or a game "
    "mode. Here it can also run once at boot, every frame whatever the game "
    "is doing, and when the status bar's counters are drawn. Each entry "
    "point costs nothing until it is written: the hook for one nobody wrote "
    "is not assembled.",
    defines=(("Define_SMW_GlobalCode", "1"),),
    bank_define="Define_SMW_LevelBank",
    bank_offset=1,
    min_rom_size="1mb",
)


#: The occupants of the level bank, in the order it holds them: the level
#: graphics' fixed-size block at its head, the palettes behind it, and the
#: packed level streams behind those, up to the managed level banks' fixed
#: tail. All three share one bank define and one offset from the
#: reservation bank.
#:
#: The first two pack from the head and are :data:`LEVEL_BANK_HEAD`: the
#: graphics declare their length and the palettes are read that much
#: further on when both are on, exactly as :data:`RESERVED_RUN`'s occupants
#: shift one another. The streams are the bank's last occupant and declare
#: nothing but the tail's table, which is fixed to the bank's end and
#: shifts for nothing -- so they are in the order and not in the packed
#: head.
LEVEL_BANK: tuple[str, ...] = (
    LEVEL_GRAPHICS.id,
    LEVEL_CODE.id,
    LEVEL_CUSTOM_PALETTES.id,
    MANAGED_LEVEL_MEMORY.id,
)

#: The level bank's occupants whose declared addresses shift by what is in
#: front of them -- see :data:`LEVEL_BANK`.
LEVEL_BANK_HEAD: tuple[str, ...] = LEVEL_BANK[:3]


#: The occupants of the shared reserved run, in the order the ROM map emits
#: them -- ``Config/ReservedBank.asm``'s list, restated here because the
#: reading side needs it too.
#:
#: **The order is a fact, not a convenience.** Each of the three is switched
#: on by itself, so each declares its tables as though the run were empty in
#: front of it, and what an occupant is actually read at is that plus the
#: :meth:`Feature.shifts_by` of whichever occupants ahead of it the cartridge
#: also has -- which is what :func:`applied` works out. The assembler is told
#: the same thing by where each placement is called from, and a build test
#: holds the two equal.
#:
#: Fixed rather than derived, and in this order for two reasons that belong to
#: the ends of it: the translevel remap table leads because its row count is
#: the one in the run a project cannot change, and the text trails because its
#: length is the one a release decides.
RESERVED_RUN: tuple[str, ...] = (
    TRANSLEVEL_REMAP.id,
    OVERWORLD_TABLES_RELOCATED.id,
    STRING_TABLES_RELOCATED.id,
)

#: Every run whose occupants are read past the blocks of whichever occupants
#: ahead of them the cartridge has: the shared reserved run, and the level
#: bank's packed head. A feature is in at most one, occupies a block in it
#: (:attr:`Feature.block_bytes`) and is in no run without one, which
#: :func:`_check_packed_runs` refuses a declaration over.
PACKED_RUNS: tuple[tuple[str, ...], ...] = (RESERVED_RUN, LEVEL_BANK_HEAD)


#: Every feature this build knows, by id. An id a project names and this
#: registry does not have is refused rather than ignored -- see :func:`applied`
#: -- because reading a cartridge through the wrong facts is the failure this
#: module exists to prevent.
#:
#: **The order is the order a reader is shown them**, and nothing else -- where
#: a feature's data lands is :data:`RESERVED_RUN` and :data:`LEVEL_BANK`, which
#: say so themselves. The four that buy room to grow lead, because that is the
#: question someone opening the Features dialog is usually asking; the ones
#: that add a per-level or per-tile choice follow.
FEATURES: dict[str, Feature] = {
    OVERWORLD_TABLES_RELOCATED.id: OVERWORLD_TABLES_RELOCATED,
    STRING_TABLES_RELOCATED.id: STRING_TABLES_RELOCATED,
    MANAGED_LEVEL_MEMORY.id: MANAGED_LEVEL_MEMORY,
    MANAGED_GRAPHICS_MEMORY.id: MANAGED_GRAPHICS_MEMORY,
    TRANSLEVEL_REMAP.id: TRANSLEVEL_REMAP,
    LEVEL_GRAPHICS.id: LEVEL_GRAPHICS,
    LEVEL_CUSTOM_PALETTES.id: LEVEL_CUSTOM_PALETTES,
    LEVEL_CODE.id: LEVEL_CODE,
    GAMEMODE_CODE.id: GAMEMODE_CODE,
    GLOBAL_CODE.id: GLOBAL_CODE,
    UBERASM.id: UBERASM,
}


def feature(feature_id: str) -> Feature:
    """One feature by id, or :class:`FeatureError` naming the ones there are."""
    try:
        return FEATURES[feature_id]
    except KeyError:
        known = ", ".join(sorted(FEATURES)) or "none -- this build declares no features"
        raise FeatureError(
            f'no feature "{feature_id}" -- this build knows {known}'
        ) from None


def build_defines(
    ids: Iterable[str], base: RomBase | None = None
) -> tuple[tuple[str, str], ...]:
    """The asar defines that switch ``ids`` on, in the order they were named.

    Only what each feature declares in :attr:`Feature.defines`, so an id that
    arrives with the base or with a patch contributes nothing -- that
    cartridge already has it, and throwing a switch it does not read would be
    a define asar warns about rather than a feature turned on twice.

    ``base`` is the cartridge being built, and the one thing it decides is
    :attr:`Feature.bank_define`: a feature that reserves an expansion bank is
    told which one by the base rather than choosing. Left out, the answer is
    the bank a plain build reserves, which is every base but ``sa1``.

    A name two features both define is refused: the two would be handed to the
    assembler in some order and the last would win, which is the same argument
    :func:`applied` makes about two features changing one fact.
    """
    bank = RESERVATION_BANK if base is None else base.reservation_bank
    out: dict[str, tuple[str, str]] = {}
    owner: dict[str, str] = {}
    for feature_id in dict.fromkeys(ids):
        found = feature(feature_id)
        declared = found.defines
        if found.bank_define is not None:
            declared += ((found.bank_define, f"${bank + found.bank_offset:02X}"),)
        for name, value in declared:
            first = owner.setdefault(name, found.id)
            if first != found.id and out[name] != (name, value):
                raise FeatureError(
                    f"{first} and {found.id} both define {name}, and only one "
                    f"value can reach the assembler"
                )
            out[name] = (name, value)
    return tuple(out.values())


def applied(
    base: RomBase, ids: Iterable[str] = (), rom_size: str | None = None
) -> RomBase:
    """``base`` as amended by ``ids``, or :class:`FeatureError` saying why not.

    The result is a base like any other, carrying the union of what it was
    built with and what was applied in :attr:`~smw_tools.bases.RomBase.features`
    -- so a caller that has one can ask it the same questions, and a caller
    that does not is reading the stock base, which is what it was doing before.

    An id the base is **already** built with is satisfied without being applied
    again: the base's own declarations already describe that cartridge, and
    every fact here replaces rather than accumulates. It still counts for
    another feature's :attr:`~Feature.requires`.

    Order is the caller's, deduplicated. It decides nothing -- two features
    that would disagree are refused rather than resolved -- and is kept only so
    that what a project stores reads back the way it was written.

    **A patched base carries a switched feature like any other.** Its source
    is this tree, so a source define reaches the assemble that produces it --
    :func:`smw_tools.build.build_rom` hands the patch's own defines and the
    build's to the same command line. What differs is where the feature's data
    ends up: the patch runs afterwards and has already taken a bank, so the
    base answers with another and :func:`_in_bank` reads the declarations
    through it. A base *built with* the feature is untouched by any of this: it
    is already satisfied and never fresh.

    **A base built with a reserved-run occupant is declared for, not reached.**
    No base in :mod:`smw_tools.bases` names one in
    :attr:`~smw_tools.bases.RomBase.features` today, so neither the refusal of
    a fresh occupant that packs ahead of a built-in one nor :func:`_in_bank`'s
    shift past a built-in one runs; and the shift reads that occupant's
    declared block, which is its length **unedited**, so a base built with
    rows already grown would need a figure of its own. Apply a cartridge's
    occupants in one call for the same reason: the result carries
    what was applied in ``features``, so a second call adding an occupant in
    front of the first is refused as though the base had shipped with it.

    ``rom_size`` is which of the base's sizes the cartridge **is**, as an id
    into :data:`~smw_tools.rom_sizes.ROM_SIZES` -- what the project building it
    chose. It reaches the result as
    :attr:`~smw_tools.bases.RomBase.built_at`, and it decides where a feature
    that uses an expansion bank *where the cartridge has one* is read
    (:attr:`Feature.bank_rom_size`). ``None`` is the base's stock size, which
    is what a build assembles when nobody has said -- and so is naming that
    size, which leaves the base as it was.
    """
    wanted = tuple(dict.fromkeys(ids))
    if rom_size is not None:
        if rom_size not in ROM_SIZES:
            raise FeatureError(f"no ROM size {rom_size!r}")
        if rom_size not in base.sizes:
            raise FeatureError(
                f"{base.id} cannot be built at {rom_size}; it offers "
                f"{', '.join(base.sizes)}"
            )
        # The stock size is what "nobody has said" already means, so naming it
        # leaves the base alone -- a base nothing was applied to is the base.
        held = None if rom_size == base.stock_size else rom_size
        if held != base.built_at:
            base = replace(base, built_at=held)
    if not wanted:
        return base
    features = [feature(feature_id) for feature_id in wanted]
    present = set(base.features)
    fresh = [found for found in features if found.id not in present]

    held = present | {found.id for found in features}
    for found in features:
        missing = [need for need in found.requires if need not in held]
        if missing:
            raise FeatureError(
                f"{found.id} needs {', '.join(sorted(missing))}, which "
                f"{base.id} has not got"
            )
        against = sorted(held & set(found.conflicts))
        if against:
            raise FeatureError(
                f"{found.id} cannot be combined with {', '.join(against)}"
            )

    claimed: dict[str, str] = {}
    for found in fresh:
        for fact in found.changes:
            first = claimed.setdefault(fact, found.id)
            if first != found.id:
                raise FeatureError(
                    f"{first} and {found.id} both change {fact}, and nothing "
                    f"says which one the cartridge ended up with"
                )

    for found in fresh:
        settled = [one for one in _run_behind(found.id) if one in present]
        if settled:
            raise FeatureError(
                f"{found.id} packs into its run ahead of "
                f"{', '.join(settled)}, which {base.id} was built with -- the "
                f"base says where those landed and this would move them"
            )

    tables = dict(base.tables)
    counts = dict(base.entry_counts)
    pools = list(base.pools)
    pooled = {region for pool in pools for region in pool.regions}
    bound = list(base.label_bound_scans)
    for found in fresh:
        tables.update(_in_bank(found, base, held))
        counts.update(found.entry_counts)
        bound += [region for region in found.label_bound_scans if region not in bound]
        for pool in found.pools:
            clash = sorted(pooled & set(pool.regions))
            if clash:
                raise FeatureError(
                    f"{found.id} pools {', '.join(clash)}, which another run "
                    f"already holds -- nothing says which bounds them"
                )
            pooled |= set(pool.regions)
            # Two pools bounded by the same labels are one run of ROM, so they
            # merge rather than stand side by side: a Run prices its members
            # against the run's total, and two declarations over one run would
            # each be blind to the other's rows. It is what makes the shared
            # reserved run one pool: each of its three occupants declares a
            # pool over the same pair of labels, and every fragment any of them
            # puts there is priced against what all three leave.
            shared = next(
                (
                    index
                    for index, run in enumerate(pools)
                    if (run.start_label, run.end_label)
                    == (pool.start_label, pool.end_label)
                ),
                None,
            )
            if shared is None:
                pools.append(pool)
            else:
                already = pools[shared]
                pools[shared] = replace(
                    already,
                    regions=already.regions + pool.regions,
                    reserved=already.reserved + pool.reserved,
                )
    return replace(
        base,
        tables=tables,
        entry_counts=counts,
        pools=tuple(pools),
        label_bound_scans=tuple(bound),
        traced=_declared(fresh, "traced", base.traced),
        ram_map=_declared(fresh, "ram_map", base.ram_map),
        driven=_declared(fresh, "driven", base.driven),
        features=tuple(dict.fromkeys(base.features + wanted)),
    )


def _run_of(feature_id: str) -> tuple[str, ...]:
    """The one of :data:`PACKED_RUNS` that holds ``feature_id``, or nothing."""
    return next((run for run in PACKED_RUNS if feature_id in run), ())


def _run_behind(feature_id: str) -> tuple[str, ...]:
    """The occupants its packed run puts behind ``feature_id``, if any."""
    run = _run_of(feature_id)
    return run[run.index(feature_id) + 1 :] if run else ()


def _run_ahead(feature_id: str) -> tuple[str, ...]:
    """The occupants its packed run puts in front of ``feature_id``."""
    run = _run_of(feature_id)
    return run[: run.index(feature_id)] if run else ()


def _in_bank(found: Feature, base: RomBase, held: set[str]) -> dict[str, RomTable]:
    """``found``'s tables, read where this cartridge actually keeps them.

    Two shifts, and a feature's declaration is what it would be with neither.

    **The bank.** A feature that reserves a whole expansion bank declares its
    tables in :data:`~smw_tools.bases.RESERVATION_BANK`, because that is the
    bank the disassembly reserves when a build says nothing. A base whose own
    is elsewhere -- ``sa1``, whose ``$10`` is its pack's -- gets the same run
    one bank up, which is exactly what the assembler did with the same number:
    :attr:`Feature.bank_define` carried it to the source, and this carries it
    to the reading side. Nothing inside the run moves, so the whole map shifts
    by the difference and by nothing else.

    **The run.** An occupant of one of :data:`PACKED_RUNS` declares its
    tables as though it were the only one, so what it is read at is that plus the
    :meth:`Feature.shifts_by` of the occupants ahead of it that ``held`` has --
    one figure each, whatever else the cartridge holds.
    The assembler works the same sum out by emitting them in that order, and
    a build test holds the two equal.

    **Neither shift touches a table below** :data:`RESERVATION_BANK`. A
    feature that uses an expansion bank it can do *without*
    (:attr:`Feature.bank_rom_size`) has to keep anything it must be able to
    name at an address every cartridge has, which means one of the game's own
    banks -- and those are exactly the banks a reservation can never be, so a
    table there is where it is declared on every base.
    """
    tables = dict(found.tables)
    shift = sum(
        feature(one).shifts_by() for one in _run_ahead(found.id) if one in held
    )
    if found.bank_define is not None and base.reservation_bank != RESERVATION_BANK:
        shift += (base.reservation_bank - RESERVATION_BANK) << 16
    if not shift:
        return tables
    return {
        role: table
        if (table.address >> 16) < RESERVATION_BANK
        else replace(
            table,
            address=table.address + shift,
            per_target={target: at + shift for target, at in table.per_target.items()},
        )
        for role, table in tables.items()
    }


def _declared(features: list[Feature], name: str, fallback):  # noqa: ANN001,ANN202
    """The one feature's answer for ``name``, or the base's where none has one.

    "The one" and not "the first": :func:`applied` has already refused two
    features that both declare a fact, so at most one of these is not ``None``.
    """
    for found in features:
        held = getattr(found, name)
        if held is not None:
            return held
    return fallback


def _check_packed_runs() -> None:
    """Refuse a set of declarations a packed run could not be read from.

    Three things, checked as this module is imported rather than by a test,
    for :meth:`Feature.__post_init__`'s reason: a run is declared by whoever
    adds an occupant to it, and half of what makes one sound is a fact about
    the *other* occupants that no one declaration can see.

    **A feature is in at most one run**, or nothing could say which blocks
    are in front of its own.

    **Every occupant declares a block and nothing else does.** An occupant
    without one is a feature read where nothing put it, or a run priced as
    though a real block were free -- which is exactly what a last occupant
    with nothing behind it is tempted into, since its figure is in no shift.
    A block declared outside a run is a figure nothing reads.

    **A block is one size on every cartridge.** Nothing an occupant emits
    depends on which others are there, so :meth:`Feature.shifts_by` is a
    question about the run's order alone. The one piece two of them ever
    shared, the level number stash, is laid down by the level bank in front
    of every occupant (``Config/LevelNumberStash.asm``).
    """
    packed = [one for run in PACKED_RUNS for one in run]
    twice = sorted({one for one in packed if packed.count(one) > 1})
    if twice:
        raise FeatureError(f"{', '.join(twice)} is in two packed runs")
    declared = {one.id for one in FEATURES.values() if one.block_bytes}
    odd = sorted(declared ^ set(packed))
    if odd:
        raise FeatureError(
            f"a packed run's occupants are exactly the features that declare "
            f"a block, and these are in one without the other: "
            f"{', '.join(odd)}"
        )


_check_packed_runs()
