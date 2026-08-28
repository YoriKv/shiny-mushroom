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
patch        --         a patched base only: its third-party patch, applied
                        over the finished image through the wrapper the base
                        declares (:attr:`~smw_tools.bases.PostBuildPatch`)
===========  =========  ======================================================

The order is load-bearing everywhere except the SPC700 group: those five write
five separate files and are run together, while every other pass patches the ROM
the pass before it wrote.

Both checksum flags are load-bearing and they disagree on purpose: the init pass
lets asar compute one so the image is well-formed, and the final pass writes the
cart's literal value -- two releases ship a checksum that is simply wrong, and
"correcting" it breaks byte-exactness.

The upstream batch file also runs ``FileType=6`` to write a firmware filename to
``Temp.txt``. SMW uses no coprocessor, so that pass is skipped; all five releases
are byte-exact without it.

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

import shutil
import tempfile
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
from .symbols import merge_pack_labels

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


@dataclass
class BuildResult:
    version: str
    label: str
    output_path: Path
    symbols_path: Path | None = None
    warnings: list[str] = field(default_factory=list)


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

    One file per build, the patched bases' included. The main pass writes the
    source's labels -- the RAM map resolved with the base's own defines, ROM
    addresses as the ROM map placed them -- and the patch pass merges its own
    in afterwards (:func:`~smw_tools.symbols.merge_pack_labels`). The source's
    addresses stay true on the patched cartridge because the patch edits bytes
    in place and never moves a label, so the merged file describes the
    cartridge the build actually produced.
    """
    out = output_dir or BUILD_DIR
    return out / target.output_name.replace(".sfc", ".sym")


def assembled_image_path(
    base: RomBase, target: BuildTarget, output_dir: Path | None = None
) -> Path:
    """Where the ROM passes' output is, before any patch pass has edited it.

    A patched base's cartridge is its assemble *plus* its patch pass, and what
    the patch changed is only measurable against what it was handed -- so the
    build keeps the assemble beside the cartridge instead of overwriting it.
    It is not a cartridge of its own: for ``sa1`` it is an image that needs an
    SA-1 to boot and has not had the pack applied, which is why it wears the
    ``.assemble`` suffix rather than a target's name. For a plain base the
    assemble *is* the cartridge, and this is :func:`output_path`.
    """
    out = output_dir or BUILD_DIR
    if base.patch is not None:
        return out / target.output_name.replace(".sfc", ".assemble.sfc")
    return output_path(base, target, out)


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

    The base's own build, whole: for a patched base that includes the patch
    pass, which is what puts the patch's labels in the file -- the pass costs
    about a second, and a file without those labels would go on describing the
    cartridge as though the patch placed nothing.
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

    wanted = rom_size if rom_size is not None else ROM_SIZES[rom_base.stock_size]
    if wanted.id not in rom_base.sizes:
        # A statement about the base rather than a failed assembly, so it is
        # `BaseError` -- which is what every caller of this module already
        # reports for "that is not a thing this base can be asked".
        raise BaseError(
            f"{rom_base.id} cannot be assembled at {wanted.label} -- it offers "
            f"{', '.join(rom_base.sizes)}"
        )
    # A patched base's ROM passes assemble the image its patch pass will edit,
    # so their size is the *source's* question: usually the source's stock,
    # left small for the patch to expand -- which is what the pinned hash was
    # taken over -- and larger only where `_source_size` says the assembler
    # itself has to provide the room. The base's own defines go on every pass,
    # the patch pass included, so the wrapper and the source read one switch.
    patch = rom_base.patch
    if patch is not None:
        # Located before anything assembles: a missing tree should cost the
        # message, not a build that dies at its final pass.
        pack_root = patch.locate()
        if pack_root is None:
            raise AsarError(patch.missing_message())
        source = _source_base(rom_base)
        assemble_size = _source_size(rom_base, wanted, defines) or ROM_SIZES[
            source.stock_size
        ]
        stock_id = source.stock_size
        defines = (*patch.source_defines, *defines)
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
    # a previous version wherever the current build writes nothing.
    out_path.unlink(missing_ok=True)
    # The ROM passes write here: the cartridge itself for a plain base, the
    # image the patch pass is handed for a patched one.
    assembled = assembled_image_path(rom_base, target, out_dir)
    assembled.unlink(missing_ok=True)

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

        if patch is not None:
            # The patch edits its input in place, so it runs over a copy and
            # the assemble stays what the ROM passes made of it.
            shutil.copy2(assembled, out_path)
            if on_progress:
                on_progress(f"applying {patch.label}")
            # The wrapper applies the patch when the base's define is set, and
            # reaches the patch's tree through the include path -- never a path
            # of its own, so an env override and a staged copy both resolve.
            # Symbols are merged for WLA only, which is the format everything
            # here reads; a no$sns request keeps its main-pass file unmerged.
            pack_sym = out_path.with_suffix(".pack.sym") if symbols == "wla" else None
            # The build's own defines reach the patch pass too: a
            # define-switched feature can need a fix-up *after* the patch --
            # the translevel remap's hook shares bytes with the pack's RAM
            # remapping -- and the pass entry is what tests them. A stock
            # build passes none, so the pinned cartridge's pass is exactly
            # what it was. Names the patch defines itself are the patch's:
            # asar refuses a command line naming one twice.
            own = {name for name, _ in patch.patch_defines} | {patch.define}
            pack_args = [
                *_define_args(
                    (
                        *(pair for pair in defines if pair[0] not in own),
                        *patch.patch_defines,
                        (patch.define, "1"),
                    )
                ),
                "--include",
                relative_path(pack_root, game),
            ]
            if pack_sym is not None:
                pack_args += [f"--symbols={symbols}", f"--symbols-path={pack_sym}"]
            warnings += run_asar(
                asar_binary(),
                [*pack_args, patch.pass_entry, str(out_path.resolve())],
                cwd=game,
                verbose=verbose,
            ).warnings
            if pack_sym is not None and sym_out is not None:
                try:
                    merge_pack_labels(sym_out, pack_sym, patch.label)
                except ValueError as error:
                    raise AsarError(str(error)) from None
                pack_sym.unlink()

            # Over the patched image, which is what the patch's own size files
            # pad and mirror the header of.
            extra = patch.entry_for(wanted.id)
            if extra is not None:
                if on_progress:
                    on_progress(f"expanding to {wanted.label}")
                warnings += run_asar(
                    asar_binary(),
                    [extra, str(out_path.resolve())],
                    cwd=pack_root,
                    verbose=verbose,
                ).warnings

            # The same question the assemble was asked, and here it covers the
            # patch too: it takes its freespace from asar, so an overrun comes
            # back longer than anyone asked for rather than failing.
            if (grew := out_path.stat().st_size) != wanted.size:
                raise AsarError(
                    f"asked for a {wanted.label} cartridge and got {grew:,} "
                    f"bytes -- {patch.label} placed something past the end of "
                    f"{wanted.size:,}. Build at a larger --rom-size instead"
                )

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
    """What size to assemble a patched base's intermediate at, or ``None`` to
    leave it to the patch.

    Only a size the *assembler* can reach reaches the intermediate, so the two
    the patch's own files place are ``None`` here. The stock size is ``None``
    too: the patch expands a 512 KB input itself, and that expansion is what
    the base's pinned hash was taken over.

    **Extra defines are the exception**, and they are the source's own: a
    feature that reserves an expansion bank needs that bank to exist while
    *this* assemble runs, and an expansion the patch performs afterwards comes
    too late to org into. So a build carrying any is assembled as large as the
    assembler can get it -- the size asked for, or, where the patch's own file
    is the only way to reach that, the largest size below it that the assembler
    *can* reach. A 6 MB `sa1` cartridge is assembled from a 4 MB intermediate
    and expanded by `asm/6mb.asm` as before; what it must not be is left at
    512 KB, where the bank the feature reserves does not exist at all and the
    source refuses itself.

    Nothing without a feature reaches that branch, so the pinned hash still
    describes the build anyone gets by default.
    """
    if defines:
        reachable = [
            ROM_SIZES[size_id]
            for size_id in base.sizes
            if ROM_SIZES[size_id].define is not None
            and ROM_SIZES[size_id].size <= rom_size.size
        ]
        return max(reachable, key=lambda size: size.size) if reachable else None
    if rom_size.define is None:
        return None
    if rom_size.id != base.stock_size:
        return rom_size
    return None


def _source_base(base: RomBase) -> RomBase:
    """The base whose tree the patched one is assembled from.

    The same tree, by construction: a patched base shares ``src_root`` with the
    base it derives from, and differs in what happens *after* the assembler.
    What the derived base still takes from here is the size its ROM passes
    assemble at when the patch is left to do the expanding -- the *source's*
    stock, not its own, which already counts the patch's growth.
    """
    from .bases import base as lookup  # noqa: PLC0415 -- avoids an import cycle

    source = lookup(DEFAULT_BASE)
    # The one patch declared today names its source target on the default base,
    # which is why the argument goes unread. A second patched base assembled
    # from some other tree must say whose -- this is what would catch it.
    assert base.src_root == source.src_root
    return source
