"""What a test run is asked for, and the pad that drives it.

The going-in half of :mod:`shiny_mushroom.emu.play`, which is the coming-back
half: the loadout a level is entered with, the two other things a run decides,
and the SNES pad as bits. All plain data -- nothing here starts a game, and the
one function that turns a :class:`Buttons` value into the structure Mesen's
input override takes stays beside the core, because that structure is the
core's.

Outside :mod:`shiny_mushroom.emu` for :mod:`shiny_mushroom.level_snapshot`'s
reason: importing anything in that package loads the ctypes binding, and the
window that reads a keyboard and offers a power-up menu must not pay for a core
to name a pad and a loadout.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import IntFlag

#: What a new save file starts with, from ``!Define_SMW_Counter_StartingLives``.
#: Five lives, expressed the way the counter expresses them -- one less than the
#: number on the status bar, which is how ``$7E0DBE`` stores it.
STARTING_LIVES = 0x04


class Buttons(IntFlag):
    """A SNES pad, in the order it shifts its buttons out.

    Not an arbitrary numbering: this is the sequence the controller's shift
    register produces, so a bit position here is the bit position on the wire.
    """

    NONE = 0
    B = 1 << 0
    Y = 1 << 1
    SELECT = 1 << 2
    START = 1 << 3
    UP = 1 << 4
    DOWN = 1 << 5
    LEFT = 1 << 6
    RIGHT = 1 << 7
    A = 1 << 8
    X = 1 << 9
    L = 1 << 10
    R = 1 << 11


@dataclass(frozen=True)
class PlayerState:
    """The loadout the level is entered with.

    A level being tested is not being played through a save file, so none of
    this can come from one. The defaults are a new game's: five lives, small
    Mario, nothing in the box.
    """

    #: 0 small, 1 big, 2 cape, 3 fire.
    powerup: int = 0

    #: As the status bar shows it, not as the counter stores it -- the
    #: conversion is :mod:`shiny_mushroom.emu.play`'s problem, not the
    #: caller's.
    lives: int = STARTING_LIVES + 1

    coins: int = 0

    #: A sprite number for the reserve box, or 0 for empty.
    item_box: int = 0

    #: A Yoshi colour to arrive riding, or 0 for none.
    yoshi: int = 0


@dataclass(frozen=True)
class PlayOptions:
    """Everything about a test run that is not the level number itself."""

    player: PlayerState = PlayerState()

    #: Load the level, or the doorway room the player would walk in through.
    #: A quarter of the cart's levels have one, and testing a level almost
    #: always means the level -- so this is off, and the loader's
    #: no-entrance-room bit is set for the run.
    entrance_room: bool = False
