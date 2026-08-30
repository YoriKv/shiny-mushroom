"""Turning a feature on and off, and what that costs the project.

:mod:`smw_tools.features` declares what a feature **is**: the tables it moved,
the entry counts it grew, the defines a build switches it on with. It knows
nothing about a project, because nothing in that package does. This is the
other half -- what happens to *work already saved* when the switch moves.

Three things, and they are the whole module:

**A limit is a reason the switch cannot move.** Not a failed attempt: a
:class:`Limit` is computed from the project as it stands, so the row can be
greyed out with the reason under it rather than offering a click that fails.
Some are permanent for this project (a base built with the feature has no
switch), some are the person's next step (a cartridge too small to hold it),
and some are the work itself -- a world map grown past what the stock tables
have room for cannot be put back into them, and that is the interesting one.

**A migration is what has to happen to the overlay for the switch to be
honest.** Room is not the only thing that moves: the editor pads an emitted
fragment out to the run of ROM the build gives it, so a Layer 2 event table
written with the feature on is *longer* than the stock slot even when its rows
would fit. Turning the feature off re-emits every saved region against the
room it is going back to. Turning one on needs no such pass -- a fragment
padded short still assembles into a longer slot, and the next save prices
itself against the build's own symbol file.

**A feature may do its own.** :class:`FeatureLifecycle` is the default, driven
entirely by the declaration, and it is enough for a feature that only
relocates tables. One that needs more -- a save format to rewrite, a table to
seed, a limitation nothing generic could know -- registers a subclass in
:data:`LIFECYCLES` and overrides the half it cares about. Nothing else in the
editor learns that it did.

Qt-free, like every module outside :mod:`shiny_mushroom.ui`: a switch is a
line in ``project.json`` and a rewritten file in the overlay, and both are
testable by handing this a ``tmp_path``.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom import build as project_build
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.project import Project, ProjectError, scanning_once
from smw_tools import asm_codec, asm_regions, asm_room, graphics_memory, packed
from smw_tools.bases import RomBase
from smw_tools.bases import base as rom_base
from smw_tools.features import (
    FEATURES,
    LEVEL_BANK_HEAD,
    LEVEL_CUSTOM_PALETTES,
    LEVEL_GRAPHICS,
    MANAGED_GRAPHICS_MEMORY,
    MANAGED_LEVEL_MEMORY,
    RESERVED_RUN,
    Feature,
    FeatureError,
    applied,
    build_defines,
    feature,
)
from smw_tools.levels import has_level_bank, managed_regions
from smw_tools.rom_sizes import ROM_SIZES
from smw_tools.symbols import SymbolTable

#: Where a feature the project has is held from: whose switch it is.
#:
#: Only :data:`BY_PROJECT` can be moved here. The other two describe a
#: cartridge that arrived with the feature already in it, and the way to be
#: without one of those is to build another base or to turn the patch off --
#: which is a different dialog and says so.
BY_PROJECT = "project"
BY_BASE = "base"
BY_PATCH = "patch"


class FeatureBlocked(FeatureError):
    """A switch that will not move, and every reason it will not.

    Raised only by :func:`enable` and :func:`disable` -- a caller that asked
    anyway. The dialog reads :attr:`limits` off the row instead and never gets
    here, which is the point of the two being the same computation.
    """

    def __init__(self, feature_id: str, limits: tuple[Limit, ...]) -> None:
        self.feature_id = feature_id
        self.limits = limits
        super().__init__("; ".join(limit.reason for limit in limits))


@dataclass(frozen=True)
class Limit:
    """One reason a feature cannot be turned on or off as the project stands."""

    #: What stands in the way, as a sentence.
    reason: str

    #: What would clear it, where anything would. Empty is not "nothing can be
    #: done" but "nothing this editor can name" -- a base built with the
    #: feature is simply what that project is.
    remedy: str = ""


@dataclass(frozen=True)
class Switched:
    """What moving a switch did.

    The project comes back because it may not be the one that went in:
    :meth:`FeatureLifecycle.on_enable` can raise the cartridge size, and
    :class:`~shiny_mushroom.project.Project` is frozen, so the caller has to
    take the one handed out or carry on building the old cartridge.
    """

    project: Project

    #: What the migration did, in the person's terms. Empty is the ordinary
    #: answer: most switches only need the next build.
    notes: tuple[str, ...] = ()


@dataclass(frozen=True)
class FeatureRow:
    """One feature as a project sees it -- everything a list row needs."""

    feature: Feature

    #: Whether the **next build** would have it. What the cartridge on disk
    #: has is :attr:`built`, and the two differ for exactly as long as a build
    #: is owed.
    on: bool

    #: Whether the cartridge on disk has it.
    built: bool

    #: Whose switch it is: :data:`BY_PROJECT`, :data:`BY_BASE` or
    #: :data:`BY_PATCH`. Only the first can be moved.
    held_by: str

    #: Why the switch will not move from where it is, empty when it will.
    limits: tuple[Limit, ...] = ()

    @property
    def movable(self) -> bool:
        return not self.limits

    @property
    def stale(self) -> bool:
        """Whether this feature is waiting on a build to become true."""
        return self.on != self.built


@dataclass(frozen=True)
class _Saved:
    """One region a project has saved, and what it has to fit into without
    the feature being switched off."""

    region_id: str

    #: The rows the project holds, as the cartridge *with* the feature reads
    #: them.
    rows: object

    #: Bytes the cartridge without the feature gives this fragment.
    room: int

    #: Whether that cartridge still pools the fragment in a shared run --
    #: which is where :attr:`room` came from, and what the refusal has to say
    #: rather than calling it stock.
    pooled: bool


# -- the lifecycle -------------------------------------------------------------


class FeatureLifecycle:
    """What turning one feature on or off costs a project.

    The default, and the whole of what a feature that only moves tables needs.
    Every judgement it makes comes from the declaration
    (:class:`smw_tools.features.Feature`) or from the project's own overlay --
    nothing is written down twice.

    A feature with something else to do subclasses this and registers itself
    in :data:`LIFECYCLES`. Override the pair that matters and call ``super()``
    for the rest: the generic checks are the ones no feature should have to
    remember, and a subclass that forgets them would let a switch move that
    loses work.
    """

    def __init__(self, feature_id: str) -> None:
        self.feature_id = feature_id

    @property
    def feature(self) -> Feature:
        """The declaration, or :class:`FeatureError` naming what there is."""
        return feature(self.feature_id)

    # -- the limitations -------------------------------------------------------

    def enable_limits(self, project: Project) -> tuple[Limit, ...]:
        """Every reason ``project`` cannot switch this feature on.

        The cartridge being too small is deliberately **not** one of them: the
        size is a project setting and :meth:`on_enable` raises it, so the only
        size that stops this is one the base cannot be built at.
        """
        found = self.feature
        limits = list(self._unswitchable(project))
        if limits:
            return tuple(limits)
        # A patched base has nowhere to put a switch, and says so through
        # `_declaration_limits`: `smw_tools.features.applied` refuses the same
        # pair for the same reason, and one sentence in one place beats two
        # here that would have to be kept saying the same thing.
        limits += self._room_limits(project, found)
        limits += self._declaration_limits(project, adding=found.id)
        limits += self._packed_run_limits(project, found)
        return tuple(limits)

    def disable_limits(self, project: Project) -> tuple[Limit, ...]:
        """Every reason ``project`` cannot switch this feature off.

        The generic pair: something else needs it, or the work saved under it
        would not fit back into the cartridge without it.
        """
        limits = list(self._unswitchable(project))
        if limits:
            return tuple(limits)
        # Before the pricing rather than beside it: a cartridge this feature
        # has been taken out from under is not a cartridge, so there is no
        # layout to price the saved work against.
        needed = self._needed_by(project)
        if needed:
            return needed
        return self._fit_limits(project)

    # -- the migrations --------------------------------------------------------

    def on_enable(self, project: Project) -> Switched:
        """Bring ``project`` to where this feature can be switched on.

        The cartridge grows where the feature needs a bank the current size
        has not got. Nothing in the overlay moves: a fragment padded to the
        stock run of ROM is shorter than the slot it is going into, which
        assembles, and the next save re-prices it against the new build's own
        symbol file.
        """
        wanted = self.feature.min_rom_size
        if wanted is None or _fits(project.rom_size_id, wanted):
            return Switched(project)
        grown = project.set_rom_size(wanted)
        return Switched(
            grown,
            (
                f"The cartridge is now {ROM_SIZES[wanted].label}, for "
                f"{self.feature.name.lower()}.",
            ),
        )

    def on_disable(self, project: Project) -> Switched:
        """Bring ``project``'s overlay back to what the stock layout holds.

        Every saved asm region is re-emitted against the run it is going back
        to. Nothing pads, so what is being re-fitted is the rows themselves --
        and a project mid-switch is between two cartridges, so the run to price
        against is the one it is going *to* rather than the one its last build
        made.

        :meth:`disable_limits` has already refused anything that would not
        fit, so this cannot fail on room. A region whose rows come back equal
        to the disassembly's is reverted rather than rewritten, which is what
        the overlay means.
        """
        without = self._base_without(project)
        moved: list[str] = []
        for held in self._saved_regions(project):
            # A run of one, whatever the cartridge going back does with the
            # fragment: `_saved_regions` has already taken the other members of
            # a run it still shares off its room, so what is left is this
            # fragment's alone and nothing else has to be priced beside it.
            run = asm_room.Run(size=held.room, members=(held.region_id,))
            if project.save_asm_regions(
                {held.region_id: held.rows}, {held.region_id: run}, without
            ):
                moved.append(held.region_id)
        if not moved:
            return Switched(project)
        listed = ", ".join(sorted(moved))
        if len(moved) == 1:
            return Switched(project, (f"{listed} was re-fitted to the stock layout.",))
        return Switched(
            project,
            (f"{len(moved)} tables were re-fitted to the stock layout: {listed}.",),
        )

    def kept_room(self, project: Project) -> int:
        """How much of this feature's block ``project`` already keeps room
        for with the switch **down**.

        Nothing, for a feature whose data arrives with it: the run is priced
        as it stands and the whole block is what turning the switch on adds
        (:meth:`_packed_run_price`). A feature whose data the overlay holds
        either way overrides this, so its room is not charged for twice.
        """
        return 0

    # -- what both halves are built out of -------------------------------------

    def _unswitchable(self, project: Project) -> tuple[Limit, ...]:
        """The limit for a feature whose presence is not this project's to
        decide, or nothing where it is.

        Three ways to arrive and only one of them is a switch, so this is the
        first thing both halves ask: a feature the base was built with, or one
        an asm patch writes into the cartridge, is a fact about that cartridge
        rather than a setting -- and each says where the real control is.
        """
        found = self.feature
        base = rom_base(project.base_id)
        if found.id in base.features:
            return (
                Limit(
                    f"{base.id} is built with {found.name}.",
                    "A project cannot change its ROM base -- a cartridge "
                    "without this feature is a new project.",
                ),
            )
        if found.id in project.feature_state and found.switchable:
            return ()
        if found.id in project_build.features_wanted(project):
            return (
                Limit(
                    f"{found.name} is written in by one of this project's "
                    f"patches, not by a switch here.",
                    "Turn that patch off under Project > Patches...",
                ),
            )
        if not found.switchable:
            return (
                Limit(
                    f"{found.name} has no switch in this disassembly: it "
                    f"arrives with a ROM base built for it, or with a patch.",
                    "Add such a patch under Project > Patches...",
                ),
            )
        return ()

    def _room_limits(self, project: Project, found: Feature) -> tuple[Limit, ...]:
        """The limit for a base that cannot be built large enough, or none."""
        wanted = found.min_rom_size
        if wanted is None or _fits(project.rom_size_id, wanted):
            return ()
        base = rom_base(project.base_id)
        if wanted in base.sizes:
            return ()
        return (
            Limit(
                f"{found.name} needs a {ROM_SIZES[wanted].label} cartridge; "
                f"{base.id} offers {', '.join(base.sizes)}.",
            ),
        )

    def _packed_run_limits(self, project: Project, found: Feature) -> tuple[Limit, ...]:
        """The limit for an occupant its packed run has no room left for, or
        none -- one of :data:`~smw_tools.features.PACKED_RUNS`.

        An occupant packs into its run whole -- the remap table at the head of
        the shared reserved run, the text at its tail, the per-level graphics'
        block at the head of the level bank -- so what switching one on costs
        is the block it occupies unedited (:meth:`_packed_run_price`), and
        what there is to pay with is whatever the occupants already there
        leave. The assembler makes the same check and refuses the build; this
        makes it while the row can still be greyed out with the number under
        it.

        A cartridge with no reserved run yet is no limit on anyone: the run is
        empty until a build makes it, and this one is what makes it. The level
        bank is priced off the declarations instead, so it always answers.
        """
        if found.id in RESERVED_RUN:
            left = _reserved_run_spare(project, found)
            run = "reserved run"
            remedy = (
                "Take that much back out of the tables and text already in "
                "the reserved bank first."
            )
        elif found.id in LEVEL_BANK_HEAD:
            left = _level_bank_spare(project)
            run = "level bank"
            remedy = (
                "Take that much back out of the levels and palettes the level "
                "bank already holds first."
            )
        else:
            return ()
        wanted = self._packed_run_price(project)
        if left is None or wanted <= left:
            return ()
        return (
            Limit(
                f"{found.name} needs {wanted:,} bytes of the {run} and "
                f"{max(left, 0):,} are left.",
                remedy,
            ),
        )

    def _packed_run_price(self, project: Project) -> int:
        """How many bytes switching this feature on adds to its packed run.

        The block it occupies unedited
        (:meth:`~smw_tools.features.Feature.block`), asked of the cartridge
        the next build makes, since part of a block may be a piece an
        occupant ahead of it emits -- the level number stash, which the
        per-level graphics carry whenever they lead the level bank.

        Less whatever the run's spare figure already holds for it
        (:meth:`kept_room`), which is nothing for most features and the whole
        block for one whose data the overlay keeps either way.
        """
        return max(0, self.feature.block_bytes - self.kept_room(project))

    def _declaration_limits(self, project: Project, adding: str) -> tuple[Limit, ...]:
        """What :mod:`smw_tools.features` refuses about the set this would
        make: a requirement nothing satisfies, a conflict, two features
        changing one fact, or two defining one name."""
        base = rom_base(project.base_id)
        wanted = (*project_build.features_wanted(project), adding)
        limits: list[Limit] = []
        try:
            applied(base, wanted, project.rom_size_id)
        except FeatureError as error:
            limits.append(Limit(f"{error}."))
        try:
            _defines_for(base, wanted)
        except FeatureError as error:
            limits.append(Limit(f"{error}."))
        return tuple(limits)

    def _needed_by(self, project: Project) -> tuple[Limit, ...]:
        """The limit for a feature something else on this cartridge needs."""
        wanted = project_build.features_wanted(project)
        needing = sorted(
            FEATURES[held].name
            for held in wanted
            if held in FEATURES and self.feature_id in FEATURES[held].requires
        )
        if not needing:
            return ()
        return (
            Limit(
                f"{', '.join(needing)} is built on {self.feature.name}.",
                "Turn that off first.",
            ),
        )

    def _fit_limits(self, project: Project) -> tuple[Limit, ...]:
        """The limit for saved work the layout without this feature has no
        room for.

        The interesting one, and the reason this module exists: a world map
        edited into the room the feature bought cannot be put back into the
        room it had. Priced rather than guessed -- what the saved rows need
        against what the cartridge going back gives the fragment, which
        :meth:`_saved_regions` measures either off the run it still shares or
        off the disassembly's own rows.

        A fragment's total rather than a table at a time: the tables inside one
        move each other, so a table that grew is paid for by any that shrank
        beside it and only the sum is a fact.
        """
        limits: list[Limit] = []
        without = self._base_without(project)
        for held in self._saved_regions(project):
            region_id, saved, room = held.region_id, held.rows, held.room
            region = asm_regions.region_for(region_id, self._base_with(project))
            sizes = region.used(saved)
            needed = sum(sizes[role] for role in region.emitted_sections)
            over = needed - room
            if over > 0:
                gives = (
                    "the reserved run leaves it"
                    if held.pooled
                    else "the stock cartridge has"
                )
                limits.append(
                    Limit(
                        f"{region_id} needs {needed:,} bytes and "
                        f"{gives} {room:,}: {over:,} too many.",
                        "Take that much back out of the world map first.",
                    )
                )
                continue
            # A table whose scan this feature binds to its rows goes back to a
            # literal scan: the count has to be the one that scan reads, or
            # the rows would be read short or past -- the destroyed tiles'
            # sixteen, with the stock over-read behind them.
            back = asm_regions.region_for(region_id, without)
            if back.growable and not back.grows:
                held = back.scanned_count(saved)
                if not back.allows(held):
                    limits.append(
                        Limit(
                            f"{region_id} holds {held} rows and the stock "
                            f"cartridge's scan reads exactly "
                            f"{back.entry_counts()[back.scanned_sections[0]]}.",
                            "Put the table back to that many rows first.",
                        )
                    )
        return tuple(limits)

    def _saved_regions(self, project: Project) -> list[_Saved]:
        """Every asm region this project has saved, and what it has to fit.

        Rows are read as the cartridge *with* the feature has them and room is
        what the one without it gives them, so the two sides of every
        comparison here are the two cartridges rather than one of them twice.

        **Room is the pool's where there still is one.** Three features share
        the reserved run, each switched on by itself, so a cartridge this one
        is taken off may still pool the fragment -- and pricing it against the
        disassembly's rows would refuse a switch for room the run has got.
        Only a fragment that cartridge pools nowhere goes back to the stock
        rows, which is the run of ROM between its label and whatever the map
        placed after it.

        A fragment that can no longer be read at all is skipped: the hand-edit
        is reported where it is written over, by name and line, and a switch is
        not the place to first hear about it.
        """
        with_it = self._base_with(project)
        without = self._base_without(project)
        symbols = _build_symbols(project)
        out: list[_Saved] = []
        for region_id in asm_regions.regions(with_it):
            if not project.asm_region_edited(region_id):
                continue
            try:
                saved = project.asm_rows(region_id)
            except (asm_codec.AsmRegionError, ProjectError, OSError):
                continue
            pooled = _pooled_room(project, region_id, without, symbols)
            if pooled is not None:
                out.append(_Saved(region_id, saved, pooled, True))
                continue
            try:
                stock = _stock_rows(project, region_id, without)
            except (asm_codec.AsmRegionError, ProjectError, OSError):
                continue
            if stock is None:
                continue
            stock_region = asm_regions.region_for(region_id, without)
            sizes = stock_region.used(stock)
            room = sum(sizes[role] for role in stock_region.emitted_sections)
            out.append(_Saved(region_id, saved, room, False))
        return out

    def _base_with(self, project: Project) -> RomBase:
        """The cartridge this project's next build makes, this feature on it."""
        wanted = dict.fromkeys(
            (*project_build.features_wanted(project), self.feature_id)
        )
        return applied(rom_base(project.base_id), wanted, project.rom_size_id)

    def _base_without(self, project: Project) -> RomBase:
        """The same cartridge with this feature taken back off."""
        wanted = [
            held
            for held in project_build.features_wanted(project)
            if held != self.feature_id
        ]
        return applied(rom_base(project.base_id), wanted, project.rom_size_id)


