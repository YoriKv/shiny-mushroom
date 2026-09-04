"""The patches that carry the editor's held work into a cartridge image.

**This is the seam an in-memory edit crosses.** Nothing the editor changes is
written to a file to be seen: a test run, and a level the open project has
already saved, both reach the emulator by patching its own copy of the
cartridge, which costs a level load rather than an assembler pass. Every future
kind of edit joins here.

Byte arithmetic over an image, a document and a project -- no Qt, so the whole
seam is testable without standing a window up. What could not be patched is
reported through the ``status`` and ``note`` callbacks the window hands in,
rather than being decided here: whether a skipped part is worth a status
message is the window's business, and this module's is which parts they are.
"""

from __future__ import annotations

import re
from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass, fields, replace
from typing import TYPE_CHECKING

from shiny_mushroom import custom_tiles, level_graphics, palettes
from shiny_mushroom.addresses import LAYER2_IS_BACKGROUND
from shiny_mushroom.header import HEADER_SIZE
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer2_table import Layer2Entry, Layer2TableError
from shiny_mushroom.layer3 import REGION_IDS as LAYER3_REGIONS
from shiny_mushroom.lunar_magic import REGION_IDS as LUNAR_MAGIC_REGIONS
from shiny_mushroom.map16 import Map16Tables
from shiny_mushroom.overworld import (
    destroy_sections,
    exit_sections,
    placement_tables,
    silent_sections,
    swap_sections,
    warp_sections,
)
from shiny_mushroom.project import ProjectError, forget_readings, scanning_once
from shiny_mushroom.project_overworld import OVERWORLD_PARTS
from shiny_mushroom.rom_patches import (
    extra_byte_counts,
    graphics_patch,
    header_patch,
    layer1_base,
    layer2_background_base,
    layer2_background_patch,
    layer2_entry_patch,
    layer2_level_patch,
    layer3_patch,
    layer3_tables,
    level_graphics_patch,
    level_graphics_rows,
    level_graphics_table_patch,
    level_patch,
    lunar_magic_patch,
    lunar_magic_tables,
    object_stream,
    overworld_patches,
    secondary_entrance_tables,
    secondary_header_patch,
    secondary_header_tables,
    sprite_base,
    sprite_stream,
)
from shiny_mushroom.secondary_entrances import REGION_IDS as ENTRANCE_REGIONS
from shiny_mushroom.secondary_header import REGION_IDS as SECONDARY_REGIONS
from smw_tools import graphics, packed
from smw_tools.asm_codec import AsmRegionError
from smw_tools.asm_regions import REGIONS, FixedTables, PathExits

if TYPE_CHECKING:
    from pathlib import Path

    from shiny_mushroom.addresses import Addresses
    from shiny_mushroom.edit import History, Level
    from shiny_mushroom.overworld import WorldMap
    from shiny_mushroom.project import Project
    from smw_tools.symbols import SymbolTable

#: Told what could not be patched, and how long to leave it on screen.
Status = Callable[[str, int], None]

#: Told *which* parts the image could not be made to carry, by name. The
#: standing half of the same report: :data:`Status` is a line that scrolls away
#: while a test window is opening over it, and this is what is still true
#: afterwards -- see
#: :meth:`~shiny_mushroom.ui.main_window.MainWindow._note_skipped`.
Skipped = Callable[[list[str]], None]

#: How long a "the cartridge's own is showing instead" note stays up.
NOTE_MS = 8000

#: The parts this module can fail to carry, by the name a status line, the
#: test window's notice and the project's build-needed reading all show. Each
#: reads after "the run shows the cartridge's own". The world map's names come
#: from :func:`~shiny_mushroom.rom_patches.overworld_patches`, which has several.
LAYER2_BACKGROUND = "Layer 2 background"
LAYER2_OBJECTS = "Layer 2 objects"
LEVEL_GRAPHICS = "level graphics"
LAYER2_POINTER = "Layer 2 pointer"

#: Which asm section each part of the overworld's model is written into, by the
#: name :class:`WorldParts` holds the part under. One flat image each.
_SECTIONS = {
    "directions": "overworld_level_directions",
    "level_events": "overworld_level_events",
    "level_names": "overworld_level_names",
    "translevel_levels": "overworld_translevel_levels",
    "subs": "overworld_event_layer1_locations",
    "sprite_disable": "overworld_sprite_submap_disable",
}

#: And the parts that are several sections of one model, with the function that
#: cuts the model into them, in the sections' order.
_CUT_SECTIONS = {
    "warps": (
        (
            "overworld_warp_trigger_columns",
            "overworld_warp_trigger_rows",
            "overworld_warp_landings_x",
            "overworld_warp_landings_y",
        ),
        warp_sections,
    ),
    "exits": (
        (
            "overworld_exit_triggers",
            "overworld_exit_landings",
            "overworld_exit_landing_cells",
        ),
        exit_sections,
    ),
    "silent": (
        (
            "overworld_silent_tiles",
            "overworld_silent_layers",
            "overworld_silent_locations",
            "overworld_silent_tile_numbers",
        ),
        silent_sections,
    ),
    "destroy": (
        (
            "overworld_destroy_before",
            "overworld_destroy_top",
            "overworld_destroy_bottom",
            "overworld_destroy_locations",
            "overworld_destroy_events",
        ),
        destroy_sections,
    ),
    "swaps": (
        (
            "overworld_event_layer1_from",
            "overworld_event_layer1_to",
        ),
        swap_sections,
    ),
}


#: The parts whose tables grow -- their scans follow their rows -- by the
#: name a skipped one is reported under. A grown table cannot be patched in
#: place: its sections would run into the labels after them, which `where`
#: still places where the build put them, so a part that is not the
#: cartridge's own count is left to a build like an outgrown stream.
_GROWN_PARTS = {
    "silent": "silent tiles",
    "swaps": "substitution pairs",
    "destroy": "destroyed tiles",
    "warps": "warp tables",
    "exits": "path exits",
}

#: Bytes an entry per asm-section role, from the regions that write them --
#: what a section image's length is held to the cartridge's count by.
_ROLE_WIDTHS = {
    role: stride
    for region in REGIONS
    if isinstance(region, (FixedTables, PathExits))
    for role, stride in zip(region.sections, region.strides, strict=True)
}


#: A caller's held level document, as the patch it makes over ``rom``. Takes
#: what the assets already claimed of the free space, so a grown stream is
#: placed clear of them -- `MainWindow._level_document_patch` is the one
#: implementation.
Document = Callable[[Sequence[range]], Mapping[int, bytes]]


def claimed(patches: Mapping[int, bytes]) -> list[range]:
    """The runs of the image ``patches`` write, as what :func:`free_space`
    takes for ``taken`` -- so a relocation made later in the same gather is
    not handed bytes an earlier one already has."""
    return [range(at, at + len(run)) for at, run in patches.items()]


