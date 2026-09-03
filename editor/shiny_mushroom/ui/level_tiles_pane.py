"""The Level Tiles page of the Level Graphics dialog: an area of the level's
Layer 1, or the whole of its Layer 2, as the 8x8 tiles it stands on, drawn
as a graphics file's sheet is and edited five ways -- exported as a PNG,
imported back, copied, pasted, and painted in the pixel editor -- with each
edited pixel written into the file it came out of.

What the picture *is* -- which block is which cell, which slot and which
file each cell's tile lives in, what a 3bpp tile can hold -- is
:mod:`shiny_mushroom.level_tiles`, Qt-free. This page draws it and asks, and
reaches the level and the project through a :class:`TilesHost` the window
hands over: the blocks' words, a file's tiles, and the save. The save is the
window's because a repainted file has to reach the canvas, and the window is
what knows how (its ``_graphics_changed``).

A Layer 1 area is picked **on the canvas**, not here: the page's button
asks the dialog to close as a pick (:data:`PICK`), the window sweeps a
rectangle of blocks and opens the dialog again on this page with the area in
hand. A modal cannot lend its parent the pointer any other way, and the
level is where the blocks are. Layer 2 needs no sweep: it is shown whole --
the 32x27 pattern of a background, or a Layer 2 level's own shape -- which
the host says the size of (:attr:`TilesHost.layer2`), and the page asks
the dialog to show it (:attr:`LevelTilesPane.area_chosen`).
"""

from __future__ import annotations

from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path

