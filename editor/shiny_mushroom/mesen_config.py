"""Reading a MesenCE configuration for the bindings in it.

MesenCE keeps everything it knows in one ``settings.json`` beside its home
folder, and the editor reads exactly one thing out of it: what holds each SNES
button on controller port 1. Nothing here writes, and nothing here reads the
rest of the file -- video, audio, shortcuts and the debugger are Mesen's
business, and the editor's test window has no equivalent to set from them.

**Only the input half is imported, and only port 1's.** The window drives one
player; a two-player configuration's port 2 is read past rather than merged
into it, which would make both players' keys press the same pad.

Mesen keeps four mapping sets per port and fires a button when any of them
says so -- that is how one configuration carries a keyboard and a gamepad at
once. They are unioned here in order, so an imported button lists its keyboard
key first and its pad button after it, which is also the order Mesen's own
dialog shows them in.

The codes are :mod:`shiny_mushroom.mesen_keys`' and are taken as they stand:
an import is a read, not a conversion. What that costs is in that module --
a pad code means something different on each operating system, and the file
does not say which one wrote it.
"""

from __future__ import annotations

import json
import os
import sys
from collections.abc import Iterator, Mapping
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom.pad_bindings import Bindings
from shiny_mushroom.play_request import Buttons

#: What the file is called, wherever it lives.
SETTINGS_NAME = "settings.json"

#: Mesen's own name for each button, and the pad bit it means. Mesen's field
#: names, not ours: this is the file's spelling and the mapping between the two
#: numberings is exactly this table.
#:
#: ``U`` and ``D``, which the file also carries, are the WonderSwan's second
#: d-pad and not a SNES button at all.
FIELDS: tuple[tuple[str, Buttons], ...] = (
    ("Up", Buttons.UP),
    ("Down", Buttons.DOWN),
    ("Left", Buttons.LEFT),
    ("Right", Buttons.RIGHT),
    ("Y", Buttons.Y),
    ("X", Buttons.X),
    ("B", Buttons.B),
    ("A", Buttons.A),
    ("L", Buttons.L),
    ("R", Buttons.R),
    ("Select", Buttons.SELECT),
    ("Start", Buttons.START),
)

#: The four mapping sets a port has, in the order Mesen tries them.
MAPPINGS = ("Mapping1", "Mapping2", "Mapping3", "Mapping4")

#: The controller types whose bindings mean what this module reads them as. A
#: port set to a mouse or a Super Scope has a mapping block all the same, and
#: importing it would bind the pad to whatever that peripheral's buttons happen
#: to be called.
PAD_TYPES = frozenset({"SnesController", "SnesRumbleController"})

#: What a file chooser offers. Mesen's configuration is always this one name,
#: so the specific filter is the useful one and "all files" is the escape.
FILTER = "Mesen configuration (settings.json);;JSON (*.json);;All files (*)"


class MesenConfigError(Exception):
    """A file that is not a MesenCE configuration, or not a readable one."""


@dataclass(frozen=True)
class MesenInput:
    """What one import found."""

    #: Where it was read from.
    path: Path

    #: Port 1's bindings, the four mapping sets unioned.
    bindings: Bindings

    #: What port 1 is set to. Kept even when it is not a pad, because the
    #: import says so rather than refusing: somebody with a Super Scope
    #: configured still has a keyboard bound underneath it.
    controller: str

    #: ``Input.ControllerDeadzoneSize`` turned into the multiplier Mesen
    #: applies -- :mod:`shiny_mushroom.pads` needs the same number to decide
    #: when a stick counts as pushed.
    deadzone: float

    @property
    def is_pad(self) -> bool:
        """Whether port 1 is a controller rather than a peripheral."""
        return self.controller in PAD_TYPES


#: ``EmuSettings::GetControllerDeadzoneRatio``: the deadzone is a five-step
#: slider in the file rather than a number, and this is what each step means.
DEADZONE_STEPS: Mapping[int, float] = {0: 0.5, 1: 0.75, 2: 1.0, 3: 1.25, 4: 1.5}

