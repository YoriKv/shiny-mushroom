"""Static checks the byte gate cannot make. No build required.

The gate proves the ROM is right. It cannot say *why* a wrong one is wrong, and
it cannot see a problem that has not moved a byte yet. This holds the checks
that catch those.

**Freespace fill sizes.** For J and U every freespace region is `$FF` padding,
but E0, E1 and SS are filled from captured cart bytes in
`Misc/GarbageData<NN>_<ROMID>.bin`. Each region declares its own size per
version, immediately above the call that inserts it::

    !SMW_UBytes = $05 : ... : !SMW_E1Bytes = $05 : !SMW_E2Bytes = $00
        %SMW_FitOriginalFreespace(<Address>, !ROMID, 05)

So a file's length is not a property of the file -- it is asserted by the
source, and a mismatch shifts every byte after it. A missing file fails the
build with an `Efile_not_found` naming a path, which reads as a broken checkout
rather than as what it is: six regions are legitimately zero bytes, upstream
ships none of those, and that alone is why both PAL builds do not assemble from
the base as given.

This checks every declared region against what is on disk, for the three
versions that use captured fill.

**The palette table's two branches.** The global palette table is written
twice, guarded on `!Define_SMW_Global_UseIndividualPaletteFiles`: the branch
every ROM map selects reads a `.tpl` per set where Lunar Magic exported one,
and the other reads every byte out of `palettes/smw.pal`. Only one is ever
assembled, so the gate cannot see the other rot -- and it had, by 60 bytes.
Both are checked here to emit the same table, which is also what keeps
`smw.pal` a faithful mirror of every colour in the game.

**Include path casing.** The checkout lives on a Windows drive, where a lookup
by name is case-insensitive, so ``incbin "Music/Levels/Passed_boss.bin"``
resolves a file actually called ``Passed_Boss.bin`` and the build is byte-exact.
On any case-sensitive filesystem the same line is `Efile_not_found` -- and one
of those is where an editor project's merged tree lands, because a project is
kept in the user's data directory. So this is a defect the gate cannot see from
the side it is run on, and it breaks a platform rather than a byte.
"""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from pathlib import Path

from .bases import RomBase, iter_includes
from .bases import base as default_base

#: `!SMW_UBytes = $05 : !SMW_JBytes = $02 : ...`, all on one line.
SIZE_DEFS = re.compile(r"!([A-Za-z0-9_]+)Bytes\s*=\s*\$([0-9A-Fa-f]+)")
#: `%SMW_InsertOriginalFreespace(!ROMID, 05)`, and the fitted form most regions
#: use, `%SMW_FitOriginalFreespace(<Address>, !ROMID, 05)`. Both, because both
#: insert the same file and either one moving would leave this blind -- which is
#: the failure the `no-regions` finding below exists for, and which it did not
#: catch when the fitted form arrived and four regions kept the placed one.
INSERT = re.compile(
    r"%SMW_(?:Insert|Fit)OriginalFreespace\("
    r"(?:\s*<Address>\s*,)?\s*!ROMID\s*,\s*([0-9]+)\s*\)"
)

#: The table whose two branches are compared, by the name it is written under.
TABLE_MACRO = "DATATABLE_SMW_GlobalPalettes"

#: `incbin "palettes/Sky.tpl":$6..$8` -- one run of the global palette table.
PALETTE_INCBIN = re.compile(
    r'incbin\s+"(palettes/[\w.]+)":\$([0-9A-Fa-f]+)\.\.\$([0-9A-Fa-f]+)'
)

#: `macro INLINEDATATABLE_RT05_SMW_EmptySpace(Address)` -- one freespace
#: region's macro. Counted so that the insertions found can be held against the
#: regions there are: a check that finds *some* of them is the shape this went
#: blind in, and is invisible where a count of zero would not be.
REGION_MACRO = re.compile(r"^macro INLINEDATATABLE_RT(\d+)_SMW_EmptySpace\(", re.M)

#: The versions whose freespace is captured cart bytes rather than `$FF`.
FILLED_VERSIONS = ("E1", "E2", "ARCADE")


@dataclass(frozen=True)
class Finding:
    kind: str
    detail: str
    file: str = ""
    line: int = 0


@dataclass
class StaticReport:
    findings: list[Finding] = field(default_factory=list)
    checked: int = 0

    #: Include paths that were found on disk and could therefore be compared.
    #: Separate from :attr:`checked` because the two checks count different
    #: things, and reporting one total would say neither.
    paths_checked: int = 0

    #: How big the global palette table is, where both its branches could be
    #: read. Zero says the comparison did not happen, which is a finding of its
    #: own rather than a pass.
    branch_bytes: int = 0

    @property
    def error_count(self) -> int:
        return len(self.findings)


