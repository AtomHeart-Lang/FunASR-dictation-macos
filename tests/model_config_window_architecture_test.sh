#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

repo = Path('/Volumes/SATA-DATA/SynologyDrive/codex/SenseVoiceDictation/sensevoice-dictation-macos')
source = (repo / 'menubar_dictation_app.py').read_text(encoding='utf-8')
start = source.index('def ui_edit_model_config(')
end = source.index('\ndef load_ui_settings(', start)
body = source[start:end]

assert 'NSWindow.alloc().initWithContentRect_styleMask_backing_defer_' in body, 'Model Config should use a dedicated NSWindow'
assert 'NSAlert.alloc().init()' not in body, 'Model Config should no longer be rendered through NSAlert'
assert '_run_modal_window(window)' in body, 'Model Config custom window should run modally'
print('[PASS] model config window architecture')
PY
