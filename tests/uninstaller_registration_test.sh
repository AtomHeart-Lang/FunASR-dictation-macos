#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ['REPO_DIR'])
source = (repo / 'create_uninstaller.sh').read_text(encoding='utf-8')
assert 'lsregister' in source.lower()
assert '"$LSREGISTER" -f "$APP_BUNDLE"' in source
print('[PASS] uninstaller registration')
PY
