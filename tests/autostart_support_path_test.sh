#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$REPO_DIR" python3 - <<'PY'
import os
from pathlib import Path
repo = Path(os.environ['REPO_DIR'])

files = {
    'menubar': repo / 'menubar_dictation_app.py',
    'enable': repo / 'enable_autostart.sh',
    'disable': repo / 'disable_autostart.sh',
    'launcher': repo / 'create_launcher.sh',
    'desktop': repo / 'launch_from_desktop.sh',
    'uninstaller': repo / 'create_uninstaller.sh',
    'uninstall': repo / 'uninstall.sh',
    'launcher_c': repo / 'launcher' / 'FunASRLauncher.c',
}
contents = {name: path.read_text(encoding='utf-8') for name, path in files.items()}

# Active runtime/support paths must use the FunASR name, not SenseVoice.
for name in ('menubar', 'enable', 'disable', 'launcher', 'desktop', 'uninstaller', 'uninstall', 'launcher_c'):
    text = contents[name]
    assert 'Library/Application Support/FunASRDictation' in text, f'{name} missing active FunASR support path'

# Legacy SenseVoice path may still exist, but only as explicit legacy fallback/cleanup.
assert 'LEGACY_APP_SUPPORT_DIR' in contents['menubar'], 'menubar should keep an explicit legacy support dir for migration only'
assert 'LEGACY_AUTOSTART_DIR' in contents['enable'], 'enable_autostart should keep explicit legacy dir references'
assert 'LEGACY_AUTOSTART_DIR' in contents['disable'], 'disable_autostart should keep explicit legacy dir references'
assert 'LEGACY_APP_SUPPORT_DIR' in contents['launcher'], 'create_launcher should keep explicit legacy dir references'
assert 'LEGACY_APP_SUPPORT_DIR' in contents['uninstaller'], 'create_uninstaller should keep explicit legacy dir references'
assert 'kLegacyRuntimePathRel' in contents['launcher_c'], 'launcher should keep explicit legacy runtime path fallback constant'

print('[PASS] autostart support path uses FunASR as active path')
PY
