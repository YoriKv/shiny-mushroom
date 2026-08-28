"""Shiny Mushroom - a cross-platform editor built on the disassembly in ``smw/``.

The package is laid out so that only :mod:`shiny_mushroom.ui` (and the
:mod:`shiny_mushroom.app` bootstrap) imports Qt. Every other module stays Qt-free, so
the model side is testable and reusable headless - the same rule that keeps
``smw_tools`` importable from a build script.

- :mod:`shiny_mushroom.app` - QApplication bootstrap and entry point.
- :mod:`shiny_mushroom.ui` - the Qt front end: main window, canvas, theme.
- :mod:`shiny_mushroom.resources` - bundled read-only assets, resolved so they
  survive a frozen release build.

``smw_tools`` is a sibling package in the same environment, not a dependency of
this one: the editor may import it to read the disassembly, but nothing in
``smw_tools`` may import the editor or Qt.
"""

__version__ = "0.1.0"

# The name shown to a person: window titles, dialogs, the About box, and
# QApplication.applicationName.
APP_NAME = "Shiny Mushroom"

# The name the *platform* files data and preferences under (application-data
# directory, QSettings). Deliberately not APP_NAME: a space in a path is
# awkward to type and quote on every platform, and this string is never shown.
# It matches the repository and the distribution name rather than the Python
# package, so a person looking at ~/.config or %APPDATA% sees the project they
# installed. Changing it orphans whatever the previous id filed away -- there
# is no migration, which is only acceptable because nothing has shipped yet.
# Both live here rather than in the Qt bootstrap because the bootstrap (data
# location) and the preference store (:func:`shiny_mushroom.ui.settings.settings`)
# must agree on them.
APP_ID = "shiny-mushroom"

#: Turns on the package's own logging, which is otherwise silent: set it to a
#: level name (``DEBUG``, ``INFO``) or to ``1`` for ``DEBUG``.
#:
#: The emulator side is where this earns its keep, because most of what can go
#: wrong there produces a plausible picture rather than an error -- a sprite
#: whose graphics routine hangs and a sprite that legitimately draws nothing
#: both come back as no tiles, and from outside they are the same answer.
DEBUG_ENV = "SHINY_MUSHROOM_DEBUG"


def configure_logging(value: str | None = None) -> int | None:
    """Install a stderr handler for this package's loggers, if asked for.

    Returns the level applied, or ``None`` when the variable is unset and
    nothing was configured. Only ``shiny_mushroom``'s own logger is touched, so
    turning it on does not make Qt or anything else start talking.

    Here rather than in :mod:`shiny_mushroom.app` because the **emulator worker
    is a separate process** and does its own logging: the parent's handler does
    the child no good across a pipe, and the child must not import Qt, which
    ``app`` does. Both entry points call this; a library module never does,
    because installing a handler is a decision for the application.
    """
    import logging
    import os

    raw = (value if value is not None else os.environ.get(DEBUG_ENV, "")).strip()
    if not raw:
        return None
    # A bare truthy value means "as much as there is"; a name means that level.
    level = logging.DEBUG if raw in {"1", "true", "yes"} else raw.upper()
    logger = logging.getLogger(__name__)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(levelname)s %(name)s: %(message)s"))
    logger.addHandler(handler)
    try:
        logger.setLevel(level)
    except ValueError:
        # An unusable value is worth saying so about rather than falling back
        # silently -- the point of setting it was to see more, not less.
        logger.setLevel(logging.DEBUG)
        logger.warning("%s=%r is not a level name; using DEBUG", DEBUG_ENV, raw)
    return logger.level
