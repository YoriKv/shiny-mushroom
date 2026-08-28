"""The regression gate: assemble, then prove the bytes are right.

Two independent comparisons, and they answer different questions:

1. Against the hashes in rom_versions.py. This is the gate. It decides
   pass/fail, needs no files on disk beyond the source tree, and works for all
   five releases. Never weaken it.
2. Against a reference dump on disk, when one is supplied. This is a diagnostic,
   not a gate -- a dump can be headered, a bad rip, or a hack base, and none of
   those make the build wrong. A mismatch here prints where the two differ so
   the cause is identifiable.

Reference dumps are found in reference/ by **content** -- every file there is
hashed and matched to the version it is a dump of -- so their filenames do not
matter, and the path can still be overridden per-run. They are never required
and never committed.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .bases import Reference, RomBase
from .bases import base as default_base
from .build import build_rom
from .paths import REFERENCE_DIR, relative_path
from .rom_image import RomImage, count_diffs, diff_clusters, format_snes, read_rom
from .rom_versions import identify
from .staging import StagedTree, staged_sources

#: version -> reference cart, resolved by content rather than by filename.
#:
#: Matching on names was brittle: dumps arrive called "Super Mario World -
#: Super Mario Bros. 4 (Japan).sfc" or "... (En) (Arcade).sfc", and a name the
#: table did not know silently downgraded the run to hashes-only -- a weaker
#: check that still printed OK. Hashing every candidate also catches the
#: opposite failure, a correctly-named file that is the wrong dump.
_REFERENCE_CACHE: dict[str, Path] | None = None


@dataclass
class CheckResult:
    version: str
    built: RomImage
    #: True when the build matches the expected hashes. This is the gate.
    exact: bool


def _scan_references() -> dict[str, Path]:
    """Map version -> cart in reference/, by SHA-1. Scanned once per process."""
    global _REFERENCE_CACHE
    if _REFERENCE_CACHE is not None:
        return _REFERENCE_CACHE

    found: dict[str, Path] = {}
    if REFERENCE_DIR.is_dir():
        for p in sorted(REFERENCE_DIR.iterdir()):
            if not p.is_file() or p.suffix.lower() not in (".sfc", ".smc"):
                continue
            try:
                version = identify(read_rom(p).sha1)
            except OSError:
                continue
            if version and version not in found:
                found[version] = p
    _REFERENCE_CACHE = found
    return found


def _find_reference(version: str) -> Path | None:
    return _scan_references().get(version)


def run_check(
    versions: list[str],
    reference_path: str | None = None,
    show_diff: bool = True,
    stage: bool | None = None,
    base: RomBase | None = None,
) -> list[CheckResult]:
    """Assemble each version and rule on its bytes.

    ``stage`` decides whether to assemble from a scratch copy of the sources
    rather than in place -- see :mod:`staging`, which also decides it by default.
    It is invisible to the verdict: the same passes run over the same bytes, and
    the only thing that moves is where they are read from. Nothing is copied
    back, so a staged run leaves no ROM in ``build/``.
    """
    rom_base = base or default_base()
    results: list[CheckResult] = []

    with staged_sources(
        stage, on_progress=lambda m: print(f"> {m}"), base=rom_base
    ) as staged:
        for version in versions:
            results.append(
                _check_one(rom_base, version, staged, reference_path, show_diff)
            )
    return results


def _check_one(
    base: RomBase,
    version: str,
    staged: StagedTree | None,
    reference_path: str | None,
    show_diff: bool,
) -> CheckResult:
    target = base.target(version)
    # Always rebuild, so the verdict describes the current source and never a
    # stale artefact left by an earlier run.
    built = build_rom(
        version,
        base=base,
        output_dir=staged.build_dir if staged else None,
        game_dir=staged.game_dir if staged else None,
        assets_dir=staged.assets_dir if staged else None,
    )
    img = read_rom(built.output_path)

    # The target's own expectation decides, so a base with no shipped cartridge
    # is judged by what it can actually claim rather than by hashes invented to
    # look like No-Intro ones. See :mod:`bases`.
    wrong = target.expectation.mismatches(img)
    exact = not wrong

    # A staged path is scratch that is about to be deleted, so it is named as
    # what it is rather than offered as somewhere to go and look.
    where = (
        f"{built.output_path.name}  (staged, not kept)"
        if staged
        else relative_path(built.output_path)
    )

    print(f"\n{target.label}  ({version})")
    print(f"  built    {where}")
    print(f"  size     {img.size}")
    print(f"  crc32    {img.crc32}")
    print(f"  sha1     {img.sha1}")
    if not target.expectation.pinned:
        # Said out loud rather than printed as a pass: "assembled" and "matches
        # its bytes" must not look the same in the log.
        print("  OK   assembled (this target pins no bytes)")
    elif exact:
        print("  OK   byte-exact")
    else:
        print("  FAIL byte mismatch against the pinned hashes")
        for detail in wrong:
            print(f"         {detail}")

    # Only a target that claims to *be* a shipped cartridge has a dump to be
    # compared against. Looking one up by version id alone would hand a derived
    # base the vanilla cart of the same release and print a few hundred regions
    # of entirely expected difference -- which reads as a problem and is not.
    shipped = isinstance(target.expectation, Reference)
    ref = Path(reference_path) if reference_path else None
    if ref is None and shipped:
        ref = _find_reference(version)
    if ref and ref.exists():
        _report_against_reference(img, ref, show_diff)
    elif not shipped:
        print(
            "  reference  none possible -- this target is not a shipped "
            "cartridge, so its pin is the only check"
        )
    else:
        # Say so rather than skipping silently: "no dump on disk" and "dump on
        # disk, identical" look the same otherwise, and only one of them means
        # the build was cross-checked against real cart bytes.
        print("  reference  none in reference/ -- pinned-hash gate only")

    return CheckResult(version=version, built=img, exact=exact)


def _report_against_reference(built: RomImage, ref_path: Path, show_diff: bool) -> None:
    ref = read_rom(ref_path)
    print(f"\n  reference  {ref_path}")
    if ref.had_copier_header:
        print("             (512-byte copier header detected and ignored)")
    print(f"             size {ref.size}  crc32 {ref.crc32}  sha1 {ref.sha1}")

    if ref.sha1 == built.sha1:
        print("             OK   identical to the build")
        return

    n = count_diffs(built.data, ref.data)
    clusters = diff_clusters(built.data, ref.data)
    print(
        f"             DIFFERS from the build: {n} bytes in {len(clusters)} region(s)"
    )
    print(
        "             The pinned-hash result above is the gate; "
        "this dump is not vanilla."
    )

    if not show_diff:
        return
    shown = clusters[:24]
    for c in shown:
        length = c.end - c.start + 1
        print(
            f"               {format_snes(c.start)}  pc 0x{c.start:06X}"
            f"  {length:>6} bytes  built={c.a.hex()} ref={c.b.hex()}"
        )
    if len(clusters) > len(shown):
        print(f"               ... and {len(clusters) - len(shown)} more region(s)")
