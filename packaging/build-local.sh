#!/usr/bin/env bash
#
# build-local.sh — freeze the editor for one platform, the way the release
# workflow freezes it.
#
# The real build happens in CI (.github/workflows/release.yml) on a tag push.
# This runs the same steps on this machine, for when a change has to be seen in
# a frozen build rather than under `uv run shiny-mushroom` — an embedded icon, a
# bundled resource, an import that only fails once PyInstaller has traced it.
#
# Usage:  packaging/build-local.sh <windows|linux> [--zip]
#
# Leaves a portable app folder in dist/shiny-mushroom/. This is not a release:
# nothing here versions, signs or notarises the output, and THIRD-PARTY.md
# inside the build is stamped as a local build so a binary handed to someone
# cannot be taken for a released one.
#
# macOS is deliberately absent. Its leg needs the LSMinimumSystemVersion stamp
# and the re-sign that follows it, both of which only run on a Mac; an untested
# recipe here would be worse than sending the reader to the workflow.

set -euo pipefail

# Locate the repository from the script rather than from git: under WSL
# `git.exe rev-parse` answers in Windows form, which `cd` cannot take.
cd "$(dirname "$0")/.."

SCRIPT_NAME="packaging/$(basename "$0")"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <windows|linux> [--zip]

Freeze the editor with PyInstaller into dist/shiny-mushroom/, mirroring the
matching leg of .github/workflows/release.yml.

  windows     builds the .exe; needs the Windows interpreter (see below)
  linux       builds the ELF, against .venv-linux
  --zip       also package as CI does: dist/shiny-mushroom-<platform>.zip|.tar.gz

PyInstaller is not a cross-compiler — it bundles the interpreter it is running
under. So "windows" has to run Windows Python: from WSL this script reaches it
as uv.exe over interop, and from a Windows shell it is already the default.
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ── Arguments ───────────────────────────────────────────────────────────────
TARGET=""
ZIP=0
while [ $# -gt 0 ]; do
  case "$1" in
    windows|linux) TARGET="$1" ;;
    -z|--zip)      ZIP=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             printf 'error: unexpected argument: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
[ -n "$TARGET" ] || { printf 'error: no target given\n\n' >&2; usage >&2; exit 2; }

# ── Per-target configuration ────────────────────────────────────────────────
# Mirrors the workflow's build matrix; keep the two in step.
case "$TARGET" in
  windows)
    CORE_DIR=windows-x64
    LIB=MesenCore.dll
    SEP=';'
    # Embedded into the .exe and shown in Explorer and the taskbar.
    ICON=(--icon packaging/shiny-mushroom.ico)
    # `env -u`: .envrc exports UV_PROJECT_ENVIRONMENT=.venv-linux for the WSL
    # uv, and handing that to the Windows uv would fill the Linux environment
    # with Windows wheels. Unset, uv.exe takes its default — .venv.
    UV_BIN=uv.exe
    UV=(env -u UV_PROJECT_ENVIRONMENT uv.exe)
    ASAR=(--add-binary "smw/asar.exe;.")
    ;;
  linux)
    CORE_DIR=linux-x64
    LIB=MesenCore.so
    SEP=':'
    # Linux has no build-time icon; the app sets its window icon at runtime.
    ICON=()
    # Named rather than inherited: without direnv loaded, a bare `uv` would
    # target .venv and overwrite the Windows environment.
    UV_BIN=uv
    UV=(env UV_PROJECT_ENVIRONMENT=.venv-linux uv)
    ASAR=(--add-binary "smw/asar:.")
    ;;
esac

command -v "$UV_BIN" >/dev/null 2>&1 \
  || die "$UV_BIN not on PATH. A $TARGET build needs it; see $SCRIPT_NAME --help."

