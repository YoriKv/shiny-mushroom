"""A call/reference graph over the assembly tree.

Grep is a poor tool for this source. "Who calls SubHorzPos" and "what writes
SpriteStatus" are the questions that actually come up, and a text search answers
them with every comment, every table entry, and every label whose name merely
contains the one you asked about. This builds the graph once (about a second
over 100k lines) and answers them exactly.

The unit of analysis is a *routine*. In ``Banks/`` and ``Routines/`` that is a
macro block -- the routines are written as macros the ROM map invokes at fixed
addresses. In ``Config/`` it is a fully-spelled column-0 label whose body
carries instructions: the feature files there keep their code stubs between
placement plumbing (org, RATS tags, asserts) and incsrc'd data fragments, and
only the label bodies that hold real 65816 instructions become nodes.

Two things an operand does not say, both tracked here because getting them wrong
produces a confident, wrong, complete-looking answer:

* **How wide the access is.** ``STA.W GameMode`` writes one byte or two
  depending on the M flag, and the second byte belongs to whatever entry sits
  above. :class:`_ModeTracker` follows REP/SEP through each routine so an access
  carries its width; :mod:`smw_tools.memory_layout` says which entry the extra byte
  lands in.
* **Whether the symbol is the destination or a pointer to it.**
  ``STA.B [_0],y`` does not write ``_0``; it reads a pointer there and writes
  wherever that points, which nothing static can name. Recording it as a write
  of ``_0`` is the one wrong answer worth going out of the way to avoid, because
  it is what would make ``--writers`` look exhaustive.
"""

from __future__ import annotations

import math
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .bases import RomBase

#: The game folder's three top-level files that carry addresses, by name. The
#: RAM map is a wrapper of `incsrc`s over `Memory/`; the SRAM map is a file of
#: its own; and the defines file is what the ROM map includes immediately before
#: the RAM map, so its values are already set when the maps' arithmetic runs.
RAM_MAP = "RAM_Map_SMW.asm"
SRAM_MAP = "SRAM_Map_SMW.asm"
GAME_DEFINES = "Misc_Defines_SMW.asm"

CALL_OPS = {"JSR", "JSL", "JMP", "JML"}
READ_OPS = {
    "LDA",
    "LDX",
    "LDY",
    "BIT",
    "CMP",
    "CPX",
    "CPY",
    "AND",
    "ORA",
    "EOR",
    "ADC",
    "SBC",
    "PEI",
}
# Read-modify-write instructions count as writes; that is the property a caller
# of this graph almost always cares about.
WRITE_OPS = {
    "STA",
    "STX",
    "STY",
    "STZ",
    "INC",
    "DEC",
    "ASL",
    "LSR",
    "ROL",
    "ROR",
    "TSB",
    "TRB",
}

#: Accesses whose operand width follows the M flag: the accumulator, and every
#: read-modify-write on memory. ``STZ`` stores the accumulator width too.
M_WIDTH_OPS = {
    "LDA",
    "STA",
    "STZ",
    "CMP",
    "AND",
    "ORA",
    "EOR",
    "ADC",
    "SBC",
    "BIT",
    "INC",
    "DEC",
    "ASL",
    "LSR",
    "ROL",
    "ROR",
    "TSB",
    "TRB",
}
#: Accesses whose operand width follows the X flag.
X_WIDTH_OPS = {"LDX", "LDY", "STX", "STY", "CPX", "CPY"}

#: Every 65816 mnemonic. What separates an instruction from an assembler
#: directive that happens to be three letters (``org``, ``pad``) in the one
#: place the difference matters: deciding whether a Config label's body is code
#: at all. The bank sources never put directives inside a routine macro, so the
#: looser match there stands.
MNEMONICS = (
    CALL_OPS
    | READ_OPS
    | WRITE_OPS
    | {
        "BCC", "BCS", "BEQ", "BMI", "BNE", "BPL", "BRA", "BRK", "BRL",
        "BVC", "BVS", "CLC", "CLD", "CLI", "CLV", "COP", "DEX", "DEY",
        "INX", "INY", "MVN", "MVP", "NOP", "PEA", "PER", "PHA", "PHB",
        "PHD", "PHK", "PHP", "PHX", "PHY", "PLA", "PLB", "PLD", "PLP",
        "PLX", "PLY", "REP", "RTI", "RTL", "RTS", "SEC", "SED", "SEI",
        "SEP", "STP", "TAX", "TAY", "TCD", "TCS", "TDC", "TSC", "TSX",
        "TXA", "TXS", "TXY", "TYA", "TYX", "WAI", "WDM", "XBA", "XCE",
    }
)  # fmt: skip