def _declared_sizes(game_dir: Path) -> dict[str, dict[str, int]]:
    """region number -> {ROMID suffix: declared byte count}.

    The sizes are set on the line above the call, so the most recent definition
    seen is the one that belongs to it.
    """
    out: dict[str, dict[str, int]] = {}
    for d in ("Banks", "Routines"):
        directory = game_dir / d
        if not directory.is_dir():
            continue
        for f in sorted(directory.glob("*.asm")):
            latest: dict[str, int] | None = None
            for raw in f.read_text(encoding="latin-1").split("\n"):
                found = SIZE_DEFS.findall(raw)
                if found:
                    latest = {k: int(v, 16) for k, v in found}
                m = INSERT.search(raw)
                if m and latest:
                    out.setdefault(m.group(1).zfill(2), latest)
    return out


def _region_macros(game_dir: Path) -> set[str]:
    """Every freespace region's number, from the macros that define them."""
    found: set[str] = set()
    for d in ("Banks", "Routines"):
        directory = game_dir / d
        if not directory.is_dir():
            continue
        for f in sorted(directory.glob("*.asm")):
            text = f.read_text(encoding="latin-1")
            found |= {m.zfill(2) for m in REGION_MACRO.findall(text)}
    return found


def _normalised(path: Path) -> Path:
    """``path`` with ``..`` folded away, without touching the filesystem."""
    return Path(os.path.normpath(path))


def _spelled_on_disk(path: Path, listings: dict[Path, dict[str, str]]) -> Path | None:
    """``path`` as it is actually spelled, or None if nothing is there.

    Every component is looked up in its parent's *listing*, because asking the
    filesystem for a name is what hides the problem: on a case-insensitive
    volume the wrong spelling answers. ``listings`` memoises the directory reads,
    which matters -- the tree holds hundreds of include paths and the checkout is
    usually across the WSL boundary, where each read is a round trip.

    Normalised lexically rather than with :meth:`~pathlib.Path.resolve`, which is
    a syscall per component and is spent on the many candidates that do not
    exist: the roots are already absolute and nothing here is a symlink, so
    folding ``..`` away is all that is wanted.
    """
    parts, probe = [], _normalised(path)
    while probe != probe.parent:
        listing = listings.get(probe.parent)
        if listing is None:
            try:
                listing = {p.name.lower(): p.name for p in probe.parent.iterdir()}
            except OSError:
                listing = {}
            listings[probe.parent] = listing
        actual = listing.get(probe.name.lower())
        if actual is None:
            return None
        parts.append(actual)
        probe = probe.parent
    return Path(probe, *reversed(parts))


def _check_include_casing(report: StaticReport, base: RomBase) -> None:
    """Compare every literal include path against its real name on disk.

    Every spelling the tree uses, through :func:`~smw_tools.bases.iter_includes`
    -- quoted or bare -- because a check that knew only one of them left the
    paths written the other way unexamined.
    """
    listings: dict[Path, dict[str, str]] = {}
    # The two roots asar's --include search path adds, in the order it tries
    # them, so a path is judged against the file the build would actually reach.
    search = [base.assets_root, base.assets_root / "SPC700"]
    for source in sorted(base.src_root.rglob("*.asm")):
        text = source.read_text(encoding="utf-8", errors="replace")
        for include in iter_includes(text):
            # A path built from a define is not resolvable without assembling.
            if "!" in include.path:
                continue
            target = include.path
            roots = [source.parent, base.game_dir, *search]
            for candidate in (root / target for root in roots):
                actual = _spelled_on_disk(candidate, listings)
                if actual is None:
                    continue
                report.paths_checked += 1
                # Compared as text, not as paths: `Path` equality case-folds on
                # Windows, which is precisely the difference being looked for --
                # the check would pass everything on the platform whose
                # case-insensitivity lets the defect in.
                if str(actual) != str(_normalised(candidate)):
                    report.findings.append(
                        Finding(
                            kind="case",
                            detail=(
                                f"{target} is spelled {actual.name} on disk; this "
                                f"resolves here and is Efile_not_found on a "
                                f"case-sensitive filesystem"
                            ),
                            file=str(source.relative_to(base.src_root.parent)),
                            line=include.line,
                        )
                    )
                break


def _palette_branches(bank00: Path) -> tuple[list[tuple[str, int, int]], ...]:
    """The two branches of `DATATABLE_SMW_GlobalPalettes`, as (file, start, end)
    runs in emission order -- the selected one first."""
    lines = bank00.read_text(encoding="utf-8").splitlines()
    guard = "if !Define_SMW_Global_UseIndividualPaletteFiles"
    opened = next(
        (n for n, line in enumerate(lines) if line.strip().startswith(guard)), None
    )
    if opened is None:
        return ([], [])
    after = list(enumerate(lines))[opened:]
    middle = next(n for n, line in after if line.strip() == "else")
    closed = next(n for n, line in after[middle - opened :] if line.strip() == "endif")
    branches = []
    for span in (lines[opened + 1 : middle], lines[middle + 1 : closed]):
        runs = []
        for line in span:
            hit = PALETTE_INCBIN.search(line)
            if hit:
                runs.append(
                    (hit.group(1), int(hit.group(2), 16), int(hit.group(3), 16))
                )
        branches.append(runs)
    # `!TRUE` selects the `.tpl` branch, which the source writes second.
    return (branches[1], branches[0])


