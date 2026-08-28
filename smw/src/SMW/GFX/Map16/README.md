# The Map16 tables

One file per table. Eight bytes per tile — four SNES tilemap entries, upper
left, lower **left**, upper right, lower right, in `TTTTTTTT YXPCCCTT` format.
`Banks/Bank0D.asm` includes these directly; nothing converts them.

| File | Tiles | Used by |
|---|---|---|
| `Global.bin` | `000`-`072`, `100`-`106`, `111`-`132` | every tileset |
| `GreenPipes.bin` | `133`-`13A` | every tileset |
| `Global2.bin` | `13B`-`152`, `16E`-`1FF` | every tileset |
| `Grassland.bin` | `073`-`0FF`, `107`-`110`, `153`-`16D` | tilesets 0, 7, 12 |
| `Castle.bin` | `073`-`0FF` | tileset 1, except PAL rev 1 |
| `Castle_PALRev1.bin` | `073`-`0FF` | tileset 1, PAL rev 1 |
| `Castle_Rest.bin` | `107`-`110`, `153`-`16D` | tileset 1, every version |
| `Rope.bin` | `073`-`0FF`, `107`-`110`, `153`-`16D` | tilesets 2, 6, 8 |
| `Underground.bin` | `073`-`0FF`, `107`-`110`, `153`-`16D` | tilesets 3, 9, 10, 11, 14 |
| `GhostHouse.bin` | `073`-`0FF`, `107`-`110`, `153`-`16D` | tilesets 4, 5, 13 |
| `SlopedPipeTiles.bin` | `1C4`-`1C7`, `1EC`-`1EF` | tilesets 0 and 7 only |
| `VariableColorPipes.bin`, `YellowPipes.bin`, `PurplePipes.bin` | scroll-swapped pipe blocks | every tileset |
| `Backgrounds.bin` | 512 background tiles | Layer 2 backgrounds |

**A tile number alone does not name a file.** `073`-`0FF`, `107`-`110` and
`153`-`16D` are tileset-specific and everything else is shared, so the same
number is different bytes in a castle than in a grassland; and tilesets 0 and 7
repoint `1C4`-`1C7` / `1EC`-`1EF` at `SlopedPipeTiles.bin` at level load.
`smw_tools.map16.table_offset(tile, tileset)` is that arithmetic, and
[`docs/smw/map16.md`](../../../../../docs/smw/map16.md) is where the split comes
from.

**Editing a shared table changes every level in the game.** Only the five
tileset tables are local to a group of levels.

## Lunar Magic

Lunar Magic interchanges Map16 data as one `.map16` container. Produce one, edit
it there, and read it back:

```bash
uv run smw map16 pack   tmp/vanilla.map16      # tables -> container
uv run smw map16 unpack tmp/edited.map16       # container -> tables
```

`pack` is exact — over the tables as committed it reproduces the container this
directory was split from, byte for byte, which `smw/tests/test_map16.py` pins.
The container is 651,760 bytes against these files' 15,272: the rest is an
acts-like table the vanilla engine has no concept of, ten redundant copies of
the resolved tileset views, and 251 empty pages. All of it is reconstructed from
constants, which is why it is not committed.
