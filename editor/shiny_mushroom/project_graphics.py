"""The graphics files a project's build inserts, and the banks that hold
them.

One of :class:`~shiny_mushroom.project.Project`'s subjects, in a module of
its own: the compressed resources in their editable raw form, the graphics
files that are the same thing under a friendlier name, and the managed
graphics banks a project adds files into. Its error, its packing record, its
``project.json`` key and its two generated fragments are here beside the
methods that use them, and :mod:`smw_tools.graphics_memory` is the partner
module the packing arithmetic lives in.

**A mixin rather than a view**, so every caller still asks the project --
``project.save_graphics(...)`` -- and nothing here is reached any other way.
What these methods read is the project's own folder, its overlay and its
metadata: they are a project's methods that happen to be written down
somewhere else, which is what makes the seam a module rather than an API.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom.project_files import (
    RAW_NAME,
    ProjectError,
    _capture,
    _now,
    _remembered,
    _restore,
    _scanned,
    _write_atomic,
)
from smw_tools import graphics, graphics_memory, packed
from smw_tools.graphics import TileFormat
from smw_tools.graphics_memory import (
    GraphicsMemoryError,
    GraphicsMemoryFull,
    Placement,
    player_files_share_a_bank,
)
from smw_tools.graphics_memory import Run as GraphicsRun
from smw_tools.packed import Packed
from smw_tools.rom_image import snes_to_pc
from smw_tools.rom_sizes import ROM_SIZES

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping

    from shiny_mushroom.project import Project


#: A tile editor's palette beside a raw graphics file -- ``GFX00.pal`` next to
#: ``GFX00.bin`` -- as one saving into the project's own graphics folder
#: leaves it. Never a build input: see :func:`is_sidecar`.
SIDECAR_SUFFIX = ".pal"

#: Where ``project.json`` records which slot each added graphics file packs
#: into: ``{"0x34": "cave-tiles.bin"}``, the editor's own mapping and the one
#: thing about an added file that is not read off the folder. See
#: :meth:`Project.added_graphics_slots`.
ADDED_GRAPHICS_KEY = "added_graphics"

#: What an added graphics file's raw form is called when nobody has named it:
#: the slot's own name, which is what a project written before there were
#: names holds throughout.
ADDED_GRAPHICS_SUFFIX = ".bin"


class GraphicsBanksFull(ProjectError):
    """The graphics files no longer fit the managed graphics banks.

    :class:`LevelBanksFull`'s counterpart for the compressed graphics
    (:func:`smw_tools.graphics_memory.pack`): the stock four banks and the
    graphics banks behind them are one packing, a file that reaches the end
    of one run moves whole into the next, and what will not fit is the file
    the packer found no run for and everything after it. Raised only once a
    bank more would not hold it either: one that would is added to the
    project instead (:meth:`Project.save_graphics`).
    """

    def __init__(self, packing: GraphicsPacking) -> None:
        self.packing = packing
        #: How many bytes have to come back out before everything fits.
        self.over = packing.over
        banks = f"{packing.banks} graphics bank{'s' if packing.banks != 1 else ''}"
        if packing.unplaced is None:
            super().__init__(
                "the graphics banks cannot hold this: GFX32 and GFX33 would "
                "no longer end in one bank, which the boot-time load needs. "
                "Take bytes out of GFX32 or GFX33."
            )
            return
        size = packing.sizes[packing.unplaced]
        super().__init__(
            f"the graphics banks are full: GFX{packing.unplaced:02X} "
            f"({size:,} bytes) fits no run of the stock banks and {banks}, "
            f"and {self.over:,} bytes have nowhere to go. Take that much out "
            f"of the graphics files, or delete an added one."
        )


@dataclass(frozen=True)
class GraphicsPacking:
    """Where the managed graphics banks put every file a project's build
    inserts -- :func:`smw_tools.graphics_memory.pack` over the project's own
    sizes, for :attr:`banks` graphics banks (:meth:`Project.graphics_packing`).

    The whole of what a save has to know: :attr:`fits`, and how much has to
    come out when it does not.
    """

    banks: int
    #: The runs the packer filled, in order: the stock four banks, then each
    #: graphics bank.
    runs: tuple[GraphicsRun, ...]
    #: Compressed size by file number, stock and added, as the build will
    #: write each.
    sizes: Mapping[int, int]
    #: Where each file landed; empty when a file found no run.
    placed: Mapping[int, Placement]
    #: How many bytes found no run: the first file left out and everything
    #: after it. Zero is the build that assembles.
    over: int = 0
    #: The first file that found no run, or ``None`` when every one did.
    unplaced: int | None = None

    @classmethod
    def make(
        cls, banks: int, runs: tuple[GraphicsRun, ...], sizes: Mapping[int, int]
    ) -> GraphicsPacking:
        try:
            placed = graphics_memory.pack(sizes, runs)
        except GraphicsMemoryFull as full:
            return cls(banks, runs, sizes, {}, over=full.over, unplaced=full.number)
        return cls(banks, runs, sizes, placed)

    @property
    def split_player(self) -> bool:
        """Whether the packing parts GFX32 from GFX33 across a bank, which the
        assembler refuses: the boot-time load reads the pair as one."""
        return bool(self.placed) and not player_files_share_a_bank(self.placed)

    @property
    def fits(self) -> bool:
        return self.unplaced is None and not self.split_player

    @property
    def used(self) -> tuple[int, ...]:
        """How many bytes of each run the packing used, by run index: from
        the run's start to the end of the last file placed in it, so a run
        the packing moved past is counted to where it left."""
        out = []
        for index, run in enumerate(self.runs):
            inside = [one for one in self.placed.values() if one.run == index]
            if not inside:
                out.append(0)
                continue
            end = max(snes_to_pc(one.end) for one in inside)
            out.append(end - snes_to_pc(run.start))
        return tuple(out)

    @property
    def spare(self) -> tuple[int, ...]:
        """What each run has left past :attr:`used`."""
        return tuple(
            run.size - used for run, used in zip(self.runs, self.used, strict=True)
        )

    @property
    def total(self) -> int:
        """Every file's bytes, end to end."""
        return sum(self.sizes.values())

    @property
    def room(self) -> int:
        """Every run's bytes, end to end."""
        return sum(run.size for run in self.runs)

    def address_of(self, number: int) -> int | None:
        """Where file ``number`` landed, or ``None``."""
        found = self.placed.get(number)
        return None if found is None else found.address


