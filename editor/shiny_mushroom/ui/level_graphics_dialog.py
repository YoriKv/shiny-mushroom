"""The level graphics editor: a modal over the level's own graphics row.

Which file each of the eight VRAM slots loads, over what the level header's
two tilesets would load (:mod:`shiny_mushroom.level_graphics`). Modal for
the header dialog's reason -- a small, self-contained set of decisions about
the level as a whole, with nothing on the canvas to point at while making
them -- and a dialog of its own rather than a page of that one because the
two answer different questions: the header is five bytes of the game's own
level record, and this is eight bytes the cartridge only has room for under
a feature the project has to carry.

The row goes into the document, so an accept is one undo step and the same
save, and Cancel leaves the level exactly as it was. Each slot's first entry
is **the file the level's tileset loads there now**, read off the cartridge
for the header the document holds -- so a slot left on it is a slot that
follows the header, and changing the header in the other dialog changes what
this one shows next time it is opened.

Offered only with a project: the row is saved into the level's own container
and reaches the cartridge through a feature of the project's, which the
accept offers when the row first names a file.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QKeySequence, QShortcut
from PySide6.QtWidgets import (
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.graphics import CGRAM_ROWS, row_name
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_graphics import (
    ANIMATED_TILES,
    INHERIT_ROW,
    LAYER_ROW,
    OTHER_VRAM,
    SLOT_WORDS,
    SPRITE_ROW,
    animated_file,
    is_inherit,
    slot_sheets,
    takes_a_row,
)
from shiny_mushroom.level_tiles import Area, surface_of_file, tiles_of_file
from shiny_mushroom.pixel_edit import Surface
from shiny_mushroom.ui.dialogs import ChoiceBox
from shiny_mushroom.ui.level_tiles_pane import (
    LevelTilesPane,
    TilesHost,
    colour_editable_under,
    colour_edits,
    colour_offsets_of,
)
from shiny_mushroom.ui.pixel_editor import PixelEditor
from shiny_mushroom.ui.render import raster_to_image
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tips import wrap_tip
from shiny_mushroom.ui.vram_slots import ROW_GAP, Region, Slot, VramSlots
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker
from smw_tools.graphics import FILE_NUMBERS, GraphicsError, fits_a_slot
from smw_tools.level_graphics import INHERIT, LAYER_SLOTS, SLOTS, UPLOAD_SLOTS

TITLE = "Level Graphics"

#: The two pages, where the dialog has a level to show tiles of.
SLOTS_TAB = "Slots"
TILES_TAB = "Level Tiles"

#: The dialog's third way out, beside Accepted and Rejected: closed so the
#: window can sweep an area of the level for the tiles page. The row as it
#: stood goes with it (:class:`AreaPick`) and comes back when the dialog is
#: opened again over the area.
PICK = 2


@dataclass(frozen=True)
class AreaPick:
    """What :meth:`LevelGraphicsDialog.edit` hands back when the tiles page
    asked for an area: the row the slots held at that moment, so nothing a
    reader had picked is lost across the round trip."""

    graphics: bytes


#: The footer: whose the row is, and what it costs. Part of the document like
#: the header's five bytes -- one accept, one undo step, the same save -- but
#: reaching the cartridge only through the feature, which is what the accept
#: offers when the row first names a file.
GRAPHICS_NOTE = (
    "Which file each slot loads, over the header's tilesets. Needs the "
    "Per-level graphics feature, offered on OK."
)

#: Said under the row once the animated tiles have been pointed somewhere
#: else. The other eight show as they are picked -- their files are written
#: into the capture's VRAM -- and this one cannot: the animated tiles are
#: expanded into a WRAM buffer on the way into the level and reach VRAM three
#: four-tile blocks at a time, so the picture behind the dialog waits for the
#: accept, which loads the level again.
ANIMATED_NOTE = (
    "The animated tiles show once you press OK: the level is loaded again for "
    "them, where the other eight are shown as you pick them."
)

#: Said over disabled slots when the level's mode is one the game prepares as
#: a Mode 7 boss scene: the uploader takes the boss path before the feature's
#: hooks, so the row would never be read
#: (:data:`shiny_mushroom.level_graphics.MODE7_BOSS_MODES`).
MODE7_NOTE = (
    "A boss room (level mode $09, $0B or $10) is a Mode 7 scene with fixed "
    "graphics, so no row is read. Change the level mode to name files here."
)

#: What a slot's first entry says: the file the level's tileset loads there
#: now, or that nothing could be read when the cartridge cannot say.
TILESET_ENTRY = "Tileset's: {file}"
TILESET_UNKNOWN = "Tileset's file"

#: The animated tiles' first entry, which has no tileset behind it to read:
#: the file every level loads unless it says otherwise, named outright
#: because it is the same file on every cartridge.
ANIMATED_ENTRY = "The game's: GFX33"

#: The window's reader for a header's two tileset rows -- the four files
#: ``SpriteGFXList`` names for its sprite tileset and the four
#: ``FGAndBGGFXList`` names for its FG/BG tileset -- or ``None`` where the
#: image cannot answer.
TilesetRows = Callable[[bytes], "tuple[bytes, bytes] | None"]

#: The window's reader for what a level whose row is *this* would be drawn
#: out of: its VRAM and its CGRAM, or ``None`` with no capture to answer
#: from. Asked again on every slot moved, so the picture is the swap the
#: canvas is showing rather than a load waited for.
VramFor = Callable[[bytes], "tuple[bytes, bytes] | None"]

#: Over the VRAM panel, and the whole of it on hover: what the picture is.
VRAM_NOTE = "VRAM Preview"

#: The palette picker's first entry: the row each half of VRAM is usually
#: drawn under, which is what the panel shows until somebody picks one.
VRAM_ROW_DEFAULT = "Each half's own"

#: How much of the column the dialog opens with in view. Four bands at 1x is
#: the height the panel had when it was two columns of four, and the height a
#: modal can give a picture beside the eight decisions it is there for; the
#: rest of the column scrolls.
VRAM_BANDS = 4
VRAM_TIP = (
    "The level's VRAM, 128 tiles a slot, in the colours each half is drawn "
    "under. Hatched tiles are animated."
)

#: What the panel calls a band, where the slot's own name is not the whole
#: story. `FG1` is the one: `ROUTINE_SMW_LevelTileAnimations` DMAs the animated
#: tiles over its lower half every frame, and `DATA_05B93B`'s sixteen
#: destinations under `!VRAM_SMW_Layer1GFXVRAMLocation` cover VRAM words
#: `$0400`-`$07FF` with no gaps -- tiles `$40`-`$7F` exactly. So half of what
#: that band shows is `GFX33`, whatever file the slot names, and pointing the
#: slot elsewhere moves only the top four rows of the sheet. Named here rather
#: than in :data:`smw_tools.level_graphics.SLOTS`, which is what the row itself
#: calls its eight bytes.
VRAM_BAND_NAMES = {"FG1": "FG1 + Anims"}


def _regions_after(index: int) -> tuple[Region, ...]:
    """The VRAM between slot ``index`` and the next one, as lines for the
    panel to write under that slot's band -- the tilemaps and the 2bpp
    Layer 3 tiles of :data:`~shiny_mushroom.level_graphics.OTHER_VRAM`,
    placed by their word addresses rather than pinned to FG3 by hand, so a
    base that moves a slot moves the lines with it."""
    below = SLOT_WORDS[index]
    above = SLOT_WORDS[index + 1] if index + 1 < len(SLOT_WORDS) else None
    return tuple(
        Region(name=what, address=hexnum(at, 4))
        for at, what in OTHER_VRAM
        if below < at and (above is None or at < above)
    )


@dataclass(frozen=True)
class _VramPane:
    """The right-hand pane: what VRAM holds while the eight decisions are
    being made, and the reader it is drawn from.

    One value rather than five attributes on the dialog, because the pane is
    all-or-nothing -- a dialog built without a :data:`VramFor` has none of it
    -- and five separate ``| None`` attributes are five things a reader could
    guard on, four of them wrong. The dialog holds
    :attr:`LevelGraphicsDialog._vram_pane`, and narrowing that narrows the
    lot.
    """

    #: What goes into the dialog's layout.
    widget: QWidget
    #: The eight slots as VRAM holds them, and the scrolled window onto them.
    view: VramSlots
    area: ZoomedArea
    #: What the picture is drawn at, and the colours it is guessed under.
    zoom: ZoomPicker
    palette: ChoiceBox
    #: What a level whose row is the one on screen would be drawn out of.
    read: VramFor

    @classmethod
    def build(cls, read: VramFor) -> _VramPane:
        """The pane, laid out at a zoom and scrolled -- the Map16 window's
        own arrangement, and its shared picker
        (:mod:`shiny_mushroom.ui.zooming`)."""
        widget = QWidget()
        column = QVBoxLayout(widget)
        column.setContentsMargins(0, 0, 0, 0)
        heading = QHBoxLayout()
        heading.addWidget(QLabel(VRAM_NOTE))
        heading.addStretch(1)
        zoom_label = QLabel("&Zoom:")
        heading.addWidget(zoom_label)
        zoom = ZoomPicker()
        zoom_label.setBuddy(zoom)
        heading.addWidget(zoom)
        column.addLayout(heading)
        under = QHBoxLayout()
        palette_label = QLabel("&Palette:")
        under.addWidget(palette_label)
        # A tile's palette is its tilemap entry's, never the file's, so the
        # panel's colours are a guess: the first entry is the one the model
        # makes per half of VRAM, and the sixteen after it are the reader
        # overruling it for all eight slots at once.
        palette = ChoiceBox()
        palette.addItem(VRAM_ROW_DEFAULT, None)
        for row in range(CGRAM_ROWS):
            palette.addItem(row_name(row), row)
        palette.setToolTip(wrap_tip(VRAM_TIP))
        palette_label.setBuddy(palette)
        under.addWidget(palette, 1)
        column.addLayout(under)
        view = VramSlots()
        view.setToolTip(wrap_tip(VRAM_TIP))
        area = ZoomedArea(view, zoom)
        column.addWidget(area, 1)
        return cls(
            widget=widget, view=view, area=area, zoom=zoom, palette=palette, read=read
        )


#: How a file the project added is described on a slot's list, the phrase
#: :func:`shiny_mushroom.level_graphics.choices` uses.
ADDED_FILE = "added file"


class LevelGraphicsDialog(QDialog):
    """Edit a level's graphics row. :attr:`graphics` is the edited copy."""

    #: The row as it stands, emitted whenever a slot moves. **The canvas
    #: follows it while the dialog is open**: the tiles are drawn out of the
    #: capture's VRAM, so showing a slot's new file is writing that file into
    #: it, not asking the game to load the level again -- which is what makes
    #: it worth doing per dropdown rather than on OK. Nothing is committed by
    #: it; the window puts the document's own row back when the dialog closes,
    #: whichever way it closed.
    changed = Signal(bytes)

    def __init__(
        self,
        header: bytes,
        graphics: bytes = b"",
        parent: QWidget | None = None,
        choices: Sequence[tuple[int, str, str]] = (),
        animated: Sequence[tuple[int, str, str]] = (),
        tileset_rows: TilesetRows | None = None,
        vram: VramFor | None = None,
        tiles: TilesHost | None = None,
        area: Area | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        #: The tiles page, or ``None`` where no host was passed and the
        #: dialog is the row alone; and the area it shows.
        self._tiles_pane: LevelTilesPane | None = None
        self._area = area
        #: The level's header: not edited here, and asked two things -- which
        #: files its tilesets load, for each slot's first entry, and whether
        #: its level mode is one whose row the game would ever read.
        self._header = bytes(header)
        #: The row as it came in, what a slot may name -- ``(number, name,
        #: purpose)``, :func:`shiny_mushroom.level_graphics.choices` -- and
        #: one combo per slot.
        self._graphics = bytes(graphics)
        self._choices = tuple(choices)
        #: What the row's ninth byte may name, which is a catalogue of its
        #: own: not a VRAM slot's file but the 384 tiles the animated tiles
        #: are expanded out of
        #: (:func:`shiny_mushroom.level_graphics.animated_choices`).
        self._animated = tuple(animated)
        self._tileset_rows = tileset_rows
        self._slots: dict[str, QComboBox] = {}
        #: Each upload slot's Edit and Clone, and the tiles host they act
        #: through -- absent without one, as the tiles page is.
        self._edit_buttons: dict[str, QPushButton] = {}
        self._clone_buttons: dict[str, QPushButton] = {}
        self._tiles_host = tiles
        #: The pixel editor over a slot's file, while one is open.
        self._file_editor: PixelEditor | None = None
        #: The eight files the header's tilesets load, which is what a slot
        #: naming none of its own is showing -- ``None`` where the cartridge
        #: could not say (:meth:`_refresh_tileset_files`).
        self._tileset_files: tuple[int, ...] | None = None
        #: The VRAM pane, or ``None`` where no reader was passed and the
        #: dialog is the eight decisions alone. The one thing to guard on.
        self._vram_pane: _VramPane | None = None

        layout = QVBoxLayout(self)
        # Two panes: the eight decisions, and what VRAM holds while they are
        # being made. The buttons span both, since they end the dialog.
        panes = QHBoxLayout()
        self._tabs: QTabWidget | None = None
        if tiles is None:
            layout.addLayout(panes, 1)
        else:
            # With a level to read, the row is one page and its tiles the
            # other: the buttons still end the dialog, and only the row
            # waits for OK -- a tile edit is a file save, made on the spot.
            self._tabs = QTabWidget()
            slots_page = QWidget()
            slots_page.setLayout(panes)
            self._tabs.addTab(slots_page, SLOTS_TAB)
            self._tiles_pane = LevelTilesPane(tiles)
            self._tiles_pane.pick_requested.connect(lambda: self.done(PICK))
            self._tiles_pane.area_chosen.connect(self.set_area)
            self._tiles_pane.saved.connect(lambda _said: self._show_vram())
            self._tabs.addTab(self._tiles_pane, TILES_TAB)
            layout.addWidget(self._tabs, 1)
            if area is not None:
                self._tabs.setCurrentWidget(self._tiles_pane)
            QShortcut(QKeySequence.StandardKey.Copy, self, self._copy_tiles)
            QShortcut(QKeySequence.StandardKey.Paste, self, self._paste_tiles)
        left = QVBoxLayout()
        panes.addLayout(left)
        form = QFormLayout()
        held = self._graphics or INHERIT_ROW
        for index, slot in enumerate(SLOTS):
            animates = index >= UPLOAD_SLOTS
            pick = ChoiceBox()
            pick.addItem(ANIMATED_ENTRY if animates else TILESET_UNKNOWN, None)
            for number, name, purpose in self._animated if animates else self._choices:
                pick.addItem(f"{name} - {purpose}", number)
            file = None if held[index] == INHERIT else held[index]
            # A slot naming a file the choices do not list -- an added file
            # the project has since dropped, or one no slot can take -- keeps
            # it as a row of its own, so a dialog opened and accepted over
            # such a level hands the same row back rather than quietly moving
            # the slot.
            if file is not None and self._offered_file(pick, file) < 0:
                pick.addItem(f"GFX{file:02X} - {_unoffered(file)}", file)
            pick.setCurrentIndex(self._offered_file(pick, file))
            pick.setToolTip(wrap_tip(GRAPHICS_NOTE))
            pick.currentIndexChanged.connect(self._slot_moved)
            self._slots[slot] = pick
            label = QLabel(f"{slot}:")
            label.setToolTip(_slot_tip(index))
            field: QWidget = pick
            if tiles is not None and not animates:
                # The file the slot holds, painted in the pixel editor, or
                # copied into a file of the project's own that the slot then
                # names -- the two things a row is for beyond choosing.
                field = QWidget()
                row = QHBoxLayout(field)
                row.setContentsMargins(0, 0, 0, 0)
                row.addWidget(pick, 1)
                edit_button = QPushButton("&Edit...")
                edit_button.setToolTip(
                    wrap_tip(
                        "Paint the file this slot holds in Mushroom Paint; "
                        "Save writes it back into the file."
                    )
                )
                edit_button.clicked.connect(lambda _=False, i=index: self.edit_slot(i))
                row.addWidget(edit_button)
                clone_button = QPushButton("Cl&one...")
                clone_button.setToolTip(
                    wrap_tip(
                        "Copy the file this slot holds into a file of the "
                        "project's own, and point the slot at the copy. Needs "
                        "Growable graphics."
                    )
                )
                clone_button.clicked.connect(
                    lambda _=False, i=index: self.clone_slot(i)
                )
                row.addWidget(clone_button)
                self._edit_buttons[slot] = edit_button
                self._clone_buttons[slot] = clone_button
            form.addRow(label, field)
        left.addLayout(form)

        self._mode7_note = QLabel(MODE7_NOTE)
        self._mode7_note.setWordWrap(True)
        left.addWidget(self._mode7_note)

        self._animated_note = QLabel(ANIMATED_NOTE)
        self._animated_note.setWordWrap(True)
        style_note(self._animated_note)
        left.addWidget(self._animated_note)

        note = QLabel(GRAPHICS_NOTE)
        note.setWordWrap(True)
        note.setMinimumWidth(320)
        left.addWidget(note)
        left.addStretch(1)

        if vram is not None:
            self._vram_pane = _VramPane.build(vram)
            self._vram_pane.palette.currentIndexChanged.connect(
                lambda _i: self._show_vram()
            )
            panes.addWidget(self._vram_pane.widget, 1)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

        self._refresh_tileset_files()
        self._weigh_the_mode()
        self._weigh_the_animated_tiles()
        self._show_vram()
        self._fit_vram()
        self._sync_slot_buttons()

    # -- what is being edited -----------------------------------------------

    @property
    def graphics(self) -> bytes:
        """The edited graphics row: eight bytes, or empty when every slot
        keeps its tileset's file -- which is a level with no row."""
        row = bytes(
            INHERIT if (file := self._slots[slot].currentData()) is None else file
            for slot in SLOTS
        )
        return b"" if is_inherit(row) else row

    def _slot_moved(self) -> None:
        """A slot was pointed somewhere else: say what the row now is, and
        show it."""
        self.changed.emit(self.graphics)
        self._show_vram()
        self._weigh_the_animated_tiles()
        self._sync_slot_buttons()

    # -- the slots' own buttons ---------------------------------------------------

    def _sync_slot_buttons(self) -> None:
        """Arm Edit and Clone where the slot holds a file a slot can take:
        neither means anything over a slot the cartridge could not name."""
        host = self._tiles_host
        files = self._effective_files()
        for index, slot in enumerate(SLOTS[:UPLOAD_SLOTS]):
            edit_button = self._edit_buttons.get(slot)
            if edit_button is None:
                continue
            file = files[index]
            have = file is not None and _takes_a_slot(file)
            edit_button.setEnabled(have and self._vram_pane is not None)
            self._clone_buttons[slot].setEnabled(
                have and host is not None and host.clone is not None
            )

    def _slot_file(self, index: int) -> int | None:
        file = self._effective_files()[index]
        return file if file is not None and _takes_a_slot(file) else None

    @property
    def file_editor(self) -> PixelEditor | None:
        return self._file_editor

    def edit_slot(self, index: int) -> PixelEditor | None:
        """Open the pixel editor over the file slot ``index`` holds -- the
        whole file, sixteen tiles to a row, under the palette row the VRAM
        panel draws that slot in -- and hand it back. Its Save writes the
        file whole through the host, as the tiles page's does."""
        host, pane = self._tiles_host, self._vram_pane
        number = self._slot_file(index)
        if host is None or pane is None or number is None:
            return None
        if self._file_editor is not None:
            self._file_editor.raise_()
            self._file_editor.activateWindow()
            return self._file_editor
        held = host.file(number)
        capture = pane.read(self.graphics)
        if held is None or capture is None:
            self._warn(f"GFX{number:02X} could not be read for editing.")
            return None
        _vram, cgram = capture
        row = pane.palette.currentData()
        if row is None:
            row = LAYER_ROW if index < LAYER_SLOTS else SPRITE_ROW
        surface = surface_of_file(held, row, cgram, host.backdrop())
        baseline = surface.palette
        offsets = colour_offsets_of(host)

        def save(painted: Surface) -> str:
            said = []
            colours = colour_edits(painted, baseline, offsets)
            if colours and host.save_colours is not None:
                note = host.save_colours(colours)
                said.append(
                    f"{len(colours)} colours changed" + (f". {note}" if note else "")
                )
            tiles = tiles_of_file(painted, held)
            if tiles == list(held.tiles):
                said.append("no tile changed")
            else:
                note = host.save({number: tiles})
                said.append(f"GFX{number:02X} written" + (f". {note}" if note else ""))
            return "; ".join(said)

        editor = PixelEditor(
            surface,
            save,
            title=f"Mushroom Paint - GFX{number:02X}",
            describe=lambda n: f"GFX{number:02X} tile {hexnum(n, 2)}",
            colour_editable=colour_editable_under(host),
            parent=self,
        )
        editor.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose, True)
        editor.saved.connect(lambda _said: self._show_vram())
        editor.finished.connect(self._file_editor_closed)
        self._file_editor = editor
        editor.open()
        return editor

    def _file_editor_closed(self) -> None:
        self._file_editor = None

    def _warn(self, message: str) -> None:
        """Say that something did not work -- the seam the tests answer
        through, since a message box never returns offscreen."""
        QMessageBox.warning(self, TITLE, message)

    def clone_slot(self, index: int) -> int | None:
        """Copy the file slot ``index`` holds into a file of the project's
        own, through the host, and point the slot at the copy -- offered on
        every upload slot's list from then on, since the project now has
        it. The new number, or ``None`` for a declined or refused clone."""
        host = self._tiles_host
        number = self._slot_file(index)
        if host is None or host.clone is None or number is None:
            return None
        try:
            new = host.clone(number, self)
        except GraphicsError as error:
            self._warn(f"GFX{number:02X} was not cloned: {error}")
            return None
        if new is None:
            return None
        self._offer_added_file(new)
        pick = self._slots[SLOTS[index]]
        pick.setCurrentIndex(self._offered_file(pick, new))
        return new

    def _offer_added_file(self, number: int) -> None:
        """List ``number`` on every upload slot as an added file, where it
        is not listed yet."""
        entry = (number, f"GFX{number:02X}", ADDED_FILE)
        if entry not in self._choices:
            self._choices = (*self._choices, entry)
        for slot in SLOTS[:UPLOAD_SLOTS]:
            pick = self._slots[slot]
            if self._offered_file(pick, number) < 0:
                pick.addItem(f"{entry[1]} - {entry[2]}", number)

    # -- the tiles page ---------------------------------------------------------

    @property
    def tiles_pane(self) -> LevelTilesPane | None:
        return self._tiles_pane

    @property
    def area(self) -> Area | None:
        """The area the tiles page shows, or ``None``."""
        return self._area

    def set_area(self, area: Area | None) -> None:
        """Show ``area`` on the tiles page, and bring the page forward."""
        self._area = area
        self._show_vram()
        if self._tabs is not None and self._tiles_pane is not None:
            self._tabs.setCurrentWidget(self._tiles_pane)

    def _on_tiles_page(self) -> bool:
        return (
            self._tabs is not None
            and self._tiles_pane is not None
            and self._tabs.currentWidget() is self._tiles_pane
        )

    def _copy_tiles(self) -> None:
        """Ctrl+C: the area, while the tiles page is in front. The slots page
        has nothing a copy could mean."""
        if self._on_tiles_page():
            assert self._tiles_pane is not None
            self._tiles_pane.copy()

    def _paste_tiles(self) -> None:
        if self._on_tiles_page():
            assert self._tiles_pane is not None
            self._tiles_pane.paste()

    def _weigh_the_animated_tiles(self) -> None:
        """Say that the ninth row waits for the accept, once it has moved.

        Only once it has: the note is about a picture that is not keeping up,
        and a row nobody has touched has nothing to keep up with
        (:data:`ANIMATED_NOTE`).
        """
        opened = animated_file(self._graphics)
        self._animated_note.setVisible(animated_file(self.graphics) != opened)

    # -- what VRAM holds ------------------------------------------------------

    def _fit_vram(self) -> None:
        """Open with a slot's whole width and :data:`VRAM_BANDS` of the
        column in view.

        A scroll area asks for almost nothing, so a dialog that let it would
        open with the panel squeezed to a band and the picture it is there for
        scrolled out of sight. The floor is a fixed size -- a slot is 128
        tiles whatever is in it -- so zooming in scrolls rather than growing
        the dialog, and the eight bands scroll past a window onto four.
        """
        pane = self._vram_pane
        if pane is None:
            return
        frame = 2 * pane.area.frameWidth()
        bar = pane.area.verticalScrollBar().sizeHint().width()
        band = pane.view.band_height(1)
        pane.area.setMinimumSize(
            pane.view.sizeHint().width() + frame + bar,
            VRAM_BANDS * (band + ROW_GAP) - ROW_GAP + frame,
        )

    def _effective_files(self) -> tuple[int | None, ...]:
        """Which file each of the eight VRAM slots loads as the dialog
        stands: the one it names, or its tileset's where it names none --
        ``None`` for a slot whose file the cartridge could not say. The
        animated tiles are not one of the eight and are not here."""
        files: list[int | None] = []
        for index, slot in enumerate(SLOTS[:UPLOAD_SLOTS]):
            named = self._slots[slot].currentData()
            if named is None and self._tileset_files is not None:
                named = self._tileset_files[index]
            files.append(named)
        return tuple(files)

    def _show_vram(self) -> None:
        """Draw what VRAM holds for the row as it stands.

        The row is *asked about* rather than applied: the caller works the
        answer out of the capture the canvas is drawn from, so a slot moved
        here shows the file it now names without waiting for a level load.
        A capture that cannot be read leaves the panel empty rather than the
        dialog broken -- the eight decisions do not depend on the picture.
        """
        pane = self._vram_pane
        if pane is None:
            return
        held = pane.read(self.graphics)
        files = self._effective_files()
        if self._tiles_pane is not None:
            # The same capture, read as the tiles of one area under the row
            # as it stands -- so a slot moved on the other page moves what
            # file each of those tiles is written back into.
            vram, cgram = held if held is not None else (None, None)
            self._tiles_pane.show_area(self._area, vram, cgram, files[:LAYER_SLOTS])
        try:
            sheets = (
                () if held is None else slot_sheets(*held, pane.palette.currentData())
            )
        except GraphicsError:
            sheets = ()
        pane.view.set_slots(
            [
                Slot(
                    name=VRAM_BAND_NAMES.get(slot, slot),
                    file="" if files[index] is None else f"GFX{files[index]:02X}",
                    address=hexnum(SLOT_WORDS[index], 4),
                    sheet=raster_to_image(sheets[index]),
                    spoken_for=ANIMATED_TILES[index],
                    regions=_regions_after(index),
                )
                for index, slot in enumerate(SLOTS[:UPLOAD_SLOTS])
            ]
            if sheets
            else []
        )

    def set_graphics(self, slot: str, file: int | None) -> None:
        """Name ``file`` in ``slot`` -- ``None`` for the tileset's -- driving
        the widget rather than going round it, so the control is the single
        source of the row however the change arrived."""
        pick = self._slots[slot]
        pick.setCurrentIndex(self._offered_file(pick, file))

    @staticmethod
    def _offered_file(pick: QComboBox, file: int | None) -> int:
        """Which row of a slot's combo names ``file`` -- ``None`` being the
        tileset's, always row 0 -- or ``-1``. By value rather than by
        position, since the rows are the file numbers."""
        return next(
            (row for row in range(pick.count()) if pick.itemData(row) == file), -1
        )

    def _refresh_tileset_files(self) -> None:
        """Word every slot's first entry from the level's header: the file
        the tileset would load there, named as the choices name it."""
        rows = None
        if self._tileset_rows is not None:
            rows = self._tileset_rows(self._header)
        names = {number: name for number, name, _ in self._choices}
        # The row order is the layer four then the sprite four, which is
        # the FG/BG list's row followed by the sprite list's.
        files = None if rows is None else (*rows[1], *rows[0])
        self._tileset_files = files
        for index, slot in enumerate(SLOTS[:UPLOAD_SLOTS]):
            text = TILESET_UNKNOWN
            if files is not None:
                file = files[index]
                text = TILESET_ENTRY.format(file=names.get(file, f"GFX{file:02X}"))
            self._slots[slot].setItemText(0, text)

    def _weigh_the_mode(self) -> None:
        """Hold the slots shut, and say why, over a level mode whose row the
        game never reads. The row itself is kept and handed back, so a mode
        changed out of the way in the header dialog brings the slots back
        exactly as they were."""
        reads = takes_a_row(self._header)
        for pick in self._slots.values():
            pick.setEnabled(reads)
        self._mode7_note.setVisible(not reads)

    @classmethod
    def edit(
        cls,
        parent: QWidget | None,
        header: bytes,
        graphics: bytes = b"",
        *,
        choices: Sequence[tuple[int, str, str]] = (),
        animated: Sequence[tuple[int, str, str]] = (),
        tileset_rows: TilesetRows | None = None,
        vram: VramFor | None = None,
        preview: Callable[[bytes], None] | None = None,
        tiles: TilesHost | None = None,
        area: Area | None = None,
    ) -> bytes | AreaPick | None:
        """Show the dialog; return the edited row, ``None`` if cancelled, or
        an :class:`AreaPick` when the tiles page asked the window to sweep
        an area -- the row as it stood rides in it, for the reopen.

        One entry point rather than a build-exec-read dance at the call site,
        so that "cancel changes nothing" is a property of this method instead
        of something every caller has to remember. The row is empty when
        every slot keeps its tileset's file, which is a level with no row.

        ``preview`` is told the row on every slot moved, for a caller that
        shows it (:attr:`changed`); putting the picture back afterwards is
        that caller's, since it is the one that knows what "back" is.
        ``vram`` is asked what a level with that row would be drawn out of,
        for the panel that shows it (:data:`VramFor`); left out, the dialog
        is the decisions alone. ``choices`` is what each of the eight VRAM
        slots may name and ``animated`` what the ninth byte may
        (:func:`shiny_mushroom.level_graphics.animated_choices`). ``tiles``
        is the window's side of the tiles page
        (:class:`~shiny_mushroom.ui.level_tiles_pane.TilesHost`); left out,
        there is no such page. ``area`` opens it on an area already picked.
        """
        dialog = cls(
            header,
            graphics,
            parent,
            choices=choices,
            animated=animated,
            tileset_rows=tileset_rows,
            vram=vram,
            tiles=tiles,
            area=area,
        )
        if preview is not None:
            dialog.changed.connect(preview)
        result = dialog.exec()
        row: bytes | AreaPick | None
        if result == PICK:
            row = AreaPick(dialog.graphics)
        else:
            row = (
                dialog.graphics if result == QDialog.DialogCode.Accepted.value else None
            )
        # Parented to the window so that it opens over it, which makes the
        # window its owner: without this, every visit to the page would leave
        # a dialog alive for as long as the window is.
        dialog.deleteLater()
        return row


