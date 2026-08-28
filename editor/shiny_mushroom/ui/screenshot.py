"""Drive the real editor offscreen and screenshot it, one step at a time.

The generic form of the throwaway screenshot scripts: boot the real MainWindow
over a cartridge or a project, walk it through an ordered list of steps --
enter the world map, pick a submap, zoom, click a cell, open a dialog through
its menu action -- and grab the window, the canvas or any widget to a PNG,
cropped and magnified as asked. Steps run in the order given, so one boot can
take many shots:

    uv run sm-shot world zoom=3 center=6,39 shot=marker.png
    uv run sm-shot --no-load theme=dark target=widget:view_bar shot=bar.png
    uv run sm-shot world submap=4 shot=vob.png action=world_layer1:off shot=l2.png

``sm-shot --help`` lists every step; ``sm-shot --list-actions`` the menu
actions ``action=`` can reach. Cell coordinates address the 16-pixel map grid
and hit the cell's centre, matching how the map's own gestures are aimed.
"""

from __future__ import annotations

import argparse
import os
import time
import types
from pathlib import Path

from smw_tools.paths import REFERENCE_DIR, WORK_ROOT

DEFAULT_ROM = REFERENCE_DIR / "Super Mario World (USA).sfc"
DEFAULT_OUT = WORK_ROOT.parent / "tmp"

CELL = 16  # the map grid the cell-addressed steps speak in, in image pixels

STEPS = {
    "theme=light|dark": "apply a theme; later steps and shots wear it",
    "level=NNN": "switch to level $NNN (hex) and wait for it to load",
    "world": "enter world-map mode and wait for the capture",
    "levelmode": "leave world-map mode and wait for the level",
    "submap=N": "world mode: show submap N under its own palette",
    "zoom=Z": "set the canvas zoom",
    "center=CX,CY": "scroll the view to centre on a map cell",
    "click=CX,CY[,MOD]": "left-click a cell's centre (MOD: shift|ctrl|alt)",
    "middleclick=CX,CY[,MOD]": "middle-click a cell's centre",
    "rightclick": "right-click off the picture: put down what is in hand,"
    " or open the context menu",
    "tab=N": "raise tab N of the tile palette dock",
    "dock=NAME[:off]": "show and raise (or hide) tile-palette|properties|palette",
    "action=NAME[:trigger|on|off]": "drive a menu action; see --list-actions",
    "call=DOTTED.PATH": "call a no-argument method reached from the window",
    "wait=SECONDS": "pump the event loop for a while",
    "target=WHAT": "what shots grab: window|canvas|properties|tile-palette"
    "|palette|widget:DOTTED.PATH (default window)",
    "crop=X,Y,W,H": "crop shots to a pixel rectangle; bare `crop=` clears it",
    "cropcell=CX,CY[,R]": "crop shots to R pixels (default 150) around a cell,"
    " at the current zoom",
    "scale=N": "magnify shots N times, nearest-neighbour; `scale=1` clears",
    "shot=NAME": "grab the current target to NAME.png in --out",
}


def parse_step(text: str) -> tuple[str, str | None]:
    """``name=value`` or a bare ``name``, checked against the step table."""
    name, eq, value = text.partition("=")
    known = {spec.partition("=")[0]: "=" in spec for spec in STEPS}
    if name not in known:
        raise SystemExit(f"unknown step {name!r}; steps: {', '.join(sorted(known))}")
    if known[name] != bool(eq):
        raise SystemExit(f"step {name!r} {'needs' if known[name] else 'takes no'} =")
    return name, value if eq else None


def ints(value: str, counts: tuple[int, ...]) -> list[int]:
    parts = [int(part) for part in value.split(",")]
    if len(parts) not in counts:
        raise SystemExit(f"expected {' or '.join(map(str, counts))} integers: {value}")
    return parts


