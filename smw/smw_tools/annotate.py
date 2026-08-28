"""Fold an address-keyed reference table into the source as comments.

The input is a TSV of address -> description rows. Each row is resolved to the
exact source line that owns its address and its text is added to that line's
comment block.

Four properties make this safe to run over 100k lines of assembly:

* **Comments only.** Nothing here emits or moves a byte, so ``smw check --all``
  stays byte-exact. That is the backstop, and it is checked after applying.
* **Idempotent by content.** A row is skipped when its text is already present
  in the target's comment block, so re-running after the table updates adds
  only what is new instead of duplicating everything.
* **Dry-run by default.** ``--apply`` is required to write.
* **Ambiguity is reported, not guessed at.** An address with no line of its own
  points into the middle of a table, and an address whose line also emits other
  addresses belongs to a shared macro body. Attaching text to either would put
  a description against code it does not describe.

FOUR KINDS OF TARGET, BECAUSE THIS TREE NAMES ADDRESSES FOUR WAYS. A RAM entry
is a ``!Name #= $addr`` define, a hardware register is the same but in the
framework's register file, a DMA channel field is a member of an asar ``struct``,
and a ROM address is a plain instruction with no name at all. Only the first
three have anything a symbol lookup could return; the fourth is resolved
through asar's own ``[addr-to-line mapping]``, which is the only exact record of
which source line produced which byte.
"""

from __future__ import annotations

import csv
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from functools import cache
from pathlib import Path

from .address_index import (
    _memory_label_locations,
    normalize_wram,
    parse_address,
    ram_map_order,
)
from .annotations import _lines, newline_of, reset_source_cache, wrap
from .paths import BUILD_DIR, REFERENCE_DIR, SRC_DIR
from .symbols import stale_sources

#: The table as saved from its source page.
DEFAULT_TSV = REFERENCE_DIR / "smwc-memory-map.tsv"

#: Which address space each section of the table describes.
#:
#: `Hijack` is deliberately absent. Those 2564 rows catalogue what third-party
#: patches do to an address ("Modified by the Clear All RAM on Reset patch..."),
#: not what the bytes in this ROM do, so folding them in would describe code
#: that is not here.
SECTION_SPACE = {
    "RAM": "wram",
    "ROM": "rom",
    "SRAM": "sram",
    "Regs": "mmio",
}

#: Comment width, including the leading `; `, before the tab indent is counted.
DEFAULT_WIDTH = 76

#: `.asm` is ASCII-only and must stay that way: a stray non-ASCII byte inside a
#: `db` string moves bytes. The table carries nine of them, all typographic.
#: `*` is written for multiply, `--` for a dash, per the source conventions.
TRANSLITERATE = {
    " ": " ",
    "©": "(c)",
    "°": " degrees",
    "·": "--",
    "×": "*",
    "‐": "-",
    "‑": "-",
    "–": "--",
    "—": "--",
    "‘": "'",
    "’": "'",
    "“": '"',
    "”": '"',
    "…": "...",
    "→": "->",
    "★": "[star]",
    "☆": "[star]",
}


@dataclass(frozen=True)
class Target:
    """A source line to hang a comment block above."""

    #: Path relative to ``src/``.
    file: str
    #: 1-indexed line of the definition or instruction.
    line: int
    #: Tie-break among several names for one address; lower wins. Must not
    #: depend on position, since this tool moves lines around -- see
    #: :func:`_ram_targets`.
    rank: tuple[int, ...] | int = 0


@dataclass
class Row:
    section: str
    address: str
    length: str
    type: str
    description: str
    details: str


