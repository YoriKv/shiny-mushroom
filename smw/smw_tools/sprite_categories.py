"""What each sprite is *for*, which is the one thing about a sprite the
cartridge does not decide.

Every other fact the editor holds about a sprite is read back out of the tree:
the names come from the dispatch tables, the ranges from the loader's own
comparisons, the behaviour flags from `sprites/SpriteProperties.asm`. A
category is not among them. There is no table in the ROM that says a Koopa is an
enemy and a feather is a powerup, and no combination of tweaker bits says it
either -- a Thwomp and a Rex share most of their flags and are not the same sort
of thing to put in a level. The judgement is therefore written down, once, in
the editor's `sprite-metadata.json` -- which is the source of truth for it and
is edited by hand. **This file is what keeps it honest**, by three rules:

- **It is complete or it fails.** :func:`check_categories` checks the table
  against the names read out of the dispatch tables, both ways. A sprite gained,
  lost or renamed in the source fails a test rather than quietly falling out of
  every filter.
- **`Unused` is not a judgement, and it is not about placement.** A sprite whose
  routine the disassembly names `Unused` is categorised :data:`UNUSED`, and one
  it names anything else is not; the two are checked against each other, so the
  four of them cannot drift. What that word means here is that the dispatch
  entry has no working sprite behind it -- `$12` and `$69` point at a return,
  `$36` at a data table -- and **not** that the game never places it. Whether it
  does is counted rather than argued -- `editor/tools/scan_sprite_usage.py`
  counts it -- and passing those counts in turns "no level places this" into a
  check rather than a claim. It is only ever a check:
  fifty named sprites are placed by no level and are in the game all the same,
  because something else spawns them -- Yoshi hatches out of an egg, a Bullet
  Bill comes out of a shooter. Deriving `unused` from the scan would file both
  of those under it.
- **The judgement covers the normal sprites only.** The shooters, generators,
  loaders and scroll commands are what the *loader* branches on, and what to
  call them follows from that with nothing left to decide. The metadata carries
  them flat beside the rest, so `category_of` stays a lookup; that they still
  say what the ranges imply is checked in
  `editor/tests/test_sprite_category_table.py` rather than re-derived.

Checked here, owned there: this package is standard-library-only so that it runs
in CI, and it may not reach into the editor's resources -- so the table is
passed in.
"""

from __future__ import annotations

#: A creature that opposes the player and can generally be dealt with -- jumped
#: on, burnt, caped, or eaten.
ENEMY = "enemy"
#: The sprite a boss battle is fought against, or the piece of one that carries
#: the fight. Distinct from :data:`ENEMY` because placing one is placing an
#: encounter rather than an obstacle.
BOSS = "boss"
#: Hurts on contact and is not a creature to be fought: a Thwomp, a spike, a
#: flame, and every projectile something else throws.
HAZARD = "hazard"
#: Changes what the player *is* when collected.
POWERUP = "powerup"
#: Collected or carried, without changing the player: coins, the key, a shell to
#: throw, a springboard to drop.
ITEM = "item"
#: Something to stand on that the level's tilemap does not hold -- moving,
#: falling, floating or line-guided.
PLATFORM = "platform"
#: Part of the level's fabric rather than a thing in it: blocks, doors, a pipe,
#: a vine. Static, and mostly solid.
TERRAIN = "terrain"
#: Changes the state of the level or the game when the player reaches it -- a
#: goal, a keyhole, a door, a message, a switch.
TRIGGER = "trigger"
#: Neither for nor against the player: Yoshi, and the figures a cutscene needs.
NPC = "npc"
#: Drawn and nothing else. Smoke, fireworks, a spotlight, a bird in the sky.
EFFECT = "effect"
#: Puts *other* sprites into the level. Both the ones the loader treats as
#: spawners -- the shooters, generators and multi-sprite loaders, which the
#: editor derives -- and the handful of ordinary sprites that carry a passenger.
SPAWNER = "spawner"
#: A layer scroll command. Derived by the editor from the range; named here
#: because it is one of the answers the vocabulary has to contain.
COMMAND = "command"
#: A dispatch table entry the disassembly found no use for.
UNUSED = "unused"

