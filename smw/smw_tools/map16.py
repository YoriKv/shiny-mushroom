"""The Map16 tables, and the Lunar Magic container they interchange through.

A Map16 tile is 8 bytes -- four SNES tilemap entries, upper left, lower left,
upper right, lower right. The ROM holds 512 of them per tileset, assembled from
two sources: a table shared by every tileset, and one of five tileset-specific
tables. `SMW_InitializeMap16Pointers` walks a bitmask to interleave them at
level load, which is what makes tiles `073`-`0FF`, `107`-`110` and `153`-`16D`
look different in a castle than in a grassland.

`smw/src/SMW/GFX/Map16/` holds one file per table, and `Bank0D.asm` includes
them directly. That is the editable form: a table is its own file, and a tile's
byte offset in it is plain arithmetic.

Lunar Magic interchanges Map16 data as a single `.map16` container -- 651,760
bytes, of which the ROM contains 15,272. The remainder is scaffolding: an
acts-like table the vanilla engine has no concept of, ten redundant copies of
the tileset views, and 251 empty pages. :func:`unpack` slices a container into
tables and :func:`pack` rebuilds one, so the tree carries the tables and a
container is produced on demand for anyone who wants to edit in Lunar Magic.

**`pack` is exact.** Rebuilding from the tables the tree ships reproduces the
container the tree was split from, byte for byte -- :data:`VANILLA_SHA1`, which
`test_map16.py` pins. Everything not in a table is a constant: the header, an
empty tile of `$1004`, and an acts-like table that is the identity up to tile
`$1FF` and `$130` above it.
"""

from __future__ import annotations

import hashlib

#: Bytes per Map16 tile: four 16-bit tilemap entries.
TILE = 8

#: Tiles per Lunar Magic page, and pages per container half.
PAGE = 256
_PAGES = 128

#: What Lunar Magic writes for a tile no one has defined.
EMPTY_TILE = bytes.fromhex("0410") * 4

#: Tiles below this act like themselves; from it up, like :data:`ACTS_DEFAULT`
#: -- the cement block -- until someone says otherwise.
_ACTS_IDENTITY = 512
ACTS_DEFAULT = 0x130

_HEADER = bytes.fromhex(
    "4c4d3136000101005302010000000000"
    "70000000400000001000000000100000"
    "00000000000000000201070000000000"
    "00000000000000000000000000000000"
    "4c756e6172204d6167696320322e3533"
    "2020a932303138204675536f59612020"
    "446566656e646572206f662052656c6d"
    "b000000000000800b000080000000100"
    "b000000000000400b000040000000400"
    "0000000000000000b000090000f00000"
    "b0f0090000010000b0f1090040000000"
)

# Container regions, from the table at header offset $70.
_TILEMAP = 0xB0  # pages $00-$7F
_BACKGROUNDS = 0x400B0  # pages $80-$FF
_ACTS_LIKE = 0x800B0  # 2 bytes per tile
_TILESET_VIEWS = 0x900B0  # 15 x 512 resolved tiles
_PIPES = 0x9F0B0  # the four pipe colour sets
_SLOPED_PIPES = 0x9F1B0
_SIZE = 0x9F1F0

#: SHA-1 of the container the tree's tables were split from.
VANILLA_SHA1 = "75258d07963381da3cda58610374b88921c47fe0"


def definitions_offset(page: int) -> int:
    """Where ``page``'s 256 definitions start in a container, eight bytes a
    tile: pages ``$00``-``$7F`` are the foreground half."""
    if not 0 <= page < _PAGES:
        raise ValueError(f"no foreground page {page:#04x}")
    return _TILEMAP + page * PAGE * TILE


def acts_like_offset(page: int) -> int:
    """Where ``page``'s 256 acts-like words start in a container, two bytes
    a tile, in the one table that covers every page."""
    if not 0 <= page < _PAGES * 2:
        raise ValueError(f"no page {page:#04x}")
    return _ACTS_LIKE + page * PAGE * 2


# -- what each table holds ---------------------------------------------------

