"""A custom sprite's properties, edited in the application.

The metadata sibling beside a sprite's code is PIXI's own JSON schema --
which is what makes importing that tool's sprites a copy -- and this dialog
is the CFG Editor's job done once: the acts-like number, the two extra
property bytes and the six Tweaker bytes' 38 fields, shown in the source's
own vocabulary (``sprites/SpritePropertiesTemplate.asm``'s names) and stored
under the tool's keys.

The dialog edits one ``.json`` and writes it back whole on OK. A key the
schema does not carry -- the display block PIXI writes for Lunar Magic --
rides through untouched: the file may have been imported, and dropping what
this dialog does not edit would lose someone else's data silently.

One key is the editor's own: ``Name``, what the project calls the sprite --
the create panel's row, the status bar and the properties heading all say
it (:func:`shiny_mushroom.project_sprites.custom_names`, which also reads
an imported file's ``Collection`` name where nobody has written one).
"""

from __future__ import annotations

import json
from pathlib import Path

from PySide6.QtWidgets import (
    QCheckBox,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QMessageBox,
    QScrollArea,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.ui.tables import style_note
from smw_tools.sprite_code import (
    DEFAULT_ACTS_LIKE,
    EXTRA_BYTE_LIMIT,
    EXTRA_BYTES_KEY,
    TWEAK_NAMES,
)

TITLE = "Sprite Properties"

#: The multi-bit fields, by their PIXI key, with each one's width. Everything
#: else in the Tweaker bytes is one bit and shown as a switch.
_NUMERIC = {
    "Object Clipping": 0x0F,
    "Sprite Clipping": 0x3F,
    "Palette": 0x07,
}

#: What the byte groups are called over their boxes: the RAM table each one
#: loads into, which is the vocabulary the disassembly's comments use.
_GROUPS = {
    "$1656": "$1656 -- clipping and stomping",
    "$1662": "$1662 -- shells and death",
    "$166E": "$166E -- palette and immunities",
    "$167A": "$167A -- interaction",
    "$1686": "$1686 -- Yoshi and objects",
    "$190F": "$190F -- platforms and POW",
}


class SpritePropertiesDialog(QDialog):
    """Edit one sprite's metadata sibling. Construct with the ``.json``
    path, ``exec``, then read :attr:`saved`."""

    def __init__(
        self,
        path: Path,
        parent: QWidget | None = None,
        project=None,
        number: int | None = None,
    ) -> None:
        super().__init__(parent)
        self._path = path
        #: For the extra-byte count's refusal: the levels already placing
        #: this number were encoded under the count as it stands, so it may
        #: only move while there are none. Absent, the count is offered
        #: unguarded -- a dialog opened on a bare file has nothing to scan.
        self._project = project
        self._number = number
        #: Whether OK wrote the file -- what makes closing the dialog a
        #: rebuild for whoever opened it.
        self.saved = False
        self._meta = self._read()
        self._numbers: dict[tuple[str, str], QSpinBox] = {}
        self._switches: dict[tuple[str, str], QCheckBox] = {}

        self.setWindowTitle(f"{TITLE} - {path.name}")
        self.setMinimumSize(560, 520)
        layout = QVBoxLayout(self)
        note = QLabel(
            "The fields are the vanilla sprite properties' own vocabulary; "
            "the file beside the sprite's code stores them in PIXI's JSON "
            "schema, so that tool's sprites import unchanged."
        )
        note.setWordWrap(True)
        style_note(note)
        layout.addWidget(note)

        name_row = QHBoxLayout()
        held = self._meta.get("Name")
        self._name = QLineEdit(held if isinstance(held, str) else "")
        self._name.setToolTip(
            "The project's own name for the sprite, said wherever the sprite "
            "is named. Left empty, it falls back to the imported collection's "
            'name, or "Custom sprite $NN".'
        )
        name_row.addWidget(QLabel("Name:"))
        name_row.addWidget(self._name, 1)
        layout.addLayout(name_row)

        top = QHBoxLayout()
        self._acts = self._spin(
            0x00, 0xFF, int(self._meta.get("ActLike", DEFAULT_ACTS_LIKE))
        )
        self._prop1 = self._spin(
            0x00, 0xFF, int(self._meta.get("Extra Property Byte 1", 0))
        )
        self._prop2 = self._spin(
            0x00, 0xFF, int(self._meta.get("Extra Property Byte 2", 0))
        )
        self._extra = QSpinBox()
        self._extra.setRange(0, EXTRA_BYTE_LIMIT)
        self._extra.setValue(
            max(0, min(EXTRA_BYTE_LIMIT, int(self._meta.get(EXTRA_BYTES_KEY, 0))))
        )
        self._extra.setToolTip(
            "How many extra bytes each placed record carries for this "
            "sprite's code to read. Part of the level format's stride, so "
            "it can only change while no level places the sprite."
        )
        for label, box in (
            ("Acts like:", self._acts),
            ("Extra property 1:", self._prop1),
            ("Extra property 2:", self._prop2),
            ("Extra bytes:", self._extra),
        ):
            top.addWidget(QLabel(label))
            top.addWidget(box)
        top.addStretch()
        layout.addLayout(top)

        inside = QWidget()
        form = QVBoxLayout(inside)
        for byte, fields in TWEAK_NAMES.items():
            box = QGroupBox(_GROUPS[byte])
            rows = QFormLayout(box)
            values = self._meta.get(byte, {})
            values = values if isinstance(values, dict) else {}
            for key, name in fields:
                value = values.get(key, 0)
                if key in _NUMERIC:
                    spin = self._spin(0, _NUMERIC[key], int(value))
                    self._numbers[(byte, key)] = spin
                    rows.addRow(f"{name}:", spin)
                else:
                    switch = QCheckBox(name)
                    switch.setChecked(bool(value))
                    self._switches[(byte, key)] = switch
                    rows.addRow(switch)
            form.addWidget(box)
        scroll = QScrollArea()
        scroll.setWidget(inside)
        scroll.setWidgetResizable(True)
        layout.addWidget(scroll)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self._save)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    def _spin(self, low: int, high: int, value: int) -> QSpinBox:
        box = QSpinBox()
        box.setRange(low, high)
        box.setDisplayIntegerBase(16)
        box.setPrefix("$")
        box.setValue(max(low, min(high, value)))
        return box

    def _read(self) -> dict:
        """The file as it stands, or the empty mapping for one not yet
        written -- a sprite with no sibling acts like the unused sprite with
        every flag clear, which is what the empty mapping reads as."""
        try:
            found = json.loads(self._path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return {}
        return found if isinstance(found, dict) else {}

    def _save(self) -> None:
        held = max(0, min(EXTRA_BYTE_LIMIT, int(self._meta.get(EXTRA_BYTES_KEY, 0))))
        if (
            self._extra.value() != held
            and self._project is not None
            and self._number is not None
        ):
            from shiny_mushroom.project_sprites import custom_placements

            placed = custom_placements(self._project, self._number)
            if placed:
                listed = ", ".join(f"${level:03X}" for level in placed[:6])
                if len(placed) > 6:
                    listed += f" and {len(placed) - 6} more"
                QMessageBox.warning(
                    self,
                    TITLE,
                    f"The extra byte count is part of the level format's "
                    f"stride, and {len(placed)} level(s) already place this "
                    f"sprite under the count as it stands: {listed}.\n\n"
                    f"Remove those placements first, or keep the count.",
                )
                return
        meta = dict(self._meta)
        named = self._name.text().strip()
        if named:
            meta["Name"] = named
        else:
            # An emptied field takes the key out rather than storing "":
            # the fallbacks -- the collection name, the plain number --
            # only speak where nothing is written.
            meta.pop("Name", None)
        meta["ActLike"] = self._acts.value()
        meta["Extra Property Byte 1"] = self._prop1.value()
        meta["Extra Property Byte 2"] = self._prop2.value()
        meta[EXTRA_BYTES_KEY] = self._extra.value()
        for byte, fields in TWEAK_NAMES.items():
            held = meta.get(byte)
            held = dict(held) if isinstance(held, dict) else {}
            for key, _name in fields:
                if (byte, key) in self._numbers:
                    held[key] = self._numbers[(byte, key)].value()
                else:
                    held[key] = self._switches[(byte, key)].isChecked()
            meta[byte] = held
        try:
            self._path.parent.mkdir(parents=True, exist_ok=True)
            self._path.write_text(
                json.dumps(meta, indent=1) + "\n", encoding="utf-8", newline="\n"
            )
        except OSError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        self.saved = True
        self.accept()