@dataclass(frozen=True)
class GraphicsSaved:
    """What saving a graphics file did.

    The project comes back because it may not be the one that went in: a
    save the graphics banks could not hold but one bank more could raises
    the project's bank count, and the cartridge with it where the new bank
    is past the old one's end -- and :class:`Project` is frozen, so the
    caller takes the one handed out or carries on building the old cartridge.
    """

    number: int
    #: The raw file written.
    path: Path
    #: The project after the save.
    project: Project
    #: The graphics bank count after the save.
    banks: int
    #: The count before it, where the save raised it; ``None`` otherwise.
    raised_from: int | None = None

    @property
    def grew(self) -> bool:
        return self.raised_from is not None

    @property
    def note(self) -> str:
        """What the save did beyond writing the file, for a status line;
        empty for the ordinary save."""
        if not self.grew:
            return ""
        return (
            f"GFX{self.number:02X} did not fit the graphics banks, so the "
            f"project now has {self.banks} of them on a "
            f"{self.project.rom_size.label} cartridge."
        )


_GENERATED_GRAPHICS = (
    "; Generated by Shiny Mushroom -- do not edit: this file is rewritten\n"
    "; whenever a graphics file is added or deleted, and hand edits do not\n"
    "; survive. The disassembly's stock copy says what the fragment is.\n"
)


def added_graphics_fragment(added: Iterable[int]) -> str:
    """The added files' fragment: one ``%SMW_AddedGraphics(GFXnn)`` per file
    number, ascending -- what the managed graphics banks pack after the
    game's own (:func:`smw_tools.graphics_memory.added_rows`)."""
    return _GENERATED_GRAPHICS + "".join(graphics_memory.added_rows(added))


def graphics_formats_fragment(added: Mapping[int, int]) -> str:
    """The formats fragment for the added files' raw sizes by number: one
    ``%SMW_GraphicsFormat(GFXnn, <code>)`` per file whose shape is not the
    ordinary 3bpp slot, ascending; a 3bpp slot file is left out, as the
    grammar reads it (:func:`smw_tools.graphics_memory.format_rows`).

    A file's shape is its length (:func:`smw_tools.packed.shape_for_size`),
    since two of the three shapes are 3bpp and differ only in how many tiles
    they hold."""
    codes = {}
    for number, size in added.items():
        shape = packed.shape_for_size(size)
        if shape is None:
            shapes = ", ".join(f"{one.size:#x}" for one in packed.ADDED_SHAPES)
            raise packed.PackedError(
                f"GFX{number:02X} is {size:#x} bytes, which is no shape a "
                f"project's own graphics file may be ({shapes})"
            )
        codes[number] = shape.code
    return _GENERATED_GRAPHICS + "".join(graphics_memory.format_rows(codes))


#: Compiled size of a raw file, against ``(path, size, mtime_ns)``.
#:
#: Pricing a region means asking what each of its edited files compresses to,
#: and every save asks again -- so without this the graphics region re-encodes
#: up to 52 files per save. Keyed on the stat rather than the contents, which is
#: the trade :func:`shiny_mushroom.build.merge` already makes: hashing the file
#: to decide whether to compress it costs a good share of compressing it.
_compiled: dict[tuple[str, int, int], int] = {}


def _compiled_size(resource, held: Path, baseline: Path | None) -> int:
    """How many bytes ``held`` will occupy in the ROM, remembered. ``None``
    for the baseline is a file nothing ships -- an added graphics file --
    which is encoded from scratch."""
    stat = held.stat()
    key = (str(held), stat.st_size, stat.st_mtime_ns)
    size = _compiled.get(key)
    if size is None:
        shipped = None if baseline is None else baseline.read_bytes()
        size = len(resource.encode(held.read_bytes(), shipped))
        if len(_compiled) > 512:  # a project has nothing like this many
            _compiled.clear()
        _compiled[key] = size
    return size


def _added_size(path: Path) -> int | None:
    """The raw file at ``path``'s length, where that is a length an added
    file may be (:func:`smw_tools.packed.shape_for_size`) -- and ``None``
    for any other length, and for a file that cannot be read at all.

    The length is the whole record: what layout the file is in and how many
    tiles it holds both follow from it."""
    try:
        size = path.stat().st_size
    except OSError:
        return None
    return size if packed.shape_for_size(size) is not None else None


def _stock_name(stem: str) -> bool:
    """Whether a raw file's name is one of the set's own files' -- ``GFX00``
    through ``GFX33``. They share the folder with the files a project adds,
    and their names are the set's rather than anybody's to take."""
    return any(stem == f"GFX{number:02X}" for number in graphics.FILE_NUMBERS)


def _slot_spelled(stem: str) -> int | None:
    """The slot a raw file's name spells -- ``GFX34`` is ``$34`` -- or
    ``None`` for a name that spells none. The spelling is exact: a folded-case
    name on a folding filesystem is not a registry key, and a number no file
    may be added under is not a slot."""
    try:
        number = int(stem[3:], 16)
    except ValueError:
        return None
    if stem != f"GFX{number:02X}" or not graphics_memory.addable(number):
        return None
    return number


def added_graphics_name(number: int) -> str:
    """What an added file's raw form is called when nobody has named it:
    ``GFX34.bin``, the slot's own name."""
    return f"GFX{number:02X}{ADDED_GRAPHICS_SUFFIX}"


