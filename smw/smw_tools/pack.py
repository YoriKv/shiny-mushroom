"""What a vendored patch tree says about itself, read without assembling it.

SA-1 Pack is a binary patch by construction: ``org`` directives into an image,
most rewriting one operand byte of an instruction it never sees the source of.
This build switches every one of those writes off and carries each in its
own source instead; :func:`read_tree` reads every ``org`` in the tree with
the file and line it came from, the ``if`` blocks it sits under, and the
disassembled instruction the generator left as a comment where there is one
-- which is what ``smw/tests/test_sa1_sprite_access.py`` holds the pack's
table against.

Everything here is text: a regex walk over the tree, following ``incsrc``
from the entry file. Macros and loops are not expanded.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

# -- the tree, read ----------------------------------------------------------

_ORG = re.compile(
    r"^\s*org\s+\$([0-9A-Fa-f]{1,6})(?:\s*\+\s*(\$[0-9A-Fa-f]+|\d+))?\s*(?::\s*(.*))?$",
    re.IGNORECASE,
)
_INCSRC = re.compile(r'^\s*incsrc\s+"?([^"\s;]+)"?', re.IGNORECASE)
_IF = re.compile(r"^\s*if\s+(.*?)\s*$", re.IGNORECASE)
_ELSE = re.compile(r"^\s*else\s*$", re.IGNORECASE)
_ENDIF = re.compile(r"^\s*endif\s*$", re.IGNORECASE)
_GUARD = re.compile(r"read[123]\(", re.IGNORECASE)
#: The generator's record of what a rewritten instruction was:
#: ``; InitYoshiEgg:       B5 E4         LDA RAM_SpriteXLo,X``.
_WAS = re.compile(r"^\s*;\s*(\w+:\s+(?:[0-9A-Fa-f]{2}\s+)+[A-Za-z]{3}\b.*?)\s*$")


@dataclass(frozen=True)
class Site:
    """One ``org`` in the patch tree: a place it writes."""

    #: SNES address the directive names, its ``+N`` folded in.
    address: int
    #: Relative to the tree's root, forward slashes.
    file: str
    line: int
    #: The text assembled at the site: what follows ``org $X :`` on the same
    #: line, or the next line that is neither blank nor a comment.
    payload: str
    #: The comment line just above the directive, which the generated files
    #: use to record the instruction being rewritten. Empty when there is none.
    was: str = ""
    #: Every ``if`` the site sits inside, outermost first, as written.
    conditions: tuple[str, ...] = ()

    @property
    def guard(self) -> str | None:
        """The innermost clean-ROM probe this site is conditioned on."""
        for c in reversed(self.conditions):
            if _GUARD.search(c):
                return c
        return None


@dataclass(frozen=True)
class Guard:
    """One ``if read1(...)`` in the tree: a block that can fail open."""

    file: str
    line: int
    condition: str
    #: Every ``if`` *around* this one, outermost first -- the switch a base
    #: turned the whole file off with is found here.
    conditions: tuple[str, ...] = ()


@dataclass
class PackTree:
    """The tree as included from its entry file."""

    root: Path
    files: list[str] = field(default_factory=list)
    sites: list[Site] = field(default_factory=list)
    guards: list[Guard] = field(default_factory=list)

    def by_file(self) -> dict[str, list[Site]]:
        out: dict[str, list[Site]] = {}
        for s in self.sites:
            out.setdefault(s.file, []).append(s)
        return out

    def site_at_or_below(self, address: int, within: int = 16) -> Site | None:
        """The nearest site starting at or before ``address``, if it is close.

        Sites carry no length -- the tree is not assembled here -- so this is
        the site a rewritten byte most plausibly belongs to: the last ``org``
        before it, provided the gap is within what one directive's payload
        could span. A byte in the patch's freespace code has no site at all,
        and the caller says so.
        """
        best: Site | None = None
        for s in self.sites:
            if s.address <= address < s.address + within and (
                best is None or s.address > best.address
            ):
                best = s
        return best


def read_tree(root: Path, entry: str) -> PackTree:
    """Walk the tree from ``entry``, following ``incsrc``, collecting sites."""
    tree = PackTree(root=root)
    seen: set[Path] = set()
    _read_file(tree, root / entry, (), seen)
    return tree


def _read_file(
    tree: PackTree, path: Path, outer: tuple[str, ...], seen: set[Path]
) -> None:
    path = path.resolve()
    if path in seen or not path.is_file():
        return
    seen.add(path)
    rel = path.relative_to(tree.root.resolve()).as_posix()
    tree.files.append(rel)
    lines = path.read_text(encoding="latin-1").split("\n")
    stack: list[str] = list(outer)
    depth_here = 0
    for i, raw in enumerate(lines, start=1):
        line = raw.split(";", 1)[0] if not raw.lstrip().startswith(";") else ""
        if m := _IF.match(line):
            stack.append(m.group(1))
            depth_here += 1
            if _GUARD.search(m.group(1)):
                tree.guards.append(Guard(rel, i, m.group(1), tuple(stack[:-1])))
            continue
        if _ELSE.match(line) and depth_here:
            stack[-1] = f"not ({stack[-1]})"
            continue
        if _ENDIF.match(line) and depth_here:
            stack.pop()
            depth_here -= 1
            continue
        if m := _INCSRC.match(line):
            _read_file(tree, path.parent / m.group(1), tuple(stack), seen)
            continue
        if m := _ORG.match(line):
            address = int(m.group(1), 16)
            if plus := m.group(2):
                address += int(plus[1:], 16) if plus.startswith("$") else int(plus)
            payload = (m.group(3) or "").strip()
            if not payload:
                payload = _next_payload(lines, i)
            was = ""
            if i >= 2 and (w := _WAS.match(lines[i - 2])):
                was = w.group(1)
            tree.sites.append(Site(address, rel, i, payload, was, tuple(stack)))


def _next_payload(lines: list[str], org_line: int) -> str:
    for raw in lines[org_line:]:
        text = raw.split(";", 1)[0].strip()
        if text:
            return text
    return ""
