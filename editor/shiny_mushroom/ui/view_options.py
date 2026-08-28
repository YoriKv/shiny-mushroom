"""What the View menu's toggles hold, and where each one is remembered.

A handful of booleans that used to sit among the window's forty-odd fields, each with
its own ``load_bool_setting`` call and its own settings key spelled out beside
it. Gathered here because they are one thing -- *how the level is shown*, as
against what is in it -- and because a default belongs next to the reason for
it rather than in the middle of a constructor.

They are properties of the **person**, not of the cartridge: someone who works
with Layer 3 off wants it off in the next level and the next session, whatever
they open. That is the same rule :mod:`shiny_mushroom.ui.settings` states, and
this is the largest group of preferences following it.

What each toggle *costs* is not here. Layer 2 is in the picture and so needs a
re-render; an object outline is painted over it and needs only a repaint. Those
are consequences for the window to work out -- see
``MainWindow._set_show_layer2`` and the rest -- and this holds only the answer
they are switching.
"""

from __future__ import annotations

from dataclasses import dataclass, fields

from shiny_mushroom.ui.settings import load_bool_setting, save_bool_setting

#: Where each toggle is stored. Under ``view/`` because that is what they are
#: about, and spelled in the store rather than derived from the field name so
#: that renaming a field here can never quietly orphan somebody's preference.
KEYS = {
    "layer1": "view/layer1",
    "layer2": "view/layer2",
    "layer3": "view/layer3",
    "sprites": "view/sprites",
    "sprite_outlines": "view/sprite-outlines",
    "objects": "view/objects",
    "screens": "view/screens",
}


@dataclass(slots=True)
class ViewOptions:
    """The answers, with the defaults a first launch gets."""

    #: On, all three: the layers are what a level *looks like*, not an
    #: annotation of it. Switching one off is for seeing past it -- the ledge
    #: under a tide, the shape of a level whose background is busier than it
    #: is -- and Layer 1 comes off for the opposite look, the background bare
    #: of the level standing in front of it.
    layer1: bool = True
    layer2: bool = True
    layer3: bool = True

    #: On: a sprite is part of the picture in the same way a block is, and a
    #: level drawn without them is a level with things missing from it.
    sprites: bool = True

    #: Off unless asked for, exactly like the object boxes and for the same
    #: reason: the artwork is what a level looks like, and a grey box around
    #: every sprite in it is a way of *reading* the level rather than something
    #: to work under. Separate from the artwork because the two answer different
    #: questions -- what is here, and where does it reach -- and because a sprite
    #: that draws nothing is only its box.
    sprite_outlines: bool = False

    #: Off unless asked for: a box around every object in the level is a way of
    #: reading the level's structure, not a thing to look at while working. The
    #: selection's outline is drawn either way.
    objects: bool = False

    #: On, unlike the object boxes: a screen boundary is one line every 256
    #: pixels and the number on it is what the level data counts in, so it earns
    #: its place in the picture rather than being a mode to go looking for.
    screens: bool = True

    @classmethod
    def load(cls) -> ViewOptions:
        """What the store says, falling back per option to the default above."""
        return cls(
            **{
                field.name: load_bool_setting(KEYS[field.name], field.default)
                for field in fields(cls)
            }
        )

    def set(self, option: str, value: bool) -> None:
        """Take ``option``'s new value and remember it for the next session.

        One method rather than a setter per toggle, so that "the answer changed"
        and "write it down" cannot come apart -- which is the failure this
        replaces: seven pairs of lines, each of which had to name the right
        field *and* the right key.

        An option this does not have raises rather than quietly growing an
        eighth: the key lookup fails first, and the dataclass is slotted, so
        neither half of a typo lands.
        """
        save_bool_setting(KEYS[option], value)
        setattr(self, option, value)

    @property
    def any_sprites(self) -> bool:
        """Whether a sprite is in the picture at all -- as artwork, as a box, or
        as both.

        What decides whether a click can land on one, because what is shown is
        what can be picked out of the picture, and a sprite that draws nothing is
        still there while its box is.
        """
        return self.sprites or self.sprite_outlines
