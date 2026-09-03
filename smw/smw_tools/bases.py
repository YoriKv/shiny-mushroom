"""ROM bases: what a project is built *on*, and the targets each one assembles.

Two axes, and conflating them is the mistake this module exists to prevent:

**A base** is the assembly and assets a cartridge is built from -- a source tree,
the game folder inside it, and the framework settings that decide the ROM's
shape. There are two today: ``vanilla``, the disassembly under ``smw/src``, and
``sa1``, the same tree declaring an SA-1 cartridge.

**A target** is a variant *within* a base, selected by ``--define ROMID``. The
vanilla base has five, and they are the five shipped releases; ``sa1`` has one.

So a build is named ``<base>/<target>`` -- ``vanilla/U``, ``sa1/U`` -- and a bare
``U`` means the default base's target of that name.

## Why the axis was worth separating before there was a second base

The framework already has the seam. ``SMW/RomMap/ROM_Map_SMW_<ROMID>.asm`` is a
base declaration in all but name: it carries the cartridge header
(``!Define_Global_ROMLayout``, ``!Define_Global_CustomChip``,
``!Define_Global_ROMSize``), an empty
``SMW_LoadGameSpecificMainExtraHardwareFiles`` hook, and the 1,270-line
``SMW_LoadROMMap`` that places every routine. A restructured base -- one that
keeps the game and moves the code -- is a sixth ROM map and a sixth ROMID.

What did *not* have a seam is this side: "version" was a five-member enum with
one base baked in behind it, spread across module-level path constants. This
module is where that base becomes a value, so the paths and the build recipe can
follow it in one place rather than being rediscovered per call site.

## Two kinds of pinned hash, and only one of them may ever be rewritten

The five vanilla hashes are **No-Intro reference hashes**: claims about
cartridges that exist in the world. Adjusting one to match a build turns the gate
off, which is why :class:`Reference` has no write path at all.

A base that is not a shipped cartridge cannot make that claim. The strongest
thing it can say is that it still assembles to what it assembled to before, which
is :class:`Reproducible` -- a real check, and one that *does* move when the base
deliberately changes. Keeping the two apart in the type is what stops the second
kind's rewritability from leaking onto the first.

:mod:`rom_versions` stays the file where the No-Intro hashes are pinned. This
module reads them; it does not restate them.
"""

from __future__ import annotations

import re
from collections.abc import Iterator
from dataclasses import dataclass, field
from pathlib import Path
from typing import ClassVar

from . import pack
from .extract import GFX_SETS
from .paths import (
    ASSETS_DIR,
    SA1_PACK_ENTRY,
    SA1_PACK_ENV,
    SA1_PACK_NAMES,
    SRC_DIR,
    VENDOR_DIR,
    find_vendored_tree,
)
from .ram_map import RamMap, Sa1Ram, WorkRam
from .rom_image import RomImage, pc_to_snes, snes_to_pc
from .rom_sizes import ROM_SIZES, STOCK, bytes_label
from .rom_tables import VANILLA_TABLES, RomTable
from .rom_versions import ALL_VERSIONS, ROM_VERSIONS

#: The expansion bank a base reserves unless it says otherwise -- see
#: :attr:`RomBase.reservation_bank`. The disassembly's own default, in
#: ``Config/ReservedBank.asm``, is the same number.
RESERVATION_BANK = 0x10


class BaseError(ValueError):
    """A base or target that is not one this repository knows about."""


#: Every way a source line names a file. All three spellings are in the tree and
#: a reader that knows only one is blind to the rest: ``incbin "GFX/x.lz2"`` and
#: ``incsrc "x.asm"`` quoted, a bare ``incsrc ../RAM_Map_SMW.asm`` in the ROM
#: maps, and the quoted form the framework's ``%LoadExtraRAMFile`` expands to.
#: A label may precede the directive, and a line that only mentions one in a
#: comment does not name it.
_INCLUDE = re.compile(
    r'^\s*(?:[\w?.]+:\s*)?(?:incbin|incsrc)\s+(?:"(?P<quoted>[^"]+)"|(?P<plain>\S+))'
    r'|^\s*%LoadExtraRAMFile\(\s*"(?P<macro>[^"]+)"\s*\)',
    re.IGNORECASE,
)


@dataclass(frozen=True)
class Include:
    """One file a source line names, and where it says so."""

    #: 1-based line number within the text it was found in.
    line: int
    #: The path exactly as written, which is the whole point on a
    #: case-insensitive filesystem.
    path: str


def iter_includes(text: str) -> Iterator[Include]:
    """Every file ``text`` names, in source order.

    One reader for all three spellings. Two that each knew a different subset is
    what left the ROM maps' bare ``incsrc`` invisible to the include-casing
    check -- and those are the lines that name the memory map.
    """
    for number, raw in enumerate(text.split("\n"), start=1):
        found = _INCLUDE.match(raw)
        if found is None:
            continue
        named = found.group("quoted") or found.group("plain") or found.group("macro")
        yield Include(line=number, path=named)


# -- what a target claims about its own bytes --------------------------------


@dataclass(frozen=True)
class Expectation:
    """What a target's assembled bytes have to be, if anything.

    Subclassed rather than flagged, because the three answers differ in what may
    be *done* to them and not only in what they hold.
    """

    #: Whether this expectation is a gate at all. ``False`` means the target is
    #: checked by assembling successfully and nothing more.
    #:
    #: A class attribute rather than a field: it is a property of *which kind*
    #: of expectation this is, so a caller must not be able to pass one in.
    pinned: ClassVar[bool] = False

    #: Whether the expectation may be regenerated from a build. Only ever true
    #: for a hash this repository produced -- see the module docstring.
    writable: ClassVar[bool] = False

    def mismatches(self, image: RomImage) -> list[str]:
        """Every way ``image`` fails this expectation, most significant first.

        A list rather than a bool so a failure names what it was: a size, a
        CRC32 and a SHA-1 disagreeing are three different diagnoses.
        """
        return []


