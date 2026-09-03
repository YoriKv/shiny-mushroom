"""What a ``BRK`` says, and how it reads.

A ``BRK`` is the 65816's software interrupt and the way a hack says "this
should never have happened". The instruction is **two bytes** -- the opcode
``$00`` and a second byte the processor fetches and then ignores -- so the
second byte costs nothing and means whatever the code that wrote it meant. By
convention it is an exception number: the BRK Exception Handler patch that
hacks put in their cartridges reads it back off the stack and looks it up in a
table of 256 messages the author fills in, so ``BRK #$01`` at the point of
failure puts that author's own sentence on the screen.

This is that handler's report, gathered from the *emulator* instead: the editor
runs the cartridge in a Mesen core that stops at a ``BRK`` before it executes
(:mod:`shiny_mushroom.emu.core`), so everything the patch preserves by hand --
the registers, the layer mirrors, the stack -- is simply read off the stopped
machine, exactly as it stood. Nothing is patched into the cartridge and nothing
is assembled: a project needs no handler in it to get one of these.

**The message is the one thing that cannot be read off the machine.** The table
lives in whatever handler the cartridge carries, and a cartridge without one
carries no table at all -- so what is shown is the number and the handler's own
default sentence, plus what the number *is*. That is more than the game itself
would have said, and it is honest about the part nobody here can know.

Qt-free and core-free, because both ends need it: the worker builds one beside
the emulator, the editor's dialog shows it, and the pipe between them carries
:meth:`BrkReport.as_dict`.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from shiny_mushroom.hexnum import hexnum

#: What the BRK Exception Handler's own table says for every entry it has not
#: been given a message for -- which, in a cartridge that carries no handler,
#: is all 256 of them.
UNKNOWN_EXCEPTION = "An unknown exception has occurred"

#: The 65816's status bits, high to low, as the letter each is written with.
#: Upper case where the bit is set, lower where it is clear, which is how every
#: SNES debugger spells a status byte.
STATUS_FLAGS = "NVMXDIZC"

#: Where a SNES boots its stack, and the last byte a stack dump can reach.
STACK_TOP = 0x01FF

#: The window the handler patch dumps -- and the page a 65816 stack normally
#: lives in. A stack pointer outside it is worth saying out loud, which is what
#: the patch's own STACK OVERFLOW and STACK UNDERFLOW lines do.
STACK_PAGE = (0x01C0, STACK_TOP)

#: How many bytes of stack a report carries at most. The dump is what was
#: pushed and not yet pulled, so it is short in a healthy program and enormous
#: in one that has just run away -- and a runaway is exactly when this is read.
MAX_STACK = 64


@dataclass(frozen=True)
class BrkReport:
    """One ``BRK``, as the machine stood when it was about to execute.

    Every field is read from the stopped core except :attr:`label` and
    :attr:`during`, which are the editor's own: what it knows about the
    cartridge, and what it was doing when the cartridge stopped.
    """

    #: The address of the ``BRK`` itself, bank included -- not the return
    #: address the instruction would have pushed.
    address: int

    #: The byte after the opcode: the exception number, whatever the code that
    #: wrote it takes that to mean.
    signature: int

    a: int
    x: int
    y: int

    #: The direct page register, and the data bank -- ``D`` and ``B`` as the
    #: handler patch's screen labels them.
    d: int
    db: int

    #: The stack pointer, before the ``BRK`` pushed anything.
    sp: int

    #: The processor status byte. :meth:`flags` spells it.
    ps: int

    #: Whether the processor was in emulation mode, which changes what ``M``
    #: and ``X`` mean and where the stack lives.
    emulation: bool

    #: Which processor executed it: ``"SNES"``, or ``"SA-1"`` on a cartridge
    #: whose coprocessor ran the code.
    cpu: str = "SNES"

    #: ``$7E0100``, the game mode, and ``$7E0019``, the powerup -- the two
    #: bytes of the game's own state the handler's screen carries.
    game_mode: int = 0
    powerup: int = 0

    #: The layer position mirrors, ``(x, y)`` for layers 1, 2 and 3 --
    #: ``$1A``/``$1C``, ``$1E``/``$20``, ``$22``/``$24``.
    layers: tuple[tuple[int, int], ...] = ()

    #: The stack as it stood, from :attr:`stack_at` upward: what had been
    #: pushed and not yet pulled, capped at :data:`MAX_STACK` bytes.
    stack: bytes = b""
    stack_at: int = 0

    #: Whether the whole of the used stack is in :attr:`stack`, or the cap cut
    #: it short.
    stack_complete: bool = True

    #: The label the address is inside, from the project's symbol file, and how
    #: far into it -- the editor fills this in, since the worker has no symbols.
    label: str = ""
    label_offset: int = 0

    #: What the editor was doing when this arrived: ``"level $105"``, ``"sprite
    #: $2E"``, ``"the world map"``. Free text, shown as written.
    during: str = ""

    #: Anything else worth carrying, by name -- kept so a caller can attach the
    #: one fact its own path knows without a field per path.
    extra: dict[str, Any] = field(default_factory=dict)

    # -- reading it --------------------------------------------------------

    @property
    def message(self) -> str:
        """The sentence for this exception number.

        :data:`UNKNOWN_EXCEPTION` for every number, because the table that
        would say otherwise is the cartridge author's and lives in a handler
        the editor does not run -- see the module docstring.
        """
        return UNKNOWN_EXCEPTION

    @property
    def where(self) -> str:
        """The address, with the label it is inside where one is known."""
        at = hexnum(self.address, 6)
        if not self.label:
            return at
        if not self.label_offset:
            return f"{at} ({self.label})"
        return f"{at} ({self.label}+{hexnum(self.label_offset)})"

    def flags(self) -> str:
        """The status byte as its letters, set ones in upper case."""
        return "".join(
            letter if self.ps & (0x80 >> bit) else letter.lower()
            for bit, letter in enumerate(STATUS_FLAGS)
        )

    @property
    def stack_note(self) -> str:
        """What is odd about where the stack pointer is, if anything.

        The handler patch says STACK OVERFLOW and STACK UNDERFLOW for a pointer
        outside the page it dumps; this says which way and leaves the drama to
        the reader.
        """
        low, high = STACK_PAGE
        if self.sp < low:
            return f"below {hexnum(low, 4)}: the stack has run deeper than a page"
        if self.sp > high:
            return f"above {hexnum(high, 4)}: more has been pulled than pushed"
        return ""

    def as_text(self) -> str:
        """The whole report as text, for the dialog's Copy button.

        One block, in the order the handler's screen puts it, so a report
        pasted into a bug thread reads like the screen somebody else's
        cartridge would have shown.
        """
        lines = [
            f"BRK {hexnum(self.signature)} at {self.where}",
            self.message,
            "",
            f"A  {hexnum(self.a, 4)}   X  {hexnum(self.x, 4)}   Y  {hexnum(self.y, 4)}",
            f"D  {hexnum(self.d, 4)}   B  {hexnum(self.db)}     "
            f"S  {hexnum(self.sp, 4)}",
            f"P  {hexnum(self.ps)}  {self.flags()}"
            + ("  (emulation mode)" if self.emulation else ""),
        ]
        if self.cpu != "SNES":
            lines.append(f"Ran on the {self.cpu}")
        lines.append("")
        for number, (x, y) in enumerate(self.layers, start=1):
            lines.append(f"Layer {number}  {hexnum(x, 4)} {hexnum(y, 4)}")
        lines.append(
            f"Powerup  {hexnum(self.powerup)}   Game mode  {hexnum(self.game_mode)}"
        )
        if self.during:
            lines.append(f"During  {self.during}")
        if self.stack:
            lines += ["", self.stack_heading()]
            lines += [f"  {row}" for row in self.stack_rows()]
        return "\n".join(lines)

    def stack_heading(self) -> str:
        """The line above the dump: what range it covers, and any note."""
        end = self.stack_at + len(self.stack) - 1
        span = (
            f"Stack {hexnum(self.stack_at, 4)}-{hexnum(end, 4)} "
            f"({len(self.stack)} bytes"
        )
        span += ", cut short)" if not self.stack_complete else ")"
        note = self.stack_note
        return f"{span} -- the pointer is {note}" if note else span

    def stack_rows(self, per_row: int = 8) -> list[str]:
        """The dump, ``per_row`` bytes to a line, each line addressed."""
        rows = []
        for start in range(0, len(self.stack), per_row):
            chunk = self.stack[start : start + per_row]
            rows.append(
                f"{hexnum(self.stack_at + start, 4)}: "
                + " ".join(f"{byte:02X}" for byte in chunk)
            )
        return rows

    # -- crossing the pipe -------------------------------------------------

    def as_dict(self) -> dict[str, Any]:
        """This report as JSON, for the worker's reply."""
        return {
            "address": self.address,
            "signature": self.signature,
            "a": self.a,
            "x": self.x,
            "y": self.y,
            "d": self.d,
            "db": self.db,
            "sp": self.sp,
            "ps": self.ps,
            "emulation": self.emulation,
            "cpu": self.cpu,
            "game_mode": self.game_mode,
            "powerup": self.powerup,
            "layers": [list(pair) for pair in self.layers],
            "stack": self.stack.hex(),
            "stack_at": self.stack_at,
            "stack_complete": self.stack_complete,
            "label": self.label,
            "label_offset": self.label_offset,
            "during": self.during,
            "extra": dict(self.extra),
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> BrkReport:
        """The other end of :meth:`as_dict`."""
        return cls(
            address=int(data["address"]),
            signature=int(data["signature"]),
            a=int(data["a"]),
            x=int(data["x"]),
            y=int(data["y"]),
            d=int(data["d"]),
            db=int(data["db"]),
            sp=int(data["sp"]),
            ps=int(data["ps"]),
            emulation=bool(data.get("emulation", False)),
            cpu=str(data.get("cpu", "SNES")),
            game_mode=int(data.get("game_mode", 0)),
            powerup=int(data.get("powerup", 0)),
            layers=tuple((int(x), int(y)) for x, y in data.get("layers", ())),
            stack=bytes.fromhex(data.get("stack", "")),
            stack_at=int(data.get("stack_at", 0)),
            stack_complete=bool(data.get("stack_complete", True)),
            label=str(data.get("label", "")),
            label_offset=int(data.get("label_offset", 0)),
            during=str(data.get("during", "")),
            extra=dict(data.get("extra", {})),
        )

    def named(self, label: str, offset: int) -> BrkReport:
        """This report with the label the editor resolved for its address."""
        return type(self)(**{**vars(self), "label": label, "label_offset": offset})

    def about(self, during: str) -> BrkReport:
        """This report with what was being done when it arrived."""
        return type(self)(**{**vars(self), "during": during})


class BrkRaised(RuntimeError):
    """A request could not be answered because the cartridge hit a ``BRK``.

    Carries the report, which is the whole point of it: the message a caller
    would print says the same thing in one line, and everything else the editor
    shows is in :attr:`report`.
    """

    def __init__(self, report: BrkReport) -> None:
        super().__init__(
            f"the cartridge hit BRK {hexnum(report.signature)} at "
            f"{hexnum(report.address, 6)}"
        )
        self.report = report


__all__ = [
    "MAX_STACK",
    "STACK_PAGE",
    "STACK_TOP",
    "STATUS_FLAGS",
    "UNKNOWN_EXCEPTION",
    "BrkRaised",
    "BrkReport",
]
