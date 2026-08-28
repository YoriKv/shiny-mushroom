"""Every compressed file the build reads, and how to get at what is inside it.

Three formats, two trees, one rule: **the file the build reads is compressed,
and the form worth editing is not.** So each of these has a *baseline* -- the
bytes as shipped -- and a *raw form*, and this module is the registry that says
which is which and which codec joins them.

| Format | Files | Where |
|---|---|---|
| LZ1 / LZ2 | 52 x 3 sets | `assets/GFX/<set>/` |
| LC_RLE1 | 17 Layer 2 background tilemaps | `SMW/levels/backgrounds/` |
| LC_RLE1 | overworld Layer 2 event properties | `SMW/overworld/layer2/events/` |
| LC_RLE2 | overworld Layer 2 tilemap, two streams | `SMW/overworld/layer2/` |

Nothing else in the tree is compressed. The `images/` trees are **stripe
images** -- a VRAM upload command stream, not compression -- the music sequences
and every table are stored plainly, and the BRR samples are compressed but
*lossily*, so they have no raw form that round-trips and are deliberately absent
here.

**The raw overlay path is the destination with a `.bin` suffix.** For the RLE
files that changes nothing; for graphics it turns `GFX00.lz2` into `GFX00.bin`,
which keeps a raw file from wearing a compressed file's extension. One rule, so
the mapping is reversible without a second table.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from . import compression, graphics, graphics_memory, rle, rom_map
from .bases import VANILLA, BuildTarget
from .bases import base as default_base
from .compression import Family
from .graphics import TileFormat
from .rle import Variant

#: What the overlay files the two base trees under -- the same names
#: :attr:`shiny_mushroom.project.Project.roots` uses, because the raw side
#: mirrors the shadowing side.
ASSETS_ROOT = "assets"
GAME_ROOT = "SMW"

#: Where the overworld's Layer 2 tilemap streams decode to. LC_RLE2 carries no
#: terminator, so this is not a check but the only thing that ends a decode:
#: `CODE_04DABA` stops when its write cursor reaches `$4000`, and at a stride of
#: two that is `$2000` bytes of payload.
OVERWORLD_LAYER2_SIZE = 0x2000

#: What the event properties stream decodes to: one `YXPCCCTT` byte for every
#: byte of the two stamp sheets -- `$900` of 6x6 blocks plus `$400` of 2x2 --
#: so a property is found at its tile's own sheet offset. `CODE_04DD57` decodes
#: until the stream's terminator; the sheets are what fix the size.
OVERWORLD_EVENT_PROPS_SIZE = 0xD00

#: Region names. A region is the run of ROM one macro fills, so every file in
#: one is bounded by the group's total rather than by its own size -- see
#: :func:`budget`. Graphics get one per asset set, since a build reads one set.
BACKGROUNDS = "levels/backgrounds"
OVERWORLD_LAYER2 = "overworld/layer2"
OVERWORLD_EVENTS = "overworld/layer2/events"


def graphics_region(directory: str) -> str:
    """The region name of one asset set's 52 files."""
    return f"graphics:{directory}"


#: Region -> ``(the macro that emits its run, the padding macro fitted behind
#: it)``, for the regions the ROM map closes with a `%SMW_FitOriginalFreespace`
#: fill. A fitted fill takes whatever is left of its run rather than a fixed
#: place in it, so the run in front may grow into it with no map change -- and
#: that slack is part of the region's budget (:func:`fitted_tail`).
#:
#: The other two regions have none: the backgrounds are two runs each abutting
#: code (`DATATABLE_RT01_SMW_Backgrounds` runs into
#: `DATATABLE_SMW_CastleDestructionText`, `RT02` into
#: `ROUTINE_RT04_SMW_LoadOverworldLayer1AndEvents`), and the overworld Layer 2
#: pair runs into `ROUTINE_RT01_SMW_LoadOverworldLayer1AndEvents`.
FITTED_TAILS: dict[str, tuple[str, str]] = {
    **{
        graphics_region(directory): (
            "DATATABLE_SMW_CompressedGraphics",
            "INLINEDATATABLE_RT34_SMW_EmptySpace",
        )
        for directory in set(graphics.SETS.values())
    },
    OVERWORLD_EVENTS: (
        "DATATABLE_SMW_OverworldLayer2EventTilemap",
        "INLINEDATATABLE_RT35_SMW_EmptySpace",
    ),
}


class PackedError(ValueError):
    """A compressed resource that is not what the registry says it is."""