@dataclass(frozen=True)
class Reference(Expectation):
    """A hash of a cartridge that exists. **Never regenerated.**

    These are No-Intro entries, so a passing build is verifiable against any
    clean dump rather than only against us. There is deliberately no code path
    that writes one: the only way to change a reference hash is to edit
    :mod:`rom_versions` by hand, having decided that the *cartridge* was recorded
    wrongly.
    """

    crc32: str
    sha1: str
    size: int

    pinned: ClassVar[bool] = True
    writable: ClassVar[bool] = False

    def mismatches(self, image: RomImage) -> list[str]:
        found = []
        if image.size != self.size:
            found.append(f"size {image.size}, expected {self.size}")
        if image.crc32 != self.crc32:
            found.append(f"crc32 {image.crc32}, expected {self.crc32}")
        if image.sha1 != self.sha1:
            found.append(f"sha1 {image.sha1}, expected {self.sha1}")
        return found


@dataclass(frozen=True)
class Reproducible(Expectation):
    """A hash this repository produced, pinned so the base cannot drift silently.

    Not a claim about any cartridge -- there is none to be exact against -- but
    still a real gate: it catches a change that moved bytes nobody meant to move.
    It differs from :class:`Reference` in being regenerable, deliberately and by
    an explicit step, when the base is *meant* to have changed.
    """

    sha1: str
    size: int

    pinned: ClassVar[bool] = True
    writable: ClassVar[bool] = True

    def mismatches(self, image: RomImage) -> list[str]:
        found = []
        if image.size != self.size:
            found.append(f"size {image.size}, expected {self.size}")
        if image.sha1 != self.sha1:
            found.append(f"sha1 {image.sha1}, expected {self.sha1}")
        return found


@dataclass(frozen=True)
class Assembles(Expectation):
    """No pinned bytes: the target passes by assembling at all.

    For a base under development, where the layout is still moving and a pin
    would be rewritten every commit -- which is a pin that checks nothing while
    looking like one that does.
    """


# -- what the editor can do with the game's own code --------------------------


@dataclass(frozen=True)
class DrivenPaths:
    """Which paths that **call the game's own routines** work on a base.

    The editor drives the cartridge in three places -- rebuilding a level
    without a full load, making a sprite draw itself, and capturing the player
    -- and each is a claim about *our code*, not about the cartridge.

    On a base with a coprocessor the routines are still callable: SA-1 Pack
    replaces each entry point with a hijack that hands the work to the C-CPU and
    **waits for it** (``ram_sa1_call``), so the call returns having had the work
    done. What has to be true as well is that the probe around it sets up,
    traces and reads back the side the work happened on -- the direct page the
    routine is entered with, the second CPU's instruction trace, and the
    relocated spelling of the buffers the result comes out of.

    **One value rather than three loose flags** because they are one idea, and
    because everything that carries them carries all three: the editor's
    ``Addresses`` holds this whole object rather than copying a field per path,
    so a fourth driven path is one line here and none anywhere else.

    They stay separate *fields* because they were proven one at a time. An
    unproven path is declared off rather than left to be discovered, since a
    probe that comes back empty is indistinguishable from a sprite that
    legitimately draws nothing.
    """

    #: Making a sprite draw itself and reading the tiles back. Measured working
    #: on ``sa1``, tile for tile against the same sprite on ``vanilla``.
    sprite_art: bool = True

    #: Capturing what the player looks like. Hijacked the same way as the
    #: sprite capture, and measured on ``sa1`` drawing the marker vanilla draws,
    #: pixel for pixel. It was declared off there until the probe stopped
    #: reading his tiles at a fixed OAM object: entry ``n`` is object ``64 + n``
    #: only under the game's own allocator, and MaxTile composites the same two
    #: tiles to objects 125 and 126. The probe now finds them by their contents,
    #: which is a fact about the picture rather than about the allocator.
    player_art: bool = True

    #: Rebuilding a level by calling the object loop instead of loading again.
    #: Measured on ``sa1`` over 42 levels and three edits each: the shortcut
    #: answers what the game-mode path answers, and 300 chained rebuilds --
    #: past the wrap the Layer 3 scroll byte counts through -- still do. The
    #: call spends 252k of its 2.8M cycle budget at worst, fewer than vanilla's
    #: 763k, because the S-CPU's share of it is the wait.
    rebuild: bool = True


@dataclass(frozen=True)
class TracedCode:
    """Which code a base's captures watch, as ``(start, end)`` CPU addresses.

    Two probes filter a trace on the program counter, because what they are
    after is *which code wrote this byte*: the sprite capture credits a sprite
    only with the OAM its own routines stored, and the object footprints credit
    a block only to the object routine that drew it. The filter is the whole of
    that judgement -- code outside the range is invisible to the capture, and
    code inside it that the probe did not mean to watch is credited to whatever
    the probe was driving.

    **These are bank ranges, and a bank has no label.** Every other address the
    editor uses is a role in :mod:`rom_tables`, anchored to a label so a build
    that moves the table moves the address with it; there is nothing to anchor
    here, because what is being named is "every routine in these banks" rather
    than one routine. So a base that relocates the code declares its own range
    -- which is the only way it can be said at all, and the reason this is a
    declaration rather than a constant in the editor: left there, a feature
    patch that moved the code out of these banks would blind both captures
    silently, and a capture that comes back empty is indistinguishable from a
    sprite that legitimately draws nothing.

    Both defaults hold under a patch that moves *tables*, which is what a
    project's overlay does, and both are measured on ``sa1``, where the pack
    hijacks the routines to the second CPU without moving them.

    The end is **exclusive**, as :attr:`~RomBase.tables`' ``player_gfx_end``
    is.
    """

    #: Banks ``$01``-``$03``: the sprite GFX routines. Bank ``$00`` is
    #: deliberately outside it -- it holds the shared OAM helpers *and* the NMI
    #: handler, and a capture must not credit a sprite with what an interrupt
    #: wrote. Measured across three levels and 24 sprites, bank ``$00`` stores
    #: into neither OAM table during a probe, so excluding it loses nothing.
    sprite_gfx: tuple[int, int] = (0x018000, 0x040000)

    #: Bank ``$0D``: every object routine, the five per-tileset tables and the
    #: extended objects alike. The bank rather than the routines because there
    #: are 123 separate stores into the tilemap across them and no primitive
    #: they all funnel through, so naming code is the only complete way to
    #: catch every write.
    object_routines: tuple[int, int] = (0x0D0000, 0x0E0000)