def check_graphics_name(name: str, taken: Iterable[str] = ()) -> str:
    """``name`` as a raw file's name, or a :class:`ProjectError` saying why it
    is not one.

    A file name and nothing else: no folder in it, no reaching upwards, and
    not one of ``taken`` -- the names the set's raw folder already holds,
    which is what makes a rename a rename rather than a save over somebody
    else's file. The suffix is the raw form's own and is added where it is
    missing, so somebody typing ``cave-tiles`` gets the file they meant.
    """
    said = name.strip()
    if said.lower().endswith(ADDED_GRAPHICS_SUFFIX):
        said = said[: -len(ADDED_GRAPHICS_SUFFIX)]
    if not said:
        raise ProjectError("a graphics file needs a name")
    if said != Path(said).name or said in {".", ".."}:
        raise ProjectError(f"{name.strip()} is a path, not a file name")
    if any(character in said for character in '\\/:*?"<>|'):
        raise ProjectError(
            f'{said} cannot be a file name: a name holds no \\ / : * ? " < > or |'
        )
    if _stock_name(said):
        raise ProjectError(
            f"{said} is one of the set's own files; a name the game already "
            f"uses is not one a project's file may take"
        )
    wanted = said + ADDED_GRAPHICS_SUFFIX
    if any(wanted.lower() == held.lower() for held in taken):
        raise ProjectError(f"{wanted} is already in the project's graphics folder")
    return wanted


def is_sidecar(relative: Path) -> bool:
    """Whether an overlay entry, by its :attr:`Project.changed` spelling, is a
    tile editor's palette beside a raw graphics file rather than a build
    input: anything under :data:`RAW_NAME` with :data:`SIDECAR_SUFFIX`."""
    return relative.parts[:1] == (RAW_NAME,) and relative.suffix == SIDECAR_SUFFIX


