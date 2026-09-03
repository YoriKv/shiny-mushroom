"""Build Mesen's emulation core for this machine.

The editor drives ``MesenCore`` -- the emulator without its .NET front end --
through ctypes. Mesen's makefile has a ``core`` target that builds exactly that
shared library and nothing else, so no .NET SDK is involved on Linux or macOS;
Windows builds the same thing from ``InteropDLL/InteropDLL.vcxproj``.

    uv run python packaging/build_mesen_core.py

With no arguments it clones the revision pinned in ``mesen-pin.json`` and puts
the result in ``mesen-cores/<os>-<arch>/`` at the repository root -- uncommitted,
and the first place :func:`shiny_mushroom.emu.core.library_path` looks. That is the
development path: build a core, and the editor and its tests use it.

``--vendor`` writes into ``editor/shiny_mushroom/resources/mesen/`` instead, which is
what ships. Releases normally take those from the *Mesen core* workflow, which
builds all platforms from the same pin; use ``--vendor`` locally only when you
mean to commit the result.

Build dependencies:

- **Linux** -- ``libsdl2-dev`` and ``libx11-dev``, plus a C++17 compiler.
- **macOS** -- ``brew install sdl2``.
- **Windows** -- Visual Studio 2022 build tools; the build runs through MSBuild.

SDL's renderer and key manager are linked but never called: the editor passes a
software renderer and ``noInput``, so nothing needs a display at runtime. Its
sound manager is what a play worker's audio comes out of on Linux and macOS --
``uv run pytest`` opens no device at all
(``shiny_mushroom.emu.core.MesenCore.NO_AUDIO_ENV``), which is what keeps the
suite silent on a developer's machine and runnable on a CI box with no card.

**Licence.** Mesen is GPLv3 and so is this repository, so bundling it is
permitted; what it obliges is offering Mesen's corresponding source alongside any
release. The pin file and the ``provenance.json`` written next to each library
are what that offer points at -- which is why this script builds from a clone of
a known commit rather than from whatever tree happens to be lying around.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PIN_FILE = Path(__file__).resolve().parent / "mesen-pin.json"
VENDOR_ROOT = REPO / "editor/shiny_mushroom/resources/mesen"
DEV_ROOT = REPO / "mesen-cores"
CHECKOUT_ROOT = REPO / "smw/tmp/mesen-src"
PATCH_DIR = Path(__file__).resolve().parent / "mesen-patches"

#: The source trees :func:`smoke_test` puts on the path. Both, because the
#: ctypes binding reads its memory map from ``smw_tools`` -- and neither package
#: is installed on the runner that builds a release core. The test suite checks
#: the whole chain imports from these two alone.
SOURCE_TREES = (REPO / "editor", REPO / "smw")

#: Filename per OS, mirroring ``shiny_mushroom.emu.core._LIBRARY_FILENAMES``. The
#: test suite checks the two agree.
LIBRARY_NAMES = {
    "Linux": "MesenCore.so",
    "Darwin": "MesenCore.dylib",
    "Windows": "MesenCore.dll",
}


def pin() -> dict[str, str]:
    return json.loads(PIN_FILE.read_text())


def platform_dir() -> str:
    """``<os>-<arch>`` for this machine, matching the vendor layout."""
    system = {"Linux": "linux", "Darwin": "macos", "Windows": "windows"}[
        platform.system()
    ]
    machine = platform.machine().lower()
    arch = "arm64" if machine in ("arm64", "aarch64") else "x64"
    return f"{system}-{arch}"


def checkout(ref: str, into: Path) -> Path:
    """Clone the pinned Mesen revision, or reuse an existing checkout of it."""
    if (into / ".git").exists():
        current = _git(into, "rev-parse", "HEAD")
        wanted = _git(into, "rev-parse", ref + "^{commit}") if current else ""
        if current and current == wanted:
            print(f"> reusing  {into} at {ref}")
            return into
        shutil.rmtree(into)

    into.parent.mkdir(parents=True, exist_ok=True)
    print(f"> cloning  {pin()['repository']} at {ref}")
    subprocess.run(
        [
            "git",
            "clone",
            "--depth",
            "1",
            "--branch",
            ref,
            pin()["repository"],
            str(into),
        ],
        check=True,
    )
    return into


def patches() -> list[Path]:
    """The patches applied on top of the pin, in name order.

    Each is a fix this project needs and upstream does not yet carry. They are
    files rather than a fork so that what is changed is reviewable in one place
    and the pin stays a plain upstream commit -- and because **GPL-3.0 requires
    a modified version to carry prominent notices of what was changed**, which
    is exactly what a patch directory is.
    """
    return sorted(PATCH_DIR.glob("*.patch"))


def apply_patches(source: Path) -> list[str]:
    """Apply every patch to ``source``, and say which. Idempotent.

    ``--ignore-whitespace`` because the patches are stored with LF endings, as
    everything in this repository is, while Mesen's tree checks out CRLF. Only
    the line terminators differ and `git apply` compares bytes, so without it a
    correct patch is refused.

    A patch that is already applied is skipped rather than failing the build,
    which is what makes rebuilding over an existing checkout work.
    """
    applied = []
    for patch in patches():
        already = subprocess.run(
            [
                *("git", "apply", "-p1", "--ignore-whitespace"),
                *("--reverse", "--check", str(patch)),
            ],
            cwd=source,
            capture_output=True,
        )
        if already.returncode == 0:
            print(f"> patched  {patch.name} (already applied)")
            applied.append(patch.name)
            continue
        result = subprocess.run(
            ["git", "apply", "-p1", "--ignore-whitespace", str(patch)],
            cwd=source,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise SystemExit(
                f"{patch.name} does not apply to {source}:\n{result.stderr}\n"
                "The pin has moved under the patch, or upstream has fixed it. "
                "Rebase or delete the patch -- do not build an unpatched core, "
                "because what these fix is not visible in a smoke test."
            )
        print(f"> patched  {patch.name}")
        applied.append(patch.name)
    return applied


def _git(cwd: Path, *args: str) -> str:
    try:
        return subprocess.run(
            ["git", *args], cwd=cwd, capture_output=True, text=True, check=True
        ).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def build(source: Path, jobs: int, use_gcc: bool) -> Path:
    """Build the shared library and return where it landed."""
    name = LIBRARY_NAMES[platform.system()]

    if platform.system() == "Windows":
        # The makefile is POSIX-only; on Windows the same library comes out of
        # the InteropDLL project, which is what the solution builds for the UI.
        #
        # SolutionDir has to be passed explicitly. MSBuild only defines it when
        # a *solution* drives the build; for a direct .vcxproj it is empty, and
        # this project's OutDir is "$(SolutionDir)\bin\win-$(PlatformTarget)\
        # $(Configuration)\". Empty makes that "\bin\win-x64\Release\" -- the
        # root of the current drive. The compile then succeeds and writes the
        # library somewhere this script never looks, so the failure surfaces as
        # "produced no MesenCore.dll" with nothing in the build log to explain
        # it. The trailing separator is the MSBuild convention for the property.
        print("> building MesenCore with MSBuild")
        result = subprocess.run(
            [
                "msbuild",
                str(source / "InteropDLL" / "InteropDLL.vcxproj"),
                f"/p:SolutionDir={source}{os.sep}",
                "/p:Configuration=Release",
                "/p:Platform=x64",
                f"/m:{jobs}",
            ]
        )
        if result.returncode != 0:
            raise SystemExit(
                "the Mesen core build failed. On Windows this needs the Visual "
                "Studio 2022 build tools: the project pins PlatformToolset v143, "
                "which earlier Visual Studio versions do not provide."
            )
    else:
        env = {**os.environ}
        if use_gcc:
            # clang is the makefile's default and produces faster code, but gcc
            # is what a stock Ubuntu or WSL has, and this is the one flag that
            # decides whether the build runs at all.
            env["USE_GCC"] = "true"
        print(f"> building MesenCore in {source} (make core -j{jobs})")
        result = subprocess.run(["make", "core", f"-j{jobs}"], cwd=source, env=env)
        if result.returncode != 0:
            raise SystemExit(
                "the Mesen core build failed. This is usually missing build "
                "dependencies -- see this script's module docstring."
            )

    found = [p for p in source.rglob(name) if p.is_file()]
    if not found:
        raise SystemExit(
            f"the build reported success but produced no {name} under {source}. "
            "On Windows this usually means OutDir resolved outside the source "
            "tree -- check that /p:SolutionDir reached MSBuild."
        )

    # Both builds leave more than one copy around -- the makefile copies the
    # library to bin/ as pgohelperlib, MSBuild writes per-configuration output
    # trees -- and picking a stale one would vendor whatever was there before
    # this run. Prefer the build output proper, then fall back to whichever copy
    # this build actually just wrote.
    hint = "Release" if platform.system() == "Windows" else "InteropDLL"
    preferred = [p for p in found if hint in p.parts]
    return max(preferred or found, key=lambda p: p.stat().st_mtime)


def install(library: Path, source: Path, destination: Path, applied: list[str]) -> Path:
    destination.mkdir(parents=True, exist_ok=True)
    target = destination / library.name
    shutil.copy2(library, target)

    (destination / "provenance.json").write_text(
        json.dumps(
            {
                **pin(),
                "commit": _git(source, "rev-parse", "HEAD") or pin()["commit"],
                "described": _git(source, "describe", "--tags", "--always")
                or pin()["ref"],
                "built_on": platform.platform(),
                "platform": platform_dir(),
                # What this core is, beyond the commit. A library built from a
                # patched tree is not the pinned upstream one, and the offer of
                # corresponding source has to point at both.
                "patches": applied,
            },
            indent=2,
        )
        + "\n"
    )
    return target


def smoke_test(library: Path) -> None:
    """Load the library and ask its version, so a bad build fails here.

    Cheap, and it catches the failures that otherwise surface much later: a
    library missing a runtime dependency, built for the wrong architecture, or
    linked against something the runner has and a user will not.
    """
    sys.path[:0] = [str(tree) for tree in SOURCE_TREES]
    os.environ["SHINY_MUSHROOM_MESEN_CORE"] = str(library)
    from shiny_mushroom.emu.core import MesenCore

    core = MesenCore()
    print(f"> loaded   MesenCore reports version {'.'.join(map(str, core.version))}")
    core.release()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source", help="use an existing Mesen src/ tree instead of cloning"
    )
    parser.add_argument("--ref", help="Mesen revision to clone (default: the pin file)")
    parser.add_argument(
        "--vendor",
        action="store_true",
        help="install into the packaged resources instead of mesen-cores/",
    )
    parser.add_argument("--output", help="install somewhere else entirely")
    parser.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    parser.add_argument(
        "--clang",
        action="store_true",
        help="build with clang instead of gcc (faster code, not always installed)",
    )
    parser.add_argument("--skip-smoke-test", action="store_true")
    args = parser.parse_args()

    if platform.system() not in LIBRARY_NAMES:
        raise SystemExit(f"no Mesen core target defined for {platform.system()}")

    if args.source:
        source = Path(args.source).expanduser().resolve()
        if not (source / "makefile").exists() and platform.system() != "Windows":
            raise SystemExit(f"{source} does not look like Mesen's src/ directory")
    else:
        source = checkout(args.ref or pin()["ref"], CHECKOUT_ROOT)

    root = (
        Path(args.output) if args.output else (VENDOR_ROOT if args.vendor else DEV_ROOT)
    )
    applied = apply_patches(source)
    library = build(source, args.jobs, use_gcc=not args.clang)
    target = install(library, source, root / platform_dir(), applied)

    if not args.skip_smoke_test:
        smoke_test(target)

    print(f"> installed {target} ({target.stat().st_size / 1_048_576:.1f} MB)")
    if not args.vendor:
        print("> this is a development core; releases use the 'Mesen core' workflow")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