# -- how a base's addresses reach the image ----------------------------------


@dataclass(frozen=True)
class AddressMap:
    """How a base's CPU addresses correspond to offsets in the ROM image.

    Every offset a caller works in is into the **headerless** image, which is
    what an emulator's ``SNES_PRG_ROM`` holds and what the pinned hashes
    describe. A ``.smc`` dump read off disk still carries its 512-byte copier
    header, and 512 bytes of skew turns a patch into an edit of whatever happens
    to be there.

    A base declares one of these because the mapping is a cartridge-level
    decision -- ``!Define_Global_ROMLayout`` in its ROM map -- and a base that
    grows past 512 KB or adds a coprocessor does not answer it the same way.
    """

    #: How the layout is spelled in the ROM map, for messages.
    id: str

    #: How many bytes of the image one CPU bank reaches.
    bank_size: int

    #: How many bytes of the image this map can spell an address for. An image
    #: may be longer -- SA-1's Super MMC reaches further than its LoROM banks do
    #: -- but an offset past this bound has no address *here*, and
    #: :meth:`address` refuses rather than inventing one.
    addressable: int

    def offset(self, address: int) -> int:
        raise NotImplementedError

    def address(self, offset: int) -> int:
        raise NotImplementedError


@dataclass(frozen=True)
class LoRom(AddressMap):
    """LoROM: the upper half of every bank maps to a slice of the file.

    Bank bit 7 is a mirror and is masked off, so ``$05E000`` and ``$85E000``
    are the same byte -- but ``$7E``/``$7F`` are work RAM and are refused. The
    arithmetic is :func:`~smw_tools.rom_image.snes_to_pc`, which is where the
    ROM image reads it too.
    """

    id: str = "LoROM"
    bank_size: int = 0x8000
    addressable: int = 0x80 * 0x8000

    def offset(self, address: int) -> int:
        return snes_to_pc(address)

    def address(self, offset: int) -> int:
        if offset >= self.addressable:
            raise ValueError(
                f"offset ${offset:06X} is past {bytes_label(self.addressable)}, "
                f"where LoROM's banks run out"
            )
        return pc_to_snes(offset)


@dataclass(frozen=True)
class Sa1LoRom(AddressMap):
    """SA-1 LoROM. Like :class:`LoRom` for the banks a level lives in, and not
    a mirror above them.

    Banks ``$00-$3F`` map exactly as LoROM does, which is why every table this
    repository reads survives the change untouched. What does **not** survive is
    the assumption that ``$80-$BF`` mirrors ``$00-$3F``: under SA-1 those banks
    are the image's third and fourth megabyte, so masking bit 7 -- which
    :class:`LoRom` does, correctly, for a 512 KB cartridge -- would silently read
    the wrong half. This refuses instead.
    """

    id: str = "SA-1 LoROM"
    bank_size: int = 0x8000
    addressable: int = 0x40 * 0x8000

    def offset(self, address: int) -> int:
        bank = (address >> 16) & 0xFF
        within = address & 0xFFFF
        if within < 0x8000:
            raise ValueError(f"${address:06X} is not in the ROM half of its bank")
        if bank > 0x3F:
            raise ValueError(
                f"${address:06X} is above bank $3F, where SA-1 stops mirroring "
                f"-- banks $40-$7D hold BW-RAM rather than ROM, and $80-$BF "
                f"are the image's third and fourth megabyte, not the first's "
                f"mirror"
            )
        return bank * self.bank_size + (within - 0x8000)

    def address(self, offset: int) -> int:
        if offset >= self.addressable:
            raise ValueError(
                f"offset ${offset:06X} is past {bytes_label(self.addressable)}, "
                f"where the LoROM banks run out -- SA-1 reaches the rest of the "
                f"image another way, which this map deliberately does not speak "
                f"for: banks $40+ are BW-RAM, not ROM"
            )
        bank, within = divmod(offset, self.bank_size)
        return (bank << 16) | (within + 0x8000)


