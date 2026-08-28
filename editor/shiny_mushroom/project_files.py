"""The primitives a project's folder is read and written through.

**One write, one signal, two caches.** Every file a project lays down goes
through :func:`_write_atomic`, which is what makes "a refused save is not a
save" possible (:func:`_capture` and :func:`_restore`) and what steps the
count everything remembering a reading is keyed on (:func:`writes`). The two
caches keyed on it are here beside it: :func:`_remembered` for a reading of
the folder, which lives until the next write, and :func:`_scanned` for a
reading of the overlay tree, which lives no longer than the block that asked
for it.

Here rather than in :mod:`shiny_mushroom.project` because a project is more
than one subject, and each subject's own module reaches for these -- see
:mod:`shiny_mushroom.project_graphics`. Nothing here knows what a project
*is*: a folder with a root is the whole of what these ask for
(:class:`Folder`), and :mod:`shiny_mushroom.project` publishes every name
below that anything outside reads.
"""

from __future__ import annotations

from contextlib import contextmanager
from datetime import UTC, datetime
from functools import wraps
from typing import TYPE_CHECKING, Concatenate, Protocol, cast

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Iterator
    from pathlib import Path


class Folder(Protocol):
    """What a remembered reading is keyed on: a project folder, and nothing
    else.

    A protocol rather than the class itself, so this module does not have to
    import the thing it is a primitive of.
    """

    @property
    def root(self) -> Path: ...


class ProjectError(Exception):
    """A project could not be created, opened or saved."""


#: What the overlay files edited **compressed** resources under, decompressed.
#:
#: The one part of the overlay that is not a mirror. Everything else shadows a
#: file the build would otherwise read; a compressed one cannot, because the
#: form the build reads is compressed and the form an editor works on is not,
#: and storing the compressed one would make the overlay a record of an
#: encoder's choices rather than of an edit. So this holds the raw form and
#: :func:`shiny_mushroom.build.merge` compiles it back -- see
#: :meth:`Project.save_raw` and :mod:`smw_tools.packed`, which is the registry
#: of what is compressed and how.
#:
#: Inside it the two base trees keep their own names, exactly as they do on the
#: shadowing side: ``raw/assets/GFX/SMW_U/GFX00.bin`` and
#: ``raw/SMW/levels/backgrounds/mountains.bin``.
RAW_NAME = "raw"


#: What a project has read off its folder, by project, reading and what the
#: reading was asked about (:func:`_key`), and the :func:`writes` count it was
#: read at.
#:
#: **One generation at a time**: the whole thing is dropped when that count
#: moves, rather than entry by entry, because a write says only that the tree
#: changed and not which reading it changed -- the reasoning :data:`_writes`
#: states. So a reading costs the disk once per write and nothing afterwards,
#: however many callers ask.
_readings: dict[tuple, object] = {}

#: The :func:`writes` count :data:`_readings` holds, or ``-1`` for empty.
_readings_at = -1


def _remembered[**Args, Reading](
    reading: Callable[Concatenate[Folder, Args], Reading],
) -> Callable[Concatenate[Folder, Args], Reading]:
    """Answer ``reading`` once per project per write, not once per caller.

    **For the readings a patch gather repeats**, which is the path this is
    for: gathering what a project has saved asks the same folder the same
    questions several times over -- and, on a checkout under a mounted
    Windows drive, a ``stat`` is milliseconds, so the questions *are* the
    cost. Measured on WSL, a gather of 69 stats, 14 directory walks and 23
    file reads takes 405 ms; the same gather with these remembered takes 95.

    Only for a reading that is **wholly a function of the project's folder**
    and returns something no caller mutates -- the two things that make the
    write count a sufficient invalidator. A reading of anything else, or one
    a caller writes into, does not belong here. In particular a reading of
    the **overlay tree** does not: that changes without this process writing
    anything, and :func:`_scanned` is its half.

    A reading may take arguments, which join the key and so must be hashable:
    one reading of several things is remembered per thing. They must be all
    that separates two answers -- callers asking the same question with the
    same arguments have to want the same answer.

    ``forget_readings`` is the other way out, for a tree changed by something
    that is not this process.
    """

    @wraps(reading)
    def answering(self: Folder, *args: Args.args, **kwargs: Args.kwargs) -> Reading:
        global _readings_at
        at = writes()
        if at != _readings_at:
            _readings.clear()
            _readings_at = at
        key = _key(self, reading, args, kwargs)
        if key not in _readings:
            _readings[key] = reading(self, *args, **kwargs)
        return cast(Reading, _readings[key])

    return answering


def _key(
    folder: Folder,
    reading: Callable[..., object],
    args: tuple[object, ...],
    kwargs: dict[str, object],
) -> tuple:
    """What one answer is filed under: the folder, the reading, and whatever
    it was asked about."""
    return (str(folder.root), reading.__qualname__, args, *sorted(kwargs.items()))


def forget_readings() -> None:
    """Drop what was read of every project's folder.

    For the one thing the write count cannot see: another program editing a
    tree while this one is open. Called where the window changes which
    project it is looking at -- see
    :func:`shiny_mushroom.cart_patches.forget_saved`, which drops its own
    reading in the same breath and for the same reason.
    """
    global _readings_at
    _readings.clear()
    _readings_at = -1


#: What has been scanned off a project's overlay inside the block
#: :func:`scanning_once` opens, keyed as :data:`_readings` is (:func:`_key`).
_scans: dict[tuple, object] = {}