def layer(patches: Mapping[int, bytes], over: Mapping[int, bytes]) -> dict[int, bytes]:
    """``patches`` with every run of ``over`` written **over** it -- spliced
    where the two overlap, rather than replacing the key.

    A plain ``|`` is wrong for this gather and was silently wrong at level
    ``$000``: a whole secondary-header table is keyed at the table's own
    offset and level ``$000``'s single byte is keyed there too, so the union
    replaced 512 bytes of saved rows with one byte and dropped every other
    level's. The same collision waits for secondary entrance ``$00`` and for
    any future run that lands inside another, so the splice is the rule here
    rather than a special case for the two that are known.

    A run that lands wholly inside an earlier one keeps that run's key and
    length, which is what leaves a patched table readable as a table. Anything
    else -- a straddle, an overlap either way -- trims the earlier run back to
    the bytes the later one does not claim and adds the later one beside it.
    The result never invents a byte neither side had, and the later run always
    wins where they disagree.
    """
    out = dict(patches)
    for at, run in over.items():
        run = bytes(run)
        end = at + len(run)
        held = [
            (base, data)
            for base, data in out.items()
            if base < end and at < base + len(data)
        ]
        if len(held) == 1 and held[0][0] <= at and held[0][0] + len(held[0][1]) >= end:
            base, data = held[0]
            spliced = bytearray(data)
            spliced[at - base : end - base] = run
            out[base] = bytes(spliced)
            continue
        for base, data in held:
            del out[base]
            if base < at:
                out[base] = data[: at - base]
            if base + len(data) > end:
                out[end] = data[end - base :]
        out[at] = run
    return out


def _graphics_number(key: Path, folder: Path) -> int | None:
    """The file number a raw overlay key names, when it is a graphics file of
    the set in ``folder`` -- `GFXnn.bin` for the game's own numbers and the
    project's added ones alike -- and ``None`` for any other resource."""
    if key.parent != folder:
        return None
    match = _GRAPHICS_KEY.fullmatch(key.name)
    return None if match is None else int(match.group(1), 16)


_GRAPHICS_KEY = re.compile(r"GFX([0-9A-F]{2})\.bin")


def _unreported(parts: list[str]) -> None:
    """A :data:`Skipped` that says nothing, for a caller with nowhere to put
    the reading.

    A probe, a catalogue pass and a test's stand-in all gather patches without
    a window behind them to hold a standing note. Every caller that *has* one
    passes it: a reading no gather ever makes is a reading nothing ever clears,
    which leaves a fixed repoint reported as still needing a build.
    """


def as_built(sprites: bytes, cart: bytes, where: Addresses) -> bytes:
    """A held sprite stream wearing the header bits this base's build owns.

    The editor lays what the project holds over the cartridge and reads any
    difference as an edit a build has not yet re-placed. That is exact only
    while the build carries level data through untouched, and on a base whose
    build **rewrites** it the two disagree the moment they are both correct: on
    ``sa1``, the finalize pass writes sprite-memory index ``$08`` into 484 of
    the 512 levels on the image's way out (``Config/SpriteMemoryIndex.asm``,
    the walk SA-1 Pack's own patch makes), and the level files it built from still
    say what the console's game said. Compared byte for byte, every one of those
    levels reads as edited, and patching the "edit" back in undoes the pack --
    a level tested that way runs at the stock sprite allocation and drops
    everything past its tenth sprite.

    So the bits the base claims
    (:attr:`~smw_tools.bases.RomBase.sprite_header_build_owned`) are taken from
    the image and the rest of the stream is left alone. Zero on a base that
    rewrites nothing, where this is the identity and the comparison is the
    byte-for-byte one it always was.

    ``cart`` is the cartridge's own stream for the same level. An empty stream
    on either side is handed back unchanged: there is no header byte to take.
    """
    owned = where.sprite_header_build_owned
    if not owned or not sprites or not cart:
        return sprites
    return bytes([(sprites[0] & ~owned & 0xFF) | (cart[0] & owned)]) + sprites[1:]


def addressable(rom: bytes | None, where: Addresses) -> bool:
    """Whether the image in hand is a cartridge these offsets mean anything in.

    Everything the window reads out of a ROM is reached through the base's
    pointer tables, and the first of them is the Layer 1 table -- so an image
    too short to hold it is not a cartridge this file can follow. A byte map is
    one such image and so is the stub the suite's loader hands back, and the
    honest answer for both is to make no patches rather than to read off the
    end of a short file.

    Asked in the three places that build cartridge patches -- a test run, a
    project's saved level, and the catalogue probe -- and asked here rather than
    three times over, because the three had drifted into three different
    explanations of one rule.
    """
    if rom is None:
        return False
    return len(rom) > where.offset(where.layer1_pointers) + 3


# -- what the project has already saved --------------------------------------


def layer2_pointer_patch(
    project: Project | None,
    rom: bytes | None,
    level: int | None,
    where: Addresses,
    symbols: SymbolTable | None,
    note: Skipped,
) -> dict[int, bytes]:
    """The project's Layer 2 entry for this level, over the image's own table.

    The table names a *label*, and the entry is patched wherever the image's
    three bytes disagree with what that label resolves to -- which covers a
    repoint the image has not been built with, and equally a repoint *taken
    back* after a build carried it: the table says stock, the built image
    still says the repoint, and the difference is the patch either way.

    Two resolvers, in order of authority. The **symbol file** is the
    assembler's own record for the very image being patched, so it is asked
    first. Without one -- before a first build -- the label's address is read
    off the cartridge itself: every level still pointing at the same entry in
    both the stock table and the project's holds the label's three bytes in
    its own slot (:meth:`~shiny_mushroom.project.Project.layer2_pointer_donors`),
    so a repoint whose target has such a donor needs no build to preview at
    all. Donors that disagree with each other, or with the kind the table
    claims, mean the tables do not describe this image, and nothing is
    guessed.

    A repoint neither resolver can answer is one **the run will not show**, so
    it goes to ``note``; the level still loads, as whatever the cartridge
    says, until a build. Empty when the tables cannot be read at all.
    """
    if project is None or rom is None or level is None:
        return {}
    if not addressable(rom, where):
        return {}
    try:
        entry = project.layer2_table().entry(level)
        repointed = project.layer2_repoint(level) is not None
    except (Layer2TableError, ProjectError, OSError):
        return {}
    found = None if symbols is None else symbols.by_name.get(entry.label)
    if found is not None:
        note([])
        return layer2_entry_patch(
            rom, level, found.addr, background=entry.background, where=where
        )
    held = _donor_entry_bytes(project, rom, level, entry, where)
    if held is None:
        # Unresolvable, which only matters when it hides an edit: a stock
        # entry over an unbuilt cartridge is already the image's own.
        note([LAYER2_POINTER] if repointed else [])
        return {}
    note([])
    at = where.offset(where.layer2_pointers + level * 3)
    if len(rom) < at + 3 or bytes(rom[at : at + 3]) == held:
        return {}
    return {at: held}