# ── Stage the emulator core ─────────────────────────────────────────────────
# It is moved out of the package for the duration of the build, for the two
# reasons the workflow spells out at length: --add-binary gets it the dependency
# analysis its SDL2/X11/ALSA link chain needs, which --collect-data would not,
# and moving it means only this platform's core ships rather than all four.
CORE=editor/shiny_mushroom/resources/mesen
STAGE=tmp/corestage
HELD=tmp/mesen-held
DEST="shiny_mushroom/resources/mesen/$CORE_DIR"

[ -f "$CORE/$CORE_DIR/$LIB" ] || die \
  "no vendored core at $CORE/$CORE_DIR/$LIB. Run the 'Mesen core' workflow,
       download mesen-cores-all and commit it."

# Whatever happens, put it back: it is tracked, and a tree left short of it
# breaks every other agent's tests with nothing obvious to blame.
restore() {
  if [ -d "$HELD" ]; then
    rm -rf "$CORE"
    mv "$HELD" "$CORE"
  fi
}
trap restore EXIT

rm -rf "$STAGE" "$HELD"
mkdir -p "$STAGE"
cp "$CORE/$CORE_DIR"/* "$STAGE"/
mv "$CORE" "$HELD"

# ── Build ───────────────────────────────────────────────────────────────────
# --windowed: no console window on Windows (a no-op on Linux).
# --collect-data: PyInstaller follows imports only, so the package's data files
# (shiny_mushroom/resources) must be collected explicitly or the frozen app
# starts without its icon or its metadata.
# pyinstaller comes in ephemerally with --with, so it need not sit in the dev
# dependency group and uv.lock.
#
# The disassembly and the assembler go in at the bundle root, because the editor
# assembles a cartridge rather than opening one: `smw_tools.paths.WORK_ROOT` is
# this file's package parent, which in a frozen app is sys._MEIPASS, so `src`,
# `vendor` and `asar` sit beside the collected packages exactly as they sit
# beside `smw_tools` in a checkout. asar is --add-binary for the execute bit.
echo "==> freezing for $TARGET with $UV_BIN"
"${UV[@]}" run --with pyinstaller pyinstaller \
  --name shiny-mushroom --windowed --noconfirm \
  --add-binary "$STAGE/$LIB$SEP$DEST" \
  --add-data "$STAGE/provenance.json$SEP$DEST" \
  "${ASAR[@]}" \
  --add-data "smw/src${SEP}src" \
  --add-data "smw/vendor${SEP}vendor" \
  --add-data "smw/asar-licenses${SEP}asar-licenses" \
  --collect-data shiny_mushroom \
  ${ICON[@]+"${ICON[@]}"} \
  editor/shiny_mushroom/__main__.py

# ── Licence ─────────────────────────────────────────────────────────────────
# The GPL asks every binary handed out to carry the terms, and THIRD-PARTY.md is
# the "clear directions" section 6d wants for the bundled core. Stamp the
# revision so a copy of this folder says what it was built from — a local build
# has no tag to name.
cp LICENSE THIRD-PARTY.md dist/shiny-mushroom/
REVISION="$(git.exe rev-parse HEAD 2>/dev/null || git rev-parse HEAD 2>/dev/null || echo unknown)"
{
  echo
  echo "## This build"
  echo
  echo "- Built locally from revision \`$REVISION\`, not from a release tag."
} >> dist/shiny-mushroom/THIRD-PARTY.md

# ── Package ─────────────────────────────────────────────────────────────────
if [ "$ZIP" -eq 1 ]; then
  case "$TARGET" in
    windows)
      powershell.exe -NoProfile -Command \
        "Compress-Archive -Force -Path dist/shiny-mushroom/* -DestinationPath dist/shiny-mushroom-win.zip"
      echo "packaged dist/shiny-mushroom-win.zip"
      ;;
    linux)
      tar -czf dist/shiny-mushroom-linux.tar.gz -C dist shiny-mushroom
      echo "packaged dist/shiny-mushroom-linux.tar.gz"
      ;;
  esac
fi

echo
echo "built dist/shiny-mushroom/ ($(du -sh dist/shiny-mushroom | cut -f1))"