class _LevelPalettesLifecycle(FeatureLifecycle):
    """Custom level palettes: the saved palettes are what the feature builds
    in, so the switch stays down while any level wears one.

    The default lifecycle's fit check reads :mod:`smw_tools.asm_regions`
    fragments, and the palettes are not one -- their fragments carry incbins
    no region grammar reads -- so the limit is asked of the project directly.
    And the switch is free where a level is already dressed, which is
    :meth:`kept_room`.
    """

    def kept_room(self, project: Project) -> int:
        """The whole head, where a level already wears a palette.

        A dressed level's blob is in the overlay with the feature off, so the
        level bank is priced with the head in front of it either way
        (:meth:`~shiny_mushroom.project.Project.level_palette_bytes`) and
        turning the switch on adds none of it.
        """
        try:
            if not project.level_palette_bytes():
                return 0
            return self.feature.block_bytes
        except (ProjectError, OSError):
            return 0

    def disable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().disable_limits(project)
        if held:
            return held
        try:
            dressed = project.level_palettes()
        except (ProjectError, OSError):
            dressed = {}
        if dressed:
            listed = ", ".join(hexnum(level, 3) for level in sorted(dressed))
            held += (
                Limit(
                    f"{len(dressed)} level(s) wear a custom palette this "
                    f"feature builds in: {listed}.",
                    "Untick each level's custom palette -- or Revert "
                    "Palettes -- and save first.",
                ),
            )
        return held