def _donor_entry_bytes(
    project: Project,
    rom: bytes,
    level: int,
    entry: Layer2Entry,
    where: Addresses,
) -> bytes | None:
    """``entry``'s three pointer bytes as the cartridge's own table spells
    them, or ``None`` when the image cannot be trusted to say.

    The donors are the other levels still pointing at ``entry`` in both
    tables; ``level`` itself is left out because it is the slot being asked
    about. All of them must agree, and each must be the kind the table claims
    -- a background's bank byte is the ``$FF`` marker and nothing else's is --
    because one wrong answer means the tables and the image have parted
    company, and a guessed pointer draws a Layer 2 the cartridge does not
    have.
    """
    try:
        donors = project.layer2_pointer_donors(entry)
    except (Layer2TableError, ProjectError, OSError):
        return None
    seen: set[bytes] = set()
    for donor in donors:
        if donor == level:
            continue
        at = where.offset(where.layer2_pointers + donor * 3)
        if len(rom) < at + 3:
            return None
        held = bytes(rom[at : at + 3])
        if (held[2] == LAYER2_IS_BACKGROUND) != entry.background:
            return None
        seen.add(held)
    if len(seen) != 1:
        return None
    return next(iter(seen))


def saved_background_patch(
    project: Project | None,
    rom: bytes | None,
    level: int | None,
    where: Addresses,
    status: Status,
) -> dict[int, bytes]:
    """The project's saved Layer 2 background for this level, over the image's
    own stream -- the raw overlay's half of what :func:`all_patches` does for
    the streams. Empty when the level's background is not one the project
    has edited, and when the saved pattern's re-encoding no longer fits the
    shipped stream's slot -- the cartridge shows its own until a build re-places
    them.
    """
    if project is None or rom is None or level is None:
        return {}
    if not addressable(rom, where):
        return {}
    base = layer2_background_base(rom, level, where=where)
    if base is None:
        return {}
    try:
        key = project.background_key(rom, base)
        if key is None or key not in project.raw_edits():
            return {}
        raw = project.raw(key)
    except (ProjectError, OSError):
        return {}
    found = layer2_background_patch(rom, level, raw, where=where)
    if found is None:
        status(
            "The project's saved Layer 2 background has outgrown its run of "
            "ROM: shown from the cartridge until a rebuild",
            NOTE_MS,
        )
        return {}
    return found


def saved_graphics_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
    taken: Sequence[range] = (),
) -> dict[int, bytes]:
    """The project's edited graphics files, over the image's own streams.

    The raw overlay's other half: every `GFXnn.bin` the project holds for the
    set its target reads -- the game's own files and the ones the project
    added -- re-encoded and written into the image the way a grown level
    stream is: in place while it still fits the slot the image gave the file,
    and relocated into free space with the file's pointer repointed when it
    has grown (:func:`~shiny_mushroom.rom_patches.graphics_patch`, which also
    places a file added since the last build and sets its format byte). A
    file whose raw form still decodes from the image is skipped, so a
    project that touched a file and changed nothing patches nothing.
    Level-independent, since the tables are the game's: the same patch
    serves every level a load asks for.

    ``taken`` is whatever free runs the caller's other patches already claim;
    what this returns claims more, and the caller threads those on to the
    level relocator in turn, so two relocations in one load cannot collide.

    What could not be carried -- a grown file with no free run to move to, a
    grown `GFX32`/`GFX33`, which the boot-time load reaches by literal, a raw
    file of a length the game cannot decompress it to, an added file on a
    cartridge with no row for it -- is said through ``status`` with the
    placement's own reason and shown as the cartridge's own until a rebuild,
    exactly as an outgrown background is. A file the project cannot read is
    reported the same way and left alone.
    """
    if project is None or rom is None:
        return {}
    if not addressable(rom, where):
        return {}
    try:
        edited = project.raw_edits()
        if not edited:
            return {}
        directory = graphics.set_for(project.target_id)
        family = graphics.family_for_set(directory)
        first = graphics.FILE_NUMBERS[0]
        folder = project.graphics_key(first, project.target_id).parent
    except (ProjectError, graphics.GraphicsError, OSError):
        return {}
    patches: dict[int, bytes] = {}
    held = list(taken)
    refused: list[str] = []
    unreadable: list[str] = []
    for key in edited:
        number = _graphics_number(key, folder)
        if number is None:
            # A background, an overworld table, or another set's file --
            # each somebody else's patch, or no build's at all.
            continue
        name = f"GFX{number:02X}"
        try:
            raw = project.raw(key)
        except (ProjectError, packed.PackedError, OSError):
            unreadable.append(name)
            continue
        found = graphics_patch(rom, number, raw, family, taken=held, where=where)
        if found.reason is not None:
            refused.append(f"{name} {found.reason}")
            continue
        patches = layer(patches, found.patches)
        held.extend(claimed(found.patches))
    if refused:
        status(
            f"The project's saved {'; '.join(refused)}: shown from the "
            f"cartridge until a rebuild",
            NOTE_MS,
        )
    if unreadable:
        status(
            f"The project's saved {' and '.join(unreadable)} could not be read: "
            f"shown from the cartridge",
            NOTE_MS,
        )
    return patches


def saved_layer2_patch(
    project: Project | None,
    rom: bytes | None,
    level: int | None,
    where: Addresses,
    status: Status,
) -> dict[int, bytes]:
    """The project's saved Layer 2 *object stream* for this level, over the
    image's own -- the other kind of Layer 2, and the other half of what
    :func:`saved_background_patch` does for a background.

    Empty for a level whose Layer 2 is a background, for a tree that does not
    place the stream, and when the image already holds it. A saved stream that
    has grown and has nowhere to go says so and shows the cartridge's own,
    exactly as an outgrown background does.
    """
    if project is None or rom is None or level is None:
        return {}
    if not addressable(rom, where):
        return {}
    try:
        stream = project.layer2_stream(level)
    except (Layer2TableError, ProjectError, OSError, ValueError):
        return {}
    if stream is None:
        return {}
    try:
        return layer2_level_patch(rom, level, *stream, where=where)
    except ValueError as error:
        status(
            f"The project's saved Layer 2 for level {hexnum(level, 3)} could not be "
            f"loaded: {error}",
            NOTE_MS,
        )
        return {}


