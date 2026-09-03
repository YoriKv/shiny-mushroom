#!/usr/bin/env python3
"""Rebuild the bundled icon font from the upstream face, keeping only our marks.

The editor ships Material Symbols Outlined cut down to the codepoints in
:class:`shiny_mushroom.ui.icons.Icon` -- around 20 KB where the upstream
variable font is 10.6 MB. That subset is a build artifact checked into the
tree, so **a new ``Icon`` member is not in the shipped font until this is
re-run**; it draws as nothing until then, and ``editor/tests/test_icon_font.py``
fails loudly when it does.

The codepoints come from the enum itself rather than a list kept alongside it,
which is the whole point: the two cannot disagree.

Usage::

    # https://github.com/google/material-design-icons -> variablefont/
    uv run --with fonttools packaging/subset_icon_font.py \\
        tmp/MaterialSymbolsOutlined.ttf

The variable axes are deliberately **kept** (``wght`` above all -- the editor
draws the icons at 300, see ``editor/shiny_mushroom/ui/icon_font.py``), so this
subsets the glyph set only and never instantiates a static instance.

The upstream face's ``LICENSE`` ships beside the subset as
``material-symbols-license.txt``; ``THIRD-PARTY.md`` and Help > About carry the
attribution Apache 2.0 asks to travel with the work.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
TARGET = (
    REPO
    / "editor"
    / "shiny_mushroom"
    / "resources"
    / "fonts"
    / "material-symbols-subset.ttf"
)


def codepoints() -> list[int]:
    """The codepoints the editor draws, read out of the enum."""
    sys.path.insert(0, str(REPO / "editor"))
    from shiny_mushroom.ui.icons import Icon  # noqa: PLC0415 - needs the path above

    return [ord(icon.value) for icon in Icon]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source", type=Path, help="the full upstream variable font (.ttf)"
    )
    parser.add_argument(
        "-o", "--output", type=Path, default=TARGET, help=f"where to write ({TARGET})"
    )
    args = parser.parse_args()
    if not args.source.is_file():
        print(f"no such font: {args.source}", file=sys.stderr)
        return 1

    unicodes = codepoints()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "fontTools.subset",
            str(args.source),
            f"--output-file={args.output}",
            "--unicodes=" + ",".join(f"U+{cp:04X}" for cp in unicodes),
            # Icons are drawn one codepoint at a time, never shaped as text, so
            # every layout feature in the face is dead weight. The ligatures
            # that let a web page write the icon's *name* go with them.
            "--layout-features=",
            "--no-hinting",
            "--desubroutinize",
            "--recalc-bounds",
        ],
        check=False,
    )
    if result.returncode != 0:
        return result.returncode
    size = args.output.stat().st_size
    print(f"{args.output.relative_to(REPO)}: {len(unicodes)} marks, {size:,} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