def _assembled(runs: list[tuple[str, int, int]], game_dir: Path) -> bytes | str:
    """What those runs emit, or what stopped them being read."""
    out = bytearray()
    for name, start, end in runs:
        path = game_dir / name
        if not path.is_file():
            return f"{name} is absent"
        data = path.read_bytes()
        if len(data) < end:
            return f"{name} is {len(data):#x} bytes, so it has no {start:X}-{end:X}"
        out += data[start:end]
    return bytes(out)


def _check_palette_branches(report: StaticReport, base: RomBase) -> None:
    """That the branch nothing assembles would emit the same table as the one
    that does.

    A branch no ROM map selects is invisible to the byte gate, so the only
    thing standing between it and silent rot is this. The two are the same
    colours cut out of different files, so a difference is either a range that
    has drifted or a `.tpl` and `smw.pal` that no longer agree -- and the
    second matters even to a reader, because `smw.pal` is where the whole
    palette is written down in one place.
    """
    bank00 = base.game_dir / "Banks" / "Bank00.asm"
    text = bank00.read_text(encoding="utf-8") if bank00.is_file() else ""
    if TABLE_MACRO not in text:
        # A tree with no palette table at all is not this check's business --
        # a fixture, or a base that does not carry one. A tree that *has* the
        # table but not in two readable branches is, and says so below.
        return
    selected, other = _palette_branches(bank00)
    if not selected or not other:
        report.findings.append(
            Finding(
                kind="no-palette-table",
                detail=(
                    "found no two-branch global palette table -- it has moved and "
                    "this check is now blind"
                ),
                file="Banks/Bank00.asm",
            )
        )
        return
    report.branch_bytes = 0
    emitted = [_assembled(runs, base.game_dir) for runs in (selected, other)]
    unread = [found for found in emitted if isinstance(found, str)]
    for detail in unread:
        report.findings.append(
            Finding(kind="palette-file", detail=detail, file="Banks/Bank00.asm")
        )
    if unread:
        return
    live, dead = emitted
    report.branch_bytes = len(live)
    if live == dead:
        return
    if len(live) != len(dead):
        detail = (
            f"the .tpl branch emits {len(live):#x} bytes and the smw.pal branch "
            f"{len(dead):#x}"
        )
    else:
        at = next(i for i in range(len(live)) if live[i] != dead[i])
        detail = f"the two branches differ from byte {at:#x}"
    report.findings.append(
        Finding(
            kind="palette-branch",
            detail=(
                f"the global palette table is not the same either way: {detail} -- "
                f"one branch's ranges have drifted from the other's"
            ),
            file="Banks/Bank00.asm",
        )
    )


def run_static_verification(base: RomBase | None = None) -> StaticReport:
    rom_base = base or default_base()
    report = StaticReport()
    misc = rom_base.game_dir / "Misc"
    declared = _declared_sizes(rom_base.game_dir)
    _check_include_casing(report, rom_base)
    _check_palette_branches(report, rom_base)

    regions = _region_macros(rom_base.game_dir)
    if not declared:
        report.findings.append(
            Finding(
                kind="no-regions",
                detail=(
                    "found no freespace insertions -- the mechanism has moved "
                    "and this check is now blind"
                ),
            )
        )
        return report
    if missed := sorted(regions - set(declared)):
        report.findings.append(
            Finding(
                kind="unread-regions",
                detail=(
                    f"{len(missed)} freespace region(s) declare a size that "
                    f"nothing here reads -- {', '.join('RT' + m for m in missed)} "
                    f"-- so their fill files are unchecked"
                ),
            )
        )

    for region in sorted(declared):
        for version in FILLED_VERSIONS:
            want = declared[region].get(f"SMW_{version}")
            if want is None:
                continue
            path = misc / f"GarbageData{region}_SMW_{version}.bin"
            report.checked += 1
            if not path.is_file():
                report.findings.append(
                    Finding(
                        kind="missing",
                        detail=(
                            f"GarbageData{region}_SMW_{version}.bin is absent; the "
                            f"source declares {want} bytes"
                            + (" (an empty file is correct)" if want == 0 else "")
                        ),
                        file=f"Misc/GarbageData{region}_SMW_{version}.bin",
                    )
                )
                continue
            actual = path.stat().st_size
            if actual != want:
                report.findings.append(
                    Finding(
                        kind="size",
                        detail=(
                            f"GarbageData{region}_SMW_{version}.bin is {actual} "
                            f"bytes; the source declares {want}"
                        ),
                        file=f"Misc/GarbageData{region}_SMW_{version}.bin",
                    )
                )
    return report


def print_report(r: StaticReport) -> None:
    if not r.findings:
        print(f"  OK   {r.checked} freespace fill files match their declared size")
        print(f"  OK   {r.paths_checked} include paths match their names on disk")
        print(
            f"  OK   both branches of the global palette table emit the same "
            f"{r.branch_bytes} bytes"
        )
        return
    for f in r.findings:
        where = f":{f.line}" if f.line else ""
        where = f"  ({f.file}{where})" if f.file else ""
        print(f"  FAIL [{f.kind}] {f.detail}{where}")
    total = r.checked + r.paths_checked
    print(f"\n  {len(r.findings)} problem(s) across {total} checked")