@dataclass(frozen=True)
class VendoredPack:
    """A third-party tree assembled inside the base's own build.

    The tree is **vendored and pinned** under ``smw/vendor/``, with an env
    override so a newer upstream can be built against without touching the
    repository -- which is how an upgrade is checked for moved bytes before it
    is taken. :meth:`locate` is where that order is read, through
    :func:`~smw_tools.paths.find_vendored_tree`. The ROM passes put the tree
    on the include path, and a ``Config/`` file of the game folder
    ``incsrc``'s its entry from the end of the ROM map when :attr:`define` is
    set -- the same define the base carries in :attr:`source_defines`, so any
    source file can ask which base it is in by one name.

    Nothing runs after the build.
    """

    #: Which target of this base's own tree is assembled.
    source_target: str

    #: The tree's entry point, relative to its checkout root, which
    #: :meth:`locate` checks a candidate tree actually carries.
    entry: str

    #: How to find the checkout, and what to tell someone who has not got one.
    env_var: str
    label: str

    #: The tree's directory name under ``smw/vendor/``, which is where
    #: :meth:`locate` looks once the env override has not answered.
    vendor_dir: str

    #: The source define that switches the tree on: the ``Config/`` file
    #: includes it only when this is set, and the base carries it in
    #: :attr:`source_defines` too.
    define: str

    #: Directory names a sibling checkout of this tree might have, searched only
    #: when neither the override nor the vendored copy answered.
    fallback_names: tuple[str, ...] = ()

    #: ``--define`` pairs for the assemble. This is how a base moves work RAM
    #: at source level: the memory map's hooks are guarded on
    #: ``defined(...)``, so a command-line define wins over the default
    #: without any file being edited.
    source_defines: tuple[tuple[str, str], ...] = ()

    @property
    def pin_path(self) -> Path:
        """The pin beside the vendored tree: its revision and its hash."""
        return VENDOR_DIR / f"{self.vendor_dir}-pin.json"

    def tree(self) -> pack.PackTree | None:
        """The tree's sites and guards, read from the located tree without
        assembling it; ``None`` if there is no tree to read."""
        root = self.locate()
        if root is None:
            return None
        return pack.read_tree(root, self.entry)

    def locate(self) -> Path | None:
        """The checkout: the env override first, the vendored tree second, and
        a sibling named in :attr:`fallback_names` only if neither answered."""
        return find_vendored_tree(
            self.env_var,
            VENDOR_DIR / self.vendor_dir,
            self.entry,
            list(self.fallback_names),
        )

    def missing_message(self) -> str:
        return (
            f"{self.label} was not found. It is vendored under smw/vendor/, so "
            f"a checkout missing it is incomplete -- or point {self.env_var} at "
            f"a tree of your own."
        )


# -- the declarations --------------------------------------------------------


@dataclass(frozen=True)
class BuildTarget:
    """One assemblable variant of a base."""

    #: Short id, as used on the command line and in output filenames.
    id: str

    #: The framework's own name for it, passed as ``--define ROMID=``.
    #:
    #: **The names do not line up with ours, and the mismatch is silent**: their
    #: ``SMW_E1`` is PAL rev 0 (our ``E0``) and their ``SMW_E2`` is PAL rev 1
    #: (our ``E1``). Their arcade build is our ``SS``.
    romid: str

    #: Human-readable release name.
    label: str

    #: Output filename under the build directory.
    output_name: str

    #: The graphics set this target reads, relative to the assets root.
    #:
    #: Three sets serve five targets: ``U``, ``E0`` and ``SS`` share one, and
    #: ``J`` and ``E1`` have their own. Stated per target rather than per base
    #: because that is the grain the cartridge uses -- and because a base derived
    #: from another can then say it reuses that base's set and cost no extraction.
    asset_set: str

    #: What its bytes have to be.
    expectation: Expectation


@dataclass(frozen=True)
class TablePool:
    """A run of ROM that several fragments share, and push each other along in.

    **Contiguity is not enough to know one.** Two fragments that touch may be
    one run, where the second is emitted after whatever the first left; or two,
    where the ROM map ``org``s the second at a literal address and the first
    cannot push it a byte. Nothing in a symbol file tells the two apart, so a
    pool is declared -- by the feature that creates one, or by a base built
    with it.

    The bounds are **labels, not addresses**: a pool is a run the assembler
    decides the extent of, and reading it back off the build that made it is
    the only answer that stays true when it moves. The members are region ids
    from :mod:`asm_regions`; a region named here that the base does not have is
    refused when the pool is read.
    """

    #: The label at the first byte of the run.
    start_label: str

    #: The label one past its last byte.
    end_label: str

    #: The regions sharing it, by :attr:`~smw_tools.asm_codec.AsmRegion.id`.
    #: Order is not significant: what they share is the total.
    regions: tuple[str, ...]

    #: Bytes of the run that no member's **emitted** sections occupy and that
    #: are not slack.
    #:
    #: A run holds whatever the assembler put in it, and not all of that is a
    #: fragment's rows: the Layer 2 event *divider* table, derived from the
    #: entries and placed directly after them; the stubs a feature emits ahead
    #: of its tables; the offset tables the assembler computes from the
    #: strings' labels. Counting only the members would offer those bytes to a
    #: save twice -- once as what they are and once as slack -- and the build
    #: would then refuse what the editor promised.
    #:
    #: **One meaning, for pricing and drawing alike.** A member is exactly the
    #: bytes :meth:`~smw_tools.asm_codec.AsmRegion.fits` prices -- its
    #: emitted sections -- and :func:`~smw_tools.asm_room.bounds` stops a
    #: fragment at the first label that is not one of those, so a section a
    #: fragment carries but does not write is in this figure and never in the
    #: member as well. A feature declaring a pool sums the bytes it puts in
    #: the run outside every member's emitted sections, and nothing else.
    reserved: int = 0


