"""What a cartridge behind the editor cannot carry, and what is said about it.

The keys :meth:`MainWindow._note_skipped` files each gatherer's reading under,
the two readings that are not a gatherer's at all, and the sentence a save's
refusal grows when it names a label the build never wrote. Here rather than in
:mod:`shiny_mushroom.ui.main_window` so the window's sections
(:mod:`shiny_mushroom.ui.window`) can say one without importing the window they
are mixed into.
"""

from __future__ import annotations

__all__ = [
    "BUILD_ONLY",
    "DISASSEMBLY",
    "LEVEL_PALETTE",
    "LEVEL_PARTS",
    "MISSING_LABEL",
    "MUSIC",
    "POINTER_PARTS",
    "SOURCE_FILES",
    "STRINGS",
    "WORLD_PARTS",
    "WORLD_TABLES",
    "_rebuild_detail",
]

#: The gatherers that report parts an in-place patch could not carry, as the
#: keys :meth:`MainWindow._note_skipped` files their readings under. They run
#: in the same breath, so each must be able to clear its own alone.
LEVEL_PARTS = "level"
WORLD_PARTS = "world map"
POINTER_PARTS = "layer 2 pointer"
#: The saved overworld fragments the editor could not read back -- hand-edited
#: past the emitter's grammar. Its own key rather than :data:`WORLD_PARTS`,
#: because the world-map patch gathers after this one and would clear it.
WORLD_TABLES = "world map tables"

#: And the canvas level's own palette: patchable only where a build has
#: already placed the blob, so the gatherer reports the gap like the rest.
LEVEL_PALETTE = "level palette"
#: The project's own source files, changed on disk since it was last built --
#: see :meth:`MainWindow._check_source_files`. Not a gatherer like the others:
#: nothing skipped it, it simply is not in the cartridge yet.
SOURCE_FILES = "source files"
#: The project's raw graphics files, changed on disk since it was last built --
#: the other half of what :meth:`MainWindow._check_source_files` notices,
#: whether a tile editor or the editor's own save wrote them. A build is owed
#: for the shipped cartridge, so they arm Rebuild and the title like
#: :data:`SOURCE_FILES`; unlike those, every run carries them
#: (:func:`shiny_mushroom.source_files.carried_by_a_run`), so the run's notice
#: never names them.
RAW_FILES = "raw files"

#: Subjects the editor can save that **no patch can carry** into a running
#: cartridge: they reach it only through a build. Not a gatherer's reading like
#: the ones above -- nothing skipped them, and there is nothing in
#: :mod:`shiny_mushroom.cart_patches` that could, because what they save is
#: assembler text rather than bytes at a known offset. Without this they are
#: the one kind of saved edit a test run is silently missing instead of
#: reporting: the reading mechanism can only ever name subjects a gatherer
#: speaks for, and these have no gatherer at all. One key for all of them,
#: since two can be saved before one build; the build clears it.
BUILD_ONLY = "build only"
#: What that key names, as the title says them.
STRINGS = "strings"
MUSIC = "music"

#: The disassembly under the project, moved on since the cartridge was built --
#: see :meth:`MainWindow._check_disassembly`. Filed beside :data:`SOURCE_FILES`
#: because it is the same reading: the cartridge on the canvas is not the one
#: the next build produces, and the title says so once for both.
DISASSEMBLY = "disassembly"

#: What every symbol a build did not write reads as, whichever tool asked for
#: it -- :mod:`smw_tools.asm_regions` and :mod:`smw_tools.rom_tables` both end
#: their complaint this way. See :func:`_rebuild_detail`.
MISSING_LABEL = "not in the symbol file"


def _rebuild_detail(detail: str) -> str:
    """``detail``, with what to do about it where it names a label the build
    never wrote.

    :mod:`smw_tools.asm_regions` answers a save's pricing off the project's own
    symbol file and names the label it could not find there, which is the true
    and useless half of the sentence: a pool the disassembly has renamed since
    this cartridge was assembled is absent from the file rather than wrong in
    it, and what reaches the person is a label they have never typed. The
    symbol file being older than the source is the whole of the problem, so
    that is what the dialog says -- and :meth:`MainWindow._check_disassembly`
    has already said it once in the status bar.
    """
    if MISSING_LABEL not in detail:
        return detail
    return (
        f"{detail}. This cartridge was built before the disassembly that "
        f"names it -- Project > Rebuild (F5) builds it again against the "
        f"source in hand, and the save works from there."
    )
