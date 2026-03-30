#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$APP_DIR/menubar_runtime.log"
LOCK_FILE="$APP_DIR/menubar_app.lock"
APP_SUPPORT_DIR="$HOME/Library/Application Support/SenseVoiceDictation"
STARTUP_CONTEXT_PATH="$APP_SUPPORT_DIR/startup_context.json"

localized_running_message() {
  local locale
  locale="$(defaults read -g AppleLocale 2>/dev/null || echo en)"
  case "$locale" in
    zh*)
      printf '%s' "FunASR Dictation 已经在运行。"$'\n'"如果没有看到图标，请检查状态栏是否因项目过多而被隐藏。"
      ;;
    *)
      printf '%s' "FunASR Dictation is already running."$'\n'"If you can't see the icon, check whether it is hidden because your menu bar is full."
      ;;
  esac
}

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
  RUNNING_MESSAGE="$(localized_running_message)" osascript <<'OSA' >/dev/null 2>&1 || true
display alert "FunASR Dictation" message (system attribute "RUNNING_MESSAGE") buttons {"OK"} default button "OK"
OSA
  exit 0
fi

# Keep the process chain attached to FunASR Dictation.app so macOS TCC
# attributes Accessibility/Input Monitoring to the app identity.
cd "$APP_DIR"
mkdir -p "$APP_SUPPORT_DIR"
cat >"$STARTUP_CONTEXT_PATH" <<'JSON'
{"source":"manual"}
JSON
exec ./start_app.sh >>"$LOG_FILE" 2>&1
