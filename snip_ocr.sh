#!/bin/sh
# Interactive screen snip -> Google Drive OCR -> clipboard.
# Designed to be triggered by a macOS global keyboard shortcut via the
# Shortcuts app (or Automator / Raycast / Hammerspoon).

set -u

cd "$(dirname -- "$0")"
PROJECT_DIR="$(pwd)"

LOG_DIR="$HOME/Library/Logs/TibetanOCR"
LOG_FILE="$LOG_DIR/snip.log"
mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG_FILE"
}

notify() {
  osascript -e "display notification \"$1\" with title \"Tibetan OCR\"" >/dev/null 2>&1 || true
}

KEEP_TMP=0
fail() {
  msg="$1"
  log "FAIL: $msg"
  KEEP_TMP=1
  notify "$msg — see $LOG_FILE"
  exit 1
}

log "--- run start (pid $$) ---"

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
log "resolved OCR_BIN: ${OCR_BIN:-<empty>}"

if [ -z "$OCR_BIN" ] || [ ! -x "$OCR_BIN" ]; then
  fail "google-ocr not found. Set TIBETAN_OCR_BIN or add it to PATH."
fi

if [ ! -f "$PROJECT_DIR/client_secret.json" ]; then
  fail "client_secret.json missing in project dir"
fi

TMP_DIR="$(mktemp -d -t tibetan_snip)"
trap '[ "$KEEP_TMP" = 1 ] && log "kept temp dir: $TMP_DIR" || rm -rf "$TMP_DIR"' EXIT
IMG="$TMP_DIR/snip.jpg"
log "temp dir: $TMP_DIR"

# Interactive rectangular selection. User can cancel with Esc (no file written).
screencapture -i -t jpg -x "$IMG"
if [ ! -f "$IMG" ]; then
  log "capture cancelled by user"
  exit 0
fi
log "captured image: $(stat -f '%z bytes' "$IMG" 2>/dev/null || echo '?')"

notify "OCR in progress..."

OCR_STATUS=0
"$OCR_BIN" \
    --client-secret "$PROJECT_DIR/client_secret.json" \
    --image-dir "$TMP_DIR" \
    --extension .jpg \
    --workers 1 \
    --no-keep >>"$LOG_FILE" 2>&1 || OCR_STATUS=$?

if [ "$OCR_STATUS" -ne 0 ]; then
  fail "OCR failed (exit $OCR_STATUS)"
fi

# google-ocr writes one .txt per input image into the same directory.
OUT="$(find "$TMP_DIR" -maxdepth 1 -name '*.txt' -print0 | xargs -0 cat)"
if [ -z "$OUT" ]; then
  TXT_COUNT="$(find "$TMP_DIR" -maxdepth 1 -name '*.txt' | wc -l | tr -d ' ')"
  log "no text produced; .txt files found: $TXT_COUNT"
  fail "OCR produced no text"
fi

printf '%s' "$OUT" | LC_CTYPE=UTF-8 pbcopy
log "OK: ${#OUT} chars copied to clipboard"
notify "Text copied to clipboard ✓"