LABEL_DEF = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):")
DEFINE_DEF = re.compile(r"^\s*(![A-Za-z_][A-Za-z0-9_]*)\s*#?=")
#: A routine is a macro definition. It emits nothing where it is written -- the
#: ROM map invokes it at a fixed address -- so the macro block *is* the unit.
MACRO_DEF = re.compile(r"^macro\s+([A-Za-z_][A-Za-z0-9_]*)")
MACRO_END = re.compile(r"^endmacro\b")
#: Labels inside a routine are scoped by this, and asar flattens the pair to
#: ``<namespace>_<label>``. That flattened form is what a call site names, so it
#: is the only way to link a JSR back to the routine that owns its target.
NAMESPACE_DEF = re.compile(r"^\s*namespace\s+([A-Za-z_][A-Za-z0-9_]*)\s*$")
# The operand is optional: PHP, PLP and RTS carry the mode as surely as the
# instructions that take an argument, and dropping them desynchronises it.
# The size hint is lowercase in this tree (``LDA.b``); matching only uppercase
# silently dropped every hint and left the width tracker guessing.
INSTR = re.compile(r"^\s+([A-Za-z]{3})(?:\.([BWLbwl]))?(?:\s+(.*))?$")
IDENT = re.compile(r"![A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]*")
#: ``REP #$30`` / ``SEP #$20``. Anything else is not a mode change we can read.
MODE_IMMEDIATE = re.compile(r"^#\$([0-9A-Fa-f]{1,2})\s*$")
#: ``Table,x`` / ``Table,y`` / ``$01,s``: the destination is the symbol plus a
#: register this analysis does not track.
INDEXED_OPERAND = re.compile(r",\s*[XYS]\s*$", re.IGNORECASE)


class _ModeTracker:
    """The M and X flags, followed through one routine.

    Unknown is a first-class answer, and the reason this is worth having at all:
    an access whose width could not be determined is reported as *possibly* wide
    rather than quietly assumed narrow. Three things make it unknown -- entry
    (the width a routine expects is an undeclared calling convention), a call
    (the callee may leave the flags anywhere, and most of this codebase does not
    restore them), and a REP/SEP whose operand is not a plain literal.

    The witnesses it does trust: REP/SEP themselves, PHP/PLP as a save and
    restore pair, and the explicit ``.B``/``.W`` on an immediate. That last one
    is reliable *here* specifically -- asar sizes an immediate from the hint and
    tracks nothing itself, so every immediate in this tree carries one, and code
    that assembles at all is code whose hints match the mode it was written for.
    """

    def __init__(self) -> None:
        self.m: int | None = None
        self.x: int | None = None
        self._saved: list[tuple[int | None, int | None]] = []

    def width_for(self, op: str) -> int | None:
        if op in M_WIDTH_OPS:
            return self.m
        if op in X_WIDTH_OPS:
            return self.x
        return None

    def apply(self, op: str, hint: str, operand: str) -> None:
        """Update the mode for the instruction that has just been read."""
        if op in ("REP", "SEP"):
            m = MODE_IMMEDIATE.match(operand.strip())
            if m is None:
                self.m = self.x = None
                return
            bits = int(m.group(1), 16)
            width = 8 if op == "SEP" else 16
            if bits & 0x20:
                self.m = width
            if bits & 0x10:
                self.x = width
        elif op == "PHP":
            self._saved.append((self.m, self.x))
        elif op == "PLP":
            self.m, self.x = self._saved.pop() if self._saved else (None, None)
        elif op in CALL_OPS:
            self.m = self.x = None
        elif hint in ("B", "W") and operand.startswith("#"):
            width = 8 if hint == "B" else 16
            if op in M_WIDTH_OPS:
                self.m = width
            elif op in X_WIDTH_OPS:
                self.x = width