#: Every category, in the order they are introduced above. A vocabulary rather
#: than an enum, because the editor holds the enum and this package is what
#: writes the file it reads.
CATEGORIES = (
    ENEMY,
    BOSS,
    HAZARD,
    POWERUP,
    ITEM,
    PLATFORM,
    TERRAIN,
    TRIGGER,
    NPC,
    EFFECT,
    SPAWNER,
    COMMAND,
    UNUSED,
)

#: What the disassembly calls a normal-sprite routine it has found no purpose
#: for. The categorisation of those is not a judgement but a reading of the
#: name, and :func:`read_sprite_categories` holds the table to it.
UNUSED_NAME = "Unused"

#: How often a level has to place a sprite before :data:`UNUSED` is a wrong
#: claim about it. Once. See :func:`read_sprite_categories`.
NEVER = 0

def check_categories(
    categories: dict[int, str],
    normal: dict[int, str],
    usage: dict[int, int] | None = None,
) -> dict[int, str]:
    """``categories`` checked against the names ``normal`` read out of the
    dispatch table and, where they are known, the ``usage`` counts scanned out
    of the level containers. Returns them, so a caller can check and use in one
    expression.

    **This checks; it does not own.** The judgement lives in the editor's
    `sprite-metadata.json`, which is the source of truth for it -- there is one
    copy of it and it is hand-edited. What is here is the five ways it could
    stop describing the sprites it names, each of which has to fail rather than
    pass quietly.

    ``normal`` is the dispatch table as :mod:`smw_tools.sprite_names` reads
    it -- the routines' own names, not the editor's, because whether a routine
    is *named* ``Unused`` is a fact about the disassembly that a nicer label in
    the metadata may not quietly change. ``usage`` is the placement counts the
    metadata carries -- sprite number to how many times the shipped levels place
    one -- and is absent on a tree nobody has scanned, which is why it is
    optional rather than required.

    The five:

    - a sprite the table names and this file does not categorise, which would
      fall out of every filter in the editor;
    - a category here for a number the table does not name, which is a category
      for a sprite that no longer exists;
    - a name this file has not been told is unused;
    - a category of :data:`UNUSED` on a routine the disassembly named, which is
      the same check from the other side -- `Unused` is the disassembly's own
      answer and not something to decide here; and
    - a sprite categorised :data:`UNUSED` that a level actually places, which is
      the one check made against the game rather than against the source, and
      the only one of the five that could catch a *reading* being wrong rather
      than a table being stale.

    The converse is deliberately **not** checked. A sprite no level places is
    not thereby unused: fifty of them are spawned by something else.
    """
    missing = sorted(set(normal) - set(categories))
    extra = sorted(set(categories) - set(normal))
    if missing or extra:
        raise ValueError(
            "sprite categories do not match the normal sprite table: "
            f"uncategorised {[f'${n:02X}' for n in missing]}, "
            f"no such sprite {[f'${n:02X}' for n in extra]}"
        )
    for number, name in sorted(normal.items()):
        unused_category = categories[number] == UNUSED
        if (name == UNUSED_NAME) != unused_category:
            raise ValueError(
                f"${number:02X} is named {name!r} and categorised "
                f"{categories[number]!r}: a routine the disassembly names "
                f"{UNUSED_NAME!r} is the one sprite whose category is read "
                "rather than decided"
            )
        placed = (usage or {}).get(number, NEVER)
        if unused_category and placed > NEVER:
            raise ValueError(
                f"${number:02X} {name!r} is categorised {UNUSED!r} and the "
                f"shipped levels place it {placed} time(s) -- rescan with "
                "`uv run python editor/tools/scan_sprite_usage.py`, then give "
                "it the category it has earned"
            )
    unknown = sorted(set(categories.values()) - set(CATEGORIES))
    if unknown:
        raise ValueError(f"categories not in the vocabulary: {unknown}")
    return dict(categories)
