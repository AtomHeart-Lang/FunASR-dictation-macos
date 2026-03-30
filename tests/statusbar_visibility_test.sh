#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ['REPO_DIR'])
source = (repo / 'menubar_dictation_app.py').read_text(encoding='utf-8')

assert 'import platform' not in source
assert 'Path(MENU_ICON).exists()' in source
assert 'icon.setTemplate_(True)' in source
assert '_app_icon_image(rounded=True)' in source
assert 'button.setImagePosition_(NSImageLeft)' in source
assert 'button.setImageScaling_(NSImageScaleProportionallyDown)' in source
assert 'nsstatusitem.setImage_(icon)' in source
assert 'button.setImage_(icon)' in source
assert 'button.setNeedsDisplay_(True)' in source
assert 'suppress engine status transition' in source
assert 'self.enable_dictation(show_alert=True, request_prompt=True)' in source
assert 'NSApplicationActivationPolicyRegular' in source
assert 'def _set_error_visibility_mode' in source
assert 'def _restore_menu_bar_visibility_mode' in source
assert 'self._set_error_visibility_mode()' in source
assert 'self._restore_menu_bar_visibility_mode()' in source
assert 'menu_open_uninstaller' in source
assert '@rumps.clicked("Open Uninstaller")' in source
assert 'self.pending_startup_enable = True' in source
assert 'self.engine.warmup_async()' not in source.split('if self.ui_settings.enable_dictation_on_app_start:', 1)[1].split('def _menu_icon_image', 1)[0]
assert 'self.title = "○"' in source or 'title="○"' in source

print('[PASS] statusbar visibility logic')
PY
