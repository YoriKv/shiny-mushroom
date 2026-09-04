"""The music and time limit bypasses: two objects that overrule a level header.

A level header names its music out of eight tracks and its time limit out of
four values, both read once at the top of the level load. Lunar Magic adds two
standard objects that say the same things without those tables -- ``26`` names
any track the music register takes, ``28`` any three-digit time limit -- and
the ``header-bypasses`` feature (``Config/HeaderBypasses.asm``) gives this
cartridge both. They win over the header because of where they run: the object
pass is behind the header parse and ahead of the music register reaching the
sound chip.

This module is the shared vocabulary -- the grammar of the two records, which
the editor's parser and the cartridge's routines have to agree on byte for
byte::

    26: N10-UUUU 0110uuuu MMMMMMMM
    28: N10-BBBB 1000AAAA R---CCCC

**Both keep their payload where a placed object keeps its position**, which is
what makes them settings for the level rather than something standing in it: a
bypass record has no position, and the two nibbles a level of either shape
would read as one are digits here. The music record carries its track twice --
once in the settings byte and once in those nibbles -- and the cartridge reads
the settings byte; the time record spells its hundreds in the settings byte and
its tens and ones in the nibbles, so all three have to be written for the
record to mean what it says.

A track of zero names none, and three zero digits name no time limit unless the
force flag is set. That is Lunar Magic's own rule, and it is what leaves the
header's setting standing where a record carries nothing.
"""

from __future__ import annotations

#: The two object numbers, and both together for a membership test.
MUSIC = 0x26
TIME_LIMIT = 0x28
OBJECTS = (MUSIC, TIME_LIMIT)

#: Bytes in either record: the standard three, since neither reads past them.
RECORD_BYTES = 3

#: A digit is a nibble, and the settings byte's high bit is the time limit's
#: force flag -- the timer written on every entry rather than only on the way
#: in from the map.
DIGIT_MASK = 0x0F
FORCE = 0x80

#: Byte 0's new-screen bit, which a bypass record carries like any other object
#: and which is the one bit of it that is not payload.
NEW_SCREEN = 0x80

#: The highest track a record can name, and the highest time limit: the whole
#: settings byte less the one value that names no track, and three digits.
MAX_TRACK = 0xFE
MAX_TIME = 0xFFF

#: What a fresh record of each kind names. The first value ``LevelMusicTable``
#: can hold, and the time limit three quarters of the game's levels start at --
#: so an object dropped into a level does something a person can hear or read
#: rather than nothing they can find.
DEFAULT_TRACK = 0x01
DEFAULT_TIME = 0x400

#: What the music register's two high bits mean where the header sets it, and
#: where the bypass does: bit 7 says the track playing is not an ordinary one,
#: bit 6 that the track asked for is the one already playing and is not to be
#: restarted. Neither is part of the record -- the cartridge works them out
#: from what is playing, exactly as the header parse does.
MUSIC_SPECIAL = 0x80
MUSIC_SAME_TRACK = 0x40


def is_bypass(number: int) -> bool:
    """Whether ``number`` is one of the two bypass objects."""
    return number in OBJECTS


def track(record: bytes) -> int | None:
    """The track a music record names, or ``None`` where it names none.

    The settings byte holds the track plus one, so a stored zero is "no
    bypass" -- the header's own setting stands, and the record does nothing.
    """
    stored = record[2] if len(record) > 2 else 0
    return None if stored == 0 else stored - 1


def with_track(record: bytes, wanted: int | None) -> bytes:
    """``record`` naming ``wanted``, or naming no track for ``None``.

    The value goes in the settings byte and again in the two nibbles a placed
    object would keep its position in, which is where the format keeps a second
    copy of it; the new-screen bit and the object number are left exactly as
    they are. The cartridge reads the settings byte, so the copy is written for
    whoever reads the record next rather than for this build.
    """
    stored = 0 if wanted is None else (wanted + 1) & 0xFF
    first = (record[0] & NEW_SCREEN) | 0x40 | (stored >> 4)
    second = (MUSIC & 0x0F) << 4 | (stored & DIGIT_MASK)
    return bytes((first, second, stored))


def time_limit(record: bytes) -> int:
    """The three digits a time record spells, as one twelve-bit number.

    Hundreds from the settings byte's low nibble, tens from byte 0's and ones
    from byte 1's -- read out of the record itself, which is what the cartridge
    does, because the loader exchanges those two nibbles in a vertical level
    and they are not positions.
    """
    hundreds = record[2] & DIGIT_MASK if len(record) > 2 else 0
    tens = record[0] & DIGIT_MASK if record else 0
    ones = record[1] & DIGIT_MASK if len(record) > 1 else 0
    return hundreds << 8 | tens << 4 | ones


def forced(record: bytes) -> bool:
    """Whether a time record resets the timer on every entry to the level."""
    return bool(len(record) > 2 and record[2] & FORCE)


def names_a_time(record: bytes) -> bool:
    """Whether a time record sets the timer at all.

    Three zero digits name none -- the header's own setting stands -- unless
    the force flag is set, which is the only way to a time limit of zero.
    """
    return time_limit(record) != 0 or forced(record)


def with_time_limit(record: bytes, wanted: int, force: bool) -> bytes:
    """``record`` spelling ``wanted`` across its three digits.

    The new-screen bit and the object number come through unchanged; every
    other bit of the record is the time limit or the force flag.
    """
    wanted &= MAX_TIME
    first = (record[0] & NEW_SCREEN) | 0x40 | (wanted >> 4 & DIGIT_MASK)
    second = (TIME_LIMIT & 0x0F) << 4 | (wanted & DIGIT_MASK)
    settings = (FORCE if force else 0x00) | (wanted >> 8 & DIGIT_MASK)
    return bytes((first, second, settings))


def blank(number: int) -> bytes:
    """A fresh record for either bypass: :data:`DEFAULT_TRACK` for the music,
    :data:`DEFAULT_TIME` for the clock, and no forced reset.

    Both name something, because the alternative is a record that does nothing
    and says so nowhere: a bypass carrying no track and a level with no bypass
    at all are the same level, and the object is the switch.
    """
    if number == MUSIC:
        return with_track(bytes(RECORD_BYTES), DEFAULT_TRACK)
    if number == TIME_LIMIT:
        return with_time_limit(bytes(RECORD_BYTES), DEFAULT_TIME, force=False)
    raise ValueError(f"{number:#04x} is not a bypass object")
