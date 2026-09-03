"""A ctypes binding to Mesen's emulation core, and where to find it.

**Nothing in the editor's own process may import this module.** It loads native
code that can segfault, and a segfault inside a shared library takes the whole
interpreter with it -- including the Qt event loop and any unsaved work. The
binding is used only from :mod:`shiny_mushroom.emu.worker`, which runs in a child
process precisely so that a crash is survivable;
:class:`shiny_mushroom.emu.supervisor.EmulatorSupervisor` is the parent-side handle.

Most of what is bound takes and returns **primitives**: memory, savestates,
emulation flags, and the debugger's ``Step``, which is three ints.
``GetCpuState`` / ``SetCpuState`` pass a C++ structure and are bound too, which
is only defensible because the core is pinned to one commit and
:class:`CpuState` mirrors *that revision's* header. ``SetBreakpoints`` is not
bound; nothing needs it.

Three ways to advance the machine, and they are not interchangeable:

- **Polling** a byte of work RAM while it runs free. Good enough for "has the
  game mode changed yet", which is why the level load in
  :mod:`shiny_mushroom.emu.smw` still works that way.
- :meth:`MesenCore.step_frame` -- exactly one frame, stopping at the same point
  every time. Needed for anything the game rebuilds per frame, because polling
  lands wherever the poll happened to fall.
- :meth:`MesenCore.call` -- run one cartridge routine and come back, with no
  frame boundary involved at all.

Passing NULL for both window handles is what makes the core headless. With no
window, ``InitializeEmu`` constructs no renderer, no sound manager and no key
manager at all, so SDL is linked but never used and there is no display,
audio device or input device to be unavailable in CI. That is the default and
it is what the level loader uses.

**A core can also be asked for pictures and sound**, which is what
:mod:`shiny_mushroom.emu.play` needs and what ``video=`` and ``audio=`` are for.
Both require a non-NULL handle, because ``InitializeEmu`` builds nothing at all
when either handle is NULL. The software renderer ignores what it is given and
the mouse manager that would use it is never built (``noInput``), so on Linux
and macOS -- where the sound manager is SDL's and ignores it too -- a number
that is merely non-NULL is enough.

**Windows needs a window that really exists, or the sound is silent.**
``SoundManager`` hands the handle to ``IDirectSound8::SetCooperativeLevel``,
which accepts an invalid one without failing: the buffers are created, written
and played, no ``[Audio]`` line is logged, and nothing comes out of the
speakers. So the core makes its own -- :func:`_own_window`, a message-only
window belonging to this process, alive for exactly as long as the core is.

**Sound needs a config pushed, or it is a crash rather than silence.** Mesen's
own front end always sets one; this package sets exactly the one field that has
to be non-default. :class:`AudioConfig` is why.
"""

from __future__ import annotations

import ctypes
import os
import platform
import shutil
import sys
import tempfile
import threading
import time
from array import array
from collections.abc import Callable, Iterator, Sequence
from contextlib import contextmanager
from enum import IntEnum
from pathlib import Path

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memtype import MemoryType, verify

#: Library filename per OS. The core is one file; everything else is layout.
_LIBRARY_FILENAMES = {
    "win32": "MesenCore.dll",
    "darwin": "MesenCore.dylib",
    "linux": "MesenCore.so",
}

#: Directory name per OS and CPU, matching Mesen's own ``$(MESENOS)-$(arch)``
#: convention. macOS genuinely needs both -- the editor ships a separate app per
#: architecture -- and naming the others the same way means a Linux arm64 core
#: can be dropped in later without moving anything.
_PLATFORM_DIRS = {
    ("win32", "x64"): "windows-x64",
    ("darwin", "x64"): "macos-x64",
    ("darwin", "arm64"): "macos-arm64",
    ("linux", "x64"): "linux-x64",
    ("linux", "arm64"): "linux-arm64",
}

#: Uncommitted cores for local development, at the repository root. Checked
#: before the bundled ones so that a freshly built core is what a source
#: checkout runs, while releases use whatever CI vendored -- without either
#: having to know about the other.
DEV_DIR_NAME = "mesen-cores"

#: Escape hatch for developing against a core built somewhere else. Also how the
#: build script points the test suite at a freshly compiled library before it is
#: vendored.
LIBRARY_ENV_VAR = "SHINY_MUSHROOM_MESEN_CORE"

#: ``EmulationFlags`` from Mesen's ``Core/Shared/SettingTypes.h``. Only the two
#: that matter here.
#:
#: ``MAXIMUM_SPEED`` is not an optimisation, it is the difference between
#: emulating in real time and emulating as fast as the host can. Without it a
#: level load takes the ~60 frames it would take on a console -- about a second
#: -- because the core dutifully sleeps between frames for a display nobody is
#: watching. With it, the same load is five to ten times quicker.
#:
#: ``CONSOLE_MODE`` tells the core there is no UI attached, which is what
#: Mesen's own headless test runner sets.
FLAG_MAXIMUM_SPEED = 0x04
FLAG_CONSOLE_MODE = 0x10

#: ``ConsoleNotificationType::RefreshSoftwareRenderer``, the 23rd entry of the
#: enum in ``Core/Shared/Interfaces/INotificationListener.h`` at the pinned
#: revision. An ordinal, like ``MemoryType`` -- and dereferencing the wrong
#: notification's parameter as a frame is a segfault rather than a wrong colour,
#: so :meth:`MesenCore.capture_video` refuses to hand on a frame whose dimensions
#: are not plausible and says so if none ever arrives.
NOTIFY_REFRESH_SOFTWARE_RENDERER = 22

#: ``ConsoleNotificationType::CodeBreak`` and ``DebuggerResumed``, the sixth and
#: seventh entries of the same enum :data:`NOTIFY_REFRESH_SOFTWARE_RENDERER`
#: counts along. A break is how the editor learns a cartridge hit a ``BRK``:
#: with the debugger on, Mesen stops the machine *before* the instruction
#: executes and sends this, which is what makes the registers in
#: :class:`shiny_mushroom.brk.BrkReport` the ones the ``BRK`` was reached with.
NOTIFY_CODE_BREAK = 5
NOTIFY_DEBUGGER_RESUMED = 6

#: ``BreakSource``, from ``Core/Debugger/DebugTypes.h``, and only the one entry
#: that matters here. Every other source is something the editor itself asked
#: for -- a pause, a frame step, the debugger starting -- and is ignored, which
#: is why the source is checked rather than the notification alone.
BREAK_SOURCE_BRK = 7

#: ``DebuggerFlags``. Per processor, and both are set: on a cartridge with an
#: SA-1 the game's own code -- a custom sprite's included -- runs on the
#: coprocessor, and ``SnesDebugger`` checks the flag for whichever CPU it is
#: serving. A cartridge without one is unharmed by the second flag.
DEBUGGER_FLAG_SNES = 1 << 0
DEBUGGER_FLAG_SA1 = 1 << 2

#: How long a ``BRK`` is: the opcode and the exception number after it. What
#: :meth:`MesenCore.let_break_go` moves the program counter by to step over one.
BRK_LENGTH = 2

#: How many times :meth:`MesenCore.let_break_go` will let a machine go before
#: leaving it. Each pass is a resume and a halt of a cartridge that has already
#: raised an exception; one is what a healthy recovery costs, and the bound is
#: here so that a cartridge breaking on every instruction cannot hold a worker
#: in the loop.
BREAK_RELEASES = 8

#: A picture no SNES ever produced. Mesen's own SNES frames are 256 or 512 wide;
#: this is a bound on what will be believed, not a format.
MAX_FRAME_DIMENSION = 4096

#: Stands in for a window handle where nothing ever dereferences one: every
#: platform but Windows, and Windows itself if it could not make the window
#: :func:`_own_window` builds. ``InitializeEmu`` treats a NULL handle as "build
#: nothing", so something has to be passed -- see the module docstring.
PLACEHOLDER_WINDOW_HANDLE = 1

#: ``CreateWindowEx``'s parent for a message-only window: no broadcast reaches
#: one and it is not enumerated with the top-level windows, which is what keeps
#: a window nobody pumps messages for from holding up the rest of the desktop.
HWND_MESSAGE = -3

#: ``void(int type, void* parameter)``. ``__stdcall`` in the header and ignored
#: on x86-64, where Windows and SysV agree.
NOTIFICATION_CALLBACK = ctypes.CFUNCTYPE(None, ctypes.c_int, ctypes.c_void_p)

#: Where :meth:`MesenCore.call` writes its stub. Bank ``$7E`` is work RAM, and
#: work RAM executes -- SMW itself runs a routine out of ``$7F8000``. This
#: particular address is inside the graphics decompression buffer, which is
#: scratch between loads, and every caller restores a savestate afterwards
#: regardless.
#:
#: **Work RAM even on a base that moved the game out of it.** A cartridge with a
#: coprocessor relocates the *game's* memory, not the console's: ``$7E:2000``
#: upward is untouched under SA-1 Pack, which runs its own interrupt handlers
#: and its SA-1 call gate from work RAM for a related reason -- code there
#: leaves the ROM bus free. Measured working: the sprite capture on ``sa1``
#: drives every one of its calls through this stub.
CALL_STUB = 0x7E2000

#: Where the stub raises its flag, and with what. A byte in the same scratch
#: buffer, clear of both stubs written into it, and a value the buffer is
#: unlikely to be holding by accident.
#:
#: **"The routine finished" is a byte, not a program counter**, and that is not
#: a stylistic choice. The stub used to end in a branch to itself and the poll
#: watched for the counter to reach it -- but a 65816 walks the program counter
#: through an instruction's operand bytes as it fetches them, so during the
#: ``JSL`` itself it passes through the branch's own address. Measured with a
#: tight poll: **5 calls in 36 were declared finished six to eight cycles in**,
#: mid-jump, before the routine had run at all. The old 0.2 ms sleep hid it by
#: never sampling that early, which made the bug a property of the poll rate.
#: A flag the stub only reaches *after* the ``RTL`` cannot say "finished" early.
CALL_DONE = CALL_STUB + 0x20
CALL_DONE_MARK = 0x5A

#: The processor status a cartridge routine is entered with: ``M`` and ``X``
#: set, so the accumulator and the index registers are both 8-bit. That is what
#: the game's own callers are in, and on the 65816 the widths are not a detail
#: -- the same instruction reads one byte or two depending on them.
CALL_ENTRY_PS = 0x30

#: Where a SNES boots its stack, and where a routine called from nothing should
#: find it. Anything deeper is somebody else's frame.
CALL_ENTRY_SP = 0x01FF

#: ``SnesCpuStopState::Running``. ``stop_state`` is the CPU's own halt, not the
#: debugger's pause: a machine stopped mid-``WAI`` keeps the value ``2`` and
#: stays waiting through a resume, program counter and all -- and SA-1 Pack's
#: main loop idles in a ``WAI``, so on ``sa1`` most pauses land there. An entry
#: that inherits it points the program counter at the stub and then executes
#: nothing, because the interrupt that would end the wait is exactly what the
#: probe silenced. Measured on ``sa1/U`` level ``$001``: every sprite capture
#: entered at ``stop_state=2`` and hung unless a stray pending interrupt
#: happened to wake it, which is why the failure came and went with host
#: timing. Vanilla idles in a branch spin and never trips this.
CALL_ENTRY_STOP_STATE = 0

#: ``CpuType::Snes``, the first entry. Every debugger export takes one, because
#: a SNES cartridge can carry a second processor the debugger treats separately.
CPU_TYPE_SNES = 0

#: ``CpuType::Sa1``, the fourth entry of the enum in
#: ``Core/Shared/SettingTypes.h`` -- and the one that makes a cartridge with a
#: coprocessor observable at all. **Measured, not assumed**: tracing two frames
#: of sprite processing on ``sa1/U`` with the main CPU alone yields 2 rows, and
#: with this added, 3092. The main CPU's entire contribution is the ``JML`` at
#: ``$01808C`` that hands the work over.
#:
#: An ordinal, so a shifted enum would silently trace the wrong processor -- but
#: unlike :class:`MemoryType` there is no size to check it against. What stands
#: in for one is that guess being wrong is loud here: it would log nothing.
CPU_TYPE_SA1 = 3