class _LevelGraphicsLifecycle(FeatureLifecycle):
    """Per-level graphics: the saved rows are what the feature builds in, so
    the switch stays down while any level carries one -- the palettes'
    rule, for the palettes' reason: the rows are no asm region the default
    fit check could read.

    The way on is the default's: the block is one fixed size at the level
    bank's head, the run behind it is what the packer and the palettes are
    priced against, and both re-price at their next save.
    """

    def disable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().disable_limits(project)
        if held:
            return held
        try:
            rows = project.level_graphics()
        except (ProjectError, OSError):
            rows = {}
        if rows:
            listed = ", ".join(hexnum(level, 3) for level in sorted(rows))
            held += (
                Limit(
                    f"{len(rows)} level(s) name graphics of their own, which "
                    f"this feature builds in: {listed}.",
                    "Set each level's graphics back to its tileset's -- or "
                    "Revert Level -- and save first.",
                ),
            )
        return held


class _ManagedLevelMemoryLifecycle(FeatureLifecycle):
    """Growable levels: the level banks are one budget with the feature on
    and seven with it off, and the saved levels have to fit whichever the
    switch is moving to.

    Neither side is an asm region, so the default's fit check sees nothing;
    both are priced here through the project's own level arithmetic --
    the packer for the way on, the stock runs' difference for the way back.
    And the level files the project adds are what the feature packs, so the
    switch stays down while there are any.

    **The cartridge is not a requirement here**, which is what separates this
    from the level bank's other two occupants: the packing uses that bank
    where the project builds one and packs into what banks ``$06`` and
    ``$07`` leave where it does not, so the switch moves at 512 KB and the
    size stays the project's own decision (:meth:`Project.rom_size_id`,
    ``Level > ...`` and the ROM size menu). What the size *does* decide is
    how much room the switch buys, which is why both halves price against
    the project's own runs rather than a fixed set.
    """

    def enable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().enable_limits(project)
        if held:
            return held
        try:
            packing = project.level_packing()
        except (ProjectError, OSError, ValueError):
            return held
        if not packing.fits:
            held += (
                Limit(
                    f"The saved levels need {packing.over:,} bytes more than "
                    f"{_runs_named(project)} hold end to end.",
                    "Take that much back out of the levels first, or build a "
                    "larger cartridge for them to overflow into.",
                ),
            )
        return held

    def disable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().disable_limits(project)
        if held:
            return held
        names = project.added_level_files()
        if names:
            held += (
                Limit(
                    f"The project adds {len(names)} level file(s) this "
                    f"feature packs: {', '.join(names)}.",
                    "Delete them under Project > Level Data first.",
                ),
            )
        over = []
        for region in managed_regions(project.base, project.target):
            try:
                room = project.level_room(region)
            except (ProjectError, OSError):
                continue
            if room < 0:
                over.append(f"{region.name} by {-room:,} bytes")
        if over:
            held += (
                Limit(
                    f"The saved levels no longer fit the stock runs: "
                    f"{', '.join(over)}.",
                    "Take that much back out of the levels in each run first.",
                ),
            )
        return held