class Driver:
    """One booted window, and the mutable shot state the steps talk to."""

    def __init__(self, window, out: Path, timeout: float) -> None:  # noqa: ANN001
        from PySide6.QtCore import QTimer

        self.window = window
        self.out = out
        self.timeout = timeout
        self.target = "window"
        self.crop: tuple[int, int, int, int] | None = None
        self.scale = 1
        #: What the window's modal alert said, once it has raised one. The
        #: alert is a nested event loop nothing here would ever return from
        #: -- a level that fails to load would hold the run open for good --
        #: so a timer, which fires inside that loop, takes the text and closes
        #: the box, and the next wait fails with the message instead.
        self.alert: str | None = None
        self._watch = QTimer()
        self._watch.setInterval(200)
        self._watch.timeout.connect(self._dismiss_alert)
        self._watch.start()

    # -- waiting ---------------------------------------------------------

    def _dismiss_alert(self) -> None:
        from PySide6.QtWidgets import QApplication, QMessageBox

        box = QApplication.activeModalWidget()
        if isinstance(box, QMessageBox):
            self.alert = " ".join(
                part for part in (box.text(), box.informativeText()) if part
            )
            box.reject()

    def _check_alert(self, what: str) -> None:
        if self.alert is not None:
            raise SystemExit(f"the editor raised an alert while {what}: {self.alert}")

    def pump(self, seconds: float) -> None:
        from PySide6.QtWidgets import QApplication

        end = time.monotonic() + seconds
        while time.monotonic() < end:
            QApplication.processEvents()
            time.sleep(0.02)
        self._check_alert("pumping")

    def pump_until(self, condition, what: str) -> None:  # noqa: ANN001
        from PySide6.QtWidgets import QApplication

        start = time.monotonic()
        while time.monotonic() - start < self.timeout:
            QApplication.processEvents()
            self._check_alert(f"waiting for {what}")
            if condition():
                print(f"ok: {what} ({time.monotonic() - start:.1f}s)", flush=True)
                return
            time.sleep(0.02)
        raise SystemExit(f"timed out after {self.timeout:.0f}s waiting for {what}")

    def level_settled(self) -> bool:
        w = self.window
        return w._snapshot is not None and not w._loading and not w._replacing

    # -- resolution ------------------------------------------------------

    def resolve(self, path: str):  # noqa: ANN202 - any attribute of the window
        """A dotted attribute path from the window, calling bound methods."""
        obj = self.window
        for part in path.split("."):
            obj = getattr(obj, part)
            if isinstance(obj, types.MethodType):
                obj = obj()
        return obj

    def target_widget(self):  # noqa: ANN202 - any grabbable widget
        w = self.window
        named = {
            "window": lambda: w,
            "canvas": lambda: w.canvas,
            "properties": lambda: w.properties,
            "tile-palette": lambda: w.tile_palette.widget(),
            "palette": lambda: w.palette_dock,
        }
        if self.target in named:
            return named[self.target]()
        return self.resolve(self.target.removeprefix("widget:"))

    # -- the steps -------------------------------------------------------

    def run(self, name: str, value: str | None) -> None:
        from PySide6.QtCore import QPoint, Qt

        w = self.window
        if name == "theme":
            from shiny_mushroom.ui.theme import Theme, apply_theme

            apply_theme(Theme(value))
        elif name == "level":
            number = int(value, 16)
            w._level_picked(number)
            self.pump_until(
                lambda: w._level == number and self.level_settled(),
                f"level ${number:03X}",
            )
        elif name == "world":
            if not w.menu_actions.world_map.isChecked():
                w.menu_actions.world_map.trigger()
            self.pump_until(lambda: w._world.ready, "the world map capture")
        elif name == "levelmode":
            if w.menu_actions.world_map.isChecked():
                w.menu_actions.world_map.trigger()
            self.pump_until(self.level_settled, "the level")
        elif name == "submap":
            w._go_to_submap(int(value))
            self.pump(0.2)
        elif name == "zoom":
            w.view.set_zoom(float(value))
        elif name == "center":
            cx, cy = ints(value, (2,))
            w.view.center_on(QPoint(cx * CELL + CELL // 2, cy * CELL + CELL // 2))
        elif name in ("click", "middleclick"):
            parts = value.split(",")
            cx, cy = int(parts[0]), int(parts[1])
            modifier = {
                None: Qt.KeyboardModifier.NoModifier,
                "shift": Qt.KeyboardModifier.ShiftModifier,
                "ctrl": Qt.KeyboardModifier.ControlModifier,
                "alt": Qt.KeyboardModifier.AltModifier,
            }[parts[2] if len(parts) > 2 else None]
            point = QPoint(cx * CELL + CELL // 2, cy * CELL + CELL // 2)
            signal = w.canvas.clicked if name == "click" else w.canvas.middle_clicked
            signal.emit(point, modifier)
        elif name == "rightclick":
            # The image pixel the press landed on and the widget position it
            # was at: `None` is the surround, which is where a bare step aims.
            w.canvas.right_clicked.emit(None, QPoint(0, 0))
        elif name == "tab":
            w.tile_palette._tabs.setCurrentIndex(int(value))
        elif name == "dock":
            dock_name, _, state = value.partition(":")
            dock = {
                "tile-palette": w.tile_palette,
                "properties": w.properties,
                "palette": w.palette_dock,
            }[dock_name]
            dock.setVisible(state != "off")
            if state != "off":
                dock.raise_()
        elif name == "action":
            action_name, _, how = value.partition(":")
            action = getattr(w.menu_actions, action_name)
            if how in ("on", "off"):
                action.setChecked(how == "on")
            else:
                action.trigger()
        elif name == "call":
            self.resolve(value)
        elif name == "wait":
            self.pump(float(value))
        elif name == "target":
            self.target = value
            self.target_widget()  # fail now, not at the shot
        elif name == "crop":
            self.crop = tuple(ints(value, (4,))) if value else None
        elif name == "cropcell":
            parts = ints(value, (2, 3))
            radius = parts[2] if len(parts) > 2 else 150
            zoom = w.canvas.zoom
            centre_x = round((parts[0] * CELL + CELL // 2) * zoom)
            centre_y = round((parts[1] * CELL + CELL // 2) * zoom)
            self.crop = (centre_x - radius, centre_y - radius, 2 * radius, 2 * radius)
        elif name == "scale":
            self.scale = int(value)
        elif name == "shot":
            self.shot(value)

    def shot(self, stem: str) -> None:
        from PySide6.QtCore import QRect, Qt
        from PySide6.QtWidgets import QApplication

        for _ in range(10):
            QApplication.processEvents()
        image = self.target_widget().grab().toImage()
        if self.crop:
            image = image.copy(QRect(*self.crop))
        if self.scale != 1:
            image = image.scaled(
                image.width() * self.scale,
                image.height() * self.scale,
                Qt.AspectRatioMode.IgnoreAspectRatio,
                Qt.TransformationMode.FastTransformation,
            )
        self.out.mkdir(parents=True, exist_ok=True)
        path = self.out / (stem if stem.endswith(".png") else stem + ".png")
        image.save(str(path))
        print(f"saved {path} ({image.width()}x{image.height()})", flush=True)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="sm-shot",
        description=__doc__.partition("\n\n")[0],
        epilog="steps, run in the order given:\n"
        + "\n".join(f"  {spec:28} {what}" for spec, what in STEPS.items()),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    source = parser.add_mutually_exclusive_group()
    source.add_argument(
        "--rom",
        type=Path,
        default=DEFAULT_ROM,
        help=f"cartridge to open (default {DEFAULT_ROM.name})",
    )
    source.add_argument("--project", type=Path, help="open a project instead")
    source.add_argument(
        "--no-load",
        action="store_true",
        help="boot the bare window: chrome shots need no cartridge",
    )
    parser.add_argument(
        "--no-build",
        action="store_true",
        help="with --project: skip the build, and do not wait for a level",
    )
    parser.add_argument("--size", default="1280x800", help="window size WxH")
    parser.add_argument(
        "--out", type=Path, default=DEFAULT_OUT, help="directory shots land in"
    )
    parser.add_argument("--platform", help="Qt platform plugin (default offscreen)")
    parser.add_argument(
        "--timeout",
        type=float,
        default=300.0,
        help="seconds each wait may take (default 300)",
    )
    parser.add_argument(
        "--list-actions",
        action="store_true",
        help="print the menu action names `action=` accepts, and exit",
    )
    parser.add_argument("steps", nargs="*", help="see the step list below")
    args = parser.parse_args(argv)
    steps = [parse_step(step) for step in args.steps]
    if not steps and not args.list_actions:
        parser.error("no steps given; nothing would be shot")

    if args.platform:
        os.environ["QT_QPA_PLATFORM"] = args.platform
    else:
        os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

    from PySide6.QtGui import QAction
    from PySide6.QtWidgets import QApplication

    from shiny_mushroom.ui.main_window import MainWindow

    app = QApplication([])
    window = MainWindow()
    width, _, height = args.size.partition("x")
    window.resize(int(width), int(height))
    window.show()

    if args.list_actions:
        import dataclasses

        for field in sorted(f.name for f in dataclasses.fields(window.menu_actions)):
            action = getattr(window.menu_actions, field)
            if isinstance(action, QAction):
                print(f"{field:28} {action.text().replace('&', '')}")
        window.close()
        return 0

    driver = Driver(window, args.out, args.timeout)
    try:
        if args.project:
            from shiny_mushroom.project import Project

            window.use_project(Project.open(args.project), build=not args.no_build)
            if not args.no_build:
                driver.pump_until(driver.level_settled, "the project's level")
        elif not args.no_load:
            if not args.rom.is_file():
                raise SystemExit(f"no cartridge at {args.rom}")
            window.load_file(args.rom)
            driver.pump_until(driver.level_settled, "the first level")
        for name, value in steps:
            driver.run(name, value)
    finally:
        # The window owns emulator worker processes; closing it is what
        # releases them, so it must happen on every exit path.
        window.close()
        driver.pump(0.5)
        app.quit()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