def _saved_table_patch(
    project: Project | None,
    rom: bytes | None,
    region_ids: Sequence[str],
    tables: Sequence[int],
    what: str,
    where: Addresses,
    status: Status,
    held_row: int | None = None,
) -> dict[int, bytes]:
    """The rows a project has saved for a group of fixed tables, over the
    image's own -- one asm region per table, patched whole.

    ``what`` names the group in the status message a reading failure earns;
    a failure abandons the whole group rather than patching part of it, an
    image carrying half a table being worse than one carrying none.

    ``held_row`` is the one row of every table in the group that a caller's
    **held document** speaks for, and it is left as the image has it -- so the
    document's own byte, measured against that image, is the byte the run
    boots. Without this the saved row would already be in place and a document
    that agrees with the *cartridge* would have nothing to patch, which is the
    one case where a held edit loses to a saved one.
    """
    if project is None or rom is None:
        return {}
    if not addressable(rom, where):
        return {}
    patches: dict[int, bytes] = {}
    for region_id, table in zip(region_ids, tables, strict=True):
        try:
            if not project.asm_region_edited(region_id):
                continue
            image = bytes(project.asm_rows(region_id)[0])
        except (AsmRegionError, ProjectError, OSError) as error:
            status(f"The project's saved {what} could not be read: {error}", NOTE_MS)
            return {}
        offset = where.offset(table)
        if held_row is not None and held_row < len(image):
            at = offset + held_row
            image = image[:held_row] + rom[at : at + 1] + image[held_row + 1 :]
        if rom[offset : offset + len(image)] != image:
            patches[offset] = image
    return patches


def saved_secondary_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
    held_level: int | None = None,
) -> dict[int, bytes]:
    """The project's saved secondary-header tables, over the image's own.

    Whole tables rather than one level's bytes, because a save is a fragment:
    the overlay carries every level's row, and a level entered through a
    screen exit reads its own entry off the same tables. Empty when nothing
    is saved or the image already holds the saved rows.

    ``held_level`` is the canvas level, where a held document speaks for it:
    its own byte of each table is left as the image has it and the document
    patches over that -- see :func:`_saved_table_patch`. Every *other* level's
    saved row still rides along, which is what a screen exit into one needs.
    """
    return _saved_table_patch(
        project,
        rom,
        SECONDARY_REGIONS,
        secondary_header_tables(where),
        "secondary header",
        where,
        status,
        held_row=held_level,
    )


def saved_lunar_magic_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
    held_level: int | None = None,
) -> dict[int, bytes]:
    """The project's saved Lunar Magic tables, over the image's own --
    :func:`saved_secondary_patch`'s rule for the four tables the
    ``lunar-magic-levels`` feature adds, and nothing on an image whose base
    has no such tables."""
    tables = lunar_magic_tables(where)
    if tables is None:
        return {}
    return _saved_table_patch(
        project,
        rom,
        LUNAR_MAGIC_REGIONS,
        tables,
        "Lunar Magic settings",
        where,
        status,
        held_row=held_level,
    )


def saved_layer3_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
    held_level: int | None = None,
) -> dict[int, bytes]:
    """The project's saved Layer 3 tables, over the image's own -- the Lunar
    Magic tables' rule, for the four the ``layer3-settings`` feature adds."""
    tables = layer3_tables(where)
    if tables is None:
        return {}
    return _saved_table_patch(
        project,
        rom,
        LAYER3_REGIONS,
        tables,
        "Layer 3 settings",
        where,
        status,
        held_row=held_level,
    )


def saved_secondary_entrances_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
) -> dict[int, bytes]:
    """The project's saved secondary-entrance tables, over the image's own.

    Whole tables, as the secondary header's are patched whole and for the
    same reason: the entrance a screen exit hands the loader is a row of the
    cartridge's table rather than anything the level being run carries, so a
    test run reaching one has to find the project's rows there. Empty when
    nothing is saved or the image already holds them.
    """
    return _saved_table_patch(
        project,
        rom,
        ENTRANCE_REGIONS,
        secondary_entrance_tables(where),
        "secondary entrances",
        where,
        status,
    )


def forget_saved() -> None:
    """Drop what was read of a project's folder: a window that has just been
    pointed at a project reads the tree as it is now, whatever was done to it
    while this one was looking elsewhere.

    The readings are the project's own
    (:func:`~shiny_mushroom.project.forget_readings`), kept against the write
    count -- which is exactly what cannot see a tree another program edited.
    """
    forget_readings()


def saved_level_graphics_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    status: Status,
) -> dict[int, bytes]:
    """The project's saved per-level graphics rows, over the image's own.

    The whole table rather than one level's row, as the secondary header
    is patched whole: a level entered through a screen exit reads its own
    row, and a row the project no longer holds -- deleted since the last
    build -- goes back to ``$FF``, so a run never dresses a level in
    graphics the project has taken away. Row by row, so what is patched is
    what differs. Empty where the image has no rows the game reads
    (:func:`~shiny_mushroom.rom_patches.level_graphics_rows`): the open level's
    own arm says so, once, rather than every load.

    Reading the rows means reading every level container, about 600 ms on
    the DrvFs a Windows checkout is under, and this runs on every redraw --
    so the reading is remembered against the project's write count
    (:func:`~shiny_mushroom.project.Project.level_graphics`) rather than
    taken again here.
    """
    if project is None or rom is None:
        return {}
    if not addressable(rom, where):
        return {}
    # Asked before the project is, since reading the rows means reading every
    # level container: an image with nowhere to patch is not worth the trip.
    if level_graphics_rows(rom, where=where) is None:
        return {}
    try:
        held = project.level_graphics()
    except (ProjectError, OSError) as error:
        status(
            f"The project's saved level graphics could not be read: {error}",
            NOTE_MS,
        )
        return {}
    return level_graphics_table_patch(
        rom,
        {level: held.get(level, b"") for level in range(level_graphics.LEVELS)},
        where=where,
    )


def map16_patch(
    held: Map16Tables | None,
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    symbols: SymbolTable | None,
    status: Status,
) -> dict[int, bytes]:
    """The Map16 tables the editor is working with, over the image's own.

    **The held tables win where there are any** -- saved or not, they are
    what the sheet shows, so they are what a picture and a test run have to
    agree with. The project's saved overlay answers when the Map16
    environment was never opened this session, and nothing answers when it
    was not and the project has no files of its own -- the ordinary case,
    which costs a directory look rather than fifteen file reads.
    :func:`world_map_patch`'s rule, and `MainWindow._world_parts`'s.

    In place and same-size, so nothing is claimed of the free space, and
    measured against the image rather than against stock, so a table put back
    to stock after a build that carried an edit is put back on the image too
    (:meth:`~shiny_mushroom.map16.Map16Tables.patches`).
    """
    if rom is None or not addressable(rom, where):
        return {}
    try:
        tables = held
        if tables is None:
            if project is None or not project.map16_edited:
                return {}
            tables = project.map16_tables()
        return tables.patches(rom, where, symbols)
    except (ProjectError, OSError, ValueError) as error:
        # Either source can be the one that would not load -- the held tables
        # are what answers when the environment has been opened -- so the
        # message names the tables rather than guessing where they came from.
        status(f"The Map16 tables could not be loaded: {error}", NOTE_MS)
        return {}