class _ManagedGraphicsMemoryLifecycle(FeatureLifecycle):
    """Growable graphics: the graphics files are one packing with the
    feature on and one budgeted run with it off, and the cartridge follows
    the project's graphics bank count rather than the feature's floor.

    Neither side is an asm region, so the default's fit check sees nothing.
    The way on raises the cartridge to the size the last graphics bank
    exists in (:func:`smw_tools.graphics_memory.rom_size_for`); the way off
    is held down by the files the project adds -- the streams are what the
    feature packs -- and by an edited stock file the stock run's budget no
    longer holds, priced as a stock save is
    (:meth:`~shiny_mushroom.project.Project.region_usage`).
    """

    def enable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().enable_limits(project)
        if held:
            return held
        try:
            _graphics_size_wanted(project)
        except graphics_memory.GraphicsMemoryError as error:
            held += (Limit(f"{error}.", "Lower the graphics bank count first."),)
        return held

    def disable_limits(self, project: Project) -> tuple[Limit, ...]:
        held = super().disable_limits(project)
        if held:
            return held
        try:
            added = project.added_graphics()
        except (ProjectError, OSError):
            added = {}
        if added:
            listed = ", ".join(f"GFX{number:02X}" for number in added)
            held += (
                Limit(
                    f"The project adds {len(added)} graphics file(s) this "
                    f"feature packs: {listed}.",
                    "Delete them under Project > Graphics Files first.",
                ),
            )
        try:
            used, budget = project.region_usage(
                packed.graphics_region(project.graphics_set)
            )
        except (ProjectError, packed.PackedError, OSError):
            return held
        if used > budget:
            held += (
                Limit(
                    f"The edited graphics files need {used:,} bytes and the "
                    f"stock run has {budget:,}: {used - budget:,} too many.",
                    "Take that much back out of the graphics files first.",
                ),
            )
        return held

    def on_enable(self, project: Project) -> Switched:
        """The cartridge follows the bank count: the feature's own floor is
        what one bank needs, and a project that asked for more needs the
        size its last bank is in."""
        wanted = _graphics_size_wanted(project)
        if _fits(project.rom_size_id, wanted):
            return Switched(project)
        grown = project.set_rom_size(wanted)
        banks = project.graphics_banks
        return Switched(
            grown,
            (
                f"The cartridge is now {ROM_SIZES[wanted].label}, for "
                f"{self.feature.name.lower()} with {banks} graphics "
                f"bank{'s' if banks != 1 else ''}.",
            ),
        )


