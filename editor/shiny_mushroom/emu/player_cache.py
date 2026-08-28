"""The player capture, kept on disk between sessions.

What the player looks like is a property of the **cartridge**, not of the level
or of the session: his graphics and his palette come from the global graphics
files rather than from a level's tileset, which is why the editor captures him
once and keeps him for every level. Asking again next launch buys nothing and
costs a probe -- a savestate, a couple of frames of emulation and a trace, held
in front of the first level a person opens.

So a capture is filed under a key that names the cartridge it came from, and a
later launch over the same bytes reads it back instead. A different cartridge --
a rebuilt project, another base, another target -- is a different key and a
fresh capture, which is what makes this safe to keep: nothing here has to decide
whether an edit could have changed how he looks, because any edit that reaches
the ROM changes the key.

Qt-free and standard-library-only, like everything outside
:mod:`shiny_mushroom.ui`, and it never raises: a cache that cannot be read or
written is a capture that has to be taken again, which is the state the editor
was in anyway. **Where** the files go is the caller's to say -- see
:func:`~shiny_mushroom.project.cache_root`.
"""

from __future__ import annotations

import gzip
import hashlib
import logging
import os
import struct
from contextlib import suppress
from pathlib import Path

from shiny_mushroom.sprite_art import PlayerArt, SpriteTile

_log = logging.getLogger(__name__)

#: What a cache file starts with, and the format it promises. Bumped rather than
#: migrated: a stale file is one capture, and re-taking it costs less than any
#: migration would.
MAGIC = b"SMPLAYERART\x01"

#: One captured tile: two signed offsets, a tile number, its attribute byte and
#: whether it is 16x16. Little-endian and fixed-width, which is what makes the
#: file readable without a schema.
TILE = struct.Struct("<hhHBB")

#: How many captures to keep. A cartridge that is being rebuilt makes a new key
#: every build, so this is a bound on a directory that would otherwise grow by a
#: file per build -- the oldest go, and going costs a re-capture.
KEEP = 8

#: What a capture is named, under the cache directory.
SUFFIX = ".playerart"


def key_for(rom: Path, base_id: str | None, target_id: str | None) -> str:
    """A name for the capture of ``rom``, as this base and target.

    The cartridge's own bytes, because that is what decides how the player is
    drawn, plus the two ids, because the same image read through another base's
    addresses is another cartridge as far as the loader is concerned.

    Returns ``""`` when the ROM cannot be read, which the caller treats as "do
    not cache" -- the load itself will fail a moment later and say why.
    """
    digest = hashlib.sha256()
    digest.update(f"{base_id or ''}/{target_id or ''}\n".encode())
    try:
        with rom.open("rb") as image:
            for block in iter(lambda: image.read(1 << 20), b""):
                digest.update(block)
    except OSError as error:
        _log.debug("no player-art cache key for %s: %s", rom, error)
        return ""
    return digest.hexdigest()[:32]


def read(root: Path, key: str) -> PlayerArt | None:
    """The capture filed under ``key``, or ``None`` if there is not one.

    ``None`` covers every way this can go wrong -- no file, a truncated one, a
    file from another format version -- because they have the same answer: take
    the capture again.
    """
    if not key:
        return None
    path = root / f"{key}{SUFFIX}"
    try:
        raw = gzip.decompress(path.read_bytes())
    except FileNotFoundError:
        return None
    except (OSError, gzip.BadGzipFile, EOFError) as error:
        _log.debug("unreadable player-art cache %s: %s", path, error)
        return None
    art = _decode(raw)
    if art is None:
        _log.debug("player-art cache %s is not a capture this build reads", path)
        return None
    # Touched on every hit, so the pruning below drops the cartridge nobody has
    # opened for longest rather than the one captured longest ago. Housekeeping
    # is never worth an error on a path where the caller has what it came for.
    with suppress(OSError):
        os.utime(path)
    return art


def write(root: Path, key: str, art: PlayerArt) -> None:
    """File ``art`` under ``key``, and drop the oldest past :data:`KEEP`.

    Silent about failure by design: this is an optimisation on a capture the
    caller already has in hand, and a read-only or full data directory must not
    turn a loaded level into an error.
    """
    if not key or not art:
        # An empty capture is a probe that found nothing, and caching one would
        # make a bad run permanent -- see `SmwLevelLoader.capture_player_art`.
        return
    path = root / f"{key}{SUFFIX}"
    try:
        root.mkdir(parents=True, exist_ok=True)
        # Written beside and renamed, so a capture interrupted half way through
        # leaves no half file for the next launch to read.
        scratch = path.with_suffix(f"{SUFFIX}.part")
        scratch.write_bytes(gzip.compress(_encode(art)))
        scratch.replace(path)
    except OSError as error:
        _log.debug("could not file the player capture at %s: %s", path, error)
        return
    _prune(root)


def _encode(art: PlayerArt) -> bytes:
    parts = [MAGIC, struct.pack("<H", len(art.tiles))]
    parts += [
        TILE.pack(tile.x, tile.y, tile.tile, tile.attributes, int(tile.large))
        for tile in art.tiles
    ]
    parts += [
        struct.pack("<I", len(art.vram)),
        art.vram,
        struct.pack("<I", len(art.cgram)),
        art.cgram,
    ]
    return b"".join(parts)


def _decode(raw: bytes) -> PlayerArt | None:
    if not raw.startswith(MAGIC):
        return None
    at = len(MAGIC)
    try:
        (count,) = struct.unpack_from("<H", raw, at)
        at += 2
        tiles = []
        for _ in range(count):
            x, y, tile, attributes, large = TILE.unpack_from(raw, at)
            at += TILE.size
            tiles.append(SpriteTile(x, y, tile, attributes, bool(large)))
        memories = []
        for _ in range(2):
            (size,) = struct.unpack_from("<I", raw, at)
            at += 4
            if at + size > len(raw):
                return None
            memories.append(raw[at : at + size])
            at += size
    except struct.error:
        return None
    return PlayerArt(tuple(tiles), memories[0], memories[1])


def _prune(root: Path) -> None:
    """Keep the :data:`KEEP` most recently used captures and no more."""
    with suppress(OSError):
        held = sorted(root.glob(f"*{SUFFIX}"), key=lambda path: path.stat().st_mtime)
        for path in held[:-KEEP]:
            path.unlink(missing_ok=True)


__all__ = ["KEEP", "SUFFIX", "key_for", "read", "write"]