def custom_tiles_patch(
    held: bytes | None,
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    symbols: SymbolTable | None,
    status: Status,
) -> dict[int, bytes]:
    """The custom tiles' container the editor is working with, over the
    image's own two tables -- :func:`map16_patch`'s rule for the same kind
    of document: the held container wins where the Tilemap editor holds
    one, the project's saved file answers otherwise, and nothing answers
    where the project has none. Nothing on a cartridge without the feature,
    since the tables it would write are not there
    (:func:`shiny_mushroom.custom_tiles.patches`)."""
    if rom is None or not addressable(rom, where):
        return {}
    if where.custom_tiles_defs is None:
        return {}
    try:
        container = held
        if container is None:
            if project is None or not project.custom_tiles_edited:
                return {}
            container = project.custom_tiles()
        return custom_tiles.patches(container, rom, where, symbols)
    except (ProjectError, OSError, ValueError) as error:
        status(f"The custom tiles could not be loaded: {error}", NOTE_MS)
        return {}


def saved_assets_patch(
    project: Project | None,
    rom: bytes | None,
    where: Addresses,
    symbols: SymbolTable | None,
    status: Status,
    taken: Sequence[range] = (),
    map16: Map16Tables | None = None,
    custom: bytes | None = None,
) -> dict[int, bytes]:
    """The parts that belong to no *level* document -- the Map16 tables, the
    levels' graphics rows and the graphics files -- over the image's own.

    ``map16`` is the Map16 environment's held tables where it has any; the
    project's saved files answer otherwise (:func:`map16_patch`). The other
    two are saved-only because nothing holds them: the graphics dialog
    writes through to the overlay as it edits.

    Both doors into the emulator gather this: a level load with no held
    document (:func:`all_patches` without ``document``) and a picture refreshed
    for an edit or a test run (``MainWindow.test_patches``). A refresh that
    carried only the document would show the edit over the cartridge's *stock*
    graphics, and the tiles somebody repainted would come and go with every
    object moved.

    The Map16 patch is in place and claims nothing; the graphics may
    relocate, so they go last here and what they claim is what a caller has
    to keep its own relocations off (:func:`claimed`).
    """
    patches = map16_patch(map16, project, rom, where, symbols, status)
    patches = layer(
        patches, custom_tiles_patch(custom, project, rom, where, symbols, status)
    )
    patches = layer(patches, saved_level_graphics_patch(project, rom, where, status))
    return layer(
        patches,
        saved_graphics_patch(
            project, rom, where, status, taken=[*taken, *claimed(patches)]
        ),
    )


def all_patches(
    project: Project | None,
    rom: bytes | None,
    level: int | None,
    where: Addresses,
    symbols: SymbolTable | None,
    status: Status,
    *,
    document: Document | None = None,
    map16: Map16Tables | None = None,
    custom: bytes | None = None,
    held: Sequence[Mapping[int, bytes]] = (),
    note: Skipped = _unreported,
) -> dict[int, bytes]:
    """**Everything the editor knows, over the image, in one order.**

    Every door into the emulator comes through here -- a level load, a
    refresh after an edit, Test Level, Test World Map -- because they are all
    the same question: what does this cartridge have to hold for what the
    editor is showing to be true? They were six hand-spelled unions before,
    and they had drifted: a test run booted without any other level's saved
    secondary header, entrance or Layer 2, and a world-map run booted on
    stock Map16 tables.

    Two things genuinely differ between the doors, and they are the two
    parameters. ``document`` is the **canvas level's held document** where the
    caller has one -- given, it wins over the project's saved streams for that
    level, which is the whole rule this seam exists for; omitted, the saved
    streams answer, which is what a load of some *other* level wants. ``held``
    carries the patches the window builds out of its own documents -- the world
    map, the colours, a test run's entrance override -- appended last because
    each is over a table nothing above touches.

    **The held document wins by not being argued with**, rather than by being
    laid over an answer already given. Every arm of
    :func:`level_document_patch` measures against the cartridge and says
    nothing where the document and the image agree, so a saved Layer 2,
    background or secondary byte laid down *first* would still be booted by a
    document that had been edited back to what the cartridge says. So the
    canvas level's saved arms are withheld while a document speaks for them:
    its two Layer 2 arms entirely, and its own byte of each whole
    secondary-header table (:func:`saved_secondary_patch`). Every *other*
    level's saved rows ride along untouched, which is what a screen exit into
    one needs. The alternative -- measuring the document against the image *as
    patched so far* -- would mean handing this seam a rewritten image, and the
    document is a callback the window owns.

    **The order is the claim discipline.** The assets can relocate and so can
    a grown stream, so the files go down first and what they take of the free
    space is handed on, rather than the level being placed over it. Each step
    is spliced rather than unioned (:func:`layer`), so a later one-byte run
    inside an earlier whole table does not take the table's key with it.

    ``note`` is told what the run will not be able to show -- today the Layer 2
    repoint no symbol file and no donor can resolve. Every door passes it: a
    reading no gather makes is a reading nothing clears.
    """
    if rom is None:
        return {}
    if project is not None and level is not None and addressable(rom, where):
        with scanning_once():
            return _merged_patches(
                _project_patches(
                    project,
                    rom,
                    level,
                    where,
                    symbols,
                    status,
                    map16,
                    document,
                    note,
                    custom,
                ),
                held,
            )
    # Nothing to gather -- no project, or an image these addresses mean
    # nothing in -- but what the editor *holds* is still true of it: a
    # cartridge opened on its own is edited the same way, and only the saved
    # side has nowhere to read from.
    patches = dict(document(())) if document is not None else {}
    return _merged_patches(patches, held)


def _merged_patches(
    patches: dict[int, bytes], held: Sequence[Mapping[int, bytes]]
) -> dict[int, bytes]:
    for one in held:
        patches = layer(patches, one)
    return patches


