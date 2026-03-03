#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$APP_DIR/menubar_runtime.log"

# Silent background launch from desktop shortcut.
cd "$APP_DIR"
./start_app.sh >>"$LOG_FILE" 2>&1 &