#: Where :meth:`MesenCore.silence_interrupts` writes its own stub. Sixteen bytes
#: past the call stub, in the same scratch buffer and for the same reasons.
INTERRUPT_STUB = CALL_STUB + 0x10

#: ``$4200``: NMI enable in bit 7, IRQ in bits 4-5, automatic joypad read in bit
#: 0. Zero turns off all three.
INTERRUPT_ENABLE = 0x4200

#: Console cycles a called routine may run for before it is called hung. The
#: unit is the emulator's own clock -- about 47,000 of them to a frame, measured
#: by stepping one -- which is the point: **what bounds a routine is how long
#: the machine ran, not how long the host took to notice.** A wall-clock budget
#: charges a busy host to the cartridge and reports a sprite as undrawable
#: because the poll loop was descheduled.
#:
#: Ten frames is roughly a hundred times the longest legitimate call measured
#: (see :meth:`MesenCore.call`), and a routine that really does not return burns
#: it in a few milliseconds of host time rather than in the half second the old
#: deadline waited out.
CALL_BUDGET = 10 * 47_000

#: How long the core may fail to execute *at all* before it is called dead.
#: Separate from the budget above, and the reason the pair always terminates:
#: a core that is running is bounded by cycles, and one that is not is bounded
#: by this. Generous because a resume takes up to 10 ms to become execution.
CALL_STALL = 2.0

#: Between polls. Two things set this floor and neither is the emulator: a
#: ``time.sleep`` of less than about 0.1 ms does not happen -- measured, a
#: requested 0.02 ms comes back as 0.12 -- and a call's wall clock is dominated
#: by the up-to-10 ms it takes a resume to become execution, which no poll rate
#: touches. Busy-waiting instead costs 13% of the emulator's throughput and buys
#: less than a tenth of a millisecond per call.
CALL_POLL = 0.0001

#: How long :meth:`MesenCore.start` waits for a resume to become execution
#: before asking again. Comfortably past a healthy one -- measured over 1500
#: resumes, median 0.54 ms and 9.2 ms at the worst -- because re-asking costs
#: nothing but a swallowed resume costs the whole call.
RESUME_CONFIRM = 0.025

#: How often the poll stops to ask the machine's clock how far it has come.
#: The flag is one byte and cheap; a CPU state is 32 and is only needed to
#: decide whether to give up, which is a question worth asking every few
#: milliseconds rather than every hundred microseconds.
CALL_PROGRESS_CHECK = 0.005


def call_stub(address: int) -> bytes:
    """``JSL address``, then raise :data:`CALL_DONE`, then spin.

    Twelve bytes of 65816: ``22`` takes a 24-bit little-endian operand, ``8F``
    is a **long** store -- which is what puts the flag in bank ``$7E`` rather
    than wherever the data bank points -- and ``80 FE`` is a relative branch of
    -2, the instruction's own address. Encoding it wrong is silent, since the
    CPU would run whatever the bytes happen to mean, so this is separated out to
    be checked.

    The spin still matters even though nothing watches for it: without it the
    machine would run on into whatever follows the stub in the scratch buffer.
    """
    return bytes(
        (
            0x22,  # JSL long
            address & 0xFF,
            (address >> 8) & 0xFF,
            (address >> 16) & 0xFF,
            0xA9,  # LDA immediate
            CALL_DONE_MARK,
            0x8F,  # STA long
            CALL_DONE & 0xFF,
            (CALL_DONE >> 8) & 0xFF,
            (CALL_DONE >> 16) & 0xFF,
            0x80,  # BRA
            0xFE,  # -2: to itself
        )
    )


def interrupt_stub(value: int) -> bytes:
    """``LDA #value : STA $4200 : RTL``, for :meth:`MesenCore.silence_interrupts`.

    Entered with an 8-bit accumulator and ``DBR = $00``, which is what
    :meth:`MesenCore.call` pins, so the absolute store lands on the register
    rather than on bank ``$7E``.
    """
    return bytes(
        (
            0xA9,  # LDA immediate
            value & 0xFF,
            0x8D,  # STA absolute
            INTERRUPT_ENABLE & 0xFF,
            INTERRUPT_ENABLE >> 8,
            0x6B,  # RTL
        )
    )


class TraceLoggerOptions(ctypes.Structure):
    """Mesen's ``TraceLoggerOptions``, mirrored field for field.

    Transcribed from ``Core/Debugger/ITraceLogger.h`` in **the pinned revision**,
    on the same grounds as :class:`CpuState`: a header only describes a binary
    if it is that binary's own source, and ``packaging/mesen-pin.json`` is what
    makes that true here.

    Three plain flags and two fixed 1000-byte strings, so there is no alignment
    subtlety to get wrong -- unlike `CpuState`, this one is hard to mirror
    incorrectly. What matters is what the two strings do:

    - **``condition``** is an expression evaluated per logged instruction, and a
      row is written only when it holds. It sees the *instruction fetch*, so it
      can test ``opPc`` but not the target of a store -- filtering by which code
      is running is possible, filtering by what it writes is not.
    - **``format``** chooses the columns. The program counter is always written
      first, before the format's own output.
    """

    _fields_ = (
        ("enabled", ctypes.c_bool),
        ("indent_code", ctypes.c_bool),
        ("use_labels", ctypes.c_bool),
        ("condition", ctypes.c_char * 1000),
        ("format", ctypes.c_char * 1000),
    )


class AddressCounters(ctypes.Structure):
    """Mesen's ``AddressCounters``, from ``Core/Debugger/MemoryAccessCounter.h``.

    One of these per address of a memory, kept by ``SnesDebugger::ProcessRead``
    and ``ProcessWrite`` unconditionally whenever the debugger exists -- which
    it always does here. **The observation is already being paid for**, which is
    what makes reading it out a thousand times cheaper than a trace of the same
    events.

    The three stamps are the master clock (``SnesMemoryManager::GetMasterClock``)
    at the last read, write and execute of that address. Being the same clock on
    both sides is the whole trick: a read stamp on a byte of the object stream
    and a write stamp on a byte of the tilemap can be ordered against each
    other, so "which record was being drawn when this block was written" is a
    comparison rather than an inference.

    Three 64-bit stamps then three 32-bit counters, so forty bytes with the tail
    padding. Mirrored on the same grounds as :class:`CpuState` -- one pinned
    commit -- and, like it, checked against a running core rather than trusted.
    """

    _fields_ = (
        ("read_stamp", ctypes.c_uint64),
        ("write_stamp", ctypes.c_uint64),
        ("exec_stamp", ctypes.c_uint64),
        ("read_counter", ctypes.c_uint32),
        ("write_counter", ctypes.c_uint32),
        ("exec_counter", ctypes.c_uint32),
    )


#: Size of one :class:`AddressCounters`, and its stride in 64-bit words.
COUNTER_SIZE = ctypes.sizeof(AddressCounters)
COUNTER_WORDS = COUNTER_SIZE // 8

#: Which 64-bit word of a counter each stamp is.
READ_STAMP, WRITE_STAMP, EXEC_STAMP = 0, 1, 2


class CpuState(ctypes.Structure):
    """Mesen's ``SnesCpuState``, mirrored field for field.

    Transcribed from ``Core/SNES/SnesCpuTypes.h`` in **the pinned revision** --
    and that qualifier is the whole basis for doing this. A header only
    describes a binary if it is the binary's own source, so this is only sound
    because ``packaging/mesen-pin.json`` names one commit, every vendored core
    is built from it, and ``provenance.json`` records which. Mirroring a struct
    from whatever version happens to be checked out is how a reader ends up
    confidently reading the wrong bytes.

    ``BaseState`` is an empty struct, so it contributes nothing and
    ``CycleCount`` sits at offset 0. Natural alignment reproduces the C++
    layout; no packing is needed, and forcing some would break it.

    The layout is also **independently confirmed by measurement**
    (``smw/tmp/cpustate_probe.py``): stepping one instruction moves the 16-bit
    field at ``+$12`` by an instruction's length, and ``$01FF`` sits at ``+$0E``
    where a SNES boots its stack. ``test_cpu_state_matches_the_measured_layout``
    holds the two against each other, so a future edit has to break both the
    header transcription and the measurement to pass.
    """

    _fields_ = (
        ("cycle_count", ctypes.c_uint64),
        ("a", ctypes.c_uint16),
        ("x", ctypes.c_uint16),
        ("y", ctypes.c_uint16),
        ("sp", ctypes.c_uint16),
        ("d", ctypes.c_uint16),
        ("pc", ctypes.c_uint16),
        ("k", ctypes.c_uint8),  # program bank
        ("dbr", ctypes.c_uint8),  # data bank
        ("ps", ctypes.c_uint8),  # processor status
        ("emulation_mode", ctypes.c_bool),
        # Mesen's "misc internal state". Modelled rather than skipped so that
        # writing a state back returns everything it came with.
        ("nmi_flag_counter", ctypes.c_uint8),
        ("irq_lock", ctypes.c_bool),
        ("need_nmi", ctypes.c_bool),
        ("irq_source", ctypes.c_uint8),
        ("prev_irq_source", ctypes.c_uint8),
        ("stop_state", ctypes.c_uint8),
    )

    @property
    def address(self) -> int:
        """The 24-bit program counter, bank included."""
        return (self.k << 16) | self.pc

    @address.setter
    def address(self, value: int) -> None:
        self.pc = value & 0xFFFF
        self.k = (value >> 16) & 0xFF

    def __repr__(self) -> str:
        return (
            f"CpuState(pc={hexnum(self.address, 6)} a={hexnum(self.a, 4)} "
            f"x={hexnum(self.x, 4)} "
            f"y={hexnum(self.y, 4)} sp={hexnum(self.sp, 4)} ps={hexnum(self.ps)})"
        )


class DebugConfig(ctypes.Structure):
    """Mesen's ``DebugConfig``, mirrored field for field.

    Transcribed from ``Core/Shared/SettingTypes.h`` in **the pinned revision**,
    on the same basis as :class:`CpuState` and :class:`SnesConfig`: the core is
    one commit, every vendored build is that commit, and a header only
    describes a binary when it is the binary's own source.

    Every field is a ``bool`` but one, and the whole struct is passed by value
    to ``SetDebugConfig`` -- so a field left out here would not shift one
    setting, it would shift every setting after it. Only
    :attr:`snes_break_on_brk` is ever set; the rest are transcribed to get that
    one to the right offset and to leave the others at the defaults a fresh
    struct already holds.
    """

    _fields_ = [
        (name, ctypes.c_bool)
        for name in (
            "break_on_uninit_read",
            "show_jump_labels",
            "draw_partial_frame",
            "show_verified_data",
            "disassemble_verified_data",
            "show_unidentified_data",
            "disassemble_unidentified_data",
            "use_lower_case_disassembly",
            "show_memory_values",
            "auto_reset_cdl",
            "use_predictive_breakpoints",
            "single_breakpoint_per_instruction",
            "snes_break_on_brk",
            "snes_break_on_cop",
            "snes_break_on_wdm",
            "snes_break_on_stp",
            "snes_break_on_invalid_ppu_access",
            "snes_break_on_read_during_auto_joy",
            "snes_use_alt_spc_op_names",
            "snes_ignore_dsp_read_writes",
            "spc_break_on_brk",
            "spc_break_on_stp_sleep",
            "gb_break_on_invalid_oam_access",
            "gb_break_on_invalid_vram_access",
            "gb_break_on_disable_lcd_outside_vblank",
            "gb_break_on_invalid_op_code",
            "gb_break_on_nop_load",
            "gb_break_on_oam_corruption",
            "nes_break_on_brk",
            "nes_break_on_unofficial_op_code",
            "nes_break_on_unstable_op_code",
            "nes_break_on_cpu_crash",
            "nes_break_on_bus_conflict",
            "nes_break_on_decayed_oam_read",
            "nes_break_on_ppu_scroll_glitch",
            "nes_break_on_ext_output_mode",
            "nes_break_on_invalid_vram_access",
            "nes_break_on_invalid_oam_write",
            "nes_break_on_dma_input_read",
            "pce_break_on_brk",
            "pce_break_on_unofficial_op_code",
            "pce_break_on_invalid_vram_address",
            "sms_break_on_nop_load",
            "gba_break_on_nop_load",
            "gba_break_on_invalid_op_code",
            "gba_break_on_unaligned_mem_access",
        )
    ] + [
        ("gba_disassembly_mode", ctypes.c_uint8),
        ("ws_break_on_invalid_op_code", ctypes.c_bool),
        ("script_allow_io_os_access", ctypes.c_bool),
        ("script_allow_network_access", ctypes.c_bool),
        ("script_timeout", ctypes.c_uint32),
    ]