from PySide6.QtCore import QMimeData, Qt, Signal
from PySide6.QtGui import QGuiApplication, QImage, QPainter, QPaintEvent, QRegion
from PySide6.QtWidgets import (
    QCheckBox,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import level_tiles
from shiny_mushroom.graphics import GraphicsError, snes_value
from shiny_mushroom.level_tiles import Area, FileTiles, LevelTiles
from shiny_mushroom.pixel_edit import Surface
from shiny_mushroom.ui.graphics_dialog import EXPORT_FOLDER_KEY, PNG_FILTER, TILES_MIME
from shiny_mushroom.ui.hatching import hatch
from shiny_mushroom.ui.pixel_editor import PixelEditor
from shiny_mushroom.ui.render import raster_to_image
from shiny_mushroom.ui.settings import load_str_setting, save_str_setting
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tile_sheet import TileSheet
from shiny_mushroom.ui.tips import wrap_tip
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker

TITLE = "Level Tiles"

#: What the page is for, said once above the picture.
HINT = (
    "Pick an area of Layer 1, or the whole of Layer 2, and its tiles are "
    "shown as they are drawn. Export, import, copy and paste edit the "
    "pixels; each tile goes back into the graphics file it came from."
)

#: Said in place of a picture until an area is picked, and how to pick one.
NO_AREA = (
    "No area picked. Select Layer 1 Area closes this dialog; drag over the "
    "level. Select Layer 2 shows the whole of Layer 2."
)

#: The Layer 2 button, and what it shows.
LAYER2_TIP = (
    "Show the whole of Layer 2 for editing here: a background's 32 x 27 "
    "pattern, or a Layer 2 level whole."
)

#: Said when the level has no Layer 2 to show.
NO_LAYER2 = "The level has no Layer 2 to show."

#: The status line the window shows while a pick is on.
PICK_PROMPT = "Drag over the level to pick an area of Layer 1; Escape cancels."

#: Hatched cells: shown, and not a file's to change.
SPOKEN_FOR_TIP = (
    "Hatched tiles are animated, or not a graphics file's, and are not written."
)

#: What Mushroom Paint's window is called over an area.
EDITOR_TITLE = "Mushroom Paint - Level Tiles"

#: CGRAM's colours, which is how many offsets a host answers with.
CGRAM_COLOURS = 256


@dataclass(frozen=True)
class TilesHost:
    """What the page asks of the window: the level's blocks, the project's
    files, and the save."""

    #: The four tilemap words of each block of an area, in storage order,
    #: block after block across each row -- or ``None`` with no level.
    words: Callable[[Area], Sequence[int] | None]
    #: The level's backdrop, the PPU's fixed colour.
    backdrop: Callable[[], int]
    #: A file as an edit needs it, or ``None`` where it cannot be read.
    file: Callable[[int], FileTiles | None]
    #: Save these files' tiles, whole; hand back a note for the status line.
    #: A :class:`GraphicsError` is a refusal, worded for a message box.
    save: Callable[[Mapping[int, Sequence[bytes]]], str]
    #: What the level is called in a PNG's record.
    name: str = ""
    #: Where each of CGRAM's 256 colours comes from -- the palette file's
    #: offset a recolour lands in, ``None`` for a colour no file backs --
    #: and the save of recoloured ones, ``{offset: 15-bit colour}``. Left
    #: out, the pixel editor changes no colours.
    colour_offsets: Callable[[], Sequence[int | None]] | None = None
    save_colours: Callable[[Mapping[int, int]], str] | None = None
    #: Copy a file into a number asked for over the widget, handing back the
    #: new number, or ``None`` for a declined ask; a :class:`GraphicsError`
    #: is the refusal. Left out, the slots page offers no Clone.
    clone: Callable[[int, QWidget], int | None] | None = None
    #: The whole of the level's Layer 2 as an area -- ``None`` with no level
    #: -- which :attr:`words` then answers for. Left out, the page offers no
    #: Select Layer 2.
    layer2: Callable[[], Area | None] | None = None


class AreaSheet(TileSheet):
    """The area's tiles, with the cells no file can take hatched over."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._spoken_for: frozenset[int] = frozenset()

    def set_spoken_for(self, cells: frozenset[int]) -> None:
        self._spoken_for = cells
        self.update()

    @property
    def spoken_for(self) -> frozenset[int]:
        return self._spoken_for

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        super().paintEvent(event)
        if not self._spoken_for or self._image.isNull():
            return
        # One region for every marked cell, hatched in a single pass: the
        # diagonals run on across a run of them rather than restarting at
        # each, and the picture stays readable under the mark.
        marked = QRegion()
        for index in self._spoken_for:
            if index < self._count:
                marked = marked.united(self.rect_of(index))
        if marked.isEmpty():
            return
        painter = QPainter(self)
        hatch(painter, marked)
        painter.end()


class LevelTilesPane(QWidget):
    """The page. Construct with a :class:`TilesHost`, then :meth:`show_area`
    it whenever the area, the row or the capture moves."""

    #: The button: close the dialog and let the window sweep an area.
    pick_requested = Signal()
    #: Select Layer 2: show this :class:`Area`, the whole of Layer 2. The
    #: dialog owns the area shown, so it is asked rather than told.
    area_chosen = Signal(object)
    #: A save went through: the caller re-reads the capture and shows it.
    saved = Signal(str)

    def __init__(self, host: TilesHost, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._host = host
        self._area: Area | None = None
        self._tiles: LevelTiles | None = None
        #: The pixel editor over the area, while one is open.
        self._editor: PixelEditor | None = None

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        hint = QLabel(HINT)
        hint.setWordWrap(True)
        style_note(hint)
        layout.addWidget(hint)

        controls = QHBoxLayout()
        self._pick = QPushButton("Select Layer 1 &Area...")
        self._pick.setToolTip(wrap_tip(NO_AREA))
        self._pick.clicked.connect(self.pick_requested.emit)
        controls.addWidget(self._pick)
        self._layer2 = QPushButton("Select &Layer 2")
        self._layer2.setToolTip(wrap_tip(LAYER2_TIP))
        self._layer2.setEnabled(host.layer2 is not None)
        self._layer2.clicked.connect(self.select_layer2)
        controls.addWidget(self._layer2)
        controls.addStretch(1)
        zoom_label = QLabel("&Zoom:")
        controls.addWidget(zoom_label)
        self._zoom = ZoomPicker()
        zoom_label.setBuddy(self._zoom)
        controls.addWidget(self._zoom)
        self._hatch = QCheckBox("&Hatch colour 0")
        self._hatch.setToolTip("Show colour 0 as a hatch instead of the backdrop.")
        controls.addWidget(self._hatch)
        layout.addLayout(controls)

        self._sheet = AreaSheet()
        self._sheet.setToolTip(wrap_tip(SPOKEN_FOR_TIP))
        self._sheet.hovered.connect(self._hovered)
        self._hatch.toggled.connect(self._sheet.set_hatched)
        layout.addWidget(ZoomedArea(self._sheet, self._zoom), 1)

        self._note = QLabel(NO_AREA)
        self._note.setWordWrap(True)
        style_note(self._note)
        layout.addWidget(self._note)

        buttons = QHBoxLayout()
        self._export = QPushButton("&Export PNG...")
        self._export.setToolTip(
            "Write the area as an indexed PNG, its palette rows in order."
        )
        self._export.clicked.connect(self._export_png)
        buttons.addWidget(self._export)
        self._import = QPushButton("&Import PNG...")
        self._import.setToolTip(
            wrap_tip(
                "Read a PNG of the area back into the files its tiles came from. "
                "A flattened one is matched against each tile's own colours."
            )
        )
        self._import.clicked.connect(self._import_png)
        buttons.addWidget(self._import)
        self._copy = QPushButton("&Copy")
        self._copy.setToolTip(
            wrap_tip(
                "Copy the area as a picture, and as indices for a paste back here."
            )
        )
        self._copy.clicked.connect(self.copy)
        buttons.addWidget(self._copy)
        self._paste = QPushButton("Pas&te")
        self._paste.setToolTip(
            wrap_tip(
                "Paste a picture of the area into the files its tiles came from. "
                "One copied elsewhere is matched against each tile's own colours."
            )
        )
        self._paste.clicked.connect(self.paste)
        buttons.addWidget(self._paste)
        self._edit = QPushButton("Edit Pi&xels...")
        self._edit.setToolTip(
            wrap_tip(
                "Paint the area in Mushroom Paint. An edit to a tile reaches "
                "every place the area draws it, and Save writes the tiles back "
                "into their files."
            )
        )
        self._edit.clicked.connect(self.edit_pixels)
        buttons.addWidget(self._edit)
        buttons.addStretch(1)
        layout.addLayout(buttons)
        self._sync_buttons()

    # -- what is shown ----------------------------------------------------------

    @property
    def area(self) -> Area | None:
        return self._area

    @property
    def tiles(self) -> LevelTiles | None:
        return self._tiles

    @property
    def sheet(self) -> AreaSheet:
        return self._sheet

    def show_area(
        self,
        area: Area | None,
        vram: bytes | None,
        cgram: bytes | None,
        files: Sequence[int | None],
    ) -> None:
        """Show ``area`` out of ``vram`` and ``cgram`` under the four layer
        slots' ``files`` -- or nothing, with no area or no capture."""
        self._area = area
        self._tiles = None
        if area is not None and vram is not None and cgram is not None:
            words = self._host.words(area)
            if words is not None:
                try:
                    self._tiles = level_tiles.read_area(
                        area, words, vram, cgram, self._host.backdrop(), files
                    )
                except GraphicsError as error:
                    self._note.setText(f"The area could not be read: {error}")
        self._draw()
        self._sync_buttons()

    def _draw(self) -> None:
        tiles = self._tiles
        if tiles is None:
            self._sheet.set_sheet(QImage(), None, 1, 0)
            self._sheet.set_spoken_for(frozenset())
            if self._area is None:
                self._note.setText(NO_AREA)
            return
        picture = raster_to_image(level_tiles.raster(tiles))
        indices = raster_to_image(level_tiles.raster(tiles, indices=True))
        self._sheet.set_sheet(picture, indices, tiles.columns, len(tiles.cells))
        self._sheet.set_spoken_for(
            frozenset(n for n, cell in enumerate(tiles.cells) if not cell.editable)
        )
        self._note.setText(tiles.summary())

    def _sync_buttons(self) -> None:
        held = self._tiles is not None
        for button in (self._export, self._import, self._copy, self._paste, self._edit):
            button.setEnabled(held)

    def select_layer2(self) -> Area | None:
        """Select Layer 2: ask the dialog to show the whole of Layer 2, and
        hand back the area asked for -- ``None``, and a note, where the
        host has no Layer 2 to show."""
        area = None if self._host.layer2 is None else self._host.layer2()
        if area is None:
            self._note.setText(NO_LAYER2)
            return None
        self.area_chosen.emit(area)
        return area

    def _hovered(self, index: int) -> None:
        tiles = self._tiles
        if tiles is None:
            return
        if index < 0:
            self._note.setText(tiles.summary())
            return
        cell = tiles.cells[index]
        column, row = index % tiles.columns, index // tiles.columns
        block = (
            tiles.area.column + column // level_tiles.CELLS_PER_BLOCK,
            tiles.area.row + row // level_tiles.CELLS_PER_BLOCK,
        )
        self._note.setText(
            f"Block (${block[0]:02X}, ${block[1]:02X}): {cell.describe()}"
        )

    # -- the four ways in and out ---------------------------------------------------

    def _export_png(self) -> None:
        tiles = self._tiles
        if tiles is None:
            return
        folder = load_str_setting(EXPORT_FOLDER_KEY) or str(Path.home())
        chosen, _filter = QFileDialog.getSaveFileName(
            self,
            "Export the area as PNG",
            str(Path(folder) / f"{self._file_stem()}.png"),
            PNG_FILTER,
        )
        if not chosen:
            return
        destination = Path(chosen)
        if not destination.suffix:
            destination = destination.with_suffix(".png")
        self.export_file(destination)

    def export_file(self, destination: Path) -> bool:
        tiles = self._tiles
        if tiles is None:
            return False
        try:
            destination.write_bytes(level_tiles.export_png(tiles, name=self._host.name))
        except (GraphicsError, OSError) as error:
            QMessageBox.warning(self, TITLE, f"The area could not be exported: {error}")
            return False
        save_str_setting(EXPORT_FOLDER_KEY, str(destination.parent))
        self._note.setText(f"Exported {destination.name} ({len(tiles.cells)} tiles)")
        return True

    def _file_stem(self) -> str:
        area = self._area
        name = self._host.name.replace("$", "").replace(" ", "-") or "level"
        if area is None:
            return name
        if area.layer == 2:
            return f"{name}-layer2"
        return f"{name}-area-{area.column:02X}-{area.row:02X}"

    def _import_png(self) -> None:
        if self._tiles is None:
            return
        folder = load_str_setting(EXPORT_FOLDER_KEY) or str(Path.home())
        chosen, _filter = QFileDialog.getOpenFileName(
            self, "Import a PNG into the area", folder, PNG_FILTER
        )
        if not chosen:
            return
        if self.import_file(Path(chosen)):
            save_str_setting(EXPORT_FOLDER_KEY, str(Path(chosen).parent))

    def import_file(self, path: Path) -> bool:
        """Read ``path`` into the area and write its tiles to the files."""
        tiles = self._tiles
        if tiles is None:
            return False
        try:
            cells = level_tiles.import_png(path.read_bytes(), tiles)
        except (GraphicsError, OSError) as error:
            QMessageBox.warning(
                self, TITLE, f"{path.name} could not be imported: {error}"
            )
            return False
        return self._apply(cells, f"Imported {path.name}")

    def copy(self) -> bool:
        """The area onto the clipboard twice over: the picture as a bitmap,
        and the indexed PNG under :data:`TILES_MIME` for a paste back here."""
        tiles = self._tiles
        if tiles is None:
            return False
        try:
            png = level_tiles.export_png(tiles, name=self._host.name)
        except GraphicsError as error:
            QMessageBox.warning(self, TITLE, f"The area could not be copied: {error}")
            return False
        mime = QMimeData()
        mime.setData(TILES_MIME, png)
        mime.setImageData(raster_to_image(level_tiles.raster(tiles)))
        QGuiApplication.clipboard().setMimeData(mime)
        self._note.setText(f"Copied the area ({len(tiles.cells)} tiles)")
        return True

    def paste(self) -> bool:
        """The clipboard's picture into the area's files: one copied here by
        its indices, any other bitmap by colour."""
        tiles = self._tiles
        if tiles is None:
            return False
        clipboard = QGuiApplication.clipboard()
        mime = clipboard.mimeData()
        own = mime is not None and mime.hasFormat(TILES_MIME)
        picture = QImage() if own else clipboard.image()
        if not own and picture.isNull():
            self._note.setText("The clipboard holds no picture to paste.")
            return False
        try:
            if own:
                cells = level_tiles.import_png(bytes(mime.data(TILES_MIME)), tiles)
            else:
                rgba = picture.convertToFormat(QImage.Format.Format_RGBA8888)
                cells = level_tiles.import_pixels(
                    bytes(rgba.constBits()), rgba.width(), rgba.height(), tiles
                )
        except GraphicsError as error:
            QMessageBox.warning(
                self, TITLE, f"The clipboard could not be pasted into the area: {error}"
            )
            return False
        return self._apply(cells, "Pasted into the area")

    def _apply(self, cells: Sequence[bytes], said: str) -> bool:
        """Write ``cells`` back into the files they came from, through the
        host, and say what happened."""
        try:
            text = self._write(cells, said)
        except GraphicsError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        self._note.setText(text)
        return text.endswith("were left") or "nothing changed" not in text

    def _write(self, cells: Sequence[bytes], said: str) -> str:
        """Write ``cells`` into their files and say what happened; a
        :class:`GraphicsError` is the refusal, worded for a message box.
        Nothing to write is a note rather than a refusal."""
        tiles = self._tiles
        if tiles is None:
            raise GraphicsError("no area is picked")
        try:
            edits = level_tiles.file_edits(tiles, cells, self._host.file)
        except GraphicsError as error:
            raise GraphicsError(f"The picture could not be written: {error}") from error
        if not edits.files:
            return f"{said}: nothing changed" + (
                f"; {edits.dropped} edited tiles are not a file's"
                if edits.dropped
                else ""
            )
        try:
            note = self._host.save(edits.files)
        except GraphicsError as error:
            raise GraphicsError(f"The files could not be saved: {error}") from error
        names = ", ".join(f"GFX{number:02X}" for number in sorted(edits.files))
        text = f"{said}: {edits.written} tiles written to {names}"
        if edits.dropped:
            text += f"; {edits.dropped} edited tiles are not a file's and were left"
        if note:
            text += f". {note}"
        self.saved.emit(text)
        return text

    # -- the pixel editor ---------------------------------------------------------

    @property
    def editor(self) -> PixelEditor | None:
        return self._editor

    def edit_pixels(self) -> PixelEditor | None:
        """Open the pixel editor over the area -- or bring the open one
        forward -- and hand it back."""
        tiles = self._tiles
        if tiles is None:
            return None
        if self._editor is not None:
            self._editor.raise_()
            self._editor.activateWindow()
            return self._editor
        surface = level_tiles.surface_of(tiles, self._host.file)
        editor = PixelEditor(
            surface,
            self._save_surface,
            title=EDITOR_TITLE,
            describe=lambda n: tiles.cells[n].describe(),
            colour_editable=colour_editable_under(self._host),
            parent=self,
        )
        editor.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose, True)
        editor.finished.connect(self._editor_closed)
        self._editor = editor
        # Window-modal rather than shown: the page is a tab of a modal
        # dialog, and a window that is not in that dialog's modal chain
        # would never receive a click. It is still its own window.
        editor.open()
        return editor

    def _editor_closed(self) -> None:
        self._editor = None

    def _colour_offsets(self) -> Sequence[int | None]:
        return colour_offsets_of(self._host)

    def _save_surface(self, surface: Surface) -> str:
        """The editor's save: the surface as the area's cells, written
        through the same path a paste takes, and its recoloured entries
        through the host's palette save. A :class:`GraphicsError` is the
        refusal, which the editor shows."""
        tiles = self._tiles
        if tiles is None:
            raise GraphicsError("the area is no longer shown")
        said = []
        colours = self._changed_colours(surface, tiles)
        if colours:
            assert self._host.save_colours is not None
            try:
                note = self._host.save_colours(colours)
            except GraphicsError as error:
                raise GraphicsError(
                    f"The colours could not be saved: {error}"
                ) from error
            said.append(
                f"{len(colours)} colours changed" + (f". {note}" if note else "")
            )
        said.append(self._write(level_tiles.cells_of(surface, tiles), "Painted"))
        text = "; ".join(said)
        self._note.setText(text)
        return text

    def _changed_colours(self, surface: Surface, tiles: LevelTiles) -> dict[int, int]:
        """The palette entries the editor recoloured, with the area's own
        colours as the baseline."""
        if self._host.save_colours is None:
            return {}
        baseline = tuple(
            tuple(tiles.colour(row, index) for index in range(level_tiles.ROW_COLOURS))
            for row in range(level_tiles.PALETTE_ROWS)
        )
        return colour_edits(surface, baseline, self._colour_offsets())


