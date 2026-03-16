#!/usr/bin/env bash
set -euo pipefail

/Volumes/SATA-DATA/SynologyDrive/codex/SenseVoiceDictation/sensevoice-dictation-macos/.venv/bin/python - <<'PY'
import sys
from pathlib import Path

repo_dir = Path('/Volumes/SATA-DATA/SynologyDrive/codex/SenseVoiceDictation/sensevoice-dictation-macos')
sys.path.insert(0, str(repo_dir))

from menubar_dictation_app import _bind_button_action

class DummyButton:
    def __init__(self):
        self.target = None
        self.action = None

    def setTarget_(self, target):
        self.target = target

    def setAction_(self, action):
        self.action = action

class SlotOwner:
    __slots__ = ()

button = DummyButton()
owner = SlotOwner()
_bind_button_action(button, owner, lambda _sender: None)

assert button.target is not None
assert button.action == 'invoke:'
print('[PASS] button callback registry')
PY