def _project_patches(
    project: Project,
    rom: bytes,
    level: int,
    where: Addresses,
    symbols: SymbolTable | None,
    status: Status,
    map16: Map16Tables | None = None,
    document: Document | None = None,
    note: Skipped = _unreported,
    custom: bytes | None = None,
) -> dict[int, bytes]:
    """:func:`all_patches`' body, inside its one reading of the overlay."""
    # The pointer first: where the level's Layer 2 *points* decides what the
    # background patch beside it would even be about.
    patches = layer2_pointer_patch(project, rom, level, where, symbols, note)
    if document is None:
        # This level's saved Layer 2, for a door holding no document of it.
        # With a document, both arms are the document's to answer -- and it
        # can only answer against an image the saved ones have not already
        # written (see `all_patches`).
        patches = layer(
            patches, saved_background_patch(project, rom, level, where, status)
        )
        patches = layer(patches, saved_layer2_patch(project, rom, level, where, status))
    patches = layer(
        patches,
        saved_secondary_patch(
            project,
            rom,
            where,
            status,
            # The canvas level's own byte of each table, likewise.
            held_level=None if document is None else level,
        ),
    )
    patches = layer(
        patches, saved_secondary_entrances_patch(project, rom, where, status)
    )
    patches = layer(
        patches,
        saved_lunar_magic_patch(
            project,
            rom,
            where,
            status,
            held_level=None if document is None else level,
        ),
    )
    patches = layer(
        patches,
        saved_layer3_patch(
            project,
            rom,
            where,
            status,
            held_level=None if document is None else level,
        ),
    )
    # The assets before the streams: both can relocate, and what the files
    # claim of the free space is handed on so the level is not placed over it.
    patches = layer(
        patches,
        saved_assets_patch(
            project,
            rom,
            where,
            symbols,
            status,
            taken=claimed(patches),
            map16=map16,
            custom=custom,
        ),
    )
    if document is not None:
        # The held document is this level as the editor has it, saved or not,
        # so the project's saved streams for it are beside the point.
        return layer(patches, document(claimed(patches)))
    streams = project.level_streams(level)
    if streams is None:
        return patches
    layer1, sprites = streams
    try:
        base = layer1_base(rom, level, where=where)
        held = sprite_stream(
            rom,
            sprite_base(rom, level, where=where),
            extra_byte_counts(rom, where=where),
        )
        # What the build set for itself is the cartridge's answer, not this
        # file's -- otherwise every level the build rewrote reads as edited.
        sprites = as_built(sprites, held, where)
        if (
            layer1[HEADER_SIZE:] == object_stream(rom, base + HEADER_SIZE)
            and sprites == held
        ):
            if layer1[:HEADER_SIZE] == rom[base : base + HEADER_SIZE]:
                return patches
            return layer(
                patches, header_patch(rom, level, layer1[:HEADER_SIZE], where=where)
            )
        return layer(
            patches,
            level_patch(
                rom,
                level,
                layer1[:HEADER_SIZE],
                layer1[HEADER_SIZE:],
                sprites,
                # The Layer 2 stream is already in `patches`, and its own claim
                # on free space with it -- so `level_patch` is not asked to
                # place it a second time, only to keep off what is placed
                # already.
                taken=claimed(patches),
                where=where,
            ),
        )
    except ValueError as error:
        # A cartridge whose tables this cannot follow, or one with nowhere to
        # put a stream that has grown. The level still loads -- as the
        # cartridge's own -- and saying so beats refusing to open it.
        status(
            f"The project's copy of level {hexnum(level, 3)} could not be "
            f"loaded: {error}",
            NOTE_MS,
        )
        return patches


# -- what is held but not saved ----------------------------------------------


def level_document_patch(
    doc: Level | None,
    history: History[Level] | None,
    rom: bytes | None,
    level: int,
    where: Addresses,
    status: Status,
    note: Skipped,
    has_background: bool,
    taken: Sequence[range] = (),
) -> dict[int, bytes]:
    """The level document's half of the seam, and which of its two halves moved
    decides how:

    - **A stream that has changed** takes the header with it, in one
      :func:`~shiny_mushroom.rom_patches.level_patch` call, because a stream that
      has *grown* has to be relocated and the header is what points at it. The
      two cannot be patched independently once that is on the table.
    - **A header on its own** -- a header edit, or a header the project has
      saved -- is five bytes at a known offset, so it can never disturb what
      comes after and needs none of the relocation machinery. Which also means
      it still works on a cartridge that machinery cannot read.

    The streams are compared against the **cartridge's own**, rather than
    against the history's base or the snapshot. The base already carries what
    the project has saved, so measuring against it hides exactly the levels a
    build has not yet re-placed -- and the document is the level, saved or not,
    so the image has to be made to hold it either way. The snapshot cannot
    answer at all: once an edit has been previewed it holds the edited streams
    too, so asking the picture would say no the moment it started saying yes.
    The base is the fallback for the one cartridge whose streams cannot be read
    back -- a hijacked sprite-bank site -- where
    :func:`~shiny_mushroom.rom_patches.level_patch` could not relocate a stream
    either.

    What the background arm could not carry goes to ``note`` as well as to
    ``status``, exactly as :func:`world_map_patch` reports its own skipped
    parts: the line scrolls away -- and on a test run it scrolls away behind
    the window that just opened over it -- while the reading has to stand for
    as long as the edit does.

    No entrance override, which is why a world-map run can share it. ``taken``
    is what the same gather has already claimed of the free space -- the
    project's relocated graphics -- so a grown stream is not placed over it.
    """
    if doc is None or rom is None:
        return {}
    if not addressable(rom, where):
        return {}
    patches: dict[int, bytes] = {}
    base = layer1_base(rom, level, where=where)
    streams = doc.streams()
    try:
        held = (
            object_stream(rom, base + HEADER_SIZE),
            sprite_stream(
                rom,
                sprite_base(rom, level, where=where),
                extra_byte_counts(rom, where=where),
            ),
        )
    except ValueError:
        held = None if history is None else history.base.streams()
    if held is not None:
        streams = (streams[0], as_built(streams[1], held[1], where))
    if streams != held:
        patches = layer(
            patches,
            level_patch(rom, level, doc.header, *streams, taken=taken, where=where),
        )
    elif doc.header != rom[base : base + HEADER_SIZE]:
        patches = layer(patches, header_patch(rom, level, doc.header, where=where))
    # The document's secondary-header bytes, where it carries them: four
    # one-byte entries in the bank $05 tables, always patchable in place.
    # Measured against the image exactly as the header is, so a document
    # matching what the project already patched in adds nothing.
    if doc.secondary:
        patches = layer(
            patches, secondary_header_patch(rom, level, doc.secondary, where=where)
        )
    # The four Lunar Magic bytes the same way, where the document carries
    # them and the image's base keeps the tables.
    if doc.lunar_magic:
        patches = layer(
            patches, lunar_magic_patch(rom, level, doc.lunar_magic, where=where)
        )
    # And the four Layer 3 bytes, on the same terms.
    if doc.layer3:
        patches = layer(patches, layer3_patch(rom, level, doc.layer3, where=where))
    # The background's own arm of the same seam; the comparison against the
    # cartridge is layer2_background_patch's own, which answers `{}` when the
    # image already decodes to the document's pattern. In place only: the
    # stream's address is shared by every level pointing at it, so an encoding
    # that has outgrown its slot is previewed as the cartridge's own -- said
    # here, since the edit is otherwise invisible in a test run.
    skipped: list[str] = []
    # The document's graphics row, where the image has rows the game reads:
    # eight bytes in place, measured against the image as the secondary
    # header is. A document with no row over an image whose row is set -- a
    # row deleted since the last build -- puts the row back to $FF. Without
    # the feature in the image there is nowhere to patch, and it is a *run*
    # that then cannot show the row: the canvas draws the row's files either
    # way, by writing them into the capture's VRAM
    # (`MainWindow._regraphicsed`), which needs nothing of the cartridge.
    if level_graphics_rows(rom, where=where) is not None:
        patches = layer(
            patches, level_graphics_patch(rom, level, doc.graphics, where=where)
        )
    elif not level_graphics.is_inherit(doc.graphics):
        skipped.append(LEVEL_GRAPHICS)
        status(
            f"Level {hexnum(level, 3)}'s own graphics are on the canvas but "
            f"not in a test run until a build: the cartridge has no per-level "
            f"graphics rows yet",
            NOTE_MS,
        )
    # The Layer 2 records' arm, for the levels whose Layer 2 is a level. Unlike
    # the background below it, this one can relocate -- so it is the one place
    # a preview quietly stops sharing the stream, which is what makes the
    # picture this level's rather than eight levels' at once.
    if doc.layer2_records:
        try:
            patches = layer(
                patches,
                layer2_level_patch(
                    rom,
                    level,
                    doc.layer2_header,
                    doc.layer2_stream(),
                    taken=claimed(patches),
                    where=where,
                ),
            )
        except ValueError as error:
            skipped.append(LAYER2_OBJECTS)
            status(f"Layer 2 could not be written into the image: {error}", NOTE_MS)
    if doc.layer2 and has_background:
        found = layer2_background_patch(rom, level, doc.layer2, where=where)
        if found is None:
            skipped.append(LAYER2_BACKGROUND)
            status(
                "The Layer 2 background no longer fits its run of ROM: test "
                "runs show the cartridge's own until a rebuild",
                NOTE_MS,
            )
        else:
            patches = layer(patches, found)
    note(skipped)
    return patches