#: The features that need more than :class:`FeatureLifecycle` does, by id.
#:
#: A feature earns an entry here by needing one -- the same kind of sparse
#: :data:`smw_tools.features.FEATURES` is. The default is not a fallback for
#: a feature nobody has got round to: it is the right answer for one that
#: only moves tables, which the declaration already describes in full.
LIFECYCLES: dict[str, FeatureLifecycle] = {
    LEVEL_CUSTOM_PALETTES.id: _LevelPalettesLifecycle(LEVEL_CUSTOM_PALETTES.id),
    LEVEL_GRAPHICS.id: _LevelGraphicsLifecycle(LEVEL_GRAPHICS.id),
    MANAGED_LEVEL_MEMORY.id: _ManagedLevelMemoryLifecycle(MANAGED_LEVEL_MEMORY.id),
    MANAGED_GRAPHICS_MEMORY.id: _ManagedGraphicsMemoryLifecycle(
        MANAGED_GRAPHICS_MEMORY.id
    ),
}


def lifecycle(feature_id: str) -> FeatureLifecycle:
    """How ``feature_id`` is switched: its own, or the default over it."""
    feature(feature_id)  # refuses an id this build cannot resolve, with the list
    return LIFECYCLES.get(feature_id) or FeatureLifecycle(feature_id)


