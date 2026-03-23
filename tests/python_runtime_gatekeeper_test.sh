#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo = Path(os.environ['REPO_DIR'])
source = (repo / 'download_python_runtime.sh').read_text(encoding='utf-8')

assert 'com.apple.quarantine' in source, 'expected quarantine cleanup for bundled python runtime'
assert 'xattr -dr com.apple.quarantine' in source, 'expected recursive quarantine removal'
assert 'codesign --force --sign -' in source, 'expected ad-hoc codesign for extracted runtime'
assert 'Mach-O' in source, 'expected Mach-O detection before signing'
assert 'prepare_runtime_for_execution' in source, 'expected dedicated runtime preparation helper'

print('[PASS] python runtime gatekeeper hardening')
PY
