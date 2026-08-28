"""Build a release and boot it in Mesen.

Under WSL the emulator is a Windows binary reached through interop, so the ROM
path has to be handed over in Windows form -- see ``to_host_path``.

``--seconds N`` boots, waits, and then closes the emulator again. Use it for any
automated or agent-driven smoke test: a detached GUI left running is invisible
to whoever started it and has to be closed by hand.
"""

from __future__ import annotations

import os
import subprocess
import time

from .bases import RomBase
from .bases import base as default_base
from .build import build_rom, output_path
from .paths import find_mesen, is_wsl, to_host_path


def close_emulator(exe_name: str = "Mesen.exe") -> None:
    """Terminate a running emulator, on either side of the WSL boundary."""
    if is_wsl() or os.name == "nt":
        subprocess.run(
            ["taskkill.exe", "/IM", exe_name, "/F"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    else:
        subprocess.run(
            ["pkill", "-f", exe_name.removesuffix(".exe")],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )


def run_in_emulator(
    version: str,
    no_build: bool = False,
    seconds: float | None = None,
    emulator_args: list[str] | None = None,
    base: RomBase | None = None,
) -> int:
    rom_base = base or default_base()
    info = rom_base.target(version)

    if no_build:
        rom_path = output_path(rom_base, info)
        if not rom_path.exists():
            raise FileNotFoundError(
                f"no existing build at {rom_path} -- drop --no-build, or run "
                f"`smw build` first"
            )
    else:
        print(f"> build    {info.label}")
        rom_path = build_rom(version, base=rom_base).output_path

    mesen = find_mesen()
    if mesen is None:
        print(
            "Mesen not found. Set MESEN_PATH to the executable, or place it at "
            "../Mesen/ next to this repository."
        )
        return 1

    args = [to_host_path(rom_path), *(emulator_args or [])]
    print(f"> launch   {mesen}")
    print(f"           {args[0]}")

    subprocess.Popen(
        [str(mesen), *args],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
        start_new_session=True,
    )

    if seconds is not None:
        print(f"> running for {seconds:g}s, then closing")
        time.sleep(seconds)
        close_emulator()
        print("> emulator closed")
    else:
        print("> emulator launched (close it yourself, or use --seconds N next time)")

    return 0
