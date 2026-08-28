"""The project's graphics files, as a dialog: the catalogue, one file's tiles
drawn under a palette row, and the things that can be done to a file --
export it as a PNG, import one back, copy it to the clipboard, paste one
over it, revert it -- and to the set: add a file of the project's own,
duplicate one, name it, move it to another slot, and delete it again.

The overlay is the state and this is a view of it, exactly as the Source
Files dialog is (:mod:`shiny_mushroom.ui.source_files_dialog`): a save writes
the raw ``.bin``, a revert or a delete deletes it, there is no OK/Cancel
pair, and the window is told through :attr:`GraphicsDialog.overlay_changed`
when a file moved so it can load the level again -- an edited file is
previewed by relocation on the next load. Everything the rows say and every
byte written comes out of :mod:`shiny_mushroom.graphics`, which knows nothing
about Qt; this file draws it and asks.

**An added file needs the managed graphics banks.** The dialog does not throw
that switch: a feature is a project setting that rebuilds the cartridge, and
the window owns that flow (:meth:`MainWindow._want_feature`). So a gesture
that needs the feature on a project without it says so through
:attr:`GraphicsDialog.feature_needed` and stops, and the window finishes the
gesture -- on the dialog it reopens, since the rebuild's reopen puts this one
away with the outgoing cartridge. A save that takes a graphics bank hands
back a project the dialog adopts, and the window is told through
:attr:`GraphicsDialog.project_replaced` so it builds the grown cartridge too.

**Nothing watches the overlay.** A raw file the project holds is an ordinary
file in a folder Open Folder shows, so anything on the desktop can save over
one; the dialog re-reads whatever moved when it is given the focus back,
which is when that has just happened. A stat apiece
(:func:`shiny_mushroom.graphics.stamps`) decides whether there is anything to
re-read, which is what makes that affordable on every activation.

**A file's name is the project's, its slot is the cartridge's.** An added
file is kept under whatever name somebody gave it and packs into the slot the
project records against that name
(:meth:`~shiny_mushroom.project.Project.added_graphics_slots`), so Rename is
the file's rename and touches nothing a build reads, while Reposition moves
the slot and re-prices the packing. The Purpose column is the name for those
rows, since what an added file is for is its author's to say.
"""

from __future__ import annotations

from collections.abc import Sequence
from pathlib import Path