class GraphicsFiles:
    """A project's graphics files: the raw overlay, the managed banks, and
    the files it adds.

    Mixed into :class:`~shiny_mushroom.project.Project`, whose fields and
    overlay primitives every method here reads -- ``self`` is that project
    and nothing else is ever constructed.
    """

    # -- compressed resources, in their editable form ------------------------

    def raw_path(self, relative: Path) -> Path:
        """Where this project keeps the raw form of one compressed resource.

        ``relative`` is the key `smw_tools.packed` uses -- the destination path
        with a ``.bin`` suffix, under the name of the tree it belongs to. Under
        :data:`RAW_NAME` rather than beside the baseline, because it is not the
        same *kind* of thing: the baseline is compressed and is what the build
        reads, and this is the form nobody assembles directly.
        """
        self.resource_for(relative)  # rejects anything not packed
        return self.overlay / RAW_NAME / relative

    def raw(self, relative: Path) -> bytes:
        """A compressed resource in its editable form, ready to edit.

        The overlay's copy if this project has one, and the shipped file
        decompressed otherwise -- the same "overlay if there is one, base
        otherwise" rule :meth:`source` states for everything else, with a decode
        on the base side because the base is not stored in an editable form.
        """
        resource = self.resource_for(relative)
        held = self.overlay / RAW_NAME / relative
        if held.is_file():
            raw = held.read_bytes()
            resource.check(raw)
            return raw
        if resource.added:
            raise ProjectError(
                f"{relative} is an added graphics file the overlay no longer "
                f"holds; nothing ships in its place"
            )
        return packed.read_raw(resource, self.base, self.assets_base)

    @_remembered
    def _base_resources(self) -> dict[Path, Packed]:
        """Every compressed resource the **base** ships, by raw key.

        Split out of :meth:`packed_resources` because it is the expensive
        half and the still half: building it scans the backgrounds folder,
        and the base tree is extracted before any project can be opened and
        read-only afterwards, so nothing a project does can change it.
        """
        return packed.resources(self.base)

    @_scanned
    def packed_resources(self) -> dict[Path, Packed]:
        """Every compressed resource this project's build reads, by raw key:
        the registry's, and the graphics files this project adds
        (:func:`smw_tools.packed.resources`).

        Answered once per gather (:func:`_scanned`), since everything that
        resolves a raw key comes through here and the added half is a reading
        of the overlay. The base's own half is remembered for longer --
        :meth:`_base_resources`.
        """
        return self._base_resources() | {
            resource.raw_relative: resource for resource in self._added_packed()
        }

    def resource_for(self, relative: Path) -> Packed:
        """The resource a raw key belongs to, the added files included.

        The same lookup :func:`smw_tools.packed.resource_for` makes, through
        :meth:`packed_resources` so it is made over a registry already read:
        building one scans the backgrounds folder, and this is asked a key at
        a time -- twice per patch gather, and once per file a graphics window
        lists.
        """
        try:
            return self.packed_resources()[Path(relative)]
        except KeyError:
            raise packed.PackedError(
                f"{relative} is not a compressed resource"
            ) from None

    def _added_packed(self) -> list[Packed]:
        found = self._added_scan()
        return packed.added_graphics(
            self.graphics_set,
            {number: size for number, (_name, size) in found.items()},
            names={number: name for number, (name, _size) in found.items()},
        )

    def _priced(self, resource: Packed) -> tuple[int | None, int]:
        """What the disassembly ships for ``resource`` and what this
        project's build will write for it: ``(shipped, compiled)``.

        ``shipped`` is ``None`` where the assets hold no baseline -- a file
        the build does not read either, and every file a project adds -- and
        ``compiled`` is then the overlay's own encoding, or nothing at all.
        Otherwise the file is priced the way the build will write it: an
        edited one through the encoder, an untouched one at the size of the
        bytes it keeps, so this is the number asar is going to see.

        **One `stat` per file for both answers**, which is why this is the
        shape :meth:`region_usage` and :meth:`graphics_sizes` share: on a
        checkout under a mounted Windows drive a `stat` is most of what
        pricing costs, and asking a second question would be a second walk.

        **Only an edited file is encoded.** Compiled sizes are remembered
        against a raw file's size and modification time
        (:func:`_compiled_size`), so re-pricing re-encodes only what has
        moved -- the same trade, for the same reason, that
        :func:`shiny_mushroom.build.merge` makes when it fingerprints a tree.
        """
        baseline = resource.baseline_path(self.base, self.assets_base)
        try:
            shipped: int | None = baseline.stat().st_size
        except OSError:
            shipped = None
        held = self.overlay / RAW_NAME / resource.raw_relative
        if not held.is_file():
            return shipped, shipped or 0
        return shipped, _compiled_size(
            resource, held, baseline if shipped is not None else None
        )

    def region_usage(self, region: str) -> tuple[int, int]:
        """How many bytes ``region``'s files would compile to, and how many they
        may occupy: ``(used, budget)``.

        Every file in the region is priced the way the build will write it
        (:meth:`_priced`), so this is the number asar is going to see.

        **What that leaves is one `stat` per file in the region**, and that is
        what a save costs: measured on WSL with the checkout on a mounted
        Windows drive, 430 ms for the 52-file graphics region, 195 ms for the
        17 backgrounds, 88 ms for the overworld pair -- almost none of it the
        encoder. The obvious next step is to remember the baseline sizes for the
        session, which would be sound because the assets are extracted before
        any project can be opened and are read-only afterwards. It is not done
        here because it is state with nothing to invalidate it against, and a
        save costing a third of a second is not yet worth that.
        """
        used = budget = 0
        for resource in packed.in_region(region, self.base):
            shipped, compiled = self._priced(resource)
            if shipped is None:
                # No baseline means the file is not in the build either, so it
                # is left out of both sides -- exactly as `packed.budget` does.
                continue
            budget += shipped
            used += compiled
        # The run may also grow into the fitted padding the ROM map places
        # behind it -- the four banks of graphics end in one -- which is
        # read off the map for this project's own target, not stat'ed.
        budget += packed.fitted_tail(region, self.base, self.target)
        return used, budget

    def save_raw(self, relative: Path, raw: bytes) -> Path:
        """Write a resource's raw form into the overlay, and say where.

        Nothing is *kept* compressed here -- the overlay holds the raw form and
        the build compresses it, so a file edited back to what it was
        contributes the cartridge's own bytes rather than this encoder's.

        **But the compressed size is checked before the write.** Every region is
        packed to the byte against whatever `RomMap/` places next, plus the
        fitted padding where the map closes the run with one
        (:func:`smw_tools.packed.budget`), so an edit that compresses larger
        than the room its group has does not fail here -- it fails several
        seconds later inside asar, with a message about an address rather than
        about the thing that was edited. Refusing it now, with the number of
        bytes, is the difference between a bad edit and a broken project.

        The edit is priced against its *region*, not against itself: files in
        one region are concatenated, so one growing is paid for by another
        shrinking and a file may grow freely while the group still fits.

        One resource of :meth:`_save_raws`, plus the metadata stamp -- which
        is this call's rather than that one's, because a lone save is a save
        and a save of several parts stamps once.
        """
        (destination,) = self._save_raws([(relative, raw)])
        self._write_metadata({"modified": _now()})
        return destination

    def _save_raws(self, pairs: list[tuple[Path, bytes]]) -> list[Path]:
        """Write compressed resources as one decision -- every one, or none.

        :meth:`_save_resources` by raw key, **for everything but the managed
        graphics**. A graphics save may need a bank the project does not
        have, and taking one raises the cartridge size
        (:meth:`set_graphics_banks`) -- which is a new :class:`Project` this
        way in has no way of handing back, a save by key answering with
        paths. Taking it anyway would leave the caller holding a project
        whose ``rom_size_id`` disagrees with ``project.json`` until it is
        reopened, so a managed graphics file is refused here instead;
        :meth:`save_graphics` is the way one is written, and it hands the
        grown project back.
        """
        resources = [
            (self.resource_for(relative), relative, raw) for relative, raw in pairs
        ]
        managed = self.graphics_region if self.graphics_managed else None
        for resource, relative, _raw in resources:
            if managed is not None and resource.region == managed:
                raise ProjectError(
                    f"{relative} is one of the managed graphics, which are "
                    f"saved through save_graphics: a bank the save needs is "
                    f"the caller's to take"
                )
        written, needed = self._save_resources(resources)
        # Excluded above, so the only way a bank could be wanted is gone.
        assert needed is None
        return written

    def _save_resources(
        self, resources: list[tuple[Packed, Path, bytes]]
    ) -> tuple[list[Path], int | None]:
        """Write compressed resources as one decision -- every one, or none
        -- and say how many graphics banks the save needs where that is more
        than the project has.

        A per-file rollback is not enough when two of them share a region: the
        first could land and the second then overflow, leaving half an edit
        saved. So every file is recorded before the first write, every touched
        region is priced once after the last, and any overflow restores **all**
        of it before the :class:`~smw_tools.packed.RegionFull` leaves -- a
        refused save is not a save, whatever it spanned.

        The graphics region is priced two ways. On a stock cartridge it is the
        run's budget (:meth:`region_usage`); where the graphics are managed
        it is the packer (:meth:`graphics_packing`), and a packing the
        project's banks cannot hold but one bank more can is not refused:
        the count comes back for the caller to take, the way a feature switch
        raises the cartridge size rather than telling someone to
        (:meth:`_graphics_banks_needed`).

        The one write path, :meth:`save_raw`'s single file included. Metadata
        is the caller's, so a save of several parts stamps once.
        """
        for resource, _relative, raw in resources:
            resource.check(raw)

        written = [self.overlay / RAW_NAME / relative for _r, relative, _b in resources]
        held = _capture(written)
        for (_resource, _relative, raw), destination in zip(
            resources, written, strict=True
        ):
            destination.parent.mkdir(parents=True, exist_ok=True)
            _write_atomic(destination, raw)

        managed = self.graphics_region if self.graphics_managed else None
        needed: int | None = None
        try:
            for region in sorted({resource.region for resource, _r, _b in resources}):
                if region == managed:
                    needed = self._graphics_banks_needed()
                    continue
                used, budget = self.region_usage(region)
                if used > budget:
                    raise packed.RegionFull(region, used, budget)
        except (packed.RegionFull, ProjectError):
            # Put back exactly what was there, all of it: a refused save is
            # not a save.
            _restore(held)
            raise
        return written, needed

    def revert_raw(self, relative: Path) -> Path | None:
        """Take a resource back out of the overlay. Deleting the file is the
        revert, exactly as it is for a level."""
        held = self.overlay / RAW_NAME / relative
        if not held.is_file():
            return None
        held.unlink()
        self._write_metadata({"modified": _now()})
        return held

    @_scanned
    def raw_edits(self) -> list[Path]:
        """Every compressed resource this project has changed, by its key.

        A directory walk rather than a comparison, for the reason
        :attr:`changed` gives: the overlay *is* the diff. Anything under
        :data:`RAW_NAME` the registry does not recognise is skipped rather than
        raising -- a stray file is not a reason a project cannot be built.

        The walk is a `stat` per file under the raw overlay, and one patch
        gather asks for it more than once, so it is answered once per gather
        (:func:`_scanned`) -- and never longer, since the folder is one a tile
        editor writes into behind this process's back.
        """
        root = self.overlay / RAW_NAME
        if not root.is_dir():
            return []
        known = self.packed_resources()
        return sorted(
            relative
            for found in root.rglob("*")
            if found.is_file() and (relative := found.relative_to(root)) in known
        )

    # -- graphics, which are the same thing with a friendlier name -----------

    @property
    def graphics_set(self) -> str:
        """The asset set this project's build reads its graphics from."""
        return graphics.set_for(self.target_id)

    @property
    def graphics_region(self) -> str:
        """The compressed-resource region its 52 files make up
        (:func:`smw_tools.packed.graphics_region`), which is what
        :meth:`region_usage` prices and what a :class:`RegionFull` names."""
        return packed.graphics_region(self.graphics_set)

    def graphics_key(self, number: int, version: str | None = None) -> Path:
        """The :meth:`raw` key for graphics file ``number``, stock or added.

        ``version`` defaults to the project's own target, whose asset set is
        what its build actually reads.

        An added file is keyed by the name the project keeps it under rather
        than by its slot (:meth:`added_graphics_slots`): the stream still
        reaches the build as ``GFXnn.lz2``, and this is where the raw form is
        filed.
        """
        directory = graphics.set_for(version or self.target_id)
        # The record is this project's target's, so another version's set is
        # asked for by the slot's own name -- a stock file's key, and the only
        # thing an added number could mean over a set the project does not read.
        name = (
            self.added_graphics_slots().get(number)
            if number not in graphics.FILE_NUMBERS and directory == self.graphics_set
            else None
        )
        try:
            return packed.graphics_raw_key(directory, number, name)
        except GraphicsMemoryError as error:
            raise ProjectError(str(error)) from error

    def graphics(self, number: int, version: str | None = None) -> bytes:
        return self.raw(self.graphics_key(number, version))

    def save_graphics(
        self, number: int, raw: bytes, version: str | None = None
    ) -> GraphicsSaved:
        """Write a graphics file's raw form, stock or added, priced the way
        the next build will place it -- and hand back the project, which is
        a new one where the save took a graphics bank
        (:class:`GraphicsSaved`)."""
        key = self.graphics_key(number, version)
        if number not in graphics.FILE_NUMBERS and number not in self.added_graphics():
            raise ProjectError(
                f"GFX{number:02X} is not a file this project adds; add it first"
            )
        (path,), needed = self._save_resources([(self.resource_for(key), key, raw)])
        return self._graphics_saved(number, path, needed)

    def revert_graphics(self, number: int, version: str | None = None) -> Path | None:
        """Put a stock file back to the shipped stream: the overlay's raw
        form comes out. An added file has no shipped stream to come back to
        and is refused: taking it out is :meth:`delete_graphics`."""
        if number in self.added_graphics():
            raise ProjectError(
                f"GFX{number:02X} was added by this project; there is nothing "
                f"to revert it to -- delete it instead"
            )
        return self.revert_raw(self.graphics_key(number, version))

    # -- the managed graphics banks, and the files a project adds --------------

    @property
    def graphics_managed(self) -> bool:
        """Whether this project's **next build** packs its graphics files --
        the ``managed-graphics-memory`` feature, switched on here or built
        into the base -- for the reason :attr:`level_memory_managed` gives:
        a save is priced against the build that will assemble it, and the
        fragments are written for that build."""
        return graphics_memory.is_managed(self.next_base)

    @property
    def graphics_banks(self) -> int:
        """How many graphics banks this project's build reserves, a
        ``project.json`` setting like the cartridge size: one unless a save
        needed more (:meth:`save_graphics`), and never lowered by anything
        but :meth:`set_graphics_banks`. Read with the feature off too, since
        the count is the project's and the switch is what reads it."""
        held = self.metadata.get("graphics_banks")
        if isinstance(held, bool) or not isinstance(held, int) or held < 1:
            return graphics_memory.DEFAULT_BANK_COUNT
        return held

    def set_graphics_banks(self, banks: int) -> Project:
        """Record a graphics bank count, raise the cartridge to the size the
        last bank exists in, and hand back the project that builds it.

        Lowering the count is refused while the packing needs it
        (:class:`GraphicsBanksFull`); the cartridge is never shrunk back, for
        the reason a feature switch does not. With the feature off the count
        is recorded and nothing else: the switch is what reads it, and its
        migration is what sizes the cartridge for it.
        """
        if banks < 1:
            raise ProjectError("the managed graphics need at least one bank")
        try:
            wanted = graphics_memory.rom_size_for(self.next_base, banks)
        except GraphicsMemoryError as error:
            raise ProjectError(str(error)) from error
        if self.graphics_managed and banks < self.graphics_banks:
            packing = self.graphics_packing(banks)
            if not packing.fits:
                raise GraphicsBanksFull(packing)
        self._write_metadata({"graphics_banks": banks, "modified": _now()})
        if (
            self.graphics_managed
            and ROM_SIZES[self.rom_size_id].size < ROM_SIZES[wanted].size
        ):
            return self.set_rom_size(wanted)
        return self

    def added_graphics_slots(self) -> dict[int, str]:
        """Which slot each of this project's added graphics files packs into,
        and what its raw file is called: ``{0x34: "cave-tiles.bin"}``, in slot
        order.

        **The raw file is still the add**, and deleting it is still the
        delete: this is a directory read of the set's raw folder, every
        ``.bin`` in it whose length is one an added file decompresses to
        (:func:`smw_tools.packed.format_for_size`). What is *recorded* is the
        one thing a file's bytes cannot say -- which slot it packs into
        (:data:`ADDED_GRAPHICS_KEY` in ``project.json``) -- and that record is
        the editor's alone: the cartridge only ever sees ``GFXnn``, since the
        asm builds both the stream's ``incbin`` path and the pointer table's
        label out of the slot.

        A file the record does not name keeps the slot its own name spells,
        which is what a file nobody has renamed is called and what a project
        written before there were names holds throughout. A file whose name
        spells nothing and that nothing names is a stray the build does not
        read, and a Source Files row says so -- as is one whose slot the
        record has already given away.
        """
        return {number: name for number, (name, _fmt) in self._added_scan().items()}

    @_scanned
    def _added_scan(self) -> dict[int, tuple[str, TileFormat]]:
        """One reading of the set's raw folder against the record: the name
        and the format of every added file, by slot. The one scan
        :meth:`added_graphics_slots` and :meth:`added_graphics` are views
        over, so a caller that wants both pays for one, and answered once
        per gather (:func:`_scanned`) so one patch set pays for one."""
        folder = self.graphics_folder()
        if not folder.is_dir():
            return {}
        # A stock 3bpp file's raw form is an added 3bpp file's length, so what
        # keeps the set's own copies out of this is their names.
        sized = {
            path.name: size
            for path in sorted(folder.glob("*.bin"))
            if not _stock_name(path.stem) and (size := _added_size(path)) is not None
        }
        found: dict[int, tuple[str, int]] = {}
        for number, name in self.added_graphics_record().items():
            if name in sized and number not in found:
                found[number] = (name, sized[name])
        named = {name for name, _size in found.values()}
        for name, size in sized.items():
            number = _slot_spelled(Path(name).stem)
            if number is not None and number not in found and name not in named:
                found[number] = (name, size)
        return dict(sorted(found.items()))

    @_remembered
    def added_graphics_record(self) -> dict[int, str]:
        """The recorded slot of each added graphics file, straight from
        ``project.json`` and believed no further: a name it holds whose file
        is gone says nothing, and :meth:`added_graphics_slots` is the reading
        every caller wants. Every write that moves a file rewrites this from
        that reading, so a stale entry lives until the next one."""
        held = self.metadata.get(ADDED_GRAPHICS_KEY)
        if not isinstance(held, dict):
            return {}
        found: dict[int, str] = {}
        for key, name in held.items():
            try:
                number = int(str(key), 16)
            except ValueError:
                continue
            if graphics_memory.addable(number) and isinstance(name, str) and name:
                found[number] = name
        return dict(sorted(found.items()))

    def _write_added_graphics_record(self, slots: Mapping[int, str]) -> None:
        """Record which slot each added file packs into. Written from a whole
        reading rather than edited entry by entry, so a record that had drifted
        from the folder is right again after any write that moves a file."""
        self._write_metadata(
            {
                ADDED_GRAPHICS_KEY: {
                    f"0x{number:02X}": name for number, name in sorted(slots.items())
                },
                "modified": _now(),
            }
        )

    def graphics_folder(self) -> Path:
        """The folder the overlay keeps this project's own raw copies of the
        set's graphics files in -- stock, added and a tile editor's sidecars
        alike, since the set is one folder."""
        return (
            self.overlay
            / RAW_NAME
            / packed.graphics_raw_key(
                self.graphics_set, graphics_memory.FIRST_ADDED
            ).parent
        )

    def added_graphics(self) -> dict[int, TileFormat]:
        """The graphics files this project adds, layout by slot, in slot
        order, ``GFX34``-``GFXFE``.

        The slots are :meth:`added_graphics_slots`' and the layout is read
        off the one fact a file's bytes carry, its length
        (:func:`smw_tools.packed.format_for_size`). Two of the three shapes
        a file may be are the same layout in different lengths, so a caller
        that needs to know which file it has asks
        :meth:`added_graphics_sizes` instead.
        """
        return {
            number: fmt
            for number, size in self.added_graphics_sizes().items()
            if (fmt := packed.format_for_size(size)) is not None
        }

    def added_graphics_sizes(self) -> dict[int, int]:
        """What each added file decompresses to, by slot: the whole of what
        the project records about a file's shape, since the length is what
        tells the shapes apart (:func:`smw_tools.packed.shape_for_size`)."""
        return {number: size for number, (_name, size) in self._added_scan().items()}

    def add_graphics(
        self, number: int | None, raw: bytes, fmt: TileFormat
    ) -> GraphicsSaved:
        """Bring a new graphics file into the project, and say what happened.

        ``number`` is the file's, ``GFX34``-``GFXFE``, or ``None`` for the
        lowest free one; ``raw`` is its decompressed form, exactly what
        ``fmt`` decompresses to. The file alone changes nothing in a build:
        its stream enters the ROM through the managed graphics banks'
        added-files fragment (:meth:`sync_graphics_fragments`), packed after
        the game's own, and its format through the formats fragment. So the
        add needs the ``managed-graphics-memory`` feature, and is refused up
        front on a project without it -- a stock build has no row to name
        the file and no run to put it in.

        Priced before it lands, as every graphics save is: a file the banks
        cannot hold is :class:`GraphicsBanksFull` and nothing is written; one
        that needs a bank more takes it (:class:`GraphicsSaved`).
        """
        if not self.graphics_managed:
            raise ProjectError(
                "a new graphics file is packed into the managed graphics banks; "
                "turn on Growable graphics under Project > Features first"
            )
        added = self.added_graphics()
        if number is None:
            free = (
                one
                for one in range(
                    graphics_memory.FIRST_ADDED, graphics_memory.LAST_ADDED + 1
                )
                if one not in added and graphics_memory.addable(one)
            )
            number = next(free, None)
            if number is None:
                raise ProjectError(
                    f"every file number GFX{graphics_memory.FIRST_ADDED:02X}-"
                    f"GFX{graphics_memory.LAST_ADDED:02X} is taken"
                )
        else:
            try:
                graphics_memory.check_added_number(number)
            except GraphicsMemoryError as error:
                raise ProjectError(str(error)) from error
            if number in added:
                raise ProjectError(
                    f"GFX{number:02X} is already a file this project adds; "
                    f"save over it, or delete it first"
                )
        shape = packed.shape_for_size(len(raw))
        if shape is None or shape.format is not fmt:
            shapes = ", ".join(
                f"{one.size:#x} bytes ({one.name})" for one in packed.ADDED_SHAPES
            )
            raise ProjectError(
                f"a graphics file a project adds is {shapes}; got {len(raw):#x} "
                f"bytes of {fmt.name}"
            )
        name = added_graphics_name(number)
        if any(
            held.lower() == name.lower()
            for held in self.added_graphics_slots().values()
        ):
            raise ProjectError(
                f"{name} is already a graphics file this project holds; rename "
                f"it, or add the new file under another number"
            )
        (resource,) = packed.added_graphics(
            self.graphics_set, {number: shape.size}, names={number: name}
        )
        key = resource.raw_relative
        (path,), needed = self._save_resources([(resource, key, raw)])
        self._write_added_graphics_record(self.added_graphics_slots())
        self.sync_graphics_fragments()
        return self._graphics_saved(number, path, needed)

    def rename_graphics(self, number: int, name: str) -> Path:
        """Give the added graphics file in slot ``number`` the file name
        ``name``, and say where it now is.

        Its bytes do not move and neither does its slot, so nothing the
        cartridge reads changes: the stream still reaches the build as
        ``GFXnn.lz2``, the fragments still name the slot, and the packing is
        the packing it was. What changes is what the project keeps the file
        under -- the file itself, a tile editor's sidecar beside it, and the
        record that says which slot the name packs into
        (:meth:`added_graphics_slots`).

        The name is checked as a file name (:func:`check_graphics_name`): a
        name and not a path, and not one the set's raw folder already holds.
        """
        if not self.graphics_managed:
            raise ProjectError(
                "an added graphics file is packed into the managed graphics "
                "banks; turn on Growable graphics under Project > Features first"
            )
        slots = self.added_graphics_slots()
        if number not in slots:
            raise ProjectError(f"GFX{number:02X} is not a file this project adds")
        folder = self.graphics_folder()
        held = folder / slots[number]
        wanted = folder / check_graphics_name(
            name, [found.name for found in folder.glob("*") if found != held]
        )
        if wanted == held:
            return held
        _write_atomic(wanted, held.read_bytes())
        held.unlink()
        sidecar = held.with_suffix(SIDECAR_SUFFIX)
        if sidecar.is_file():
            _write_atomic(wanted.with_suffix(SIDECAR_SUFFIX), sidecar.read_bytes())
            sidecar.unlink()
        self._write_added_graphics_record({**slots, number: wanted.name})
        return wanted

    def reposition_graphics(self, number: int, to: int) -> GraphicsSaved:
        """Pack the added graphics file in slot ``number`` into slot ``to``
        instead, and say what happened.

        Neither its bytes nor its name change; what changes is the slot the
        record gives it, which is the slot the fragments name and the label
        the pointer table's row carries. A file nobody has named is called
        after the slot it sits in (:func:`added_graphics_name`), so that one
        is renamed with the move -- an unnamed file goes on looking unnamed
        rather than spelling a slot it left.

        Priced like the add it re-does, and refused the same way: the packing
        is in slot order, so a file that moves moves every file after it, and
        a packing the banks cannot hold puts the record back before
        :class:`GraphicsBanksFull` leaves. One that needs a bank more takes
        it, exactly as a save does.

        **Nothing else is rewritten.** A level's graphics row names a file by
        slot (:mod:`shiny_mushroom.level_graphics`), and a level that named
        the old one now names a file the cartridge has not got: which levels
        those are is :meth:`level_graphics`' to answer and the caller's to
        say, since a reposition that quietly rewrote level containers would be
        editing levels nobody asked it to open.
        """
        if not self.graphics_managed:
            raise ProjectError(
                "an added graphics file is packed into the managed graphics "
                "banks; turn on Growable graphics under Project > Features first"
            )
        slots = self.added_graphics_slots()
        if number not in slots:
            raise ProjectError(f"GFX{number:02X} is not a file this project adds")
        if to == number:
            raise ProjectError(f"GFX{number:02X} is already in that slot")
        try:
            graphics_memory.check_added_number(to)
        except GraphicsMemoryError as error:
            raise ProjectError(str(error)) from error
        if to in slots:
            raise ProjectError(
                f"GFX{to:02X} is already a file this project adds; delete it first"
            )
        folder = self.graphics_folder()
        held = folder / slots[number]
        # A file nobody named is named after its slot, and follows it.
        wanted = (
            folder / added_graphics_name(to)
            if held.name == added_graphics_name(number)
            else held
        )
        sidecar = held.with_suffix(SIDECAR_SUFFIX)
        moved = wanted.with_suffix(SIDECAR_SUFFIX)
        # Captured before the first write, as every save that can be refused
        # is: what goes back is the four paths exactly as they were.
        before = _capture([held, wanted, sidecar, moved])
        was = self.added_graphics_record()
        if wanted != held:
            _write_atomic(wanted, held.read_bytes())
            held.unlink()
            if before[sidecar] is not None:
                _write_atomic(moved, before[sidecar])
                sidecar.unlink()
        moved_slots = {n: name for n, name in slots.items() if n != number}
        moved_slots[to] = wanted.name
        self._write_added_graphics_record(moved_slots)
        self.sync_graphics_fragments()
        try:
            needed = self._graphics_banks_needed()
        except GraphicsBanksFull:
            _restore(before)
            self._write_added_graphics_record(was)
            self.sync_graphics_fragments()
            raise
        return self._graphics_saved(to, wanted, needed)

    def delete_graphics(self, number: int) -> Path:
        """Take an added graphics file out of the project -- the raw file and
        a tile editor's sidecar beside it -- and say which file moved. The
        fragments follow (:meth:`sync_graphics_fragments`)."""
        if not self.graphics_managed:
            raise ProjectError(
                "an added graphics file is packed into the managed graphics "
                "banks; turn on Growable graphics under Project > Features first"
            )
        slots = self.added_graphics_slots()
        if number not in slots:
            raise ProjectError(f"GFX{number:02X} is not a file this project adds")
        held = self.graphics_folder() / slots[number]
        held.unlink()
        held.with_suffix(SIDECAR_SUFFIX).unlink(missing_ok=True)
        self._write_added_graphics_record(
            {n: name for n, name in slots.items() if n != number}
        )
        self.sync_graphics_fragments()
        return held

    def sync_graphics_fragments(self) -> list[Path]:
        """Bring the added-graphics fragments in step with the project, and
        say which files moved.

        The two fragments the managed graphics banks read
        (``Config/ManagedGraphicsMemory.asm``): the added files, one line
        each, and the format of each that is 4bpp. Both are derived from
        :meth:`added_graphics`, so every flow that adds or deletes a file
        calls this, and a fragment that would say what the disassembly's
        stock copy says -- no files, no 4bpp files -- has no overlay copy.

        No metadata stamp of its own: the callers are already saves.
        """
        sizes = self.added_graphics_sizes()
        wanted: dict[Path, str | None] = {
            graphics_memory.ADDED_FRAGMENT: None,
            graphics_memory.FORMATS_FRAGMENT: None,
        }
        if sizes:
            wanted[graphics_memory.ADDED_FRAGMENT] = added_graphics_fragment(sizes)
        if any(
            (shape := packed.shape_for_size(size)) is not None
            and shape.code != graphics_memory.FORMAT_3BPP
            for size in sizes.values()
        ):
            wanted[graphics_memory.FORMATS_FRAGMENT] = graphics_formats_fragment(sizes)
        return self._sync_fragments(wanted)

    def graphics_sizes(
        self, overriding: Mapping[int, int] | None = None
    ) -> dict[int, int]:
        """What the build will write for every graphics file, by number:
        the shipped stream's size for an unedited stock file, the
        re-encoding's for an edited one, the encoding's for an added one --
        and ``overriding``'s where a save is pricing what it is about to
        write. A stock file the assets do not hold counts nothing, as
        :meth:`region_usage` leaves it out."""
        sizes: dict[int, int] = {}
        known = self.packed_resources()
        for number in graphics.FILE_NUMBERS:
            sizes[number] = self._priced(known[self.graphics_key(number)])[1]
        for resource in self._added_packed():
            number = int(resource.relative.stem[3:], 16)
            sizes[number] = self._priced(resource)[1]
        if overriding:
            sizes.update(overriding)
        return sizes

    def graphics_packing(
        self, banks: int | None = None, overriding: Mapping[int, int] | None = None
    ) -> GraphicsPacking:
        """Where the managed graphics banks put every file this project's
        build inserts, with ``banks`` graphics banks -- the project's count
        unless a save is asking about one more -- over :meth:`graphics_sizes`
        with ``overriding`` applied."""
        if banks is None:
            banks = self.graphics_banks
        try:
            runs = graphics_memory.runs_for(self.next_base, banks)
        except GraphicsMemoryError as error:
            raise ProjectError(str(error)) from error
        return GraphicsPacking.make(banks, runs, self.graphics_sizes(overriding))

    def _graphics_banks_needed(self) -> int | None:
        """How many graphics banks the overlay as it stands needs, where
        that is more than the project has: ``None`` when the packing fits,
        one more when that holds it, :class:`GraphicsBanksFull` otherwise.

        One more and never further: a save writes one file, and no file is
        larger than a bank, so a packing one bank more cannot hold is not
        this save's to fix.
        """
        banks = self.graphics_banks
        packing = self.graphics_packing(banks)
        if packing.fits:
            return None
        if packing.split_player:
            raise GraphicsBanksFull(packing)
        try:
            more = self.graphics_packing(banks + 1)
        except ProjectError:
            raise GraphicsBanksFull(packing) from None
        if not more.fits:
            raise GraphicsBanksFull(packing)
        return banks + 1

    def _graphics_saved(
        self, number: int, path: Path, needed: int | None
    ) -> GraphicsSaved:
        """The result of a graphics save, the bank taken where the save
        needed one -- which stamps the metadata itself."""
        before = self.graphics_banks
        if needed is not None and needed != before:
            grown = self.set_graphics_banks(needed)
            return GraphicsSaved(number, path, grown, needed, raised_from=before)
        self._write_metadata({"modified": _now()})
        return GraphicsSaved(number, path, self, before)