@dataclass(frozen=True)
class RomBase:
    """A source tree and the targets it assembles to."""

    #: Short id, as used in ``<base>/<target>`` and stored in a project.
    id: str

    #: Human-readable name.
    label: str

    #: The tree holding the game folder and its ``Global`` sibling.
    src_root: Path

    #: The game folder's name inside :attr:`src_root`.
    #:
    #: Fixed per base by the framework rather than free: ``Global_Macros.asm``
    #: resolves ``../<GameID>/RomMap/...`` from ``--define GameID``, so the
    #: folder name and the GameID are one decision.
    game_folder: str

    #: What ``--define GameID`` is given. The same string as
    #: :attr:`game_folder`, and separate only because they are two arguments to
    #: the framework rather than one.
    game_id: str

    #: ROM-derived graphics, music and samples, outside the source tree and
    #: reached through asar's include search path.
    assets_root: Path

    #: Every target, by id, in the order they should be built and reported.
    targets: dict[str, BuildTarget]

    #: How this base's CPU addresses reach offsets in the image.
    address_map: AddressMap

    #: Where this base keeps the game's work RAM -- see :mod:`ram_map`.
    #:
    #: The counterpart to :attr:`address_map` for the other side of the machine.
    #: A base with a coprocessor does not keep ``$7E:0100`` in work RAM at all,
    #: and a reader that assumed it did would get a byte of the right number out
    #: of the wrong memory.
    ram_map: RamMap

    #: Where its tables and driveable routines are -- see :mod:`rom_tables`.
    tables: dict[str, RomTable]

    #: How many entries a table holds, by role, where this base **departs from
    #: the stock format** -- see :mod:`asm_regions`, which declares the count
    #: every table ships with and is the one place those are written down.
    #:
    #: Empty means "the format's own", which is every table on both bases: a
    #: count is indexed by something that cannot renumber, so growing one is a
    #: change to the game's search code and never an edit. What puts an entry
    #: here is a :class:`~smw_tools.features.Feature` that grew a table.
    entry_counts: dict[str, int] = field(default_factory=dict)

    #: Runs of ROM several editable fragments share, with nothing placed
    #: between them -- see :class:`TablePool`. Empty means every fragment is
    #: bounded by whatever the ROM map placed after it, which is every fragment
    #: on a stock cartridge.
    pools: tuple[TablePool, ...] = ()

    #: Editable regions whose table scan this base's build bounds by the
    #: fragment's own labels where the stock build's is a literal -- by
    #: :mod:`asm_regions` id. The rows then bound the scan: the table grows,
    #: and nothing past it is read. Empty on a stock cartridge, whose literal
    #: scans are the format's; what puts an entry here is a
    #: :class:`~smw_tools.features.Feature` whose build rewrote the bound.
    label_bound_scans: tuple[str, ...] = ()

    #: How this base is produced, when it is not simply assembled. ``None`` for
    #: a base asar builds outright; a :class:`VendoredPack` for one that
    #: assembles a third-party tree inside its own build.
    pack: VendoredPack | None = None

    #: Which bits of every level's **sprite-stream header byte** this base's
    #: build sets for itself, so the editor can tell a difference it made from
    #: an edit somebody meant.
    #:
    #: Zero for a base whose build carries level data through untouched, which
    #: is what makes a level file and the cartridge it built comparable byte
    #: for byte -- the editor lays the project's streams over the image and a
    #: difference is an edit the build has not yet re-placed. A base whose
    #: build *rewrites* level data breaks that: the bits named here are the
    #: cartridge's answer and not the project's, so the editor takes them from
    #: the image rather than reading them as an edit and patching them back
    #: out. Nothing else about the stream is affected -- the records, and the
    #: rest of the header byte, stay the project's.
    #:
    #: ``$1F`` on ``sa1``: the sprite-memory index, which SA-1 Pack's
    #: ``remap/sprite_memory.asm`` writes as ``$08`` into every level it is
    #: allowed to, because 22 sprite slots need an allocation the stock game
    #: has no setting for. It preserves the top three bits, so they are not
    #: claimed here. See ``docs/smw/sa1/sprites.md``.
    sprite_header_build_owned: int = 0x00

    #: Which of the editor's driven paths work on this base -- see
    #: :class:`DrivenPaths`.
    driven: DrivenPaths = DrivenPaths()

    #: Where this base keeps the code its captures trace -- see
    #: :class:`TracedCode`. Declared rather than resolved through
    #: :attr:`tables`, because a bank range has no label to anchor to.
    traced: TracedCode = TracedCode()

    #: Which capabilities beyond the stock game this base's cartridge has, as
    #: ids into :data:`~smw_tools.features.FEATURES`.
    #:
    #: **A statement, not an instruction.** The fields above already describe
    #: the cartridge a base builds, features included -- a base built with a
    #: bigger sprite engine declares the RAM map that engine uses. This says
    #: *which* capabilities those declarations account for, so a project that
    #: adds one on top is not applied twice, and so a feature that needs
    #: another under it can be satisfied by the base having it.
    #:
    #: Empty on both bases today: nothing a base builds in is declared as a
    #: registry feature yet. ``sa1`` is where the first entry lands -- its
    #: pack's 22-slot sprite engine is already inside :attr:`ram_map`, and
    #: naming it here is what would let a project refuse a patch that adds
    #: it a second time.
    features: tuple[str, ...] = ()

    #: The first expansion bank this base's cartridge has free, as a bank
    #: number -- what a feature reserving a whole bank is given to reserve.
    #:
    #: :data:`RESERVATION_BANK` on a plain build, and that is the useful bank
    #: to have: the first one an expanded image adds, so it is at the same
    #: address at every size from 1 MB up, and below ``$40``, so the work RAM
    #: mirror is still under it. ``sa1`` answers ``$11``, because SA-1 Pack's
    #: freespace search runs at the end of the main pass and lands its code
    #: in ``$10`` -- reserving that bank would take it out from under the
    #: pack, and the pack would then be somewhere no build of this base has
    #: ever put it.
    #:
    #: A fact about the cartridge rather than about the feature, which is why
    #: it is declared here: a feature that named one bank would be wrong on
    #: every base whose ``$10`` is spoken for.
    reservation_bank: int = RESERVATION_BANK

    #: Which cartridge sizes this base can be built at, **smallest first**, as
    #: ids into :data:`~rom_sizes.ROM_SIZES`.
    #:
    #: A base's own list, not the module's: what is reachable depends on the
    #: memory map the source assembles under. ``vanilla`` stops at 4 MB where
    #: plain LoROM does; ``sa1`` starts at 1 MB, because SA-1 Pack needs
    #: freespace and cannot fit a 512 KB cartridge, and reaches 6 and 8 MB
    #: through the framework's own SA-1 sizes.
    #:
    #: The first entry is the **stock** size: the one a build assembles when
    #: nobody has said, and the only one a target's pinned hash describes.
    sizes: tuple[str, ...] = (STOCK,)

    #: Which of :attr:`sizes` the cartridge in hand **is**, or ``None`` where
    #: nobody has said -- which is :attr:`stock_size`, the size a build
    #: assembles when it is not told otherwise.
    #:
    #: A declaration says what a base *can* be built at; this says what it was,
    #: and it is a fact about the cartridge for the same reason every other
    #: fact here is. A feature that uses an expansion bank where the cartridge
    #: has one and does without where it has not reads differently at 512 KB
    #: and at 1 MB (:data:`~features.MANAGED_LEVEL_MEMORY`), so anything asking
    #: where its tables are needs the size as well as the base -- and would
    #: otherwise have to be handed the two separately, which is a pair a caller
    #: can get half right. :func:`~features.applied` is what sets it.
    built_at: str | None = None

    @property
    def stock_size(self) -> str:
        """The size this base builds when nobody has chosen one."""
        return self.sizes[0]

    @property
    def size_id(self) -> str:
        """The size the cartridge in hand is: :attr:`built_at`, or
        :attr:`stock_size` where nobody has said."""
        return self.built_at or self.stock_size

    @property
    def size_bytes(self) -> int:
        """How long the cartridge in hand is -- :attr:`size_id` in bytes."""
        return ROM_SIZES[self.size_id].size

    @property
    def source_defines(self) -> tuple[tuple[str, str], ...]:
        """The ``--define`` pairs this base's **source** is assembled with.

        Not a build detail: these are what the memory map resolves against, so
        they decide what address every ``!RAM_SMW_*`` entry has on this base.
        ``sa1`` sets the direct page to ``$3000`` and low RAM to ``$6000``, and
        an index built without them answers with vanilla's numbers -- in exactly
        the shape of a right answer, which is why anything reading the map takes
        the base rather than the tree.

        The defines live on the patch because that is what they exist for, and
        are read from here because a base that carried its own would have them
        read the same way.
        """
        return self.pack.source_defines if self.pack else ()

    @property
    def expandable(self) -> bool:
        """Whether there is anything to choose. A base with one size is not a
        base whose cartridge length is anyone's decision."""
        return len(self.sizes) > 1

    def room(self, size_id: str) -> int:
        """How many bytes ``size_id`` adds over this base's stock cartridge.

        The number that decides the choice, and it is **relative** on purpose: a
        size is picked against what the project already builds, and the absolute
        length says nothing about how much of it the game is already using.
        """
        return ROM_SIZES[size_id].size - ROM_SIZES[self.stock_size].size

    def size_summary(self, size_id: str) -> str:
        """``size_id`` as a row someone picks from: the length and what it buys."""
        extra = self.room(size_id)
        if not extra:
            return f"{ROM_SIZES[size_id].label} (stock)"
        return f"{ROM_SIZES[size_id].label} (+{bytes_label(extra)})"

    def table(self, role: str) -> RomTable:
        """One table by role, or :class:`BaseError` naming the roles there are.

        Never a silent ``None``: a missing role reached through ``.get`` would
        become an address of zero somewhere far from here, and patch the front
        of the cartridge.
        """
        try:
            return self.tables[role]
        except KeyError:
            raise BaseError(
                f'{self.id} declares no table "{role}" -- expected one of '
                f"{', '.join(sorted(self.tables))}"
            ) from None

    def at(self, role: str, target_id: str | None = None) -> int:
        """The SNES address of one table by role, in one target's build.

        ``None`` answers for the default target, which is what a cartridge
        of unknown provenance is read as. A target this base does not have
        is refused the same way an unknown role is -- resolving it to the
        default would read plausible bytes from a subtly wrong place.
        """
        if target_id is not None and target_id not in self.targets:
            raise BaseError(
                f'{self.id} has no target "{target_id}" -- expected one of '
                f"{', '.join(sorted(self.targets))}"
            )
        return self.table(role).address_for(target_id)

    @property
    def game_dir(self) -> Path:
        """The folder asar is run from, and every path in the tree resolves from."""
        return self.src_root / self.game_folder

    @property
    def global_dir(self) -> Path:
        """The framework beside the game folder.

        Its name is fixed at ``Global``: the entry point is reached as
        ``../Global/AssembleFile.asm`` and the framework resolves its own
        siblings from there.
        """
        return self.src_root / "Global"

    def rom_map(self, target: BuildTarget) -> Path:
        """The ROM map file a target assembles through.

        ``Global_Macros.asm`` reaches it as
        ``../<GameID>/RomMap/ROM_Map_!ROMID.asm``, and the ROMID carries the
        GameID itself (``SMW_U``, not ``U``) -- so the name is *not* the two
        defines joined, which is the plausible wrong guess.

        This file is where a base's real shape is declared: the cartridge header
        (layout, chip, ROM and SRAM size), the extra-hardware hook, and the
        placement of every routine.
        """
        return self.game_dir / "RomMap" / f"ROM_Map_{target.romid}.asm"

    def rom_map_includes(self, target: BuildTarget) -> list[Path]:
        """The files a target's ROM map pulls in, resolved on disk.

        **This is the seam a base differs at.** Two bases may name the same
        ``src_root`` -- and a base that restructures the game rather than
        replacing it should, since a fork duplicates the tree and makes every fix
        land twice. What varies is which files the ROM map chooses:

            macro SMW_LoadGameSpecificMainSNESFiles()
                incsrc ../RAM_Map_SMW.asm        ; per ROMID

        A base that moves the whole memory map swaps that line for its own file,
        and nothing another base reads is touched.

        Resolved the way asar resolves ``incsrc`` -- against the including file's
        own directory first, then the game folder, which is the working
        directory a build runs from. A path that resolves to neither is reported
        as missing rather than guessed at, because that is the case worth
        catching: a variant file named but not written is otherwise
        ``Efile_not_found`` from inside a pass that has already read half the
        tree.
        """
        rom_map = self.rom_map(target)
        try:
            text = rom_map.read_text(encoding="latin-1")
        except OSError:
            return []
        found: list[Path] = []
        for include in iter_includes(text):
            named = include.path
            for root in (rom_map.parent, self.game_dir):
                candidate = (root / named).resolve()
                if candidate.is_file():
                    found.append(candidate)
                    break
            else:
                # Kept, unresolved, so a caller can report it. Dropping it would
                # make a missing variant file look like one that was never asked
                # for.
                found.append((rom_map.parent / named).resolve())
        return found

    def target(self, target_id: str) -> BuildTarget:
        """One target by id, or :class:`BaseError` naming the valid set."""
        try:
            return self.targets[target_id]
        except KeyError:
            raise BaseError(
                f'{self.id} has no target "{target_id}" -- expected one of '
                f"{', '.join(self.targets)}"
            ) from None


