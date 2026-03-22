#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ['REPO_DIR'])
download = (repo / 'download_python_runtime.sh').read_text(encoding='utf-8')
build = (repo / 'build_dmg.sh').read_text(encoding='utf-8')

assert 'SVD_BUNDLED_PYTHON_DIR' in download
assert 'use_bundled_archive_if_available' in download
assert 'Using bundled standalone Python runtime' in download
assert 'bundled_python' in build
assert 'Bundling standalone Python runtime archives' in build
assert 'cpython-${PYTHON_VERSION}-aarch64-apple-darwin-install_only_stripped.tar.gz' in build
assert 'cpython-${PYTHON_VERSION}-x86_64-apple-darwin-install_only_stripped.tar.gz' in build

print('[PASS] bundled python runtime')
PY