#: How many :func:`scanning_once` blocks are open. Counted rather than a flag
#: so a gather that runs inside another gather's block still scans once.
_scanning = 0


def _scanned[**Args, Reading](
    reading: Callable[Concatenate[Folder, Args], Reading],
) -> Callable[Concatenate[Folder, Args], Reading]:
    """Answer ``reading`` once per :func:`scanning_once` block, and live
    outside one.

    :func:`_remembered`'s shorter-lived half, **for a reading of the overlay
    tree** -- which changes without this process writing anything, because a
    tile editor saving into the folder ``Open Folder`` shows is how a
    graphics file is meant to be repainted. The write count says nothing
    about that, so a reading of the tree may not outlive the block that asked
    for it, and everything that exists to notice such an edit -- the Graphics
    window on the way in, the catalogue it lists -- still reads the folder as
    it is.

    What the block buys is the repetition: a patch gather asks the same
    folder the same questions several times over, and those are one scan.
    So does a pass that walks every editable asm region -- pricing one
    fragment reads every other member of the run it shares, and the Source
    Files listing prices all twenty-one.

    Arguments join the key exactly as they do for :func:`_remembered`, so one
    reading of several things is scanned once per thing.

    A write of this process's own drops what was scanned
    (:func:`_write_atomic`), so a method that reads the overlay, writes, and
    reads again -- :meth:`~shiny_mushroom.project_graphics.GraphicsFiles.
    add_graphics` records the folder after
    saving into it -- sees the file it just wrote.
    """

    @wraps(reading)
    def answering(self: Folder, *args: Args.args, **kwargs: Args.kwargs) -> Reading:
        if not _scanning:
            return reading(self, *args, **kwargs)
        key = _key(self, reading, args, kwargs)
        if key not in _scans:
            _scans[key] = reading(self, *args, **kwargs)
        return cast(Reading, _scans[key])

    return answering


@contextmanager
def scanning_once() -> Iterator[None]:
    """Read the overlay tree once for the length of the block.

    Opened by the two gathers that ask a project what it has saved --
    ``MainWindow.test_patches`` and
    :func:`shiny_mushroom.cart_patches.project_patches` -- which is where the
    repetition is: what is edited, what is packed and which files the project
    adds are each asked for several times while one patch set is built, and
    the answer cannot change while it is being built.
    """
    global _scanning
    _scanning += 1
    try:
        yield
    finally:
        _scanning -= 1
        if not _scanning:
            _scans.clear()


def _string_list(held: object) -> tuple[str, ...]:
    """A stored list of strings, tolerantly: anything else reads as empty.

    Every metadata file here is hand-editable and none of them may stop a
    project from opening, so a field that is not a list costs the field rather
    than the folder. What the strings *mean* is checked by whoever reconciles
    them -- :func:`shiny_mushroom.patches.user_patches` for the patch manifest,
    :mod:`smw_tools.features` for a feature id.
    """
    if not isinstance(held, list):
        return ()
    return tuple(str(entry) for entry in held)


def _now() -> str:
    return datetime.now(UTC).isoformat(timespec="seconds")


def _capture(paths: Iterable[Path]) -> dict[Path, bytes | None]:
    """What each of ``paths`` holds now, ``None`` for one that is not there.

    Half of what makes "a refused save is not a save" true of a write that has
    already landed; :func:`_restore` is the other half. Taken **before** the
    first write, because a path written twice in one save would otherwise be
    remembered as the first write rather than as what was there to begin with.
    """
    return {path: path.read_bytes() if path.is_file() else None for path in paths}


def _restore(held: dict[Path, bytes | None]) -> None:
    """Put back exactly what :func:`_capture` found, the absences included."""
    for path, before in held.items():
        if before is None:
            path.unlink()
        else:
            _write_atomic(path, before)


#: How many times this process has written into a project folder.
#:
#: **The signal that what a project holds has changed.** Every write a
#: project makes goes through :func:`_write_atomic`, and every operation that
#: only *removes* files still stamps ``modified`` through it -- so this moves
#: whenever anything a project holds moves, which is what a reader that
#: remembers what it read needs to know (:func:`_remembered`). It says
#: nothing about *what* changed, deliberately: a
#: reader that has to re-read on any write is right, where one deciding for
#: itself which writes matter to it is one save away from being wrong.
_writes = 0


def writes() -> int:
    """How many times this process has written into a project -- see
    :data:`_writes`."""
    return _writes


def _write_atomic(path: Path, data: str | bytes) -> None:
    """Write through a temporary file and rename over the target.

    A half-written ``.mwl`` is a level that will not assemble, and a save
    interrupted by a crash or a full disk should leave the previous one intact
    rather than a truncated file the build chokes on.

    **The scan cache goes with it**, so a reading taken inside a
    :func:`scanning_once` block is never the folder as it stood before this
    write: a method that reads what the overlay holds, writes, and reads
    again -- adding a graphics file does -- would otherwise record the
    tree without the file it has just added. :data:`_writes` is stepped for
    the longer-lived half (:func:`_remembered`) for the same reason.
    """
    global _writes
    temporary = path.with_suffix(path.suffix + ".tmp")
    if isinstance(data, str):
        temporary.write_text(data, encoding="utf-8")
    else:
        temporary.write_bytes(data)
    temporary.replace(path)
    _writes += 1
    _scans.clear()