# -- what the dialog asks ------------------------------------------------------


def rows(project: Project) -> tuple[FeatureRow, ...]:
    """Every feature this build declares, as ``project`` has or could have it.

    In registry order, which is :data:`~smw_tools.features.FEATURES`' own
    reading order -- growable first. Sorting here would reshuffle the list
    every time a feature is added or renamed, and would put the order in two
    places.

    **One reading of the overlay for the whole list**
    (:func:`~shiny_mushroom.project.scanning_once`): pricing what a switch
    would cost reads every asm region the project has saved, and a row that
    shares a run with another reads that one too, so without the block the
    same fragments come off the disk once a row. The block is what makes
    those one read each, and the list is answered from a tree that cannot
    change while it is being answered.
    """
    with scanning_once():
        wanted = project_build.features_wanted(project)
        built = project.features
        base = rom_base(project.base_id)
        chosen = project.feature_state
        return tuple(
            _row(project, found, base, wanted, built, chosen)
            for found in FEATURES.values()
        )


def _row(
    project: Project,
    found: Feature,
    base: RomBase,
    wanted: tuple[str, ...],
    built: tuple[str, ...],
    chosen: tuple[str, ...],
) -> FeatureRow:
    on = found.id in wanted
    if found.id in base.features:
        held_by = BY_BASE
    elif (on and found.id not in chosen) or not found.switchable:
        held_by = BY_PATCH
    else:
        held_by = BY_PROJECT
    switch = lifecycle(found.id)
    limits = switch.disable_limits(project) if on else switch.enable_limits(project)
    return FeatureRow(
        feature=found,
        on=on,
        built=found.id in built,
        held_by=held_by,
        limits=limits,
    )


