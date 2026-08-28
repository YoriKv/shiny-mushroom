"""Point a level number at other containers -- the Level Data window's remap.

The level-number side of what the header dialog's Layer 2 subsection does for
the third stream: a level's Layer 1 and sprite pointer-table entries, offered
as the containers they could name instead. The dialog only *chooses* -- a
level, and a container per stream -- and hands the choice back; writing the
tables is :meth:`~shiny_mushroom.project.Project.save_level_pointers`' job,
and whether the open level has to be reloaded over it is the window's, which
owns the unsaved-work question a reload asks first.

Two pickers rather than one because that is what the format is: forty-five
shipped levels already take their layout and their sprite list out of two
different files, and remapping one stream is how such a level is made. The
consequence line under them is the other honest thing a remap has to say --
which level numbers will share the chosen files -- because sharing is the
easiest thing to create by accident and nothing else says it before a save
does.

The same line says where the level's **Layer 2** will go. A Layer 1 file is
half a level, and the file records what its level had behind it -- a
background, or the stream a Layer 2 mode walks -- so a Layer 1 move takes
the number's Layer 2 entry along
(:meth:`~shiny_mushroom.project.Project.layer2_for_container`); without that
the number would draw its old background under the new level. The dialog
says which entry will follow, or that none will when the file names one the
tree does not hold.

And it carries the one combination that does not merely look wrong. A Layer
1 file whose header names a Layer 2 level mode makes the game read the
level's *Layer 2* entry as objects, and pointing such a file at a number
whose Layer 2 would be a background image hangs the cartridge on the load.
The dialog asks its caller (:meth:`~shiny_mushroom.project.Project.layer2_gap`)
about the pair as it would stand, says so, and holds OK shut -- because a
save would refuse it anyway, and the error is better read before the button
than after it.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtWidgets import (
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QLabel,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer2_table import Layer2Entry
from shiny_mushroom.level_files import ContainerNames
from shiny_mushroom.level_pointers import StreamTarget
from shiny_mushroom.project_levels import Layer2Gap
from shiny_mushroom.ui.tables import style_note
from smw_tools.levels import LEVEL_COUNT

TITLE = "Remap a Level"

#: What a remap is, said up front: the files keep their bytes, the number
#: changes which of them it is a route to.
HINT = (
    "A level number routes to a pair of .mwl files -- header and layout, and "
    "sprite list. No file's bytes move."
)


class RemapLevelDialog(QDialog):
    """Choose a level number and the containers its two entries should name.

    ``levels`` is what each number reads today
    (:func:`~shiny_mushroom.level_files.container_names` over the project's
    own tables), and the two target lists are the labels the banks define
    (:meth:`~shiny_mushroom.project.Project.layer1_targets` and
    :meth:`~shiny_mushroom.project.Project.sprite_targets`).
    """

    def __init__(
        self,
        levels: dict[int, ContainerNames],
        layer1: tuple[StreamTarget, ...],
        sprites: tuple[StreamTarget, ...],
        level: int,
        parent: QWidget | None = None,
        container: str | None = None,
        gap: Callable[[int, str, Layer2Entry | None], Layer2Gap | None] | None = None,
        layer2: Callable[[str], Layer2Entry | None] | None = None,
    ) -> None:
        """``container`` is the file to open the two pickers on -- the row
        the viewer had selected -- where the level's own entries would
        otherwise be the starting point. A stream the file is not offered
        for keeps the level's own.

        ``layer2`` is
        :meth:`~shiny_mushroom.project.Project.layer2_for_container`: what
        the chosen Layer 1 file says its Layer 2 was, which the remap will
        point the number at. ``gap`` is
        :meth:`~shiny_mushroom.project.Project.layer2_gap`, asked of every
        Layer 1 choice with that entry, so the pair weighed is the pair the
        save writes. Either left out -- by a test standing the form up on its
        own -- the dialog simply does not say that much, and the save still
        makes its own check.
        """
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self._levels = levels
        self._gap = gap
        self._layer2 = layer2
        #: What ``gap`` and ``layer2`` answered, by what they were asked
        #: about: each answer costs a container read or more, and every
        #: keystroke in either combo asks again for the same one.
        self._gaps: dict[tuple[int, str], Layer2Gap | None] = {}
        self._carried: dict[str, Layer2Entry | None] = {}

        layout = QVBoxLayout(self)
        hint = QLabel(HINT)
        hint.setWordWrap(True)
        style_note(hint)
        layout.addWidget(hint)

        form = QFormLayout()
        self._level = QComboBox()
        for number in range(LEVEL_COUNT):
            self._level.addItem(f"{hexnum(number, 3)} — {self._named(number)}", number)
        form.addRow("&Level:", self._level)

        self._layer1 = self._targets(layer1)
        form.addRow("Layer &1 file:", self._layer1)
        self._sprites = self._targets(sprites)
        form.addRow("&Sprites file:", self._sprites)
        layout.addLayout(form)

        #: Who else will read the chosen files -- the one consequence a remap
        #: creates that nothing else says before a save does.
        self._consequence = QLabel()
        self._consequence.setWordWrap(True)
        style_note(self._consequence)
        layout.addWidget(self._consequence)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)
        self._ok = buttons.button(QDialogButtonBox.StandardButton.Ok)

        self._level.currentIndexChanged.connect(self._level_changed)
        self._layer1.currentIndexChanged.connect(self._retell)
        self._sprites.currentIndexChanged.connect(self._retell)
        self._level.setCurrentIndex(max(0, min(level, LEVEL_COUNT - 1)))
        self._level_changed()
        # The viewer's selected file, where it is offered: a stream it is not
        # offered for keeps the level's own.
        if container is not None:
            for box in (self._layer1, self._sprites):
                self._land(box, container)
            self._retell()

    # -- what was chosen -----------------------------------------------------

    @property
    def chosen_level(self) -> int:
        return int(self._level.currentData())

    def chosen_layer1(self) -> StreamTarget | None:
        """The Layer 1 target picked, or ``None`` for one that is no move --
        the container the level's entry already names, whatever label spells
        it, is not an edit."""
        return self._chosen(self._layer1, lambda names: names.layer1)

    def chosen_sprites(self) -> StreamTarget | None:
        """The sprite target picked, on :meth:`chosen_layer1`'s terms."""
        return self._chosen(self._sprites, lambda names: names.sprites)

    def chosen_layer2(self) -> Layer2Entry | None:
        """The Layer 2 entry the Layer 1 move carries with it -- ``None`` when
        Layer 1 is not moving, when nothing was given to ask, or when the
        file names a Layer 2 the tree does not hold."""
        chosen = self.chosen_layer1()
        if self._layer2 is None or chosen is None:
            return None
        if chosen.container not in self._carried:
            self._carried[chosen.container] = self._layer2(chosen.container)
        return self._carried[chosen.container]

    def _chosen(self, box: QComboBox, current) -> StreamTarget | None:
        target = box.currentData()
        if target is None:
            return None
        names = self._levels.get(self.chosen_level)
        if names is not None and current(names) == target.container:
            return None
        return target

    # -- keeping the form honest ---------------------------------------------

    def _targets(self, offered: tuple[StreamTarget, ...]) -> QComboBox:
        box = QComboBox()
        for target in offered:
            box.addItem(target.container, target)
        return box

    def _named(self, level: int) -> str:
        names = self._levels.get(level)
        if names is None:
            # A number the tree does not place -- a table entry naming a label
            # nothing defines. Remapping is exactly how it becomes a level.
            return "(not placed)"
        if names.split:
            return f"{names.layer1} / {names.sprites}"
        return names.layer1

    def _level_changed(self) -> None:
        """A new level starts from what its entries name today, so the combos
        read as facts until they are moved."""
        names = self._levels.get(self.chosen_level)
        self._select(self._layer1, None if names is None else names.layer1)
        self._select(self._sprites, None if names is None else names.sprites)
        self._retell()

    def _land(self, box: QComboBox, container: str) -> None:
        """Land ``box`` on ``container`` where it is offered, and leave it
        where it is otherwise."""
        for index in range(box.count()):
            held = box.itemData(index)
            if held is not None and held.container == container:
                box.setCurrentIndex(index)
                return

    def _select(self, box: QComboBox, container: str | None) -> None:
        """Land ``box`` on ``container``, inventing the row when the list has
        none for it.

        The invented row carries no target, so leaving it selected is leaving
        the entry alone -- without it, a container whose label is not offered
        for this stream would leave the box on whatever the last level chose,
        and accepting would remap a stream nobody touched.
        """
        if box.itemData(0) is None and box.count():
            box.removeItem(0)
        if container is None:
            return
        for index in range(box.count()):
            if box.itemData(index).container == container:
                box.setCurrentIndex(index)
                return
        box.insertItem(0, container, None)
        box.setCurrentIndex(0)

    def _retell(self) -> None:
        """Say what the choice does: whether it would load at all, and who
        will share the chosen files."""
        level = self.chosen_level
        one = self._layer1.currentData()
        other = self._sprites.currentData()
        gap = self._layer2_gap()
        self._ok.setEnabled(gap is None)
        parts = [] if gap is None else [gap.refusing_a_remap]
        if one is not None and other is not None:
            sharing = sorted(
                number
                for number, names in self._levels.items()
                if number != level
                and (names.layer1 == one.container or names.sprites == other.container)
            )
            if sharing:
                listed = ", ".join(hexnum(number, 3) for number in sharing)
                parts.append(
                    f"Saving {hexnum(level, 3)} will then also change {listed}: "
                    f"the same bytes under other numbers, not copies."
                )
            else:
                parts.append("No other level number reads these files.")
        followed = self._layer2_said()
        if followed:
            parts.append(followed)
        self._consequence.setText("\n\n".join(parts))

    def _layer2_said(self) -> str:
        """Where the level's Layer 2 goes with this Layer 1 move, or nothing
        when Layer 1 is not moving or nothing was given to ask."""
        chosen = self.chosen_layer1()
        if self._layer2 is None or chosen is None:
            return ""
        carried = self.chosen_layer2()
        if carried is None:
            return (
                f"Its Layer 2 stays where it is: {chosen.container}.mwl names "
                f"one the tree does not hold."
            )
        return f"Its Layer 2 follows the file: {carried.describe()}."

    def _layer2_gap(self) -> Layer2Gap | None:
        """Whether the Layer 1 choice would leave the game reading a background
        as objects -- asked only of a choice that is a move, because a level
        already sitting on such a pair is not this remap's doing and refusing
        to touch it would strand it. Asked with the Layer 2 entry the move
        carries, so the pair weighed is the pair the save writes."""
        chosen = self.chosen_layer1()
        if self._gap is None or chosen is None:
            return None
        key = (self.chosen_level, chosen.container)
        if key not in self._gaps:
            self._gaps[key] = self._gap(*key, self.chosen_layer2())
        return self._gaps[key]
