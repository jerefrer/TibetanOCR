#!/bin/sh
# Interactive screen snip -> Google Drive OCR -> clipboard.
# Designed to be triggered by a macOS global keyboard shortcut via the
# Shortcuts app (or Automator / Raycast / Hammerspoon).

set -u

cd "$(dirname -- "$0")"
PROJECT_DIR="$(pwd)"

notify() {
  osascript -e "display notification \"$1\" with title \"Tibetan OCR\"" >/dev/null 2>&1 || true
}

# GUI launchers (Shortcuts, Automator) do not load the interactive shell
# profile, so binaries installed via asdf / pyenv / mise / Homebrew / pipx
# are not on PATH by default. Probe common locations.
for p in \
  "$HOME/.asdf/shims" \
  "$HOME/.pyenv/shims" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims" \
  /opt/homebrew/bin \
  /usr/local/bin \
  "$HOME/.local/bin"; do
  [ -d "$p" ] && PATH="$p:$PATH"
done
export PATH

# Escape hatch for unusual installs: users can export TIBETAN_OCR_BIN with
# an absolute path to the google-ocr binary.
OCR_BIN="${TIBETAN_OCR_BIN:-$(command -v google-ocr 2>/dev/null || true)}"

if [ -z "$OCR_BIN" ] || [ ! -x "$OCR_BIN" ]; then
  notify "google-ocr not found. Set TIBETAN_OCR_BIN or add it to PATH."
  exit 1
fi

if [ ! -f "$PROJECT_DIR/client_secret.json" ]; then
  notify "client_secret.json missing in project dir"
  exit 1
fi

TMP_DIR="$(mktemp -d -t tibetan_snip)"
trap 'rm -rf "$TMP_DIR"' EXIT
IMG="$TMP_DIR/snip.jpg"

# Interactive rectangular selection. User can cancel with Esc (no file written).
screencapture -i -t jpg -x "$IMG"
[ -f "$IMG" ] || exit 0

notify "OCR in progress..."

if ! "$OCR_BIN" \
    --client-secret "$PROJECT_DIR/client_secret.json" \
    --image-dir "$TMP_DIR" \
    --extension .jpg \
    --workers 1 \
    --no-keep >/dev/null 2>&1; then
  notify "OCR failed"
  exit 1
fi

# google-ocr writes one .txt per input image into the same directory.
OUT="$(find "$TMP_DIR" -maxdepth 1 -name '*.txt' -print0 | xargs -0 cat)"
if [ -z "$OUT" ]; then
  notify "OCR produced no text"
  exit 1
fi

printf '%s' "$OUT" | LC_CTYPE=UTF-8 pbcopy
notify "Text copied to clipboard ✓"
