#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$APP_DIR/menubar_runtime.log"

# Launch through Terminal because keyboard event-tap permissions are stable
# when the process is started under a trusted terminal app.
CMD="cd '$APP_DIR' && ./start_app.sh >>'$LOG_FILE' 2>&1"
CMD_ESCAPED="${CMD//\"/\\\"}"

osascript <<OSA
tell application "Terminal"
    do script "$CMD_ESCAPED"
    try
        set miniaturized of front window to true
    end try
end tell
OSA
