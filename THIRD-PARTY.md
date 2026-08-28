# Third-party components in Shiny Mushroom

Shiny Mushroom is GPL-3.0-only. Its own source — including the scripts that build
every binary below — is the repository this release was published from; the
release workflow stamps the exact URL and tag at the bottom of this file.

This file is the "clear directions" GPLv3 section 6d asks for: it says, next to
the object code, where the corresponding source for each bundled component is.
It ships inside the released application alongside `LICENSE`.

It covers the **editor release** only. The disassembly under `smw/` is source
and is never released as a binary -- the editor assembles a cartridge from it,
on the machine it runs on, out of assets the person extracted from a cartridge
they own. The *assembler* that does it is bundled, and is listed below; the
emulator `smw play` launches on a developer's machine is not, and is not.

*This is a record of what we ship and where its source is, written by the
maintainers. It is not legal advice.*

## MesenCore

The SNES emulation core the editor drives to make the game load a level. Bundled
as a shared library, one per platform, under
`shiny_mushroom/resources/mesen/<os>-<arch>/`.

| | |
|---|---|
| Upstream | [MesenCE](https://github.com/nesdev-org/MesenCE) — the community-maintained continuation of [SourMesen/Mesen2](https://github.com/SourMesen/Mesen2) |
| Licence | GPL-3.0-or-later |
| Version | see `packaging/mesen-pin.json` |
| Exact commit | see `provenance.json` beside each library, and the pin file |
| Modified | yes — the patches in `packaging/mesen-patches/`, listed per library in `provenance.json` |

**Modified, and here is what was changed.** The core we bundle is the pinned
commit with every patch in `packaging/mesen-patches/` applied. Each patch is a
readable diff with its reasoning in the file, `provenance.json` beside each
library names the ones that went into it, and the build refuses to produce a
library if one no longer applies. That directory is the notice of modification
GPL-3.0 section 5(a) asks for.

**Corresponding source — attached to this release.** Every release that bundles
a core also carries `mesen-core-source-<version>-<commit>-patched.tar.gz`: the
exact commit those libraries were built from, **with the patches applied and
also included in the tree**, so the archive is the source of the binary rather
than of something near it. It is on the same release page as the application, so
nothing here depends on an upstream repository still existing or a tag still
pointing where it did.

The scripts that control its compilation are `packaging/build_mesen_core.py` and
`.github/workflows/mesen-core.yml`, both in this repository.

To reproduce a bundled library exactly:

```bash
uv run python packaging/build_mesen_core.py --vendor
```

## asar

The 65816 assembler the editor runs to build a project's cartridge. Bundled at
the root of the application's bundled data, one binary for the platform the
release is for: `asar.exe` (Windows PE), `asar` (Linux ELF), `asar-macos`
(universal Mach-O, x86_64 and arm64 in one file).

| | |
|---|---|
| Upstream | [RPGHacker/asar](https://github.com/RPGHacker/asar) |
| Licence | LGPL-3.0-or-later, with a permissive summary in `asar-licenses/LICENSE` |
| Version | 1.91 |
| Modified | no |

Unmodified: the binaries are asar 1.91 as it assembles from that tag's source,
and nothing in this repository patches it. Its licence texts travel with it in
`asar-licenses/`, which the release bundles beside the binary, as the LGPL asks.

**The macOS binary is ours to explain.** Upstream publishes Windows and Linux
builds and no macOS one, so `asar-macos` was built by the maintainers from the
1.91 source rather than downloaded. It is the same version as the other two and
carries no changes.

## Qt, via PySide6

The GUI toolkit. Bundled by PyInstaller as part of the application.

| | |
|---|---|
| Upstream | <https://download.qt.io/official_releases/QtForPython/> |
| Licence | LGPL-3.0 |
| Version | pinned in `uv.lock` |

LGPLv3 permits use in a GPLv3 work. We do not modify Qt or PySide6; the released
application links the unmodified wheels, and their source is available from the
upstream above at the version `uv.lock` records.

## CPython

The interpreter, bundled by PyInstaller.

| | |
|---|---|
| Upstream | <https://www.python.org/downloads/> |
| Licence | PSF License Agreement |
| Version | 3.12 (`.python-version`) |

## Keeping this file true

`packaging/mesen-pin.json` is the single source of truth for which Mesen
revision we ship; changing it rebuilds every platform through the *Mesen core*
workflow. If a bundled component is added, removed or replaced, it changes here
in the same commit — a notice that lists something we no longer ship, or omits
something we do, is worse than no notice at all.
