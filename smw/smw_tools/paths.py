"""Project path resolution, plus the host-dependent asar and emulator lookups."""

from __future__ import annotations

import os
import re
from pathlib import Path

#: The `smw/` package directory, derived from this file's location rather than cwd.
WORK_ROOT = Path(__file__).resolve().parent.parent

#: Mount point of the Windows drives under WSL. A path under here is a Windows
#: one reached over 9p, and is the only kind :func:`to_host_path` can translate;
#: a path outside it is the VM's own ext4 disk, which no Windows binary can see.
INTEROP_ROOT = "/mnt/"

SRC_DIR = WORK_ROOT / "src"
BUILD_DIR = WORK_ROOT / "build"
REFERENCE_DIR = WORK_ROOT / "reference"
TMP_DIR = WORK_ROOT / "tmp"

#: The game folder, and the framework it sits beside. Both names are fixed by
#: the framework: Global_Macros.asm resolves `../<GameID>/RomMap/...` with
#: GameID="SMW", so neither can be renamed without editing the framework.
GAME_DIR = SRC_DIR / "SMW"
GLOBAL_DIR = SRC_DIR / "Global"

#: The assembler entry point, as reached from GAME_DIR. It is a dispatcher, not
#: a manifest: which part of the ROM it emits depends on ``--define FileType``.
#: Kept relative because the framework resolves sibling paths from it.
FRAMEWORK_ENTRY = Path("..") / "Global" / "AssembleFile.asm"

#: ROM-derived assets, kept out of the source tree (and out of git) because they
#: are copyrighted cart data. The build reaches them through asar's include
#: search path instead -- see ``asset_include_args``.
ASSETS_DIR = WORK_ROOT / "assets"

#: Written beside the assets to record which cart produced them.
EXTRACTION_STATE = WORK_ROOT / ".extraction-state.json"


def asset_include_args(cwd: Path = GAME_DIR, assets: Path | None = None) -> list[str]:
    """asar ``--include`` flags that make the relocated assets resolvable.

    Two paths, because the tree incbins them at two different depths: the ROM
    map asks for ``GFX/SMW_U/x.lz2`` from the game folder, while ``SPC700/*.asm``
    asks for ``Music/Levels/x.bin`` relative to itself. Passing both means not a
    single ``incbin`` in the imported tree has to change.

    ``assets`` overrides where they are, defaulting to the checkout's own. An
    editor project builds from a *merged* assets root -- the extracted ones with
    whatever it has overlaid on top -- and this is the whole of what it takes to
    point the build at it.

    Relative where it can be, because a relative include is the one spelling
    every host reads the same way -- including asar.exe launched from WSL, which
    cannot resolve a POSIX absolute path.
    """
    root = assets or ASSETS_DIR
    return [
        arg
        for path in (root, root / "SPC700")
        for arg in ("--include", relative_path(path, cwd))
    ]


def relative_path(path: Path | str, start: Path | str | None = None) -> str:
    """``path`` spelled from ``start`` -- the working directory by default.

    Absolute when there is no relative spelling at all: Windows has no path
    between two drives, and `os.path.relpath` raises rather than saying so. Both
    callers want the short form as a convenience and neither is entitled to fail
    over it -- an include asar takes either way, and a line of a report.
    """
    try:
        return os.path.relpath(path, start)
    except ValueError:
        return str(path)


def asar_binary() -> Path:
    """Pick the asar build committed at the package root.

    Both are checked in so the project builds from Windows and from WSL/Linux
    without a setup step; under WSL we prefer the Linux ELF because launching
    the PE through interop is markedly slower.
    """
    elf = WORK_ROOT / "asar"
    exe = WORK_ROOT / "asar.exe"
    if os.name == "nt":
        if exe.exists():
            return exe
        raise FileNotFoundError(f"asar.exe not found at {exe}")
    if elf.exists():
        return elf
    if exe.exists():
        return exe
    raise FileNotFoundError(f"no asar binary found at {elf} or {exe}")


def is_wsl() -> bool:
    """True under WSL, where .exe files are launchable but need Windows paths."""
    if os.name == "nt":
        return False
    try:
        return "microsoft" in Path("/proc/sys/kernel/osrelease").read_text().lower()
    except OSError:
        return False