#: The disassembly under ``smw/src``: five targets, five shipped cartridges.
#:
#: Its expectations are built from :mod:`rom_versions` rather than restated here,
#: so there is exactly one place a No-Intro hash is written down.
VANILLA = RomBase(
    id="vanilla",
    label="Super Mario World (the shipped cartridges)",
    src_root=SRC_DIR,
    game_folder="SMW",
    game_id="SMW",
    assets_root=ASSETS_DIR,
    address_map=LoRom(),
    ram_map=WorkRam(),
    tables=VANILLA_TABLES,
    pack=None,
    # Every rung the framework's `%GetROMSize()` offers that plain LoROM can
    # address. Past 4 MB the map runs out, not the table.
    sizes=("512kb", "1mb", "1.5mb", "2mb", "2.5mb", "3mb", "3.5mb", "4mb"),
    targets={
        version: BuildTarget(
            id=version,
            romid=romid,
            label=ROM_VERSIONS[version].label,
            output_name=ROM_VERSIONS[version].output_name,
            asset_set=GFX_SETS[version],
            expectation=Reference(
                crc32=ROM_VERSIONS[version].crc32,
                sha1=ROM_VERSIONS[version].sha1,
                size=ROM_VERSIONS[version].size,
            ),
        )
        for version, romid in (
            ("J", "SMW_J"),
            ("U", "SMW_U"),
            ("SS", "SMW_ARCADE"),
            ("E0", "SMW_E1"),
            ("E1", "SMW_E2"),
        )
    },
)

