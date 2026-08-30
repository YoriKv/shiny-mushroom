"""Mesen's key codes, and what each one is called.

A Mesen configuration binds a pad button to a ``uint16`` rather than to a key
name, so reading one means knowing that number's alphabet. There are four
blocks in it:

* ``1``-``172`` the keyboard, in the order ``KeyDefinitions.h`` lists it --
  Windows' virtual-key order, which is where Mesen took it from, and the same
  on all three platforms.
* ``0x200``-``0x204`` the mouse buttons.
* ``0x1000`` and up a gamepad, ``0x1000 + port * 0x100 + index``.
* ``0x2000`` and up a DirectInput stick, Windows only.

**A pad code means something different on each operating system.** The index in
it is the key manager's, and each platform's key manager builds its own list --
Windows from XInput's button order, Linux from libevdev's, macOS from
GameController's. Mesen writes no note of which one produced a configuration,
so a code above ``0x1000`` can only be read as the *running* platform's, which
is what :func:`pad_buttons` returns and what :func:`key_name` names it as. A
configuration carried from another platform imports its keyboard faithfully and
its pad approximately; nothing here can do better, because the file does not
say.

Zero is Mesen's "nothing bound". It is not in :data:`KEY_NAMES`: an unbound
button is an absence, and naming it invites it to be stored as a binding.

**These numbers are a contract with somebody else's file, and nothing checks
them at runtime.** They are positions in Mesen's own tables, as of MesenCE
2.2.1 -- ``Core/Shared/KeyDefinitions.h`` for the keyboard and the mouse, and
the three key managers under ``Windows/``, ``Linux/`` and ``MacOS/`` for the
pads. :mod:`shiny_mushroom.memtype`'s trick is not available here: the core
only builds a key manager for a real window handle, so there is nothing to ask.
A revision that renumbered a key would bind the wrong one on import and say
nothing, which is what a pin move has to re-read these tables for. Nothing
*else* would break: the bindings the editor stores are self-consistent, since
:mod:`shiny_mushroom.ui.qt_keys` and :mod:`shiny_mushroom.pads` both read them
from here.
"""

from __future__ import annotations

import sys

#: The first gamepad code. Mesen's ``IKeyManager::BaseGamepadIndex``.
GAMEPAD_BASE = 0x1000

#: The first DirectInput code, and so one past the last gamepad one.
#: ``WindowsKeyManager::BaseDirectInputIndex``.
DIRECTINPUT_BASE = 0x2000

#: How far apart two devices' codes are, so a device has 256 of them and the
#: device is ``(code - base) // 0x100``.
DEVICE_STRIDE = 0x100