@dataclass
class Stats:
    rows: int = 0
    not_applicable: int = 0
    targets: int = 0
    resolved: int = 0
    unresolved: int = 0
    ambiguous: int = 0
    already_present: int = 0
    edited: int = 0
    files_touched: int = 0
    #: Addresses that resolved to nothing, and to a shared macro line.
    unresolved_addrs: list[str] = field(default_factory=list)
    ambiguous_addrs: list[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# The table


def read_tsv(path: Path) -> list[Row]:
    with Path(path).open(encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        cols = {c.strip().lower() for c in (reader.fieldnames or [])}
        if not {"section", "address", "description"} <= cols:
            raise ValueError(
                f"{path}: expected at least section/address/description columns, "
                f"got: {', '.join(sorted(cols))}"
            )
        return [
            Row(
                section=(r.get("section") or "").strip(),
                address=(r.get("address") or "").strip(),
                length=(r.get("length") or "").strip(),
                type=(r.get("type") or "").strip(),
                description=(r.get("description") or "").strip(),
                details=(r.get("details") or "").strip(),
            )
            for r in reader
        ]


def row_applies(row: Row) -> bool:
    """Whether a row describes hardware this cartridge actually has.

    The `Regs` section mixes real SNES registers with expansion-chip ones. SMW
    is a plain LoROM cart: no MSU-1, no SA-1, no Super FX, so those rows
    describe silicon that is not in this game.
    """
    if row.section == "Regs":
        return row.type.startswith("SNES Register")
    return True


_REG_ACCESS_PREFIX = re.compile(r"^[-+rwb?]{2,8}\s+(?=[A-Z0-9]{2,}\b)")

#: Prose that pointed somewhere the table cannot reach. The source page carried
#: hyperlinks; the export dropped them, leaving "see here" aimed at nothing and
#: "this patch" naming no patch. Both read as information while carrying none,
#: which is exactly what an asm comment here must not do -- so the sentence
#: that made the reference goes, and the rest of the description stays.
#: (`h ttp` is not a typo: the export breaks URLs that way.)
_DANGLING = re.compile(
    r"h\s?ttps?://|www\."
    r"|\bthis (?:patch|tool|thread|post|link|page)\b"
    r"|\b(?:see|click|download|found)\s+(?:here|this|below)\b",
    re.IGNORECASE,
)

#: Split on sentence ends only where a capital follows, so `#$00 = ...` and
#: `$008E28: ...` inside a description are not mistaken for boundaries.
_SENTENCE = re.compile(r"(?<=[.!?])\s+(?=[A-Z])")


def drop_dangling_references(text: str) -> str:
    kept = [s for s in _SENTENCE.split(text) if not _DANGLING.search(s)]
    return " ".join(kept).strip()


def clean_description(row: Row) -> str:
    """The text to fold in, which is the description column only.

    The `details` column is deliberately ignored. It never holds content: every
    non-empty value is the *heading* of a collapsible panel on the source page
    ("Valid Values", "Usage", "Diagram"), and appending one just leaves a
    dangling word at the end of the comment.

    Register descriptions are prefixed with an access-flag string (`wb++++`)
    that is meaningless without the source page's legend, so it is dropped and
    the register name left to lead.
    """
    text = row.description.strip()
    if row.section == "Regs":
        text = _REG_ACCESS_PREFIX.sub("", text)
    return to_ascii(drop_dangling_references(text)).strip()


def to_ascii(text: str) -> str:
    for bad, good in TRANSLITERATE.items():
        text = text.replace(bad, good)
    # Anything still outside ASCII would fail the tree's own check, and silently
    # dropping it would leave a sentence with a hole in it. Mark it instead.
    return "".join(c if ord(c) < 0x80 else "?" for c in text)


# ---------------------------------------------------------------------------
# Targets: where in the source each address is named


#: The RAM map holds more than addresses. `!OAM_SMW_GenericNormalSprite = $40`
#: is an OAM slot index and `!CGRAM_SMW_YoshiCoinFlash = $64` a palette index;
#: both are small constants that read as WRAM addresses if you go by number,
#: which is how a description of $7E0040 ends up over an OAM constant. Only the
#: two prefixes that actually name storage are eligible.
_ADDRESS_PREFIXES = ("!RAM_", "!SRAM_")


def _ram_targets() -> dict[tuple[str, int], list[Target]]:
    """Every `!Name #= $address` entry of the RAM and SRAM maps.

    Aliases are common and carry no storage of their own:

        !RAM_SMW_Misc_ScratchRAM7E1436 = $001436
            !RAM_SMW_Player_OnTiltingPlatformXPosLo = !RAM_SMW_Misc_ScratchRAM7E1436

    The file's own convention is that the canonical entry sits at column 0 and
    the role-specific aliases are indented beneath it, so indent depth
    separates those. Across files the map's include order decides, which puts
    the region files ahead of `WRAM_Extended.asm` -- the catch-all that holds
    the per-sprite aliases and the Lunar Magic entries, and where a description
    of the game's own RAM does not belong.

    **Neither half of that may depend on position**, because this tool inserts
    lines. Ranking by line number across files would be right on a clean tree
    and then drift on the next run: whichever file gained the most comments is
    the one whose entries slide furthest down.
    """
    order = ram_map_order()
    out: dict[tuple[str, int], list[Target]] = defaultdict(list)
    for name, (rel, line, space, addr) in _memory_label_locations().items():
        if space not in ("wram", "sram", "mmio"):
            continue
        if not name.startswith(_ADDRESS_PREFIXES):
            continue
        key = (space, normalize_wram(addr) if space == "wram" else addr)
        text = _lines(rel)[line - 1]
        rank = (order.get(rel, len(order)), _indent_width(text))
        out[key].append(Target(rel, line, rank))
    for targets in out.values():
        targets.sort(key=lambda t: (t.rank, t.line))
    return out


#: `!REGISTER_NMIEnable = $004210` at column 0. Indented `!Name = $80` lines in
#: the same file are bit-field constants, not addresses, and are skipped.
_REGISTER_ENTRY = re.compile(r"^!REGISTER_([A-Za-z0-9_]+)\s*#?=\s*\$([0-9A-Fa-f]{4,6})")
_STRUCT_OPEN = re.compile(r"^\s*struct\s+([A-Za-z0-9_]+)\s+\$([0-9A-Fa-f]{4,6})")
#: `.SourceLo: skip $01`. The prefix is captured because it is what states the
#: radix: asar reads `$` as hexadecimal, `%` as binary and a bare operand as
#: **decimal**, so `skip 10` advances the cursor by ten bytes and not sixteen.
_STRUCT_FIELD = re.compile(r"^\s*\.([A-Za-z0-9_]+):\s*skip\s+([$%]?)([0-9A-Fa-f]+)")
_SKIP_RADIX = {"$": 16, "%": 2, "": 10}
_STRUCT_CLOSE = re.compile(r"^\s*endstruct\b")

#: The framework's SNES register file. Shared by every game built on the
#: framework rather than specific to this one, which is why it is named here
#: explicitly instead of being swept up by a glob over the register directory:
#: the expansion-chip files beside it describe hardware SMW does not have.
REGISTER_FILE = "Global/HardwareRegisters/SNES.asm"


def _register_targets() -> dict[tuple[str, int], list[Target]]:
    """Hardware registers, as plain defines and as `struct` members.

    DMA and HDMA are `struct`s rather than defines because the eight channels
    are the same seven fields repeated every $10 bytes. Only channel 0 has a
    name in the source; the rows for channels 1-7 resolve to nothing and are
    reported, because there is no line that describes channel 5 in particular.
    """
    out: dict[tuple[str, int], list[Target]] = defaultdict(list)
    path = SRC_DIR / REGISTER_FILE
    if not path.is_file():
        return out
    struct_base: int | None = None
    cursor = 0
    for i, raw in enumerate(_lines(REGISTER_FILE)):
        m = _REGISTER_ENTRY.match(raw)
        if m:
            out[("mmio", int(m.group(2), 16) & 0xFFFF)].append(
                Target(REGISTER_FILE, i + 1, 0)
            )
            continue
        m = _STRUCT_OPEN.match(raw)
        if m:
            struct_base = int(m.group(2), 16) & 0xFFFF
            cursor = struct_base
            continue
        if _STRUCT_CLOSE.match(raw):
            struct_base = None
            continue
        m = _STRUCT_FIELD.match(raw)
        if m and struct_base is not None:
            out[("mmio", cursor)].append(Target(REGISTER_FILE, i + 1, 1))
            cursor += int(m.group(3), _SKIP_RADIX[m.group(2)])
    for targets in out.values():
        targets.sort(key=lambda t: (t.rank, t.line))
    return out


def _rom_targets(sym_path: Path) -> dict[tuple[str, int], list[Target]]:
    """ROM addresses, through asar's own address-to-line mapping.

    A ROM address has no name to look up: the documented addresses are branch
    targets, table entries and hijack points in the middle of routines, not
    routine heads. The symbol file's `[addr-to-line mapping]` section is the
    assembler's record of which source line emitted each byte, which is the
    only exact answer to "what wrote $0092AE".

    **A line that emits more than one address is dropped.** 657 of them do:
    they are bodies of macros invoked from many places, so one line stands for
    many addresses and a description of any one of them would be wrong against
    the rest.
    """
    sym_path = Path(sym_path)
    text = sym_path.read_text(encoding="latin-1")
    files: dict[str, str] = {}
    addr_to_line: dict[int, tuple[str, int]] = {}
    mode = ""
    for raw in text.split("\n"):
        line = raw.strip()
        if line.startswith("["):
            mode = line
            continue
        if mode == "[source files]":
            parts = line.split(None, 2)
            if len(parts) == 3:
                files[parts[0].lower()] = parts[2]
        elif mode == "[addr-to-line mapping]":
            parts = line.split()
            if len(parts) != 2 or ":" not in parts[0] or ":" not in parts[1]:
                continue
            bank, off = parts[0].split(":")
            file_id, src_line = parts[1].split(":")
            try:
                addr = (int(bank, 16) << 16) | int(off, 16)
                addr_to_line[addr] = (files.get(file_id.lower(), ""), int(src_line, 16))
            except ValueError:
                continue

    addr_to_line = _apply_line_offsets(addr_to_line)

    fanout = Counter(addr_to_line.values())
    # Compared against the files the mapping actually names rather than the whole
    # tree, because that is what these line numbers describe -- and once per
    # file, not once per address: the mapping names a few dozen files 78,000
    # times, and each comparison is a syscall.
    mapped = {
        rel
        for f, _ in addr_to_line.values()
        if (rel := _normalize_sym_path(f)) is not None
    }
    stale = stale_sources(sym_path, mapped)
    if stale:
        # The mapping is line numbers, and this tool's own output is inserted
        # lines. A pass over a file edited since the build would aim every
        # address at whatever has since drifted into that position -- and
        # succeed at it, silently, because any line can hold a comment. One
        # stale file is enough to refuse the whole pass: the run rewrites the
        # tree, and half of it against a build that no longer describes it is
        # worse than none.
        raise ValueError(
            f"{sym_path} is older than {len(stale)} file(s) it maps, starting with "
            f"{stale[0]} -- its line numbers no longer describe them. "
            f"Re-run `smw build U --symbols` first."
        )
    out: dict[tuple[str, int], list[Target]] = defaultdict(list)
    for addr, (raw_file, line) in addr_to_line.items():
        rel = _normalize_sym_path(raw_file)
        if rel is None or fanout[(raw_file, line)] != 1:
            continue
        out[("rom", addr)].append(Target(rel, _hoist_over_labels(rel, line), 0))
    return out


#: A label alone on its line: `Main:`, `.Setting00:`, `CODE_008DF5:`.
_BARE_LABEL = re.compile(r"^\s*[.#]?[A-Za-z_][\w.]*:\s*(;.*)?$")

#: A line that emits nothing: blank, comment, or a directive that only steers
#: the assembler. Everything else is a statement that produces bytes.
_NOT_A_STATEMENT = re.compile(
    r"^\s*($|;"
    r"|(if|else|elseif|endif|macro|endmacro|namespace|struct|endstruct"
    r"|org|base|arch|incsrc|pushpc|pullpc|includeonce|function|print|warn)\b)",
    re.IGNORECASE,
)


def _emits(line: str) -> bool:
    """Whether a line produces bytes.

    A label alone on its line does not -- it names the address the next
    statement will occupy. Counting it as one would make the two candidate
    lines look equally plausible and cost the calibration a vote.
    """
    if not line.strip() or _NOT_A_STATEMENT.match(line):
        return False
    return not _BARE_LABEL.match(line)


def _apply_line_offsets(
    addr_to_line: dict[int, tuple[str, int]],
) -> dict[int, tuple[str, int]]:
    """Correct asar's line numbers per file, by calibrating against the source.

    The mapping is 1-indexed, but **inside a macro body asar's line lags by
    one**: in `Banks/Bank00.asm` it puts `SEI` -- the byte at $008000 -- against
    $008001, and every entry after it is short by a line the same way. Files
    pulled in as plain data (`levels/`, `strings/`, `overworld/`) have no lag.
    Nothing in the file says which kind it is, and guessing one offset for the
    whole build annotates one of the two kinds against the wrong statement.

    So the offset is measured rather than assumed. An entry is *decisive* when
    exactly one of the two candidate lines emits bytes at all -- the other
    being a comment, a blank or an `if`. Those vote, per file; a file whose
    entries are all indecisive (a dense data table, where every candidate is a
    `db`) is dropped rather than guessed at.
    """
    votes: dict[str, Counter[int]] = defaultdict(Counter)
    for raw_file, line in addr_to_line.values():
        rel = _normalize_sym_path(raw_file)
        if rel is None:
            continue
        lines = _lines(rel)
        here = _emits(lines[line - 1]) if 0 < line <= len(lines) else False
        after = _emits(lines[line]) if 0 <= line < len(lines) else False
        if here != after:
            votes[raw_file][0 if here else 1] += 1

    offsets = {f: c.most_common(1)[0][0] for f, c in votes.items() if c}
    return {
        addr: (raw_file, line + offsets[raw_file])
        for addr, (raw_file, line) in addr_to_line.items()
        if raw_file in offsets
    }


def _hoist_over_labels(rel: str, line: int) -> int:
    """The line to put the comment above, given the one that emits the address.

    A label alone above a statement names the same address as that statement,
    so the description belongs above the label rather than wedged between the
    label and its data. Labels sharing the line with their statement --
    `.Setting00:  incbin ...` -- are already covered by the statement itself.
    """
    lines = _lines(rel)
    while line > 1 and _BARE_LABEL.match(lines[line - 2]):
        line -= 1
    return line


@cache
def _normalize_sym_path(raw: str) -> str | None:
    """A `[source files]` entry as a path relative to ``src/``.

    asar records paths as it saw them, from a working directory of ``src/SMW``:
    ``../SMW/Banks/Bank00.asm``, ``../Global/Global_Macros.asm`` and bare
    ``strings/LevelNameStrings.asm`` all appear. Anything that resolves outside
    the tree -- an asset include -- is dropped.

    Cached because ``resolve()`` is a syscall and the mapping names the same
    few dozen files 78,000 times over.
    """
    if not raw:
        return None
    try:
        resolved = (SRC_DIR / "SMW" / raw).resolve()
        return str(resolved.relative_to(SRC_DIR.resolve())).replace("\\", "/")
    except (ValueError, OSError):
        return None


# ---------------------------------------------------------------------------
# Reading and rewriting source


def _indent_width(line: str) -> int:
    """Indent depth, counting a tab as one level rather than as N columns."""
    return len(line) - len(line.lstrip("\t "))


def _leading_indent(line: str) -> str:
    return line[: len(line) - len(line.lstrip("\t "))]


_IS_COMMENT = re.compile(r"^\s*;")


def _comment_block_start(lines: list[str], line: int) -> int:
    """0-indexed start of the run of comment lines directly above ``line``."""
    i = line - 1
    while i > 0 and _IS_COMMENT.match(lines[i - 1] or ""):
        i -= 1
    return i


def _normalize(text: str) -> str:
    """Fold to case and spacing only, for the already-present comparison."""
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def wrap_comment(text: str, indent: str, width: int) -> list[str]:
    """``text`` as a comment block at ``indent``, wrapped to ``width``."""
    return wrap(text, f"{indent}; ", width)


# ---------------------------------------------------------------------------


def _tsv_address(row: Row, space: str) -> int | None:
    """The row's address as a key into the target tables.

    Each space states addresses its own way: the table writes WRAM as `$7E1400`
    but the source writes the bank-$00 mirror, and it writes registers as
    16-bit `$2100` while the source writes the long `$002100` form.
    """
    m = re.match(r"\$?([0-9A-Fa-f]{2,6})", row.address)
    if not m:
        return None
    addr = parse_address(m.group(0))
    if addr is None:
        return None
    if space == "wram":
        return normalize_wram(addr if addr >= 0x2000 else 0x7E0000 | addr)
    if space == "mmio":
        return addr & 0xFFFF
    return addr


def run(
    tsv_path: Path | str = DEFAULT_TSV,
    *,
    section: str | None = None,
    apply: bool = False,
    limit: int | None = None,
    width: int = DEFAULT_WIDTH,
    sym_path: Path | str | None = None,
) -> Stats:
    tsv_path = Path(tsv_path)
    if not tsv_path.is_file():
        raise FileNotFoundError(f"table not found: {tsv_path}")
    all_rows = read_tsv(tsv_path)
    if section:
        all_rows = [r for r in all_rows if r.section.lower() == section.lower()]
    rows = [r for r in all_rows if r.section in SECTION_SPACE and row_applies(r)]

    needs_rom = any(r.section == "ROM" for r in rows)
    targets: dict[tuple[str, int], list[Target]] = defaultdict(list)
    for table in (_ram_targets(), _register_targets()):
        for key, hits in table.items():
            targets[key].extend(hits)
    if needs_rom:
        sym = Path(sym_path) if sym_path else BUILD_DIR / "SMW_U.sym"
        if not sym.is_file():
            raise FileNotFoundError(
                f"no symbol file at {sym} -- run `smw build U --symbols` first"
            )
        for key, hits in _rom_targets(sym).items():
            targets[key].extend(hits)

    # Several addresses carry more than one row. Group them so one address
    # produces one comment block with each distinct description as its own
    # paragraph, rather than N separate insertions.
    groups: dict[tuple[str, int], list[Row]] = defaultdict(list)
    for row in rows:
        space = SECTION_SPACE[row.section]
        addr = _tsv_address(row, space)
        if addr is not None:
            groups[(space, addr)].append(row)

    stats = Stats(
        rows=len(all_rows),
        not_applicable=len(all_rows) - len(rows),
        targets=len(groups),
    )

    # Edits are collected per file and applied bottom-up, so inserting lines
    # never invalidates the line numbers of edits still pending.
    edits: dict[str, list[tuple[int, list[str]]]] = defaultdict(list)
    claimed: set[tuple[str, int]] = set()

    for key in sorted(groups):
        if limit is not None and stats.edited >= limit:
            break
        space, addr = key
        hits = targets.get(key) or []
        if not hits:
            stats.unresolved += 1
            stats.unresolved_addrs.append(f"${addr:06X} {space}")
            continue
        stats.resolved += 1

        target = hits[0]
        # Two addresses landing on one line would stack two unrelated
        # descriptions above it. The first wins; the rest are reported.
        if (target.file, target.line) in claimed:
            stats.ambiguous += 1
            stats.ambiguous_addrs.append(f"${addr:06X} {space}")
            continue

        lines = _lines(target.file)
        if target.line > len(lines):
            stats.unresolved += 1
            stats.unresolved_addrs.append(f"${addr:06X} {space} (line past EOF)")
            continue
        start = _comment_block_start(lines, target.line)
        existing = _normalize(" ".join(lines[start : target.line - 1]))

        paragraphs: list[str] = []
        for row in groups[key]:
            body = clean_description(row)
            norm = _normalize(body)
            if not norm or norm in existing:
                continue
            if any(_normalize(p) == norm for p in paragraphs):
                continue
            paragraphs.append(body)
        if not paragraphs:
            stats.already_present += 1
            continue

        indent = _leading_indent(lines[target.line - 1])
        text: list[str] = []
        for para in paragraphs:
            if text:
                text.append(f"{indent};")
            text.extend(wrap_comment(para, indent, width))

        edits[target.file].append((target.line, text))
        claimed.add((target.file, target.line))
        stats.edited += 1

    if apply:
        for rel, items in edits.items():
            lines = _lines(rel)
            for line, text in sorted(items, key=lambda e: -e[0]):
                lines[line - 1 : line - 1] = text
            (SRC_DIR / rel).write_bytes(newline_of(rel).join(lines).encode("latin-1"))
        reset_source_cache()
    stats.files_touched = len(edits)
    return stats
