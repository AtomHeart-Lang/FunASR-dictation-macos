#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo_dir = Path(os.environ["REPO_DIR"])
source = (repo_dir / "task_runner" / "TaskProgressApp.m").read_text(encoding="utf-8")

assert "@property(nonatomic, assign) BOOL taskStarted;" in source
assert "if (self.finished || !self.taskStarted || self.task == nil || !self.task.running)" in source
assert "self.taskStarted = YES;" in source

print("[PASS] uninstall cancel flow")
PY
