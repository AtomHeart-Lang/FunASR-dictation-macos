# FunASR Dictation for macOS

[中文文档](README.zh-CN.md)

## Table of Contents
- [Overview](#overview)
- [DMG Installation](#dmg-installation)
- [Getting Started](#getting-started)
- [Daily Use](#daily-use)
- [Hotkey Setup](#hotkey-setup)
- [Model Config](#model-config)
- [Menubar States](#menubar-states)
- [Developer](#developer)

<a id="overview"></a>
## Overview

FunASR Dictation is a macOS menubar dictation app built on [Fun-ASR-Nano-2512](https://github.com/FunAudioLLM/Fun-ASR).

Core workflow:
- press the trigger once to start recording
- press it again to stop
- transcribe locally on your Mac
- auto-paste into the active text box

Why people use this app instead of built-in dictation or generic tools:
- local inference on your Mac, without a mandatory cloud round-trip
- practical mixed Chinese/English recognition quality for real typing workflows
- global trigger + automatic paste into nearly any text field
- native macOS installer / uninstaller windows without requiring Terminal

<a id="dmg-installation"></a>
## DMG Installation

For normal users, use the DMG release.

What the DMG installer does:
- downloads a standalone Python runtime during setup
- installs Python dependencies automatically
- downloads the latest supported model during setup
- installs the runtime to `~/Library/Application Support/FunASRDictation/app`
- creates the launcher app at `~/Applications/FunASR Dictation.app`
- creates the graphical uninstaller at `~/Applications/Uninstall FunASR Dictation.app`

Installation steps:
1. Download the latest `funasr-dictation-installer-2.2.0.dmg` from Releases.
2. Open the DMG.
3. Double-click `Install FunASR Dictation.app`.
4. Wait for the native installer window to finish downloading and setting up the runtime.
5. If you want a Desktop shortcut, click `Create Desktop Shortcut` in the installer window.
6. Click `Open App`.

Notes:
- the DMG does not bundle the model cache
- no Homebrew or preinstalled Python is required on the target Mac
- if a Desktop shortcut is created, macOS may require deleting it manually during uninstall

<a id="getting-started"></a>
## Getting Started

On first launch, grant these permissions to `FunASR Dictation` when macOS asks:
- Microphone
- Accessibility
- Input Monitoring

After that:
- the app lives in the macOS menubar
- the Dock icon stays hidden during normal use
- UI language follows the app language setting in the menu (`System / 中文 / English`)

Main menu items:
- `Toggle Dictation`
- `Hotkey Settings`
- `Model Config`
- `Update Model`
- `Enable Dictation On App Start`
- `Enable Launch At Login`
- `Quit App`

<a id="daily-use"></a>
## Daily Use

Typical dictation flow:
1. Turn dictation on from the menu.
2. Focus any text box.
3. Press the configured trigger once to start recording.
4. Speak.
5. Press the same trigger again to stop.
6. The app transcribes and pastes the text automatically.

Features available in normal use:
- keyboard trigger or mouse trigger
- menu bar status indicators for loading / ready / recording / transcribing / error
- model update from the menu
- launch-at-login toggle from the menu
- optional dictation-on-app-start toggle from the menu

<a id="hotkey-setup"></a>
## Hotkey Setup

Open `Hotkey Settings` from the menu.

The dialog shows:
- current trigger mode
- current keyboard hotkey
- current mouse button

Setup flow:
1. Click `Set Keyboard Hotkey` or `Set Mouse Button`.
2. Choose automatic capture or manual input.
3. Save the setting.
4. Select whether keyboard or mouse is the active trigger mode.
5. Click `Save`.

These settings are persisted in:
- `~/Library/Application Support/SenseVoiceDictation/ui_settings.json`

<a id="model-config"></a>
## Model Config

Use `Model Config` from the menu to edit runtime settings in UI.

Recommended defaults for this release:
- `language = "auto"`
- `sample_rate = 16000`
- `channels = 1`
- `paste_delay_ms = 20`
- `idle_unload_seconds = 300`
- `enable_beep = true`
- `use_itn = true`
- `merge_vad = false`
- `hotwords = ""`
- `remove_emoji = true`
- `batch_size_s = 0` (internal runtime value, not exposed in the UI)

What each setting is for:
- `Recognition Language`: keep `auto` for mixed Chinese/English speech
- `Sample Rate`: use `16000` unless your audio device requires `44100/48000`
- `Channels`: `1` is recommended; use `2` only for true stereo input devices
- `Paste Delay`: if paste occasionally fails, increase it slightly
- `Idle Model Unload Seconds`: set `0` to keep the model loaded all the time
- `Normalize Numbers/Dates`: cleaner text formatting for dates, numbers, and units
- `Merge Long-Pause Segments`: may be faster for long audio, but punctuation is usually less natural
- `Hot Words`: add names, brands, or technical terms you say often
- `Remove Emoji`: removes emoji symbols from the final pasted text

How changes apply:
- save in the UI
- the new values take effect from the next recording

<a id="menubar-states"></a>
## Menubar States

- `○` OFF
- `…` LOADING
- `⇡` UPDATING
- `✓` READY
- `●` RECORDING
- `↻` TRANSCRIBING
- `!` ERROR

<a id="developer"></a>
## Developer

This section collects the direct script / command based workflow.

### Source Installation

Requirements:
- macOS 11+
- Python 3.11+
- Xcode Command Line Tools when no bundled launcher binary is available

Install from source:

```bash
./install.sh
```

Start from source:

```bash
./start_app.sh
```

Optional source-install commands:

```bash
./create_launcher.sh
./create_desktop_shortcut.sh
./enable_autostart.sh
./disable_autostart.sh
./uninstall.sh
```

### Build the DMG

```bash
./build_dmg.sh
```

Output:

```bash
./funasr-dictation-installer-2.2.0.dmg
```

### Script Reference

- `install.sh`: install environment, dependencies, model, and launcher helpers
- `start_app.sh`: start the menubar app directly from source
- `create_launcher.sh`: create the clickable launcher app in `~/Applications`
- `create_desktop_shortcut.sh`: create the optional Desktop shortcut symlink
- `create_uninstaller.sh`: create the graphical uninstaller app in `~/Applications`
- `enable_autostart.sh`: enable LaunchAgent autostart
- `disable_autostart.sh`: disable LaunchAgent autostart
- `remove_launcher.sh`: remove launcher app and Desktop shortcut symlink
- `uninstall.sh`: uninstall runtime, model cache, launcher apps, and related support files
- `build_dmg.sh`: build the end-user installer DMG
- `install_from_dmg.command`: installer entry script used inside the DMG app
- `download_python_runtime.sh`: download and verify the standalone Python runtime for DMG installs
- `prepare_release.sh`: clean local artifacts and build the release zip
- `task_runner/TaskProgressApp.m`: native installer / uninstaller progress window implementation
- `launcher/FunASRLauncher.c`: launcher source responsible for runtime path resolution and TCC bootstrap
- `funasr_nano_runtime/`: bundled runtime source required by `Fun-ASR-Nano-2512`

### Uninstall and Cleanup

```bash
./uninstall.sh
```

This removes:
- launch agents
- running app processes
- runtime files under `~/Library/Application Support/FunASRDictation`
- launcher / uninstaller apps in `~/Applications`
- Fun-ASR model cache and legacy SenseVoice cache when present

If macOS blocks automatic Desktop shortcut removal, uninstall still completes and you can delete the Desktop shortcut manually.
