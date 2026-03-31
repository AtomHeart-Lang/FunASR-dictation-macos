#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$REPO_DIR" python3 - <<'PY'
import os
from pathlib import Path
text = (Path(os.environ['REPO_DIR']) / 'menubar_dictation_app.py').read_text(encoding='utf-8')

assert 'def is_os_autostart_healthy() -> bool:' in text, 'healthy autostart predicate missing'
assert 'if not AUTOSTART_RUNNER.exists():' in text, 'runner existence check missing'
assert 'return True' in text[text.index('def is_os_autostart_runner_outdated() -> bool:'): text.index('def set_os_autostart_enabled')], 'runner missing should mark configuration outdated/damaged'
assert 'runtime_path = read_runtime_app_dir()' in text, 'runtime path health check missing'
assert 'self.launch_login_item.state = 1 if is_os_autostart_healthy() else 0' in text, 'menu launch-at-login should reflect health, not mere plist existence'
assert 'if not is_os_autostart_damaged():' in text, 'autostart self-heal gate missing'
print('[PASS] autostart health logic present')
PY