from PySide6.QtCore import QEvent, QMimeData, Qt, Signal
from PySide6.QtGui import QGuiApplication, QImage, QKeySequence, QShortcut
from PySide6.QtWidgets import (
    QAbstractItemView,
    QCheckBox,
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QSplitter,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import graphics, palettes
from shiny_mushroom.graphics import (
    Colour,
    GraphicsError,
    GraphicsFile,
    Kind,
    PaletteRow,
)
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.project import Project, ProjectError
from shiny_mushroom.project_graphics import GraphicsBanksFull, GraphicsSaved
from shiny_mushroom.ui.dialogs import open_folder
from shiny_mushroom.ui.graphics_asks import (
    ADDED_FORMATS,
    FILE,
    AddGraphicsFileDialog,
    FileNameDialog,
    FileNumberDialog,
    answered,
    format_name,
)
from shiny_mushroom.ui.palette_grid import Swatch, SwatchGrid
from shiny_mushroom.ui.render import raster_to_image
from shiny_mushroom.ui.settings import load_str_setting, save_str_setting
from shiny_mushroom.ui.tables import PaddedCells, style_note, style_table
from shiny_mushroom.ui.tile_sheet import TileSheet
from shiny_mushroom.ui.tips import wrap_tip
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker
from smw_tools import graphics as codec
from smw_tools import graphics_memory, packed
from smw_tools.graphics import TILE_PIXELS, TileFormat

TITLE = "Graphics Files"

#: What the list is, and the one idea a reader has to be handed: the raw file
#: in the project is the edit, and everything here is a way of making one.
HINT = (
    "Each row is a graphics file the build reads. Export one to a PNG and "
    "import it back, copy and paste through the clipboard, or edit the "
    "project's copy in place through Open Folder. Add File adds a file of the "
    "project's own; Duplicate File copies the one on show."
)

#: The gestures that need the managed graphics banks, as
#: :attr:`GraphicsDialog.feature_needed` names them.
ADD = "add"
DUPLICATE = "duplicate"
DELETE = "delete"

COLUMNS = ("File", "Purpose", "Format", "Tiles", "Status")

#: Where every PNG chooser here opens -- the export's, the import's and the
#: add's -- remembered the way the ROM export's folder is: one folder for
#: the file a reader is passing back and forth.
EXPORT_FOLDER_KEY = "graphics/export_folder"

PNG_FILTER = "PNG pictures (*.png);;All files (*)"

#: The clipboard format a copy puts the file's own indexed picture under,
#: beside the bitmap every other application reads. It is an exported PNG
#: byte for byte, so a paste of one is an import: the indices come back as
#: they were rather than through a colour match, and the ``shiny-mushroom``
#: text refuses a file of the wrong format or size the same way.
TILES_MIME = "application/x-shiny-mushroom-tiles"

#: The row on offer when neither a level nor the palette file can give one:
#: sixteen greys, so a sheet can always be drawn.
GREYS = PaletteRow("Greys", tuple((n * 17, n * 17, n * 17) for n in range(16)))

_COLUMN_NOTES = {
    "Format": (
        "How the file's tiles are laid out. A 3bpp file is drawn under a full "
        "row of sixteen: the loader moves some of its colours to indices "
        "8-15."
    ),
    "Status": ("Whether the project holds its own copy, and what that copy costs."),
}

#: The item data slot holding the row's file number.
_NUMBER_ROLE = Qt.ItemDataRole.UserRole


def _name(number: int) -> str:
    """``GFX1E`` for ``0x1E``, stock or added -- the codec's own spelling,
    which its :func:`~smw_tools.graphics.file_name` refuses past the set."""
    return f"GFX{number:02X}"


def status_text(row: GraphicsFile, changed: int) -> str:
    """What a row's Status column says: stock, added and what it packs to,
    or edited and what it cost."""
    if row.kind is Kind.ADDED:
        return f"added, {format_name(row.format)}, {row.encoded:,} bytes"
    if not row.edited:
        return "stock"
    if row.grown > 0:
        return f"edited, grown by {row.grown:,} bytes"
    return f"edited ({changed} tile{'s' if changed != 1 else ''})"


def room_text(room: graphics.Room) -> str:
    return (
        f"Graphics run: {room.used:,} / {room.budget:,} bytes "
        f"({room.free:,} {'free' if room.free >= 0 else 'over'})"
    )


def rooms_text(rooms: Sequence[graphics.Room]) -> str:
    """The footer where the graphics are managed: every run the packer
    fills, each at what it holds against its size."""
    listed = "; ".join(
        f"{room.name}: {room.used:,} / {room.budget:,}" for room in rooms
    )
    return f"Graphics runs: {listed} bytes"


def blank_tiles(fmt: TileFormat) -> list[bytes]:
    """An added file of ``fmt`` with every pixel colour 0: what a new file
    starts as, and what a PNG imported into one is read against."""
    return [bytes(TILE_PIXELS)] * added_count(fmt)


def added_count(fmt: TileFormat) -> int:
    """How many tiles an added file of ``fmt`` holds -- one length per
    format (:func:`smw_tools.packed.added_raw_size`), so every added file is
    the same 128 tiles whichever of the two it is."""
    return packed.added_raw_size(fmt) // fmt.tile_bytes


def added_format(fmt: TileFormat) -> TileFormat:
    """The format a copy of a ``fmt`` file is added in.

    An added file is 3bpp or 4bpp (:data:`ADDED_FORMATS`), so only a 4bpp
    file keeps its own layout; the rest are copied as 3bpp, which loses no
    pixel -- a 2bpp file's indices run to 3 and the Mode 7 file's to 7, both
    inside the eight a 3bpp file holds.
    """
    return fmt if fmt in ADDED_FORMATS else TileFormat.PLANAR_3BPP


def copied_shape(fmt: TileFormat, tiles: int) -> packed.AddedShape:
    """The shape a copy of a file of ``fmt`` holding ``tiles`` tiles is
    added as.

    The source's own shape wherever an added file may be it, which is what
    keeps a copy of the animated tiles the animated tiles: their 384 is a
    shape a project adds (:data:`~smw_tools.packed.ADDED_SHAPES`), so a copy
    of ``GFX33`` is one of those rather than the first 128 of it. Anything
    else is copied as the slot shape of :func:`added_format`'s layout.
    """
    layout = added_format(fmt)
    exact = next(
        (
            shape
            for shape in packed.ADDED_SHAPES
            if shape.format is layout and shape.tiles == tiles
        ),
        None,
    )
    return exact if exact is not None else packed.shape_for_format(layout)


def fitted_tiles(tiles: Sequence[bytes], shape: packed.AddedShape) -> list[bytes]:
    """``tiles`` as an added file of ``shape`` holds them: its first
    :attr:`~smw_tools.packed.AddedShape.tiles` of them, blank tiles behind a
    file that has fewer."""
    count = shape.tiles
    return list(tiles[:count]) + [bytes(TILE_PIXELS)] * max(0, count - len(tiles))


def image_tiles(
    image: QImage,
    fmt: TileFormat,
    baseline_tiles: Sequence[bytes],
    palette: Sequence[Colour],
) -> list[bytes]:
    """A ``QImage`` as tiles, matched against ``palette``.

    The one place a picture reaches the model as pixels rather than as a PNG:
    a bitmap off the clipboard carries no palette of its own, so every pixel
    is matched (:func:`shiny_mushroom.graphics.import_pixels`). Qt is asked
    for RGBA8888, whose four bytes a pixel need no scanline padding, so the
    buffer is the model's own layout.
    """
    rgba = image.convertToFormat(QImage.Format.Format_RGBA8888)
    return graphics.import_pixels(
        bytes(rgba.constBits()),
        rgba.width(),
        rgba.height(),
        fmt,
        baseline_tiles,
        palette,
    )


def duplicate_note(row: GraphicsFile) -> str:
    """What a copy of ``row`` is not, in a sentence, or ``""`` where the copy
    is the file: an added file is one of the shapes a project may add
    (:func:`copied_shape`), so a file that is none of them is copied as much
    of it as the nearest one fits."""
    shape = copied_shape(row.format, row.tiles)
    count = shape.tiles
    said = []
    if shape.format is not row.format:
        said.append(f"as a {format_name(shape.format)} file")
    if row.tiles > count:
        said.append(f"as its first {count} tiles of {row.tiles}")
    elif row.tiles < count:
        said.append(f"as {count} tiles, the {count - row.tiles} behind it blank")
    return f"The copy is added {' and '.join(said)}." if said else ""


class GraphicsDialog(QDialog):
    """One project's graphics files. Construct, ``show``, and connect
    :attr:`overlay_changed`, :attr:`feature_needed` and
    :attr:`project_replaced`."""

    #: A file in the overlay moved -- imported, added, deleted, reverted, or
    #: saved from outside and noticed on focus. Once per gesture or sweep,
    #: not per file: what the window does with it is load the level again.
    overlay_changed = Signal()

    #: A gesture needs the managed graphics banks and the project has not
    #: got them: :data:`ADD`, :data:`DUPLICATE` or :data:`DELETE`, and the
    #: file number it was about -- the one to copy or delete, ``-1`` for an
    #: add. The dialog stops there; the window offers the feature and
    #: finishes the gesture on the dialog it reopens
    #: (:meth:`MainWindow._graphics_feature_needed`).
    feature_needed = Signal(str, int)

    #: A save took a graphics bank, and the project that builds the grown
    #: cartridge is a new one -- adopted here already, and handed to the
    #: window with the save's own note, so it holds the same project and
    #: says what happened.
    project_replaced = Signal(object, str)

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._project = project
        self._rows: list[GraphicsFile] = []
        #: What the overlay's raw graphics files looked like when last read
        #: -- see :meth:`_recheck`.
        self._stamps: dict[Path, tuple[int, int]] = {}
        #: The level on screen's CGRAM, or ``None`` with no level open.
        self._cgram: bytes | None = None
        #: The file on show and its tiles, decoded once per selection.
        self._number: int | None = None
        self._tiles: list[bytes] = []
        self._changed: set[int] = set()
        self._palette_rows: list[PaletteRow] = []
        #: Whether the row on show was somebody's choice rather than the
        #: file's default -- a choice is kept, by name, across files and
        #: levels; a default is made again for each.
        self._chosen = False
        #: Whether the splitter has been given its opening widths -- see
        #: :meth:`_refill`.
        self._sized = False
        self.setWindowTitle(TITLE)
        self.setMinimumSize(1100, 600)

        layout = QVBoxLayout(self)
        hint = QLabel(HINT)
        style_note(hint)
        layout.addWidget(hint)

        split = QSplitter(Qt.Orientation.Horizontal)
        layout.addWidget(split, 1)

        self._table = QTableWidget(0, len(COLUMNS))
        self._table.setHorizontalHeaderLabels(COLUMNS)
        for column, name in enumerate(COLUMNS):
            note = _COLUMN_NOTES.get(name)
            if note is not None:
                self._table.horizontalHeaderItem(column).setToolTip(wrap_tip(note))
        self._table.verticalHeader().setVisible(False)
        self._table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self._table.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        style_table(self._table)
        self._table.setItemDelegate(PaddedCells(self._table))
        self._table.currentCellChanged.connect(lambda *_a: self._selected())
        split.addWidget(self._table)

        side = QWidget()
        side_layout = QVBoxLayout(side)
        side_layout.setContentsMargins(0, 0, 0, 0)
        controls = QHBoxLayout()
        palette_label = QLabel("&Palette row:")
        controls.addWidget(palette_label)
        self._palette_pick = QComboBox()
        palette_label.setBuddy(self._palette_pick)
        self._palette_pick.setSizeAdjustPolicy(
            QComboBox.SizeAdjustPolicy.AdjustToContents
        )
        self._palette_pick.currentIndexChanged.connect(lambda _i: self._draw())
        self._palette_pick.activated.connect(lambda _i: self._choose())
        controls.addWidget(self._palette_pick, 1)
        zoom_label = QLabel("&Zoom:")
        controls.addWidget(zoom_label)
        self._sheet = TileSheet()
        self._sheet.hovered.connect(self._hovered)
        # The sheet is built here rather than beside its scroll area because
        # the picker drives it: one setting, whatever moved it -- this box or
        # Ctrl and the wheel over the sheet itself.
        self._zoom_pick = ZoomPicker()
        self._zoom_pick.setToolTip("Ctrl and the wheel over the sheet zoom too.")
        zoom_label.setBuddy(self._zoom_pick)
        controls.addWidget(self._zoom_pick)
        self._hatch = QCheckBox("&Hatch colour 0")
        self._hatch.setChecked(self._sheet.hatched)
        self._hatch.setToolTip(
            "Show colour 0 as a hatch instead of the row's own colour."
        )
        self._hatch.toggled.connect(self._sheet_hatched)
        controls.addWidget(self._hatch)
        side_layout.addLayout(controls)

        self._swatches = SwatchGrid(columns=16, cell=14)
        self._swatches.setToolTip("The colours the sheet is drawn under")
        side_layout.addWidget(self._swatches, 0, Qt.AlignmentFlag.AlignLeft)

        side_layout.addWidget(ZoomedArea(self._sheet, self._zoom_pick), 1)

        self._hover = QLabel()
        style_note(self._hover)
        side_layout.addWidget(self._hover)
        split.addWidget(side)
        split.setStretchFactor(0, 0)
        split.setStretchFactor(1, 1)
        self._split = split

        self._room = QLabel()
        style_note(self._room)
        layout.addWidget(self._room)

        self._moved = QLabel()
        style_note(self._moved)
        self._moved.setVisible(False)
        layout.addWidget(self._moved)

        row = QHBoxLayout()
        self._export = QPushButton("&Export PNG...")
        self._export.setToolTip("Write the tiles as an indexed PNG, sixteen to a row.")
        self._export.clicked.connect(self._export_png)
        row.addWidget(self._export)
        self._import = QPushButton("&Import PNG...")
        self._import.setToolTip(
            wrap_tip(
                "Read a PNG into the file. A flattened one is matched against the "
                "row on show."
            )
        )
        self._import.clicked.connect(self._import_png)
        row.addWidget(self._import)
        self._copy = QPushButton("&Copy")
        self._copy.setToolTip(
            wrap_tip(
                "Copy the sheet as a picture, and as indices for a paste back here."
            )
        )
        self._copy.clicked.connect(self._copy_tiles)
        row.addWidget(self._copy)
        self._paste = QPushButton("Pas&te")
        self._paste.setToolTip(
            wrap_tip(
                "Paste a picture into the file. One copied elsewhere is matched "
                "against the row on show."
            )
        )
        self._paste.clicked.connect(self._paste_tiles)
        row.addWidget(self._paste)
        self._add = QPushButton("&Add File...")
        self._add.setToolTip(
            wrap_tip(
                f"Add a graphics file, GFX{graphics_memory.FIRST_ADDED:02X} to "
                f"GFX{graphics_memory.LAST_ADDED:02X}, blank or from a PNG. "
                f"Needs Growable graphics; the first add offers to turn it on."
            )
        )
        self._add.clicked.connect(self.add_file)
        row.addWidget(self._add)
        self._duplicate = QPushButton("D&uplicate File...")
        self._duplicate.setToolTip(
            wrap_tip(
                "Copy the file on show into a number of the project's own. Needs "
                "Growable graphics."
            )
        )
        self._duplicate.clicked.connect(self._duplicate_file)
        row.addWidget(self._duplicate)
        row.addStretch()
        self._revert = QPushButton("&Revert")
        self._revert.setToolTip(
            "Take the project's copy out; the game's own comes back."
        )
        self._revert.clicked.connect(self._revert_file)
        row.addWidget(self._revert)
        # Rename and Delete stand where Revert does, for a row that has
        # nothing to revert to: an added file has no shipped stream behind
        # it, and its number is the project's to choose rather than the
        # game's.
        self._rename = QPushButton("Re&name...")
        self._rename.setToolTip(
            wrap_tip("Rename the added file's own copy. Nothing a level names changes.")
        )
        self._rename.clicked.connect(self._rename_file)
        self._rename.setVisible(False)
        row.addWidget(self._rename)
        self._reposition = QPushButton("Re&position...")
        self._reposition.setToolTip(
            wrap_tip(
                f"Pack the added file into another slot, GFX"
                f"{graphics_memory.FIRST_ADDED:02X} to "
                f"GFX{graphics_memory.LAST_ADDED:02X}. A level naming the old "
                f"slot has to be repointed."
            )
        )
        self._reposition.clicked.connect(self._reposition_file)
        self._reposition.setVisible(False)
        row.addWidget(self._reposition)
        self._delete = QPushButton("&Delete")
        self._delete.setToolTip(
            wrap_tip(
                "Take the added file out of the project; nothing ships in its place."
            )
        )
        self._delete.clicked.connect(self._delete_file)
        self._delete.setVisible(False)
        row.addWidget(self._delete)
        layout.addLayout(row)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        folder = buttons.addButton(
            "Open &Folder", QDialogButtonBox.ButtonRole.ActionRole
        )
        folder.setToolTip("Show the folder the project's own copies are in.")
        folder.clicked.connect(self._open_folder)
        layout.addWidget(buttons)

        # The buttons carry mnemonics like every other here; Ctrl+C and Ctrl+V
        # are what a hand reaches for over a picture, and nothing else in the
        # dialog answers them.
        QShortcut(QKeySequence.StandardKey.Copy, self, self._copy_tiles)
        QShortcut(QKeySequence.StandardKey.Paste, self, self._paste_tiles)

        self._refill()
        if self._rows:
            self._table.setCurrentCell(0, 0)

    # -- what the window tells it ---------------------------------------------

    def set_cgram(self, cgram: bytes | None) -> None:
        """The level on screen's colours, or ``None`` with no level open.

        The rows on offer follow: the level's sixteen rows first, then the
        palette file's runs. The row picked stays picked by name where the
        new list still has it.
        """
        if cgram == self._cgram:
            return
        self._cgram = cgram
        self._offer_rows()
        self._draw()

    @property
    def project(self) -> Project:
        """The project the rows are read from -- not always the one handed in,
        since a save that took a graphics bank hands back a new one."""
        return self._project

    def adopt(self, project: Project) -> None:
        """Read from ``project`` from here on: the one a feature switch or a
        grown save handed back, over the same folder."""
        if project is self._project:
            return
        self._project = project
        self._refill()
        self._read_tiles()
        self._draw()
        self._sync_buttons()

    @property
    def number(self) -> int | None:
        """The file on show."""
        return self._number

    @property
    def palette_row(self) -> PaletteRow | None:
        index = self._palette_pick.currentIndex()
        if not 0 <= index < len(self._palette_rows):
            return None
        return self._palette_rows[index]

    def pick_palette_row(self, name: str) -> bool:
        """Draw under the row called ``name``, as a choice -- see
        :attr:`_chosen`."""
        for index, row in enumerate(self._palette_rows):
            if row.name == name:
                self._palette_pick.setCurrentIndex(index)
                self._choose()
                return True
        return False

    def _choose(self) -> None:
        self._chosen = True

    def select(self, number: int) -> None:
        for index, row in enumerate(self._rows):
            if row.number == number:
                self._table.setCurrentCell(index, 0)
                return

    # -- the list -------------------------------------------------------------

    def _refill(self, stamps: dict[Path, tuple[int, int]] | None = None) -> None:
        """Read the catalogue again, keeping the row somebody was on -- or,
        where that file has gone, following the table onto whatever took its
        place, so that the sheet and the buttons are the row on show."""
        chosen = self._number
        self._stamps = graphics.stamps(self._project) if stamps is None else stamps
        self._rows = graphics.files(self._project)
        self._table.setRowCount(len(self._rows))
        for index, row in enumerate(self._rows):
            self._fill_row(index, row)
        self._table.resizeColumnsToContents()
        if not self._sized:
            # The list opens at the width its columns ask for and the sheet
            # takes the rest -- once, since every later read of the catalogue
            # would otherwise undo a split somebody dragged.
            self._sized = True
            wanted = sum(self._table.columnWidth(n) for n in range(len(COLUMNS))) + 24
            self._split.setSizes([wanted, max(360, self.width() - wanted)])
        self._room.setText(self._room_text())
        if chosen is not None:
            self.select(chosen)
        # A deleted file leaves the table on a row of its own choosing, and
        # the number it was showing names nothing: the rest of the dialog
        # reads that number, so it is put back onto the row the table is on.
        if self._number is not None and self._row_named(self._number) is None:
            self._selected()
        self._sync_buttons()

    def _fill_row(self, index: int, row: GraphicsFile) -> None:
        changed = (
            len(graphics.changed_tiles(self._project, row.number)) if row.edited else 0
        )
        cells = (
            row.name,
            row.purpose,
            format_name(row.format),
            str(row.tiles),
            status_text(row, changed),
        )
        for column, text in enumerate(cells):
            item = QTableWidgetItem(text)
            item.setData(_NUMBER_ROLE, row.number)
            if column == 3:
                item.setTextAlignment(
                    Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter
                )
            self._table.setItem(index, column, item)

    def _room_text(self) -> str:
        """The footer: the stock run against its budget, or, with the
        graphics managed, every run of the packing."""
        try:
            if self._project.graphics_managed:
                return rooms_text(graphics.rooms(self._project))
            return room_text(graphics.room(self._project))
        except (packed.PackedError, ProjectError, OSError) as error:
            return f"Graphics run: not priced ({error})"

    def _current(self) -> GraphicsFile | None:
        index = self._table.currentRow()
        return self._rows[index] if 0 <= index < len(self._rows) else None

    def _sync_buttons(self) -> None:
        row = self._current()
        have = row is not None
        added = have and row.kind is Kind.ADDED
        self._export.setEnabled(have)
        self._import.setEnabled(have)
        self._copy.setEnabled(have)
        self._paste.setEnabled(have)
        self._duplicate.setEnabled(have)
        self._revert.setVisible(not added)
        self._revert.setEnabled(have and row.edited and not added)
        self._rename.setVisible(added)
        self._rename.setEnabled(added)
        self._reposition.setVisible(added)
        self._reposition.setEnabled(added)
        self._delete.setVisible(added)
        self._delete.setEnabled(added)

    # -- the sheet ------------------------------------------------------------

    def _selected(self) -> None:
        row = self._current()
        if row is None:
            self._number = None
            self._tiles = []
            self._changed = set()
            self._sheet.set_sheet(QImage(), None, graphics.COLUMNS, 0)
            self._sync_buttons()
            return
        self._number = row.number
        self._read_tiles()
        self._offer_rows()
        self._draw()
        self._sync_buttons()

    def _read_tiles(self) -> None:
        if self._number is None:
            return
        try:
            self._tiles = graphics.tiles(self._project, self._number)
            # An added file differs from no shipped file: every tile is its
            # own, and outlining all of them would say nothing.
            row = self._current()
            self._changed = (
                set()
                if row is not None and row.kind is Kind.ADDED
                else graphics.changed_tiles(self._project, self._number)
            )
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            self._tiles = []
            self._changed = set()
            self._hover.setText(f"{_name(self._number)} could not be read: {error}")

    def _offer_rows(self) -> None:
        """Fill the palette picker for the file on show.

        A row somebody chose stays picked, by name, where the new list still
        has it; otherwise the file's own default row is picked -- one of the
        level's where there is a level, the first on offer where not.
        """
        row = self._current()
        if row is None:
            self._palette_rows = []
            self._palette_pick.clear()
            return
        was = self.palette_row.name if self._chosen and self.palette_row else None
        rows = self._rows_for(row.format)
        self._palette_rows = rows
        self._palette_pick.blockSignals(True)
        self._palette_pick.clear()
        for offered in rows:
            self._palette_pick.addItem(offered.name)
        picked = next((i for i, r in enumerate(rows) if r.name == was), -1)
        if picked < 0:
            picked = graphics.default_row(row.number) if self._cgram is not None else 0
        self._palette_pick.setCurrentIndex(min(picked, len(rows) - 1))
        self._palette_pick.blockSignals(False)

    def _rows_for(self, fmt: TileFormat) -> list[PaletteRow]:
        """The rows on offer: the scene's, the palette file's, and the greys
        -- the file's runs skipped where the project cannot assemble them."""
        rows: list[PaletteRow] = []
        if self._cgram is not None:
            try:
                rows += graphics.scene_rows(self._cgram, fmt)
            except GraphicsError:
                pass
        try:
            rows += graphics.file_rows(self._project.palette(), fmt)
        except (palettes.PaletteError, ProjectError, OSError):
            pass
        rows.append(PaletteRow(GREYS.name, GREYS.colours[: graphics.row_width(fmt)]))
        return rows

    def _draw(self) -> None:
        """Paint the file on show under the row picked."""
        row = self.palette_row
        # An offset apiece, though nothing is edited here: a swatch without
        # one is drawn hatched, which means "not editable" in the panel and
        # would mean nothing on a strip that only shows.
        self._swatches.set_swatches(
            [
                Swatch(graphics.snes_value(colour), n, f"Colour {n:X}")
                for n, colour in enumerate(row.colours)
            ]
            if row is not None
            else []
        )
        if row is None or self._number is None or not self._tiles:
            self._sheet.set_sheet(QImage(), None, graphics.COLUMNS, 0)
            return
        picture = raster_to_image(graphics.raster(self._tiles, row.colours))
        # The same tiles with each pixel's index as its grey level: where the
        # sheet's colour 0 is, which the hatch is cut from.
        indices = raster_to_image(
            graphics.raster(self._tiles, [(n, n, n) for n in range(256)])
        )
        self._sheet.set_sheet(
            picture, indices, graphics.COLUMNS, len(self._tiles), self._changed
        )
        self._hover.setText(self._summary())

    def _summary(self) -> str:
        row = self._current()
        if row is None:
            return ""
        text = f"{row.name}: {row.tiles} tiles, {format_name(row.format)}"
        if row.kind is Kind.ADDED:
            text += "; added by this project"
        elif self._changed:
            text += f"; {len(self._changed)} changed from the shipped file (outlined)"
        return text

    def _sheet_hatched(self, hatched: bool) -> None:
        self._sheet.set_hatched(hatched)

    def _hovered(self, index: int) -> None:
        if index < 0:
            self._hover.setText(self._summary())
            return
        note = " (changed)" if index in self._changed else ""
        self._hover.setText(f"Tile {index} (${index:02X}){note}")

    # -- the buttons ----------------------------------------------------------

    def _export_png(self) -> None:
        row, palette = self._current(), self.palette_row
        if row is None or palette is None or not self._tiles:
            return
        folder = load_str_setting(EXPORT_FOLDER_KEY) or str(Path.home())
        chosen, _filter = QFileDialog.getSaveFileName(
            self,
            f"Export {row.name} as PNG",
            str(Path(folder) / f"{row.name}.png"),
            PNG_FILTER,
        )
        if not chosen:
            return
        destination = Path(chosen)
        if not destination.suffix:
            destination = destination.with_suffix(".png")
        try:
            png = graphics.export_png(
                self._tiles, row.format, palette.colours, name=row.name
            )
            destination.write_bytes(png)
        except (GraphicsError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"{row.name} could not be exported: {error}"
            )
            return
        save_str_setting(EXPORT_FOLDER_KEY, str(destination.parent))
        self._hover.setText(f"Exported {destination.name} ({len(self._tiles)} tiles)")

    def _import_png(self) -> None:
        row, palette = self._current(), self.palette_row
        if row is None or palette is None:
            return
        folder = load_str_setting(EXPORT_FOLDER_KEY) or str(Path.home())
        chosen, _filter = QFileDialog.getOpenFileName(
            self, f"Import a PNG into {row.name}", folder, PNG_FILTER
        )
        if not chosen:
            return
        self.import_file(Path(chosen))

    def import_file(self, path: Path) -> bool:
        """Read ``path`` into the file on show and save it, if it fits."""
        row, palette = self._current(), self.palette_row
        if row is None or palette is None:
            return False
        try:
            tiles = graphics.import_png(
                path.read_bytes(), row.format, self._tiles, palette.colours
            )
        except (GraphicsError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"{path.name} could not be imported: {error}"
            )
            return False
        if not self._save_tiles(row, tiles, f"Imported {path.name} into {row.name}"):
            return False
        save_str_setting(EXPORT_FOLDER_KEY, str(path.parent))
        return True

    def _save_tiles(self, row: GraphicsFile, tiles: Sequence[bytes], said: str) -> bool:
        """Save ``tiles`` as the file ``row`` names, if the graphics hold them.

        The price is asked before the write so a refusal comes with the
        numbers; the save's own check (:class:`~smw_tools.packed.RegionFull`)
        is the same arithmetic and is reported the same way if it disagrees.
        """
        try:
            price = graphics.price(self._project, row.number, tiles)
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, f"{row.name} could not be saved: {error}")
            return False
        if not price.fits:
            QMessageBox.warning(
                self, TITLE, _over_budget(row, price, self._project.graphics_managed)
            )
            return False
        try:
            saved = self._project.save_graphics(
                row.number, codec.encode_tiles(row.format, tiles)
            )
        except packed.RegionFull as error:
            QMessageBox.warning(
                self,
                TITLE,
                f"{row.name} was not saved: its run would need {error.used:,} "
                f"bytes and has {error.budget:,} -- {error.used - error.budget:,} "
                f"too many.",
            )
            return False
        except GraphicsBanksFull as error:
            QMessageBox.warning(self, TITLE, f"{row.name} was not saved: {error}.")
            return False
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, f"{row.name} could not be saved: {error}")
            return False
        self._take(saved, said)
        return True

    # -- the clipboard ---------------------------------------------------------

    def _copy_tiles(self) -> bool:
        """The file on show onto the clipboard, twice over: the sheet as a
        bitmap, for whatever else paints pictures, and the exported PNG under
        :data:`TILES_MIME`, so a paste back here carries the indices rather
        than a match against colours."""
        row, palette = self._current(), self.palette_row
        if row is None or palette is None or not self._tiles:
            return False
        try:
            png = graphics.export_png(
                self._tiles, row.format, palette.colours, name=row.name
            )
        except GraphicsError as error:
            QMessageBox.warning(self, TITLE, f"{row.name} could not be copied: {error}")
            return False
        mime = QMimeData()
        mime.setData(TILES_MIME, png)
        mime.setImageData(
            raster_to_image(graphics.raster(self._tiles, palette.colours))
        )
        QGuiApplication.clipboard().setMimeData(mime)
        self._hover.setText(f"Copied {row.name} ({len(self._tiles)} tiles)")
        return True

    def _paste_tiles(self) -> bool:
        """The clipboard's picture into the file on show, saved as an import
        is: a picture copied here as its own indices, any other bitmap by
        matching every pixel against the palette row on show."""
        row, palette = self._current(), self.palette_row
        if row is None or palette is None:
            return False
        clipboard = QGuiApplication.clipboard()
        mime = clipboard.mimeData()
        own = mime is not None and mime.hasFormat(TILES_MIME)
        picture = QImage() if own else clipboard.image()
        if not own and picture.isNull():
            self._hover.setText("The clipboard holds no picture to paste.")
            return False
        try:
            if own:
                tiles = graphics.import_png(
                    bytes(mime.data(TILES_MIME)),
                    row.format,
                    self._tiles,
                    palette.colours,
                )
            else:
                tiles = image_tiles(picture, row.format, self._tiles, palette.colours)
        except GraphicsError as error:
            QMessageBox.warning(
                self,
                TITLE,
                f"The clipboard could not be pasted into {row.name}: {error}",
            )
            return False
        return self._save_tiles(row, tiles, f"Pasted into {row.name}")

    # -- the files the project adds --------------------------------------------

    def add_file(self) -> bool:
        """Bring a new file into the project, through the add dialog.

        On a project whose graphics are not managed the gesture is handed to
        the window through :attr:`feature_needed` and nothing is asked: the
        add dialog would be choosing for a file the project has to refuse.
        """
        if not self._project.graphics_managed:
            self.feature_needed.emit(ADD, -1)
            return False
        try:
            taken = self._project.added_graphics()
        except (ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        dialog = AddGraphicsFileDialog(taken, self)
        chosen = answered(
            dialog,
            lambda: (dialog.chosen_number, dialog.chosen_format, dialog.chosen_source),
        )
        if chosen is None:
            return False
        number, fmt, source = chosen
        if number is None:
            return False
        tiles = blank_tiles(fmt)
        if source == FILE:
            folder = load_str_setting(EXPORT_FOLDER_KEY) or str(Path.home())
            chosen, _filter = QFileDialog.getOpenFileName(
                self, f"Import a PNG into GFX{number:02X}", folder, PNG_FILTER
            )
            if not chosen:
                return False
            palette = self._row_for_new(fmt)
            try:
                tiles = graphics.import_png(
                    Path(chosen).read_bytes(), fmt, tiles, palette.colours
                )
            except (GraphicsError, OSError) as error:
                QMessageBox.warning(
                    self, TITLE, f"{Path(chosen).name} could not be imported: {error}"
                )
                return False
            save_str_setting(EXPORT_FOLDER_KEY, str(Path(chosen).parent))
        return self.add_tiles(number, fmt, tiles)

    def add_tiles(
        self,
        number: int,
        fmt: TileFormat,
        tiles: Sequence[bytes],
        said: str = "Added",
    ) -> bool:
        """File ``tiles`` as the new file ``number`` in ``fmt``, priced as
        every graphics save is: a file the banks cannot hold is refused with
        the numbers, one that needs a bank more takes it. ``said`` is what
        the note calls the add, since a duplicate is one."""
        try:
            raw = codec.encode_tiles(fmt, tiles)
            saved = self._project.add_graphics(number, raw, fmt)
        except GraphicsBanksFull as error:
            QMessageBox.warning(self, TITLE, f"GFX{number:02X} was not added: {error}.")
            return False
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"GFX{number:02X} could not be added: {error}"
            )
            return False
        self._number = saved.number
        self._take(saved, f"{said} GFX{saved.number:02X}")
        return True

    def _row_for_new(self, fmt: TileFormat) -> PaletteRow:
        """The row a PNG for a new file is read under: the one on show where
        it is the format's width, the format's first offered row otherwise."""
        picked = self.palette_row
        if picked is not None and len(picked.colours) == graphics.row_width(fmt):
            return picked
        return self._rows_for(fmt)[0]

    def _duplicate_file(self) -> None:
        row = self._current()
        if row is not None:
            self.duplicate_file(row.number)

    def duplicate_file(self, number: int) -> bool:
        """Bring file ``number``'s tiles in again as a new added file.

        The copy is an add and is priced and refused as one; what it saves
        the reader is painting a file that is nearly another one. Any file
        may be copied, the game's own included, and the copy keeps the
        source's shape wherever a project may add it -- the animated tiles'
        384 as well as a slot's 128 (:func:`copied_shape`). Where the source
        is a shape a project cannot add, :func:`duplicate_note` says up
        front where the two part.

        Needs the managed graphics banks the way an add does, and is handed
        to the window the same way on a project without them, carrying the
        file to copy so the window can finish the gesture on the dialog it
        reopens.
        """
        if not self._project.graphics_managed:
            self.feature_needed.emit(DUPLICATE, number)
            return False
        try:
            taken = self._project.added_graphics()
            held = graphics.tiles(self._project, number)
            shape = copied_shape(graphics.file_format(self._project, number), len(held))
            tiles = fitted_tiles(held, shape)
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        source = _name(number)
        row = self._row_named(number)
        note = duplicate_note(row) if row is not None else ""
        dialog = FileNumberDialog(
            "Duplicate file",
            f"{source} is copied into the number typed here."
            + (f" {note}" if note else ""),
            taken,
            self,
        )
        to = answered(dialog, lambda: dialog.chosen_number)
        if to is None:
            return False
        return self.add_tiles(to, shape.format, tiles, said=f"Duplicated {source} into")

    def _row_named(self, number: int) -> GraphicsFile | None:
        """The catalogue row for file ``number``, or ``None`` for a number
        the list has not got."""
        return next((row for row in self._rows if row.number == number), None)

    def _rename_file(self) -> None:
        row = self._current()
        if row is not None and row.kind is Kind.ADDED:
            self.rename_file(row.number)

    def rename_file(self, number: int) -> bool:
        """Give the added file in slot ``number`` another name.

        Nothing the cartridge reads moves -- the slot is what a level names
        and what the fragments carry -- so this is the file's rename and the
        record's, and no packing is re-priced
        (:meth:`~shiny_mushroom.project.Project.rename_graphics`).
        """
        row = self._row_named(number)
        if row is None:
            return False
        try:
            taken = [
                found.name
                for found in self._project.graphics_folder().glob("*")
                if found.name != row.file_name
            ]
        except (ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        dialog = FileNameDialog(
            "Rename file",
            f"{row.name}'s own copy is renamed; nothing a level names changes.",
            taken,
            row.file_name,
            self,
        )
        name = answered(dialog, lambda: dialog.chosen_name)
        if name is None:
            return False
        try:
            self._project.rename_graphics(number, name)
        except (ProjectError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"{row.file_name} could not be renamed: {error}"
            )
            return False
        self._changed_here(f"Renamed {row.file_name} to {name}")
        return True

    def _reposition_file(self) -> None:
        row = self._current()
        if row is None or row.kind is not Kind.ADDED:
            return
        try:
            taken = self._project.added_graphics()
        except (ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        dialog = FileNumberDialog(
            "Reposition file",
            f"{row.purpose} packs into the slot typed here instead of {row.name}.",
            taken,
            self,
        )
        number = answered(dialog, lambda: dialog.chosen_number)
        if number is not None:
            self.reposition_file(row.number, number)

    def reposition_file(self, number: int, to: int) -> bool:
        """Pack the added file in slot ``number`` into slot ``to`` instead.

        The levels that named the old slot are named first and are not
        rewritten: a move that edited level containers would be saving levels
        nobody opened, and which slot should follow the file is the reader's
        call -- see
        :meth:`~shiny_mushroom.project.Project.reposition_graphics`.
        """
        levels = self._levels_naming(number)
        if levels and not self._asked_about(number, to, levels):
            return False
        try:
            saved = self._project.reposition_graphics(number, to)
        except GraphicsBanksFull as error:
            QMessageBox.warning(
                self, TITLE, f"GFX{number:02X} was not repositioned: {error}."
            )
            return False
        except (GraphicsError, packed.PackedError, ProjectError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"GFX{number:02X} could not be repositioned: {error}"
            )
            return False
        self._number = saved.number
        self._take(saved, f"Repositioned GFX{number:02X} to GFX{to:02X}")
        return True

    def _levels_naming(self, number: int) -> list[int]:
        """Which levels have slot ``number`` in a graphics row, lowest first.

        A row is eight bytes, one file number each and ``$FF`` for the
        tileset's, so a row that names the file has the number *in* it --
        and no added file is ever ``$FF``
        (:data:`smw_tools.graphics_memory.SENTINEL`).
        """
        try:
            rows = self._project.level_graphics()
        except (ProjectError, OSError):
            return []
        return sorted(level for level, row in rows.items() if number in row)

    def _asked_about(self, number: int, to: int, levels: Sequence[int]) -> bool:
        """Say which levels name the slot and ask whether to move the file
        out of it anyway. Six numbers and a count, since a file a hundred
        levels load is a sentence rather than a list."""
        shown = ", ".join(hexnum(level, 3) for level in levels[:6])
        if len(levels) > 6:
            shown += f" and {len(levels) - 6} more"
        many = len(levels) != 1
        asked = QMessageBox.question(
            self,
            "Reposition file",
            f"Move GFX{number:02X} to GFX{to:02X}?\n\n"
            f"{len(levels)} level{'s' if many else ''} "
            f"({shown}) name{'' if many else 's'} GFX{number:02X} in a "
            f"graphics slot and will go on naming it, which is a file the "
            f"cartridge no longer has. Point them at GFX{to:02X} on the "
            f"level header's Graphics page.",
        )
        return asked == QMessageBox.StandardButton.Yes

    def _delete_file(self) -> None:
        row = self._current()
        if row is not None and row.kind is Kind.ADDED:
            self.delete_file(row.number)

    def delete_file(self, number: int) -> bool:
        """Take the added file ``number`` out of the project, after asking.

        Needs the managed graphics banks the way an add does, and is handed
        to the window the same way on a project without them.
        """
        if not self._project.graphics_managed:
            self.feature_needed.emit(DELETE, number)
            return False
        asked = QMessageBox.question(
            self,
            "Delete file",
            f"Delete GFX{number:02X}?\n\nThe added file is deleted; nothing "
            f"ships in its place, and a tileset naming it loads nothing there.",
        )
        if asked != QMessageBox.StandardButton.Yes:
            return False
        try:
            self._project.delete_graphics(number)
        except (ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        self._changed_here(f"Deleted GFX{number:02X}")
        return True

    def _take(self, saved: GraphicsSaved, said: str) -> None:
        """What every save through the project ends with: the project it
        handed back adopted where the save grew it -- and the window told,
        before the reload it is about to be asked for -- then the re-read."""
        if saved.grew:
            self._project = saved.project
            self.project_replaced.emit(saved.project, saved.note)
        self._changed_here(f"{said}. {saved.note}" if saved.note else said)

    def _open_folder(self) -> None:
        """Show the folder the project's own copies of these files are in,
        in whatever this desktop browses files with.

        The overlay's raw folder for the set the build reads -- where an
        edited file, an added one and a tile editor's sidecar all land --
        made first if the project has not written one yet, exactly as the
        Source Files window's own button does it.
        """
        row = self._current()
        try:
            folder = (
                graphics.raw_path(self._project, row.number).parent
                if row is not None
                else self._project.overlay
            )
        except (GraphicsError, ProjectError, OSError):
            folder = self._project.overlay
        if open_folder(folder):
            self._hover.setText(f"Opened {folder}")
            return
        QMessageBox.information(
            self,
            TITLE,
            f"Nothing on this desktop is registered to browse folders. The "
            f"project's own copies of these files are in {folder}.",
        )

    def _revert_file(self) -> None:
        row = self._current()
        if row is None or not row.edited:
            return
        asked = QMessageBox.question(
            self,
            "Revert file",
            f"Revert {row.name}?\n\nThe file goes back to the cartridge's own "
            f"graphics; any tile-editor work on it is lost.",
        )
        if asked != QMessageBox.StandardButton.Yes:
            return
        try:
            self._project.revert_graphics(row.number)
            # The palette beside it was for that copy of the file.
            graphics.raw_path(self._project, row.number).with_suffix(".pal").unlink(
                missing_ok=True
            )
        except (ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        self._changed_here(f"Reverted {row.name}")

    def _changed_here(self, said: str) -> None:
        """A write this dialog made: re-read, redraw, and tell the window."""
        self._refill()
        self._read_tiles()
        self._draw()
        self._sync_buttons()
        self._hover.setText(said)
        self.overlay_changed.emit()

    # -- what moved while somebody was in another window ---------------------

    def changeEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        super().changeEvent(event)
        if event.type() == QEvent.Type.ActivationChange and self.isActiveWindow():
            self._recheck()

    def _recheck(self) -> None:
        """Re-read what was saved over a raw file while this window was not
        active -- anything on the desktop can, the folder being an ordinary one.

        A stat apiece over the raw files the overlay holds, and nothing more
        when none moved. A file that did is read again and its row and sheet
        redrawn, and the window is told once, whatever the count.
        """
        found = graphics.stamps(self._project)
        if found == self._stamps:
            return
        before = self._stamps
        numbers = {
            graphics.raw_path(self._project, row.number): row.number
            for row in self._rows
        }
        moved = sorted(
            _name(numbers[path])
            for path, stamp in found.items()
            if path in numbers and before.get(path) != stamp
        )
        gone = sorted(
            _name(numbers[path]) for path in set(before) - set(found) if path in numbers
        )
        self._refill(found)
        self._read_tiles()
        self._draw()
        self._sync_buttons()
        self._say(moved + gone)
        self.overlay_changed.emit()

    def _say(self, moved: list[str]) -> None:
        self._moved.setText(
            f"{', '.join(moved)} changed on disk; the rows show what is there now."
            if moved
            else ""
        )
        self._moved.setVisible(bool(moved))


def _over_budget(row: GraphicsFile, price: graphics.Price, managed: bool) -> str:
    """The refusal, with the numbers a save is decided on: the stock run's,
    or the managed packing's -- which was priced at one bank more too."""
    packs = (
        f"The picture packs to {price.encoded:,} bytes against "
        f"{price.baseline:,} shipped"
    )
    if managed:
        return (
            f"{row.name} was not saved. {packs}, and the graphics banks would "
            f"need {price.used:,} bytes of their {price.budget:,} -- "
            f"{price.over:,} too many, even with a bank more. Shrink the edit, "
            f"or delete an added file."
        )
    return (
        f"{row.name} was not saved. {packs}, and the run every graphics file "
        f"shares would need {price.used:,} bytes of its {price.budget:,} -- "
        f"{price.over:,} too many. Shrink the edit, or make room in another "
        f"file."
    )


__all__ = [
    "ADD",
    "DELETE",
    "DUPLICATE",
    "EXPORT_FOLDER_KEY",
    "GraphicsDialog",
    "TITLE",
    "added_count",
    "added_format",
    "blank_tiles",
    "copied_shape",
    "duplicate_note",
    "fitted_tiles",
    "room_text",
    "rooms_text",
    "status_text",
]
