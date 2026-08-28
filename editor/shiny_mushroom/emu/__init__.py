"""Rendering a level by running the game, with the core held at arm's length.

The editor needs a level's tiles, graphics and colours. It can get them by
reimplementing SMW's formats, or by running SMW's own loader and reading what it
produced. This package is the second: a vendored Mesen core drives the cart
through its real level-load path, and the result comes back as a
:class:`~shiny_mushroom.level_snapshot.LevelSnapshot`.

The reason to do it this way is correctness, not speed. A parser is faster and
has no native dependency, but it is only right about the ROM it was written
against -- a hack whose loader was patched produces something the parser has
never seen, and the failure is a subtly wrong picture rather than an error. The
cart's own code is right by construction about whatever cart it is given.

**The layout is a safety boundary, not a filing decision.**

- :mod:`~shiny_mushroom.emu.supervisor` runs in the editor's process and never loads
  the shared library. Everything the app touches is here.
- :mod:`~shiny_mushroom.emu.worker` is a separate process that owns the core, so a
  segfault costs a restart rather than the application.
- :mod:`~shiny_mushroom.emu.core`, :mod:`~shiny_mushroom.emu.smw` and
  :mod:`~shiny_mushroom.emu.play` are the worker's internals: the ctypes binding,
  the game's load choreography, and the same choreography ending in a level
  somebody can play. The rest of the choreography is
  :mod:`~shiny_mushroom.emu.sprite_probe`,
  :mod:`~shiny_mushroom.emu.overworld_capture` and
  :mod:`~shiny_mushroom.emu.loading`.

**Importing anything in this package loads the ctypes binding**, because this
module publishes the supervisors and they reach the core through it. That is
why everything a document can want without a machine is outside it:
:mod:`shiny_mushroom.addresses` says where a base keeps everything,
:mod:`shiny_mushroom.rom_patches` is byte arithmetic over an image,
:mod:`shiny_mushroom.level_snapshot`, :mod:`shiny_mushroom.overworld_snapshot`
and :mod:`shiny_mushroom.sprite_art` are what a capture comes back as,
:mod:`shiny_mushroom.play_request` is what a test run is asked for, and
:mod:`shiny_mushroom.worker_protocol` is the framing between the two processes
-- which ``shiny_mushroom/__main__.py`` reads before it knows which one it is.
None of them may import anything from here, and
``editor/tests/test_imports.py`` measures that rather than trusting it.

Nothing here imports Qt, and turning a snapshot into a picture is the ``ui``
side's job -- a snapshot is bytes, which is what makes it diffable against a
future static parser producing the same type.

    from shiny_mushroom.emu import EmulatorSupervisor

    with EmulatorSupervisor(rom) as emu:
        snapshot = emu.load_level(0x105)
        preview = emu.load_level(0x105, patches={0x0308E2: b"\\x56\\x10\\xbf"})

A cart can also be *played* rather than read. That is a second worker with a
second core -- one built for video and sound cannot be one built for neither,
and there is one core per process -- and it is what "test this level" is:

    from shiny_mushroom.emu import PlaySupervisor
    from shiny_mushroom.play_request import Buttons

    with PlaySupervisor(rom) as play:
        play.enter_level(0x105, patches={0x0308E2: b"\\x56\\x10\\xbf"})
        header, pixels = play.pump(buttons=Buttons.RIGHT)
"""

from __future__ import annotations

from shiny_mushroom.emu.core import EmulatorUnavailable
from shiny_mushroom.emu.loading import LevelLoadError
from shiny_mushroom.emu.supervisor import (
    EmulatorError,
    EmulatorSupervisor,
    PlaySupervisor,
)

__all__ = [
    "EmulatorError",
    "EmulatorSupervisor",
    "EmulatorUnavailable",
    "LevelLoadError",
    "PlaySupervisor",
]