#: SA-1: the same tree, assembled as U under ``Define_SMW_SA1`` with the
#: vendored SA-1 Pack in-pass.
#:
#: **It shares vanilla's source root**, which is the whole point of a base being
#: a declaration rather than a copy. The same ROM map places the same routines
#: at the same addresses -- so its tables are vanilla's tables, unmoved. What
#: differs is what the define switches on, and the cartridge that comes out:
#: 1 MB, SA-1, and an address map that stops mirroring at bank $3F.
#:
#: The pack's tree is vendored under smw/vendor/. See :class:`VendoredPack`.
#:
#: One target, because SA-1 Pack applies to the USA release and nothing else.
#: ``sa1/U`` beside ``vanilla/U`` reads oddly and is exactly right: same
#: release, different base.
SA1 = RomBase(
    id="sa1",
    label="Super Mario World with SA-1 Pack applied",
    src_root=SRC_DIR,
    game_folder="SMW",
    game_id="SMW",
    assets_root=ASSETS_DIR,
    address_map=Sa1LoRom(),
    ram_map=Sa1Ram(),
    tables=VANILLA_TABLES,
    # The pack hands the object loop, the sprite main and init code and the
    # player's drawing routine to the second CPU. Calling one still works --
    # the hijack dispatches and waits -- and what had to be established for
    # each is that the probe around the call reads the side the work happened
    # on. All three are measured, so this base declares nothing off and takes
    # `DrivenPaths`' defaults; what each measurement was is written there.
    driven=DrivenPaths(),
    # The build rewrites every eligible level's sprite-memory index on the
    # cartridge's way out (Config/SpriteMemoryIndex.asm, under
    # Define_SMW_SpriteMemoryIndex below), so those five bits are the
    # cartridge's and not the project's.
    sprite_header_build_owned=0x1F,
    pack=VendoredPack(
        source_target="U",
        entry=SA1_PACK_ENTRY,
        env_var=SA1_PACK_ENV,
        label="SA-1 Pack",
        vendor_dir="sa1-pack",
        define="Define_SMW_SA1",
        fallback_names=tuple(SA1_PACK_NAMES),
        # The base's own switch first -- Config/SA1Pack.asm includes the
        # pack on it, and the source sees it on every pass. Then every
        # region the memory map places where the pack would have moved it;
        # the pack's own copies of that work are switched off beside the
        # include, in Config/SA1Pack.asm.
        source_defines=(
            ("Define_SMW_SA1", "1"),
            ("Define_SMW_DirectPageLocation", "$3000"),
            ("Define_SMW_LowRAMLocation", "$6000"),
            # The pack's smaller remaps, placed by the source the same way:
            # the Map16 tables in BW-RAM, the save files in BW-RAM, and the
            # V-blank uploads folded onto DMA channel 2 with the window on
            # HDMA channel 1, which the pack keeps 0 and 1 free for.
            ("Define_SMW_Map16Location", "$40C800"),
            ("Define_SMW_SaveDataLocation", "$41C000"),
            ("Define_SMW_OAMUploadDMAChannel", "$02"),
            ("Define_SMW_TilemapUploadDMAChannel", "$02"),
            ("Define_SMW_WindowHDMAChannel", "$01"),
            # Every eligible level's sprite memory index set to $08, the one
            # the pack's 22-slot sprite memory is keyed on, as each list is
            # emitted -- the pack's own exclusions included.
            ("Define_SMW_SpriteMemoryIndex", "$08"),
            # More Sprites' 22 slots, and its tables where the pack keeps
            # them: the memory map's SA-1 layout block, selected by the
            # pack's define, places every table the pack's non_dp and
            # dp_trivial tables used to move.
            ("Define_SMW_MaxNormalSpriteSlot", "$15"),
        ),
    ),
    #: Bank $11, not the $10 a plain build reserves. The pack allocates its
    #: own ~18 KB with asar's freespace search, and that search runs at the
    #: end of the main pass, after every bank has emitted -- so $10 is where
    #: the pack has always landed, and a reservation there would push it into
    #: a bank no build of this base has put it in. One bank up costs nothing:
    #: $11 is the same address at every size from 1 MB and still under the
    #: work RAM mirror.
    reservation_bank=0x11,
    #: Whole megabytes only, because that is the grain the Super MMC maps ROM
    #: in. 1 MB is the floor rather than a choice: the pack's own code needs
    #: the expansion. 5 and 7 are missing because the framework declares 6
    #: and 8 past the LoROM banks and nothing between.
    sizes=("1mb", "2mb", "3mb", "4mb", "6mb", "8mb"),
    targets={
        "U": BuildTarget(
            id="U",
            romid="SMW_U",
            label="USA (NTSC), SA-1",
            output_name="SMW_SA1.sfc",
            asset_set=GFX_SETS["U"],
            # Not a cartridge anyone shipped, so it cannot claim a No-Intro
            # hash. What it claims is that this base still assembles to what it
            # assembled to before -- and that it differs from SA-1 Pack applied
            # to a real USA cartridge by exactly seven enumerated bytes: five
            # in two routines with no callers, where our reading is the correct
            # one and the patch's is not, and two of dead padding. See the pin
            # file for the list.
            #
            # It moves when SA-1 Pack is upgraded, which is the point: a
            # `Reproducible` pin over a dependency nobody here controls is what
            # notices that the dependency changed.
            expectation=Reproducible(
                sha1="d6bbf6ad7b267bc15d4bd6d63f59f51a74016427",
                size=1048576,
            ),
        )
    },
)

