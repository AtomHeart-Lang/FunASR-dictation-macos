#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$REPO_DIR" python3 - <<'PY'
import os
from pathlib import Path
text = (Path(os.environ['REPO_DIR']) / 'launcher' / 'FunASRLauncher.c').read_text(encoding='utf-8')
assert 'kRuntimePathRel = "Library/Application Support/FunASRDictation/runtime_app_dir.txt"' in text
assert 'kLegacyRuntimePathRel = "Library/Application Support/SenseVoiceDictation/runtime_app_dir.txt"' in text
assert 'show_alert(' in text, 'launcher should show an explicit alert instead of failing silently'
assert 'Runtime configuration was not found' in text
assert 'The runtime directory is missing or unavailable' in text
print('[PASS] launcher runtime path handling')
PY
