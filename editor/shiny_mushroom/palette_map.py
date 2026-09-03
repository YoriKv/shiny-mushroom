"""Which colour on screen came from which byte of the palette file.

The editor renders from a CGRAM the game's own loader wrote and an emulator
captured, which is what makes the picture right without the editor knowing a
format (``docs/editor/emulator-worker.md``). It is also
what a palette edit runs into: a captured CGRAM is 256 colours with no record of
where any of them came from, so recolouring one means recovering the mapping the
capture threw away.

That mapping is small, because the cartridge's is. ``SMW_BufferPalettesRoutines``
(``Banks/Bank00.asm``) is a handful of calls to one worker, ``LoadColors``,
which takes a source pointer, a byte offset into the palette mirror, a colour
count and a row count, and steps sixteen colours between rows. :class:`Run` is
one of those calls, and the tables below are the arguments the game passes,
transcribed -- the count and the row count each one *more* than the value the
game stores, because both of ``LoadColors``' loops are ``DEY``/``BPL`` and run
once more than they count down.

Sources are named by **label**, not by offset, exactly as the game's own code
names them, and resolve through the bundled catalog
(:func:`shiny_mushroom.palettes.run`). A range moved in ``Bank00.asm`` reaches
this by regenerating that file; nothing here holds an offset into the blob that
the table did not give it.

**Nothing is offered that the capture does not confirm.** A modelled mapping is
kept only where the colour it points at in the palette file is the colour the
capture actually holds (:func:`provenance`). That is not belt-and-braces: it is
what makes the model safe to be incomplete. A Mode 7 boss room, whose palette
runs through a variant this module does not carry; a colour an animation
rewrites every frame; a capture taken mid-fade -- each comes back as "not
editable here" rather than as a wrong recolour. Where the model does agree, the
byte it names holds the colour on screen.

Agreement is a check and not a proof: two offsets can hold the same colour, so
a match confirms the model was not contradicted rather than that no other
offset would also have matched. It is still the difference between an edit that
lands where it is aimed and one that does not.

What is deliberately left unmapped:

- **Colour 0 of every row.** ``SMW_UpdateEntirePalette`` zeroes the first
  colour and DMAs the mirror whole, so the whole column is the backdrop showing
  through rather than a colour anything chose.
- **Colour 1 of every row.** The code literals ``$7FDD`` (background rows) and
  ``$7FFF`` (sprite rows), written by ``LoadColorInVerticalStrip``. Changing
  them is a patch, not a palette edit.
- **Colour ``$64``**, rewritten every frame from ``Flashing`` by the animation
  code -- the pulse in ``?`` blocks and coins. Its source is editable as a run
  like any other; which frame a capture caught is not something to guess.
- **Per-sprite dynamic palettes**, uploaded by sprite code rather than by the
  loader.

Qt-free, and independent of the emulator: it is handed a captured CGRAM and a
palette file, and hands back offsets.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom import palettes
from shiny_mushroom.palettes import COLOR_SIZE, PaletteError

#: Colours in one CGRAM row, and rows in CGRAM. The loader's ``$20``-byte row
#: step is this many colours.
ROW = 16
ROWS = 16

#: Colours in the whole of CGRAM.
CGRAM_COLORS = ROW * ROWS

#: Not from the palette file. The value :func:`provenance` gives an entry it
#: cannot account for, and the one a caller must not write through.
UNMAPPED = -1

#: ``DATA_00ABD3``: byte offsets into a header-selected set, indexed by the
#: header's three-bit setting. Twelve colours apart, which is the two rows of
#: six that each of background, foreground and sprite writes.
#:
#: The loader masks the setting to **four** bits, and the table carries four
#: more entries after these eight -- the offsets for the ending palettes. A
#: header cannot reach them: all three palette fields are three bits wide
#: (:data:`shiny_mushroom.header.FIELDS`), so the ninth entry is unreachable
#: from a level and the mask below is the header's rather than the loader's.
LEVEL_SET_OFFSETS = (0x00, 0x18, 0x30, 0x48, 0x60, 0x78, 0x90, 0xA8)

#: ``DATA_00ABDF``: byte offsets into the overworld area sets, indexed by the
#: palette id ``DATA_00AD1E`` gives a submap. Twenty-eight colours apart.
#:
#: Six of the seven fit inside ``OW_Areas``, which is exactly ``6 * $38`` bytes
#: long; the seventh would read past its end. Nothing asks for it -- no submap
#: carries id 6 -- so it is transcribed as the table has it rather than trimmed.
OVERWORLD_SET_OFFSETS = (0x0000, 0x0038, 0x0070, 0x00A8, 0x00E0, 0x0118, 0x0150)

#: ``DATA_00AD1E``: which of those sets each submap wears, in submap order.
#: Two submaps share id 3, and id 6 is never asked for.
SUBMAP_PALETTE = (1, 0, 3, 4, 3, 5, 2)

#: The player's ten colours, and the four runs any of them can be. Which one is
#: on screen is a fact about the player at the moment of capture -- Mario or
#: Luigi, fire or not -- and is settled by asking the capture rather than by
#: reading the save file: :func:`player_run` takes the one that matches.
PLAYER_FIRST = 0x86
PLAYER_COUNT = 10
PLAYER_LABELS = ("Mario", "Luigi", "MarioFire", "LuigiFire")


@dataclass(frozen=True)
class Run:
    """One ``LoadColors`` call: ``count`` colours from ``label`` plus
    ``offset``, into CGRAM from colour ``first``, repeated down ``rows``.

    Each row restarts sixteen colours further into CGRAM and carries straight
    on through the source, which is the loop's own shape: ``$04`` gains ``$20``
    per row while the source pointer never rewinds.
    """

    label: str
    offset: int
    first: int
    count: int
    rows: int = 1

    def targets(self) -> tuple[int, ...]:
        """Every CGRAM colour index this run writes, in the order it writes
        them -- which is the order the source colours run in."""
        return tuple(
            row * ROW + self.first + n
            for row in range(self.rows)
            for n in range(self.count)
        )


def level_runs(background: int, foreground: int, sprite: int) -> tuple[Run, ...]:
    """``SMW_BufferPalettesRoutines_Levels``, for one level's header.

    In the order the game runs them, which is the order they must be applied:
    a later run wins where two overlap. None of these do overlap today, and
    keeping the order is what makes that a fact about the transcription rather
    than an assumption in it. The player's run does overlap ``Objects``, which
    is why :func:`level_provenance` appends it rather than putting it here.
    """
    return (
        # Colours 8-F of rows 0-1: Layer 3 and the status bar.
        Run("Layer3", 0, first=0x08, count=8, rows=2),
        # Colours 2-7 of rows 4-D: the shared level colours. The source runs
        # on past `Objects` into the three boss-room labels, because a boss's
        # palette and this run's later rows are the same bytes.
        Run("Objects", 0, first=0x42, count=6, rows=10),
        # Colours 2-7 of rows 2-3, E-F and 0-1: the three header-selected sets.
        Run("Foreground", LEVEL_SET_OFFSETS[foreground & 0x07], 0x22, 6, 2),
        Run("Sprites", LEVEL_SET_OFFSETS[sprite & 0x07], 0xE2, 6, 2),
        Run("Background", LEVEL_SET_OFFSETS[background & 0x07], 0x02, 6, 2),
        # Colours 9-F of rows 2-4 and 9-B: the berries, the same bytes twice.
        Run("YoshiBerry", 0, first=0x29, count=7, rows=3),
        Run("YoshiBerry", 0, first=0x99, count=7, rows=3),
    )


def overworld_runs(submap: int, cleared: bool = False) -> tuple[Run, ...]:
    """``SMW_BufferPalettesRoutines_Overworld_Sub``, for one submap.

    ``cleared`` is the special-world flag that swaps the area sets for their
    after-the-Star-Road copies -- the same bytes' worth, at the other end of
    the file.
    """
    if not 0 <= submap < len(SUBMAP_PALETTE):
        raise PaletteError(f"submap {submap} is not one of the seven")
    areas = "OW_AreasPassed" if cleared else "OW_Areas"
    return (
        # Colours 1-7 of rows 4-7.
        Run(areas, OVERWORLD_SET_OFFSETS[SUBMAP_PALETTE[submap]], 0x41, 7, 4),
        # Colours 9-F of rows 2-7.
        Run("OW_Objects", 0, first=0x29, count=7, rows=6),
        # Colours 1-7 of rows 8-F. Runs on past `OW_Sprites` into the lightning
        # colours, which are the last sprite row's.
        Run("OW_Sprites", 0, first=0x81, count=7, rows=8),
        # Colours 8-F of rows 0-1, running on into the Mode 7 boss colours.
        Run("OW_Layer3", 0, first=0x08, count=8, rows=2),
    )


def title_runs() -> tuple[Run, ...]:
    """``SMW_BufferPalettesRoutines_TitleScreen``: colours 8-F of rows 0 and 1,
    and nothing else. Everything the title screen shows below those two rows is
    left by whatever ran before it."""
    return (
        Run("DATA_00B63C", 0, first=0x08, count=8),
        Run("TS_Layer3", 0, first=0x18, count=8),
    )


#: Which run of the palette file each header field picks out of, and how many
#: colours it takes -- the two rows of six ``LoadColors`` writes for each.
#: ``back_area_color`` is not here: it is one colour, and it does not reach
#: CGRAM at all (:func:`back_area_offset`).
HEADER_SETS = {
    "background_palette": ("Background", 12),
    "foreground_palette": ("Foreground", 12),
    "sprite_palette": ("Sprites", 12),
}


def header_set(key: str, setting: int) -> tuple[int, int]:
    """Where the colours header field ``key`` selects start, and how many.

    What lets a panel show the twelve colours a setting stands for beside the
    number, and what a "show me these" gesture points the palette panel at.
    """
    if key not in HEADER_SETS:
        raise PaletteError(f"{key} does not select a palette set")
    label, count = HEADER_SETS[key]
    start = _label_offset(label) + LEVEL_SET_OFFSETS[setting & 0x07]
    return start, count


def back_area_offset(setting: int) -> int:
    """Where the backdrop colour for header setting ``setting`` lives.

    Not a CGRAM entry at all: the loader copies it to ``BackgroundColorLo``,
    which reaches the screen as the PPU's fixed colour. A snapshot carries it as
    ``back_area_color``, and an edit that only rewrote CGRAM would change
    nothing on screen.
    """
    return _label_offset("Sky") + (setting & 0x07) * COLOR_SIZE


# -- turning runs into a map -------------------------------------------------


#: The loader reads colours out of the global table and no other. The document
#: carries two more -- the Magikoopa and Big Boo fade steps, which their own
#: sprite routines write to CGRAM rather than ``LoadColors`` -- so a run that
#: ran past the global table's end would map a level's colour onto a boss's.
GLOBAL_TABLE = palettes.table("global_palettes")


def _label_offset(name: str) -> int:
    """Where ``name`` starts in the blob, from the bundled catalog."""
    return palettes.run(name).start


def modelled(runs: tuple[Run, ...]) -> list[int]:
    """CGRAM colour index to palette-file byte offset, as the runs say it is.

    :data:`UNMAPPED` for everything no run writes. **Unverified** -- this is
    what the game's code says it does, and :func:`provenance` is what checks it
    against what the capture holds.
    """
    out = [UNMAPPED] * CGRAM_COLORS
    for run in runs:
        source = _label_offset(run.label) + run.offset
        for step, target in enumerate(run.targets()):
            if not 0 <= target < CGRAM_COLORS:
                raise PaletteError(
                    f"{run.label} writes CGRAM colour {target}, which is not one"
                )
            offset = source + step * COLOR_SIZE
            if offset + COLOR_SIZE > GLOBAL_TABLE.end:
                raise PaletteError(
                    f"{run.label} reads past the end of the global palette table"
                )
            out[target] = offset
    return out


def player_run(blob: bytes, cgram: bytes) -> Run | None:
    """Which of the player's four palettes the capture caught, as a run.

    The player's ten colours reach CGRAM by a DMA every frame rather than
    through ``LoadColors``, so they are blob-backed like anything else but are
    not in :func:`level_runs`. Which of the four is on screen is settled by
    matching the capture: the run whose colours are the colours that are there.

    ``None`` when none of them matches -- a capture taken while the player was
    flashing, or on a screen with no player at all.
    """
    for label in PLAYER_LABELS:
        offset = _label_offset(label)
        wanted = palettes.colors(blob, offset, PLAYER_COUNT)
        if wanted == _cgram_colors(cgram, PLAYER_FIRST, PLAYER_COUNT):
            return Run(label, 0, first=PLAYER_FIRST, count=PLAYER_COUNT)
    return None


def provenance(blob: bytes, cgram: bytes, runs: tuple[Run, ...]) -> list[int]:
    """The mapping, kept only where the capture agrees with it.

    ``blob`` is the palette file **the capture was made under** -- the project's
    own, not the checkout's -- because that is what its colours have to match.

    An entry survives when the colour at the offset the model names is the
    colour CGRAM holds. Everything else comes back :data:`UNMAPPED`, which is
    the panel's cue to show it as not editable here.
    """
    palettes.check(blob)
    out = modelled(runs)
    for index, offset in enumerate(out):
        if offset == UNMAPPED:
            continue
        if palettes.color(blob, offset) != cgram_color(cgram, index):
            out[index] = UNMAPPED
    return out


def level_provenance(
    blob: bytes,
    cgram: bytes,
    *,
    background: int,
    foreground: int,
    sprite: int,
) -> list[int]:
    """:func:`provenance` for a level, the player's rows included.

    **The player's run goes last, and has to.** It is the one pair of runs here
    that overlaps: the player holds colours 6-F of row 8, and ``Objects`` holds
    colours 2-7 of rows 4-D, so they both claim row 8's colours 6 and 7. Last
    wins in :func:`modelled`, and last is right -- the loader writes ``Objects``
    once, and the per-frame DMA writes the player over it every frame after.
    That overlap is the two colours between the 164 these runs write and the 162
    distinct entries the model claims.
    """
    runs = level_runs(background, foreground, sprite)
    player = player_run(blob, cgram)
    return provenance(blob, cgram, runs + ((player,) if player else ()))


def overworld_provenance(blob: bytes, cgram: bytes, submap: int) -> list[int]:
    """:func:`provenance` for one submap of the world map.

    Both area sets are tried: which of them a map wears is a flag in the saved
    game rather than anything a capture carries, and the wrong one simply fails
    to match.
    """
    best = provenance(blob, cgram, overworld_runs(submap))
    other = provenance(blob, cgram, overworld_runs(submap, cleared=True))
    return other if _mapped_count(other) > _mapped_count(best) else best


# -- reading a captured CGRAM ------------------------------------------------


def cgram_color(cgram: bytes, index: int) -> int:
    """The 15-bit colour CGRAM holds at ``index``, or ``-1`` past its end.

    A short CGRAM is a synthetic snapshot; refusing to map it beats raising out
    of the middle of a panel that is only trying to draw swatches.
    """
    return palettes.unpack(cgram, index * COLOR_SIZE)


def _cgram_colors(cgram: bytes, first: int, count: int) -> tuple[int, ...]:
    return tuple(cgram_color(cgram, first + n) for n in range(count))


def _mapped_count(found: list[int]) -> int:
    return sum(1 for offset in found if offset != UNMAPPED)


# -- putting an edit back on screen ------------------------------------------


def recolored(cgram: bytes, found: list[int], edits: palettes.Edits) -> bytes:
    """``cgram`` with every edit written into the entries that source it.

    The whole of the preview: a snapshot recoloured with this is a snapshot the
    existing renderers draw without knowing anything happened, because every one
    of them reads its colours out of the CGRAM it was handed and nothing else.

    Returns ``cgram`` itself when no edit reaches it, so a caller can tell a
    real recolour from a redraw with nothing to do.
    """
    if not edits:
        return cgram
    at = {
        index * COLOR_SIZE: edits[offset]
        for index, offset in enumerate(found)
        if offset != UNMAPPED and offset in edits
    }
    if not at:
        return cgram
    out = bytearray(cgram)
    for byte, value in at.items():
        if byte + COLOR_SIZE > len(out):
            continue
        palettes.pack(out, byte, value)
    return bytes(out)


def with_header_sets(
    cgram: bytes,
    blob: bytes,
    found: list[int],
    *,
    held: tuple[int, int, int],
    wanted: tuple[int, int, int],
    edits: palettes.Edits,
) -> bytes:
    """``cgram`` as it would be with the header naming the palette sets
    ``wanted`` -- background, foreground, sprite -- instead of ``held``.

    The three settings pick where in the file each set's twelve colours are
    read from, and nothing else: same runs, same CGRAM entries, another
    offset. So a set changed in the header dialog reaches the canvas without a
    level load, which is what lets "which of eight backgrounds" be answered by
    looking at the level rather than by loading it eight times.

    ``found`` is the provenance of the capture **under** ``held``, and an entry
    it could not account for is left alone: a level wearing a palette of its
    own does not read these sets at all, and writing them over its colours
    would show a level the game would never draw.

    ``edits`` are the palette document's changes to ``blob``, so a colour
    edited and not yet saved is the colour a set moved onto it shows -- the
    same bytes :func:`recolored` would put there.

    Returns ``cgram`` itself when the settings say the same thing, so a caller
    can tell a move from a redraw with nothing to do.
    """
    if held == wanted:
        return cgram
    palettes.check(blob)
    was = modelled(level_runs(*held))
    now = modelled(level_runs(*wanted))
    out = bytearray(cgram)
    moved = False
    for index, offset in enumerate(now):
        if offset == was[index] or found[index] != was[index]:
            continue
        byte = index * COLOR_SIZE
        if byte + COLOR_SIZE > len(out):
            continue
        palettes.pack(out, byte, edits.get(offset, palettes.color(blob, offset)))
        moved = True
    return bytes(out) if moved else cgram
