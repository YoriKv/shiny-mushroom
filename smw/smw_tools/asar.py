"""Thin wrapper around the asar assembler.

asar reports failures on stdout rather than by exit code in some paths, so this
scans the output for ``error:`` lines as well as checking the status. Anything
less strict risks a "successful" build that silently produced a half-assembled
ROM.

**A run that fails writes what it said to a log.** The exception carries the
first few ``error:`` lines, which is what fits in a message; a build that will
not assemble is read by looking at the whole of the assembler's output, and the
one place every run of it goes through is here.
"""

from __future__ import annotations

import os
import re
import subprocess
import threading
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from smw_tools.paths import logs_dir

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

#: What a failed run's output is written to, under
#: :func:`~smw_tools.paths.logs_dir`.
#:
#: One file, overwritten each time. The run worth reading is the one that just
#: failed -- a build makes eight assembler passes and stops at the first that
#: does not work -- and a directory of timestamped logs is a thing nobody ever
#: prunes.
FAILURE_LOG = "asar-failure.log"

#: How many error lines the exception's own message carries. The rest are in
#: the log: a dialog holding a hundred of them is unreadable, and the first few
#: are where the cause usually is.
MESSAGE_ERRORS = 20

#: Serialises the write of :data:`FAILURE_LOG`. A build runs the SPC700 passes
#: on three threads at once, so two of them can fail within a moment of each
#: other -- and one truncating the file while the other is writing it would
#: leave a log that is neither run's output.
_LOG_LOCK = threading.Lock()


def _log_line(log: Path | None) -> str:
    """The line naming the log, for a message that has one to name. Empty
    otherwise, so a run whose output could not be kept says nothing about it."""
    return "" if log is None else f"\n  log:     {log}"


def warning_flags() -> list[str]:
    return [f"-wno{w}" for w in SILENCED_WARNINGS]


@dataclass
class AsarResult:
    stdout: str
    stderr: str
    warnings: list[str] = field(default_factory=list)


class AsarError(RuntimeError):
    """A run of the assembler that did not produce what was asked for.

    :attr:`log_path` is where the whole of that run's output was written, for a
    failure that came from running it -- ``None`` where there was no output to
    keep, which is every check made *about* a run rather than by one, and a
    failure of the write itself. It is what the editor's "View Compiler Log"
    button reads.
    """

    def __init__(self, message: str, log_path: Path | None = None) -> None:
        super().__init__(message)
        self.log_path = log_path


def _write_log(
    asar_bin: Path,
    args: list[str],
    cwd: Path,
    exit_code: int | None,
    output: str,
) -> Path | None:
    """Write a failed run's output where the editor can show it, and say where.

    ``None`` rather than an exception when it cannot be written: a build that
    failed must report what the assembler said, not what the logger could not
    do.
    """
    path = logs_dir() / FAILURE_LOG
    when = datetime.now().astimezone().isoformat(timespec="seconds")
    status = "did not launch" if exit_code is None else f"exit {exit_code}"
    try:
        with _LOG_LOCK:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(
                f"{when}\n"
                f"command: {asar_bin} {' '.join(args)}\n"
                f"cwd:     {cwd}\n"
                f"status:  {status}\n\n"
                f"{output.rstrip()}\n",
                encoding="utf-8",
            )
    except OSError:
        return None
    return path


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
        log = _write_log(asar_bin, args, cwd, None, str(exc))
        raise AsarError(
            f"failed to launch asar ({asar_bin}): {exc}{_log_line(log)}", log
        ) from exc

    stdout = proc.stdout or ""
    stderr = proc.stderr or ""
    if verbose and stdout.strip():
        print(stdout.rstrip())

    combined = f"{stdout}\n{stderr}"
    errors = [ln for ln in combined.split("\n") if _ERROR_LINE.search(ln)]
    warnings = [ln for ln in combined.split("\n") if _WARNING_LINE.search(ln)]

    if proc.returncode != 0 or errors:
        detail = "\n".join(errors[:MESSAGE_ERRORS]) if errors else combined.strip()
        log = _write_log(asar_bin, args, cwd, proc.returncode, combined)
        raise AsarError(
            f"asar failed (exit {proc.returncode})\n"
            f"  command: {asar_bin} {' '.join(args)}\n"
            f"  cwd:     {cwd}{_log_line(log)}\n{detail}",
            log,
        )

    return AsarResult(stdout=stdout, stderr=stderr, warnings=warnings)