def enable(project: Project, feature_id: str) -> Switched:
    """Switch ``feature_id`` on, migration and all.

    The limits are checked here as well as by the dialog, because the two are
    not the same moment: a row is drawn once and clicked later, and what a
    project holds can have moved in between.
    """
    switch = lifecycle(feature_id)
    if feature_id in project.feature_state:
        return Switched(project)
    limits = switch.enable_limits(project)
    if limits:
        raise FeatureBlocked(feature_id, limits)
    done = switch.on_enable(project)
    done.project.set_feature_state([*done.project.feature_state, feature_id])
    return done


def disable(project: Project, feature_id: str) -> Switched:
    """Switch ``feature_id`` off, migration and all.

    The migration runs **before** the switch is recorded, so a project that
    fails halfway through re-fitting its overlay is still a project that has
    the feature -- which is the state its half-migrated files describe.
    """
    switch = lifecycle(feature_id)
    if feature_id not in project.feature_state:
        return Switched(project)
    limits = switch.disable_limits(project)
    if limits:
        raise FeatureBlocked(feature_id, limits)
    done = switch.on_disable(project)
    done.project.set_feature_state(
        [held for held in done.project.feature_state if held != feature_id]
    )
    return done


# -- small shared readings -----------------------------------------------------


def _runs_named(project: Project) -> str:
    """What the packer had to fit this project's levels into, in words: the
    game's own level banks, and the expansion bank behind them where the
    cartridge has one."""
    stock = "banks $06 and $07"
    if not has_level_bank(project.next_base):
        return stock
    return f"{stock} and the level bank"


def _fits(rom_size_id: str, wanted: str) -> bool:
    """Whether a cartridge of ``rom_size_id`` is at least ``wanted``."""
    return ROM_SIZES[rom_size_id].size >= ROM_SIZES[wanted].size


def _graphics_size_wanted(project: Project) -> str:
    """The cartridge size ``project``'s graphics bank count needs on the base
    its next build makes, or :class:`~smw_tools.graphics_memory.GraphicsMemoryError`
    for a count no size of the base reaches."""
    return graphics_memory.rom_size_for(project.next_base, project.graphics_banks)


