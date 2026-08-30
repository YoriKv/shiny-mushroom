"""The level header: five bytes, thirteen fields, and what each one means.

Every level begins with five bytes that decide how it is set up rather than what
is in it -- how many screens long it is, which graphics and palettes it loads,
what the music is, how long you have. The object stream says what a level
*contains*; this says what kind of level it is.

Qt-free, like the object model: a field is a slice of a byte with a name, and
turning that into a row of widgets is the dialog's job. Keeping the two apart is
what lets the arithmetic -- which bits, which order, which value is stored one
less than it means -- be tested by reading bytes back.

Fields are named and bounded from the parser in the disassembly's
``SMW_LoadLevelHeader``. Where a value is one of a small set the game names
itself, the names come from the table it indexes; where it is not, the field is
a number and says so rather than inventing prose for it.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom.hexnum import hexbytes
from shiny_mushroom.metadata import OBJECTS

#: Bytes in a level header.
HEADER_SIZE = 5

#: The key of the one header field whose choices are not a fact about the
#: game's code: which track each music setting plays is a table a project can
#: edit, so a window showing it asks the project rather than reading
#: :data:`MUSIC` -- see :func:`shiny_mushroom.music_tables.setting_names`.
MUSIC_FIELD = "music"

#: The tracks the *shipped* ``LevelMusicTable`` gives those eight settings.
#: What a window falls back to when there is no project to ask.
MUSIC = (
    "Here We Go",
    "Cave Drums",
    "Piano",
    "Castle",
    "Ghost House",
    "Water Level",
    "Boss Battle",
    "Switch Palace",
)

#: ``TimerTable``, which holds the hundreds digit: ``$00 $02 $03 $04``. Zero is
#: not "no time" by accident -- it is what the untimed rooms use.
TIME_LIMITS = ("None", "200", "300", "400")

#: The four vertical scroll settings, as the header parser reads them into
#: ``!RAM_SMW_Flag_Layer1VerticalScrollLevelSetting``. ``$3`` is the odd one:
#: the parser turns it into the same zero as ``$0`` and clears the *horizontal*
#: setting on the way past, so it is the only value that stops both.
VERTICAL_SCROLL = (
    "None",
    "Free",
    "Free when flying or climbing",
    "None, and no horizontal scroll",
)

#: The sixteen sprite tilesets a header can name, by the row of
#: ``SpriteGFXList`` each one selects -- four sprite graphics files, named after
#: what the shipped levels using the row put on screen. The table has ten more
#: rows above these, reached by the overworld, the cutscenes and the credits
#: rather than by a header, so a four-bit field cannot name them.
SPRITE_TILESETS = (
    "Forest",
    "Castle",
    "Mushroom",
    "Underground",
    "Water",
    "Pokey",
    "Underground 2",
    "Ghost House",
    "Banzai Bill",
    "Yoshi's House",
    "Dino-Rhino",
    "Switch Palace",
    "Mecha-Koopa",
    "Wendy/Lemmy",
    "Ninji",
    "Unused (no shipped level selects it)",
)

#: The thirty-two level modes, from the six parallel tables the header parser
#: indexes with this field -- ``VerticalTable``, ``LevMainScrnTbl``,
#: ``LevSubScrnTbl``, ``LevCGADSUBtable``, ``SpecialLevTable`` and
#: ``LevXYPPCCCTtbl``, which name the same thirty-two rows the same way.
#:
#: Several names repeat: ``$0E`` and ``$0F`` differ from ``$00`` and ``$01``
#: only in which layers go on the main screen and which on the sub, and ``$11``
#: from ``$0C`` only in its colour maths. The number in front of the name in a
#: dropdown is what tells them apart, which is why it is shown.
LEVEL_MODES = (
    "Horizontal",
    "Horizontal, Layer 2 (no interaction)",
    "Horizontal, Layer 2 (interaction)",
    "Do not use",
    "Do not use",
    "Do not use",
    "Do not use",
    "Vertical, Layer 2 (no interaction)",
    "Vertical, Layer 2 (interaction)",
    "Horizontal boss (Reznor, Ludwig, Roy, Morton)",
    "Vertical",
    "Horizontal boss (Larry, Iggy)",
    "Horizontal, dark background",
    "Vertical, dark background",
    "Horizontal",
    "Horizontal, Layer 2 (no interaction)",
    "Horizontal boss (Bowser)",
    "Horizontal, dark background",
    *("Cannot use",) * 12,
    "Horizontal, translucent",
    "Horizontal, Layer 2 translucent (interaction)",
)

#: The fifteen tilesets, by the object table each one dispatches to. Tileset
#: ``$F`` indexes past the dispatcher's entries; the cart never sets it.
TILESETS = tuple(
    OBJECTS.tileset_groups.get(number, "Unused (past the dispatcher)")
    for number in range(16)
)

#: The level modes whose Layer 2 the loader never walks as an object stream:
#: mode ``$00`` and the six ``SMW_BeginLoadingLevelData`` names outright, plus
#: the three boss modes, which leave its loop before either layer is read.
#:
#: Every *other* mode sends the loader back round that loop with the Layer 2
#: pointer in place of the Layer 1 one, so a level in one of them reads its
#: Layer 2 entry as a stream of objects. Which of the two the entry actually
#: holds is the pointer's own business (:mod:`shiny_mushroom.layer2_table`),
#: and nothing makes the two agree -- see :func:`needs_layer2_data`.
LAYER2_IMAGE_MODES = frozenset(
    {0x00, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x10, 0x11, 0x1E}
)


@dataclass(frozen=True)
class HeaderField:
    """One field: a run of bits in one header byte, named."""

    key: str
    name: str
    byte: int
    shift: int
    bits: int
    description: str

    #: Value names, when the field selects one of a set the game itself names.
    #: There is one per value the bits can hold, so every value has a name and
    #: a dropdown over them can show any header.
    #:
    #: ``None`` means the value is a number and the editor shows it as one --
    #: which is the honest answer for the palette indices and the item memory,
    #: whose meaning is a table of colours or a rule rather than a word.
    choices: tuple[str, ...] | None = None

    #: What the stored value is short of the value that is meant. The screen
    #: count is stored minus one, so a one-screen level stores zero.
    offset: int = 0

    @property
    def mask(self) -> int:
        return ((1 << self.bits) - 1) << self.shift

    @property
    def minimum(self) -> int:
        return self.offset

    @property
    def maximum(self) -> int:
        return ((1 << self.bits) - 1) + self.offset

    def get(self, header: bytes) -> int:
        """The field's value in ``header``, offset applied."""
        return ((header[self.byte] & self.mask) >> self.shift) + self.offset

    def set(self, header: bytes, value: int) -> bytes:
        """``header`` with this field set to ``value``. Out-of-range clamps.

        Clamped rather than raised: every caller is a widget that already bounds
        its own value, and a header is five bytes with no room for a field to
        spill into its neighbour.
        """
        stored = min(max(value, self.minimum), self.maximum) - self.offset
        edited = bytearray(header)
        edited[self.byte] = (edited[self.byte] & ~self.mask) | (
            stored << self.shift
        ) & self.mask
        return bytes(edited)

    def text(self, header: bytes) -> str:
        """The value as the editor shows it: a name where there is one."""
        value = self.get(header)
        if self.choices is None:
            return str(value)
        return self.choices[value - self.offset]


