"""The project's audio as four tabs: the music, the effects, the memory, the wiring.

A report and nothing else: it reads :mod:`shiny_mushroom.audio` and paints it,
and no gesture here changes anything. The four tabs are the four questions the
audio hardware raises and no one place answers -- *what songs are there*, *what
effects are there*, *what is in the SPC700's memory*, and *how does the game ask
for any of it* -- so a reader can follow a level's three header bits all the way
to a run of bytes in ARAM.

**The ARAM tab is drawn once per music bank, not once.** The three music banks
upload to the same address, so there is no single picture of ARAM: what is
resident depends on where the player is. Three bars, stacked, is the honest
shape -- and putting them under each other is what makes the one thing worth
seeing obvious, which is that they are three different lengths ending in the
same free space.

The bar follows the memory map's picture deliberately
(:mod:`shiny_mushroom.ui.memory_map_dialog`): flat ground first, claimed runs
laid over it, a run never narrower than a pixel, and the eye sent to the gaps.
Someone who has read one has read the other.

Colours are derived from the application palette at paint time rather than held,
so a theme switch needs nothing but the repaint Qt already sends.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtCore import QRect, QSize, Qt, Signal
from PySide6.QtGui import QColor, QMouseEvent, QPainter, QPaintEvent, QPalette
from PySide6.QtWidgets import (
    QAbstractItemView,
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QHBoxLayout,
    QLabel,
    QSizePolicy,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.audio import AudioMap, MusicBank, Segment
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.ui.tables import PickedCells, style_note, style_table
from shiny_mushroom.ui.theme import blended
from shiny_mushroom.ui.tips import wrap_tip
from smw_tools import audio

TITLE = "Audio"

MUSIC_TAB = "&Music"
SFX_TAB = "Sound &Effects"
ARAM_TAB = "&ARAM"
MAPPING_TAB = "Ma&pping"

MUSIC_HINT = (
    "Every song a music bank can play, and the value written to $1DFB to ask "
    "for it. Only one bank is in the SPC700's memory at a time, so a value "
    "means a different song depending on where the player is."
)
SFX_HINT = (
    "Every sound effect, by the mailbox that asks for it. $1DF9 and $1DFC each "
    "have their own table and their own numbering; $1DFA carries a handful of "
    "commands the engine answers itself rather than a table of effects."
)
ARAM_HINT = (
    "The SPC700's 64 KB, once for each music bank that can be resident. The "
    "engine, the sound effects and the samples are uploaded once and stay; the "
    "music window below them is rewritten every time the game changes context."
)
MAPPING_HINT = (
    "How a level ends up playing something: three bits of its header pick a row "
    "of LevelMusicTable, the row holds a music value, and the value indexes the "
    "resident bank's pointer table."
)

MUSIC_COLUMNS = (
    "Value",
    "Name",
    "Plays",
    "At",
    "Phrases",
    "Channels",
    "Loops",
    "Reaches",
)

#: The one column of the song table an edit lands in: which song the value
#: resolves to, picked from the labels the bank's own source defines.
PLAYS_COLUMN = 2
SFX_COLUMNS = ("Mailbox", "Value", "Name", "At", "Bytes", "Note")
SLOT_COLUMNS = ("Bits", "Track", "Value", "Song", "Levels")

#: The one column of the settings table an edit lands in: which track the
#: header setting names, picked from the defines the disassembly states.
TRACK_COLUMN = 1
UPLOAD_COLUMNS = ("Uploaded", "From ROM", "Bytes", "Into ARAM")

_MUSIC_NOTES = {
    "Value": "What the game writes to the music mailbox at $7E1DFB.",
    "At": "Where the song's list of phrases is in the SPC700's memory.",
    "Phrases": "How many phrases the song plays through before it ends or loops.",
    "Channels": "Which of the eight DSP voices any of its phrases uses.",
    "Plays": (
        "Which song the value resolves to, through the bank's pointer table. "
        "The name beside it is the *value's*, from the define that states it -- "
        "repoint a value and the two stop agreeing, which is the edit showing."
    ),
    "Reaches": (
        "How many bytes of the bank the song touches. Songs share phrases and "
        "whole passages of a channel, so this is a reach and not a cost: "
        "deleting a song would free far less than this."
    ),
}

_SFX_NOTES = {
    "Mailbox": "Which of the game's four sound mailboxes asks for this effect.",
    "At": "Where the effect's byte stream is in the SPC700's memory.",
    "Bytes": "How long that stream is, to the byte that ends or holds it.",
}

_SLOT_NOTES = {
    "Bits": "The value of header byte 2's bits 4-6, which is the row index.",
    "Track": "The define this row of LevelMusicTable holds. Pick another to "
    "change what every level on this setting plays.",
    "Value": "What that define is worth -- the music value itself.",
    "Levels": "Every level in the cartridge whose header picks this row.",
}

#: How tall one ARAM bar is, and the gap under it -- the memory map's bank bar,
#: which these are meant to read as.
BAR_HEIGHT = 26

#: How tall the mapping tab's upload table is allowed to get: its header and
#: the four rows it will always have, and no share of the height beyond that.
UPLOADS_HEIGHT = 140

#: The narrowest a run may be painted. The engine's own variables are 1,280 of
#: 65,536 bytes, and the warm-boot marker a quarter of that; they are part of
#: the point, so they get a mark wide enough to have a colour.
MINIMUM_WIDTH = 3

#: How far the flat ground sits from the surface behind it, and how far a run
#: the engine merely keeps is washed toward that ground. The same two numbers
#: the memory map uses, for the same reason.
GROUND_GREY = 0.22
KEPT_WASH = 0.55

#: The hues, on the memory map's one rule: what holds bytes you put there is
#: coloured, what is free is green, and what is not yours is grey. Keyed by the
#: blob that wrote the run, since that is what a reader would change.
BLOB_COLORS = {
    audio.ENGINE_BLOB: QColor(0xC2, 0x7B, 0x2E),
    audio.SAMPLES_BLOB: QColor(0x8E, 0x5B, 0xC4),
    audio.LEVEL_MUSIC_BLOB: QColor(0x3D, 0x7F, 0xC8),
    audio.OVERWORLD_MUSIC_BLOB: QColor(0x3D, 0x7F, 0xC8),
    audio.CREDITS_MUSIC_BLOB: QColor(0x3D, 0x7F, 0xC8),
}

FREE_COLOR = QColor(0x46, 0x9E, 0x5E)


def segment_color(segment: Segment, palette: QPalette) -> QColor:
    """The colour one run of ARAM is painted in.

    The ground is derived rather than written down, for the memory map's
    reason: it is the surface seen from a little way off, and a literal grey
    that reads right against the light window is a smear against the dark one.
    """
    ground = blended(
        palette.color(QPalette.ColorRole.WindowText),
        palette.color(QPalette.ColorRole.Base),
        GROUND_GREY,
    )
    if segment.free:
        return FREE_COLOR
    if segment.blob is not None:
        return BLOB_COLORS.get(segment.blob, ground)
    # A run the engine keeps at runtime: nothing was uploaded into it, so it is
    # the ground washed toward the surface rather than a colour of its own.
    return blended(palette.color(QPalette.ColorRole.Base), ground, KEPT_WASH)


def describe(segment: Segment) -> str:
    """One line about a run of ARAM: where it is, what it is, how big."""
    where = f"{hexnum(segment.start, 4)}-{hexnum(segment.end - 1, 4)}"
    return f"{where}   ·   {segment.name}   ·   {segment.size:,} bytes"


class AramBar(QWidget):
    """One reading of ARAM, painted to scale, with the run under the cursor
    pickable."""

    #: A run was hovered, or ``None`` when the cursor left the bar.
    hovered = Signal(object)

    def __init__(
        self, segments: Sequence[Segment] = (), parent: QWidget | None = None
    ) -> None:
        super().__init__(parent)
        self._segments: tuple[Segment, ...] = tuple(segments)
        self.setMouseTracking(True)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        self.setMinimumHeight(BAR_HEIGHT)

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return QSize(480, BAR_HEIGHT)

    def show_segments(self, segments: Sequence[Segment]) -> None:
        self._segments = tuple(segments)
        self.update()

    def segment_at(self, x: int) -> Segment | None:
        """Which run a point along the bar is in.

        Off the *address* rather than off the painted rectangles, so a run too
        narrow to have been drawn at its true width is still picked where it
        really is -- the picture rounds, and this must not.
        """
        if not self._segments:
            return None
        width = max(self.width(), 1)
        at = min(int(x * audio.ARAM_SIZE / width), audio.ARAM_SIZE - 1)
        for one in self._segments:
            if one.start <= at < one.end:
                return one
        return None

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        palette = self.palette()
        area = self.rect()
        ground = blended(
            palette.color(QPalette.ColorRole.WindowText),
            palette.color(QPalette.ColorRole.Base),
            GROUND_GREY,
        )
        painter.fillRect(area, ground)
        for one, box in self._boxes(area):
            painter.fillRect(box, segment_color(one, palette))
        painter.setPen(ground.darker(140))
        painter.drawRect(area.adjusted(0, 0, -1, -1))

    def _boxes(self, area: QRect) -> list[tuple[Segment, QRect]]:
        """Every run and the rectangle it gets.

        Both edges are rounded from the run's own address, so neighbours share
        an edge exactly and the bar has no seams; a run that rounds to nothing
        is widened rather than dropped.
        """
        made = []
        for one in self._segments:
            left = round(one.start * area.width() / audio.ARAM_SIZE)
            right = round(one.end * area.width() / audio.ARAM_SIZE)
            width = max(right - left, MINIMUM_WIDTH)
            made.append((one, QRect(left, area.top(), width, area.height())))
        return made

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        found = self.segment_at(event.position().toPoint().x())
        self.setToolTip(describe(found) if found is not None else "")
        self.hovered.emit(found)

    def leaveEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        self.hovered.emit(None)
        super().leaveEvent(event)


class AudioDialog(QDialog):
    """The Audio window: a report over the cartridge, with two tables editable.

    Handed an :class:`~shiny_mushroom.audio.AudioMap` and painting it. The two
    edits it offers are the two hops from a level to a song that do not mean
    touching sequence data -- which track a header setting names, and which song
    a music value resolves to -- and neither is performed here: a pick is a
    signal the window answers, because the window owns the project the tables
    are written into and the rebuild the edit needs.
    """

    #: A music value should resolve to another song: blob, value, song label.
    repoint_asked = Signal(str, int, str)
    #: A header music setting should name another track: setting, define.
    track_asked = Signal(int, str)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self.setMinimumSize(860, 520)
        self._map: AudioMap | None = None
        #: One bar and one caption per music bank, keyed by the blob whose
        #: residency that reading assumes.
        self._bars: dict[str, AramBar] = {}
        self._captions: dict[str, QLabel] = {}

        self._tabs = QTabWidget(self)
        self._tabs.addTab(self._build_music(), MUSIC_TAB)
        self._tabs.addTab(self._build_sfx(), SFX_TAB)
        self._tabs.addTab(self._build_aram(), ARAM_TAB)
        self._tabs.addTab(self._build_mapping(), MAPPING_TAB)

        layout = QVBoxLayout(self)
        layout.addWidget(self._tabs, 1)
        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    # -- building --------------------------------------------------------------

    def _table(self, columns: Sequence[str], notes: dict[str, str]) -> QTableWidget:
        """A read-only table in the look every table in the editor shares."""
        table = QTableWidget(0, len(columns), self)
        table.setHorizontalHeaderLabels(list(columns))
        for column, name in enumerate(columns):
            held = notes.get(name)
            if held is not None and table.horizontalHeaderItem(column) is not None:
                table.horizontalHeaderItem(column).setToolTip(wrap_tip(held))
        table.verticalHeader().setVisible(False)
        table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        # Read-only unless the caller arms a column; the two that are editable
        # say so for themselves.
        table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        style_table(table)
        return table

    def _page(self, hint: str, *widgets: QWidget) -> QWidget:
        page = QWidget(self)
        layout = QVBoxLayout(page)
        note = QLabel(hint, page)
        note.setWordWrap(True)
        style_note(note)
        layout.addWidget(note)
        for widget in widgets:
            widget.setParent(page)
            layout.addWidget(widget, 1 if isinstance(widget, QTableWidget) else 0)
        return page

    def _build_music(self) -> QWidget:
        picker = QHBoxLayout()
        self._bank_pick = QComboBox(self)
        self._bank_pick.setToolTip(
            wrap_tip(
                "Which music bank to read. All three upload to the same place, "
                "so only one of them is ever in the SPC700's memory."
            )
        )
        self._bank_pick.currentIndexChanged.connect(self._show_bank)
        picker.addWidget(QLabel("Bank:", self))
        picker.addWidget(self._bank_pick, 1)
        row = QWidget(self)
        row.setLayout(picker)

        self._songs = self._table(MUSIC_COLUMNS, _MUSIC_NOTES)
        self._songs.setEditTriggers(
            QAbstractItemView.EditTrigger.DoubleClicked
            | QAbstractItemView.EditTrigger.SelectedClicked
            | QAbstractItemView.EditTrigger.EditKeyPressed
        )
        cells = PickedCells(self._songs, self._song_choices, self._song_current)
        cells.committed.connect(self._song_picked)
        self._songs.setItemDelegate(cells)
        self._bank_note = QLabel("", self)
        self._bank_note.setWordWrap(True)
        style_note(self._bank_note)
        return self._page(MUSIC_HINT, row, self._songs, self._bank_note)

    def _build_sfx(self) -> QWidget:
        self._effects = self._table(SFX_COLUMNS, _SFX_NOTES)
        self._sfx_note = QLabel("", self)
        self._sfx_note.setWordWrap(True)
        style_note(self._sfx_note)
        return self._page(SFX_HINT, self._effects, self._sfx_note)

    def _build_aram(self) -> QWidget:
        page = QWidget(self)
        layout = QVBoxLayout(page)
        note = QLabel(ARAM_HINT, page)
        note.setWordWrap(True)
        style_note(note)
        layout.addWidget(note)
        for blob in audio.MUSIC_BLOBS:
            caption = QLabel("", page)
            style_note(caption)
            layout.addWidget(caption)
            bar = AramBar((), page)
            bar.hovered.connect(self._aram_hovered)
            layout.addWidget(bar)
            self._bars[blob] = bar
            self._captions[blob] = caption
        self._aram_note = QLabel("", page)
        self._aram_note.setWordWrap(True)
        self._aram_note.setMinimumHeight(48)
        self._aram_note.setAlignment(
            Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft
        )
        style_note(self._aram_note)
        layout.addWidget(self._aram_note)
        layout.addStretch(1)
        return page

    def _build_mapping(self) -> QWidget:
        self._slots = self._table(SLOT_COLUMNS, _SLOT_NOTES)
        self._slots.setEditTriggers(
            QAbstractItemView.EditTrigger.DoubleClicked
            | QAbstractItemView.EditTrigger.SelectedClicked
            | QAbstractItemView.EditTrigger.EditKeyPressed
        )
        cells = PickedCells(self._slots, self._track_choices, self._track_current)
        cells.committed.connect(self._track_picked)
        self._slots.setItemDelegate(cells)
        self._uploads = self._table(UPLOAD_COLUMNS, {})
        # Four rows and never more, so the uploads take what they hold and the
        # eight slots -- which is what the tab is for -- take the rest.
        self._uploads.setMaximumHeight(UPLOADS_HEIGHT)
        self._uploads.setSizePolicy(
            QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Maximum
        )
        self._mapping_note = QLabel("", self)
        self._mapping_note.setWordWrap(True)
        style_note(self._mapping_note)
        return self._page(MAPPING_HINT, self._slots, self._uploads, self._mapping_note)

    # -- filling ---------------------------------------------------------------

    def show_audio(self, read: AudioMap) -> None:
        """Show one reading of the project's cartridge."""
        self._map = read
        held = self._bank_pick.currentData()
        self._bank_pick.blockSignals(True)
        self._bank_pick.clear()
        for bank in read.banks:
            self._bank_pick.addItem(
                f"{bank.name}  ({len(bank.songs)} songs)", bank.blob
            )
        wanted = max(self._bank_pick.findData(held), 0)
        self._bank_pick.setCurrentIndex(wanted)
        self._bank_pick.blockSignals(False)
        self._show_bank()
        self._fill_sfx(read)
        self._fill_aram(read)
        self._fill_mapping(read)

    def _show_bank(self) -> None:
        if self._map is None:
            return
        blob = self._bank_pick.currentData()
        bank = self._map.bank(blob) if blob else None
        if bank is None:
            self._songs.setRowCount(0)
            self._bank_note.setText("")
            return
        self._songs.setRowCount(len(bank.songs))
        for row, song in enumerate(bank.songs):
            channels = ", ".join(str(one + 1) for one in song.channels)
            self._cells(
                self._songs,
                row,
                (
                    hexnum(song.value, 2),
                    song.name,
                    song.label,
                    hexnum(song.pointer, 4),
                    f"{len(song.song.phrases)}",
                    channels,
                    "yes" if song.loops else "",
                    f"{song.size:,}",
                ),
            )
        self._songs.resizeColumnsToContents()
        self._bank_note.setText(_bank_note(bank))

    def _fill_sfx(self, read: AudioMap) -> None:
        self._effects.setRowCount(len(read.sfx))
        for row, effect in enumerate(read.sfx):
            self._cells(
                self._effects,
                row,
                (
                    hexnum(effect.port & 0xFFFF, 4),
                    hexnum(effect.value, 2),
                    effect.name,
                    hexnum(effect.pointer, 4),
                    f"{effect.size:,}",
                    "same bytes as an earlier value" if effect.cloned else "",
                ),
            )
        self._effects.resizeColumnsToContents()
        distinct = len({(one.port, one.pointer) for one in read.sfx})
        self._sfx_note.setText(
            f"{len(read.sfx)} entries over {distinct} distinct streams -- the "
            f"rest are values pointing at an effect another value already names. "
            f"$1DFA is not in this table: its four values are commands the "
            f"engine answers itself, not entries in a table."
        )

    def _fill_aram(self, read: AudioMap) -> None:
        for bank in read.banks:
            bar = self._bars.get(bank.blob)
            if bar is None:
                continue
            bar.show_segments(read.layout.get(bank.blob, ()))
            caption = self._captions.get(bank.blob)
            if caption is not None:
                caption.setText(
                    f"{bank.name} resident -- its {bank.size:,} bytes reach "
                    f"{hexnum(bank.end - 1, 4)}"
                )
        self._aram_note.setText(_aram_note(read))

    def _fill_mapping(self, read: AudioMap) -> None:
        self._slots.setRowCount(len(read.slots))
        for row, slot in enumerate(read.slots):
            levels = ", ".join(hexnum(one, 3) for one in slot.levels[:12])
            if len(slot.levels) > 12:
                levels += f", and {len(slot.levels) - 12} more"
            self._cells(
                self._slots,
                row,
                (
                    str(slot.slot),
                    slot.name,
                    hexnum(slot.value, 2),
                    slot.song.label if slot.song is not None else "no such value",
                    f"{len(slot.levels)}   {levels}",
                ),
            )
        self._slots.resizeColumnsToContents()

        uploads = _uploads(read)
        self._uploads.setRowCount(len(uploads))
        for row, cells in enumerate(uploads):
            self._cells(self._uploads, row, cells)
        self._uploads.resizeColumnsToContents()
        self._mapping_note.setText(_mapping_note(read))

    # -- picking -------------------------------------------------------------

    def _song_choices(self, row: int, column: int):
        """Every song this bank's source defines, for the Plays column."""
        if column != PLAYS_COLUMN or self._map is None:
            return None
        blob = self._bank_pick.currentData()
        return [(one, one) for one in self._map.songs_offered.get(blob, ())]

    def _song_current(self, row: int, column: int) -> int:
        offered = self._song_choices(row, column)
        bank = self._map.bank(self._bank_pick.currentData()) if self._map else None
        if not offered or bank is None or row >= len(bank.songs):
            return -1
        held = bank.songs[row].label
        return next((n for n, (_, one) in enumerate(offered) if one == held), -1)

    def _song_picked(self, row: int, column: int, value: object) -> None:
        if column != PLAYS_COLUMN or self._map is None:
            return
        bank = self._map.bank(self._bank_pick.currentData())
        if bank is None or row >= len(bank.songs):
            return
        self.repoint_asked.emit(bank.blob, bank.songs[row].value, str(value))

    def _track_choices(self, row: int, column: int):
        """Every track the disassembly names, for the Track column."""
        if column != TRACK_COLUMN or self._map is None:
            return None
        return [
            (f"{one.name}   ({hexnum(one.value, 2)})", one.define)
            for one in self._map.tracks_offered
        ]

    def _track_current(self, row: int, column: int) -> int:
        offered = self._track_choices(row, column)
        if not offered or self._map is None or row >= len(self._map.slots):
            return -1
        held = self._map.slots[row].value
        names = {one.define: one.value for one in self._map.tracks_offered}
        return next((n for n, (_, one) in enumerate(offered) if names[one] == held), -1)

    def _track_picked(self, row: int, column: int, value: object) -> None:
        if column != TRACK_COLUMN or self._map is None or row >= len(self._map.slots):
            return
        self.track_asked.emit(self._map.slots[row].slot, str(value))

    def _cells(self, table: QTableWidget, row: int, values: Sequence[str]) -> None:
        for column, value in enumerate(values):
            table.setItem(row, column, QTableWidgetItem(value))

    def _aram_hovered(self, segment: Segment | None) -> None:
        if segment is None:
            if self._map is not None:
                self._aram_note.setText(_aram_note(self._map))
            return
        self._aram_note.setText(describe(segment))