# -- the game's colours ------------------------------------------------------


def palette_patch(
    blob: bytes | None,
    rom: bytes | None,
    where: Addresses,
) -> dict[int, bytes]:
    """The game's colours as the editor holds them, over the image's own.

    The document is three tables laid end to end
    (:mod:`shiny_mushroom.palettes`) and they are three separate runs of the
    cartridge, so this is **one flat patch per table** -- however many colours
    were changed, and whichever tables they were in. Nothing to relocate,
    nothing to price and nothing that can outgrow its slot: each table is a
    fixed run of `incbin` ranges. A table the document does not differ from is
    not patched at all.

    **The canvas does not need this.** A palette edit reaches the picture by
    recolouring the captured CGRAM in place
    (:func:`shiny_mushroom.palette_map.recolored`), which costs a redraw rather
    than a level load. This is for the **running game**: a test run boots the
    image, and the image has to be wearing the colours the editor is showing.

    Where each table is comes from ``where``, like everything else this module
    patches: a fact about the *target* and not only about the base -- the
    global table is ``$00B0A0`` on ``U`` and ``$00B040`` on ``J`` -- declared
    in :mod:`smw_tools.rom_tables` and overridden by the project's own build
    where there is one.
    """
    if blob is None or rom is None:
        return {}
    if not addressable(rom, where):
        return {}
    if len(blob) != palettes.BLOB_SIZE:
        return {}
    patches: dict[int, bytes] = {}
    for table in palettes.TABLES:
        try:
            at = where.offset(getattr(where, table.role))
        except ValueError:
            continue
        if at < 0 or at + table.size > len(rom):
            continue
        wanted = blob[table.at : table.end]
        if rom[at : at + table.size] != wanted:
            patches[at] = bytes(wanted)
    return patches


def palette_document(rom: bytes | None, where: Addresses) -> bytes | None:
    """The palette document a cartridge image is wearing, or ``None`` where it
    cannot be read for one.

    The inverse of :func:`palette_patch`: each table read from wherever this
    target put it, laid out in the order the document holds them. What the
    editor measures a capture against, and what a colour it has not edited
    comes from.
    """
    if rom is None or not addressable(rom, where):
        return None
    out = bytearray()
    for table in palettes.TABLES:
        try:
            at = where.offset(getattr(where, table.role))
        except ValueError:
            return None
        found = rom[at : at + table.size]
        if len(found) != table.size:
            return None
        out += found
    return bytes(out)


def palette_over(
    document: bytes, patches: Mapping[int, bytes], where: Addresses
) -> bytes:
    """``document`` with every table ``patches`` carries written into it.

    What a load booted, table by table: a run that recoloured a boss fade
    carries that table and nothing else, so the other two are still whatever
    the document already said. A patch of the wrong size for the table at that
    address is not one of ours and is left alone.
    """
    if len(document) != palettes.BLOB_SIZE:
        return document
    out = bytearray(document)
    for table in palettes.TABLES:
        try:
            at = where.offset(getattr(where, table.role))
        except ValueError:
            continue
        found = patches.get(at)
        if found is not None and len(found) == table.size:
            out[table.at : table.end] = found
    return bytes(out)


# -- the overworld -----------------------------------------------------------


@dataclass(frozen=True)
class WorldParts:
    """The overworld's tables as some source holds them, each ``None`` where
    that source has nothing of its own to say.

    Gathered from the world map mode when it has ever been opened -- saved or
    not, what is on the canvas is what a test run must agree with -- and from
    the project's saved overlay otherwise.
    """

    #: Every field is named for the :class:`~shiny_mushroom.overworld.WorldMap`
    #: attribute it carries, which is also the keyword
    #: :meth:`~shiny_mushroom.project.Project.save_world_map` takes it as and
    #: the :class:`~shiny_mushroom.project_overworld.OverworldPart` name for the asm
    #: ones. One spelling, so :func:`world_parts_from_map` needs no table of
    #: its own and another part is a field here and a field there.
    tiles: bytes | None = None
    layer2: bytes | None = None
    stamps: object | None = None
    stamp_props: object | None = None
    sprites: object | None = None
    directions: bytes | None = None
    level_events: bytes | None = None
    level_names: object | None = None
    translevel_levels: bytes | None = None
    events: object | None = None
    silent: object | None = None
    destroy: object | None = None
    subs: bytes | None = None
    swaps: bytes | None = None
    warps: object | None = None
    exits: object | None = None
    sprite_disable: bytes | None = None


