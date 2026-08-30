"""Reading the gamepads plugged into this machine, in Mesen's numbering.

The test window drives the emulator itself rather than letting the core read a
keyboard (:mod:`shiny_mushroom.emu.core` builds it with ``noInput``), and the
core's key managers are only ever constructed for a real window, which the
worker has none of. So a gamepad has to be read here, and read the way Mesen
reads one, because the bindings an import brings are Mesen's device indices:
"Pad1 A" is a position in a list that the key manager for *this* operating
system builds, and a reader that numbered its buttons differently would turn
every imported pad binding into a different button.

Two backends, both through :mod:`ctypes` and the standard library:

* **Windows** -- XInput, the same API ``WindowsKeyManager`` uses, so the codes
  line up by construction. A DirectInput-only stick is not read; Mesen puts
  those at ``0x2000`` and up, and a binding to one is imported and inert.
* **Linux** -- the evdev character devices, the same ones ``libevdev`` reads
  for Mesen, in the same ``/dev/input/eventN`` order, so "Pad1" is the same pad
  in both. State is asked of the kernel each poll (``EVIOCGKEY``,
  ``EVIOCGABS``) rather than accumulated from the event stream: there is no
  queue to fall behind, and a poll that is skipped costs nothing.
* **macOS** -- none. The framework Mesen uses there, GameController, is
  Objective-C and out of reach from :mod:`ctypes`. Bindings are imported and
  said to be unread rather than silently doing nothing.

**Polling, not listening.** :meth:`PadReader.poll` is called from the window's
timer while a test run is on screen and at no other time -- a reader is opened
when the run starts and closed when it stops, so nothing here runs, or holds a
device open, while somebody is editing.
"""

from __future__ import annotations

import ctypes
import os
import sys
import time
from pathlib import Path
from typing import Protocol

try:
    import fcntl
except ImportError:  # pragma: no cover -- Windows, where the backend is XInput
    fcntl = None  # type: ignore[assignment]

from shiny_mushroom.mesen_keys import pad_code

#: How many pads Mesen numbers. XInput has four; the evdev backend takes the
#: first four it finds, which is what ``LinuxKeyManager`` does with the first
#: twenty. Four is what a SNES multitap could carry and more than the editor's
#: one-player window can use.
MAX_PADS = 4


class PadReader(Protocol):
    """A source of held Mesen pad codes."""

    def poll(self) -> frozenset[int]:
        """Every pad code held right now."""

    def describe(self) -> str:
        """One line for a dialog: what is being read, or why nothing is."""

    def close(self) -> None:
        """Let the devices go."""


class NoPads:
    """The reader for a platform with no backend, and for a machine with no pad.

    A real object rather than ``None`` so that every caller has the same shape
    to talk to; what it knows is why it is empty, which is the one thing a
    dialog wants to say.
    """

    def __init__(self, reason: str) -> None:
        self._reason = reason

    def poll(self) -> frozenset[int]:
        return frozenset()

    def describe(self) -> str:
        return self._reason

    def close(self) -> None:
        return


# -- Windows -----------------------------------------------------------------

#: The XInput libraries, newest first. 1.4 ships with Windows 8 and later, 1.3
#: with the DirectX redistributable, and 9.1.0 with every Windows since Vista
#: -- so the last one is the floor rather than a preference.
XINPUT_LIBRARIES = ("xinput1_4", "xinput1_3", "xinput9_1_0")

#: ``ERROR_DEVICE_NOT_CONNECTED``. Asking an empty slot costs far more than
#: asking a full one, which is why a slot that answers this is not asked again
#: until :data:`RESCAN_SECONDS` have passed.
_NOT_CONNECTED = 1167

#: How long a slot stays written off. Long enough that polling four empty slots
#: is free, short enough that plugging a pad in mid-run is noticed.
RESCAN_SECONDS = 2.0

#: ``XINPUT_GAMEPAD_TRIGGER_THRESHOLD`` and the two thumbstick deadzones, from
#: ``XInput.h``. Mesen scales all three by twice the configured deadzone ratio.
_TRIGGER_THRESHOLD = 30
_LEFT_THUMB_DEADZONE = 7849
_RIGHT_THUMB_DEADZONE = 8689


