"""Qt key events in Mesen's numbering.

The test window binds its pad in :mod:`shiny_mushroom.mesen_keys`' codes,
because that is the numbering an imported MesenCE configuration is written in
and the numbering a gamepad is read into. A keyboard arrives as Qt key codes
instead, so it is translated here, on the way in, and the rest of the window
never sees a ``Qt.Key`` again.

**The translation is one to many.** Qt says "Shift" where Mesen says "Left
Shift" and "Right Shift", so a Shift press holds both codes and a binding to
either fires -- the same for the other three modifiers, which Qt also reports
without a side. And it goes the other way for Return and Enter, which are two
Qt keys and one Mesen code.

Qt reports the keypad with the *main* keyboard's key codes and a
:attr:`~PySide6.QtCore.Qt.KeyboardModifier.KeypadModifier` beside them, where
Mesen numbers the two separately, so :func:`mesen_codes` is told which it was.
"""

from __future__ import annotations

from PySide6.QtCore import Qt

# The letters and the digits are contiguous in both numberings, and the
# function keys nearly so -- built rather than listed, because twenty-six
# hand-written rows are twenty-six chances to transpose two of them.
_LETTERS = {int(Qt.Key.Key_A) + n: (44 + n,) for n in range(26)}
_DIGITS = {int(Qt.Key.Key_0) + n: (34 + n,) for n in range(10)}
_FUNCTION = {int(Qt.Key.Key_F1) + n: (90 + n,) for n in range(24)}

#: Qt key code to the Mesen codes it holds, for the main keyboard.
QT_TO_MESEN: dict[int, tuple[int, ...]] = {
    **_LETTERS,
    **_DIGITS,
    **_FUNCTION,
    int(Qt.Key.Key_Backspace): (2,),
    int(Qt.Key.Key_Tab): (3,),
    int(Qt.Key.Key_Clear): (5,),
    # Both Enters, and one code: Mesen has a single "Enter", and somebody who
    # reaches for the keypad's should not find the game ignoring them.
    int(Qt.Key.Key_Return): (6,),
    int(Qt.Key.Key_Enter): (6,),
    int(Qt.Key.Key_Pause): (7,),
    int(Qt.Key.Key_CapsLock): (8,),
    int(Qt.Key.Key_Escape): (13,),
    int(Qt.Key.Key_Space): (18,),
    int(Qt.Key.Key_PageUp): (19,),
    int(Qt.Key.Key_PageDown): (20,),
    int(Qt.Key.Key_End): (21,),
    int(Qt.Key.Key_Home): (22,),
    int(Qt.Key.Key_Left): (23,),
    int(Qt.Key.Key_Up): (24,),
    int(Qt.Key.Key_Right): (25,),
    int(Qt.Key.Key_Down): (26,),
    int(Qt.Key.Key_Print): (30,),
    int(Qt.Key.Key_Insert): (31,),
    int(Qt.Key.Key_Delete): (32,),
    int(Qt.Key.Key_Help): (33,),
    int(Qt.Key.Key_Menu): (72,),
    int(Qt.Key.Key_NumLock): (114,),
    int(Qt.Key.Key_ScrollLock): (115,),
    # The four Qt reports without a side. Both of Mesen's, so a binding to
    # either one of them fires from either key.
    int(Qt.Key.Key_Shift): (116, 117),
    int(Qt.Key.Key_Control): (118, 119),
    int(Qt.Key.Key_Alt): (120, 121),
    int(Qt.Key.Key_Meta): (70, 71),
    int(Qt.Key.Key_AltGr): (121,),
    int(Qt.Key.Key_Semicolon): (140,),
    int(Qt.Key.Key_Equal): (141,),
    int(Qt.Key.Key_Comma): (142,),
    int(Qt.Key.Key_Minus): (143,),
    int(Qt.Key.Key_Period): (144,),
    int(Qt.Key.Key_Slash): (145,),
    int(Qt.Key.Key_QuoteLeft): (146,),
    int(Qt.Key.Key_BracketLeft): (149,),
    int(Qt.Key.Key_Backslash): (150,),
    int(Qt.Key.Key_BracketRight): (151,),
    int(Qt.Key.Key_Apostrophe): (152,),
}

#: The same, for a key press that carried the keypad modifier. Only the keys
#: the keypad *has*: anything else with the modifier set is looked up in
#: :data:`QT_TO_MESEN` as usual, because a keyboard that reports the modifier
#: on a key the numpad does not have is still that key.
KEYPAD_TO_MESEN: dict[int, tuple[int, ...]] = {
    **{int(Qt.Key.Key_0) + n: (74 + n,) for n in range(10)},
    int(Qt.Key.Key_Asterisk): (84,),
    int(Qt.Key.Key_Plus): (85,),
    int(Qt.Key.Key_Minus): (87,),
    int(Qt.Key.Key_Period): (88,),
    int(Qt.Key.Key_Slash): (89,),
    # A keypad with Num Lock off sends these instead of its digits, and they
    # are the same physical keys -- so they are the numpad's codes, not the
    # arrow cluster's, which is what Mesen's key manager reports too.
    int(Qt.Key.Key_Insert): (74,),
    int(Qt.Key.Key_End): (75,),
    int(Qt.Key.Key_Down): (76,),
    int(Qt.Key.Key_PageDown): (77,),
    int(Qt.Key.Key_Left): (78,),
    int(Qt.Key.Key_Clear): (79,),
    int(Qt.Key.Key_Right): (80,),
    int(Qt.Key.Key_Home): (81,),
    int(Qt.Key.Key_Up): (82,),
    int(Qt.Key.Key_PageUp): (83,),
    int(Qt.Key.Key_Delete): (88,),
}


def mesen_codes(key: int, keypad: bool = False) -> tuple[int, ...]:
    """What ``key`` is called in Mesen's numbering. Empty if it has no name.

    ``key`` is a plain ``int`` rather than a ``Qt.Key`` because a real key
    event can carry a value that is not in the enum at all -- a keyboard's
    media keys, a compose sequence -- and converting one to look it up raises
    instead of missing.
    """
    if keypad:
        found = KEYPAD_TO_MESEN.get(key)
        if found is not None:
            return found
    return QT_TO_MESEN.get(key, ())