class RegionFull(PackedError):
    """A region's files no longer fit the run of ROM they are assembled into."""

    def __init__(self, region: str, used: int, budget: int) -> None:
        self.region = region
        self.used = used
        self.budget = budget
        super().__init__(
            f"{region} needs {used:,} bytes and has {budget:,}: "
            f"{used - budget:,} too many"
        )


@dataclass(frozen=True)
class Packed:
    """One compressed file: where it lives, and how to open and close it."""

    #: Which base tree, :data:`ASSETS_ROOT` or :data:`GAME_ROOT`.
    root: str
    #: Path within that tree -- the compressed file the build actually reads.
    relative: Path
    #: ``None`` for the LZ family, a variant for the RLE ones.
    variant: Variant | None = None
    #: The LZ family member, for graphics.
    family: Family | None = None
    #: What it must decompress to, where that is fixed. ``None`` means "whatever
    #: the baseline decodes to" -- true of the backgrounds, which are `$360` or
    #: `$361` bytes depending on the file.
    raw_size: int | None = None
    #: The run of ROM this shares with its neighbours. Files in one region are
    #: concatenated by a single macro that `RomMap/` places at a fixed address,
    #: so what bounds them is the **sum** of the group -- see :func:`budget`.
    region: str = ""
    #: A graphics file the project adds under the managed graphics banks
    #: (:mod:`smw_tools.graphics_memory`): no stream of it ships, so its
    #: baseline never exists, :meth:`encode` packs it from scratch, and it is
    #: packed by the banks rather than budgeted in its region -- :func:`budget`
    #: and every reader of a region leave it out, as they do any file with no
    #: baseline. Named for the set's region all the same, so a listing groups
    #: it with the files it is packed behind.
    added: bool = False
    #: The raw form's file name where that is not the compiled file's own --
    #: an added graphics file, and nothing else. Its stream has to reach the
    #: build under the slot it packs into, since the asm builds both the
    #: `incbin` path and the pointer table's label out of ``GFXnn``; what a
    #: project keeps the raw file under is a name somebody gave it. ``None``
    #: is the rule :attr:`raw_relative` states.
    raw_name: str | None = None

    @property
    def raw_relative(self) -> Path:
        """Where the raw form is filed, within the raw overlay root: the
        compressed file's own path with a ``.bin`` suffix, or, for a file
        carrying a :attr:`raw_name`, that name beside it."""
        if self.raw_name is not None:
            return Path(self.root) / self.relative.parent / self.raw_name
        return Path(self.root) / self.relative.with_suffix(".bin")

    def baseline_path(self, game_dir: Path, assets: Path) -> Path:
        root = assets if self.root == ASSETS_ROOT else game_dir
        return root / self.relative

    def decode(self, baseline: bytes) -> bytes:
        """The raw form of ``baseline``, checked as far as it can be."""
        if self.variant is None:
            assert self.family is not None
            raw, consumed = compression.decompress(baseline, self.family)
        else:
            raw, consumed = rle.decompress(baseline, self.variant, size=self.raw_size)
        if consumed != len(baseline):
            raise PackedError(
                f"{self.relative}: {consumed} of {len(baseline)} bytes are the "
                f"structure -- the rest is not part of it"
            )
        self.check(raw)
        return raw

    def check(self, raw: bytes) -> None:
        """Refuse a raw form of the wrong length.

        Worth doing rather than trusting: a short one compresses cleanly,
        assembles cleanly, and shows up as corrupted VRAM several steps later.
        """
        if self.raw_size is not None and len(raw) != self.raw_size:
            raise PackedError(
                f"{self.relative} holds {self.raw_size:#x} bytes, got {len(raw):#x}"
            )

    def encode(self, raw: bytes, baseline: bytes | None) -> bytes:
        """``raw`` compressed, keeping ``baseline`` where it still fits.

        The byte-exactness rule: a file whose contents are unchanged is not
        re-encoded at all, so it contributes the cartridge's own bytes and a
        project that edited nothing still assembles to the pinned hashes.

        **Anything that does get encoded is packed as small as the codec can
        manage.** That is not a fallback for when something overflows -- it is
        the only sensible setting, because a file reaching the encoder has
        changed and so cannot match the cartridge however it is packed, while
        every region it might live in is full to the byte. Matching vanilla is
        already lost; fitting is not.
        """
        self.check(raw)
        if self.variant is None:
            assert self.family is not None
            if baseline is None:
                return compression.compress(raw, self.family, smallest=True)
            return compression.repack(baseline, raw, self.family, smallest=True)
        if baseline is None:
            return rle.compress(raw, self.variant, smallest=True)
        return rle.repack(
            baseline, raw, self.variant, size=self.raw_size, smallest=True
        )


