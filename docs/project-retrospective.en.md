# FunASR Dictation Project Retrospective

Last updated: 2026-04-03

[中文版本](./project-retrospective.md)

## Table of Contents

- [1. Summary Metrics](#1-summary-metrics)
- [2. Project Phase Overview](#2-project-phase-overview)
- [3. Feature Improvements](#3-feature-improvements)
- [4. Problem Fixes](#4-problem-fixes)
- [5. Testing and Engineering Outcomes](#5-testing-and-engineering-outcomes)
- [6. Overall Conclusion](#6-overall-conclusion)

## 1. Summary Metrics

The figures below are consolidated from this project thread, git history, release tags, and test scripts.

| Metric | Value | Notes |
| --- | --- | --- |
| Collaboration rounds | 100+ | Estimated from the full working thread, including retries and interrupted sessions |
| Git commits | 103 | Through `v1.0.9` |
| Tagged versions | 27 | From the earliest `v0.1.0` to current `v1.0.9` |
| DMG release / test builds | 26 | Spanning both the `v1.x` and `v2.x` release phases |
| Automated test scripts | 21 | Covering install, uninstall, UI, model loading, autostart, and related flows |
| Repository migrations | 1 | Moved from the old repository to `FunASR-dictation-macos` |
| Primary ASR model switch | 1 | Migrated from SenseVoice to Fun-ASR Nano 2512 |
| Explicit fixes and regressions addressed | 40+ | Aggregated across features, installer flow, permissions, startup, and UI |

### Reading the numbers

- This project evolved from a script-driven local dictation utility into a distributable, installable, uninstallable, and maintainable macOS desktop product.
- In the later stages, much of the work was not about adding brand-new features, but about fixing real-world stability issues in:
  - the installer
  - permission attribution
  - menu bar visibility
  - autostart
  - uninstall cleanup
  - cross-version macOS compatibility

## 2. Project Phase Overview

### 2.1 Initial usable version

- Packaged the local speech-to-text workflow as a macOS menu bar app
- Supported basic hotkey trigger, recording, and auto-paste
- Shipped the earliest GitHub release as `v0.1.0`

### 2.2 Configuration and UX enhancement phase

- Added a native Model Config UI
- Added hotkey setup, mouse trigger, beeps, and text cleanup controls
- Localized menus and dialogs in Chinese and English
- Iteratively improved the workflow for non-technical users

### 2.3 Model migration and recognition quality phase

- Migrated from SenseVoice to Fun-ASR Nano 2512
- Added runtime compatibility handling and local model-cache preference
- Improved recognition quality, English term retention, and overall robustness

### 2.4 DMG productization phase

- Moved from source-based setup to DMG-based installation
- Added graphical installer and graphical uninstaller flows
- Integrated standalone Python, automatic dependency installation, and automatic model download
- Completed the product-facing details around shortcuts, launcher, uninstaller, and icon system

### 2.5 Repository rename and formal release phase

- Renamed and migrated the repository to `FunASR-dictation-macos`
- Published the new repository's `v1.0.0`
- Continued hardening around macOS 14 compatibility, permissions, startup feedback, and autostart recovery
- Reached a state where the product is installable, testable, releasable, and regression-checkable

## 3. Feature Improvements

This section groups the major capabilities we added or significantly improved during the project.

### 3.1 Menu bar application behavior

- Turned the tool into a real macOS menu bar application
- Added visible state handling for:
  - ready
  - recording
  - transcribing
  - permission error
  - general error
- Added startup visibility improvements and user-facing launch feedback

### 3.2 Hotkeys and trigger modes

- Added keyboard hotkey triggering
- Added mouse middle-button / side-button triggering
- Consolidated scattered menu entries into a dedicated Hotkey Settings dialog
- Added guided native flows for:
  - listening for a hotkey
  - manual entry
  - displaying the current setup

### 3.3 Model configuration

- Added a native `Model Config` window
- Supported major settings including:
  - recognition language
  - sample rate
  - channel count
  - paste delay
  - idle model unload interval
  - number/date normalization
  - merge long-pause segments
  - emoji filtering
  - hot words
- Iteratively refined:
  - card-based layout
  - title hierarchy
  - scrollable content
  - Chinese / English adaptation

### 3.4 Text processing experience

- Added configurable recording beeps
- Added text cleanup behavior
- Improved removal of unwanted spaces between Chinese characters
- Improved cleanup of spaces before punctuation and inside brackets
- Preserved user-entered hotword casing instead of forcing lowercase on save

### 3.5 Model and recognition pipeline

- Migrated from SenseVoice to Fun-ASR Nano 2512
- Added local-cache-first model loading
- Added model warmup flow
- Added idle model unload to reduce memory usage
- Supported loading the model again on subsequent use after unload

### 3.6 Installation and uninstallation

- Added DMG-based graphical installation
- Added graphical uninstallation
- Prepared standalone Python automatically during install
- Created a project-local virtual environment automatically
- Installed dependencies automatically
- Downloaded models during installation
- Added optional desktop shortcut creation
- Expanded uninstall cleanup to cover:
  - the main app
  - the uninstaller
  - the virtual environment
  - the standalone Python runtime
  - model caches
  - LaunchAgent files
  - legacy directories

### 3.7 Launch and autostart

- Supported launching from `Applications`
- Supported login autostart
- Added visible fallback behavior when permissions are missing, so the app is not silently “running in the background”
- Added startup notices
- Added an “already running” prompt when the app icon is clicked again

### 3.8 Branding and icon system

- Unified the product name to `FunASR Dictation`
- Replaced the main app icon with the new gradient microphone icon
- Gave the uninstaller its own icon with a trash indicator
- Added rounded corners directly to icons so they appear more consistent on older macOS versions

### 3.9 Localization

- Added bilingual menu items
- Added bilingual main dialogs
- Added bilingual installer and uninstaller flows
- Maintained both Chinese and English README files
- Added a runtime language switch to verify English menu and dialog layouts

## 4. Problem Fixes

This section groups the most important issues we fixed during the project.

### 4.1 Model installation and loading

- Fixed the Fun-ASR Nano “not registered” model error
- Stabilized `trust_remote_code` fallback behavior
- Fixed first-run model load failures after download
- Fixed cases where cached local models still triggered network-dependent resolution
- Fixed model-loading state transitions that became inconsistent after failures

### 4.2 Recognition output issues

- Fixed “recording ends but no text is produced”
- Fixed “transcription completes but text is not inserted into the target input”
- Reduced occasional paste failures caused by timing
- Fixed several unwanted spacing issues
- Improved mixed Chinese/English text stability

### 4.3 Permissions and TCC

- Fixed Accessibility permission invalidating repeatedly
- Fixed Input Monitoring instability
- Fixed launcher identity drift that broke permission attribution
- Added clearer permission guidance and restart instructions
- Fixed the “nothing appears to be running” experience when permissions failed

### 4.4 Menu bar visibility

- Fixed menu bar icon not appearing
- Removed the accidental `FA` prefix in the status display
- Added fallback handling for status item visibility across different macOS versions
- Added startup notices to reduce “the app is running but I did not notice it” confusion
- Fixed the case where clicking the app again while running gave no feedback

### 4.5 Launcher and startup path

- Fixed desktop shortcut double-click doing nothing
- Fixed silent launcher failures
- Fixed hard-coded runtime paths that broke after migration or relocation
- Fixed missing runtime metadata without self-healing
- Fixed launch-at-login showing as enabled while the underlying setup was broken

### 4.6 Autostart

- Fixed LaunchAgent enable-order problems
- Fixed login autostart for external-drive installs
- Fixed missing autostart runner not being treated as a damaged setup
- Unified the active runtime support path under `FunASRDictation`, so legacy `SenseVoiceDictation` is no longer required for normal operation

### 4.7 Installer

- Fixed first-run installer bootstrap problems
- Fixed localized macOS systems not finding Terminal
- Fixed the crash caused by auto-launching the app immediately after install
- Added installer cancellation support
- Added cleanup after cancellation
- Fixed standalone Python download slowness and HTTP/2 failures
- Fixed Gatekeeper blocking `python3.11`

### 4.8 Uninstaller

- Fixed the uninstaller window not closing after clicking `Cancel`
- Fixed uninstall aborting when Desktop shortcut removal failed
- Added localized uninstall warnings
- Fixed failures when metadata files were missing and the uninstaller could not resolve the installed runtime path

### 4.9 UI and layout

- Iteratively fixed the `Model Config` window for:
  - height overflow
  - content clipping
  - lack of scrolling
  - uneven card margins
  - title and icon misalignment
- Iteratively fixed the `Hotkey Settings` window for:
  - button emphasis
  - title-to-content spacing
  - current-setting text hierarchy
  - left/right alignment
- Iteratively fixed installer layout issues such as:
  - truncated text
  - bilingual copy fitting
  - button-area balance

## 5. Testing and Engineering Outcomes

### 5.1 Automated test coverage

The repository now contains **21 test scripts**, covering:

- installer and uninstaller behavior
- startup and cancellation flows
- standalone Python handling
- Gatekeeper compatibility
- LaunchAgent autostart
- launcher runtime-path resolution
- Model Config geometry
- Hotkey Settings layout
- status-bar visibility
- startup notices and relaunch prompts
- release packaging checks

### 5.2 Release strategy

Versioning went through two clear phases:

- Legacy repository phase:
  - `v0.1.0`
  - `v2.0.0` through `v2.2.2`
- New repository phase:
  - `v1.0.0` through current `v1.0.9`

This reflects a real product transition:
- not just patch releases
- but a repository migration, product rename, and rebuilt release line

### 5.3 Engineering maturity

Compared with the early state, the project now has much stronger product and engineering foundations:

- a stable DMG build path
- graphical installation and uninstallation
- bilingual user-facing flows
- autostart and startup guidance
- broader regression coverage
- explicit release tags and release assets

## 6. Overall Conclusion

The main achievement of this project is not simply that we “built a dictation tool.” We took a local speech-to-text utility that began life as a developer-oriented script and gradually turned it into a macOS application that ordinary users can install, configure, use, and uninstall.

In practical terms, the most important outcomes were:

- a stable migration from SenseVoice to Fun-ASR with better recognition quality
- turning core workflows like configuration, hotkeys, installation, uninstallation, and permission guidance into product-level features
- repeatedly validating and fixing issues on real hardware, real macOS versions, and real permission environments
- turning many “only shows up on a user’s machine” failures into repeatable tests and engineering guardrails

If we had to summarize the entire journey in one sentence:

> We turned a local dictation script into a real macOS product that can be installed, used, tested, and delivered to other people.