class MemoryOperationInfo(ctypes.Structure):
    """Mesen's ``MemoryOperationInfo``, which a break event carries by value.

    Not read for anything: it is here so :class:`BreakEvent`'s later fields sit
    where the core put them.
    """

    _fields_ = (
        ("address", ctypes.c_uint32),
        ("value", ctypes.c_int32),
        ("type", ctypes.c_uint8),
        ("memory_type", ctypes.c_uint8),
    )


class BreakEvent(ctypes.Structure):
    """What ``CodeBreak`` points at: why the machine stopped, and which CPU."""

    _fields_ = (
        ("source", ctypes.c_int32),
        ("source_cpu", ctypes.c_int32),
        ("operation", MemoryOperationInfo),
        ("breakpoint_id", ctypes.c_int32),
    )


class SoftwareRendererSurface(ctypes.Structure):
    """One of the three layers ``RefreshSoftwareRenderer`` hands out.

    Transcribed from the anonymous structs at the foot of
    ``Core/Shared/Video/SoftwareRenderer.cpp`` **in the pinned revision**, on the
    same terms as :class:`CpuState`: a header describes a binary only when it is
    that binary's source, and the pin is what makes that checkable.

    ``Buffer`` is ``uint32_t*`` in ``0xAARRGGBB``, which on a little-endian host
    is byte-for-byte what Qt calls ``Format_RGB32`` -- so a frame reaches the
    screen without a per-pixel conversion anywhere.
    """

    _fields_ = (
        ("buffer", ctypes.POINTER(ctypes.c_uint32)),
        ("width", ctypes.c_uint32),
        ("height", ctypes.c_uint32),
        ("is_dirty", ctypes.c_bool),
    )


class SoftwareRendererFrame(ctypes.Structure):
    """The whole parameter: the emulated picture, then the two overlays.

    Only the first is read. The other two are Mesen's own on-screen display and
    the Lua script HUD, neither of which exists in a core driven this way.
    """

    _fields_ = (
        ("frame", SoftwareRendererSurface),
        ("emu_hud", SoftwareRendererSurface),
        ("script_hud", SoftwareRendererSurface),
    )


class KeyMappingSet(ctypes.Structure):
    """Four keyboard mappings and a turbo rate, as ``SnesConfig`` embeds them.

    Every mapping is 123 ``uint16_t`` -- 23 named buttons then
    ``CustomKeys[100]`` -- so it is declared as the flat array it is rather than
    as 123 fields. Nothing here is ever set: a play worker is built with
    ``noInput``, so there is no key manager to consult a mapping, and buttons
    arrive through the debugger override instead. It exists only because it sits
    between the start of the struct and the one field that has to be right.
    """

    _fields_ = (
        ("mappings", (ctypes.c_uint16 * 123) * 4),
        ("turbo_speed", ctypes.c_uint32),
    )


class ControllerConfig(ctypes.Structure):
    """One port: its key mappings, then what is plugged into it."""

    _fields_ = (
        ("keys", KeyMappingSet),
        ("type", ctypes.c_int32),  # ControllerType; 0 None, 1 SnesController
    )


class SnesConfig(ctypes.Structure):
    """Mesen's ``SnesConfig``, mirrored so that a pad can be plugged in.

    Bound reluctantly and for exactly one reason: ``ControllerType`` defaults to
    ``None`` on both ports, so a core that nobody has configured has no
    controller device at all -- and ``SetInputOverrides`` writes to a device.
    Without this the buttons go nowhere, silently, which is what the first
    working version of the play session did.

    Everything else in it is set to the value the pinned header's own member
    initialisers give, so applying this leaves the core's settings as they were.
    Three fields are the only ones that are not zero, and each matters:
    ``ChannelVolumes`` at 100 (zeroed, the game is silent), ``GsuClockSpeed``
    at 100 and ``BsxCustomDate`` at -1 (neither reached by SMW, both set anyway
    rather than left as a difference).

    **The layout is checked by what happens, not by reading it back.** After
    this is applied, ``HasControlDevice`` must report a SNES controller: the
    only way ``type`` lands where the core reads it is for every offset before
    it to be right, and there are 9,920 bytes of them. The frame size not
    changing says the same about ``Overscan``, which sits after it.
    """

    _fields_ = (
        ("port1", ControllerConfig),
        ("port2", ControllerConfig),
        ("port1_sub_ports", ControllerConfig * 4),
        ("port2_sub_ports", ControllerConfig * 4),
        ("region", ctypes.c_int32),
        ("allow_invalid_input", ctypes.c_bool),
        ("high_res_blend_mode", ctypes.c_int32),
        ("hide_bg_layer1", ctypes.c_bool),
        ("hide_bg_layer2", ctypes.c_bool),
        ("hide_bg_layer3", ctypes.c_bool),
        ("hide_bg_layer4", ctypes.c_bool),
        ("hide_sprites", ctypes.c_bool),
        ("disable_frame_skipping", ctypes.c_bool),
        ("force_fixed_resolution", ctypes.c_bool),
        ("overscan", ctypes.c_uint32 * 4),  # left, right, top, bottom
        ("interpolation_type", ctypes.c_int32),
        ("channel_volumes", ctypes.c_uint32 * 8),
        ("enable_random_power_on_state", ctypes.c_bool),
        ("enable_strict_board_mappings", ctypes.c_bool),
        ("ram_power_on_state", ctypes.c_int32),
        ("spc_clock_speed_adjustment", ctypes.c_int32),
        ("ppu_extra_scanlines_before_nmi", ctypes.c_uint32),
        ("ppu_extra_scanlines_after_nmi", ctypes.c_uint32),
        ("gsu_clock_speed", ctypes.c_uint32),
        ("bsx_custom_date", ctypes.c_int64),
    )

    @classmethod
    def defaults(cls) -> SnesConfig:
        """The struct as the pinned header default-constructs it.

        Zero everywhere the header says zero, which is nearly everywhere, and
        the three exceptions written out.
        """
        config = cls()
        config.channel_volumes = (ctypes.c_uint32 * 8)(*([100] * 8))
        config.gsu_clock_speed = 100
        config.bsx_custom_date = -1
        return config

    @classmethod
    def with_controller(cls) -> SnesConfig:
        """The defaults, with a pad in port 1 and nothing in port 2."""
        config = cls.defaults()
        config.port1.type = CONTROLLER_SNES
        return config


#: ``ControllerType::SnesController``, the entry after ``None``.
CONTROLLER_SNES = 1


#: The volume a core is built at, and what :meth:`MesenCore.set_volume` puts
#: back after something has turned the sound down for a stretch nobody is
#: listening to. Mesen's own default, and the only field of the audio config
#: anything here ever moves.
MASTER_VOLUME = 100


class AudioConfig(ctypes.Structure):
    """Mesen's ``AudioConfig``, mirrored so that sound does not crash the core.

    Bound for one field, like :class:`SnesConfig`, and for a sharper reason.
    ``AudioDevice`` is a ``const char*`` that defaults to **null**, because
    Mesen's own front end always pushes a config before anything plays. Nothing
    here did, and the Windows sound manager ends every frame with

        SetAudioDevice(cfg.AudioDevice)      // takes a std::string by value

    -- so the first frame of sound constructed a ``std::string`` from a null
    pointer and took the worker down with an access violation. It is the only
    pointer in any of these config structs, which is why it is the only one that
    faults rather than merely behaving oddly.

    Every other field is the pinned header's own default. The two that are not
    zero-or-obvious matter: ``SampleRate`` is 48000 while the Windows manager
    opens its device at 44100, so the first buffer always re-initialises it, and
    ``AudioLatency`` decides how large that device's buffer is.
    """

    _fields_ = (
        ("audio_device", ctypes.c_char_p),
        ("enable_audio", ctypes.c_bool),
        ("disable_dynamic_sample_rate", ctypes.c_bool),
        ("master_volume", ctypes.c_uint32),
        ("sample_rate", ctypes.c_uint32),
        ("audio_latency", ctypes.c_uint32),
        ("mute_sound_in_background", ctypes.c_bool),
        ("reduce_sound_in_background", ctypes.c_bool),
        ("reduce_sound_in_fast_forward", ctypes.c_bool),
        ("volume_reduction", ctypes.c_uint32),
        ("reverb_enabled", ctypes.c_bool),
        ("reverb_strength", ctypes.c_uint32),
        ("reverb_delay", ctypes.c_uint32),
        ("cross_feed_enabled", ctypes.c_bool),
        ("cross_feed_ratio", ctypes.c_uint32),
        ("enable_equalizer", ctypes.c_bool),
        ("band_gains", ctypes.c_double * 20),
        ("audio_player_enable_track_length", ctypes.c_bool),
        ("audio_player_track_length", ctypes.c_uint32),
        ("audio_player_auto_detect_silence", ctypes.c_bool),
        ("audio_player_silence_delay", ctypes.c_uint32),
    )

    @classmethod
    def defaults(cls, device: bytes = b"") -> AudioConfig:
        """The struct as the pinned header default-constructs it, plus a device.

        ``device`` is an **empty name on purpose**: the sound manager compares it
        against the names of the devices it can find, matches none, and leaves
        the device GUID zeroed -- which is what "the default output" is. What
        matters is that it is a string rather than a null pointer.
        """
        return cls(
            audio_device=device,
            enable_audio=True,
            disable_dynamic_sample_rate=False,
            master_volume=MASTER_VOLUME,
            sample_rate=48000,
            audio_latency=60,
            mute_sound_in_background=False,
            reduce_sound_in_background=True,
            reduce_sound_in_fast_forward=False,
            volume_reduction=75,
            audio_player_enable_track_length=True,
            audio_player_track_length=120,
            audio_player_auto_detect_silence=True,
            audio_player_silence_delay=3,
        )


class ControllerState(ctypes.Structure):
    """Mesen's ``DebugControllerState``, which is how a button is pressed here.

    Fourteen plain ``bool``s from ``Core/Debugger/DebugTypes.h``, passed **by
    value**. Bound on the same grounds as :class:`CpuState` -- one pinned commit
    -- and cheaper to be confident about, being fourteen bytes with no padding
    decisions in them.

    ``U`` and ``D`` are not the d-pad; they are the Famicom microphone and a
    second unused bit, and ``SnesDebugger::ProcessInputOverrides`` ignores both.
    The d-pad is ``Up``/``Down``/``Left``/``Right``.

    **An all-clear state is not an override.** Mesen skips a controller whose
    state has no button pressed, deferring to whatever the key manager says --
    and a core built with ``noInput`` has none, so it reads as nothing held.
    Releasing every button therefore does what it looks like.
    """

    _fields_ = tuple(
        (name, ctypes.c_bool)
        for name in (
            "a",
            "b",
            "x",
            "y",
            "l",
            "r",
            "mic",
            "unused",
            "up",
            "down",
            "left",
            "right",
            "select",
            "start",
        )
    )


