"""Enable ``python -m shiny_mushroom``, and the frozen build's second role.

A frozen application has no separate interpreter to start a helper process with,
so the executable re-invokes *itself* to run the emulator worker. That check has
to happen before :mod:`shiny_mushroom.app` is imported: the worker has no use for Qt,
and constructing a QApplication in a process that will never show a window is
both wasteful and, under a ``--windowed`` build with no console, a good way to
turn a crash into silence.
"""

import sys


def main() -> int:
    from shiny_mushroom.worker_protocol import WORKER_FLAG

    if WORKER_FLAG in sys.argv[1:]:
        from shiny_mushroom.emu.worker import main as worker_main

        return worker_main()

    from shiny_mushroom.app import main as app_main

    return app_main()


if __name__ == "__main__":
    raise SystemExit(main())