@dataclass(frozen=True)
class Access:
    """One instruction's use of one memory symbol."""

    symbol: str
    kind: str  # 'read' | 'write'
    #: 8, 16, or None when the mode could not be determined at that point.
    width: int | None
    #: How the operand reaches its destination, which is what decides whether
    #: naming ``symbol`` describes the access or merely starts it:
    #:
    #: ``direct``   -- ``STA.W GameMode``. The destination is the symbol, plus
    #:                 one more byte when the access is 16-bit.
    #: ``indexed``  -- ``STA.W Layer1ScrollType,x``. The destination is the
    #:                 symbol *plus the index*, i.e. somewhere in the table that
    #:                 begins there, and no static reading says how far.
    #: ``indirect`` -- ``STA.B [_0],y``. The symbol is a pointer; the
    #:                 destination is wherever it points.
    addressing: str


@dataclass
class Routine:
    name: str
    file: str
    #: 1-indexed line of the anchor that opens it: the `macro` line for a bank
    #: routine, the column-0 label for a Config one.
    line: int
    #: 1-indexed last line of the body: the `endmacro` for a bank routine, the
    #: line before the next boundary for a Config one.
    end_line: int
    #: The `namespace` it declares, if any. Labels inside are flattened to
    #: ``<namespace>_<label>``, and that is what call sites reference, so this is
    #: how a JSR target resolves back to the routine that defines it.
    namespace: str | None = None
    #: ``"macro"`` for a bank routine (its name is a macro's, never assembled as
    #: a label) or ``"label"`` for a Config one (its name *is* the label a call
    #: site names and a symbol file carries). Address resolution and where the
    #: documentation block sits both follow from this.
    kind: str = "macro"
    #: The column-0 labels the body defines. One namespace can span several
    #: macro chunks -- ``SMW_GameMode12_PrepareLevel`` spans six, across three
    #: banks -- so the namespace alone cannot say which chunk a flattened name
    #: belongs to; the label it carries can.
    labels: set[str] = field(default_factory=set)


@dataclass
class CodeGraph:
    routines: dict[str, Routine] = field(default_factory=dict)
    #: Memory-map labels (Memory/*.asm), name -> defining file.
    memory: dict[str, str] = field(default_factory=dict)
    #: `!Name` defines (Constants/, Memory/, Config/), name -> defining file.
    defines: dict[str, str] = field(default_factory=dict)
    #: routine -> routines it calls (JSR/JSL/JMP/JML).
    calls: dict[str, set[str]] = field(default_factory=dict)
    #: routine -> routines that call it.
    callers: dict[str, set[str]] = field(default_factory=dict)
    #: routine -> memory labels / defines it reads.
    reads: dict[str, set[str]] = field(default_factory=dict)
    #: routine -> memory labels / defines it writes.
    writes: dict[str, set[str]] = field(default_factory=dict)
    #: symbol -> routines that reference it at all.
    referenced_by: dict[str, set[str]] = field(default_factory=dict)
    #: routine -> every individual access it makes, with width and indirection.
    #: ``reads`` and ``writes`` are the names out of this; the detail is what
    #: answers "and what else did that store touch".
    accesses: dict[str, list[Access]] = field(default_factory=dict)


def strip_comment(line: str) -> str:
    """Strip trailing comments, respecting quoted strings."""
    in_str = False
    for i, c in enumerate(line):
        if c == '"':
            in_str = not in_str
        elif c == ";" and not in_str:
            return line[:i]
    return line


def _list_asm(root: Path, directory: str) -> list[Path]:
    full = root / directory
    if not full.is_dir():
        return []
    return sorted(p for p in full.iterdir() if p.suffix == ".asm")


def _read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="latin-1").split("\n")


def resolve_base(base: RomBase | None = None) -> RomBase:
    """``base``, or the default one -- looked up late so a redirected base wins.

    The one place the default is reached, so that every module answering for
    "this tree" answers for the same one, and a test that points the registry at
    a fixture points all of them at once.
    """
    from .bases import base as default  # noqa: PLC0415 -- avoids an import cycle

    return base or default()