class PadGamepad(ctypes.Structure):
    """``XINPUT_GAMEPAD``, which is the whole of what a slot reports."""

    _fields_ = [
        ("wButtons", ctypes.c_ushort),
        ("bLeftTrigger", ctypes.c_ubyte),
        ("bRightTrigger", ctypes.c_ubyte),
        ("sThumbLX", ctypes.c_short),
        ("sThumbLY", ctypes.c_short),
        ("sThumbRX", ctypes.c_short),
        ("sThumbRY", ctypes.c_short),
    ]


class _XInputState(ctypes.Structure):
    _fields_ = [("dwPacketNumber", ctypes.c_ulong), ("Gamepad", PadGamepad)]


class XInputPads:
    """The four XInput slots, read as ``WindowsKeyManager`` reads them.

    Mesen numbers a slot's buttons from **one**, in ``XINPUT_GAMEPAD``'s bit
    order, so button *n* is bit *n - 1* and code 0 stays free to mean unbound.
    Past the sixteen bits come the two triggers and the eight stick directions,
    each with the same threshold Mesen applies -- a binding to "Pad1 LT Left"
    has to start pressing where it would in Mesen or the stick feels wrong.
    """

    def __init__(self, library: ctypes.WinDLL, deadzone: float) -> None:
        self._get_state = library.XInputGetState
        self._get_state.argtypes = [ctypes.c_ulong, ctypes.POINTER(_XInputState)]
        self._get_state.restype = ctypes.c_ulong
        self._deadzone = deadzone
        self._state = _XInputState()
        #: When each empty slot may be asked again. Zero means "now".
        self._retry_at = [0.0] * MAX_PADS
        self._connected = 0

    def poll(self) -> frozenset[int]:
        now = time.monotonic()
        held: set[int] = set()
        connected = 0
        for port in range(MAX_PADS):
            if self._retry_at[port] > now:
                continue
            if self._get_state(port, ctypes.byref(self._state)) != 0:
                self._retry_at[port] = now + RESCAN_SECONDS
                continue
            connected += 1
            held.update(self._buttons(port, self._state.Gamepad))
        self._connected = connected
        return frozenset(held)

    def _buttons(self, port: int, pad: PadGamepad) -> list[int]:
        ratio = self._deadzone * 2
        pressed = [
            pad_code(port, bit + 1) for bit in range(16) if pad.wButtons & (1 << bit)
        ]
        left, right = _LEFT_THUMB_DEADZONE * ratio, _RIGHT_THUMB_DEADZONE * ratio
        # Index by index as WindowsKeyManager numbers them: 17 and 18 the
        # triggers, then the right stick's four directions and the left's.
        for index, held in (
            (17, pad.bLeftTrigger > _TRIGGER_THRESHOLD * ratio),
            (18, pad.bRightTrigger > _TRIGGER_THRESHOLD * ratio),
            (19, pad.sThumbRY > right),
            (20, pad.sThumbRY < -right),
            (21, pad.sThumbRX < -right),
            (22, pad.sThumbRX > right),
            (23, pad.sThumbLY > left),
            (24, pad.sThumbLY < -left),
            (25, pad.sThumbLX < -left),
            (26, pad.sThumbLX > left),
        ):
            if held:
                pressed.append(pad_code(port, index))
        return pressed

    def describe(self) -> str:
        if not self._connected:
            return "No controller found. XInput reports every slot empty."
        return f"{self._connected} controller(s) on XInput."

    def close(self) -> None:
        return


# -- Linux -------------------------------------------------------------------

_EV_KEY = 0x01
_EV_ABS = 0x03

_KEY_BYTES = 0x300 // 8
_ABS_BYTES = 0x40 // 8

_ABS_X, _ABS_Y, _ABS_Z = 0x00, 0x01, 0x02
_ABS_RX, _ABS_RY, _ABS_RZ = 0x03, 0x04, 0x05
_ABS_HAT0X, _ABS_HAT0Y = 0x10, 0x11
_ABS_HAT1X, _ABS_HAT1Y = 0x12, 0x13
_ABS_HAT2X, _ABS_HAT2Y = 0x14, 0x15
_ABS_HAT3X, _ABS_HAT3Y = 0x16, 0x17