class StepType(IntEnum):
    """The one ``StepType`` this package uses, and how its value is known.

    **Measured, not read off a header.** These are positions in Mesen's internal
    C++ enum, so the honest way to pin one down is to drive it and watch what
    moves. ``smw/tmp/step_probe2.py`` runs each candidate twice from one
    savestate and reports what changed; ``6`` is the only value that advances
    exactly one frame, comes to rest (``IsPaused`` goes true), and leaves a
    **complete** OAM buffer that is byte-identical between the two runs.

    The near misses are the reason this is not a guess. ``7`` and ``9`` also
    stop repeatably but land where the buffer is empty or half-filled, and
    ``1``, ``11``, ``12`` and ``13`` never come to rest at all -- each of which
    would look like working code and produce a subtly or completely wrong
    picture.
    """

    #: One PPU frame, stopping after the sprites have been drawn.
    PPU_FRAME = 6


class CoreBroke(RuntimeError):
    """The debugger stopped the machine at a ``BRK``, and it is stopped still.

    Raised by whatever was waiting for the machine to do something -- a call
    that will now never return, a game mode that will never change -- so that a
    request fails at the moment of the ``BRK`` rather than at the far end of a
    timeout.

    :attr:`evidence` is whatever :attr:`MesenCore.on_break` gathered while the
    machine was still stopped, which is the only moment the registers and the
    stack are the ``BRK``'s own. Nothing here decides what that is: the core
    knows a machine and not a cartridge, and it is
    :class:`shiny_mushroom.emu.smw.CartSession` that turns one into a
    :class:`shiny_mushroom.brk.BrkReport`.
    """

    def __init__(self, message: str, evidence: object = None) -> None:
        super().__init__(message)
        self.evidence = evidence


class EmulatorUnavailable(RuntimeError):
    """No usable emulator core -- not vendored for this platform, or unloadable.

    Raised rather than returned so that a caller which forgot to check cannot
    proceed with a half-initialised loader; the editor catches it and degrades
    to whatever non-emulated rendering exists.
    """


def host_platform() -> tuple[str, str]:
    """This machine as ``(os, arch)`` in the names the vendor layout uses."""
    system = "linux" if sys.platform.startswith("linux") else sys.platform
    machine = platform.machine().lower()
    if machine in ("x86_64", "amd64", "x64"):
        arch = "x64"
    elif machine in ("arm64", "aarch64"):
        arch = "arm64"
    else:  # pragma: no cover - no runner has one
        arch = machine
    return system, arch


def platform_dir() -> str:
    """The vendor directory for this machine, e.g. ``linux-x64``."""
    key = host_platform()
    if key not in _PLATFORM_DIRS:
        raise EmulatorUnavailable(
            f"no Mesen core layout is defined for {key[0]}-{key[1]}"
        )
    return _PLATFORM_DIRS[key]


def dev_library_dir() -> Path:
    """Where locally built cores live in a source checkout, built or not."""
    repository = Path(__file__).resolve().parents[3]
    return repository / DEV_DIR_NAME / platform_dir()


def library_path() -> Path:
    """Locate the core for this machine, or say precisely why there is none.

    Three places, most specific first: an explicit path in the environment, a
    locally built core at the repository root, then the one bundled into the
    package. The middle one is why a developer who has just built a core does
    not have to copy it anywhere, and why doing so cannot accidentally become
    what a release ships.
    """
    override = os.environ.get(LIBRARY_ENV_VAR)
    if override:
        path = Path(override)
        if not path.exists():
            raise EmulatorUnavailable(
                f"{LIBRARY_ENV_VAR} points at {path}, which does not exist"
            )
        return path

    system, _ = host_platform()
    if system not in _LIBRARY_FILENAMES:
        raise EmulatorUnavailable(
            f"no Mesen core is built for platform {sys.platform!r}"
        )
    name = _LIBRARY_FILENAMES[system]
    folder = platform_dir()

    local = dev_library_dir() / name
    if local.exists():
        return local

    from shiny_mushroom import resources

    node = resources.resource("mesen", folder, name)
    # A Traversable is not necessarily a real file, but ctypes needs a path on
    # disk. Every packaging route we use (source tree, wheel, PyInstaller
    # one-folder and one-file) materialises data files, so this holds -- and if
    # it ever stops holding, this is the line that says so.
    try:
        path = Path(str(node))
    except TypeError as exc:  # pragma: no cover - depends on the loader
        raise EmulatorUnavailable(
            f"the vendored core is not a real file: {exc}"
        ) from exc
    if not path.exists():
        raise EmulatorUnavailable(
            f"no Mesen core for {folder}. Looked in {local.parent} and in the "
            f"bundled resources. Build one with "
            f"`uv run python packaging/build_mesen_core.py`, download one from "
            f"the 'Mesen core' workflow, or set {LIBRARY_ENV_VAR} to a library."
        )
    return path


def _own_window() -> int | None:
    """A window of this process's own for the sound manager to hold, on Windows.

    ``None`` everywhere else, and ``None`` on a Windows that would not make one:
    both mean "pass :data:`PLACEHOLDER_WINDOW_HANDLE`", which is what every
    other platform's core wants anyway.

    **Message-only** (:data:`HWND_MESSAGE` as its parent) rather than a hidden
    top-level one. DirectSound only stores the handle, so what the window costs
    is what the desktop can ask of it -- and nothing in this process ever pumps
    a message loop, so a window that broadcasts could reach would stall whoever
    sent one until it timed out. A message-only window is not enumerated with
    the top-level windows and receives no broadcast at all.

    ``STATIC`` rather than a class of ours, because registering one means a
    window procedure that has to outlive every window made from it -- a
    ctypes callback held for the life of the process to answer messages that
    never arrive.
    """
    if sys.platform != "win32":
        return None
    user32 = ctypes.WinDLL("user32", use_last_error=True)
    user32.CreateWindowExW.restype = ctypes.c_void_p
    user32.CreateWindowExW.argtypes = [
        ctypes.c_uint32,  # dwExStyle
        ctypes.c_wchar_p,  # lpClassName
        ctypes.c_wchar_p,  # lpWindowName
        ctypes.c_uint32,  # dwStyle
        ctypes.c_int,  # X
        ctypes.c_int,  # Y
        ctypes.c_int,  # nWidth
        ctypes.c_int,  # nHeight
        ctypes.c_void_p,  # hWndParent
        ctypes.c_void_p,  # hMenu
        ctypes.c_void_p,  # hInstance
        ctypes.c_void_p,  # lpParam
    ]
    window = user32.CreateWindowExW(
        0,
        "STATIC",
        "Shiny Mushroom sound",
        0,
        0,
        0,
        0,
        0,
        ctypes.c_void_p(HWND_MESSAGE),
        None,
        None,
        None,
    )
    # A core that plays quietly is worth more than one that will not start, so
    # a window that could not be made is a fallback rather than a failure.
    return window or None


def _close_window(window: int) -> None:
    """Destroy what :func:`_own_window` made. Only ever called with one."""
    user32 = ctypes.WinDLL("user32", use_last_error=True)
    user32.DestroyWindow.argtypes = [ctypes.c_void_p]
    user32.DestroyWindow(ctypes.c_void_p(window))