def to_host_path(p: Path | str) -> str:
    """Translate a POSIX path to a Windows one for a Windows binary under WSL.

    Outside WSL this is the identity.
    """
    text = str(p)
    if not is_wsl():
        return text
    m = re.match(rf"^{re.escape(INTEROP_ROOT)}([a-z])/(.*)$", text)
    if not m:
        return text
    return f"{m.group(1).upper()}:\\{m.group(2).replace('/', chr(92))}"


def find_patch_tree(env: str, names: list[str], marker: str) -> Path | None:
    """Locate a third-party patch tree the user supplies themselves.

    Checked in order: ``$<env>``, then each of ``names`` beside this package and
    beside the repository. ``marker`` is a path that must exist inside it, so a
    directory that merely has the right name is not mistaken for the tree.

    **The fallback behind a vendored default.** :func:`find_vendored_tree` asks
    the environment and then the vendored copy, and reaches here only when both
    are absent -- the sibling-checkout search is a last resort, not the
    arrangement.

    Returns None rather than raising, so a caller can say what is missing and
    how to supply it.
    """
    found = os.environ.get(env)
    if found and (Path(found) / marker).exists():
        return Path(found)
    roots = [WORK_ROOT, WORK_ROOT.parent, WORK_ROOT.parent.parent]
    for root in roots:
        for name in names:
            candidate = (root / name).resolve()
            if (candidate / marker).exists():
                return candidate
    return None


#: Third-party trees vendored into this package, kept **outside** ``src/``.
#:
#: That placement is not tidiness. Four things walk ``src/`` and would each be
#: wrong about a patch tree: `verify_static`'s include-casing check, the
#: ASCII-only rule, the analysis tools (`codegraph`, `address_index`, `symbols`),
#: which would index someone else's `org` directives as if they were our
#: disassembly, and the base contract's ROM-map checks.
VENDOR_DIR = WORK_ROOT / "vendor"

#: SA-1 Pack: vendored, and pinned beside itself.
SA1_PACK_ENV = "SA1_PACK_PATH"
SA1_PACK_DIR = VENDOR_DIR / "sa1-pack"
SA1_PACK_PIN = VENDOR_DIR / "sa1-pack-pin.json"
SA1_PACK_NAMES = ["SMW-SA1-Pack", "sa1-pack"]
SA1_PACK_ENTRY = "asm/sa1.asm"


def find_vendored_tree(
    env: str, vendored: Path, entry: str, names: list[str] | None = None
) -> Path | None:
    """A third-party tree: the vendored copy, unless overridden.

    ``$<env>`` wins, so a newer upstream can be built against without touching
    the repository -- which is the whole way to find out whether an upgrade
    moves the ROM before deciding to vendor it. Otherwise the vendored copy,
    and only then a sibling checkout named in ``names``, which is what a working
    tree looked like before such a tree was committed.

    ``entry`` is the file that must exist inside it, so a directory that merely
    has the right name is not mistaken for the tree.
    """
    override = os.environ.get(env)
    if override and (Path(override) / entry).exists():
        return Path(override)
    if (vendored / entry).exists():
        return vendored
    return find_patch_tree(env, names or [], entry)


def find_sa1_pack() -> Path | None:
    """The SA-1 Pack tree. The declaration that builds against it is
    :data:`~smw_tools.bases.SA1`'s patch, which finds it the same way."""
    return find_vendored_tree(
        SA1_PACK_ENV, SA1_PACK_DIR, SA1_PACK_ENTRY, SA1_PACK_NAMES
    )


def find_mesen() -> Path | None:
    """Locate the Mesen executable.

    Checked in order: ``$MESEN_PATH``, an ``emulator/`` directory inside
    package, then an adjacent ``../Mesen`` beside the package or beside the
    repository. Returns None when not found so callers can print an actionable
    message instead of raising.
    """
    env = os.environ.get("MESEN_PATH")
    if env and Path(env).exists():
        return Path(env)
    names = ["Mesen.exe"] if os.name == "nt" else ["Mesen", "Mesen.exe"]
    # WORK_ROOT is this package (smw/), which sits inside the repository root,
    # so an emulator kept alongside the repo is two levels up rather than one.
    dirs = [
        WORK_ROOT / "emulator",
        WORK_ROOT / ".." / "Mesen",
        WORK_ROOT / ".." / "MesenCE",
        WORK_ROOT / ".." / ".." / "Mesen",
        WORK_ROOT / ".." / ".." / "MesenCE",
    ]
    for d in dirs:
        for n in names:
            p = (d / n).resolve()
            if p.exists():
                return p
    return None
