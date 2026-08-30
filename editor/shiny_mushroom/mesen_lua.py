"""The warp script an external Mesen is handed alongside the cartridge.

Test Level Externally builds the project's cart and opens it in whatever
emulator is set (:mod:`shiny_mushroom.external_emulator`). That run boots to
the title screen, because nothing can drive a program the editor merely
launched -- **except in Mesen**, which takes a Lua script on its command line
and runs it against the machine. So this module writes one, and the row lands
in the level or on the world map being edited instead of at the title.

**It is the same choreography the editor's own test window uses**, moved from
Python driving a core it owns (:mod:`shiny_mushroom.emu.play`) to Lua driving
the one it started. Both write the same handful of work-RAM bytes and let the
game's own dispatcher do the rest; the differences are all in what a launched
emulator cannot be asked for:

- **It waits for the title screen rather than restoring a savestate.** The boot
  runs -- a few seconds of Nintendo logo -- and the script watches the game mode
  for it, since there is no state to restore and nothing to fast-forward with
  (Mesen's Lua has no speed control at all).
- **The fade is not wound forward.** Winding it is worth a halt and a start on a
  machine being driven for a picture; in a window somebody is watching, thirty
  frames of fade is what arriving in a level looks like.

What is generated is a *complete script per run*, values and all -- there is no
Lua library on disk for it to find, because the file is handed to a program
running under another OS half the time and a second path to translate is a
second thing to get wrong.

Qt-free and side-effect-free: it returns text. Where that text is written and
which emulator it is handed to is
:meth:`~shiny_mushroom.ui.window.testing.Testing.test_level_external`'s.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom.addresses import (
    GAME_MODE,
    INTRO_LEVEL_FLAG,
    MARIO_MAP,
    MODE_FADE_IN,
    MODE_IN_LEVEL,
    MODE_LOAD_SUBLEVEL,
    MOSAIC_MIRROR,
    SUBLEVELS_ENTERED,
    TITLE_MODES,
    Addresses,
)
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memtype import MemoryType
from shiny_mushroom.overworld_snapshot import (
    CURRENT_CHARACTER,
    MODE_OVERWORLD,
    MODE_PLAYER_SELECT,
    OW_SAVE_BUFFER,
    TWO_PLAYER_GAME,
    save_buffer,
)
from shiny_mushroom.rom_patches import (
    BRANCH_ALWAYS,
    BRANCH_CARRY_CLEAR,
    BRANCH_NOT_EQUAL,
    level_request_bytes,
    needs_direct_request,
)

__all__ = ["SCRIPT_NAME", "BranchNotTheGames", "level_script", "overworld_script"]

#: What the script is called on disk. One file per project, rewritten by every
#: run: Mesen's script window is titled after it, and a name that said which
#: level was in it would leave a folder of stale scripts behind.
SCRIPT_NAME = "test-warp.lua"

#: Mesen's Lua names for the memories a base's RAM can be in, plus the
#: cartridge. The Lua enum is ``MemoryType.h``'s member names with the first
#: letter lowered (``LuaApi.cpp``, where ``emu.memType`` is built), so this is
#: the same table :mod:`shiny_mushroom.memtype` keeps in ordinals -- said again
#: in the other vocabulary, because a script names them and a core numbers them.
LUA_MEMORY: dict[MemoryType, str] = {
    MemoryType.SNES_WORK_RAM: "snesWorkRam",
    MemoryType.SNES_SAVE_RAM: "snesSaveRam",
    MemoryType.SA1_INTERNAL_RAM: "sa1InternalRam",
    MemoryType.SNES_PRG_ROM: "snesPrgRom",
}


class BranchNotTheGames(ValueError):
    """The branch a level's request needs patched is not the game's byte."""


@dataclass(frozen=True, slots=True)
class _Write:
    """One byte, and the Mesen memory it goes in."""

    memory: str
    offset: int
    value: int

    def lua(self) -> str:
        return f'{{"{self.memory}", 0x{self.offset:06X}, 0x{self.value:02X}}}'


def _at(where: Addresses, offset: int, value: int) -> _Write:
    """One work-RAM write, through the base's own RAM map.

    :meth:`~shiny_mushroom.addresses.Addresses.at` is the only way this module
    names memory, for the reason that method exists: on a base with a
    coprocessor, ``$7E`` and an offset is a byte of the right number from the
    wrong memory.
    """
    memory, place = where.at(offset)
    return _Write(LUA_MEMORY[memory], place, value & 0xFF)


def level_script(level: int, rom: bytes, *, where: Addresses) -> str:
    """The script that walks the title screen into ``level``.

    The four bytes ``SpecifySublevelToLoad`` reads, plus the mosaic mirror:
    mode ``$13``'s fade in steps the mosaic *down* from wherever the mirror
    was left, and a run that never played mode ``$0F`` left it at ``$00`` --
    so without priming it the level comes up drawn at half resolution. Written
    here for :meth:`~shiny_mushroom.emu.play.PlaySession._load`'s reason,
    which has the whole of it.

    ``rom`` is the built cartridge, read for one byte: the levels whose request
    the stock routine cannot spell need a branch held open for the length of the
    load, and a cartridge whose branch is not the game's is one this cannot
    reason about. :class:`BranchNotTheGames` then, rather than a patch written
    blind over somebody's hack.
    """
    flag, map_index = level_request_bytes(level)
    stage = [
        _at(where, SUBLEVELS_ENTERED, 0),
        _at(where, INTRO_LEVEL_FLAG, flag),
        _at(where, MARIO_MAP, map_index),
        _at(where, MOSAIC_MIRROR, 0xF0),
    ]
    return _script(
        label=f"level {hexnum(level, 3)}",
        where=where,
        stage=stage,
        mode=MODE_LOAD_SUBLEVEL,
        done=(MODE_FADE_IN, MODE_IN_LEVEL),
        branch=_branch_patch(level, rom, where=where),
    )


def overworld_script(
    submap: int,
    x: int,
    y: int,
    tile_settings: bytes,
    event_flags: bytes,
    *,
    where: Addresses,
) -> str:
    """The script that walks the title screen onto the world map.

    A fabricated save buffer staged at ``$1F49`` and game mode ``$0A``, which
    is :meth:`~shiny_mushroom.emu.play.PlaySession._load_overworld`'s request
    and is made this way for its reasons: the player-select handler is what
    copies the buffer over the live tables, rebuilds the Layer 2 buffer nothing
    after file select ever rebuilds, and walks the real fade chain onto the map.

    All it wants is a confirm press, which the script holds and releases on the
    pad until the map is up -- and then puts the menu's own two answers back,
    since the cursor chose them: one player, as Mario.
    """
    staged = save_buffer(tile_settings, event_flags, submap, x, y)
    stage = [_at(where, OW_SAVE_BUFFER + at, byte) for at, byte in enumerate(staged)]
    stage.append(_at(where, INTRO_LEVEL_FLAG, 0))
    return _script(
        label="the world map",
        where=where,
        stage=stage,
        mode=MODE_PLAYER_SELECT,
        done=(MODE_OVERWORLD,),
        press=MODE_PLAYER_SELECT,
        after=[_at(where, TWO_PLAYER_GAME, 0), _at(where, CURRENT_CHARACTER, 0)],
    )


def _branch_patch(
    level: int, rom: bytes, *, where: Addresses
) -> tuple[int, int] | None:
    """``(offset, the game's byte)`` for a level whose request needs a branch
    held open, or ``None`` for the 438 that do not.

    The same two branches
    :meth:`~shiny_mushroom.emu.smw.CartSession.direct_level_numbers` holds, and
    the same refusal for a cartridge whose byte is not the game's: writing an
    unadjusted low byte to a routine that still subtracts ``$24`` loads a
    different level and says nothing about it.
    """
    if not needs_direct_request(level):
        return None
    address, opcode = (
        (where.level_override_branch, BRANCH_NOT_EQUAL)
        if level & 0xFF == 0x00
        else (where.level_adjust_branch, BRANCH_CARRY_CLEAR)
    )
    offset = where.offset(address)
    found = rom[offset] if 0 <= offset < len(rom) else None
    if found != opcode:
        raise BranchNotTheGames(
            f"level {hexnum(level, 3)} can only be asked for by patching the "
            f"branch at {hexnum(address, 6)}, which holds "
            f"{'nothing' if found is None else hexnum(found)} rather than the "
            f"game's {hexnum(opcode)} -- something has hijacked it"
        )
    return offset, opcode


def _script(
    *,
    label: str,
    where: Addresses,
    stage: list[_Write],
    mode: int,
    done: tuple[int, ...],
    press: int | None = None,
    after: list[_Write] | None = None,
    branch: tuple[int, int] | None = None,
) -> str:
    """One complete script: the run's own values, then the fixed flow.

    The flow is a three-state machine over the game mode -- wait for the title,
    stage and request, then finish when the game says it arrived -- and it is
    written once here rather than once per kind, because a level warp and a map
    warp differ only in what they stage and what they wait for.
    """
    memory, place = where.at(GAME_MODE)
    values = "\n".join(
        [
            f"local LABEL = {_lua_string(label)}",
            f"local GAME_MODE = {{{_lua_string(LUA_MEMORY[memory])}, 0x{place:06X}}}",
            f"local TITLE_MODES = {_lua_set(sorted(TITLE_MODES))}",
            f"local REQUEST = 0x{mode:02X}",
            f"local ARRIVED = {_lua_set(done)}",
            f"local PRESS_AT = {'nil' if press is None else f'0x{press:02X}'}",
            f"local BRANCH = {_lua_branch(branch)}",
            f"local STAGE = {_lua_writes(stage)}",
            f"local AFTER = {_lua_writes(after or [])}",
        ]
    )
    return f"{_HEADER}\n{values}\n{_FLOW}"


def _lua_string(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _lua_set(values) -> str:
    """A Lua set -- ``{[6] = true, ...}`` -- so the flow tests membership
    rather than walking a list once a frame."""
    return "{" + ", ".join(f"[0x{value:02X}] = true" for value in values) + "}"


def _lua_branch(branch: tuple[int, int] | None) -> str:
    if branch is None:
        return "nil"
    offset, original = branch
    return (
        f"{{offset = 0x{offset:06X}, open = 0x{BRANCH_ALWAYS:02X}, "
        f"shut = 0x{original:02X}}}"
    )


def _lua_writes(writes: list[_Write]) -> str:
    """A write list, wrapped so a staged save buffer is readable rather than
    one line of a hundred and forty entries."""
    if not writes:
        return "{}"
    lines, row = [], []
    for write in writes:
        row.append(write.lua())
        if len(row) == 4:
            lines.append("  " + ", ".join(row) + ",")
            row = []
    if row:
        lines.append("  " + ", ".join(row) + ",")
    return "{\n" + "\n".join(lines) + "\n}"


#: What the script says about itself. Regenerated per run, so it says so.
_HEADER = """\
-- Shiny Mushroom's test warp, written by Test Level Externally.
--
-- Rewritten by every run and read only by the emulator it was handed to, so
-- editing it is not worth the trouble -- the next run overwrites it.
--
-- It watches the game mode from the boot, stages the bytes the game's own
-- loader reads, and then leaves: nothing here runs once the level or the map
-- is up, and the pad is the player's throughout.
"""

#: The flow every warp shares. Reads its values off the locals above.
_FLOW = """\

local ROM = emu.memType.snesPrgRom
local state = "waiting"
local holding = false

local function memory(name)
  return emu.memType[name]
end

local function game_mode()
  return emu.read(GAME_MODE[2], memory(GAME_MODE[1]), false)
end

local function put(write)
  emu.write(write[2], write[3], memory(write[1]))
end

local function write_all(writes)
  for _, write in ipairs(writes) do put(write) end
end

-- The request. The branch, where one is in the way, is open only across the
-- load: the image is the one being played afterwards, and a permanent BRA
-- there is a game that can never enter a level from the map.
local function request()
  if BRANCH then emu.write(BRANCH.offset, BRANCH.open, ROM) end
  write_all(STAGE)
  emu.write(GAME_MODE[2], REQUEST, memory(GAME_MODE[1]))
  state = "warping"
end

local function arrive()
  if BRANCH then emu.write(BRANCH.offset, BRANCH.shut, ROM) end
  write_all(AFTER)
  state = "done"
  emu.displayMessage("Shiny Mushroom", "Warped to " .. LABEL)
end

local function on_frame()
  if state == "done" then return end
  local mode = game_mode()
  if state == "waiting" then
    if TITLE_MODES[mode] then request() end
  elseif ARRIVED[mode] then
    arrive()
  end
end

-- The confirm press the player-select menu waits for, held and released so an
-- edge lands whatever the emulation speed. Set on the poll rather than on the
-- frame, which is where Mesen applies it in time for the game to read it.
local function on_input()
  if state ~= "warping" or PRESS_AT == nil then return end
  if game_mode() == PRESS_AT then
    holding = not holding
    emu.setInput({start = holding}, 0, 0)
  elseif holding then
    holding = false
    emu.setInput({start = false}, 0, 0)
  end
end

emu.addEventCallback(on_frame, emu.eventType.endFrame)
emu.addEventCallback(on_input, emu.eventType.inputPolled)
"""