class MesenCore:
    """One loaded, initialised, headless emulator core.

    Not reentrant and not thread-safe: the core keeps global state in the shared
    library, so a process gets exactly one of these. That is a real constraint
    rather than an oversight -- ``_emu`` in ``EmuApiWrapper.cpp`` is a file-scope
    singleton -- and it is the other reason the worker is a separate process.
    """

    #: Set this in the environment and no core built anywhere will open a sound
    #: device, whatever it was asked for. It is read here rather than passed
    #: down because the core that matters lives in a **worker subprocess**: a
    #: caller can only ask the supervisor for silence, and nothing it patches in
    #: its own process reaches the object that would open the device. An
    #: inherited environment does.
    #:
    #: The test suite sets it (``editor/tests/conftest.py``). A run must not
    #: need a sound device to pass, must not make a noise on a developer's
    #: machine, and must not spend a second of SDL startup on one.
    NO_AUDIO_ENV = "SHINY_MUSHROOM_NO_AUDIO"

    def __init__(
        self,
        home_folder: Path | None = None,
        *,
        video: bool = False,
        audio: bool = False,
    ) -> None:
        if audio and os.environ.get(self.NO_AUDIO_ENV):
            audio = False
        path = library_path()
        try:
            # CDLL, not WinDLL, on every platform: the exports are declared
            # __stdcall but that calling convention does not exist on x86-64,
            # where Windows and SysV both ignore it.
            self._lib = ctypes.CDLL(str(path))
        except OSError as exc:
            raise EmulatorUnavailable(f"could not load {path}: {exc}") from exc

        self._bind()

        # The core writes save data, savestates and its own scratch here. It is
        # never read back by this package -- the state we care about is passed
        # in memory -- but it must exist and be writable. A made-up one is
        # removed again in :meth:`release`; a caller's is the caller's.
        self._owns_home = home_folder is None
        self._home = home_folder or Path(
            tempfile.mkdtemp(prefix="shiny_mushroom-mesen-")
        )
        self._home.mkdir(parents=True, exist_ok=True)

        # NULL for both handles means "build nothing" -- no renderer, no sound
        # manager, no key manager -- which is what a loader wants. Asking for
        # either means passing something non-NULL, and on Windows something the
        # window manager will agree exists: see the module docstring.
        self._window = _own_window() if (video or audio) else None
        handle = (
            ctypes.c_void_p(self._window or PLACEHOLDER_WINDOW_HANDLE)
            if (video or audio)
            else None
        )
        self._lib.InitDll()
        self._lib.InitializeEmu(
            str(self._home).encode(),
            handle,  # window handle
            handle,  # viewer handle
            True,  # softwareRenderer: a buffer we can copy, never a GPU surface
            not audio,  # noAudio
            not video,  # noVideo
            True,  # noInput -- buttons arrive through set_buttons, not a keyboard
        )
        self._rom_loaded = False
        self._video = video
        self._audio = audio
        self._controller = False
        if audio:
            self._configure_audio()
        # Held for as long as the core is: ctypes does not keep a reference to a
        # callback the library is holding, so letting either of these be
        # collected leaves the render thread calling freed memory.
        self._notify_trampoline: object | None = None
        self._listener: int | None = None
        # Every trampoline this core has ever registered, kept alive until the
        # library itself is gone -- see :meth:`_stop_video` for why
        # unregistering is not enough to make one collectable.
        self._retired_trampolines: list[object] = []
        self._video_sink = None
        # The debugger's half of the same arrangement -- see
        # :meth:`watch_for_brk`. The break is written by the emulation thread
        # from inside the notification and read by whichever thread is waiting
        # for the machine, which is what a single assignment of an immutable
        # tuple is safe for.
        self._break_trampoline: object | None = None
        self._break_listener: int | None = None
        self._break: tuple[int, int] | None = None
        self._watching_brk = False
        #: Called with ``(source, cpu)`` while the machine is still stopped at
        #: a break, and whatever it returns is carried on :class:`CoreBroke`.
        #: The core gathers nothing itself: what is worth reading off a stopped
        #: SMW cartridge is not a fact about a Mesen core.
        self.on_break: Callable[[int, int], object] | None = None

    def _bind(self) -> None:
        """Declare argument and return types for everything we call.

        ctypes defaults every argument to int-sized and every return to int,
        which silently truncates pointers on 64-bit. Declaring them is not
        optional tidiness.
        """
        lib = self._lib
        c = ctypes

        lib.InitDll.restype = None
        lib.InitDll.argtypes = []

        lib.InitializeEmu.restype = None
        lib.InitializeEmu.argtypes = [
            c.c_char_p,
            c.c_void_p,
            c.c_void_p,
            c.c_bool,
            c.c_bool,
            c.c_bool,
            c.c_bool,
        ]

        lib.LoadRom.restype = c.c_bool
        lib.LoadRom.argtypes = [c.c_char_p, c.c_char_p]

        lib.GetMesenVersion.restype = c.c_uint32
        lib.GetMesenVersion.argtypes = []

        lib.SetEmulationFlag.restype = None
        lib.SetEmulationFlag.argtypes = [c.c_int32, c.c_bool]

        for name in ("Pause", "Resume", "Release", "InitializeDebugger"):
            fn = getattr(lib, name)
            fn.restype = None
            fn.argtypes = []

        for name in ("IsRunning", "IsPaused"):
            fn = getattr(lib, name)
            fn.restype = c.c_bool
            fn.argtypes = []

        # Step(cpuType, count, stepType). All three primitives, so this is on
        # the safe side of the line the module docstring draws.
        lib.Step.restype = None
        lib.Step.argtypes = [c.c_int32, c.c_int32, c.c_int32]

        # The one structure-passing pair that is bound, against a struct
        # mirrored from the pinned revision's own header -- see CpuState.
        for name in ("GetCpuState", "SetCpuState"):
            fn = getattr(lib, name)
            fn.restype = None
            fn.argtypes = [c.POINTER(CpuState), c.c_int32]

        # The debugger, which is how a BRK is noticed. Three primitives and
        # one by-value struct -- see DebugConfig -- against a debugger the
        # editor never single-steps: what it is turned on for is the one thing
        # it does without being asked, which is to stop at a BRK.
        lib.SetDebuggerFlag.restype = None
        lib.SetDebuggerFlag.argtypes = [c.c_int32, c.c_bool]
        lib.SetDebugConfig.restype = None
        lib.SetDebugConfig.argtypes = [DebugConfig]
        lib.ResumeExecution.restype = None
        lib.ResumeExecution.argtypes = []
        lib.IsDebuggerRunning.restype = c.c_bool
        lib.IsDebuggerRunning.argtypes = []

        # The trace logger, which is how the editor learns which code wrote
        # what -- see TraceLoggerOptions. Passed by value, as the export takes
        # it.
        lib.SetTraceOptions.restype = None
        lib.SetTraceOptions.argtypes = [c.c_int32, TraceLoggerOptions]
        lib.StartLogTraceToFile.restype = None
        lib.StartLogTraceToFile.argtypes = [c.c_char_p]
        lib.StopLogTraceToFile.restype = None
        lib.StopLogTraceToFile.argtypes = []

        # The access counters. Bound because they are how the editor finds out
        # which object drew which block -- see `AddressCounters`.
        lib.GetMemoryAccessCounts.restype = None
        lib.GetMemoryAccessCounts.argtypes = [
            c.c_uint32,
            c.c_uint32,
            c.c_int32,
            c.c_void_p,
        ]

        # The write log -- this project's own patch to the core
        # (`packaging/mesen-patches`), so an unpatched build simply lacks the
        # exports and the editor falls back to the counters' one-stamp answer.
        # A capability, not an assumption.
        try:
            lib.SetWriteLogRange.restype = None
            lib.SetWriteLogRange.argtypes = [
                c.c_int32,
                c.c_uint32,
                c.c_uint32,
                c.c_uint32,
            ]
            lib.GetWriteLog.restype = c.c_uint32
            lib.GetWriteLog.argtypes = [c.c_void_p, c.POINTER(c.c_uint32)]
        except AttributeError:
            self._write_log_capacity = None
        else:
            self._write_log_capacity = 0

        lib.GetMemorySize.restype = c.c_uint32
        lib.GetMemorySize.argtypes = [c.c_int32]

        lib.GetMemoryState.restype = None
        lib.GetMemoryState.argtypes = [c.c_int32, c.POINTER(c.c_uint8)]

        lib.SetMemoryState.restype = None
        lib.SetMemoryState.argtypes = [c.c_int32, c.POINTER(c.c_uint8), c.c_int32]

        lib.GetMemoryValue.restype = c.c_uint8
        lib.GetMemoryValue.argtypes = [c.c_int32, c.c_uint32]

        lib.SetMemoryValue.restype = None
        lib.SetMemoryValue.argtypes = [c.c_int32, c.c_uint32, c.c_uint8]

        lib.SaveStateFile.restype = None
        lib.SaveStateFile.argtypes = [c.c_char_p]

        lib.LoadStateFile.restype = None
        lib.LoadStateFile.argtypes = [c.c_char_p]

        # The frame pump. The listener is an opaque handle to hand back at
        # release; nothing here looks inside it.
        lib.RegisterNotificationCallback.restype = c.c_void_p
        lib.RegisterNotificationCallback.argtypes = [NOTIFICATION_CALLBACK]

        lib.UnregisterNotificationCallback.restype = None
        lib.UnregisterNotificationCallback.argtypes = [c.c_void_p]

        # Buttons. Structures by value, mirrored from the pinned revision --
        # see ControllerState and SnesConfig for why that is defensible here.
        lib.SetInputOverrides.restype = None
        lib.SetInputOverrides.argtypes = [c.c_uint32, ControllerState]

        lib.SetSnesConfig.restype = None
        lib.SetSnesConfig.argtypes = [SnesConfig]

        lib.SetAudioConfig.restype = None
        lib.SetAudioConfig.argtypes = [AudioConfig]

        lib.HasControlDevice.restype = c.c_bool
        lib.HasControlDevice.argtypes = [c.c_int32]

    # -- lifecycle ---------------------------------------------------------

    @property
    def version(self) -> tuple[int, int, int]:
        """The core's version, as Mesen packs it: one byte each, major first."""
        raw = self._lib.GetMesenVersion()
        return ((raw >> 16) & 0xFF, (raw >> 8) & 0xFF, raw & 0xFF)

    def load_rom(self, rom: Path) -> None:
        if not self._lib.LoadRom(str(rom).encode(), b""):
            raise EmulatorUnavailable(f"the core refused to load {rom}")
        self._rom_loaded = True

        # **After** LoadRom, never before. Loading a ROM resets the emulation
        # flags, so a MaximumSpeed set during construction is silently discarded
        # and the core paces itself to 60 fps for a display nobody is watching --
        # which costs 520 ms per level load instead of 170 ms. Nothing reports
        # this; the only symptom is that everything takes exactly real time.
        # Mesen's own headless test runner sets these here for the same reason.
        self.set_maximum_speed(True)
        self._lib.SetEmulationFlag(FLAG_CONSOLE_MODE, True)
        # The memory dumper belongs to the debugger, which is created on demand
        # by the first call that needs it -- so the layout check has to come
        # after a ROM exists, not after construction.
        self._lib.InitializeDebugger()
        verify(self.memory_size)
        if self._controller and not self._lib.HasControlDevice(CONTROLLER_SNES):
            # Checked here rather than at attach_controller, which runs before
            # there is a console to hold a device. The pad landing where the
            # core looks for it means every one of the 9,920 bytes in front of
            # SnesConfig.port1.type is at the offset this mirror says.
            raise EmulatorUnavailable(
                "the core registered no SNES controller after being configured "
                "for one, so SnesConfig's layout is not this build's and "
                "button presses would go nowhere."
            )

    def set_maximum_speed(self, unlimited: bool) -> None:
        """Emulate as fast as the host can, or at the speed of a console.

        Unlimited is what a loader wants and what :meth:`load_rom` leaves set:
        the frames between a request and a loaded level are not for looking at.
        A core somebody is *playing* has to be put back to console speed, which
        is what turning this off does -- Mesen's frame limiter paces it whether
        or not a sound device was ever opened.
        """
        self._lib.SetEmulationFlag(FLAG_MAXIMUM_SPEED, unlimited)

    @contextmanager
    def at_maximum_speed(self) -> Iterator[None]:
        """Run the block as fast as the host can, then go back to real time."""
        self.set_maximum_speed(True)
        try:
            yield
        finally:
            self.set_maximum_speed(False)

    def release(self) -> None:
        """Stop and free the core. Safe to call twice, and only to call.

        The handle is dropped rather than merely marked, so a call made after
        this fails here instead of reaching a library whose state has been torn
        down -- where the same mistake is a native fault at some later moment.
        """
        if self._lib is None:
            return
        # A machine stopped at a break has its emulation thread blocked inside
        # it, and Release stops and joins that thread -- so it is let go first,
        # whatever anybody was going to do with the break.
        if self._break is not None:
            self._break = None
            self._lib.ResumeExecution()
        # Before Release: the render thread is still calling the trampoline
        # until the listener is taken down.
        self._stop_video()
        self._stop_breaks()
        self._lib.Release()
        # Only here, and never before Release has returned. Release stops the
        # emulation and render threads and joins them, so this is the first
        # moment at which nothing native can still be inside a trampoline.
        self._retired_trampolines.clear()
        self._lib = None
        # After ``Release``, which is what takes the sound manager -- and the
        # handle it is still holding -- down.
        if self._window is not None:
            _close_window(self._window)
            self._window = None
        if self._owns_home:
            shutil.rmtree(self._home, ignore_errors=True)

    # -- breaks ------------------------------------------------------------

    def watch_for_brk(self) -> None:
        """Stop the machine at every ``BRK``, and notice when it happens.

        Three things, once per core: the debugger is started, both SNES
        processors are told to run it, and ``SnesBreakOnBrk`` is set. From then
        on a ``BRK`` anywhere in the cartridge -- the game's own code, a hack's,
        a custom sprite's -- stops the machine **before the instruction
        executes** and sends ``CodeBreak``. That ordering is the whole value of
        it: the registers, the stack pointer and the status byte are the ones
        the ``BRK`` was reached with, where a handler running *after* it can
        only report what it managed to preserve.

        **Measured at about 2.5%**: 300 frames at maximum speed run at 193 fps
        with the debugger off and 188 with it on, which is why this is on for
        every worker rather than something a person turns on when they suspect
        a crash -- by which time the crash has already happened.

        Starting the debugger stops the machine once, on its own account
        (``BreakSource::Pause``), so this ends by letting it go again.
        """
        if self._watching_brk:
            return
        lib = self._lib

        def notified(kind: int, parameter: int) -> None:
            # On the emulation thread, which then blocks until something calls
            # ResumeExecution -- so this does as little as a thread that has
            # stopped a machine mid-instruction should.
            if kind != NOTIFY_CODE_BREAK or not parameter:
                return
            event = ctypes.cast(parameter, ctypes.POINTER(BreakEvent)).contents
            if event.source == BREAK_SOURCE_BRK:
                self._break = (event.source, event.source_cpu)

        trampoline = NOTIFICATION_CALLBACK(notified)
        self._break_trampoline = trampoline
        self._break_listener = lib.RegisterNotificationCallback(trampoline)
        self.arm_brk(True)
        lib.SetDebuggerFlag(DEBUGGER_FLAG_SNES, True)
        lib.SetDebuggerFlag(DEBUGGER_FLAG_SA1, True)
        lib.InitializeDebugger()
        lib.ResumeExecution()
        self._watching_brk = True

    def _stop_breaks(self) -> None:
        """Take the break listener down, the way :meth:`_stop_video` does.

        Retired rather than dropped: the library holds the pointer until
        ``Release`` has joined its threads, so a trampoline collected here
        would be freed memory an emulation thread is still calling.
        """
        if self._break_listener is None:
            return
        self._lib.UnregisterNotificationCallback(ctypes.c_void_p(self._break_listener))
        self._break_listener = None
        self._retired_trampolines.append(self._break_trampoline)
        self._break_trampoline = None
        self._watching_brk = False

    def arm_brk(self, armed: bool) -> None:
        """Turn breaking at a ``BRK`` on or off, leaving the debugger running.

        Off is how a machine gets *past* the ``BRK`` it is stopped at without
        stopping at the same instruction again a cycle later, and how a
        runaway that BRKs in a loop is kept from breaking on every pass while
        the recovery runs.
        """
        config = DebugConfig()
        config.snes_break_on_brk = bool(armed)
        self._lib.SetDebugConfig(config)

    @property
    def broke_on_brk(self) -> bool:
        """Whether the machine is stopped at a ``BRK`` right now."""
        return self._break is not None

    def peek_break(self) -> object:
        """Gather what the break is worth and **leave the machine stopped**.

        :meth:`take_break` without the ending, for the one caller that has
        somebody to ask: a test run's player is about to be shown the report
        and offered the choice between :meth:`resume_break` and
        :meth:`let_break_go`, and neither can be made for them here.

        The machine stays stopped in the meantime, which is what "the run
        froze at a ``BRK``" looks like from the window: no frames arrive,
        because none are being drawn.
        """
        if self._break is None or self.on_break is None:
            return None
        return self.on_break(*self._break)

    def take_break(self) -> object:
        """Gather what the break is worth, let the machine go, and forget it.

        In that order, and the order is the point. :attr:`on_break` reads the
        stopped machine -- the only moment at which it is the ``BRK``'s own --
        and only then is the ``BRK`` stepped past: resuming first would leave a
        cartridge with no handler running into whatever its ``BRK`` vector
        points at, over the very bytes the report is made of.

        Breaking is disarmed for the resume and armed again after it, so the
        instruction the machine is sitting on does not stop it a second time.
        """
        source, cpu = self._break or (BREAK_SOURCE_BRK, CPU_TYPE_SNES)
        evidence = None
        if self.on_break is not None:
            evidence = self.on_break(source, cpu)
        self.let_break_go()
        return evidence

    def let_break_go(self) -> None:
        """Unblock a machine stopped at a break, without executing the ``BRK``.

        The emulation thread is *inside* the break until something resumes it,
        so this is what every other request in the worker's life waits on --
        and the machine has to come out of it in a state the next request can
        use.

        **The instruction is stepped over rather than run**, which is the
        difference between a recovery and a second crash. A ``BRK`` executed on
        a cartridge with no handler vectors through ``$00FFE6`` -- ``$FFFF`` on
        a stock image -- and the runaway that follows walks into more of them:
        measured, letting one go produced a fresh break inside the game's own
        code within the same frame, and then another, each of which blocked the
        thread again and would have been handed to the next request as though
        its cartridge had raised it. Moving the program counter past the two
        bytes leaves the machine standing at the instruction after the
        exception, which is a machine that stops when it is told to. Nobody
        reads it either way: every caller restores a savestate or reports a
        failure.

        **Looped, and not because a ``BRK`` can break twice.** Breaking is
        disarmed for the resume, so the instruction stepped over cannot stop
        the machine again -- but the frame the halt takes to land is a frame of
        a cartridge whose code has just raised an exception, and a break that
        arrives in it leaves the emulation thread blocked again. One left
        pending would be handed to the next request as though its cartridge had
        raised it; one left *blocked* would stop the worker answering at all.

        :meth:`resume_break` is the other ending, and the one that *does*
        execute it -- for a run whose player asked to carry on.
        """
        for _ in range(BREAK_RELEASES):
            if self._break is None:
                break
            _, cpu = self._break
            self._break = None
            self.arm_brk(False)
            state = self.cpu_state(cpu)
            state.pc = (state.pc + BRK_LENGTH) & 0xFFFF
            self.set_cpu_state(state, cpu)
            self._lib.ResumeExecution()
            self.halt()
        self.arm_brk(True)

    def resume_break(self) -> None:
        """Let a machine stopped at a ``BRK`` carry on running past it.

        :meth:`let_break_go`'s other ending, for the one caller that has
        somebody watching: a test run whose player has read the report and
        asked to carry on. The cartridge executes the ``BRK`` and goes wherever
        its vector says, which is the run they asked to keep.
        """
        if self._break is None:
            return
        self._break = None
        self.arm_brk(False)
        self._lib.ResumeExecution()
        self.start()
        self.arm_brk(True)

    # -- pictures ----------------------------------------------------------

    def capture_video(self, sink, timeout: float = 5.0) -> None:
        """Have ``sink(width, height, pixels)`` called for every frame drawn.

        ``pixels`` is ``width * height`` little-endian ``0xAARRGGBB`` words --
        Qt's ``Format_RGB32`` byte for byte. The copy is made inside the
        callback because the buffer belongs to Mesen and is only guaranteed for
        its duration; the alternative is a picture that tears or a pointer that
        outlives its lock.

        **The sink runs on Mesen's render thread**, not the caller's, and its
        exceptions are swallowed rather than unwound into C++. It should latch
        the frame and return; anything longer stalls the renderer.

        Waits for the first frame, and fails if none arrives. That wait is the
        only check there is on ``NOTIFY_REFRESH_SOFTWARE_RENDERER`` still being
        the notification it was at the pinned revision -- silence here means
        either the ordinal has moved or the core was built without video, and
        both are worth an exception rather than a permanently black window.
        """
        if not self._video:
            raise EmulatorUnavailable(
                "this core was created without video; pass video=True to see frames"
            )
        seen = threading.Event()

        def trampoline(kind: int, parameter: int) -> None:
            if kind != NOTIFY_REFRESH_SOFTWARE_RENDERER or not parameter:
                return
            try:
                surface = ctypes.cast(
                    parameter, ctypes.POINTER(SoftwareRendererFrame)
                ).contents.frame
                width, height = surface.width, surface.height
                if (
                    not surface.buffer
                    or not 0 < width <= MAX_FRAME_DIMENSION
                    or not 0 < height <= MAX_FRAME_DIMENSION
                ):
                    # Not a frame -- so this is not the notification we think it
                    # is. Dropping it is the only safe move; the wait below turns
                    # a run of these into a legible failure.
                    return
                pixels = ctypes.string_at(surface.buffer, width * height * 4)
                seen.set()
                sink(width, height, pixels)
            except Exception:  # noqa: BLE001 - there is no caller to raise into
                pass

        self._stop_video()
        self._video_sink = sink
        self._notify_trampoline = NOTIFICATION_CALLBACK(trampoline)
        self._listener = self._lib.RegisterNotificationCallback(self._notify_trampoline)
        if not seen.wait(timeout):
            self._stop_video()
            raise EmulatorUnavailable(
                f"no frame arrived within {timeout:g}s of asking for video: "
                f"either this core has no software renderer, or "
                f"notification {NOTIFY_REFRESH_SOFTWARE_RENDERER} is no "
                f"longer RefreshSoftwareRenderer in its revision."
            )

    def _stop_video(self) -> None:
        """Take the listener down, but keep the trampoline. Safe with none.

        **Unregistering does not mean the trampoline has stopped being
        called.** Mesen's notification manager copies its listener list under a
        lock and then dispatches without one, so a thread already inside
        ``SendNotification`` holds the listener alive across an unregister --
        and the next notification, including the two that ``Release`` itself
        sends while stopping, finds it still there and calls straight through
        to whatever address the callback holds. Dropping the ctypes thunk here
        makes that address freed memory: an illegal instruction on the thread
        that got there first, which on Windows surfaces as ``0xc000001d``
        raised out of ``Release`` and depends entirely on a frame landing in
        the same millisecond as the close. So the thunk is retired rather than
        released, and :meth:`release` frees the retired ones once the library
        has joined every thread that could reach them.
        """
        if self._listener is not None:
            self._lib.UnregisterNotificationCallback(self._listener)
            self._listener = None
        if self._notify_trampoline is not None:
            self._retired_trampolines.append(self._notify_trampoline)
            self._notify_trampoline = None
        self._video_sink = None

    # -- buttons -----------------------------------------------------------

    def _configure_audio(self) -> None:
        """Give the core an audio config with a device name that is a string.

        **Not optional, and not tuning.** Without it ``AudioConfig.AudioDevice``
        is the null pointer the header defaults it to, and the Windows sound
        manager builds a ``std::string`` from it at the end of every frame --
        so the first frame of sound is an access violation on the emulation
        thread. Linux never sees it, which is exactly the kind of difference
        that ships.

        The device name has to outlive the call: the core keeps the pointer and
        reads through it every frame, so the buffer is held here rather than
        being a temporary that is freed on the way out of this method.
        """
        self._audio_device = ctypes.create_string_buffer(b"")
        self._lib.SetAudioConfig(
            AudioConfig.defaults(ctypes.cast(self._audio_device, ctypes.c_char_p))
        )

    def set_volume(self, percent: int) -> None:
        """Turn the sound down, or put it back. 0 is silent, 100 is as built.

        The whole audio config goes over, because that is the only shape the
        core takes one in -- the device name included, read from the buffer
        :meth:`_configure_audio` keeps alive for exactly as long as the core
        is, and for exactly this reason.

        **Nothing at all without a sound manager.** A core built with
        ``audio=False`` has none to tell, and the config it would carry names a
        buffer that core never made.
        """
        if not self._audio:
            return
        config = AudioConfig.defaults(ctypes.cast(self._audio_device, ctypes.c_char_p))
        config.master_volume = int(percent)
        self._lib.SetAudioConfig(config)

    def attach_controller(self) -> None:
        """Plug a SNES pad into port 1.

        **Call this before** :meth:`load_rom`, which checks that it took.
        Control devices are built from the settings when the console is
        constructed, and that happens at ROM load -- so configuring afterwards
        leaves the machine without one until something else rebuilds them.

        Nothing has a controller by default -- ``ControllerType::None`` on both
        ports -- and ``SetInputOverrides`` writes into a device rather than onto
        the bus, so without this every button press is discarded in silence.
        That is not hypothetical: it is what the first version of this did.
        """
        self._lib.SetSnesConfig(SnesConfig.with_controller())
        self._controller = True

    def set_buttons(self, state: ControllerState, port: int = 0) -> None:
        """Hold exactly the buttons ``state`` names, from now until told otherwise.

        This is the debugger's input override, which the SNES debugger applies
        at every input poll -- so it survives frames without being re-sent, and
        it is why the core is built with ``noInput``: there is no keyboard in
        the worker process to compete with it.
        """
        self._lib.SetInputOverrides(port, state)

    # -- execution ---------------------------------------------------------

    def pause(self) -> None:
        self._lib.Pause()

    def halt(self, timeout: float = 2.0) -> None:
        """Stop the core and wait until it has actually stopped.

        **``Pause`` is a request, not a stop.** It returns immediately while the
        emulation thread carries on to a convenient boundary, so anything that
        writes CPU state straight after pausing is racing it -- the write lands
        and the thread then continues from wherever it already was, which looks
        exactly like the write having been ignored.

        ``IsPaused`` is no help: it reports the debugger's break state, and a
        plain ``Pause`` leaves it false. The cycle counter is the honest signal.
        Two consecutive reads agreeing means nothing is executing.
        """
        self.pause()
        deadline = time.monotonic() + timeout
        previous = self.cpu_state().cycle_count
        while time.monotonic() < deadline:
            time.sleep(0.0005)
            current = self.cpu_state().cycle_count
            if current == previous:
                return
            previous = current
        raise EmulatorUnavailable(f"the core kept running {timeout:g}s after a pause")

    def resume(self) -> None:
        self._lib.Resume()

    def start(self, timeout: float = 1.0) -> None:
        """Resume, and make sure the request took.

        **``Resume`` is a request too, and one of them can be lost.** ``Pause``
        is processed on the emulation thread, so a resume issued while a pause
        is still in flight can be swallowed -- and what is left behind reports
        itself *paused* with the program counter exactly where it was put.
        Caught in the act on the sprite probe: the core executed three cycles in
        two seconds, ``IsPaused`` was true, ``stop_state`` was zero and no
        interrupt was pending, and **a second resume started it within 0.7 ms**.

        That is where the capture's rare "this sprite has no graphics" came
        from, and before the budget was in cycles it was where the rare
        wall-clock expiry came from too. Measured at roughly one call in three
        hundred; with the retry, none in six hundred probes.

        Asking again is safe because a resume that was *not* lost has already
        started the machine, which is what the cycle counter is checked for.
        """
        self._arm(self.resume, timeout, "a resume")

    def _arm(self, ask: Callable[[], None], timeout: float, what: str) -> None:
        """Ask the core to run, and keep asking until the cycle counter moves.

        The one loop behind :meth:`start` and :meth:`step_frame`, which face
        the same lost request for the same reason -- both release the
        debugger's break, and a break still in flight can park after the
        release and leave the machine stopped with the request already spent.

        ``RESUME_CONFIRM`` is the whole of the judgement: a machine that has
        executed nothing that long did not receive the request. It is long
        against the microseconds a resume takes to show, which is what keeps a
        re-ask from landing on a request that was merely slow to start.
        """
        base = self.cpu_state().cycle_count
        deadline = time.monotonic() + timeout
        while True:
            ask()
            settle = time.monotonic() + RESUME_CONFIRM
            while time.monotonic() < settle:
                if self.cpu_state().cycle_count != base:
                    return
                time.sleep(CALL_POLL)
            # Read once more, as late as anything can be read before asking
            # again: the settle loop's last look is a poll interval short of
            # the deadline it was waiting on.
            if self.cpu_state().cycle_count != base:
                return
            if time.monotonic() >= deadline:
                raise EmulatorUnavailable(
                    f"the core did not start within {timeout:g}s of {what}"
                )

    @property
    def running(self) -> bool:
        return bool(self._lib.IsRunning())

    @property
    def paused(self) -> bool:
        """Whether execution is stopped. Not the same as :attr:`running`, which
        asks whether a ROM is open at all."""
        return bool(self._lib.IsPaused())

    def step_frame(self, count: int = 1, timeout: float = 5.0) -> None:
        """Advance exactly ``count`` frames and stop, at the same point each time.

        This is the difference between reading a frame and guessing at one.
        Anything the game rebuilds every frame -- OAM above all -- is cleared
        early in the frame and refilled as the frame's work runs, so a reader
        that resumes the core and pauses it again by wall clock lands at an
        arbitrary point in that cycle and sees a buffer that is empty, partial
        or complete depending on timing it does not control.

        ``Step`` is asynchronous: it arms a condition and the emulation thread
        runs until it is met. Waiting for ``IsPaused`` alone is **not** enough,
        and getting that wrong is silent -- the core is *already* paused when
        the step is armed, so a wait that only looks for "paused" is satisfied
        by the state it started in and returns before a single frame has run.
        The reader then sees whatever was in memory beforehand, and the bug
        hides behind any work done between the step and the read, because that
        gives the emulation thread the time the wait should have.

        So this waits for execution to *start* and then to stop. Either half
        timing out means the machine is not where the caller thinks, which is
        worth an exception rather than a plausible wrong answer.

        **One step armed for ``count`` frames, not ``count`` steps of one.** The
        handshake costs about 10 ms and a frame costs about 6, so stepping one
        at a time triples the price of every multi-frame wait: two frames
        measured 32 ms as a loop and 22 ms as one step. Verified equivalent --
        the frame counter advances by exactly ``count`` either way, and work RAM
        and VRAM come out byte-identical (smw/tmp/step_equivalence_probe.py).

        **The arm can be swallowed, and is re-asked the way a resume is.**
        ``Step`` releases the debugger's break as it arms -- but a break still
        in flight (a halt's pause the emulation thread had not processed yet)
        parks *after* that release and raises the wait flag again, leaving the
        machine stopped with an armed step nothing will start. Observed under
        host contention as "did not start within 5s of a frame step", the same
        shape as the lost resume :meth:`start` documents. Asking again releases
        the parked break, and it is safe for the same reason: nothing of the
        first arm has run, which is what :meth:`_arm` checks the cycle counter
        for before every re-ask. **The check cannot be made atomic**: an arm
        that starts in the instant between that check and the next one is armed
        twice, which for a step is frames the caller did not ask for rather
        than a harmless second resume. ``RESUME_CONFIRM`` is what makes it
        vanishingly unlikely -- it is longer than a frame, so a step that had
        started would have moved the counter -- and no re-ask has been observed
        overshooting.
        """
        if count <= 0:
            return
        self._arm(
            lambda: self._lib.Step(CPU_TYPE_SNES, count, int(StepType.PPU_FRAME)),
            timeout,
            "a frame step",
        )
        self._await(lambda: self.paused, timeout, "stop")

    # -- CPU state ---------------------------------------------------------

    def cpu_state(self, cpu: int = CPU_TYPE_SNES) -> CpuState:
        """The registers of ``cpu``, the main 65816 unless told otherwise.

        ``cpu`` is for a cartridge with a coprocessor, where the code that
        matters may be running on the other one: the SA-1 is a 65816 too and
        answers this same structure. Everything but a break report asks about
        the main CPU, which is the one this package drives.
        """
        state = CpuState()
        self._lib.GetCpuState(ctypes.byref(state), cpu)
        return state

    def set_cpu_state(self, state: CpuState, cpu: int = CPU_TYPE_SNES) -> None:
        """Write registers back, to ``cpu``'s.

        Every field the struct has is written, including the internal
        interrupt state -- which is why they are all modelled rather than
        skipped. Read one, change what you mean to, write it back, and nothing
        else moves.
        """
        self._lib.SetCpuState(ctypes.byref(state), cpu)

    # -- calling a cartridge routine ---------------------------------------

    def call(
        self,
        address: int,
        budget: int = CALL_BUDGET,
        direct_page: int = 0x0000,
    ) -> None:
        """Run one cartridge routine to completion, then restore the registers.

        The machinery is a stub written into work RAM -- ``JSL address``, then a
        store that raises :data:`CALL_DONE`, then a branch to itself -- with the
        program counter pointed at it. The routine's ``RTL`` lands on the store,
        so a flag the poll can read is what makes "finished" observable without
        a breakpoint.

        **``budget`` is in console cycles, not seconds.** A routine that has not
        returned within it is hung and reported as such; one that is merely slow
        to be *noticed* is not charged for the host's inattention. Measured, the
        longest legitimate call is a few thousand cycles against a budget of ten
        frames, and a genuinely hung one -- a raw ``$DB`` sprite number sends the
        main loop into a loop it never leaves -- spends that in a few
        milliseconds rather than waiting out a wall-clock deadline.

        Work RAM rather than bank ``$00`` ``$2000``, which is where smw-editor
        puts its stub: theirs is a synthetic memory, ours is a real SNES bus,
        and ``$002000`` there is PPU register space that will not execute.

        **Interrupts still run.** A real core keeps servicing NMI and IRQ while
        the routine executes, which a bare interpreter does not have to think
        about -- so a caller that cares about what the frame's handler does to
        OAM should make the call immediately after :meth:`step_frame`, while
        the whole frame is still ahead of it.

        **The entry state is pinned, not inherited.** A paused machine is
        stopped wherever it happened to be, and some of the time that is inside
        the NMI handler: measured on a level load, most stops are the main
        loop's idle spin at ``$00806C`` with ``ps=$32`` and an empty stack, but
        a few are ``$00A3xx`` with ``ps=$14`` -- a **16-bit accumulator** -- and
        ``sp=$01F1``, fourteen bytes deep in the interrupt's own frame. Copying
        that wholesale runs the routine in the wrong register widths on a stack
        that is not its, and a 65816 routine given the wrong widths reads and
        writes twice or half what it means to. Measured, the sprite capture hung
        outright on four loads in sixty that way and on none once these were
        pinned.

        So the entry gets what the game's own callers have: native mode, 8-bit
        accumulator and index, ``DBR=$00``, the stack where the console boots
        it, and a CPU that is *running* -- not still inside the ``WAI`` a pause
        can land on, which with interrupts silenced would execute nothing at
        all (:data:`CALL_ENTRY_STOP_STATE`). Everything is put back afterwards,
        so the interrupted code resumes with its own frame intact.

        **``direct_page`` is a fact about the base, and defaults to a console's
        zero.** It is a parameter rather than a constant because a cartridge
        with a coprocessor need not keep the direct page on page zero: SA-1 Pack
        sets ``D=$3000`` at boot and *leaves the game's direct-page accesses
        unrewritten*, so the whole of ``$7E:0000-$7E:00FF`` is reached through
        ``D`` alone. Measured on a running ``sa1/U``, ``D=$3000``. Entering a
        routine there with a console's zero is silent and total: every ``LDA
        $19`` in it reads a byte of the right number out of the wrong memory.
        See :attr:`smw_tools.ram_map.RamMap.direct_page`.

        **``A``, ``X`` and ``Y`` are pinned too, and ``X`` is the load-bearing
        one.** A 65816 routine takes its arguments in the registers, and the
        cartridge's sprite routines take the *slot index* in ``X`` -- Bank ``$0C``
        calls ``InitializeNormalSpriteRAMTables`` with ``LDX #$00`` immediately
        before the ``JSL``, and ``ClearTables`` indexes all forty of its stores
        with it. Inheriting ``X`` from a paused machine (measured at ``$0006``
        and ``$0008`` on some loads) therefore clears a different slot's tables
        than the one the probe set up. Zeroing all three took three of four
        levels from two-to-four distinct sprite captures per twelve loads to
        one.

        Registers are put back afterwards -- **except the cycle counter, which
        is left where the machine has got to.** It is part of the same struct,
        so writing the entry state back wholesale rewound the emulator's own
        clock by however long the routine took, twice per call. Nothing was
        measured breaking, but a core schedules its PPU, DMA and interrupts
        against that number and it is not ours to move.

        Whatever the routine did to memory stays, which is the entire point;
        restore a savestate to undo that.
        """
        self.halt()
        self._write_bytes(
            MemoryType.SNES_WORK_RAM, CALL_STUB & 0xFFFF, call_stub(address)
        )
        self.write(MemoryType.SNES_WORK_RAM, CALL_DONE & 0xFFFF, 0x00)

        saved = self.cpu_state()
        entry = CpuState.from_buffer_copy(bytes(saved))
        entry.address = CALL_STUB
        entry.ps = CALL_ENTRY_PS
        entry.sp = CALL_ENTRY_SP
        entry.d = direct_page
        entry.dbr = 0x00
        entry.emulation_mode = False
        entry.stop_state = CALL_ENTRY_STOP_STATE
        entry.a = entry.x = entry.y = 0x0000
        # A halt that landed on a frame boundary -- which is where step_frame
        # always stops -- leaves the VBlank NMI latched, and an entry that
        # inherits the latch takes the interrupt before the stub's first
        # instruction. This game runs its whole frame from the NMI handler, so
        # that is a frame of the game over whatever half-written state the
        # caller has staged. The latch is the machine's, not the routine's:
        # cleared here, and put back with the rest of the saved state after.
        entry.nmi_flag_counter = 0
        entry.need_nmi = False
        entry.irq_source = 0
        self.set_cpu_state(entry)

        started = time.monotonic()
        checked = started
        last_count, last_moved = saved.cycle_count, started
        try:
            self.start()
            while True:
                if self.finished(CALL_DONE):
                    return
                if self.broke_on_brk:
                    # A routine that hit a BRK is not slow, it is stopped --
                    # and the evidence is gathered here, before the `finally`
                    # below puts the caller's registers back over it.
                    raise CoreBroke(
                        f"{hexnum(address, 6)} hit a BRK", self.take_break()
                    )
                now = time.monotonic()
                if now - checked >= CALL_PROGRESS_CHECK:
                    checked = now
                    count = self.cpu_state().cycle_count
                    ran = count - saved.cycle_count
                    # The spin after the routine burns cycles too, so a poll the
                    # host was late to make can spend the budget on an idle
                    # machine. The flag is the authority; the budget only says
                    # when to go and ask it one last time.
                    if ran > budget and not self.finished(CALL_DONE):
                        raise EmulatorUnavailable(
                            f"{hexnum(address, 6)} ran {ran} cycles without returning"
                        )
                    if ran > budget:
                        return
                    # A machine that froze -- a WAI with interrupts off, or a
                    # core that never started executing -- never spends the
                    # budget, so a frozen cycle counter is its own deadline.
                    # Without this the poll spins until the supervisor's
                    # timeout kills the whole worker for what one retry would
                    # have fixed. One guard covers both cases; the message
                    # separates "never ran" from "ran and stopped".
                    if count != last_count:
                        last_count, last_moved = count, now
                    elif now - last_moved > CALL_STALL:
                        raise EmulatorUnavailable(
                            f"the core did not execute within {CALL_STALL:g}s"
                            f" of a call to {hexnum(address, 6)}"
                            if not ran
                            else f"{hexnum(address, 6)} stopped executing"
                            f" after {ran} cycles"
                        )
                time.sleep(CALL_POLL)
        finally:
            # Halted rather than paused: `Pause` returns while the emulation
            # thread runs on to a boundary, so the registers below would be
            # written under a machine that is still executing and the clock
            # they are stamped with sampled off one. See :meth:`halt`.
            self.halt()
            # The registers as they were, on the clock as it now is.
            restored = CpuState.from_buffer_copy(bytes(saved))
            restored.cycle_count = self.cpu_state().cycle_count
            self.set_cpu_state(restored)

    def finished(self, flag: int) -> bool:
        """Whether the stub has raised ``flag`` -- one byte, read while running."""
        return self.read(MemoryType.SNES_WORK_RAM, flag & 0xFFFF) == CALL_DONE_MARK

    def silence_interrupts(self) -> None:
        """Turn NMI, IRQ and automatic joypad reading off until a state is
        restored.

        For :meth:`call`, which leaves interrupts running: a routine driven out
        of band is *not* where the console's own caller ran it, so a VBlank can
        land in the middle of it. Measured on the sprite capture, that is the
        difference between a stable answer and a wrong one -- across 100 probes
        of level ``$002``, none of the 66 that no interrupt reached came back
        differently and two of the 34 that one did, with one dolphin credited
        with another sprite's tiles.

        **Run as code, not written through the debugger.** A debug write to
        ``$4200`` does not reach the register: measured, NMIs kept arriving at
        the same rate afterwards, while running the store stopped them dead --
        zero handler entries in 50 ms against six.

        **This also drains a pending one.** An interrupt already latched when
        the probe starts is serviced on the first instruction the machine
        executes, whatever ``$4200`` says by then, so calling this *before* the
        setup writes is what makes that harmless: the handler runs here, where
        there is nothing yet to disturb.

        There is no matching "on" -- the caller restores a savestate, which puts
        the register back to whatever it really was rather than to a value this
        would have to guess.
        """
        self._run_interrupt_stub(0x00)

    def resume_interrupts(self, value: int) -> None:
        """Write ``value`` to ``$4200`` as code -- the "on" switch
        :meth:`silence_interrupts` deliberately lacks.

        For a caller that ran a masked call chain and wants the game's own
        interrupt setting back *without* restoring a savestate: with ``$4200``
        still clear, no VBlank can beat this stub's first instruction, so the
        entry is safe by construction. The spin after it runs with interrupts
        live, so anything the next frame must not disturb should be written
        before this is called.
        """
        self._run_interrupt_stub(value)

    def _run_interrupt_stub(self, value: int) -> None:
        """Write ``value`` to ``$4200`` by running a stub, not by a debug write.

        A debug write to that register does not reach it -- see
        :meth:`silence_interrupts` for the measurement.
        """
        self._write_bytes(
            MemoryType.SNES_WORK_RAM, INTERRUPT_STUB & 0xFFFF, interrupt_stub(value)
        )
        self.call(INTERRUPT_STUB)

    def _await(self, condition, timeout: float, what: str) -> None:
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if condition():
                return
            time.sleep(0.0002)
        raise EmulatorUnavailable(
            f"the core did not {what} within {timeout:g}s of a frame step"
        )

    @contextmanager
    def running_free(self) -> Iterator[None]:
        """Run the emulator for the duration of the block, then pause again.

        Paired so that an exception in the polling loop cannot leave the core
        running flat out in the background.

        Started rather than merely resumed: a swallowed resume here would leave
        the block waiting out its whole budget on a machine that never moved,
        which for the level load is a five-second failure reported as "the cart
        did not reach a loaded level".
        """
        self.start()
        try:
            yield
        finally:
            self.pause()

    # -- memory ------------------------------------------------------------

    def memory_size(self, memory: MemoryType) -> int:
        return int(self._lib.GetMemorySize(int(memory)))

    def read(self, memory: MemoryType, address: int) -> int:
        return int(self._lib.GetMemoryValue(int(memory), address))

    def write(self, memory: MemoryType, address: int, value: int) -> None:
        self._lib.SetMemoryValue(int(memory), address, value & 0xFF)

    def access_stamps(
        self, memory: MemoryType, offset: int, length: int, stamp: int
    ) -> array:
        """One column of the access counters, as master-clock stamps.

        ``stamp`` picks the column: :data:`READ_STAMP`, :data:`WRITE_STAMP` or
        :data:`EXEC_STAMP`. The result is indexed by address, from ``offset``.

        **This is a read of bookkeeping the core is already keeping**, not a new
        observation -- so unlike the trace logger it costs nothing while the
        machine runs and only the copy when it stops. One ``memcpy`` out of the
        core and one strided slice; nothing per-address is formatted or parsed.
        """
        buffer = (ctypes.c_uint8 * (length * COUNTER_SIZE))()
        self._lib.GetMemoryAccessCounts(offset, length, int(memory), buffer)
        words = array("Q")
        words.frombytes(bytes(buffer))
        return words[stamp::COUNTER_WORDS]

    @property
    def has_write_log(self) -> bool:
        """Whether this core carries the write-log patch's exports."""
        return self._write_log_capacity is not None

    def set_write_log_range(
        self, memory: MemoryType, offset: int, length: int, capacity: int
    ) -> None:
        """Log every write into ``[offset, offset+length)`` of ``memory``.

        What the log adds over the counters is *history*: a counter keeps one
        write stamp per address, the log keeps every write with its master
        clock, which is what recovers a cell written by one object and drawn
        over by a later one. ``capacity`` bounds the core-side buffer; a run
        that exceeds it sets the overflow flag :meth:`write_log` reports
        instead of wrapping, so a truncated answer can never pass as a whole
        one. The registration survives savestate restores; the entries do not,
        exactly as the counters are zeroed.
        """
        if not self.has_write_log:
            raise EmulatorUnavailable("this core does not carry the write log")
        self._lib.SetWriteLogRange(int(memory), offset, length, capacity)
        self._write_log_capacity = capacity

    def write_log(self) -> tuple[list[tuple[int, int]], bool]:
        """Every logged write since the last reset, in order, plus overflow.

        Entries are ``(address, master clock)`` with the address absolute in
        the registered memory, the same numbering the counters use. Sized to
        the registered capacity so one call reads a consistent snapshot; like
        the counters, it is meant to be read while the machine is stopped.
        """
        if not self._write_log_capacity:
            raise EmulatorUnavailable("no write log range is registered")
        overflow = ctypes.c_uint32(0)
        buffer = (ctypes.c_uint8 * (self._write_log_capacity * 16))()
        count = self._lib.GetWriteLog(buffer, ctypes.byref(overflow))
        words = array("Q")
        words.frombytes(bytes(buffer[: count * 16]))
        entries = [
            (words[i + 1] & 0xFFFFFFFF, words[i]) for i in range(0, len(words), 2)
        ]
        return entries, bool(overflow.value)

    def read_all(self, memory: MemoryType) -> bytes:
        """Copy an entire memory out in one call.

        One ``GetMemoryState`` beats a loop of ``GetMemoryValue``: the per-call
        cost dominates, and reading 64 KB of VRAM a byte at a time through
        ctypes is slower than the level load it follows.
        """
        size = self.memory_size(memory)
        buffer = (ctypes.c_uint8 * size)()
        self._lib.GetMemoryState(int(memory), buffer)
        return bytes(buffer)

    def write_all(self, memory: MemoryType, data: bytes) -> None:
        buffer = (ctypes.c_uint8 * len(data)).from_buffer_copy(data)
        self._lib.SetMemoryState(int(memory), buffer, len(data))

    def patch_rom(self, patches: dict[int, bytes]) -> None:
        """Apply byte edits to the loaded cartridge image, in memory only.

        This is the injection channel: the ROM on disk is untouched and no
        rebuild happens, so a preview costs a level load rather than an asar
        pass. Offsets are into the headerless image, the same numbering
        ``smw_tools`` uses.
        """
        for offset, data in patches.items():
            self._write_bytes(MemoryType.SNES_PRG_ROM, offset, data)

    def _write_bytes(
        self, memory: MemoryType, offset: int, data: Sequence[int]
    ) -> None:
        """Write consecutive bytes, one debugger call each -- there is no bulk
        write below a whole memory."""
        for n, byte in enumerate(data):
            self.write(memory, offset + n, byte)

    # -- savestates --------------------------------------------------------

    def save_state(self, path: Path) -> None:
        self._lib.SaveStateFile(str(path).encode())

    def load_state(self, path: Path) -> None:
        self._lib.LoadStateFile(str(path).encode())

    # -- tracing -----------------------------------------------------------

    @contextmanager
    def tracing(
        self,
        path: Path,
        condition: str,
        columns: str,
        cpus: Sequence[int] = (CPU_TYPE_SNES,),
    ) -> Iterator[None]:
        """Log the instructions matching ``condition`` to ``path`` for the block.

        The trace logger is how the editor finds out *which code did what* --
        which object drew a tile, which routine touched an address. It is the
        only mechanism the core offers that records that losslessly without
        stopping the emulator: a breakpoint costs milliseconds per hit, and the
        event viewer's log is cleared every frame and only ever handed back in
        the slice a UI would draw.

        Rows land in the file in **execution order**, which is the whole point.
        Nothing here has to reason about time, and it must not try to: the
        trace's own clock (``CycleCount``, the CPU's) and the one the memory
        counters stamp with (the master clock) advance at a ratio that changes
        with every memory region the CPU touches, so the two cannot be compared.
        Order is the only sound relation between two rows.

        ``condition`` is filtered on the instruction fetch, so it can name
        ``opPc`` but cannot ask about the target of a store; select the code and
        sort out what it wrote when parsing. Paired so a caller cannot leave the
        logger running, which would keep writing a file for the rest of the
        session.

        **``cpus`` is which processors are logged, and on a cartridge with a
        coprocessor it is the whole question.** The options are per ``CpuType``
        and the rows land in one file in execution order regardless, so adding
        one costs a second ``SetTraceOptions``. A cartridge that has no such
        processor is unharmed by being asked about it -- the options are stored
        against a CPU that never executes -- which is what lets a caller pass
        the same pair for every base.

        **The file is not what this costs, and a narrower condition is not
        cheaper.** Measured on a level load tracing bank ``$0D`` -- 37k rows,
        0.8 MB -- of the ~60 ms the trace adds, at most ~15 is writing the file
        and the rest is paid whatever the condition says: the core disassembles
        *every* executed instruction while the logger is enabled, then evaluates
        the whole condition on it, with no short-circuit. So a condition that
        selects fewer rows makes every instruction more expensive and comes out
        slower overall. ``GetExecutionTrace`` reads the same rows from memory
        instead of a file, and is not offered here for the same reason plus one
        worse: its ring holds 30,000 rows, which this trace overflows. The
        numbers are in `docs/editor/emulator-worker.md`.
        """
        options = TraceLoggerOptions()
        options.enabled = True
        options.condition = condition.encode()
        options.format = columns.encode()
        path.parent.mkdir(parents=True, exist_ok=True)
        for cpu in cpus:
            self._lib.SetTraceOptions(cpu, options)
        self._lib.StartLogTraceToFile(str(path).encode())
        try:
            yield
        finally:
            self._lib.StopLogTraceToFile()
            options.enabled = False
            for cpu in cpus:
                self._lib.SetTraceOptions(cpu, options)