#: Tile runs the shared tables cover, in the order the files store them.
SHARED_RUNS: dict[str, tuple[tuple[int, int], ...]] = {
    "Global": ((0x000, 0x073), (0x100, 0x107), (0x111, 0x133)),
    "GreenPipes": ((0x133, 0x13B),),
    "Global2": ((0x13B, 0x153), (0x16E, 0x200)),
}

#: Tile runs every tileset-specific table covers, in file order.
TILESET_RUNS: tuple[tuple[int, int], ...] = (
    (0x073, 0x100),
    (0x107, 0x111),
    (0x153, 0x16E),
)

#: FG/BG tileset -> the table that supplies its tileset-specific tiles.
#:
#: The object loader groups the same fifteen tilesets the same way, through a
#: dispatch table of its own -- :data:`smw_tools.object_names.TILESET_GROUPS`
#: is these rows, and its tests check them against the bank.
TILESET_TABLES: tuple[str, ...] = (
    "Grassland",  # 0
    "Castle",  # 1
    "Rope",  # 2
    "Underground",  # 3
    "GhostHouse",  # 4
    "GhostHouse",  # 5
    "Rope",  # 6
    "Grassland",  # 7
    "Rope",  # 8
    "Underground",  # 9
    "Underground",  # 10
    "Underground",  # 11
    "Grassland",  # 12
    "GhostHouse",  # 13
    "Underground",  # 14
)

#: Tiles the sloped-pipe block overrides, in tilesets 0 and 7 only.
SLOPED_PIPE_TILES: tuple[tuple[int, int], ...] = ((0x1C4, 0x1C8), (0x1EC, 0x1F0))

#: Every table, and where it comes from in a container.
TABLES: dict[str, tuple[tuple[int, int], ...]] = {
    "Global": ((0x980B0, 0x98448), (0x988B0, 0x988E8), (0x98938, 0x98A48)),
    "GreenPipes": ((0x98A48, 0x98A88),),
    "Global2": ((0x98A88, 0x98B48), (0x98C20, 0x990B0)),
    "SlopedPipeTiles": ((_SLOPED_PIPES, _SIZE),),
    "VariableColorPipes": ((_PIPES, _PIPES + 0x40),),
    "YellowPipes": ((_PIPES + 0x80, _PIPES + 0xC0),),
    "PurplePipes": ((_PIPES + 0xC0, _PIPES + 0x100),),
    "Grassland": ((0x90448, 0x908B0), (0x908E8, 0x90938), (0x90B48, 0x90C20)),
    "Castle": ((0x91448, 0x918B0),),
    "Castle_PALRev1": ((0x10B0, 0x1518),),
    "Castle_Rest": ((0x918E8, 0x91938), (0x91B48, 0x91C20)),
    "Rope": ((0x92448, 0x928B0), (0x928E8, 0x92938), (0x92B48, 0x92C20)),
    "Underground": ((0x93448, 0x938B0), (0x938E8, 0x93938), (0x93B48, 0x93C20)),
    "GhostHouse": ((0x94448, 0x948B0), (0x948E8, 0x94938), (0x94B48, 0x94C20)),
    "Backgrounds": ((_BACKGROUNDS, _BACKGROUNDS + PAGE * 2 * TILE),),
}


def table_offset(tile: int, tileset: int) -> tuple[str, int]:
    """Which table defines ``tile`` under ``tileset``, and its byte offset in it.

    The one piece of arithmetic an editor cannot avoid: the same tile number is
    a different eight bytes in a castle than in a grassland, and which file to
    write is decided by the run the number falls in rather than by the number
    alone.
    """
    if not 0 <= tile < 0x200:
        raise ValueError(f"Map16 tile {tile:#05x} is outside the ROM's $000-$1FF")
    if not 0 <= tileset < len(TILESET_TABLES):
        raise ValueError(f"no FG/BG tileset {tileset}")

    if tileset in (0, 7):
        seen = 0
        for start, stop in SLOPED_PIPE_TILES:
            if start <= tile < stop:
                return "SlopedPipeTiles", (seen + tile - start) * TILE
            seen += stop - start

    seen = 0
    for name, runs in SHARED_RUNS.items():
        for start, stop in runs:
            if start <= tile < stop:
                return name, (seen + tile - start) * TILE
            seen += stop - start
        seen = 0

    table = TILESET_TABLES[tileset]
    seen = 0
    for start, stop in TILESET_RUNS:
        if start <= tile < stop:
            # Tileset 1 keeps tiles 107-16D in its own file, so the two halves
            # of the castle table are addressed separately.
            if table == "Castle" and start != 0x073:
                return "Castle_Rest", (seen - 141 + tile - start) * TILE
            return table, (seen + tile - start) * TILE
        seen += stop - start
    raise AssertionError(f"tile {tile:#05x} fell through every run")


