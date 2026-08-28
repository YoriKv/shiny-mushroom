# Vendored emulator cores

`MesenCore` libraries that ship with the editor, one directory per platform:

```
mesen/
├── linux-x64/     MesenCore.so     + provenance.json
├── macos-arm64/   MesenCore.dylib  + provenance.json
├── macos-x64/     MesenCore.dylib  + provenance.json
└── windows-x64/   MesenCore.dll    + provenance.json
```

**These come from CI, not from a local build.** Run the *Mesen core* workflow
(`.github/workflows/mesen-core.yml`), download its `mesen-cores-all` artifact and
unzip it over this directory. The workflow builds every platform from the one
revision pinned in [`packaging/mesen-pin.json`](../../../../packaging/mesen-pin.json),
which names the upstream fork and commit as well as the version. That is what
keeps the set consistent: the editor calls Mesen through its internal C++/C#
boundary, so a mixed set would mean the memory layout differs
between platforms with nothing to say so.

A platform may be rebuilt locally (`build_mesen_core.py --vendor`) between
workflow runs, from the same pin and patch set -- each library's
`provenance.json` says exactly what went into it. The macOS libraries
currently predate `0002-memory-write-log.patch`; that patch only *adds*
exports, which the editor probes for and lives without (footprints fall back
to last-writer attribution), so the set stays safe until the workflow rebuilds
all four.

For development, build your own with
`uv run python packaging/build_mesen_core.py`. It writes to `mesen-cores/` at
the repository root — uncommitted, and preferred over this directory at runtime,
so your build is what a source checkout uses without ever becoming what a
release ships.

`provenance.json` records the upstream commit each library was built from.
Mesen is GPLv3 and so are we, so bundling it is permitted; what it obliges is
being able to hand over the corresponding source. That file is how we can.

The design is in [`docs/editor/emulator-worker.md`](../../../../docs/editor/emulator-worker.md).