@lru_cache(maxsize=1)
def _graphics() -> tuple[Packed, ...]:
    """The 52 files of each of the three asset sets.

    Cached because it is a pure function of the registry -- 156 entries built
    from constants -- and :func:`resources` is called several times per save.
    """
    return tuple(
        Packed(
            root=ASSETS_ROOT,
            relative=graphics.baseline_relative(directory, number),
            family=graphics.family_for_set(directory),
            raw_size=graphics.decompressed_size(number),
            region=graphics_region(directory),
        )
        for directory in sorted(set(graphics.SETS.values()))
        for number in graphics.FILE_NUMBERS
    )


def _overworld() -> list[Packed]:
    """The three compressed overworld tables.

    The Layer 2 pair is one 16-bit-per-tile map split into two streams that the
    decoder interleaves -- tile numbers into the even bytes, `YXPCCCTT` into the
    odd ones -- which is why they are the same size and share a variant.
    """
    layer2 = Path("overworld/layer2")
    return [
        Packed(
            GAME_ROOT,
            layer2 / "tiles.bin",
            Variant.RLE2,
            raw_size=OVERWORLD_LAYER2_SIZE,
            region=OVERWORLD_LAYER2,
        ),
        Packed(
            GAME_ROOT,
            layer2 / "properties.bin",
            Variant.RLE2,
            raw_size=OVERWORLD_LAYER2_SIZE,
            region=OVERWORLD_LAYER2,
        ),
        Packed(
            GAME_ROOT,
            layer2 / "events" / "properties.bin",
            Variant.RLE1,
            raw_size=OVERWORLD_EVENT_PROPS_SIZE,
            region=OVERWORLD_EVENTS,
        ),
    ]


def _backgrounds(game_dir: Path) -> list[Packed]:
    """Every Layer 2 background tilemap.

    Read off the directory rather than listed, because the rule really is "every
    file here is LC_RLE1" -- `Banks/Bank0C.asm` says so over each one -- and a
    list would be a second copy of the directory that could disagree with it.
    """
    directory = game_dir / "levels" / "backgrounds"
    if not directory.is_dir():
        return []
    return [
        Packed(
            GAME_ROOT,
            Path("levels/backgrounds") / path.name,
            Variant.RLE1,
            region=BACKGROUNDS,
        )
        for path in sorted(directory.glob("*.bin"))
    ]


@dataclass(frozen=True)
class AddedShape:
    """One shape a file a project adds may be: a layout, a length, and the
    code the managed graphics banks' format table speaks for the pair
    (:data:`graphics_memory.FORMAT_3BPP` and the rest).

    **The length is what tells them apart**, which is why this is a shape
    rather than a format: two of the three are 3bpp and differ only in how
    many tiles they hold, so a project reads a file's shape off its bytes
    (:func:`shape_for_size`) and never has to record it.
    """

    code: int
    format: TileFormat
    #: What it decompresses to, in bytes.
    size: int
    #: What it is, in the words a dialog offers it in.
    name: str

    @property
    def tiles(self) -> int:
        """How many tiles it holds."""
        return self.size // self.format.tile_bytes

    @property
    def fits_a_slot(self) -> bool:
        """Whether the uploader can put it in one of the eight VRAM slots --
        128 tiles, the two the upload stub distinguishes. The animated
        tiles' shape is the one that cannot: it is larger than a slot and
        larger than the decompression buffer, and reaches WRAM by another
        path entirely (:data:`graphics_memory.FIRST_STAGED_FORMAT`)."""
        return self.code < graphics_memory.FIRST_STAGED_FORMAT


#: The shapes a file a project adds may be, in the order a dialog offers
#: them. The 2bpp and Mode 7 layouts stay the fixed-number files': nothing a
#: project adds is loaded by a path that reads either.
ADDED_SHAPES: tuple[AddedShape, ...] = (
    AddedShape(
        graphics_memory.FORMAT_3BPP,
        TileFormat.PLANAR_3BPP,
        graphics_memory.decompressed_size(graphics_memory.FORMAT_3BPP),
        "3bpp, a slot's 128 tiles",
    ),
    AddedShape(
        graphics_memory.FORMAT_4BPP,
        TileFormat.PLANAR_4BPP,
        graphics_memory.decompressed_size(graphics_memory.FORMAT_4BPP),
        "4bpp, a slot's 128 tiles",
    ),
    AddedShape(
        graphics_memory.FORMAT_ANIMATED,
        TileFormat.PLANAR_3BPP,
        graphics_memory.decompressed_size(graphics_memory.FORMAT_ANIMATED),
        "3bpp, the animated tiles' 384",
    ),
)

