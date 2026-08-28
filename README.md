# Shiny Mushroom

**Shiny Mushroom** is a cross-platform Super Mario World all-in-one editor.

If you run into issues or have questions. Submit a github issue or reach out to me
on Discord through the https://romhack.ing/ Discord server.

Shiny Mushroom is built on Python + Qt (PySide6) and runs on Windows, macOS, and Linux.

## Features

- **Built from source** - ROMs are built from ASM source and binary files which
  can be overriden via each project's individual overlay. Level, ASM, graphics, etc
  changes are all stored as overridden or additional files local to the project.
- **Rendered via emulator** - The editor runs an emulator under the hood for all
  rendering. Changes in the editor are immediately applied and previewed.
- **Level editing** - full support for object, sprite, exits, and background editing.
- **Level metadata** - level header, secondary entrances, graphics/tilemaps/anim
  overrides, and more.
- **World map** - Layer 1 and Layer 2 tiles, events, walking paths, warps, exits, 
  and sprites, all editable.
- **Graphics and palettes** - edit graphics via PNG and clipboard, edit palettes,
  and add custom graphics files.
- **Additional features** - expanded tables for levels, strings, graphics, and more.
  Per-tile levels for the overworld, and per-level graphics and palettes. Expand
  cartridge size.
- **SA-1 Pack** - full support for the SA-1 pack across all features. When creating
  a new project select either vanilla or SA-1 pack as the base.
- **Patches** - Write/import custom patches and store them in a list that gets automatically
  applied on build. Patches can use symbols instead of raw memory locations.
- **Playtesting** - instant in-editor level and overworld testing with spawn position
  override

## Getting Started

### Install

Grab the build for your platform from the [Releases page](https://github.com/YoriKv/shiny-mushroom/releases), unpack and run, no installer.

### First steps

1. **Supply a cartridge** - once, on first run. Graphics, music and samples
   are extracted and stored locall. Any of the 5 releases can work as a base.
2. **Create a new project** - a folder is created to store all of your modified files.
3. **Edit a level** - pick a level, click to select, drag to move, and use the
   Create panel to place objects and sprites.
4. **Test it** - `Ctrl+R` plays the level on the canvas with your edits in it.
5. **Save** - `Ctrl+S` writes the level into the project. `Ctrl+M` swaps the
   canvas to the world map and back.

Help -> Shortcuts (`F1`) to view a list of keyboard shortcuts.

## Thank You

Thanks to the following projects and people, for what this editor is built on
and for the accumulated community knowledge it represents.


- **[Yoshifanatic's SNES framework](https://github.com/Yoshifanatic1/SNES-ROM-Framework)** - the
  disassembly this tool is based on
- **[SMWDisX](https://github.com/IsoFrieze/SMWDisX)** by IsoFrieze and
  contributors - additional disassembly used for reference
- **[asar](https://github.com/RPGHacker/asar)** by Alcaro and the asar
  developers - the assembler every build runs
- **[SA-1 Pack](https://github.com/VitorVilela7/SMW-SA1-Pack)** by Vitor Vilela
  and contributors - what the SA-1 ROM base is built with, used with the
  author's permission
- **[MesenCE](https://github.com/nesdev-org/MesenCE)** by SourMesen and the Mesen
  contributors - the SNES core the editor drives
- **[SMW Central](https://www.smwcentral.net/)** - the community memory map and
  the documentation behind much of the commentary

## AI Use Disclaimer

This tool was created with the help of an AI coding agent. All of the code and
some of the tooltips are AI generated, but the design and other aspects of this
project are my own.