#: Every field, in the order the bytes run. Bit positions and destinations are
#: the header parser's; the wording is the shortest thing that says what the
#: field decides.
FIELDS: tuple[HeaderField, ...] = (
    HeaderField(
        "background_palette",
        "Background palette",
        0,
        5,
        3,
        "Which of eight background palette sets the level loads.",
    ),
    HeaderField(
        "screens",
        "Screens",
        0,
        0,
        5,
        "How long the level is, in screens.",
        offset=1,
    ),
    HeaderField(
        "back_area_color",
        "Back area colour",
        1,
        5,
        3,
        "The colour behind everything, shown wherever a tile is transparent.",
    ),
    HeaderField(
        "level_mode",
        "Level mode",
        1,
        0,
        5,
        "The level's geometry and which layers are drawn: horizontal or "
        "vertical, Layer 2 as tiles or as a background, boss room.",
        choices=LEVEL_MODES,
    ),
    HeaderField(
        "layer3_priority",
        "Layer 3 priority",
        2,
        7,
        1,
        "Whether Layer 3 is drawn in front of the level.",
        choices=("Normal", "In front"),
    ),
    HeaderField(
        "music",
        "Music",
        2,
        4,
        3,
        "The level's music, through LevelMusicTable.",
        choices=MUSIC,
    ),
    HeaderField(
        "sprite_tileset",
        "Sprite tileset",
        2,
        0,
        4,
        "Which sprite graphics load -- the enemies the level can show.",
        choices=SPRITE_TILESETS,
    ),
    HeaderField(
        "time_limit",
        "Time limit",
        3,
        6,
        2,
        "Seconds on the clock; only the hundreds digit is stored.",
        choices=TIME_LIMITS,
    ),
    HeaderField(
        "sprite_palette",
        "Sprite palette",
        3,
        3,
        3,
        "Which of eight sprite palette sets the level loads.",
    ),
    HeaderField(
        "foreground_palette",
        "Foreground palette",
        3,
        0,
        3,
        "Which of eight foreground palette sets the level loads.",
    ),
    HeaderField(
        "item_memory",
        "Item memory",
        4,
        6,
        2,
        "How the level remembers coins and blocks already collected.",
    ),
    HeaderField(
        "vertical_scroll",
        "Vertical scroll",
        4,
        4,
        2,
        "Whether and how the camera follows the player up and down. The last "
        "setting stops it horizontally too.",
        choices=VERTICAL_SCROLL,
    ),
    HeaderField(
        "fg_bg_tileset",
        "FG/BG tileset",
        4,
        0,
        4,
        "Which graphics files load, which Map16 definitions the tiles use, "
        "and what each object number means.",
        choices=TILESETS,
    ),
)

FIELDS_BY_KEY = {field.key: field for field in FIELDS}


def field_value(header: bytes, key: str, default: int = 0) -> int:
    """One field's value out of ``header``, or ``default`` when the bytes stop
    short of it.

    For the callers that want a single field rather than the whole readout, and
    that may be handed a level carrying no header at all: the bits are here,
    said once, so nothing else has to know which byte a field sits in.
    """
    found = FIELDS_BY_KEY[key]
    return found.get(header) if len(header) > found.byte else default


def needs_layer2_data(header: bytes) -> bool:
    """Whether ``header``'s level mode makes the game read Layer 2 as objects.

    The header says which of the two shapes the loader goes looking for; the
    level's Layer 2 pointer says which one the bytes are. Nothing checks that
    they agree, and one way round the disagreement is fatal: a mode that walks
    objects, over an entry that is a background image, has the loader parse a
    compressed background tilemap as an object stream. It places objects on
    screens the layout tables do not have and never comes back -- so a load
    that would end that way is worth refusing before it is saved.
    """
    return field_value(header, "level_mode") not in LAYER2_IMAGE_MODES


def describe(header: bytes) -> list[tuple[str, str]]:
    """Every field as label/value pairs, for a readout."""
    return [(field.name, field.text(header)) for field in FIELDS]


def format_bytes(header: bytes) -> str:
    """The header as hex, the way the disassembly and a hex editor show it."""
    return hexbytes(header)