#: The two shapes a VRAM slot can load, by format -- what an added file is
#: unless it is made to be a level's animated tiles.
ADDED_FORMATS: dict[int, TileFormat] = {
    shape.code: shape.format for shape in ADDED_SHAPES if shape.fits_a_slot
}


def shape_for_size(size: int) -> AddedShape | None:
    """The shape an added raw file of ``size`` bytes is, or ``None`` for a
    length no shape decompresses to."""
    for shape in ADDED_SHAPES:
        if shape.size == size:
            return shape
    return None


def shape_for_format(fmt: TileFormat) -> AddedShape:
    """The slot-shaped file of ``fmt``, or :class:`PackedError` for a layout
    an added file cannot have. The animated tiles' shape is never this
    answer -- it is asked for by length, since it shares its layout."""
    for shape in ADDED_SHAPES:
        if shape.fits_a_slot and shape.format is fmt:
            return shape
    names = ", ".join(held.name for held in ADDED_FORMATS.values())
    raise PackedError(f"an added graphics file is {names}, not {fmt.name}")


def format_code(fmt: TileFormat) -> int:
    """The format table's code for a slot-shaped file of ``fmt``."""
    return shape_for_format(fmt).code


def added_raw_size(fmt: TileFormat) -> int:
    """What a slot-shaped added file of ``fmt`` decompresses to."""
    return shape_for_format(fmt).size


def format_for_size(size: int) -> TileFormat | None:
    """The layout an added raw file of ``size`` bytes is in, or ``None`` for
    a length no shape decompresses to. What the file *is* takes the length
    too (:func:`shape_for_size`); this is the layout alone, which is what
    reading its tiles needs."""
    shape = shape_for_size(size)
    return None if shape is None else shape.format


def graphics_raw_key(directory: str, number: int, name: str | None = None) -> Path:
    """The raw overlay key of graphics file ``number`` of ``directory``'s set,
    stock or added: the compressed destination under :data:`ASSETS_ROOT` with
    a ``.bin`` suffix, the one rule :attr:`Packed.raw_relative` states.

    ``name`` is the file name an added file is kept under where that is not
    the slot's own -- :attr:`Packed.raw_name`, and the same key it gives.
    """
    if number in graphics.FILE_NUMBERS:
        relative = graphics.baseline_relative(directory, number)
    else:
        relative = graphics_memory.asset_relative(directory, number)
    if name is not None:
        return Path(ASSETS_ROOT) / relative.parent / name
    return Path(ASSETS_ROOT) / relative.with_suffix(".bin")


def added_graphics(
    directory: str,
    added: Mapping[int, int],
    names: Mapping[int, str] | None = None,
) -> list[Packed]:
    """The resources of the files a project adds to ``directory``'s set --
    raw size by file number -- in number order, each :attr:`Packed.added`.

    Nothing here is read off a registry literal: which numbers exist is the
    project's, and its own bytes say how long each is where the stock table
    says a stock file's. ``names`` is what the project keeps each raw file
    under where that is not the slot's own name.
    """
    held = names or {}
    return [
        Packed(
            root=ASSETS_ROOT,
            relative=graphics_memory.asset_relative(directory, number),
            family=graphics.family_for_set(directory),
            raw_size=size,
            region=graphics_region(directory),
            added=True,
            raw_name=held.get(number),
        )
        for number, size in sorted(added.items())
    ]


def resources(
    game_dir: Path | None = None, added: Iterable[Packed] = ()
) -> dict[Path, Packed]:
    """Every compressed resource, keyed by its path under the raw overlay root.

    ``game_dir`` is the base's game folder, so a test can point this at a
    fixture tree. ``added`` is what a project brings that ships nowhere --
    :func:`added_graphics` -- and joins the registry on the same terms.
    """
    root = default_base().game_dir if game_dir is None else game_dir
    found = [*_graphics(), *_overworld(), *_backgrounds(root), *added]
    return {packed.raw_relative: packed for packed in found}