#: Every base this repository knows how to build, by id.
BASES: dict[str, RomBase] = {VANILLA.id: VANILLA, SA1.id: SA1}

#: The base used when none is named. A bare target id resolves against this one.
DEFAULT_BASE = VANILLA.id

#: The target built when none is named. ``U`` is the release the editor works in
#: and the one a single-version command should mean.
DEFAULT_TARGET = "U"


def base(base_id: str | None = None) -> RomBase:
    """One base by id, or the default. :class:`BaseError` for anything else."""
    if base_id is None:
        return BASES[DEFAULT_BASE]
    try:
        return BASES[base_id]
    except KeyError:
        raise BaseError(
            f'unknown ROM base "{base_id}" -- expected one of {", ".join(BASES)}'
        ) from None


def resolve(spec: str | None = None) -> tuple[RomBase, BuildTarget]:
    """Read a ``<base>/<target>`` spec, a bare target id, or nothing.

    ``"vanilla/U"``, ``"U"`` and ``None`` all answer the same thing today,
    because there is one base. Written to take the long form now so that adding
    a base is a registration rather than a parser change.

    Raises with the valid set listed rather than falling back silently, so a
    typo can never quietly build -- and then "verify" -- the wrong thing.
    """
    if spec is None:
        found = base()
        return found, found.target(DEFAULT_TARGET)
    head, separator, tail = spec.partition("/")
    found = base(head) if separator else base()
    target_id = tail if separator else head
    # Matched case-insensitively, because the target ids are shouted (`U`, `E0`)
    # and nobody types them that way twice in a row. The base ids are not: they
    # are lowercase words, and accepting `VANILLA` would invite `Vanilla` in a
    # stored project file, where it has to compare equal to itself later.
    upper = target_id.upper()
    if not separator and target_id in BASES and upper not in found.targets:
        # A known base id offered where a target goes: the thing exists, the
        # spelling is what is missing, so the error says the spelling.
        example = next(iter(BASES[target_id].targets))
        raise BaseError(
            f'"{target_id}" is a base, not a target -- its targets are written '
            f"{target_id}/<target>, e.g. {target_id}/{example}"
        )
    return found, found.target(upper if upper in found.targets else target_id)


def all_targets(found: RomBase | None = None) -> list[BuildTarget]:
    """Every target of ``found``, in declaration order."""
    return list((found or base()).targets.values())


def _check_vanilla_matches_rom_versions() -> None:
    """The vanilla base declares exactly the five releases, and no others.

    Asserted at import rather than only in the tests: the two lists are written
    in different files for good reasons, and a base that quietly dropped a target
    would show up as a gate that passes over four releases.
    """
    if list(VANILLA.targets) != ALL_VERSIONS:
        raise BaseError(
            f"the vanilla base declares {list(VANILLA.targets)}, "
            f"but rom_versions lists {ALL_VERSIONS}"
        )


_check_vanilla_matches_rom_versions()
