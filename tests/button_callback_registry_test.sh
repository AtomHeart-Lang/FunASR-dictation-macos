#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo_dir = Path(os.environ['REPO_DIR'])
source = (repo_dir / 'menubar_dictation_app.py').read_text(encoding='utf-8')

assert 'def _bind_button_action(' in source
assert 'button.setAction_(\"invoke:\")' in source
assert '_BUTTON_CALLBACK_TARGETS.append(target)' in source
print('[PASS] button callback registry')
PY
