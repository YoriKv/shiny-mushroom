"""Handing a built cartridge to the emulator somebody already has.

The editor plays a level in a core of its own -- a second process, patched with
what is only in memory, entered by driving the game's own state machine
([`test-level.md`](../../docs/editor/test-level.md)). This is the other kind of
run: the project's cartridge, as it was built, opened in whatever emulator the
person already uses. Nothing is patched, because a program the editor merely
launched cannot be reached into -- so the cart boots to its title screen like
any other, and what is in it is what was saved.

**Except in Mesen**, which takes a Lua script on its command line and runs it
against the machine. This module knows only that such a script may be handed
over and that Mesen is the emulator that reads one (:func:`is_mesen`); what the
script says is :mod:`shiny_mushroom.mesen_lua`'s.

**Qt-free, so the launch itself is testable without a window.** What the store
holds is :mod:`shiny_mushroom.ui.settings_dialog`'s question; this module is
handed an executable and its files and decides only how to spell them for the
host.

Two hosts need that spelling changed:

- **macOS**, where an emulator is an ``.app`` bundle rather than a program. A
  bundle cannot be executed, so the ROM goes to ``open -a``, which is what a
  double-click does.
- **WSL**, where the emulator is usually a Windows binary reached through
  interop. It runs, but it cannot read a POSIX path, so the cartridge has to be
  handed over in Windows form -- ``wslpath`` for the general case, since a
  project lives in the Linux home rather than under ``/mnt``.
"""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

from smw_tools.paths import is_wsl, to_host_path

__all__ = ["MESEN_NAMES", "LaunchError", "is_mesen", "launch"]


class LaunchError(Exception):
    """The emulator could not be started, with the reason to show."""


#: What a Mesen build is called, without its extension. Mesen is the one
#: emulator the editor can ask for more than "open this file" -- it takes a Lua
#: script on its command line and runs it against the machine
#: (:mod:`shiny_mushroom.mesen_lua`) -- so it is the one this has to recognise.
#:
#: **By name, which is all there is to go on.** The file cannot be asked what it
#: is without running it, so an emulator renamed to something else is one the
#: editor treats as any other: the cartridge still opens, and it opens at the
#: title screen.
MESEN_NAMES = frozenset({"mesen", "mesence"})


def is_mesen(executable: Path) -> bool:
    """Whether ``executable`` looks like a Mesen build."""
    return executable.stem.lower() in MESEN_NAMES


def launch(executable: Path, rom: Path, script: Path | None = None) -> None:
    """Open ``rom`` in ``executable``, and leave it running.

    Detached: the emulator outlives the editor, which is the point of running
    the cartridge outside it. Nothing is waited for and nothing is read back --
    a run that ends is one somebody closed.

    ``script`` is a Lua file handed over beside the cartridge, which only Mesen
    reads -- see :func:`is_mesen`, the one caller that decides whether to pass
    one. It goes through the same host spelling the ROM does.

    :class:`LaunchError` for anything that stops it starting, worded for the
    person who set the path: a missing or unrunnable executable is the
    preference being wrong, not the cartridge.
    """
    if not executable.exists():
        raise LaunchError(f"There is nothing at {executable}.")
    if not rom.is_file():
        raise LaunchError(f"There is no cartridge at {rom}.")
    if script is not None and not script.is_file():
        raise LaunchError(f"There is no script at {script}.")
    try:
        subprocess.Popen(
            _command(executable, rom, script),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            # POSIX only, and what keeps the emulator from dying with the
            # editor's process group. Windows detaches a GUI child anyway.
            start_new_session=os.name != "nt",
        )
    except OSError as error:
        raise LaunchError(error.strerror or str(error)) from error


def _command(executable: Path, rom: Path, script: Path | None = None) -> list[str]:
    """The argument list that opens ``rom``, spelled for this host."""
    files = [rom] if script is None else [rom, script]
    # A macOS bundle is a directory: `open -a` is the only way to run one, and
    # the files after it are what a double-click hands the application.
    if executable.suffix == ".app":
        return ["open", "-a", str(executable), *(str(file) for file in files)]
    return [str(executable), *(_host_argument(executable, file) for file in files)]


def _host_argument(executable: Path, file: Path) -> str:
    """A file as the emulator will be able to open it.

    Itself everywhere but one place: a Windows emulator run from WSL, which
    sees the filesystem the editor is on only through a UNC path.
    ``to_host_path`` covers the drives mounted under ``/mnt``; ``wslpath``
    covers the rest, which is where projects actually live. A conversion that
    fails hands the path over unchanged rather than raising -- the emulator's
    own "file not found" says more than a translation error would.
    """
    if not is_wsl() or executable.suffix.lower() != ".exe":
        return str(file)
    converted = to_host_path(file)
    if converted != str(file):
        return converted
    try:
        return subprocess.run(
            ["wslpath", "-w", str(file)],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return str(file)
