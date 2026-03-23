#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)" python3 - <<'PY'
import os
from pathlib import Path
repo = Path(os.environ['REPO_DIR'])
create_uninstaller = (repo / 'create_uninstaller.sh').read_text(encoding='utf-8')
assert 'APP_VERSION="1.0.4"' in create_uninstaller
assert 'APP_VERSION="1.0.4"' in (repo / 'build_dmg.sh').read_text(encoding='utf-8')
assert 'APP_VERSION="1.0.4"' in (repo / 'create_launcher.sh').read_text(encoding='utf-8')
assert 'assets/uninstaller_launcher_icon_finnal.png' in create_uninstaller
assert (repo / 'assets' / 'uninstaller_launcher_icon_finnal.png').exists(), 'Dedicated uninstaller icon asset is missing'

readme = (repo / 'README.md').read_text(encoding='utf-8')
readme_zh = (repo / 'README.zh-CN.md').read_text(encoding='utf-8')
assert '## DMG Installation' in readme
assert '## Getting Started' in readme
assert '## Developer' in readme
assert '### Menu Name Mapping (EN/CN)' not in readme
assert '[中文文档]' in readme
assert '## DMG 安装' in readme_zh
assert '## 快速开始' in readme_zh
assert '## 开发者说明' in readme_zh
assert '### 菜单中英文名称对照' not in readme_zh
assert '## Developer' in readme and readme.index('## Developer') > readme.index('## Getting Started')
assert '## 开发者说明' in readme_zh and readme_zh.index('## 开发者说明') > readme_zh.index('## 快速开始')
print('[PASS] release polish')
PY
