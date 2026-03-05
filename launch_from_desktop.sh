#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$APP_DIR/menubar_runtime.log"

# Keep the process chain attached to FunASR Dictation.app so macOS TCC
# attributes Accessibility/Input Monitoring to the app identity.
cd "$APP_DIR"
exec ./start_app.sh >>"$LOG_FILE" 2>&1