def _view(tables: dict[str, bytes], tileset: int) -> bytearray:
    """The 512 tiles a tileset resolves to -- shared and specific interleaved."""
    out = bytearray(PAGE * 2 * TILE)
    for name, runs in SHARED_RUNS.items():
        src, at = tables[name], 0
        for start, stop in runs:
            out[start * TILE : stop * TILE] = src[at : at + (stop - start) * TILE]
            at += (stop - start) * TILE

    table = TILESET_TABLES[tileset]
    specific = tables[table] + (tables["Castle_Rest"] if table == "Castle" else b"")
    at = 0
    for start, stop in TILESET_RUNS:
        out[start * TILE : stop * TILE] = specific[at : at + (stop - start) * TILE]
        at += (stop - start) * TILE
    return out


def unpack(container: bytes) -> dict[str, bytes]:
    """Slice a Lunar Magic container into one blob per table."""
    if container[:4] != b"LM16":
        raise ValueError("not an LM16 container")
    if len(container) != _SIZE:
        raise ValueError(f"container is {len(container)} bytes, expected {_SIZE}")
    return {
        name: b"".join(container[a:b] for a, b in runs) for name, runs in TABLES.items()
    }


def pack(tables: dict[str, bytes]) -> bytes:
    """Rebuild a Lunar Magic container from the tables.

    Every byte not in a table is a constant, so this is a total function of its
    input -- and on the tables the tree ships it reproduces :data:`VANILLA_SHA1`.
    """
    missing = set(TABLES) - set(tables)
    if missing:
        raise ValueError(f"missing tables: {', '.join(sorted(missing))}")

    out = bytearray(EMPTY_TILE * (_SIZE // TILE))
    out[: len(_HEADER)] = _HEADER

    # Pages $00-$01: the tileset 0 view, with the sloped-pipe block applied --
    # which is what a level using tileset 0 or 7 actually sees.
    view0 = _view(tables, 0)
    at = 0
    for start, stop in SLOPED_PIPE_TILES:
        span = (stop - start) * TILE
        view0[start * TILE : stop * TILE] = tables["SlopedPipeTiles"][at : at + span]
        at += span
    out[_TILEMAP : _TILEMAP + len(view0)] = view0

    # Page $02 is where PAL rev 1's castle table is parked.
    out[0x10B0 : 0x10B0 + len(tables["Castle_PALRev1"])] = tables["Castle_PALRev1"]

    backgrounds = tables["Backgrounds"]
    out[_BACKGROUNDS : _BACKGROUNDS + len(backgrounds)] = backgrounds

    acts = bytearray()
    for tile in range((_TILESET_VIEWS - _ACTS_LIKE) // 2):
        value = tile if tile < _ACTS_IDENTITY else ACTS_DEFAULT
        acts += value.to_bytes(2, "little")
    out[_ACTS_LIKE:_TILESET_VIEWS] = acts

    for tileset in range(len(TILESET_TABLES)):
        at = _TILESET_VIEWS + tileset * PAGE * 2 * TILE
        out[at : at + PAGE * 2 * TILE] = _view(tables, tileset)

    for offset, name in enumerate(
        ("VariableColorPipes", "GreenPipes", "YellowPipes", "PurplePipes")
    ):
        at = _PIPES + offset * 0x40
        out[at : at + 0x40] = tables[name]
    out[_SLOPED_PIPES:_SIZE] = tables["SlopedPipeTiles"]

    return bytes(out)


def container_sha1(container: bytes) -> str:
    return hashlib.sha1(container).hexdigest()