_BTN_TRIGGER, _BTN_THUMB, _BTN_THUMB2 = 0x120, 0x121, 0x122
_BTN_TOP, _BTN_TOP2, _BTN_PINKIE = 0x123, 0x124, 0x125
_BTN_BASE, _BTN_BASE2, _BTN_BASE3 = 0x126, 0x127, 0x128
_BTN_BASE4, _BTN_BASE5, _BTN_BASE6 = 0x129, 0x12A, 0x12B
_BTN_DEAD = 0x12F
_BTN_A, _BTN_B, _BTN_C = 0x130, 0x131, 0x132
_BTN_X, _BTN_Y, _BTN_Z = 0x133, 0x134, 0x135
_BTN_TL, _BTN_TR, _BTN_TL2, _BTN_TR2 = 0x136, 0x137, 0x138, 0x139
_BTN_SELECT, _BTN_START = 0x13A, 0x13B
_BTN_THUMBL, _BTN_THUMBR = 0x13D, 0x13E
_BTN_DPAD_UP, _BTN_DPAD_DOWN = 0x220, 0x221
_BTN_DPAD_LEFT, _BTN_DPAD_RIGHT = 0x222, 0x223

#: ``LinuxGameController::IsButtonPressed``, its evdev half: Mesen's index to
#: the buttons that press it. Indices 26-29 are the d-pad, which most pads
#: report as a hat axis and a PS3 pad as these buttons, so both are checked --
#: exactly as Mesen does.
_LINUX_KEYS: dict[int, tuple[int, ...]] = {
    0: (_BTN_A,),
    1: (_BTN_B,),
    2: (_BTN_C,),
    3: (_BTN_X,),
    4: (_BTN_Y,),
    5: (_BTN_Z,),
    6: (_BTN_TL,),
    7: (_BTN_TR,),
    8: (_BTN_TL2,),
    9: (_BTN_TR2,),
    10: (_BTN_SELECT,),
    11: (_BTN_START,),
    12: (_BTN_THUMBL,),
    13: (_BTN_THUMBR,),
    26: (_BTN_DPAD_RIGHT,),
    27: (_BTN_DPAD_LEFT,),
    28: (_BTN_DPAD_DOWN,),
    29: (_BTN_DPAD_UP,),
    42: (_BTN_TRIGGER,),
    43: (_BTN_THUMB,),
    44: (_BTN_THUMB2,),
    45: (_BTN_TOP,),
    46: (_BTN_TOP2,),
    47: (_BTN_PINKIE,),
    48: (_BTN_BASE,),
    49: (_BTN_BASE2,),
    50: (_BTN_BASE3,),
    51: (_BTN_BASE4,),
    52: (_BTN_BASE5,),
    53: (_BTN_BASE6,),
    54: (_BTN_DEAD,),
}

#: The other half: Mesen's index to the axis it watches and which way. A stick
#: is two buttons, one per direction, which is what makes "Pad1 X-" bindable.
_LINUX_AXES: dict[int, tuple[int, bool]] = {
    14: (_ABS_X, True),
    15: (_ABS_X, False),
    16: (_ABS_Y, True),
    17: (_ABS_Y, False),
    18: (_ABS_Z, True),
    19: (_ABS_Z, False),
    20: (_ABS_RX, True),
    21: (_ABS_RX, False),
    22: (_ABS_RY, True),
    23: (_ABS_RY, False),
    24: (_ABS_RZ, True),
    25: (_ABS_RZ, False),
    26: (_ABS_HAT0X, True),
    27: (_ABS_HAT0X, False),
    28: (_ABS_HAT0Y, True),
    29: (_ABS_HAT0Y, False),
    30: (_ABS_HAT1X, True),
    31: (_ABS_HAT1X, False),
    32: (_ABS_HAT1Y, True),
    33: (_ABS_HAT1Y, False),
    34: (_ABS_HAT2X, True),
    35: (_ABS_HAT2X, False),
    36: (_ABS_HAT2Y, True),
    37: (_ABS_HAT2Y, False),
    38: (_ABS_HAT3X, True),
    39: (_ABS_HAT3X, False),
    40: (_ABS_HAT3Y, True),
    41: (_ABS_HAT3Y, False),
}