def _build_symbols(project: Project) -> SymbolTable | None:
    """``project``'s own build's symbol file, or ``None`` where it has none.

    The record of where that build put every placement, and the only thing
    that knows how big the reserved run really is. A project that has never
    been built has no such record, and a switch priced against one asks for it
    here rather than reaching for a literal.

    Through :func:`shiny_mushroom.build.built_symbols`, so the file is parsed
    once for the whole dialog rather than once a row that prices something.
    """
    return project_build.built_symbols(project)


def _pooled_room(
    project: Project,
    region_id: str,
    base: RomBase,
    symbols: SymbolTable | None,
) -> int | None:
    """What the run ``base`` pools ``region_id`` in leaves that fragment.

    ``None`` where ``base`` pools it in no run, or where nothing can be
    measured -- a project with no build has no run to measure, and the caller
    prices the fragment against the disassembly's own rows instead.

    :func:`shiny_mushroom.build.asm_room` for the cartridge the switch is
    going to: the run is measured off the build's symbol file and the other
    members are counted at the project's own rows, so a run a sibling grew
    into has that much less to give this fragment.
    """
    if symbols is None or not any(region_id in pool.regions for pool in base.pools):
        return None
    try:
        return project_build.asm_room(project, region_id, symbols, base=base)
    except (asm_codec.AsmRegionError, ProjectError, OSError):
        return None


def _level_bank_spare(project: Project) -> int | None:
    """How many bytes the level bank leaves behind what ``project``'s next
    build already puts there: the head's occupants it already has, and the
    level streams the managed level banks pack in behind them.

    ``None`` where it cannot be priced at all -- the packer reads every level
    container the project holds, and a tree that will not be read is not one
    to grey a row out over. Negative where the packed streams already do not
    fit, which is a limit on anything wanting room at the head.
    """
    try:
        return project.level_bank_spare()
    except (ProjectError, OSError):
        return None


def _reserved_run_spare(project: Project, found: Feature) -> int | None:
    """How many bytes of the shared reserved run ``project``'s build leaves.

    ``None`` where there is nothing to measure: a project with no build, or
    one whose build reserved no run at all.

    The run is bounded by the labels every occupant names, read off the symbol
    file rather than declared, and what is in it is the pooled fragments at the
    project's own rows plus what the pool holds for the stubs and derived
    tables that are nobody's fragment. An occupant the next build adds and this
    one has not got is counted at the bytes it occupies unedited: its fragments
    are not in this ROM to read, and they will be in the next one.
    """
    symbols = _build_symbols(project)
    if symbols is None or not found.pools:
        return None
    bounds = (found.pools[0].start_label, found.pools[0].end_label)
    edges = [symbols.by_name.get(label) for label in bounds]
    if any(edge is None for edge in edges):
        return None
    base = project.cartridge_base
    pool = next(
        (one for one in base.pools if (one.start_label, one.end_label) == bounds),
        None,
    )
    run = asm_room.Run(
        size=edges[1].addr - edges[0].addr,
        members=pool.regions if pool else (),
        reserved=pool.reserved if pool else 0,
    )
    used: dict[str, int] = {}
    for member in run.members:
        try:
            used[member] = asm_regions.region_for(member, base).fits(
                project.asm_rows(member), None
            )
        except (asm_codec.AsmRegionError, ProjectError, OSError):
            return None
    wanted = project_build.features_wanted(project)
    coming = sum(
        feature(one).block_bytes
        for one in RESERVED_RUN
        if one in wanted and one not in project.features
    )
    return run.spare(used) - coming


def _defines_for(base: RomBase, ids: tuple[str, ...]) -> None:
    """Raise where the switched features of ``ids`` cannot share one command
    line -- the check :func:`shiny_mushroom.build.defines_wanted` makes at
    build time, made early enough to grey a row out."""
    build_defines([held for held in ids if held not in base.features], base)


def _stock_rows(project: Project, region_id: str, base: RomBase):  # noqa: ANN201
    """A region's rows as the disassembly ships them, read as ``base`` has
    them rather than as the project's own cartridge does.

    :meth:`shiny_mushroom.project.Project.asm_region_stock` answers the same
    question for the project's cartridge; the point here is to ask it of the
    *other* one, which is the layout the rows have to fit back into.
    """
    region = asm_regions.region_for(region_id, base)
    if not region.applies_to(project.target_id):
        return None
    try:
        text = asm_room.tree_text(region, project.base)
    except OSError:
        # The base tree does not carry the fragment; there is nothing this
        # cartridge would have to fit back into.
        return None
    return region.parse(text, base)