#: The middle step, which is Mesen's default and what anything unreadable
#: falls back to.
DEFAULT_STEP = 2
DEFAULT_DEADZONE = DEADZONE_STEPS[DEFAULT_STEP]


def deadzone_ratio(step: int) -> float:
    """What one slider step multiplies a stick's deadzone by."""
    return DEADZONE_STEPS.get(step, DEFAULT_DEADZONE)


def deadzone_step(ratio: float) -> int:
    """Which step a multiplier came from -- :func:`deadzone_ratio` backwards,
    so a preference can be stored as the number the file uses."""
    for step, value in DEADZONE_STEPS.items():
        if value == ratio:
            return step
    return DEFAULT_STEP


def read(path: Path) -> MesenInput:
    """Read ``path`` for port 1's bindings.

    Raises :class:`MesenConfigError` for anything that is not a configuration
    with a SNES port in it -- including a valid JSON document that simply is
    not one, because "imported nothing" and "imported a file with no bindings"
    look identical afterwards and only one of them is worth saying.
    """
    try:
        # utf-8-sig: Mesen's serializer writes a byte order mark, and the plain
        # utf-8 codec keeps it as a character in the first key's name.
        text = path.read_text(encoding="utf-8-sig")
    except OSError as error:
        raise MesenConfigError(f"{path} could not be read: {error}") from error
    try:
        document = json.loads(text)
    except ValueError as error:
        raise MesenConfigError(f"{path} is not valid JSON: {error}") from error
    if not isinstance(document, dict):
        raise MesenConfigError(f"{path} is not a Mesen configuration.")

    port = (
        document.get("Snes", {}).get("Port1")
        if isinstance(document.get("Snes"), dict)
        else None
    )
    if not isinstance(port, dict):
        raise MesenConfigError(
            f"{path} has no SNES controller settings in it. "
            "A Mesen configuration that has never run a SNES game may not yet."
        )

    codes: dict[Buttons, tuple[int, ...]] = {}
    for field, button in FIELDS:
        codes[button] = tuple(_bound(port, field))
    if not any(codes.values()):
        raise MesenConfigError(f"{path} binds nothing on SNES port 1.")

    return MesenInput(
        path=path,
        bindings=Bindings(codes),
        controller=str(port.get("Type", "")),
        deadzone=_deadzone(document.get("Input")),
    )


def _bound(port: dict, field: str) -> Iterator[int]:
    """Every code bound to ``field`` across the port's four mapping sets."""
    seen: set[int] = set()
    for name in MAPPINGS:
        mapping = port.get(name)
        if not isinstance(mapping, dict):
            continue
        code = mapping.get(field)
        # Mesen writes 0 for unbound, and a bool is an int in Python -- a
        # hand-edited file with `true` in it must not become key code 1.
        if not isinstance(code, int) or isinstance(code, bool) or code <= 0:
            continue
        if code not in seen:
            seen.add(code)
            yield code


def _deadzone(section: object) -> float:
    if not isinstance(section, dict):
        return DEFAULT_DEADZONE
    size = section.get("ControllerDeadzoneSize")
    if not isinstance(size, int) or isinstance(size, bool):
        return DEFAULT_DEADZONE
    return deadzone_ratio(size)


def known_locations() -> tuple[Path, ...]:
    """Where an installed MesenCE keeps its configuration, most likely first.

    ``ConfigManager.HomeFolder``'s two non-portable answers: its own folder,
    and the ``Mesen2`` one it inherits a configuration from when it finds no
    folder of its own. A portable install keeps ``settings.json`` beside the
    executable instead, which is anywhere at all -- so this is where to *look*
    and not where the file must be, and every caller offers a chooser as well.
    """
    # Documents on Windows, the config directory everywhere else -- .NET's
    # SpecialFolder.ApplicationData, which is XDG_CONFIG_HOME or ~/.config on
    # both Linux and macOS.
    if sys.platform == "win32":
        base = Path.home() / "Documents"
    else:
        base = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    return tuple(base / folder / SETTINGS_NAME for folder in ("MesenCE", "Mesen2"))


def find_settings() -> Path | None:
    """The first configuration :func:`known_locations` actually has, if any."""
    return next((path for path in known_locations() if path.is_file()), None)