def build_graph(base: RomBase | None = None) -> CodeGraph:
    """The call and access graph over ``base``'s source tree.

    Which tree that is, and what the game folder inside it is called, are the
    base's to say: two bases may share a checkout and differ only in what their
    ROM maps include, and a third could bring its own. ``Global`` is the one
    fixed name -- the framework resolves its own siblings from there.

    The graph itself carries no addresses, so it is the same for every base
    reading the same files. What differs is *where those files are*, which is
    why this takes a base rather than assuming one.
    """
    rom_base = resolve_base(base)
    root, game = rom_base.src_root, rom_base.game_folder
    g = CodeGraph()

    # --- pass 1: the symbol universe --------------------------------------
    # The RAM map is `!Name #= $address` throughout, so memory labels and plain
    # defines are the same syntax here; what separates them is which file they
    # live in. There are no `skip`-anchored labels in this tree.
    #
    # The SRAM map sits beside the game's other top-level files rather than
    # under `Memory/`, and it names storage exactly as the RAM map does -- so it
    # is read here and not with the defines, or nothing that walks `memory` (the
    # address index, and the layout built on it) would ever see save RAM.
    sram_map = root / game / SRAM_MAP
    memory_files = [*_list_asm(root, f"{game}/Memory")]
    if sram_map.is_file():
        memory_files.append(sram_map)
    for f in memory_files:
        rel = f.relative_to(root).as_posix()
        for raw in _read_lines(f):
            d = DEFINE_DEF.match(strip_comment(raw))
            if d:
                g.memory.setdefault(d.group(1), rel)
    for f in [
        *_list_asm(root, game),
        *_list_asm(root, f"{game}/Config"),
        *_list_asm(root, "Global"),
    ]:
        if f == sram_map:
            continue
        rel = f.relative_to(root).as_posix()
        for raw in _read_lines(f):
            d = DEFINE_DEF.match(strip_comment(raw))
            if d:
                g.defines.setdefault(d.group(1), rel)

    # --- pass 2: routines, and every reference inside them -----------------
    #: (routine, identifiers referenced, (mnemonic, size hint, operand) in order)
    pending: list[tuple[str, set[str], list[tuple[str, str, str]]]] = []

    def close(
        routine: Routine | None,
        refs: set[str] | None,
        ops: list[tuple[str, str, str]] | None,
        end_line: int,
    ) -> None:
        """Finalise the routine that just ended at ``end_line``."""
        if routine is None or refs is None or ops is None:
            return
        routine.end_line = end_line
        g.routines[routine.name] = routine
        pending.append((routine.name, refs, ops))

    for f in [*_list_asm(root, f"{game}/Banks"), *_list_asm(root, f"{game}/Routines")]:
        rel = f.relative_to(root).as_posix()
        lines = _read_lines(f)
        cur: Routine | None = None
        cur_refs: set[str] | None = None
        cur_ops: list[tuple[str, str, str]] | None = None
        depth = 0

        for i, raw in enumerate(lines):
            line = strip_comment(raw)
            m = MACRO_DEF.match(line)
            if m:
                depth += 1
                if depth == 1:
                    cur = Routine(name=m.group(1), file=rel, line=i + 1, end_line=i + 1)
                    cur_refs = set()
                    cur_ops = []
                    continue
            elif MACRO_END.match(line):
                depth -= 1
                if depth == 0:
                    close(cur, cur_refs, cur_ops, i + 1)
                    cur = cur_refs = cur_ops = None
                    continue
            if cur is None or cur_refs is None or cur_ops is None:
                continue

            ns = NAMESPACE_DEF.match(line)
            if ns and cur.namespace is None and ns.group(1) != "off":
                cur.namespace = ns.group(1)

            d = LABEL_DEF.match(line)
            if d:
                cur.labels.add(d.group(1))
            body = line[d.end() :] if d else line
            for t in IDENT.finditer(body):
                cur_refs.add(t.group(0))
            ins = INSTR.match(f" {body}" if d else line)
            if ins:
                op, hint, operand = ins.groups()
                cur_ops.append((op.upper(), (hint or "").upper(), operand or ""))
        close(cur, cur_refs, cur_ops, len(lines))

    # Config/ carries the feature stubs: real code under fully-spelled column-0
    # labels, sitting inside placement macros between org/RATS/assert plumbing
    # and incsrc'd data fragments. The unit there is the label -- the macro
    # around it places a whole feature, not one routine -- and its body runs to
    # the next column-0 label, a `namespace` line (which opens an incsrc'd
    # fragment), or the macro boundary. A body with no 65816 instruction in it
    # is data or plumbing and makes no node, which is what keeps the pointer
    # tables, the defines-only files and the reservation macros out of the
    # graph. Conditionals are walked straight through, both arms, exactly as
    # the bank scan walks version conditionals.
    for f in _list_asm(root, f"{game}/Config"):
        rel = f.relative_to(root).as_posix()
        lines = _read_lines(f)
        cur = None
        cur_refs = None
        cur_ops = None
        has_code = False

        for i, raw in enumerate(lines):
            line = strip_comment(raw)
            d = LABEL_DEF.match(line)
            ends_region = d or (
                MACRO_DEF.match(line)
                or MACRO_END.match(line)
                or NAMESPACE_DEF.match(line)
            )
            if ends_region:
                if cur is not None and has_code:
                    close(cur, cur_refs, cur_ops, i)
                cur = cur_refs = cur_ops = None
                if not d:
                    continue
                cur = Routine(
                    name=d.group(1), file=rel, line=i + 1, end_line=i + 1, kind="label"
                )
                cur_refs = set()
                cur_ops = []
                has_code = False
                body = line[d.end() :]
                if not body.strip():
                    continue
            else:
                body = line
            if cur is None or cur_refs is None or cur_ops is None:
                continue
            for t in IDENT.finditer(body):
                cur_refs.add(t.group(0))
            ins = INSTR.match(f" {body}" if d else body)
            if ins and ins.group(1).upper() in MNEMONICS:
                op, hint, operand = ins.groups()
                cur_ops.append((op.upper(), (hint or "").upper(), operand or ""))
                has_code = True
        if cur is not None and has_code:
            close(cur, cur_refs, cur_ops, len(lines))

    # --- pass 3: classify references now that all names are known ----------
    # A call site never names the routine: it names a label *inside* it, which
    # asar flattened to `<namespace>_<label>` -- `JSL SMW_UploadPlayerGFX_Main`
    # reaches the routine whose namespace is `SMW_UploadPlayerGFX`. Resolving a
    # target means finding the longest namespace that prefixes it, since
    # namespaces themselves share prefixes (`SMW_Sprite` vs `SMW_SpriteMain`)
    # -- and then, because one namespace can span several macro chunks, the
    # chunk that defines the label the name carries. Longest label wins there
    # for the same reason the longest namespace does: `Main` and `Main_Loop`
    # can both be labels, and only the longer one names the sublabel's owner.
    by_namespace: dict[str, list[Routine]] = {}
    for r in g.routines.values():
        if r.namespace:
            by_namespace.setdefault(r.namespace, []).append(r)

    def resolve_call(n: str) -> str | None:
        if n in g.routines:
            return n
        best: str | None = None
        for ns in by_namespace:
            if n.startswith(ns + "_") and (best is None or len(ns) > len(best)):
                best = ns
        if best is None:
            return None
        sharers = by_namespace[best]
        label = n[len(best) + 1 :]
        owner: str | None = None
        longest = -1
        for r in sharers:
            for defined in r.labels:
                if label == defined or label.startswith(defined + "_"):
                    if len(defined) > longest:
                        longest = len(defined)
                        owner = r.name
        # No chunk defines the label: a `#`-anchored label this scan does not
        # record, or a spelling only one side of a conditional assembles. The
        # last-registered chunk keeps such a call resolving somewhere, which
        # was the rule for every call before labels decided it.
        return owner if owner is not None else sharers[-1].name

    def is_data(n: str) -> bool:
        return n in g.memory or n in g.defines

    for name, refs, ops in pending:
        calls: set[str] = set()
        reads: set[str] = set()
        writes: set[str] = set()
        accesses: list[Access] = []
        mode = _ModeTracker()

        for op, hint, operand in ops:
            clean = strip_comment(operand).strip()
            # `[$00],y` and `($00,x)` dereference; `#$A9|(!Flag<<8)` is an
            # immediate that merely contains a bracket, hence the leading char
            # rather than a search.
            immediate = clean.startswith("#")
            if clean.startswith(("[", "(")):
                addressing = "indirect"
            elif INDEXED_OPERAND.search(clean):
                addressing = "indexed"
            else:
                addressing = "direct"
            width = mode.width_for(op)

            for m in IDENT.finditer(clean):
                n = m.group(0)
                if op in CALL_OPS:
                    target = resolve_call(n)
                    if target and target != name:
                        calls.add(target)
                elif immediate:
                    # `LDA.W #Sprite` loads the *address*. Counting that as a
                    # read of the location is a claim about behaviour the
                    # instruction does not make; the reference survives in
                    # `referenced_by`, which is where it belongs.
                    continue
                elif op in READ_OPS and is_data(n):
                    reads.add(n)
                    accesses.append(Access(n, "read", width, addressing))
                elif op in WRITE_OPS and is_data(n):
                    accesses.append(Access(n, "write", width, addressing))
                    if addressing == "indirect":
                        # The pointer is read to form the address; what gets
                        # written is somewhere else entirely.
                        reads.add(n)
                    else:
                        writes.add(n)

            mode.apply(op, hint, clean)

        g.calls[name] = calls
        g.reads[name] = reads
        g.writes[name] = writes
        g.accesses[name] = accesses
        for c in calls:
            g.callers.setdefault(c, set()).add(name)
        for r in refs:
            if r not in g.routines and resolve_call(r) is None and not is_data(r):
                continue
            g.referenced_by.setdefault(r, set()).add(name)

    return g


