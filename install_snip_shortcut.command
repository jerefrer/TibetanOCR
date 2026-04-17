#!/bin/sh
# One-time setup helper for the snip-to-OCR keyboard shortcut.
# Verifies prerequisites, copies the invocation path to the clipboard,
# and opens Shortcuts.app so you can paste it into a "Run Shell Script"
# action. macOS does not allow programmatic keyboard-shortcut assignment,
# so the final binding step is done in the Shortcuts UI.

set -u

BOLD="\033[1m"; RESET="\033[0m"
GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; CYAN="\033[36m"

ok()   { printf "${GREEN}${BOLD}✓${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}${BOLD}!${RESET} %s\n" "$1"; }
err()  { printf "${RED}${BOLD}✗${RESET} %s\n" "$1"; }
info() { printf "${CYAN}${BOLD}→${RESET} %s\n" "$1"; }

cd "$(dirname -- "$0")"
PROJECT_DIR="$(pwd)"
SCRIPT="$PROJECT_DIR/snip_ocr.sh"

printf "${BOLD}${CYAN}== Tibetan Snip OCR — Shortcut installer ==${RESET}\n\n"

if [ ! -f "$SCRIPT" ]; then
  err "snip_ocr.sh missing in $PROJECT_DIR"
  exit 1
fi
[ -x "$SCRIPT" ] || chmod +x "$SCRIPT"
ok "snip_ocr.sh is executable"

if [ ! -f "$PROJECT_DIR/client_secret.json" ]; then
  warn "client_secret.json missing — run process_images.command once first to authenticate."
else
  ok "client_secret.json found"
fi

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

if command -v google-ocr >/dev/null 2>&1; then
  ok "google-ocr found at $(command -v google-ocr)"
else
  err "google-ocr not found on PATH"
  warn "Install it with:  pipx install google-drive-ocr"
  warn "Or set TIBETAN_OCR_BIN in your environment to its absolute path."
fi

printf "\n${BOLD}Next steps (one-time setup in the Shortcuts app):${RESET}\n"
printf "  1. The path below has been copied to your clipboard.\n"
printf "  2. In Shortcuts.app, click ${BOLD}+${RESET} to create a new shortcut.\n"
printf "  3. Name it e.g. ${BOLD}Tibetan Snip OCR${RESET}.\n"
printf "  4. Add the action ${BOLD}Run Shell Script${RESET}:\n"
printf "       - Shell:  zsh\n"
printf "       - Input:  no input\n"
printf "       - Pass Input: to stdin (or leave default)\n"
printf "       - Script: paste the path below.\n"
printf "  5. Open the shortcut's ${BOLD}Details${RESET} pane (top-right toggle) and\n"
printf "     click ${BOLD}Add Keyboard Shortcut${RESET} — choose e.g. ⌃⌥⌘T.\n"
printf "  6. First run: macOS will ask for ${BOLD}Screen Recording${RESET} permission\n"
printf "     for Shortcuts.app — grant it, then restart Shortcuts.app.\n\n"

printf "${BOLD}Path to paste:${RESET}\n  ${CYAN}%s${RESET}\n\n" "$SCRIPT"

printf '%s' "$SCRIPT" | pbcopy && ok "Path copied to clipboard"

info "Opening Shortcuts.app..."
open -a Shortcuts || warn "Could not open Shortcuts.app automatically."

printf "\n${BOLD}${GREEN}Done.${RESET} Press any key to close this window.\n"
read -n 1 -s
