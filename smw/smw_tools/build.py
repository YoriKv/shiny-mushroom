"""Assemble one release.

The framework does not build in a single pass. `AssembleFile.asm` is a dispatcher
selected by ``--define FileType``, and a complete ROM needs several passes over
it, each patching the same output file:

===========  =========  ======================================================
pass         FileType   what it does
===========  =========  ======================================================
init         ``0``      lays down the ROM, ``--fix-checksum=on``
spc x5       ``4``      assembles each SPC700 source to its own ``.bin``
main         ``1``      the game itself, which incbins those ``.bin`` files
finalize     ``2``      end-of-ROM fixups
checksum     ``3``      writes the header checksum, ``--fix-checksum=off``
===========  =========  ======================================================

The order is load-bearing everywhere except the SPC700 group: those five write
five separate files and are run together, while every other pass patches the ROM
the pass before it wrote.

Both checksum flags are load-bearing and they disagree on purpose: the init pass
lets asar compute one so the image is well-formed, and the final pass writes the
cart's literal value -- two releases ship a checksum that is simply wrong, and
"correcting" it breaks byte-exactness.

The upstream batch file also runs ``FileType=6`` to write a firmware filename to
``Temp.txt``. That pass is skipped: no base here needs a firmware file -- the
SA-1 carries none -- and every target is byte-exact without it.

Three more details carry weight:

``cwd`` is the game folder
    Every path in the tree resolves relative to ``src/SMW``, and the entry point
    is reached as ``../Global/AssembleFile.asm``.

``--include`` reaches the assets
    Graphics, music and samples live outside the source tree and are found
    through asar's include search path. See ``paths.asset_include_args``.

The output extension decides the header
    asar writes a headerless image for ``.sfc`` and prepends a 512-byte copier
    header for ``.smc``. This project always emits ``.sfc``, which is what the
    No-Intro hashes in rom_versions.py describe.

Nothing is written into the source tree
    The five ``.bin`` blobs are the only files a build produces that are not the
    ROM, and they go to a directory of their own beside it rather than into the
    tree, reached through the include path (:func:`_spc_blobs`). A build reads
    the sources and writes only to its output directory, so two builds may run
    over one checkout at the same time.
"""

from __future__ import annotations

import json
import os
import shutil
import tempfile
import time
from collections.abc import Callable, Iterable, Iterator
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager
from dataclasses import dataclass, field
from pathlib import Path

from .asar import AsarError, run_asar, warning_flags
from .bases import DEFAULT_BASE, DEFAULT_TARGET, BaseError, BuildTarget, RomBase
from .bases import base as default_base
from .paths import (
    BUILD_DIR,
    FRAMEWORK_ENTRY,
    asar_binary,
    asset_include_args,
    relative_path,
)
from .rom_sizes import DEFINE as ROM_SIZE_DEFINE
from .rom_sizes import ROM_SIZES, RomSize

#: Assembled individually, then incbin'd by the main pass.
SPC_SOURCES = ("Engine", "samples", "overworld_music", "level_music", "credits_music")

#: The directory name the blobs have to be reachable under.
#:
#: Three files in ``Banks/`` incbin them as ``SPC700/<name>.bin``, which asar
#: resolves against its working directory and then against each ``--include``
#: path. So a directory of this name anywhere, with an include pointing at its
#: parent, is where the blobs may live -- and none of the ``incbin`` lines has
#: to know which. See :func:`_spc_blobs`.
SPC_DIR = "SPC700"

#: How many SPC700 passes run at once.
#:
#: They are the only passes that can overlap at all: each reads the shared tree
#: and writes its own ``.bin``, where every other pass patches the one ROM and
#: has to see what the pass before it wrote. Assembling them is mostly waiting
#: on the filesystem, so four in flight collapses five passes into a little over
#: one -- and a fifth thread would only wait on the four ahead of it.
SPC_WORKERS = 4

#: Beside each image: what the build that wrote it was asked for.
RECORD_SUFFIX = ".build.json"

