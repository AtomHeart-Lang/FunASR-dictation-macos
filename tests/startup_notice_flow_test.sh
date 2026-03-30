#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ["REPO_DIR"])
source = (repo / "menubar_dictation_app.py").read_text(encoding="utf-8")
launcher = (repo / "launch_from_desktop.sh").read_text(encoding="utf-8")
autostart = (repo / "enable_autostart.sh").read_text(encoding="utf-8")

assert "STARTUP_STATE_PATH" in source
assert "STARTUP_CONTEXT_PATH" in source
assert "class StartupState" in source
assert "def load_startup_state()" in source
assert "def save_startup_state(" in source
assert "def consume_startup_context()" in source
assert "startup_notice_title" in source
assert "startup_notice_body" in source
assert "already_running_hidden_hint" in source
assert "show_startup_notice" in source
assert "manual" in launcher and "startup_context.json" in launcher
assert "autostart" in autostart and "startup_context.json" in autostart

print("[PASS] startup notice flow")
PY
