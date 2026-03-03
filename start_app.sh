#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .venv/bin/activate ]]; then
  echo "[ERROR] .venv not found. Run ./install.sh first."
  exit 1
fi

source .venv/bin/activate
exec python3 menubar_dictation_app.py
