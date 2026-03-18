#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
import sys
from pathlib import Path

repo_dir = Path(os.environ["REPO_DIR"])
sys.path.insert(0, str(repo_dir))

from hotkey_dialog_layout import (
    build_hotkey_dialog_geometry,
    build_hotkey_settings_actions,
    build_hotkey_settings_sections,
)

sections = build_hotkey_settings_sections()
assert [section.key for section in sections] == ["mode", "current"], sections
assert sections[0].title_key == "hotkey_dialog_section_mode"
assert sections[1].title_key == "hotkey_dialog_section_current"

mode_items = [item.key for item in sections[0].items]
assert mode_items == ["mode_keyboard", "mode_mouse"], mode_items

current_items = [item.key for item in sections[1].items]
assert current_items == ["keyboard_hotkey", "mouse_button"], current_items

actions = build_hotkey_settings_actions()
assert [action.key for action in actions] == ["set_keyboard", "set_mouse", "save"], actions
assert [action.label_key for action in actions] == ["menu_set_hotkey", "menu_set_mouse", "save"]
assert actions[-1].emphasis == "primary"

geometry = build_hotkey_dialog_geometry()
assert geometry.panel_w == 278
assert geometry.mode_card_h == 60
assert geometry.mode_radio_y == 6
assert geometry.mode_title_bottom - (geometry.mode_radio_y + 20) >= 4
assert geometry.current_card_h == 72
assert geometry.current_keyboard_y == 22
assert geometry.current_mouse_y == 6
assert geometry.current_title_bottom - (geometry.current_keyboard_y + 16) >= 4

print("[PASS] hotkey dialog layout")
PY
