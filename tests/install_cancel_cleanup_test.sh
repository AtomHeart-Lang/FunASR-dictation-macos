#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ['REPO_DIR'])
source = (repo / 'install_from_dmg.command').read_text(encoding='utf-8')
assert 'BACKUP_PYTHON_DIR' in source
assert 'BACKUP_LAUNCHER_APP' in source
assert 'BACKUP_UNINSTALLER_APP' in source
assert 'trap on_cancel INT TERM' in source
assert 'pkill -TERM -P $$' in source
assert 'rm -rf "$INSTALL_ROOT/python-runtime"' in source
assert 'mv "$BACKUP_PYTHON_DIR" "$INSTALL_ROOT/python-runtime"' in source
assert 'SVD_BUNDLED_PYTHON_DIR' in source
print('[PASS] install cancel cleanup')
PY
