"""What a load does when the game does not arrive: waiting, failing, retrying.

Every load in this package -- a level, the overworld, the replay probe -- waits
on the same thing (a game mode reached and then left), fails in the same way and
retries the same flake. The three are here rather than in any one of them so
that all three say it once.
"""

from __future__ import annotations

import logging
from collections.abc import Callable

#: Where a retry reports what it did -- see
#: :data:`shiny_mushroom.emu.smw._log`, which this follows.
_log = logging.getLogger(__name__)


def _through(mode: int) -> Callable[[int], bool]:
    """A wait condition for "the game reached ``mode`` and has now left it".

    Reaching it first is what makes leaving it mean anything: a request has
    only just been written when a wait like this starts, so the game mode is
    still the one before and "not this mode" is true for a reason that has
    nothing to do with the load being finished.
    """
    entered = False

    def done(current: int) -> bool:
        nonlocal entered
        entered = entered or current == mode
        return entered and current != mode

    return done


#: How many times a level request is made before the load is reported as
#: failed. Every attempt after the first starts from the title state, which is
#: the recovery -- see :meth:`SmwLevelLoader._attempting`.
#:
#: Three rather than two because the failure is a property of the host's timing
#: rather than of the request: measured over 144 loads on ``sa1`` with six
#: emulators competing for the machine, one attempt in twelve hung, and two
#: consecutive hangs is what an editor shows the user as an error.
LOAD_ATTEMPTS = 3


class LevelLoadError(RuntimeError):
    """The game did not reach a loaded level within the time allowed."""


def retry_load[T](
    run: Callable[[int], T],
    what: str,
    recover: Callable[[int], None] | None = None,
    then: str = "retrying",
    attempts: int = LOAD_ATTEMPTS,
) -> T:
    """Call ``run(attempt)`` until it stops raising :class:`LevelLoadError`.

    Every load in this package retries the same flake for the same reason -- a
    game mode written into a machine restored mid-frame is sometimes never
    dispatched, and only starting again from an anchor clears it, which is what
    :meth:`SmwLevelLoader._attempting` sets out.

    ``what`` names what is being loaded and ``then`` says what the next attempt
    will do differently; both are for the line a failed attempt logs.
    ``recover`` is what makes the next attempt different, and it runs only when
    there is going to be one -- the last failure is raised as it stands, so a
    load that cannot be made to work is reported rather than swallowed.
    """
    for attempt in range(attempts):
        try:
            return run(attempt)
        except LevelLoadError as failure:
            if attempt == attempts - 1:
                raise
            if recover is not None:
                recover(attempt)
            _log.warning(
                "%s did not load on attempt %d of %d (%s); %s",
                what,
                attempt + 1,
                attempts,
                failure,
                then,
            )
    raise LevelLoadError(f"{what} was not attempted at all")