#: Keyboard codes to the name Mesen's own interface shows for each.
KEY_NAMES: dict[int, str] = {
    1: "Cancel",
    2: "Backspace",
    3: "Tab",
    4: "Line Feed",
    5: "Clear",
    6: "Enter",
    7: "Pause",
    8: "Caps Lock",
    9: "Kana Mode",
    10: "Junja Mode",
    11: "Final Mode",
    12: "Kanji Mode",
    13: "Esc",
    14: "IME convert",
    15: "IME nonconvert",
    16: "IME accept",
    17: "IME mode change request",
    18: "Space",
    19: "Page Up",
    20: "Page Down",
    21: "End",
    22: "Home",
    23: "Left Arrow",
    24: "Up Arrow",
    25: "Right Arrow",
    26: "Down Arrow",
    27: "Select",
    28: "Print",
    29: "Execute",
    30: "Print Screen",
    31: "Insert",
    32: "Delete",
    33: "Help",
    34: "0",
    35: "1",
    36: "2",
    37: "3",
    38: "4",
    39: "5",
    40: "6",
    41: "7",
    42: "8",
    43: "9",
    44: "A",
    45: "B",
    46: "C",
    47: "D",
    48: "E",
    49: "F",
    50: "G",
    51: "H",
    52: "I",
    53: "J",
    54: "K",
    55: "L",
    56: "M",
    57: "N",
    58: "O",
    59: "P",
    60: "Q",
    61: "R",
    62: "S",
    63: "T",
    64: "U",
    65: "V",
    66: "W",
    67: "X",
    68: "Y",
    69: "Z",
    70: "Left Win",
    71: "Right Win",
    72: "Apps",
    73: "Sleep",
    74: "Numpad 0",
    75: "Numpad 1",
    76: "Numpad 2",
    77: "Numpad 3",
    78: "Numpad 4",
    79: "Numpad 5",
    80: "Numpad 6",
    81: "Numpad 7",
    82: "Numpad 8",
    83: "Numpad 9",
    84: "Numpad *",
    85: "Numpad +",
    86: "Separator",
    87: "Numpad -",
    88: "Numpad .",
    89: "Numpad /",
    90: "F1",
    91: "F2",
    92: "F3",
    93: "F4",
    94: "F5",
    95: "F6",
    96: "F7",
    97: "F8",
    98: "F9",
    99: "F10",
    100: "F11",
    101: "F12",
    102: "F13",
    103: "F14",
    104: "F15",
    105: "F16",
    106: "F17",
    107: "F18",
    108: "F19",
    109: "F20",
    110: "F21",
    111: "F22",
    112: "F23",
    113: "F24",
    114: "Num Lock",
    115: "Scroll Lock",
    116: "Left Shift",
    117: "Right Shift",
    118: "Left Ctrl",
    119: "Right Ctrl",
    120: "Left Alt",
    121: "Right Alt",
    122: "Browser Back",
    123: "Browser Forward",
    124: "Browser Refresh",
    125: "Browser Stop",
    126: "Browser Search",
    127: "Browser Favorites",
    128: "Browser Home",
    129: "Volume Mute",
    130: "Volume Down",
    131: "Volume Up",
    132: "Next Track",
    133: "Previous Track",
    134: "Stop",
    135: "Play/Pause",
    136: "Start Mail",
    137: "Select Media",
    138: "Start Application 1",
    139: "Start Application 2",
    140: ";",
    141: "=",
    142: ",",
    143: "-",
    144: ".",
    145: "/",
    146: "`",
    147: "AbntC1",
    148: "AbntC2",
    149: "[",
    150: "\\",
    151: "]",
    152: "'",
    153: "Oem8",
    154: "|",
    155: "IME Processed",
    156: "System",
    157: "OemAttn",
    158: "OemFinish",
    159: "DbeHiragana",
    160: "DbeSbcsChar",
    161: "DbeDbcsChar",
    162: "OemBackTab",
    163: "DbeNoRoman",
    164: "CrSel",
    165: "ExSel",
    166: "EraseEof",
    167: "Play",
    168: "DbeNoCodeInput",
    169: "NoName",
    170: "DbeEnterDialogConversionMode",
    171: "OemClear",
    172: "DeadCharProcessed",
}

#: Mouse buttons, in the same numbering.
MOUSE_NAMES: dict[int, str] = {
    512: "Mouse Left",
    513: "Mouse Right",
    514: "Mouse Middle",
    515: "Mouse 4",
    516: "Mouse 5",
}

#: XInput's buttons in bit order, which is what a Windows configuration's pad
#: codes index -- **one-based**: Mesen numbers this list from 1, so that a
#: cleared binding (0) cannot read as the first button. The two ``?`` are the
#: two unassigned bits of ``XINPUT_GAMEPAD``'s button word; the entries past
#: ``R2`` are stick directions rather than buttons, and the last four are the
#: axes themselves, which a pad binding never names.
XINPUT_BUTTONS: tuple[str, ...] = (
    "Up",
    "Down",
    "Left",
    "Right",
    "Start",
    "Back",
    "L3",
    "R3",
    "L1",
    "R1",
    "?",
    "?",
    "A",
    "B",
    "X",
    "Y",
    "L2",
    "R2",
    "RT Up",
    "RT Down",
    "RT Left",
    "RT Right",
    "LT Up",
    "LT Down",
    "LT Left",
    "LT Right",
    "LT Y",
    "LT X",
    "RT Y",
    "RT X",
)

#: A DirectInput stick's names, zero-based from :data:`DIRECTINPUT_BASE`, with
#: the 128 numbered buttons Mesen appends after them. Its six axes are left out:
#: Mesen puts them at ``+ 0x110``, past the stride, where they collide with the
#: next stick's buttons -- so a code there is ambiguous in Mesen itself, and
#: naming it either way would be inventing an answer the file does not have.
DIRECTINPUT_BUTTONS: tuple[str, ...] = (
    "Y+",
    "Y-",
    "X-",
    "X+",
    "Y2+",
    "Y2-",
    "X2-",
    "X2+",
    "Z+",
    "Z-",
    "Z2+",
    "Z2-",
    "DPad Up",
    "DPad Down",
    "DPad Right",
    "DPad Left",
) + tuple(f"But{n}" for n in range(1, 129))

