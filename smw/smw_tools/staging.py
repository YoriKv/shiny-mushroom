"""Assemble somewhere the filesystem is not the bottleneck.

Under WSL the checkout normally sits on a Windows drive, reached over 9p. Every
file open is a round-trip to a server on the Windows side, and asar opens the
tree in bulk -- 255 ``.asm`` files behind 294 ``incsrc`` and 353 ``incbin``
directives, re-read from scratch by every pass, nine passes per release.

The cost is not the assembling. Measured on the main pass, which is 19 of the 24
seconds a release takes:

=================  ==========  ==========  ==================================
tree lives on      wall        CPU         voluntary context switches
=================  ==========  ==========  ==================================
``/mnt/d`` (9p)    18.89s      2.73s       96,154
``/`` (ext4)        1.68s      1.75s       negligible
=================  ==========  ==========  ==================================

Seven eighths of that first row is time blocked on a syscall. So `check` copies
the sources somewhere local, assembles there, and deletes the copy -- taking
``check --all`` from around 110 seconds to under 20.

**The staged tree is scratch, not an output.** Nothing is copied back: `check`
reads its verdict out of the hashes, and the ROM it hashed goes with the rest.
`build` is the command that leaves a ROM on disk, and it does not stage.

Staging is skipped whenever it would not pay, and the conditions are in
:func:`staging_would_help` -- a native Linux or Windows checkout is already on a
local disk, and `asar.exe` under WSL interop cannot see an ext4 path at all.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

from .bases import RomBase
from .bases import base as default_base
from .paths import INTEROP_ROOT, WORK_ROOT, asar_binary, is_wsl


@dataclass(frozen=True)
class StagedTree:
    """Where a staged build reads its inputs and writes its output."""

    root: Path
    game_dir: Path
    assets_dir: Path
    build_dir: Path


def staging_would_help() -> bool:
    """True when copying the tree elsewhere is faster than assembling in place.

    Three conditions, and each one alone is enough to rule it out:

    ``is_wsl()``
        A native Linux or Windows checkout already reads at local-disk speed, so
        the copy would be pure cost.
    the assembler is not a ``.exe``
        A Windows binary under WSL interop cannot see an ext4 path, so a staged
        tree is simply invisible to it. Both asar builds are committed and the
        ELF is preferred, so this only bites where the ELF is missing.
    both the tree and the scratch space are on the right side of ``/mnt``
        Staging pays for exactly one reason -- it moves the reads off 9p. A tree
        that is already local has nothing to gain, and a ``TMPDIR`` pointing back
        at a Windows drive would move them from one 9p mount to another.
    """
    if not is_wsl():
        return False
    if asar_binary().suffix.lower() == ".exe":
        return False
    if not str(WORK_ROOT).startswith(INTEROP_ROOT):
        return False
    return not str(Path(tempfile.gettempdir()).resolve()).startswith(INTEROP_ROOT)


def _copy_tree(src: Path, dest: Path) -> None:
    """Copy ``src`` to ``dest``, by whichever means is present.

    rsync reads the tree from one process rather than one syscall at a time from
    Python, which is what the slow side of this copy is made of. It is not
    everywhere, though -- notably not on a stock Windows -- so the stdlib is the
    fallback rather than the requirement.

    A source that is not there is not copied and not an error. A fresh checkout
    has no ``assets/`` at all -- they are extracted from a cartridge rather than
    committed -- and staging must not decide anything a build in place would
    not: the missing file is reported by the ``incbin`` that wanted it, on
    either path.
    """
    if not src.is_dir():
        return
    rsync = shutil.which("rsync")
    if rsync:
        dest.mkdir(parents=True, exist_ok=True)
        subprocess.run([rsync, "-a", f"{src}/", f"{dest}/"], check=True)
    else:
        shutil.copytree(src, dest, dirs_exist_ok=True)


@contextmanager
def staged_sources(
    enabled: bool | None = None,
    on_progress: object = None,
    base: RomBase | None = None,
) -> Iterator[StagedTree | None]:
    """Stage ``base``'s sources in scratch space for the duration of the block.

    Yields ``None`` when the build should happen in place, which is what every
    caller must handle -- staging is an optimisation, and every path through here
    has to end at the same ROM.

    ``enabled`` forces the decision either way; the default asks
    :func:`staging_would_help`.
    """
    rom_base = base or default_base()
    if enabled is None:
        enabled = staging_would_help()
    if not enabled:
        yield None
        return

    root = Path(tempfile.mkdtemp(prefix="smw-build-"))
    pointed: str | None = None
    was: str | None = None
    try:
        if callable(on_progress):
            on_progress(f"staging sources in {root}")
        # The whole source root, not just the game folder: the entry point is
        # reached as ../Global/AssembleFile.asm and the framework resolves its
        # own paths from there, so Global has to be a sibling in the copy too.
        _copy_tree(rom_base.src_root, root / "src")
        _copy_tree(rom_base.assets_root, root / "assets")
        patch = rom_base.pack
        if patch is not None and (tree := patch.locate()) is not None:
            # The main pass opens the vendored tree the same way it opens src/
            # -- file by file, from wherever it is -- so it is staged for the
            # same reason, and pointed at through the tree's own env override:
            # the documented way to build against a tree elsewhere, restored on
            # the way out. A tree locate() cannot find is left for the build to
            # report.
            _copy_tree(tree, root / "patch")
            pointed, was = patch.env_var, os.environ.get(patch.env_var)
            os.environ[pointed] = str(root / "patch")
        build_dir = root / "build"
        build_dir.mkdir(parents=True, exist_ok=True)
        yield StagedTree(
            root=root,
            game_dir=root / "src" / rom_base.game_folder,
            assets_dir=root / "assets",
            build_dir=build_dir,
        )
    finally:
        if pointed is not None:
            if was is None:
                os.environ.pop(pointed, None)
            else:
                os.environ[pointed] = was
        try:
            shutil.rmtree(root)
        except OSError as exc:
            # Not fatal -- the verdict is already decided -- but it must not be
            # silent, or the scratch space fills up a directory at a time.
            print(f"warning: could not remove {root}: {exc}", file=sys.stderr)