def _takes_a_slot(file: int) -> bool:
    """Whether Edit and Clone mean anything over ``file``: a stock file the
    uploader writes into a slot, or any added file -- the only ones a slot's
    list offers, and not the set's to ask :func:`fits_a_slot` about."""
    return file not in FILE_NUMBERS or fits_a_slot(file)


def _unoffered(file: int) -> str:
    """Why a file a slot names is not among the choices: one of the ten the
    uploader never writes into a slot (:func:`smw_tools.graphics.fits_a_slot`),
    or an added file the project no longer holds."""
    if file in FILE_NUMBERS:
        return "not a file a slot takes"
    return "not in this project"


def _slot_tip(index: int) -> str:
    """What a slot is, for the tooltip: which list fills it on a stock
    cartridge, and which of that list's four entries -- or, for the ninth,
    that it is not one of the eight at all."""
    if index >= UPLOAD_SLOTS:
        return (
            f"{SLOTS[index]}: the 384 tiles the animated blocks, lava, coins "
            f"and conveyors are DMA'd out of. Decompressed and expanded into "
            f"WRAM on the way into the level, not uploaded to a VRAM slot."
        )
    if index < LAYER_SLOTS:
        return (
            f"Layer slot {SLOTS[index]}: entry {index} of the FG/BG tileset's "
            f"row of FGAndBGGFXList."
        )
    return (
        f"Sprite slot {SLOTS[index]}: entry {index - LAYER_SLOTS} of the sprite "
        f"tileset's row of SpriteGFXList."
    )