def colour_offsets_of(host: TilesHost) -> list[int | None]:
    """Where each of CGRAM's 256 colours comes from, per ``host`` -- or
    nowhere for every colour, with a host that does not say."""
    if host.colour_offsets is None:
        return [None] * CGRAM_COLOURS
    return (list(host.colour_offsets()) + [None] * CGRAM_COLOURS)[:CGRAM_COLOURS]


def colour_editable_under(host: TilesHost) -> Callable[[int, int], bool]:
    """Which entries the pixel editor may recolour under ``host``: those the
    file backs -- and never colour 0, which is the backdrop shown through
    every row and not a row's own to change."""
    offsets = colour_offsets_of(host)
    return lambda row, index: (
        index != 0 and offsets[row * level_tiles.ROW_COLOURS + index] is not None
    )


def colour_edits(
    surface: Surface,
    baseline: Sequence[Sequence[tuple[int, int, int]]],
    offsets: Sequence[int | None],
) -> dict[int, int]:
    """The entries ``surface`` draws in another colour than ``baseline``,
    by the offset each lands in -- those ``offsets`` can place -- as the
    15-bit words the palettes take."""
    changed: dict[int, int] = {}
    for row, colours in enumerate(surface.palette):
        for index, colour in enumerate(colours):
            if index == 0 or colour == tuple(baseline[row][index]):
                continue
            at = row * level_tiles.ROW_COLOURS + index
            if at < len(offsets) and offsets[at] is not None:
                changed[offsets[at]] = snes_value(colour)
    return changed


__all__ = [
    "EDITOR_TITLE",
    "AreaSheet",
    "LevelTilesPane",
    "colour_editable_under",
    "colour_edits",
    "colour_offsets_of",
    "LAYER2_TIP",
    "NO_AREA",
    "NO_LAYER2",
    "PICK_PROMPT",
    "TilesHost",
]
