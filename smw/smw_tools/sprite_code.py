"""What a custom sprite's code may say, and the fragments it is read through.

``Config/CustomSprites.asm`` assembles a project's sprites out of fragments
the editor regenerates -- the rows naming each sprite number's routine per
entry point, the properties each number carries, and the sprites' own code.
This module is their grammar: what a file may declare, and the text of each
fragment. It is ``smw_tools.level_code`` again with sprites in place of
levels, and shares that module's library mechanism outright.

Nothing here parses 65816, and nothing here rewrites a file. A file is
asar's to understand, and the placement that reads it checks the one thing
a text scan could not -- that an ``org`` into the game came back -- against
the assembled position rather than the source.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Mapping

from smw_tools.level_code import namespaced

#: The folders a project's custom sprites live in, relative to the game
#: folder: one folder per sprite kind, because which folder a file goes in
#: is the one thing the editor cannot work out for itself -- a library file
#: in a flat folder would be indistinguishable from a sprite. None of these
#: folders' files shadow anything the disassembly ships.
SPRITES_DIR = "code/sprites"
LIB_DIR = "code/sprites/lib"

#: The kinds a sprite may be, in the order the engine's own tables come:
#: ``normal`` through the 201-entry pair, the rest through their own
#: dispatch. The folder under :data:`SPRITES_DIR` is the kind's name.
KINDS = (
    "normal",
    "extended",
    "cluster",
    "minorextended",
    "bounce",
    "smoke",
    "generator",
    "shooter",
)

#: The kinds past ``normal``: one ``main`` entry point each, dispatched
#: where the game dispatches that kind, with numbers past the vanilla
#: table's end.
KIND_ENTRIES = ("main",)

#: A normal sprite's entry points: ``init`` and ``main`` are PIXI's, and
#: the five behind them are that tool's custom status entry points, run in
#: place of the acts-like behaviour at the matching sprite status --
#: ``mouth`` at ``$07``, ``carriable`` at ``$09``, ``kicked`` at ``$0A``,
#: ``carried`` at ``$0B``, ``goal`` at ``$0C``, the goal walk. A status a
#: sprite does not cover runs the game's behaviour and then, at ``$09``
#: and up, the sprite's ``main`` -- PIXI's contract, which most carryable
#: sprites in the wild are written against.
NORMAL_ENTRIES = ("init", "main", "carriable", "kicked", "carried", "mouth", "goal")

#: Every entry point any kind serves, plus ``cape`` -- PIXI's per-extended-
#: sprite cape-interaction pointer, which this dispatch does not build --
#: so a file declaring it is refused by name rather than assembled with
#: its cape behaviour silently dropped.
ALL_ENTRIES = NORMAL_ENTRIES + ("cape",)

#: How many numbers a kind's rows table holds. Normal sprites get the whole
#: byte -- the custom bit is what makes the number space a second $100 --
#: and every other kind gets $80, which is more than any of their number
#: bytes can carry.
NORMAL_NUMBERS = 0x100
KIND_NUMBERS = 0x80

#: The vanilla entry counts of the dispatch tables, by kind: a number below
#: its kind's count is the game's, and a custom row may not shadow it. The
#: counts are the tables' own (``docs/smw/sprite-dispatch.md``); the
#: shooter's and the generator's are over the dispatched index, which their
#: sites decrement before the call.
VANILLA_COUNTS = {
    "normal": 0xC9,
    "extended": 0x13,
    "cluster": 0x09,
    "minorextended": 0x0C,
    "bounce": 0x08,
    "smoke": 0x06,
    "generator": 0x0F,
    "shooter": 0x03,
}

#: The one sprite number the custom bit cannot mark: the goal tape's two
#: extra bits choose between secret exits under Lunar Magic 3.00's hijack,
#: so both are spoken for and the spawn stub leaves the flag unset.
GOAL_TAPE = 0x7B

#: The fragment naming each sprite's routines, one macro line per row --
#: read with the defines, because the hooks in ``Banks/`` ask which entry
#: points and kinds are wanted long before the tables are placed.
ROWS_FRAGMENT = "code/sprites/custom-sprites.asm"

#: The fragment carrying each sprite's properties -- the acts-like number,
#: the six Tweaker bytes in the source's own vocabulary, and the two extra
#: property bytes -- as named defines and one macro line per sprite.
PROPERTIES_FRAGMENT = "code/sprites/custom-sprite-properties.asm"

#: The fragment holding the sprites' own code: one label and ``incsrc`` per
#: sprite file, placed in the sprite bank once every bank has emitted.
DATA_FRAGMENT = "code/sprites/custom-sprites-data.asm"

#: The sprite library fragment: one ``namespace`` and ``incsrc`` per file
#: in :data:`LIB_DIR`, exactly the shared library the level code has
#: (``smw_tools.level_code``), so ``math.asm``'s ``sqrt`` is ``math_sqrt``
#: to every sprite that calls it.
LIB_FRAGMENT = "code/pixi/lib.asm"

#: PIXI's shared routines: one ``.asm`` per routine, reached by a macro
#: named after the file -- ``%GetDrawInfo()`` -- which is that tool's own
#: mechanism. The fragment defines every macro first and assembles the
#: bodies after, so a routine may call another's macro whatever order the
#: folder reads in.
ROUTINES_DIR = "code/pixi/routines"
ROUTINES_FRAGMENT = "code/pixi/routines.asm"

#: The table name each entry point's rows are emitted under, which is also
#: the spelling the rows fragment's macro lines use.
TABLES = {
    "init": "Init",
    "main": "Main",
    "carriable": "Carriable",
    "kicked": "Kicked",
    "carried": "Carried",
    "mouth": "Mouth",
    "goal": "Goal",
}

#: The kind name each non-normal kind's rows are emitted under.
KIND_TABLES = {
    "extended": "Extended",
    "cluster": "Cluster",
    "minorextended": "MinorExtended",
    "bounce": "Bounce",
    "smoke": "Smoke",
    "generator": "Generator",
    "shooter": "Shooter",
}

#: A label at the start of a line, which is one of the two ways an entry
#: point is declared in the wild. The same textual reading the tools do,
#: with the same hole: a label inside a false ``if`` is still a label here,
#: so what a file declares is a claim the assembler settles.
_LABEL = re.compile(rf"^({'|'.join(ALL_ENTRIES)}):", re.M | re.I)

#: The other spelling: PIXI's ``print "INIT", pc`` declarations, which its
#: patcher reads out of asar's output. Read as the same claim.
_PRINT = re.compile(
    r"^\s*print\s+\"("
    + "|".join(entry.upper() for entry in ALL_ENTRIES)
    + r")\s*\"\s*,\s*pc",
    re.M | re.I,
)


class SpriteCodeError(Exception):
    """A file that cannot be a custom sprite, or a fragment that cannot be
    written."""


#: The print form, with the position it stands at -- see
#: :func:`prints_to_labels`.
_PRINT_NAMES = "|".join(entry.upper() for entry in ALL_ENTRIES)
_PRINT_LINE = re.compile(
    r"(?im)^(\s*)print\s+\"(" + _PRINT_NAMES + r")\s*\"?\s*,\s*pc\s*$"
)


def prints_to_labels(source: str) -> str:
    """``source`` with each ``print "MAIN", pc`` declaration made a label at
    the same position, which is what a rows table can name.

    The label keeps the print's own place in the file -- the position is the
    declaration's whole meaning -- and the import is where this belongs:
    PIXI's patcher reads the printed address out of the assembler's output,
    and this build reads labels.
    """
    return _PRINT_LINE.sub(lambda m: f"{m.group(2).lower()}:", source)


def plain_labels(source: str) -> str:
    """``source`` with PIXI's macro-scoped label prefix stripped.

    That tool assembles each shared routine inside a generated macro, so its
    labels are spelled ``?main`` and ``?.loop``; read as a bare file those
    are errors. The import strips the ``?``, and the routines fragment reads
    each file inside a namespace of its own, so the plain names collide with
    nothing.
    """
    return re.sub(r"\?(?=[A-Za-z_.])", "", source)


def declared(source: str) -> tuple[str, ...]:
    """The entry points ``source`` declares, in :data:`ALL_ENTRIES` order.

    Both spellings in the wild are read -- a ``main:`` label at the start of
    a line, and PIXI's ``print "MAIN", pc`` -- and both are claims rather
    than facts: either inside a false ``if`` is declared here and absent
    from the build. Whoever generates the rows has to drop one the
    assembler could not find.
    """
    found = {name.lower() for name in _LABEL.findall(source)}
    found |= {name.lower() for name in _PRINT.findall(source)}
    return tuple(entry for entry in ALL_ENTRIES if entry in found)


def labelled(source: str) -> tuple[str, ...]:
    """The entry points ``source`` declares **as labels**, which is the only
    spelling a rows table can name.

    A ``print "MAIN", pc`` declaration marks a position the rows cannot
    reach -- PIXI's patcher reads it out of the assembler's output, and this
    build reads labels -- so a file carrying only the print form is one the
    import has to rewrite, and whoever generates the rows says so rather
    than emitting a row into nothing.
    """
    found = {name.lower() for name in _LABEL.findall(source)}
    return tuple(entry for entry in ALL_ENTRIES if entry in found)


def _check_number(kind: str, number: int) -> None:
    """Refuse a number the kind's table cannot hold or the game already
    dispatches."""
    numbers = NORMAL_NUMBERS if kind == "normal" else KIND_NUMBERS
    if not 0 <= number < numbers:
        raise SpriteCodeError(
            f"a {kind} sprite is numbered $00 to ${numbers - 1:02X}, "
            f"not ${number:02X}"
        )
    if kind != "normal" and number < VANILLA_COUNTS[kind]:
        raise SpriteCodeError(
            f"${number:02X} is one of the game's own {kind} sprites -- its "
            f"table dispatches $00 to ${VANILLA_COUNTS[kind] - 1:02X}, and a "
            f"custom row may not shadow one. Custom {kind} sprites start at "
            f"${VANILLA_COUNTS[kind]:02X}."
        )


def rows_fragment(
    rows: Mapping[str, Mapping[int, str]],
    kinds: Mapping[str, Mapping[int, str]] = {},
) -> str:
    """The fragment naming each sprite's routines, one line per row.

    ``rows`` is the routine label per number per normal entry point;
    ``kinds`` the label per number per non-normal kind, whose one entry
    point is ``main``. Lines come in entry-point order and then number
    order, which is a reading order and nothing else -- the macros declare
    each row as a define and the placement emits every table row by row.
    """
    lines = []
    for entry in NORMAL_ENTRIES:
        for number in sorted(rows.get(entry, {})):
            _check_number("normal", number)
            lines.append(
                f"%SMW_CustomSprite({TABLES[entry]}, "
                f"${number:02X}, {rows[entry][number]})\n"
            )
    for kind in KINDS[1:]:
        for number in sorted(kinds.get(kind, {})):
            _check_number(kind, number)
            lines.append(
                f"%SMW_CustomSpriteKind({KIND_TABLES[kind]}, "
                f"${number:02X}, {kinds[kind][number]})\n"
            )
    return "".join(lines)


def properties_fragment(sprites: Mapping[int, str]) -> str:
    """The macro lines binding each sprite number to its property defines.

    ``sprites`` maps the number onto the define prefix its block of named
    properties uses -- ``{0x1A: "CustomSpr01A"}`` for a block of
    ``!Define_SMW_CustomSpr01A_<name>`` lines. The blocks themselves are
    the editor's to write in the template's vocabulary; this is only the
    line that makes the assembler build the table rows from them.
    """
    lines = []
    for number in sorted(sprites):
        _check_number("normal", number)
        lines.append(
            f"%SMW_CustomSpriteProperties(${number:02X}, {sprites[number]})\n"
        )
    return "".join(lines)


def lib_fragment(names: Iterable[str]) -> str:
    """The fragment that assembles the sprite library, one file per line.

    The level code's own mechanism (:func:`smw_tools.level_code.namespaced`),
    shared rather than copied: each file is read inside a namespace of its
    own name, order is the folder's sorted and means nothing, and a library
    file may call another's labels -- which PIXI's ``routines/`` cannot.
    """
    return "".join(namespaced(name, f"{LIB_DIR}/{name}.asm") for name in sorted(names))


_ROUTINE_NAME = re.compile(r"[A-Za-z_]\w*\Z")


def routines_fragment(names: Iterable[str]) -> str:
    """The fragment that gives each shared routine its macro and its body.

    PIXI's own mechanism: a routine file is assembled once and reached by a
    macro named after it, so ``%GetDrawInfo()`` costs a ``JSL`` wherever it
    is written. The macros all come first and the bodies after, so a
    routine's body may call another routine's macro whatever order the
    folder reads in. Each body is read inside a namespace of its own, the
    library's mechanism -- which asks of a file dropped in by hand what the
    import produces: plain labels, not the macro-scoped ``?main`` spelling
    PIXI's originals carry.

    A file whose name could not be a macro's is refused: the name *is* the
    macro, so there is nothing else it could become.
    """
    held = sorted(names)
    for name in held:
        if not _ROUTINE_NAME.match(name):
            raise SpriteCodeError(
                f"{name}.asm cannot be a shared routine: the file's name is "
                f"the macro a sprite calls it by, so it must be one word of "
                f"letters, digits and underscores"
            )
    macros = "".join(
        f"macro {name}()\n\tJSL.l SMW_PixiRoutine_{name}\nendmacro\n" for name in held
    )
    bodies = "".join(
        f"SMW_PixiRoutine_{name}:\n"
        + namespaced(f"PixiRoutine{name}", f"{ROUTINES_DIR}/{name}.asm")
        for name in held
    )
    return macros + bodies


#: PIXI's names for the six Tweaker bytes' fields, LSB first per byte, onto
#: the template's -- the positional mapping ``docs/smw/sprite-dispatch.md``
#: tabulates, held here so a metadata sibling in that tool's own JSON
#: schema reads straight into the named vocabulary. The multi-bit fields
#: lead each byte, exactly as the template's ``db`` expressions build them.
TWEAK_NAMES: dict[str, tuple[tuple[str, str], ...]] = {
    "$1656": (
        ("Object Clipping", "ObjectClipping"),
        ("Can be jumped on", "SafeToJumpOn"),
        ("Dies when jumped on", "DiesWhenJumpedOn"),
        ("Hop in/kick shell", "HopInOrKickShells"),
        ("Disappears in cloud of smoke", "DisappearAsSmokeCloud"),
    ),
    "$1662": (
        ("Sprite Clipping", "SpriteClipping"),
        ("Use shell as death frame", "UseShellAsDeathFrame"),
        ("Fall straight down when killed", "FallWhenKilled"),
    ),
    "$166E": (
        ("Use second graphics page", "UseSP3And4"),
        ("Palette", "Palette"),
        ("Disable fireball killing", "ImmuneToFire"),
        ("Disable cape killing", "ImmuneToCape"),
        ("Disable water splash", "DisableSplashing"),
        ("Don't interact with Layer 2", "OnlyInteractWithLayer1"),
    ),
    "$167A": (
        ("Don't disable cliping when starkilled", "DontDisableClippingWhenStarKilled"),
        ("Invincible to star/cape/fire/bounce blk.", "InvincibleToMostThings"),
        ("Process when off screen", "TrackWhenOffScreen"),
        ("Don't change into shell when stunned", "DontBecomeShellWhenStunned"),
        ("Can't be kicked like shell", "CantBeKickedLikeShell"),
        (
            "Process interaction with Mario every frame",
            "ProcessPlayerInteractionEveryFrame",
        ),
        ("Gives power-up when eaten by yoshi", "GivePowerupWhenEaten"),
        ("Don't use default interaction with Mario", "UseNonDefaultPlayerInteraction"),
    ),
    "$1686": (
        ("Inedible", "Inedible"),
        ("Stay in Yoshi's mouth", "StayInYoshisMouth"),
        ("Weird ground behaviour", "DisableGroundShifting"),
        ("Don't interact with other sprites", "DisableSpriteClipping"),
        ("Don't change direction if touched", "DontChangeDirectionWhenTouched"),
        ("Don't turn into coin when goal passed", "DontBecomeCoinOnGoalTapeTrigger"),
        ("Spawn a new sprite", "SpawnsNewSprite"),
        ("Don't interact with objects", "DisableObjectClipping"),
    ),
    "$190F": (
        ("Make platform passable from below", "CanPassThroughPlaformFromBelow"),
        ("Don't erase when goal passed", "DontDespawnOnLevelEnd"),
        ("Can't be killed by sliding", "ImmuneToSliding"),
        ("Takes 5 fireballs to kill", "5FireballHP"),
        ("Can be jumped on with upwards Y speed", "CanBeJumpedOnWithUpwardYSpeed"),
        ("Death frame two tiles high", "2TileTallDeathFrame"),
        ("Don't turn into a coin with silver POW", "ImmuneToSilverPSwitch"),
        (
            "Don't get stuck in walls (carryable sprites)",
            "DontGetStuckInWallsWhenCarried",
        ),
    ),
}

#: What a new custom sprite acts like when its metadata does not say: the
#: unused sprite, the corpus's own answer (159 of 288 declarations).
DEFAULT_ACTS_LIKE = 0x36

#: The most extra bytes a record may carry behind its three: what four
#: covers is all but five of the corpus's 242 declared counts, and past it
#: PIXI switches to a pointer scheme this cartridge does not make.
EXTRA_BYTE_LIMIT = 4

#: The metadata key the count is stored under -- PIXI's own, the
#: bit-set column, since a custom sprite is by definition the bit set.
EXTRA_BYTES_KEY = "Additional Byte Count (extra bit set)"


def properties_defines(prefix: str, meta: Mapping) -> str:
    """One sprite's property block: the named defines a
    ``%SMW_CustomSpriteProperties`` line reads, from a metadata mapping in
    PIXI's own JSON schema.

    Every field is written whether the mapping carries it or not -- the
    macro reads all of them -- and a missing one is its default: the
    acts-like number is the unused sprite's and every flag is clear. The
    values are emitted as the same named defines a vanilla sprite's
    properties are written in, so the assembly a person reads back is
    spelled the way ``sprites/SpriteProperties.asm`` is.
    """
    acts = int(meta.get("ActLike", DEFAULT_ACTS_LIKE)) & 0xFF
    prop1 = int(meta.get("Extra Property Byte 1", 0)) & 0xFF
    prop2 = int(meta.get("Extra Property Byte 2", 0)) & 0xFF
    extra = int(meta.get(EXTRA_BYTES_KEY, 0))
    if not 0 <= extra <= EXTRA_BYTE_LIMIT:
        raise SpriteCodeError(
            f"{prefix} declares {extra} extra bytes; the spawn seam reads "
            f"up to {EXTRA_BYTE_LIMIT}, and past that PIXI's own answer is "
            f"a pointer scheme this cartridge does not make"
        )
    lines = [
        f"!Define_SMW_{prefix}_ActsLike = ${acts:02X}",
        f"!Define_SMW_{prefix}_ExtraProp1 = ${prop1:02X}",
        f"!Define_SMW_{prefix}_ExtraProp2 = ${prop2:02X}",
        f"!Define_SMW_{prefix}_ExtraBytes = ${extra:02X}",
    ]
    for byte, fields in TWEAK_NAMES.items():
        values = meta.get(byte, {})
        for key, name in fields:
            value = values.get(key, 0) if isinstance(values, Mapping) else 0
            lines.append(f"!Define_SMW_{prefix}_{name} = ${int(value) & 0xFF:02X}")
    return "\n".join(lines) + "\n"