def resource_for(
    raw_relative: Path, game_dir: Path | None = None, added: Iterable[Packed] = ()
) -> Packed:
    """The resource a raw overlay path belongs to."""
    try:
        return resources(game_dir, added)[Path(raw_relative)]
    except KeyError:
        raise PackedError(f"{raw_relative} is not a compressed resource") from None


def read_raw(
    packed: Packed, game_dir: Path | None = None, assets: Path | None = None
) -> bytes:
    """The raw form of a shipped file: its baseline, decompressed and checked."""
    path = packed.baseline_path(
        default_base().game_dir if game_dir is None else game_dir,
        default_base().assets_root if assets is None else assets,
    )
    if not path.is_file():
        raise PackedError(f"{path} is missing; the assets are not extracted")
    return packed.decode(path.read_bytes())


# -- how much room a group of files has -------------------------------------


def in_region(region: str, game_dir: Path | None = None) -> list[Packed]:
    """Every resource assembled into ``region``, in the order the macro
    concatenates them."""
    return [
        resource
        for resource in resources(game_dir).values()
        if resource.region == region
    ]


def targets_reading(region: str) -> list[BuildTarget]:
    """The vanilla targets whose build assembles ``region``: the set's readers
    for a graphics region, every release for the committed tables."""
    for directory in set(graphics.SETS.values()):
        if region == graphics_region(directory):
            return [t for t in VANILLA.targets.values() if t.asset_set == directory]
    return list(VANILLA.targets.values())


def fitted_tail(
    region: str, game_dir: Path | None = None, target: BuildTarget | None = None
) -> int:
    """How many bytes of cartridge padding ``region``'s run may grow into.

    Read off the ROM map (:mod:`smw_tools.rom_map`): the padding macro
    :data:`FITTED_TAILS` names must be the placement right after the region's
    run, and what it yields is its own `!<ROMID>Bytes` count -- the same define
    `%SMW_FitOriginalFreespace` sizes the fill from, so this cannot say one
    thing while the assembler does another. The map's placement address of the
    fill would give the same figure only by way of the baselines' sum, which is
    what this is being added *to*.

    ``target`` picks the release; ``None`` is the smallest tail among the
    releases that read the region, which is the only figure safe to promise a
    project that has not said which cartridge it builds. Zero for a region the
    map closes with something other than a fitted fill, for a ``game_dir`` with
    no map to read -- a fixture tree -- and for a map that no longer places the
    fill where the registry says: a rearranged map is a reason to say nothing,
    not to guess.
    """
    run = FITTED_TAILS.get(region)
    if run is None:
        return 0
    root = default_base().game_dir if game_dir is None else game_dir
    targets = [target] if target is not None else targets_reading(region)
    return min(_tail_of(root, one.romid, *run) for one in targets)


def _tail_of(root: Path, romid: str, run: str, fill: str) -> int:
    placed = rom_map.placements_for(root, romid)
    for before, after in zip(placed, placed[1:], strict=False):
        if before.macro == run and after.macro == fill:
            return after.free
    return 0


def budget(
    region: str,
    game_dir: Path | None = None,
    assets: Path | None = None,
    target: BuildTarget | None = None,
) -> int:
    """How many bytes ``region``'s files may occupy between them.

    **What they occupy today, plus the fitted padding behind them.** `RomMap/`
    places every macro at a hardcoded address, so a region's files are packed
    to the byte against the next thing along and growing one file by a byte is
    paid for by another in the same region shrinking. The one exception is a
    run the map closes with a `%SMW_FitOriginalFreespace` fill, which takes
    whatever is left of its run rather than a fixed place in it: the graphics
    and the overworld event properties have one (:data:`FITTED_TAILS`), so
    those regions may grow into it with no map edit and no lost byte-exactness
    for a project that does not -- the fill is still every byte it was
    (:func:`fitted_tail`). The other regions abut code and have exactly what
    they ship with.

    ``target`` is the release being built; without one the tail is the smallest
    among the releases that read the region.
    """
    root = default_base().game_dir if game_dir is None else game_dir
    asset_root = default_base().assets_root if assets is None else assets
    shipped = 0
    for resource in in_region(region, game_dir):
        # One `stat` per file, not an `is_file` and then a `stat`: on a mounted
        # drive each is a round trip, and the graphics region is 52 of them.
        try:
            shipped += resource.baseline_path(root, asset_root).stat().st_size
        except OSError:
            # A resource with no baseline is not in the build either -- asar
            # would refuse the `incbin` -- so it is left out of both sides of
            # the comparison rather than counted as nothing on one of them.
            continue
    return shipped + fitted_tail(region, root, target)