#: libevdev's order, which is what a Linux configuration's pad codes index,
#: zero-based.
LINUX_BUTTONS: tuple[str, ...] = (
    "A",
    "B",
    "C",
    "X",
    "Y",
    "Z",
    "L1",
    "R1",
    "L2",
    "R2",
    "Select",
    "Start",
    "L3",
    "R3",
    "X+",
    "X-",
    "Y+",
    "Y-",
    "Z+",
    "Z-",
    "X2+",
    "X2-",
    "Y2+",
    "Y2-",
    "Z2+",
    "Z2-",
    "Right",
    "Left",
    "Down",
    "Up",
    "Right 2",
    "Left 2",
    "Down 2",
    "Up 2",
    "Right 3",
    "Left 3",
    "Down 3",
    "Up 3",
    "Right 4",
    "Left 4",
    "Down 4",
    "Up 4",
    "Trigger",
    "Thumb",
    "Thumb2",
    "Top",
    "Top2",
    "Pinkie",
    "Base",
    "Base2",
    "Base3",
    "Base4",
    "Base5",
    "Base6",
    "Dead",
    "Y",
    "X",
    "Y2",
    "X2",
    "Z",
    "Z2",
)

#: GameController's order, which is what a macOS configuration's pad codes
#: index, zero-based.
MACOS_BUTTONS: tuple[str, ...] = (
    "A",
    "B",
    "X",
    "Y",
    "L1",
    "R1",
    "Start",
    "Select",
    "Up",
    "Down",
    "Left",
    "Right",
    "L2",
    "R2",
    "L3",
    "R3",
    "X+",
    "X-",
    "Y+",
    "Y-",
    "X2+",
    "X2-",
    "Y2+",
    "Y2-",
    "X",
    "Y",
    "X2",
    "Y2",
)


def pad_buttons() -> tuple[str, ...]:
    """The button names this platform's pad codes index.

    Named for the platform the editor is *running* on rather than the one the
    configuration came from, because a code is only ever read against the pad
    in front of the person -- see the module docstring.
    """
    if sys.platform == "win32":
        return XINPUT_BUTTONS
    if sys.platform == "darwin":
        return MACOS_BUTTONS
    return LINUX_BUTTONS


def pad_code(port: int, index: int) -> int:
    """The code for one button of one pad. The inverse of :func:`pad_button`."""
    return GAMEPAD_BASE + port * DEVICE_STRIDE + index


def pad_button(code: int) -> tuple[int, int] | None:
    """Which pad and which of its buttons ``code`` names, or ``None``.

    ``None`` for everything that is not a gamepad code, DirectInput included:
    the editor has no way to read a DirectInput stick, so a binding to one is
    an imported binding that will not fire rather than one it can resolve.
    """
    if not GAMEPAD_BASE <= code < DIRECTINPUT_BASE:
        return None
    offset = code - GAMEPAD_BASE
    return offset // DEVICE_STRIDE, offset % DEVICE_STRIDE


def is_pad(code: int) -> bool:
    """Whether ``code`` is a pad or stick rather than a key or a mouse button."""
    return code >= GAMEPAD_BASE


def key_name(code: int) -> str:
    """What to call ``code`` on screen.

    Every code gets a name, including one nothing in the tables above claims:
    an imported configuration is somebody else's file, and a binding shown as
    ``Key 4242`` says what is in it, where a blank would say the import lost it.
    """
    if code in KEY_NAMES:
        return KEY_NAMES[code]
    if code in MOUSE_NAMES:
        return MOUSE_NAMES[code]
    if code >= DIRECTINPUT_BASE:
        return _device_name("Joy", code - DIRECTINPUT_BASE, DIRECTINPUT_BUTTONS, 0)
    if code >= GAMEPAD_BASE:
        buttons = pad_buttons()
        # XInput's list is numbered from 1 and the other two from 0. The shift
        # is the key manager's, not the pad's, so it belongs here beside the
        # tables rather than in whatever is reading a controller.
        first = 1 if buttons is XINPUT_BUTTONS else 0
        return _device_name("Pad", code - GAMEPAD_BASE, buttons, first)
    return f"Key {code}"


def _device_name(kind: str, offset: int, buttons: tuple[str, ...], first: int) -> str:
    """``Pad2 Start`` and the like, or the raw code when the index has no name."""
    device, index = divmod(offset, DEVICE_STRIDE)
    if not first <= index < first + len(buttons):
        return f"{kind}{device + 1} #{index}"
    return f"{kind}{device + 1} {buttons[index - first]}"
