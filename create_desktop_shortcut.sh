#!/usr/bin/env bash
set -euo pipefail

APP_NAME="FunASR Dictation"
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"
DESKTOP_APP="$HOME/Desktop/$APP_NAME.app"

is_chinese_locale() {
  local locale="${LC_ALL:-${LC_MESSAGES:-${LANG:-${AppleLocale:-}}}}"
  locale="$(printf '%s' "$locale" | tr '[:upper:]' '[:lower:]')"
  [[ "$locale" == zh* ]]
}

localize() {
  local zh="$1"
  local en="$2"
  if is_chinese_locale; then
    printf '%s\n' "$zh"
  else
    printf '%s\n' "$en"
  fi
}

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "[ERROR] $(localize "未找到应用启动器：$APP_BUNDLE" "Launcher app not found: $APP_BUNDLE")"
  echo "$(localize "请先运行 ./create_launcher.sh。" "Run ./create_launcher.sh first.")"
  exit 1
fi

mkdir -p "$HOME/Desktop"
rm -f "$DESKTOP_APP"
ln -s "$APP_BUNDLE" "$DESKTOP_APP"

echo "[OK] $(localize "桌面快捷方式已创建（符号链接）：$DESKTOP_APP" "Desktop shortcut created (symlink): $DESKTOP_APP")"
echo "[WARN] $(localize "卸载时如果 macOS 阻止自动删除桌面快捷方式，请手动从桌面删除。" "If macOS blocks automatic removal during uninstall, delete the Desktop shortcut manually from Desktop.")"