def world_parts_from_map(held: WorldMap) -> WorldParts:
    """The overworld parts as the world map mode holds them.

    A part the document does not carry reads as empty, which is the same
    "nothing of its own to say" a ``None`` here means, so the two shapes line
    up field for field -- see :class:`WorldParts`. The two that do not are the
    two whose forms differ: the Layer 1 tilemap is never absent, and the
    sprite-disable rows are numbers in the document and bytes in a patch.
    """
    return WorldParts(
        **{
            field.name: getattr(held, field.name) or None
            for field in fields(WorldParts)
        }
        | {"tiles": held.tiles, "sprite_disable": bytes(held.sprite_disable)}
    )


def world_parts_from_project(
    project: Project | None, note: Skipped = _unreported
) -> WorldParts:
    """The overworld parts the project has saved, for a map whose mode was
    never opened this session.

    Each part is read on its own and left ``None`` where it will not read: a
    project can carry an edited tilemap and an unreadable stamp sheet, and the
    half that reads is still worth patching in. The asm regions are each their
    own fragment and read the same way, one at a time; ``note`` is told which
    of them would not read -- see :func:`_asm_parts`.
    """
    if project is None or not project.overworld_edited:
        # Said rather than skipped: a gatherer that finds nothing has to clear
        # its own reading, or a fragment fixed by hand stays reported.
        note([])
        return WorldParts()
    parts = WorldParts()
    try:
        parts = replace(parts, tiles=project.overworld_tiles())
    except (ProjectError, OSError):
        pass
    try:
        parts = replace(parts, layer2=project.overworld_layer2())
    except (ProjectError, packed.PackedError, OSError):
        pass
    try:
        parts = replace(
            parts,
            stamps=project.overworld_stamps(),
            stamp_props=project.overworld_stamp_props(),
        )
    except (ProjectError, packed.PackedError, OSError):
        parts = replace(parts, stamps=None, stamp_props=None)
    try:
        parts = replace(parts, sprites=project.overworld_sprites())
    except (ProjectError, OSError):
        pass
    return replace(parts, **_asm_parts(project, note))


def _asm_parts(project: Project, note: Skipped = _unreported) -> dict[str, object]:
    """The overworld tables the project keeps as edited asm regions.

    Which tables those are, and how each region's model reads back as the form
    :class:`WorldParts` holds, is
    :data:`~shiny_mushroom.project_overworld.OVERWORLD_PARTS` -- the same table the save
    writes them through, so a part cannot be saveable and unpreviewable.

    **Each region is read on its own**, because each one is its own file: the
    parts are as many fragments under ``overworld/tables/``, and one of them
    hand-edited past the emitter's grammar says nothing about the others.
    A part that will not read is dropped and *named* through ``note`` rather
    than silently left empty -- a build assembles the fragment whether or not
    the editor can read it, so "needs a build to preview" is exactly true of
    it, and that is the reading :data:`Skipped` feeds.
    """
    found: dict[str, object] = {}
    unreadable: list[str] = []
    for part in OVERWORLD_PARTS:
        if not project.asm_region_edited(part.region):
            continue
        try:
            found[part.name] = part.from_model(project.asm_rows(part.region))
        except (ProjectError, AsmRegionError, OSError):
            unreadable.append(part.region)
    note(unreadable)
    return found


def _asm_sections(
    parts: WorldParts, where: Addresses
) -> tuple[dict[str, bytes], list[str]]:
    """The parts that are written as asm sections, and the names of any that
    have outgrown the room the image gives them."""
    sections: dict[str, bytes] = {}
    unpatchable: list[str] = []
    for name, role in _SECTIONS.items():
        held = getattr(parts, name)
        if held is None:
            continue
        if role not in where.roles:
            # A feature's own table over a cartridge without the feature --
            # the image has no such table to patch, so the part waits for the
            # build that gives it one.
            unpatchable.append(_GROWN_PARTS.get(name, name.replace("_", " ")))
            continue
        sections[role] = held
    for name, (roles, cut) in _CUT_SECTIONS.items():
        model = getattr(parts, name)
        if model is None:
            continue
        images = dict(zip(roles, cut(model), strict=True))
        if name in _GROWN_PARTS and any(
            len(image) != where.counts[role] * _ROLE_WIDTHS[role]
            for role, image in images.items()
        ):
            # Grown or shrunk past what the cartridge was built with: the
            # table's labels are where the build put them, and an image of
            # another length patched under them would write over its
            # neighbours -- or leave the scan reading stale rows.
            unpatchable.append(_GROWN_PARTS[name])
            continue
        sections.update(images)
    if parts.events is not None:
        # Unpadded is fine here: the pointer table bounds every read, so stale
        # entry bytes past the new table are unreachable -- the same argument
        # the compressed streams make below.
        entries, pointers = placement_tables(parts.events)
        room = where.offset(where.overworld_event_pointers) - where.offset(
            where.overworld_event_tile_entries
        )
        if len(entries) <= room:
            sections["overworld_event_tile_entries"] = entries
            sections["overworld_event_pointers"] = pointers
        else:
            unpatchable.append("event stamp placements")
    return sections, unpatchable


def world_map_patch(
    parts: WorldParts,
    rom: bytes | None,
    where: Addresses,
    status: Status,
    note: Skipped,
) -> dict[int, bytes]:
    """The world map as the editor holds it, over the image's own tables.

    The arithmetic is :func:`~shiny_mushroom.rom_patches.overworld_patches`'; what
    is left here is gathering the parts and saying which of them, if any, could
    not be previewed without a build.
    """
    if rom is None or not addressable(rom, where):
        return {}
    sections, unpatchable = _asm_sections(parts, where)
    if (
        parts.tiles is None
        and parts.layer2 is None
        and parts.stamps is None
        and parts.stamp_props is None
        and parts.sprites is None
        and not sections
        and not unpatchable
    ):
        # Nothing is edited, so nothing can need a build.
        note([])
        return {}
    patches, skipped = overworld_patches(
        rom,
        tiles=parts.tiles,
        layer2=parts.layer2,
        stamps=parts.stamps,
        stamp_props=parts.stamp_props,
        sprites=parts.sprites,
        asm_sections=sections or None,
        where=where,
    )
    skipped = unpatchable + skipped
    note(skipped)
    if skipped:
        status(
            f"The test run shows the cartridge's {' and '.join(skipped)}: the "
            f"edit has outgrown its run of ROM. Rebuild and open the built "
            f"image to see it.",
            NOTE_MS,
        )
    return patches
