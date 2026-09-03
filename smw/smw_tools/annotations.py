"""Reading the documentation attached to a label.

The annotation for a label is the run of comment lines directly above it. This
reads them back out of the source, which means the tools always show what the
file currently says -- edit a comment and the next lookup reflects it, with
nothing to regenerate or keep in sync.

The comment blocks are not uniform prose. A memory entry carries structured
leading lines that are metadata rather than description::

    ; === $7E0DBE ===        <- the address the entry lives at
    ; 1 byte                 <- its size
    ; f---bbbb               <- a bit-field diagram
    ; number of lives        <- the actual description
    PlayerLives: skip 1

Those are separated out so a caller can show a one-line summary without the
summary turning out to be "=== $7E0DBE ===".
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from .paths import SRC_DIR

ADDRESS_BANNER = re.compile(r"^===\s*\$([0-9A-Fa-f]{2,6})\s*===$")
SIZE_LINE = re.compile(r"^(\d+)\s+bytes?$", re.IGNORECASE)
#: Bit-field diagrams and ASCII rules: `f---bbbb`, `+------- when set`, `----`.
#:
#: A diagram has to carry at least one placeholder -- `-`, `?` or `*` -- to be
#: one. Letters alone are a word, and matching those swallowed one-word
#: descriptions ("unused", "garbage") whole, leaving the entry with an
#: annotation and no summary.
DIAGRAM = re.compile(
    r"^[-+|:.\s]*$|^(?=.{4,}$)[a-zA-Z?*\-]*[?*\-][a-zA-Z?*\-]*$|^[|+][-+|]*\s"
)
#: A full-width banner rule, which belongs to the file or section, not the label.
SECTION_RULE = re.compile(r"^[=-]{6,};?$")

_COMMENT_PREFIX = re.compile(r"^\s*;\s?")
_IS_COMMENT = re.compile(r"^\s*;")
#: The lines between a `macro` and its body: the namespace it opens and the
#: `%InsertMacroAtXPosition(<Address>)` that anchors it. Neither emits anything.
_MACRO_PREAMBLE = re.compile(r"^\s*(namespace\b|%[A-Za-z_]\w*\()")
_LABEL = re.compile(r"^\s*([.#]?[A-Za-z_][\w.]*):")
#: The label a routine's entry point conventionally carries; asar flattens the
#: pair, so it is reached as `<namespace>_Main`.
ENTRY_LABEL = "Main"

_file_lines: dict[str, list[str]] = {}
_file_newline: dict[str, str] = {}


def _lines(rel_path: str) -> list[str]:
    """Source lines with their terminators stripped, newline style remembered.

    One cache for the whole package, because reading a comment block and
    rewriting one are the same file seen twice: a second cache is how an edit
    made through one reader stays invisible to the other.

    The tree is CRLF and must stay CRLF: mixing endings buries a real change in
    noise. Read as bytes rather than through ``read_text``, which translates
    CRLF to LF on the way in and would make every line of every file it touched
    look modified.
    """
    if rel_path not in _file_lines:
        p = Path(rel_path)
        abs_path = p if p.is_absolute() else SRC_DIR / rel_path
        text = abs_path.read_bytes().decode("latin-1")
        crlf = text.count("\r\n")
        _file_newline[rel_path] = "\r\n" if crlf * 2 >= text.count("\n") else "\n"
        _file_lines[rel_path] = [ln.rstrip("\r") for ln in text.split("\n")]
    return _file_lines[rel_path]


def newline_of(rel_path: str) -> str:
    """The line ending :func:`_lines` read ``rel_path`` with."""
    return _file_newline[rel_path]


def reset_source_cache() -> None:
    """Drop cached file contents; call after editing sources in-process."""
    _file_lines.clear()
    _file_newline.clear()


@dataclass
class Annotation:
    #: Address stated by a `; === $XXXXXX ===` banner, if present.
    address: str | None = None
    #: Size stated by a `; N byte(s)` line, if present.
    size: str | None = None
    #: Description paragraphs, metadata and diagrams removed.
    paragraphs: list[str] = field(default_factory=list)
    #: Every comment line of the block, verbatim, without the leading `; `.
    raw: list[str] = field(default_factory=list)


def annotation_for(rel_path: str, line: int) -> Annotation | None:
    """The annotation for the label defined at ``line`` (1-indexed) of ``rel_path``.

    Returns None when the label has no comment block above it.
    """
    if line <= 0:
        return None
    src = _lines(rel_path)

    # Walk up over the contiguous comment run.
    start = line - 1
    while start > 0:
        prev = src[start - 1] if start - 1 < len(src) else ""
        if not _IS_COMMENT.match(prev):
            break
        body = _COMMENT_PREFIX.sub("", prev).rstrip()
        # A section rule ends the block: it heads the file or region, not this label.
        if SECTION_RULE.match(body.strip()):
            break
        start -= 1
    if start == line - 1:
        return None

    raw = [_COMMENT_PREFIX.sub("", src[i]).rstrip() for i in range(start, line - 1)]
    return _parse_block(raw)


def _parse_block(raw: list[str]) -> Annotation:
    """Split a comment block's lines into metadata and description."""
    ann = Annotation(raw=raw)
    current: list[str] = []

    def flush() -> None:
        nonlocal current
        if current:
            ann.paragraphs.append(" ".join(current).strip())
        current = []

    for line_text in raw:
        t = line_text.strip()
        if not t:
            flush()
            continue
        addr = ADDRESS_BANNER.match(t)
        if addr:
            ann.address = f"${addr.group(1).upper()}"
            continue
        if SIZE_LINE.match(t):
            ann.size = t
            continue
        if DIAGRAM.match(t):
            continue
        current.append(t)
    flush()

    ann.paragraphs = [p for p in ann.paragraphs if p]
    return ann