#: How long :func:`stock_build` waits for another process's rebuild of the same
#: output before giving up, and how old a lock has to be before it is taken for
#: one left by a process that died holding it. The lock is held for one build
#: of one target -- some twenty seconds on a mounted Windows drive -- so a lock
#: minutes old belongs to nothing that is still running.
LOCK_WAIT = 300.0
LOCK_STALE = 180.0


@dataclass
class BuildResult:
    version: str
    label: str
    output_path: Path
    symbols_path: Path | None = None
    warnings: list[str] = field(default_factory=list)


@dataclass(frozen=True)
class BuildRecord:
    """What one build in an output directory was asked for.

    Every kind of build of a target writes the same file: ``smw build U``,
    ``smw build U --feature uberasm`` and ``smw build U --rom-size 1mb`` all
    leave ``build/SMW_U.sfc``, and an editor project's build of its merged tree
    can land there too. The image does not say which it is, and a symbol file
    from any of them reads exactly like the stock one -- it parses, resolves
    every name, and answers with the addresses of a cartridge nobody asked
    about. So each build leaves this beside its image, and whatever needs a
    particular kind of build reads it before reading the ROM: the test
    fixtures and ``smw symbol`` through :func:`stock_build`.

    ``defines`` are the caller's -- the feature switches -- and never the ones a
    patched base adds to every build of itself. ``overlaid`` says the build read
    a project's merged tree or assets rather than the checkout's.
    """

    base: str
    target: str
    rom_size: str
    defines: tuple[tuple[str, str], ...] = ()
    symbols: str | None = None
    overlaid: bool = False

    @property
    def stock(self) -> bool:
        """Whether this is the build the pinned hash describes: the checkout's
        own tree, at the base's stock size, with nothing switched on."""
        return (
            not self.defines
            and not self.overlaid
            and self.rom_size == default_base(self.base).stock_size
        )

    @property
    def asked_for(self) -> str:
        """The request, for a message: ``stock``, or what made it not."""
        parts = []
        if self.defines:
            parts.append("with " + ", ".join(f"{n}={v}" for n, v in self.defines))
        if self.rom_size != default_base(self.base).stock_size:
            parts.append(f"at {ROM_SIZES[self.rom_size].label}")
        if self.overlaid:
            parts.append("from a project's tree")
        return ", ".join(parts) or "stock"

    def write(self, path: Path) -> None:
        path.write_text(
            json.dumps(
                {
                    "base": self.base,
                    "target": self.target,
                    "rom_size": self.rom_size,
                    "defines": [list(pair) for pair in self.defines],
                    "symbols": self.symbols,
                    "overlaid": self.overlaid,
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )

    @classmethod
    def read(cls, path: Path) -> BuildRecord | None:
        """The record at ``path``, or ``None`` when there is none to read -- a
        build older than records, or one that is still being written."""
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            return None
        try:
            return cls(
                base=raw["base"],
                target=raw["target"],
                rom_size=raw["rom_size"],
                defines=tuple((str(n), str(v)) for n, v in raw.get("defines", ())),
                symbols=raw.get("symbols"),
                overlaid=bool(raw.get("overlaid", False)),
            )
        except (KeyError, TypeError, ValueError):
            return None


@contextmanager
def _spc_blobs(out_dir: Path) -> Iterator[Path]:
    """A directory for one build's SPC700 blobs, removed when the build ends.

    The blobs are intermediates, and the upstream batch file writes them into
    the source tree -- which makes a build a *write* to the tree it is reading,
    and two builds at once a race: five fixed filenames, one copy of each, and
    ``Engine.bin`` differs between J and the rest, so whoever assembles second
    overwrites what the first is about to incbin. Giving each build its own
    directory is what makes concurrent builds independent, and it is what lets
    the source tree be read-only to a build.

    It goes beside the ROM rather than in the system temp: the output directory
    is somewhere the assembler has already been shown it can write, which the
    system temp is not on every host this builds on -- a staged tree is on the
    VM's own disk, and ``asar.exe`` under WSL interop cannot see that at all.
    """
    root = Path(tempfile.mkdtemp(prefix=".spc-", dir=out_dir))
    try:
        (root / SPC_DIR).mkdir()
        yield root
    finally:
        shutil.rmtree(root, ignore_errors=True)


def _define_args(pairs: Iterable[tuple[str, str]]) -> list[str]:
    """``(name, value)`` pairs as the ``--define name=value`` flags asar takes."""
    return [arg for name, value in pairs for arg in ("--define", f"{name}={value}")]


def output_path(
    base: RomBase, target: BuildTarget, output_dir: Path | None = None
) -> Path:
    """Where a build of ``base``'s ``target`` lands.

    Named here rather than at each call site because it is what ``--no-build``
    goes looking for: a caller that spelled it differently would report a ROM
    missing that is sitting right there.
    """
    return (output_dir or BUILD_DIR) / target.output_name


def symbols_path(
    base: RomBase, target: BuildTarget, output_dir: Path | None = None
) -> Path:
    """Where a ``--symbols`` build of ``base``'s ``target`` writes its symbols.

    One file per build. The main pass writes every label -- the RAM map
    resolved with the base's own defines, ROM addresses as the ROM map placed
    them, and a vendored tree's own labels where it assembled them, since it
    assembles in the same pass.
    """
    out = output_dir or BUILD_DIR
    return out / target.output_name.replace(".sfc", ".sym")


def record_path(
    base: RomBase, target: BuildTarget, output_dir: Path | None = None
) -> Path:
    """Where the :class:`BuildRecord` for a build of ``base``'s ``target`` is."""
    return (output_dir or BUILD_DIR) / target.output_name.replace(
        ".sfc", RECORD_SUFFIX
    )


def read_record(
    base: RomBase, target: BuildTarget, output_dir: Path | None = None
) -> BuildRecord | None:
    """What the build of ``base``'s ``target`` in ``output_dir`` was asked for,
    or ``None`` when nothing says."""
    return BuildRecord.read(record_path(base, target, output_dir))


@contextmanager
def _exclusive(output: Path) -> Iterator[None]:
    """Hold the lock on ``output`` for the block.

    An ``O_EXCL`` create rather than ``fcntl`` or ``msvcrt``, because it is the
    one primitive every host this runs on honours the same way: a DrvFS mount
    under WSL, NTFS from Windows, ext4 on CI. A lock older than
    :data:`LOCK_STALE` is one a process died holding, and is taken over.
    """
    lock = output.with_name(output.name + ".lock")
    deadline = time.monotonic() + LOCK_WAIT
    while True:
        try:
            os.close(os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY))
            break
        except FileExistsError:
            try:
                age = time.time() - lock.stat().st_mtime
            except FileNotFoundError:
                continue
            if age > LOCK_STALE:
                lock.unlink(missing_ok=True)
                continue
            if time.monotonic() > deadline:
                raise AsarError(
                    f"{lock} has been held for {int(age)}s -- another build of "
                    f"{output.name} is still running, or died; remove the lock "
                    f"if nothing is building"
                ) from None
            time.sleep(0.2)
    try:
        yield
    finally:
        lock.unlink(missing_ok=True)


def stock_build(
    base: RomBase,
    target_id: str | None = None,
    symbols: bool = True,
    output_dir: Path | None = None,
    on_progress: Callable[[str], None] | None = None,
) -> BuildResult | None:
    """The stock build of ``base``'s ``target`` in ``output_dir``, rebuilt if
    what is there was asked for something else.

    ``None`` when there is no build there at all: a checkout without assets
    cannot make one, and whether that is a skip or a failure is the caller's
    to say. A build that *is* there but was made otherwise -- with a feature
    switched on, at another size, from a project's tree, or (when ``symbols``)
    without the symbol file -- is replaced by the stock build with symbols,
    which is the one every literal address in this package describes. A build
    older than records is taken at its word; the pinned hash is what tells on
    it.

    Safe from several processes at once: the check and the rebuild happen under
    a lock on the output, so parallel test workers that all find a feature
    build wait for one rebuild rather than each starting their own.
    """
    target = base.target(target_id) if target_id else analysis_target(base)
    out_dir = output_dir or BUILD_DIR
    rom = output_path(base, target, out_dir)
    sym = symbols_path(base, target, out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    with _exclusive(rom):
        if not rom.is_file():
            return None
        record = read_record(base, target, out_dir)
        has_symbols = sym.is_file() and (record is None or record.symbols is not None)
        if record is not None and not record.stock:
            why = f"was built {record.asked_for}"
        elif symbols and not has_symbols:
            why = "has no symbol file"
        else:
            return BuildResult(
                target.id, target.label, rom, sym if has_symbols else None
            )
        if on_progress:
            on_progress(f"{rom.name} {why} -- rebuilding the stock cartridge")
        return build_rom(
            target.id,
            base=base,
            output_dir=out_dir,
            symbols="wla",
            on_progress=on_progress,
        )


def analysis_target(base: RomBase) -> BuildTarget:
    """The target a symbol file for reading ``base`` describes.

    The default target, or -- for a base that has no target of that name -- its
    first, because a base with one target has already answered.
    """
    if DEFAULT_TARGET in base.targets:
        return base.target(DEFAULT_TARGET)
    return base.target(next(iter(base.targets)))


def build_symbols(
    base: RomBase,
    on_progress: Callable[[str], None] | None = None,
    verbose: bool = False,
) -> Path:
    """Assemble what a symbol file for ``base`` describes, and say where it is.

    The base's own build, whole.
    """
    target = analysis_target(base)
    result = build_rom(
        target.id,
        base=base,
        symbols="wla",
        on_progress=on_progress,
        verbose=verbose,
    )
    if result.symbols_path is None:  # pragma: no cover -- symbols were asked for
        raise AsarError(f"assembled {base.id}/{target.id} but wrote no symbol file")
    return result.symbols_path


def build_rom(
    version: str,
    output_dir: Path | None = None,
    symbols: str | None = None,
    on_progress: Callable[[str], None] | None = None,
    verbose: bool = False,
    game_dir: Path | None = None,
    assets_dir: Path | None = None,
    base: RomBase | None = None,
    defines: tuple[tuple[str, str], ...] = (),
    rom_size: RomSize | None = None,
) -> BuildResult:
    """Assemble ``version`` of ``base``. ``symbols`` may be 'wla' or 'nocash'.

    ``base`` is which ROM base to assemble, defaulting to ``vanilla``. It decides
    the source tree, the GameID and which targets exist; ``version`` names one of
    that base's targets.

    ``rom_size`` assembles the same source into a larger cartridge, for a base
    that allows it -- see :mod:`rom_sizes`. ``None`` and the stock size are the
    same request and neither adds a define, so the ordinary build is the one the
    pinned hashes were taken over.

    ``game_dir`` is the game folder to assemble, defaulting to the base's own.
    Passing one is how a *merged* tree is built -- the base with an editor
    project's changed files laid over it -- and it must have a ``Global``
    sibling, because the entry point is reached as ``../Global/AssembleFile.asm``
    and the framework resolves its own paths from there. It is a relocated copy
    of ``base``, not a way to assemble some other base.

    ``assets_dir`` moves the graphics, music and samples the same way, for the
    same reason: a project can overlay those too, and the build has to read the
    merged set rather than the checkout's.
    """
    rom_base = base or default_base()
    try:
        target = rom_base.target(version)
    except BaseError as error:
        raise AsarError(str(error)) from None
    # What the caller asked for, before the base adds its own -- the record
    # says what was *switched on*, and a patched base's defines are on always.
    asked = defines
    overlaid = game_dir is not None or assets_dir is not None

    wanted = rom_size if rom_size is not None else ROM_SIZES[rom_base.stock_size]
    if wanted.id not in rom_base.sizes:
        # A statement about the base rather than a failed assembly, so it is
        # `BaseError` -- which is what every caller of this module already
        # reports for "that is not a thing this base can be asked".
        raise BaseError(
            f"{rom_base.id} cannot be assembled at {wanted.label} -- it offers "
            f"{', '.join(rom_base.sizes)}"
        )
    # A base with a vendored tree assembles it inside the main pass, so the
    # ROM passes run at the size the cartridge needs (`_source_size`) with
    # the tree on the include path, and the base's own defines on every pass.
    pack = rom_base.pack
    if pack is not None:
        # Located before anything assembles: a missing tree should cost the
        # message, not a build that dies at its final pass.
        pack_root = pack.locate()
        if pack_root is None:
            raise AsarError(pack.missing_message())
        source = _source_base(rom_base)
        assemble_size = (
            _source_size(rom_base, wanted, defines) or ROM_SIZES[source.stock_size]
        )
        stock_id = source.stock_size
        defines = (*pack.source_defines, *defines)
    else:
        pack_root = None
        assemble_size = wanted
        stock_id = rom_base.stock_size

    # The stock size adds no define, so asking for it and asking for nothing are
    # one command line -- which is what keeps the pinned hashes describing the
    # build anyone gets by default.
    expanded = assemble_size if assemble_size.id != stock_id else None

    out_dir = output_dir or BUILD_DIR
    out_path = output_path(rom_base, target, out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    # asar patches an existing file in place; a stale one would leave bytes from
    # a previous version wherever the current build writes nothing. The record
    # and the symbol file go with it: until this build has written its own,
    # nothing beside the image may claim to describe it.
    out_path.unlink(missing_ok=True)
    record_at = record_path(rom_base, target, out_dir)
    record_at.unlink(missing_ok=True)
    symbols_path(rom_base, target, out_dir).unlink(missing_ok=True)
    assembled = out_path

    game = game_dir or rom_base.game_dir
    # The SPC700 blobs the passes below write and read go here rather than
    # into the tree being assembled, and the include is how the main pass
    # finds them -- see :func:`_spc_blobs`.
    with _spc_blobs(out_dir) as blobs:
        common = [
            *asset_include_args(game, assets_dir or rom_base.assets_root),
            # Relative for the reason `asset_include_args` gives: it is the one
            # spelling every host reads the same way.
            "--include",
            relative_path(blobs, game),
            # A base with a vendored tree reads it as well: Config/SA1Pack.asm
            # includes its entry from the end of the ROM map.
            *(["--include", relative_path(pack_root, game)] if pack_root else []),
            *warning_flags(),
            "--define",
            f"GameID={rom_base.game_id}",
            "--define",
            f"ROMID={target.romid}",
            # Every pass, not only the one that writes the header: `%GetROMSize()`
            # decides `!MaxROMSize` as well, and a pass that disagreed about where
            # the ROM ends would warn about an overflow that is not one.
            *_define_args(
                (
                    *defines,
                    *(
                        ()
                        if expanded is None or expanded.define is None
                        else ((ROM_SIZE_DEFINE, expanded.define),)
                    ),
                )
            ),
        ]
        entry = str(FRAMEWORK_ENTRY)

        def run(extra: list[str], output: str) -> list[str]:
            result = run_asar(
                asar_binary(),
                [*extra, *common, entry, output],
                cwd=game,
                verbose=verbose,
            )
            return result.warnings

        warnings: list[str] = []
        if on_progress:
            on_progress(f"assembling {target.label}")

        warnings += run(["--fix-checksum=on", "--define", "FileType=0"], str(assembled))

        sym_out: Path | None = None
        if on_progress:
            on_progress("assembling SPC700 blobs")

        def spc(name: str) -> list[str]:
            return run(
                [
                    "--no-title-check",
                    "--define",
                    "FileType=4",
                    "--define",
                    f"PathToFile=SPC700/{name}.asm",
                ],
                str(blobs / SPC_DIR / f"{name}.bin"),
            )

        # Mapped rather than collected as they finish, so the warnings stay in
        # source order however the passes happen to interleave. A failing pass
        # raises out of here, which is what it did when they ran one after another.
        with ThreadPoolExecutor(SPC_WORKERS) as pool:
            for found in pool.map(spc, SPC_SOURCES):
                warnings += found

        main_pass = ["--define", "FileType=1"]
        if symbols:
            # Attached to the main pass: it carries the game code, so it is the only
            # pass whose symbols are worth anything. Symbols from the other passes
            # are not merged, so the file is not a complete picture of the ROM.
            sym_out = symbols_path(rom_base, target, out_dir)
            main_pass += [f"--symbols={symbols}", f"--symbols-path={sym_out}"]

        if on_progress:
            on_progress("assembling main ROM")
        warnings += run(main_pass, str(assembled))
        warnings += run(["--define", "FileType=2"], str(assembled))
        warnings += run(
            ["--fix-checksum=off", "--define", "FileType=3"], str(assembled)
        )

        # A Windows process holding a handle on build/ -- Explorer with the folder
        # open is the usual one -- stops it being replaced from the WSL side, so a
        # preceding `rm -rf build` leaves it in a state where mkdir appears to
        # succeed but asar's write lands nowhere.
        if not assembled.exists():
            raise AsarError(
                f"asar reported success but produced no output at {assembled}\n"
                f"  something is holding {out_dir} open -- close it in Explorer or "
                f"your editor and retry"
            )

        # The framework pads to `!MaxROMSize`, so a longer image is something placed
        # past the end of the cartridge -- and the usual cause is freespace, which
        # **asar grows the ROM to satisfy rather than refusing**. A silently doubled
        # image is the surprise this whole option exists to replace, so it is a
        # failed build here and not the warning the framework settles for.
        #
        # Asked of every size and not only the expanded ones: the stock build is the
        # one where asar's auto-expansion is likeliest, since it has no room at all.
        if (got := assembled.stat().st_size) != assemble_size.size:
            raise AsarError(
                f"asked for a {assemble_size.label} cartridge and got {got:,} "
                f"bytes -- something is placed past the end of "
                f"{assemble_size.size:,}. If a patch used freespace, asar grew "
                f"the ROM to fit it: build at a larger --rom-size instead"
            )

    BuildRecord(
        base=rom_base.id,
        target=target.id,
        rom_size=wanted.id,
        defines=tuple(asked),
        symbols=symbols,
        overlaid=overlaid,
    ).write(record_at)

    return BuildResult(
        version=version,
        label=target.label,
        output_path=out_path,
        symbols_path=sym_out,
        warnings=warnings,
    )


def _source_size(
    base: RomBase, rom_size: RomSize, defines: tuple[tuple[str, str], ...]
) -> RomSize | None:
    """What size to assemble a vendored-pack base's image at, or ``None`` when
    the assembler reaches nothing at or below what was asked for.

    The pack's code assembles *inside* the main pass (``Config/SA1Pack.asm``),
    and its freespace search lands in the expansion the cartridge has -- so
    the image is assembled as large as the assembler can get it: the size
    asked for, since every size a base offers now carries a define the memory
    map reaches (past 4 MB, ``Config/SA1Pack.asm`` does the fills, the header
    mirror and the MMC values the pack's own size files used to). A feature
    that reserves an expansion bank needs that bank to exist while this
    assemble runs for the same reason. ``None`` only when nothing the
    assembler reaches lies at or below what was asked for.

    The base's stock size is a size the assembler reaches, so the stock
    build assembles at it and the pinned hash describes exactly that.
    """
    reachable = [
        ROM_SIZES[size_id]
        for size_id in base.sizes
        if ROM_SIZES[size_id].define is not None
        and ROM_SIZES[size_id].size <= rom_size.size
    ]
    return max(reachable, key=lambda size: size.size) if reachable else None


def _source_base(base: RomBase) -> RomBase:
    """The base whose tree the derived one is assembled from.

    The same tree, by construction: a base with a vendored pack shares
    ``src_root`` with the base it derives from, and differs in what its
    define switches on. What the derived base still takes from here is the
    size to fall back to should its own list offer nothing the assembler
    reaches -- the *source's* stock, not its own, which already counts the
    pack's growth.
    """
    from .bases import base as lookup  # noqa: PLC0415 -- avoids an import cycle

    source = lookup(DEFAULT_BASE)
    # The one patch declared today names its source target on the default base,
    # which is why the argument goes unread. A second patched base assembled
    # from some other tree must say whose -- this is what would catch it.
    assert base.src_root == source.src_root
    return source
