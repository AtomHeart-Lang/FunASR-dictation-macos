#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$APP_DIR/menubar_runtime.log"
LOCK_FILE="$APP_DIR/menubar_app.lock"

already_running() {
  local py="$APP_DIR/.venv/bin/python3"
  [[ -x "$py" ]] || return 1
  "$py" - "$LOCK_FILE" <<'PY'
import fcntl
import os
import sys

path = sys.argv[1]
fd = os.open(path, os.O_RDWR | os.O_CREAT, 0o644)
try:
    fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    raise SystemExit(0)
else:
    raise SystemExit(1)
finally:
    os.close(fd)
PY
}

if already_running; then
  osascript <<'OSA' >/dev/null 2>&1 || true
display alert "FunASR Dictation" message "FunASR Dictation is already running in the menu bar." buttons {"OK"} default button "OK"
OSA
  exit 0
fi

# Keep the process chain attached to FunASR Dictation.app so macOS TCC
# attributes Accessibility/Input Monitoring to the app identity.
cd "$APP_DIR"
exec ./start_app.sh >>"$LOG_FILE" 2>&1