def _bank_note(bank: MusicBank) -> str:
    """What one music bank costs, and what nothing in it points at."""
    unreached = ""
    if bank.unreached:
        unreached = (
            f"   {bank.unreached:,} bytes of it are reached by no song -- the "
            f"phrase rows the disassembly marks unused."
        )
    return (
        f"{bank.size:,} bytes at {hexnum(bank.aram, 4)}, from "
        f"{hexnum(bank.address, 6)} in the cartridge.{unreached}"
    )


def _aram_note(read: AudioMap) -> str:
    """The standing readout under the bars, replaced while a run is hovered."""
    return (
        f"The music window is at {hexnum(read.window, 4)} and the largest bank "
        f"in it needs {read.window_size:,} bytes. Whatever bank is resident, at "
        f"least {read.free:,} bytes of the 65,536 are free. Point at a run to "
        f"read it."
    )


def _uploads(read: AudioMap) -> list[tuple[str, str, str, str]]:
    """One row per blob the game uploads, in the order a session uploads them."""
    rows: list[tuple[str, str, str, str]] = []
    engine = (
        "engine, effects and overworld music"
        if read.boot_runs_on
        else "engine and effects"
    )
    rows.append(("At boot", "", "", engine))
    for bank in read.banks:
        rows.append(
            (
                bank.name,
                hexnum(bank.address, 6),
                f"{bank.rom_size:,}",
                f"{hexnum(bank.aram, 4)}-{hexnum(bank.end - 1, 4)}",
            )
        )
    return rows


def _mapping_note(read: AudioMap) -> str:
    """The part of the wiring no table has a row for."""
    runs_on = ""
    if read.boot_runs_on:
        runs_on = (
            "  The engine's upload carries no terminator, so the boot upload "
            "runs straight on into the overworld music bank behind it in ROM -- "
            "which is why the title screen has music before any bank has been "
            "asked for."
        )
    return (
        "$1DFB takes a music value, $1DF9 and $1DFC a sound effect, and $1DFA "
        "one of four commands the engine answers itself.  A music value is only "
        "meaningful against the bank that happens to be resident: the same $07 "
        "is a ghost house in a level and Bowser's Valley on the world map." + runs_on
    )
