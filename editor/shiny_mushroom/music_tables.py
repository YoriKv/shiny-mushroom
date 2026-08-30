"""The two audio tables a project can edit, and what each row may name.

Both are :class:`~shiny_mushroom.token_table.TokenTable`\\ s -- one token moves
and the file is otherwise byte for byte what it was -- and between them they are
the whole of the path from a level to a song that does not mean editing sequence
data:

``levels/music.asm``
    ``LevelMusicTable``: which of the eight header settings plays which track.
    A row's token is a ``!Define_SMW_LevelMusic_*``, so the saved source still
    says *Castle* rather than ``$08``.
``SPC700/tables/*-music-pointers.asm``
    ``MusicPtrs``, one fragment per music bank: which song a music value
    resolves to. A row's token is the ``MUSIC_*`` label above a song's phrase
    list.

Change the first and every level on that setting plays something else; change
the second and every level, world and cutscene that asks for that value does.
The two compose -- a setting names a value and the value names a song -- which
is why they are edited from one window.

**Both are the tables of one music bank.** ``LevelMusicTable``'s values are
level-bank values, and the three pointer fragments are independent: repointing
overworld value ``$02`` says nothing about level value ``$02``, because the two
tables are never in the SPC700's memory at once.

Qt-free, like the rest of the model. What a token *means* -- which song a label
is above, what value a define holds -- is read here; writing the fragment is
:class:`shiny_mushroom.project_music.MusicFiles`' job.
"""

from __future__ import annotations

import re
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom.token_table import TokenTable, TokenTableError
from smw_tools import audio

#: The fragment ``SMW_LoadLevelHeader`` reads its eight settings out of.
LEVEL_MUSIC_TABLE = Path("levels/music.asm")

#: The fragment at the head of each music bank's block, by the blob it belongs
#: to. Split out of the three SPC700 sources so a repoint shadows a table
#: rather than a bank's worth of song data.
MUSIC_POINTERS = {
    audio.LEVEL_MUSIC_BLOB: Path("SPC700/tables/level-music-pointers.asm"),
    audio.OVERWORLD_MUSIC_BLOB: Path("SPC700/tables/overworld-music-pointers.asm"),
    audio.CREDITS_MUSIC_BLOB: Path("SPC700/tables/credits-music-pointers.asm"),
}

#: Where each blob's songs are defined, for the labels a pointer row may name.
MUSIC_SOURCES = {
    audio.LEVEL_MUSIC_BLOB: Path("SPC700/level_music.asm"),
    audio.OVERWORLD_MUSIC_BLOB: Path("SPC700/overworld_music.asm"),
    audio.CREDITS_MUSIC_BLOB: Path("SPC700/credits_music.asm"),
}

#: The define prefix a level music setting's token wears.
LEVEL_MUSIC_PREFIX = "Define_SMW_LevelMusic_"

#: A song's label where the source defines it: at column zero, before its list
#: of phrase pointers.
_SONG_LABEL = re.compile(r"^(MUSIC_\w+):")

#: A level music define, as the fragment spells it.
_DEFINE_TOKEN = re.compile(r"^!(" + LEVEL_MUSIC_PREFIX + r"\w+)$")


class MusicTableError(TokenTableError):
    """A table that could not be read, or a row it does not have."""


# -- the tables ---------------------------------------------------------------


@dataclass(frozen=True)
class LevelMusicTable(TokenTable):
    """``LevelMusicTable``: eight rows, one per header music setting."""

    noun = "music setting"
    plural = "music settings"

    @classmethod
    def _error(cls, message: str) -> MusicTableError:
        return MusicTableError(message)

    def define(self, setting: int) -> str:
        """The define ``setting`` names, without its ``!``.

        The fragment spells a token with the sigil because that is what asar
        reads; everything above this speaks of the define itself.
        """
        token = self.token(setting)
        found = _DEFINE_TOKEN.match(token)
        if found is None:
            raise MusicTableError(
                f"music setting {setting} names {token!r}, which is not a "
                f"{LEVEL_MUSIC_PREFIX} define -- this table has been edited by "
                f"hand into a shape the editor cannot read back"
            )
        return found.group(1)

    def with_define(self, setting: int, define: str) -> LevelMusicTable:
        """This table with ``setting`` naming ``define``."""
        return self.repointed(setting, f"!{define}")


