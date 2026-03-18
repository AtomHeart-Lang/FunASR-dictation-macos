#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

repo_dir = Path('/Volumes/SATA-DATA/SynologyDrive/codex/SenseVoiceDictation/sensevoice-dictation-macos')
source = (repo_dir / 'menubar_dictation_app.py').read_text(encoding='utf-8')

assert 'def _bind_button_action(' in source
assert 'button.setAction_(\"invoke:\")' in source
assert '_BUTTON_CALLBACK_TARGETS.append(target)' in source
print('[PASS] button callback registry')
PY