def closure(g: CodeGraph, root: str, depth: float = math.inf) -> dict[str, int]:
    """Transitive callees of ``root``, breadth-first, capped at ``depth``."""
    seen = {root: 0}
    frontier = [root]
    d = 0
    while frontier and d < depth:
        d += 1
        nxt: list[str] = []
        for n in frontier:
            for c in g.calls.get(n, ()):
                if c in seen:
                    continue
                seen[c] = d
                nxt.append(c)
        frontier = nxt
    return seen


def spilling_accesses(g: CodeGraph, symbol: str, kind: str) -> dict[str, int | None]:
    """Routines whose plain access to ``symbol`` runs past its first byte.

    Maps routine -> 16 when the width was determined, None when it was not. An
    8-bit access cannot spill and is never listed; an undetermined one is,
    because the alternative is to silently answer "no" on a maybe. Indexed and
    indirect accesses are excluded -- they overrun for a different reason and
    saying "16-bit store to the entry above" of one would be a wrong
    explanation of a right answer.
    """
    out: dict[str, int | None] = {}
    for routine, accs in g.accesses.items():
        for a in accs:
            if a.symbol != symbol or a.kind != kind or a.addressing != "direct":
                continue
            if a.width == 8:
                continue
            if a.width == 16 or routine not in out:
                out[routine] = a.width
    return out


def accesses_by_addressing(
    g: CodeGraph, kind: str, addressing: str
) -> dict[str, set[str]]:
    """Routine -> the symbols it accesses in the given addressing mode.

    For ``indirect`` these are pointers, and for ``indexed`` table bases: in
    both cases the symbol names where the access *starts*, not where it lands.
    They are why a list of accesses that named a target is not a list of
    everything that touches it.
    """
    out: dict[str, set[str]] = {}
    for routine, accs in g.accesses.items():
        syms = {a.symbol for a in accs if a.kind == kind and a.addressing == addressing}
        if syms:
            out[routine] = syms
    return out


def routine_source(g: CodeGraph, name: str, base: RomBase | None = None) -> str | None:
    """The macro body of ``name``, read back out of ``base``'s tree.

    ``Routine.file`` is relative to the source root the graph was built over, so
    the same base has to be passed back in to resolve it.
    """
    r = g.routines.get(name)
    if r is None:
        return None
    lines = _read_lines(resolve_base(base).src_root / r.file)
    return "\n".join(lines[r.line - 1 : r.end_line])
