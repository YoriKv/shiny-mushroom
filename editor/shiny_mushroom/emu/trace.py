"""Reading Mesen's trace log, one row at a time.

Two modules ask the same three things of a trace -- which instruction ran, where
it ran, and what address it reached -- because both ask the logger for the same
:data:`COLUMNS`. :mod:`shiny_mushroom.emu.footprints` groups the answers by the
object loop's boundary rows; :mod:`shiny_mushroom.emu.oam_writes` maps them
through a base's RAM map. What each does with a row is its own; getting a row
out of a line of text is here.

Nothing here opens a file. A trace arrives as an iterable of lines, which is
what makes both parses pure functions over text and testable without an
emulator.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Iterator

#: The program counter is written first whatever this says, so the columns only
#: have to ask for the two things a parse needs: which instruction, and where it
#: reached. The disassembly is what separates a store from a load -- the routines
#: being watched read the memories they write, and an effective address is
#: logged either way.
COLUMNS = "[Disassembly] [EffectiveAddress]"

#: The stores a parse counts. ``STA`` and ``STZ`` are what the object routines
#: use; sprite routines reach OAM with all four, indexed and otherwise. The
#: others are listed for both so that a routine that starts using one does not
#: silently stop being counted.
STORES = frozenset({"STA", "STZ", "STX", "STY"})

_EFFECTIVE = re.compile(r"\[\$([0-9A-Fa-f]{4,6})\]")


def pc_range(bounds: tuple[int, int]) -> str:
    """A trace filter matching a program counter inside ``bounds``.

    Filtered on the instruction fetch, which is all the trace logger can do:
    ``opPc`` is available, the target of a store is not. Decimal because the
    expression parser's number syntax is not part of any interface we control.
    """
    start, end = bounds
    return f"opPc >= {start} && opPc < {end}"


def rows(
    lines: Iterable[str], addressed: frozenset[str] = STORES
) -> Iterator[tuple[int, str, int | None]]:
    """Each usable line as ``(program counter, mnemonic, effective address)``.

    Lines the logger did not write a program counter and a mnemonic onto are
    dropped rather than reported: a trace file is written while the machine
    runs and its last line can be a partial one.

    The effective address is read only for a row whose mnemonic is in
    ``addressed``, and that is a cost decision rather than a filter -- the
    regex over the rows nobody will ask about is most of the price of a
    37,000-row object trace. Every other row's address is ``None``.
    """
    for line in lines:
        parts = line.split()
        if len(parts) < 2:
            continue
        try:
            counter = int(parts[0], 16)
        except ValueError:
            continue
        mnemonic = parts[1].upper()
        address = None
        if mnemonic in addressed:
            found = _EFFECTIVE.search(line)
            if found is not None:
                address = int(found.group(1), 16)
        yield counter, mnemonic, address


__all__ = ["COLUMNS", "STORES", "pc_range", "rows"]
