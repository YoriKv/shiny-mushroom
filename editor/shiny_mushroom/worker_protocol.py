"""The framing that crosses the worker process boundary.

Deliberately not :mod:`pickle`. A pickle stream is executable, and while both
ends of this pipe are ours today, a format that runs arbitrary code on receipt
is the wrong default for a channel whose whole purpose is to contain a process
that might be misbehaving. It is also silently version-coupled: a dataclass that
gains a field breaks unpickling in a way that reads as corruption.

Instead: a JSON header for structure, raw bytes for bulk. A frame is

    4-byte big-endian length, then that many bytes of UTF-8 JSON,
    then, concatenated, the payloads whose lengths the header lists in "blobs".

Keeping VRAM and the tilemap out of the JSON matters -- base64 in a JSON string
would cost about a third more bytes and a copy each way, on the one part of the
message that is actually large.

Outside :mod:`shiny_mushroom.emu`, and standard library only. This is the seam,
not either side of it: ``shiny_mushroom/__main__.py`` reads :data:`WORKER_FLAG`
to decide which process it is *before* anything is loaded that would settle the
question, and a stub worker in the tests speaks the format without a core
anywhere. Importing anything in that package loads the ctypes binding, so
naming the framing must not mean naming a core.
"""

from __future__ import annotations

import json
import struct
from typing import Any, BinaryIO

_LENGTH = struct.Struct(">I")

#: Argument that turns a frozen editor executable into a worker, checked in
#: ``shiny_mushroom/__main__.py`` before Qt is imported.
#:
#: It lives in this leaf module rather than in :mod:`shiny_mushroom.emu.worker`
#: because both ends need it, and importing the worker to get it would mean the
#: child process imports that module twice -- once through the package's
#: ``__init__``, once as ``__main__`` under ``-m`` -- leaving two copies of its
#: state and a RuntimeWarning saying so.
WORKER_FLAG = "--emu-worker"

#: What a worker is asked to be when it opens a ROM, and therefore what kind of
#: core it builds: ``render`` has no renderer, no sound and no input at all,
#: ``play`` has a software renderer and a sound device. Mesen keeps its emulator
#: in a file-scope singleton, so this is settled once per process rather than
#: per request -- which is why testing a level is a second worker.
#:
#: Here rather than in :mod:`shiny_mushroom.emu.worker` for the same reason
#: :data:`WORKER_FLAG` is: both ends need them, and the parent reaching into the
#: child's module to get them would invert the boundary the emulator package is
#: built around.
MODE_RENDER = "render"
MODE_PLAY = "play"

#: Refuse absurd headers rather than allocating on a corrupt or desynchronised
#: stream. Headers are a few hundred bytes.
MAX_HEADER = 1 << 20

#: And the same for a blob length, which is a number a header *claims* rather
#: than one this side computed. The largest payload that crosses the pipe is a
#: cartridge image or a video frame, both well under this.
MAX_BLOB = 1 << 24


class ProtocolError(RuntimeError):
    """The stream ended, desynchronised, or carried something unreadable."""


def write_message(
    stream: BinaryIO, header: dict[str, Any], blobs: list[bytes] | None = None
) -> None:
    blobs = blobs or []
    header = {**header, "blobs": [len(b) for b in blobs]}
    encoded = json.dumps(header, separators=(",", ":")).encode()
    stream.write(_LENGTH.pack(len(encoded)))
    stream.write(encoded)
    for blob in blobs:
        stream.write(blob)
    stream.flush()


def read_message(stream: BinaryIO) -> tuple[dict[str, Any], list[bytes]]:
    """Read one frame. Raises :class:`ProtocolError` at a clean end of stream.

    Every number the header carries about the frame's own shape is checked
    before it is acted on, and a header that fails is a :class:`ProtocolError`
    like any other desynchronised stream. That is what the format promises over
    a pickle: a peer that has gone wrong cannot make this side hang on a read
    with no end, allocate a buffer of its choosing, or raise something the
    caller does not catch.
    """
    size = _read_exactly(stream, _LENGTH.size)
    (length,) = _LENGTH.unpack(size)
    if length > MAX_HEADER:
        raise ProtocolError(
            f"header of {length} bytes is implausible; stream is out of sync"
        )
    try:
        header = json.loads(_read_exactly(stream, length))
    except json.JSONDecodeError as exc:
        raise ProtocolError(f"malformed header: {exc}") from exc
    return header, [_read_exactly(stream, n) for n in _blob_lengths(header)]


def _blob_lengths(header: Any) -> list[int]:
    """The payload sizes ``header`` declares, checked before anything is read.

    A negative length would read to end of stream rather than raise -- a
    :class:`io.BufferedReader` treats a negative count as "everything" -- so an
    unvalidated one is an indefinite hang rather than an error.
    """
    if not isinstance(header, dict):
        raise ProtocolError(f"header is {type(header).__name__}, not an object")
    lengths = header.get("blobs", [])
    if not isinstance(lengths, list):
        raise ProtocolError(f"blob lengths are {type(lengths).__name__}, not a list")
    for length in lengths:
        # `bool` is an `int`, and a payload length is not a flag.
        if isinstance(length, bool) or not isinstance(length, int):
            raise ProtocolError(f"blob length {length!r} is not a number")
        if not 0 <= length <= MAX_BLOB:
            raise ProtocolError(f"blob of {length} bytes is implausible")
    return lengths


def _read_exactly(stream: BinaryIO, count: int) -> bytes:
    """Read exactly ``count`` bytes, or fail.

    A pipe read is free to return short, and treating a short read as the whole
    message is how this kind of code develops rare, unreproducible bugs.
    """
    chunks, remaining = [], count
    while remaining:
        chunk = stream.read(remaining)
        if not chunk:
            raise ProtocolError(
                "the emulator worker closed the connection"
                if not chunks and remaining == count
                else f"stream ended {remaining} bytes into a {count}-byte read"
            )
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)
