"""Application bootstrap: construct the QApplication and show the main window."""

from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtGui import QIcon, QPixmap
from PySide6.QtWidgets import QApplication

from shiny_mushroom import APP_ID, APP_NAME, __version__, configure_logging, resources
from shiny_mushroom.ui.main_window import MainWindow
from shiny_mushroom.ui.settings import load_enum_setting
from shiny_mushroom.ui.theme import THEME_KEY, Theme, apply_theme

# Only the application name is set on the QApplication, never an organization:
# QStandardPaths appends both, so an organization equal to the app would nest
# the data directory as shiny-mushroom/shiny-mushroom. This is a single app with no
# separate organization - which is also why the preference store names its own
# identity rather than inheriting this one (shiny_mushroom.ui.settings.settings).


def cart_argument(arguments: list[str]) -> Path | None:
    """The image named on the command line, or ``None``.

    Qt strips its own arguments (``-style``, ``-platform``, ...) in the
    ``QApplication`` constructor, so what reaches here is genuinely ours --
    and anything still starting with a dash is an option nobody claimed
    rather than a path.
    """
    return next((Path(one) for one in arguments if not one.startswith("-")), None)


def main(argv: list[str] | None = None) -> int:
    """Entry point for both ``shiny_mushroom`` and ``python -m shiny_mushroom``."""
    # Before anything that might log, so the first load is not the one missed.
    configure_logging()
    app = QApplication(argv if argv is not None else sys.argv)
    app.setApplicationName(APP_ID)
    app.setApplicationDisplayName(APP_NAME)
    app.setApplicationVersion(__version__)

    # Style and palette both come from the theme, and both before the window is
    # built: a widget that bakes a palette color into a pixmap should rasterize
    # it once, in the color it will actually be shown in. View > Theme switches
    # it live afterwards.
    apply_theme(load_enum_setting(THEME_KEY, Theme.LIGHT))

    # The window, taskbar and dock icon while running. Loaded from bytes rather
    # than a file path so it resolves identically in a source checkout and in a
    # frozen build, where resources live inside the bundle. The packaged
    # executables also embed platform icons at build time (see packaging/ and
    # the release workflow); this covers the live window everywhere, and Linux,
    # which has no build-time icon at all.
    icon = QPixmap()
    icon.loadFromData(resources.read_bytes("icons", "app.png"))
    app.setWindowIcon(QIcon(icon))

    window = MainWindow()

    # **Before the window is shown**, which is what makes "the app cannot be
    # used until this is done" literal rather than a matter of greyed-out menus.
    # It is a no-op once there is a cartridge and a project, which after the
    # first launch is every launch; when the answer is to stop, there is nothing
    # to show and the process ends without ever having drawn a window.
    if not window.require_setup():
        return 0
    window.show()

    # **Nothing is loaded here in the ordinary case.** Setup has already opened
    # the project's cartridge -- the one it builds from the disassembly, the
    # extracted assets and its own overlay -- which is the ROM the editor
    # edits, and the only image whose features it can read: a cartridge opened
    # over it is read through the stock declarations, so every capability the
    # project builds in reads as absent (`MainWindow._use_base`). A path named
    # on the command line still wins, because asking for an image by name is
    # asking for it.
    cart = cart_argument(app.arguments()[1:])
    if cart is not None:
        window.load_file(cart)

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