def routine_annotation(rel_path: str, line: int) -> tuple[str, Annotation] | None:
    """The first documented label inside a routine, as ``(label, annotation)``.

    A routine's prose is not above its anchor and cannot be. ``line`` is its
    `macro` line, and every one of those in the tree is preceded by a blank
    line -- the routines are separated by a `;###` banner and then a gap -- so
    :func:`annotation_for` stops immediately and reports no documentation. The
    prose is *below*, inside the body, under `%InsertMacroAtXPosition`.

    **The label is returned because the block is not always about the routine.**
    A block sitting there documents whatever label follows it, and for most
    routines that is the first data table rather than the entry point -- `Tiles`,
    `XSpeed`, `InitialXSpeed`. Only a block above the conventional entry label,
    `Main`, describes the routine itself. Handing back the description alone
    would read as the routine's own and be wrong far more often than right, so
    the caller is told what it documents and decides how to present it.
    """
    src = _lines(rel_path)
    i = line  # 0-indexed: the line after `macro`
    while i < len(src) and (not src[i].strip() or _MACRO_PREAMBLE.match(src[i])):
        i += 1
    if i >= len(src) or not _IS_COMMENT.match(src[i]):
        return None
    start = i
    while i < len(src) and _IS_COMMENT.match(src[i]):
        i += 1
    label = _LABEL.match(src[i]) if i < len(src) else None
    if label is None:
        return None
    raw = [_COMMENT_PREFIX.sub("", src[j]).rstrip() for j in range(start, i)]
    if any(SECTION_RULE.match(t.strip()) for t in raw):
        return None
    return label.group(1), _parse_block(raw)


def summarize(ann: Annotation | None, max_len: int = 62) -> str:
    """A single line of description, truncated to ``max_len`` characters."""
    if ann is None or not ann.paragraphs:
        return ""
    text = re.sub(r"\s+", " ", ann.paragraphs[0]).strip()
    if len(text) <= max_len:
        return text
    # Prefer cutting at a sentence end, then a word boundary. The `end` bounds
    # below allow a match that *starts* at the limit: rfind's stop index is
    # exclusive of the whole match, so it must be widened by the needle length.
    stop = text.rfind(". ", 0, max_len + 2)
    if stop > max_len * 0.5:
        return text[: stop + 1]
    space = text.rfind(" ", 0, max_len)
    return text[: space if space > 0 else max_len - 1] + "..."


def wrap(text: str, prefix: str, width: int) -> list[str]:
    """``text`` as lines of at most ``width``, each one starting with ``prefix``.

    A word longer than the room left over stands on its own line rather than
    being broken: these are addresses, labels and register names, and a
    hyphenated one reads as two of them.
    """
    out: list[str] = []
    line = ""
    for word in text.split():
        candidate = f"{line} {word}" if line else word
        if line and len(prefix + candidate) > width:
            out.append(prefix + line)
            line = word
        else:
            line = candidate
    if line:
        out.append(prefix + line)
    return out


def format_annotation(
    ann: Annotation | None, indent: str = "  ", width: int = 78
) -> list[str]:
    """Wrap the full description for display under a heading."""
    if ann is None:
        return []
    out: list[str] = []
    for p in ann.paragraphs:
        if out:
            out.append("")
        out += wrap(p, indent, width)
    return out
