#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ["REPO_DIR"])
source = (repo / "menubar_dictation_app.py").read_text(encoding="utf-8")
start = source.index("def ui_edit_model_config(")
end = source.index("\ndef load_ui_settings(", start)
body = source[start:end]

assert "visible_panel_h = min(layout.panel_h, 620)" in body
assert "NSScrollView.alloc().initWithFrame_(NSMakeRect(0, bottom_strip_h, window_w, visible_panel_h))" in body
assert "scroll_view.setDocumentView_(panel)" in body
assert "cancel_button = NSButton.alloc().initWithFrame_(NSMakeRect(window_w - 182, 16, 76, 30))" in body

print("[PASS] model config scroll layout")
PY