#: The fraction of an axis' travel Mesen calls the middle, before the
#: configured ratio scales it. ``LinuxGameController::CheckAxis``.
_AXIS_DEADZONE = 0.400


#: ``\'E\'``, the input subsystem's ioctl letter, and the size of one
#: ``struct input_absinfo``.
_IOCTL_INPUT = 0x45
_ABSINFO_BYTES = 24


def _ioctl_read(number: int, size: int) -> int:
    """One of the input subsystem's reading ioctls, in asm-generic's layout.

    ``_IOC(_IOC_READ, \'E\', number, size)`` spelled out, because the numbers
    the kernel headers build with macros have to be built with arithmetic here:
    ``EVIOCGKEY`` is ``0x18``, ``EVIOCGBIT(type)`` is ``0x20 + type`` and
    ``EVIOCGABS(axis)`` is ``0x40 + axis``.
    """
    return (2 << 30) | (size << 16) | (_IOCTL_INPUT << 8) | number


class _EvdevPad:
    """One ``/dev/input/eventN``, asked for its state rather than listened to."""

    def __init__(self, fd: int, axes: dict[int, tuple[int, int, int]]) -> None:
        self._fd = fd
        #: Each usable axis' captured centre, low and high. The centre is read
        #: once, when the device is opened, rather than assumed to be the
        #: midpoint -- which is ``Calibrate()``'s reason: a trigger rests at
        #: its minimum and a worn stick rests wherever it rests.
        self._axes = axes
        self._keys = bytearray(_KEY_BYTES)
        self._info = bytearray(_ABSINFO_BYTES)

    def held(self, port: int, deadzone: float) -> list[int]:
        """Every code this pad holds, as pad number ``port``.

        One ``EVIOCGKEY`` for all of the buttons and one ``EVIOCGABS`` per axis
        the pad actually has -- the state comes from the kernel each time
        rather than from a queue of events, so a poll the window skips while it
        is busy costs a poll rather than a backlog.
        """
        if not self._read(0x18, self._keys):
            # Unplugged mid-run. Everything on it comes up, which is the only
            # safe reading: a held button on a pad that is gone is a button
            # nothing will ever release.
            return []
        values = {axis: self._value(axis) for axis in self._axes}
        pressed = [
            pad_code(port, index)
            for index, buttons in _LINUX_KEYS.items()
            if any(self._keys[b >> 3] & (1 << (b & 7)) for b in buttons)
        ]
        for index, (axis, positive) in _LINUX_AXES.items():
            value = values.get(axis)
            if value is None or not self._past(axis, value, positive, deadzone):
                continue
            code = pad_code(port, index)
            # The d-pad's four indices are reachable both ways -- as a hat axis
            # and as a button -- and Mesen presses them from either.
            if code not in pressed:
                pressed.append(code)
        return pressed

    def _value(self, axis: int) -> int | None:
        if not self._read(0x40 + axis, self._info):
            return None
        return int.from_bytes(self._info[:4], sys.byteorder, signed=True)

    def _past(self, axis: int, value: int, positive: bool, deadzone: float) -> bool:
        """``CheckAxis``: how far from its centre an axis counts as pushed."""
        centre, low, high = self._axes[axis]
        if positive:
            return value - centre > (high - centre) * _AXIS_DEADZONE * deadzone
        return value - centre < -((centre - low) * _AXIS_DEADZONE * deadzone)

    def _read(self, number: int, into: bytearray) -> bool:
        try:
            fcntl.ioctl(self._fd, _ioctl_read(number, len(into)), into, True)
        except OSError:
            return False
        return True

    def close(self) -> None:
        try:
            os.close(self._fd)
        except OSError:
            pass


class EvdevPads:
    """Every gamepad under ``/dev/input``, numbered as Mesen numbers them.

    ``LinuxGameController::GetController`` walks ``event0`` upwards and keeps
    what reports either a gamepad button or an absolute X axis, so the order
    here is that walk's -- which is what makes "Pad1" the same device in the
    editor as in Mesen on the same machine.
    """

    def __init__(self, pads: list[_EvdevPad], deadzone: float) -> None:
        self._pads = pads
        self._deadzone = deadzone

    def poll(self) -> frozenset[int]:
        held: set[int] = set()
        for port, pad in enumerate(self._pads):
            held.update(pad.held(port, self._deadzone))
        return frozenset(held)

    def describe(self) -> str:
        return f"{len(self._pads)} controller(s) under /dev/input."

    def close(self) -> None:
        for pad in self._pads:
            pad.close()
        self._pads = []


