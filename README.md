# Installation

Before you can use this tool you will need to have 3 things installed:
- python
- poppler
- the [`google-drive-ocr`](https://pypi.org/project/google-drive-ocr/) package
  for python (it ships a CLI called `google-ocr`)

You'd also need to have the path to the `google-ocr` binary included in your
system PATH variable so that it can be called from any directory.

## Recommended install for `google-ocr` (portable)

The "Quick Snip OCR" feature below is launched by macOS Shortcuts, which
does **not** read your interactive shell profile (`.zshrc`, `.bashrc`).
Several Python installers put binaries in locations that are only visible
to interactive shells (`asdf`, `pyenv`, `mise` shims…), so a script
launched by Shortcuts may not find `google-ocr` even though it works
fine in your terminal.

To avoid this, the most reliable install is **`pipx`**, which puts the
binary at `~/.local/bin/google-ocr` — a path that both the terminal and
GUI launchers see:

```sh
brew install pipx
pipx ensurepath
pipx install google-drive-ocr
```

If you prefer another installer (asdf / pyenv / mise / Homebrew / Conda),
the snip script already probes their standard shim/bin locations, so it
should "just work". If it doesn't, you have two escape hatches:

1. Export `TIBETAN_OCR_BIN` in your environment pointing to the binary's
   absolute path (e.g. in your shortcut's Run Shell Script action):
   ```sh
   export TIBETAN_OCR_BIN="$HOME/.asdf/shims/google-ocr"
   ```
2. Symlink the binary into a universally-visible location:
   ```sh
   sudo ln -s "$(which google-ocr)" /usr/local/bin/google-ocr
   ```

# Usage

👋 If it's the first time you use TibetanOCR, please refer to the 
[First use](#first-use) section below.

## Processing images

1. Put all your images as .jpg files in the `images` folder.
2. Click on the file appropriate to your system:
   1. On Mac/Linux: `process_images.command`
   2. On Windows: `process_images.bat`
3. Wait until the script finishes
4. Enter the `images` folder
5. See the result in the `output.txt` file

⚠️ Don't work directly on `output.txt` but move or copy it somewhere else because
  it will be overriden the next time you use this tool!


## Processing a PDF

1. Copy your PDF in the `pdf` folder and rename your PDF as `input.pdf`.
2. Click on the file appropriate to your system:
   1. On Mac/Linux: `process_pdf.command`
   2. On Windows: `process_pdf.bat`
3. Enter the `pdf` folder
4. See the result in the `output.txt` file

⚠️ The process will generate a lot of temporary files in the `pdf` folder so
  don't panic, just wait, the temporary files will be cleaned up at the end.
        
⚠️ Don't work directly on `output.txt` but move or copy it somewhere else because
  it will be overriden the next time you use this tool!


## Quick Snip OCR (macOS, keyboard shortcut)

A CleanShot-style workflow: press a keyboard shortcut, draw a rectangle on
screen, the captured image is OCR'd through Google Drive, and the
recognized text is copied to your clipboard.

### One-time setup

1. Run `process_images.command` at least once first so Google authentication
   completes and `client_secret.json` is created at the project root.
2. Double-click `install_snip_shortcut.command`. It will:
   - Make `snip_ocr.sh` executable
   - Check that `google-ocr` and `client_secret.json` can be found
   - Copy the absolute path of `snip_ocr.sh` to your clipboard
   - Open the Shortcuts app
3. In the Shortcuts app:
   1. Click **+** to create a new shortcut and name it e.g. *Tibetan Snip OCR*.
   2. Add the action **Run Shell Script** and configure it:
      - **Shell:** `zsh`
      - **Input:** no input (or leave the default — the script ignores it)
      - **Script:** paste (⌘V) the path — that is the full content of the
        action.
   3. Open the **Details** panel (top-right icon) and click
      **Add Keyboard Shortcut** — pick e.g. `⌃⌥⌘T`.
4. The first time you trigger the shortcut, macOS will ask Shortcuts.app for
   **Screen Recording** permission (needed by `screencapture`). Grant it in
   *System Settings → Privacy & Security → Screen Recording*, then quit and
   reopen Shortcuts.app.

> Why can't this be fully automated? macOS does not allow keyboard shortcuts
> to be assigned to a Shortcut programmatically — that final step must be
> done in the Shortcuts UI. Everything else is handled by the installer.

### Usage

1. Press your chosen keyboard shortcut (e.g. `⌃⌥⌘T`).
2. Draw a rectangle over the Tibetan text.
3. A first notification says "OCR in progress..." — the round-trip through
   Google Drive typically takes 3–8 seconds.
4. A second notification says "Text copied to clipboard ✓". Paste anywhere
   with ⌘V.

Press Escape during step 2 to cancel without doing anything.

### Troubleshooting

- **"google-ocr not found"**: see the *Recommended install for `google-ocr`*
  section above, or set `TIBETAN_OCR_BIN` in the Run Shell Script action.
- **"client_secret.json missing"**: run `process_images.command` once first
  (even with an empty `images/` folder) to trigger the Google login flow.
- **No notifications appear**: check *System Settings → Notifications →
  Script Editor / Shortcuts* is allowed to show notifications.
- **The selection rectangle doesn't appear**: Screen Recording permission
  for Shortcuts.app is missing — grant it and restart Shortcuts.


## First use

When running one of the the two scripts for the first time, your web browser
will be opened and will ask you to login to one of your Google accounts.
This is totally normal since it needs to have permission to access your Google
Drive to perform the OCR. So when asked just select the Google account of your
choice, type your password if you're not already logged in, and validate.

It will then show you a warning saying that Google did not validate this
application. This is also normal since we are using some kind of Google
developers tools without wanting to register an actual application. So just
click the gray link somewhere (on the bottom left in Chrome) that says
something like « Advanced settings », and then on « Access TibetanOCR ».

You will then see a message saying that everything worked and that you can now
close the web page.

Coming back to the terminal you will see that the OCR process is now underway
or already finished. Go to your `images/` or `pdf/` directory to find the
`output.txt` file with the OCRed text.
