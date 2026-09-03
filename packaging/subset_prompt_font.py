#!/usr/bin/env python3
"""Cut the bundled controller font out of PromptFont's own source.

The editor draws the twelve SNES buttons from PromptFont (SIL OFL), subset to
the codepoints in :class:`shiny_mushroom.ui.icons.PadIcon`. Like
``subset_icon_font.py`` this reads the codepoints **out of the enum**, so the
font and the code cannot disagree, and the subset it writes is a build artifact
checked into the tree: **a new ``PadIcon`` member is not in the shipped font
until this is re-run**, and draws as nothing until then.

Usage::

    uv run --with fonttools packaging/subset_prompt_font.py \\
        ../Icons/PromptFont/promptfont.sfd

**This compiles the outlines rather than subsetting a built face**, which is
not what the Material script does and needs saying. PromptFont ships as a
FontForge ``.sfd`` and is built with FontForge and SBCL; neither is a
reasonable thing to require here for twelve glyphs. The ``.sfd`` is a text
format, and every glyph the editor draws from it is a plain cubic outline with
no references, so it maps straight onto a CFF charstring -- which is what
PromptFont's own release is. The alternative was to vendor somebody else's
build of the font, and the one that was to hand had unlabelled Select and Start
pills where upstream now draws the words.

The parser is deliberately narrow. It reads the ``Fore`` layer's ``SplineSet``
and the ``m``/``l``/``c`` operators, and it refuses anything else -- a glyph
carrying a reference, a quadratic outline or a second layer is an error rather
than a silently empty mark.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
TARGET = (
    REPO / "editor" / "shiny_mushroom" / "resources" / "fonts" / "promptfont-subset.otf"
)
#: Where the upstream checkout sits beside this one. Only a default -- the path
#: is an argument, and nothing in the build depends on it being here.
DEFAULT_SOURCE = REPO.parent.parent / "Icons" / "PromptFont" / "promptfont.sfd"

FAMILY = "PromptFont Subset"

#: The ``head`` table's timestamps, in TrueType's own epoch (seconds since the
#: start of 1904). Zero, because what matters is that it is the same number
#: every run -- see where it is applied.
_EPOCH = 0

#: One line of a SplineSet: the numbers, then the operator, then FontForge's
#: point flags -- a small integer, or a hex point name where the outline is
#: referenced from a hint or a spiro layer. Neither means anything here.
_NUMBER = r"-?\d+(?:\.\d+)?"
_POINT_LINE = re.compile(rf"^\s*((?:{_NUMBER}\s+)+)([mlc])\s+\S+\s*$")


def codepoints() -> list[int]:
    """The controller marks the editor draws, read out of the enum."""
    sys.path.insert(0, str(REPO / "editor"))
    from shiny_mushroom.ui.icons import PadIcon  # noqa: PLC0415 - needs the path

    return [ord(icon.value) for icon in PadIcon]


def glyphs(sfd: str) -> dict[int, str]:
    """Every encoded glyph in ``sfd``, by codepoint, as its raw block."""
    found: dict[int, str] = {}
    for block in sfd.split("StartChar: ")[1:]:
        body = block.split("EndChar")[0]
        encoding = re.search(r"^Encoding:\s+(-?\d+)\s+(-?\d+)", body, re.M)
        if encoding and int(encoding.group(2)) >= 0:
            found[int(encoding.group(2))] = body
    return found


def draw(body: str, pen) -> int:  # noqa: ANN001 - a fontTools pen
    """Trace one glyph's ``Fore`` outline onto ``pen``; answer its advance.

    Raises rather than drawing something wrong: this runs once, by hand, and a
    glyph that came out empty or half-traced would ship as a blank button that
    only a person looking at the dialog would catch.
    """
    if "Refer:" in body:
        raise ValueError("glyph uses a reference, which this parser does not resolve")
    width = re.search(r"^Width:\s+(-?\d+)", body, re.M)
    if width is None:
        raise ValueError("glyph has no Width")
    _, _, fore = body.partition("\nFore\n")
    outline = fore.partition("SplineSet\n")[2].partition("EndSplineSet")[0]
    if not outline.strip():
        raise ValueError("glyph has no Fore SplineSet")

    open_contour = False
    for line in outline.splitlines():
        if not line.strip():
            continue
        match = _POINT_LINE.match(line)
        if match is None:
            raise ValueError(f"unhandled SplineSet line: {line.strip()!r}")
        numbers = [float(n) for n in match.group(1).split()]
        op = match.group(2)
        if op == "m":
            if open_contour:
                pen.closePath()
            pen.moveTo((numbers[0], numbers[1]))
            open_contour = True
        elif op == "l":
            pen.lineTo((numbers[0], numbers[1]))
        else:  # a cubic, which is what CFF wants anyway
            pen.curveTo(
                (numbers[0], numbers[1]),
                (numbers[2], numbers[3]),
                (numbers[4], numbers[5]),
            )
    if open_contour:
        pen.closePath()
    return int(width.group(1))


def build(source: Path, wanted: list[int], output: Path) -> int:
    from fontTools.fontBuilder import FontBuilder  # noqa: PLC0415 - a build-only dep
    from fontTools.pens.t2CharStringPen import T2CharStringPen  # noqa: PLC0415

    sfd = source.read_text(encoding="utf-8", errors="replace")
    header = sfd.split("StartChar:")[0]
    ascent = int(re.search(r"^Ascent:\s+(\d+)", header, re.M).group(1))
    descent = int(re.search(r"^Descent:\s+(\d+)", header, re.M).group(1))
    upem = ascent + descent
    copyright_ = re.search(r"^Copyright:\s+(.*)$", header, re.M)

    found = glyphs(sfd)
    missing = [f"U+{cp:04X}" for cp in wanted if cp not in found]
    if missing:
        print(f"not in {source}: {', '.join(missing)}", file=sys.stderr)
        return 1

    names = [".notdef"] + [f"uni{cp:04X}" for cp in wanted]
    charstrings = {}
    metrics = {}
    for name, cp in zip(names[1:], wanted, strict=True):
        pen = T2CharStringPen(None, None)
        try:
            advance = draw(found[cp], pen)
        except ValueError as problem:
            print(f"U+{cp:04X}: {problem}", file=sys.stderr)
            return 1
        charstrings[name] = pen.getCharString()
        metrics[name] = (advance, 0)
    blank = T2CharStringPen(None, None)
    charstrings[".notdef"] = blank.getCharString()
    metrics[".notdef"] = (upem, 0)

    builder = FontBuilder(upem, isTTF=False)
    builder.setupGlyphOrder(names)
    builder.setupCharacterMap({cp: f"uni{cp:04X}" for cp in wanted})
    builder.setupCFF(
        FAMILY.replace(" ", ""),
        {
            "FullName": FAMILY,
            "FamilyName": FAMILY,
            "Weight": "Regular",
            "Notice": copyright_.group(1) if copyright_ else "",
        },
        charstrings,
        {},
    )
    builder.setupHorizontalMetrics(metrics)
    builder.setupHorizontalHeader(ascent=ascent, descent=-descent)
    builder.setupNameTable(
        {
            "familyName": FAMILY,
            "styleName": "Regular",
            "psName": FAMILY.replace(" ", ""),
            "copyright": copyright_.group(1) if copyright_ else "",
        }
    )
    builder.setupOS2(sTypoAscender=ascent, sTypoDescender=-descent, usWinAscent=ascent)
    builder.setupPost()
    # Pinned, so the same .sfd always compiles to the same bytes. FontBuilder
    # stamps `head` with the clock, and this is a build artifact checked into
    # the tree: left alone, re-running the script to confirm it still works
    # would leave a diff that says nothing.
    builder.font["head"].created = builder.font["head"].modified = _EPOCH
    output.parent.mkdir(parents=True, exist_ok=True)
    builder.save(str(output))
    print(
        f"{output.relative_to(REPO)}: {len(wanted)} marks, "
        f"{output.stat().st_size:,} bytes"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source",
        type=Path,
        nargs="?",
        default=DEFAULT_SOURCE,
        help=f"PromptFont's promptfont.sfd ({DEFAULT_SOURCE})",
    )
    parser.add_argument(
        "-o", "--output", type=Path, default=TARGET, help=f"where to write ({TARGET})"
    )
    args = parser.parse_args()
    if not args.source.is_file():
        print(f"no such font source: {args.source}", file=sys.stderr)
        return 1
    return build(args.source, codepoints(), args.output)


if __name__ == "__main__":
    raise SystemExit(main())
