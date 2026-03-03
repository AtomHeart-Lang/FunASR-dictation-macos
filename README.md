# SenseVoice Dictation for macOS

A menubar dictation app for macOS:
- Press trigger once to start recording
- Press again to stop
- Transcribe with SenseVoice
- Auto-paste into the active text box

## Features

- Menubar status indicators (off/loading/ready/recording/transcribing/error/updating)
- Keyboard trigger and mouse trigger
- Manual trigger configuration
- Model update from menu (`Update Model`)
- Autostart via LaunchAgent
- Clickable launcher app (Applications + Desktop)
- One-command uninstall and cleanup

## Requirements

- macOS 11+
- Python 3.11+
- Xcode Command Line Tools (`clang`) for launcher generation

Optional:
- `ffmpeg` (not required by this app flow)

## Installation

```bash
./install.sh
```

Default installer actions:
1. Create `.venv`
2. Install Python dependencies from `requirements.txt`
3. Create `config.toml` from `config.example.toml` if missing
4. Pre-download SenseVoice + VAD models
5. Create launcher app in `~/Applications` and Desktop

Installer options:
- `--no-model`
- `--no-launcher`
- `--autostart`

## Run

```bash
./start_app.sh
```

## Menubar States

- `○` OFF
- `…` LOADING
- `⇡` UPDATING
- `✓` READY
- `●` RECORDING
- `↻` TRANSCRIBING
- `!` ERROR

## Menu Items

- `Toggle Dictation`
- `Use Keyboard Trigger`
- `Use Mouse Trigger`
- `Set Keyboard Hotkey`
- `Set Mouse Button`
- `Update Model`
- `Enable Dictation On App Start`
- `Quit App`

## Script Reference

### Core scripts

- `install.sh`: install environment/dependencies and optional setup steps
- `start_app.sh`: start menubar app (single-instance guarded)
- `enable_autostart.sh`: enable LaunchAgent autostart
- `disable_autostart.sh`: disable LaunchAgent autostart
- `create_launcher.sh`: create clickable `.app` launcher
- `remove_launcher.sh`: remove clickable launcher
- `uninstall.sh`: uninstall and cleanup runtime/model/env
- `prepare_release.sh`: clean artifacts and produce release zip

### Uninstall behavior

`./uninstall.sh` removes:
- launch agents
- running app processes
- SenseVoice model cache
- `.venv`
- local logs/locks/runtime config
- launcher apps in Applications/Desktop

Also supports full source removal:

```bash
./uninstall.sh --delete-project-dir
```

## Keyboard Hotkey Token List

### Format

- Use `modifier+key`, e.g. `<ctrl>+a`, `<ctrl>+<left>`, `<cmd>+<shift>+<f8>`

### Modifiers

- `<ctrl>`
- `<alt>`
- `<cmd>`
- `<shift>`

Notes:
- `<option>` is normalized to `<alt>`

### Main keys

Letters:
- `a` `b` `c` `d` `e` `f` `g` `h` `i` `j` `k` `l` `m` `n` `o` `p` `q` `r` `s` `t` `u` `v` `w` `x` `y` `z`

Numbers:
- `0 1 2 3 4 5 6 7 8 9`

Symbols:
- `=` `-` `[` `]` `;` `'` `\\` `,` `.` `/` `` ` ``

Special keys:
- `<space>`
- `<enter>`
- `<tab>`
- `<backspace>`
- `<delete>`
- `<esc>`
- `<left>` `<right>` `<up>` `<down>`
- `<home>` `<end>` `<pgup>` `<pgdn>`

Function keys:
- `<f1>` ... `<f19>`

## Mouse Trigger Token List

Preferred values:
- `left`
- `right`
- `middle`
- `x1`
- `x2`

Equivalent aliases:
- `button0` -> `left`
- `button1` -> `right`
- `button2` -> `middle`
- `button3` -> `x1`
- `button4` -> `x2`
- `primary` -> `left`
- `secondary` -> `right`

Extended buttons:
- `button5` ... `button24`

## Permissions

Grant permissions to the terminal/launcher process:
- Microphone
- Accessibility
- Input Monitoring

## GitHub Sharing

Create release package:

```bash
./prepare_release.sh
```

This generates:
- `sensevoice-dictation-macos-release.zip`

## Chinese Documentation

- `README.zh-CN.md`
