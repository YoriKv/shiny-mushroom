"""Thin wrapper around the asar assembler.

asar reports failures on stdout rather than by exit code in some paths, so this
scans the output for ``error:`` lines as well as checking the status. Anything
less strict risks a "successful" build that silently produced a half-assembled
ROM.
"""

from __future__ import annotations

import os
import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

#: Warnings this project deliberately silences.
#:
#: ``feature_deprecated`` fires ~50 times per build: the disassembly uses
#: ``rep N : db $FF``, ``check bankcross on`` and ``math pri on``, all of which
#: asar 1.91 has deprecated but still honours. Rewriting them is a source change
#: that must not alter a single ROM byte, so it is deliberately kept separate;
#: until then the noise would bury real diagnostics.
SILENCED_WARNINGS = ["feature_deprecated"]

#: Keep the assembler off the screen on Windows.
#:
#: ``asar.exe`` is a console program, so Windows hands it a console of its own
#: whenever the parent has none -- a black window flashing over the editor once
#: per assembler run, and an extraction or a build makes dozens. Its output is
#: captured here in every case, so that console never shows anything: the flash
#: is the whole of it.
_NO_WINDOW: dict[str, int] = (
    {"creationflags": subprocess.CREATE_NO_WINDOW} if os.name == "nt" else {}
)

_ERROR_LINE = re.compile(r"(^|\s)error:")
_WARNING_LINE = re.compile(r"(^|\s)warning:")


def warning_flags() -> list[str]:
    return [f"-wno{w}" for w in SILENCED_WARNINGS]


@dataclass
class AsarResult:
    stdout: str
    stderr: str
    warnings: list[str] = field(default_factory=list)


class AsarError(RuntimeError):
    pass


def run_asar(
    asar_bin: Path,
    args: list[str],
    cwd: Path,
    verbose: bool = False,
) -> AsarResult:
    try:
        proc = subprocess.run(
            [str(asar_bin), *args],
            cwd=str(cwd),
            capture_output=True,
            text=True,
            errors="replace",
            **_NO_WINDOW,
        )
    except OSError as exc:
        raise AsarError(f"failed to launch asar ({asar_bin}): {exc}") from exc

    stdout = proc.stdout or ""
    stderr = proc.stderr or ""
    if verbose and stdout.strip():
        print(stdout.rstrip())

    combined = f"{stdout}\n{stderr}"
    errors = [ln for ln in combined.split("\n") if _ERROR_LINE.search(ln)]
    warnings = [ln for ln in combined.split("\n") if _WARNING_LINE.search(ln)]

    if proc.returncode != 0 or errors:
        detail = "\n".join(errors[:20]) if errors else combined.strip()
        raise AsarError(
            f"asar failed (exit {proc.returncode})\n"
            f"  command: {asar_bin} {' '.join(args)}\n"
            f"  cwd:     {cwd}\n{detail}"
        )

    return AsarResult(stdout=stdout, stderr=stderr, warnings=warnings)