def _open_evdev(deadzone: float) -> PadReader:
    pads: list[_EvdevPad] = []
    unreadable = 0
    devices = sorted(
        Path("/dev/input").glob("event*"),
        key=lambda path: int(path.name.removeprefix("event") or 0),
    )
    for device in devices:
        if len(pads) >= MAX_PADS:
            break
        try:
            fd = os.open(device, os.O_RDONLY | os.O_NONBLOCK)
        except OSError:
            # Almost always "not in the input group", which is worth counting
            # so the dialog can say that rather than "no controller".
            unreadable += 1
            continue
        axes = _pad_axes(fd)
        if axes is None:
            os.close(fd)
            continue
        pads.append(_EvdevPad(fd, axes))
    if pads:
        return EvdevPads(pads, deadzone)
    if unreadable:
        return NoPads(
            f"{unreadable} input device(s) could not be opened -- this user is "
            "probably not in the 'input' group."
        )
    return NoPads("No controller found under /dev/input.")


def _pad_axes(fd: int) -> dict[int, tuple[int, int, int]] | None:
    """``None`` unless this device is a gamepad; its calibrated axes if it is.

    The test is ``GetController``'s: a device with a gamepad button on it, or
    one with an absolute X axis, which between them cover a pad whose d-pad is
    buttons and one whose is a hat.
    """
    keys = bytearray(_KEY_BYTES)
    axes_bits = bytearray(_ABS_BYTES)
    try:
        fcntl.ioctl(fd, _ioctl_read(0x20 + _EV_KEY, _KEY_BYTES), keys, True)
        fcntl.ioctl(fd, _ioctl_read(0x20 + _EV_ABS, _ABS_BYTES), axes_bits, True)
    except OSError:
        return None
    has_gamepad_button = bool(keys[_BTN_A >> 3] & (1 << (_BTN_A & 7)))
    has_x_axis = bool(axes_bits[_ABS_X >> 3] & (1 << (_ABS_X & 7)))
    if not (has_gamepad_button or has_x_axis):
        return None

    axes: dict[int, tuple[int, int, int]] = {}
    for axis in {axis for axis, _ in _LINUX_AXES.values()}:
        if not axes_bits[axis >> 3] & (1 << (axis & 7)):
            continue
        info = bytearray(_ABSINFO_BYTES)
        try:
            fcntl.ioctl(fd, _ioctl_read(0x40 + axis, _ABSINFO_BYTES), info, True)
        except OSError:
            continue
        value, low, high = (
            int.from_bytes(info[n : n + 4], sys.byteorder, signed=True)
            for n in (0, 4, 8)
        )
        if high > low:
            axes[axis] = (value, low, high)
    return axes


# -- the choice --------------------------------------------------------------


def open_pads(deadzone: float = 1.0) -> PadReader:
    """A reader for this machine's gamepads. Never raises, never returns None.

    ``deadzone`` is Mesen's ratio -- see
    :attr:`shiny_mushroom.mesen_config.MesenInput.deadzone` -- so a stick
    starts pressing where the imported configuration says it does.
    """
    try:
        if sys.platform == "win32":
            return _open_xinput(deadzone)
        if sys.platform == "darwin":
            return NoPads(
                "Controllers are not read on macOS. Imported controller "
                "bindings are kept, and the keyboard drives the test run."
            )
        return _open_evdev(deadzone)
    except Exception as error:  # noqa: BLE001 - a missing device is not a failure
        # Every backend is somebody else's kernel or DLL, and none of it is
        # worth a window that will not open: a test run with no pad is the
        # ordinary case, and the dialog says what went wrong.
        return NoPads(f"Controllers could not be read: {error}")


def _open_xinput(deadzone: float) -> PadReader:
    for name in XINPUT_LIBRARIES:
        try:
            library = ctypes.WinDLL(name)  # type: ignore[attr-defined]
        except OSError:
            continue
        if hasattr(library, "XInputGetState"):
            return XInputPads(library, deadzone)
    return NoPads("XInput is not available on this machine.")