@dataclass(frozen=True)
class MusicPointerTable(TokenTable):
    """``MusicPtrs``: one row per music value, **numbered from one**.

    The mailbox value is the index the engine uses and it starts at ``$01``,
    since ``$00`` is the mailbox's "nothing asked for" -- so a value and a row
    are one apart everywhere, and this is the only place that arithmetic lives.
    """

    noun = "music value"
    plural = "music values"

    @classmethod
    def _error(cls, message: str) -> MusicTableError:
        return MusicTableError(message)

    @property
    def values(self) -> tuple[int, ...]:
        """Every music value this table answers, ascending."""
        return tuple(range(1, len(self.tokens) + 1))

    def song(self, value: int) -> str:
        """The song label ``value`` resolves to."""
        return self.token(value - 1)

    def values_playing(self, label: str) -> tuple[int, ...]:
        """Every music value that resolves to ``label``, ascending."""
        return tuple(row + 1 for row in self.rows_naming(label))

    def with_song(self, value: int, label: str) -> MusicPointerTable:
        """This table with ``value`` resolving to ``label``."""
        return self.repointed(value - 1, label)

    def token(self, row: int) -> str:
        if not 0 <= row < len(self.tokens):
            raise self._error(f"this bank has no music value ${row + 1:02X}")
        return self.tokens[row]


# -- what a row may name ------------------------------------------------------


@dataclass(frozen=True)
class TrackChoice:
    """One thing a level music setting can be given.

    ``value`` is what the byte becomes, which is the only reason a caller can
    say whether the choice names a song in the level bank: the define is a
    name for a number and nothing more.
    """

    define: str
    name: str
    value: int


def track_choices(defines: str) -> tuple[TrackChoice, ...]:
    """Every ``!Define_SMW_LevelMusic_*`` the disassembly states, in file order.

    All of them, including the ones that are not songs: ``MusicFade`` is
    ``$80``, a command rather than a track, and the table will take it. Which
    of them resolve to a song is the caller's to say and the window's to show
    -- refusing here would be this module deciding what a hack may do with a
    byte the game itself writes.
    """
    out: list[TrackChoice] = []
    for name, value in audio.defines_in(defines, LEVEL_MUSIC_PREFIX):
        out.append(
            TrackChoice(f"{LEVEL_MUSIC_PREFIX}{name}", audio.readable(name), value)
        )
    return tuple(out)


def setting_names(
    table: LevelMusicTable, tracks: Iterable[TrackChoice]
) -> tuple[str, ...]:
    """What each of the eight header music settings should be called.

    **The name of a setting is the name of the track it holds**, so it follows
    an edit: change setting 0 to Castle and every window that names settings
    says Castle. Anything holding a fixed list would go on saying *Here We Go*
    over a setting that no longer plays it, which is a label that lies rather
    than one that is merely stale.

    A setting whose define is not one of ``tracks`` -- or a table hand-edited
    into a shape that has no define at all -- is named for what it holds
    instead, since inventing prose for it would be the same lie.
    """
    named = {one.define: one.name for one in tracks}
    out = []
    for setting in range(len(table.lines)):
        try:
            define = table.define(setting)
        except MusicTableError:
            out.append(f"Setting {setting}")
            continue
        out.append(named.get(define, define.removeprefix(LEVEL_MUSIC_PREFIX)))
    return tuple(out)


def song_labels(source: str) -> tuple[str, ...]:
    """Every ``MUSIC_*`` label one music bank's source defines, in file order.

    What a pointer row may name, and the whole of it: a label the source does
    not define assembles nothing, and a row may name any label it does --
    including one no row currently names, which is how a bank's unused songs
    are reached.
    """
    seen: dict[str, None] = {}
    for line in source.splitlines():
        found = _SONG_LABEL.match(line)
        if found is not None:
            seen.setdefault(found.group(1), None)
    return tuple(seen)
