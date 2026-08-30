"""What holds each SNES button, and the set the editor ships with.

A binding is a :class:`~shiny_mushroom.play_request.Buttons` member and the
Mesen key codes that hold it -- codes rather than Qt keys, because the pad is
driven from two places at once. The keyboard arrives as Qt key events and a
gamepad as raw device state, and translating both into
:mod:`shiny_mushroom.mesen_keys`' numbering up front is what lets one binding
set answer for both. It is also the numbering an imported MesenCE configuration
is written in, so an import is a read rather than a conversion.

**A button has a list of codes, not one.** Mesen keeps four mapping sets per
port and fires a button when any of them says so; both Enters are Start here
for the same reason, and either Shift is Select. So the question a binding set
answers is not "which key is Start" but "is any of Start's keys down", which is
:meth:`Bindings.held` and the only arithmetic in the module.

Qt-free, and outside :mod:`shiny_mushroom.ui` on purpose: this is the same data
whether it came from a keyboard, a gamepad or a file, and the two modules that
turn a real device into codes -- :mod:`shiny_mushroom.ui.qt_keys` and
:mod:`shiny_mushroom.pads` -- each depend on it rather than the other way
about.
"""

from __future__ import annotations

import json
from collections.abc import Container, Iterable, Mapping
from dataclasses import dataclass

from shiny_mushroom.play_request import Buttons

#: The twelve buttons, in the order a person reads a controller: the pad, the
#: four face buttons in their diamond, the shoulders, then the two in the
#: middle. Not :class:`Buttons`' own order, which is the shift register's --
#: right for the wire and wrong for a list somebody is looking at.
BUTTON_ORDER: tuple[Buttons, ...] = (
    Buttons.UP,
    Buttons.DOWN,
    Buttons.LEFT,
    Buttons.RIGHT,
    Buttons.Y,
    Buttons.X,
    Buttons.B,
    Buttons.A,
    Buttons.L,
    Buttons.R,
    Buttons.SELECT,
    Buttons.START,
)


@dataclass(frozen=True)
class Bindings:
    """Which codes hold which buttons.

    A button missing from :attr:`codes`, or holding an empty tuple, is a button
    nothing can press -- which is a legitimate answer and what an imported
    configuration that left one unbound means.
    """

    codes: Mapping[Buttons, tuple[int, ...]]

    def __post_init__(self) -> None:
        # Normalised on the way in rather than trusted: the two callers that
        # build one are a JSON document and a parsed Mesen file, so "a list of
        # ints, in order, no duplicates, no zeroes" is a property this has to
        # establish rather than one it can assume. Zero is Mesen's "unbound"
        # and would otherwise be a code that matches nothing forever.
        object.__setattr__(
            self,
            "codes",
            {
                button: tuple(dict.fromkeys(int(c) for c in bound if int(c)))
                for button, bound in self.codes.items()
                if button in BUTTON_ORDER
            },
        )

    def for_button(self, button: Buttons) -> tuple[int, ...]:
        """The codes that hold ``button``, in the order they were bound."""
        return self.codes.get(button, ())

    def held(self, down: Container[int]) -> Buttons:
        """Everything ``down`` is holding.

        Recomputed from what is down rather than accumulated as keys go up and
        down, which is what makes two keys on one button work: releasing one of
        Start's two Enters while the other is held must not release Start, and
        an incremental fold cannot tell the difference.
        """
        held = Buttons.NONE
        for button, bound in self.codes.items():
            if any(code in down for code in bound):
                held |= button
        return held

    def bound_codes(self) -> frozenset[int]:
        """Every code this set has a use for.

        What a keyboard handler asks before deciding a key is not its business:
        an unbound key has to fall through to Qt, or the window swallows every
        shortcut in it.
        """
        return frozenset(code for bound in self.codes.values() for code in bound)

    def replace(self, button: Buttons, codes: Iterable[int]) -> Bindings:
        """This set with ``button`` bound to ``codes`` instead."""
        return Bindings({**self.codes, button: tuple(codes)})

    def to_json(self) -> str:
        """The form the preference store keeps, keyed by button name.

        By name rather than by the bit, so that reading a stored preference
        does not depend on :class:`Buttons`' numbering staying put, and so that
        somebody looking at the config file can see what it says.
        """
        return json.dumps(
            {button.name: list(self.for_button(button)) for button in BUTTON_ORDER},
            separators=(",", ":"),
        )

    @classmethod
    def from_json(cls, text: str) -> Bindings | None:
        """Read :meth:`to_json` back, or ``None`` if it is not that.

        ``None`` rather than an exception for the reason every accessor in
        :mod:`shiny_mushroom.ui.settings` falls back: a hand-edited config, or
        one written by a newer build, must not stop the editor from starting.
        """
        try:
            stored = json.loads(text)
        except (TypeError, ValueError):
            return None
        if not isinstance(stored, dict):
            return None
        codes: dict[Buttons, tuple[int, ...]] = {}
        for button in BUTTON_ORDER:
            bound = stored.get(button.name)
            if bound is None:
                continue
            # A button that is there but is not a list of codes means this is
            # not the document it looks like, and half-reading one is worse
            # than falling back: the buttons that did parse would stand beside
            # the shipped defaults for the ones that did not, which is an
            # arrangement nobody chose.
            if not isinstance(bound, list) or not all(
                isinstance(code, int) and not isinstance(code, bool) for code in bound
            ):
                return None
            codes[button] = tuple(bound)
        return cls(codes) if codes else None


#: The layout every SNES emulator has shipped with for twenty years, so a
#: player's hands already know it: Z and X are the keys nearest the left hand
#: and get the two buttons Mario uses constantly -- Y to run and spin, B to
#: jump. Close to Mesen's own "Arrow keys" preset and deliberately not identical
#: to it: that preset puts B on A and X on X, and Start and Select on D and E.
#:
#: Both Enters are Start, because the keypad's is a different key from the main
#: one and somebody who reaches for it should not find the game ignoring them;
#: both Shifts are Select for the same reason.
DEFAULT_BINDINGS = Bindings(
    {
        Buttons.UP: (24,),  # Up Arrow
        Buttons.DOWN: (26,),  # Down Arrow
        Buttons.LEFT: (23,),  # Left Arrow
        Buttons.RIGHT: (25,),  # Right Arrow
        Buttons.Y: (69,),  # Z
        Buttons.B: (67,),  # X
        Buttons.X: (44,),  # A
        Buttons.A: (62,),  # S
        Buttons.L: (60,),  # Q
        Buttons.R: (66,),  # W
        Buttons.START: (6,),  # Enter
        Buttons.SELECT: (116, 117),  # Left Shift, Right Shift
    }
)
