#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path

repo_dir = Path(os.environ["REPO_DIR"])
source = (repo_dir / "task_runner" / "TaskProgressApp.m").read_text(encoding="utf-8")

assert "@property(nonatomic, assign) BOOL taskStarted;" in source
assert "@property(nonatomic, assign) BOOL cancellationRequested;" in source
assert "requestCancelIfNeeded" in source
assert "cancelRunningTask" in source
assert "killpg(pid, SIGTERM);" in source
assert "killpg(runningPid, SIGKILL);" in source
assert "self.taskStarted = YES;" in source
assert 'self.closeButton.title = Localized(@"取消", @"Cancel");' in source
assert 'self.closeButton.title = Localized(@"关闭", @"Close");' in source

print("[PASS] uninstall cancel flow")
PY
