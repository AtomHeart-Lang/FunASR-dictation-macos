#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo_dir = Path(os.environ["REPO_DIR"])
source = (repo_dir / "menubar_dictation_app.py").read_text(encoding="utf-8")

assert "def _prefer_cached_model_source(" in source
assert "model_source = _prefer_cached_model_source(MODEL_NAME, PRIMARY_MODEL_CACHE_DIR)" in source
assert "vad_source = _prefer_cached_model_source(VAD_MODEL_NAME, PRIMARY_VAD_CACHE_DIR)" in source
assert 'logging.info("model sources resolved: model=%s vad=%s", model_source, vad_source)' in source

print("[PASS] model load source fallback")
PY
