#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_ROOT="$HOME/Library/Application Support/FunASRDictation"
APP_DIR="$INSTALL_ROOT/app"
PAYLOAD_ARCHIVE="$SCRIPT_DIR/funasr-dictation-payload.tar.gz"
BACKUP_DIR=""
BACKUP_PYTHON_DIR=""
BACKUP_LAUNCHER_APP=""
BACKUP_UNINSTALLER_APP=""
RESTORE_ON_ERROR=1
CANCELLED=0
LOG_FILE="$INSTALL_ROOT/install.log"

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

emit_progress() {
  local percent="$1"
  shift
  echo "[Progress] $percent $*"
}

mkdir -p "$INSTALL_ROOT"
TMP_DIR="$(mktemp -d "$INSTALL_ROOT/.payload.XXXXXX")"
exec > >(tee -a "$LOG_FILE") 2>&1

cleanup() {
  rm -rf "$TMP_DIR"
  if [[ "$RESTORE_ON_ERROR" -eq 1 ]]; then
    rm -rf "$APP_DIR"
    rm -rf "$INSTALL_ROOT/python-runtime"
    rm -rf "$HOME/Applications/FunASR Dictation.app"
    rm -rf "$HOME/Applications/Uninstall FunASR Dictation.app"
    if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
      mv "$BACKUP_DIR" "$APP_DIR"
      echo "[WARN] $(localize "安装失败，已恢复之前的应用版本。" "Installation failed. Restored the previous app version.")"
    fi
    if [[ -n "$BACKUP_PYTHON_DIR" && -d "$BACKUP_PYTHON_DIR" ]]; then
      mv "$BACKUP_PYTHON_DIR" "$INSTALL_ROOT/python-runtime"
      echo "[WARN] $(localize "安装失败，已恢复之前的 Python 运行时。" "Installation failed. Restored the previous Python runtime.")"
    fi
    if [[ -n "$BACKUP_LAUNCHER_APP" && -d "$BACKUP_LAUNCHER_APP" ]]; then
      mv "$BACKUP_LAUNCHER_APP" "$HOME/Applications/FunASR Dictation.app"
    fi
    if [[ -n "$BACKUP_UNINSTALLER_APP" && -d "$BACKUP_UNINSTALLER_APP" ]]; then
      mv "$BACKUP_UNINSTALLER_APP" "$HOME/Applications/Uninstall FunASR Dictation.app"
    fi
  elif [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
    rm -rf "$BACKUP_DIR"
    rm -rf "$BACKUP_PYTHON_DIR"
    rm -rf "$BACKUP_LAUNCHER_APP"
    rm -rf "$BACKUP_UNINSTALLER_APP"
  fi
}
trap cleanup EXIT

on_cancel() {
  CANCELLED=1
  RESTORE_ON_ERROR=1
  echo
  echo "[WARN] $(localize "检测到用户取消，正在停止安装并清理已产生的文件。" "Cancellation requested. Stopping installation and cleaning up generated files.")"
  pkill -TERM -P $$ >/dev/null 2>&1 || true
  sleep 0.2
  pkill -KILL -P $$ >/dev/null 2>&1 || true
  exit 130
}
trap on_cancel INT TERM

on_error() {
  local exit_code="$1"
  local line_no="$2"
  echo
  echo "[ERROR] $(localize "DMG 安装在第 $line_no 行失败（退出码 $exit_code）。" "DMG installation failed at line $line_no (exit $exit_code).")"
  echo "[ERROR] $(localize "请检查日志：$LOG_FILE" "Check log: $LOG_FILE")"
  if [[ "${FUNASR_UI_MODE:-0}" != "1" ]]; then
    osascript <<OSA >/dev/null 2>&1 || true
display alert "FunASR Dictation Installer" message "$(localize "安装失败。请检查日志：\n$LOG_FILE" "Installation failed. Check log:\n$LOG_FILE")" as critical
OSA
  fi
}
trap 'on_error $? $LINENO' ERR

if [[ ! -f "$PAYLOAD_ARCHIVE" ]]; then
  echo "[ERROR] Missing installer payload: $PAYLOAD_ARCHIVE"
  exit 1
fi

emit_progress 6 "$(localize "准备安装" "Preparing installation")"
echo "[Step] $(localize "停止已运行的应用进程" "Stopping running app instance")"
pkill -f "[m]enubar_dictation_app.py" >/dev/null 2>&1 || true
pkill -f "[s]tart_app.sh" >/dev/null 2>&1 || true

emit_progress 12 "$(localize "解压安装载荷" "Extracting installer payload")"
echo "[Step] $(localize "解压安装载荷" "Extracting payload")"
tar -xzf "$PAYLOAD_ARCHIVE" -C "$TMP_DIR"

PAYLOAD_APP_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [[ -z "$PAYLOAD_APP_DIR" || ! -d "$PAYLOAD_APP_DIR" ]]; then
  echo "[ERROR] Invalid payload layout."
  exit 1
fi

if [[ -d "$APP_DIR" ]]; then
  BACKUP_DIR="$INSTALL_ROOT/app.backup.$(date +%s)"
  mv "$APP_DIR" "$BACKUP_DIR"
fi

if [[ -d "$INSTALL_ROOT/python-runtime" ]]; then
  BACKUP_PYTHON_DIR="$INSTALL_ROOT/python-runtime.backup.$(date +%s)"
  mv "$INSTALL_ROOT/python-runtime" "$BACKUP_PYTHON_DIR"
fi

if [[ -d "$HOME/Applications/FunASR Dictation.app" ]]; then
  BACKUP_LAUNCHER_APP="$INSTALL_ROOT/launcher.backup.$(date +%s)"
  mv "$HOME/Applications/FunASR Dictation.app" "$BACKUP_LAUNCHER_APP"
fi

if [[ -d "$HOME/Applications/Uninstall FunASR Dictation.app" ]]; then
  BACKUP_UNINSTALLER_APP="$INSTALL_ROOT/uninstaller.backup.$(date +%s)"
  mv "$HOME/Applications/Uninstall FunASR Dictation.app" "$BACKUP_UNINSTALLER_APP"
fi

mv "$PAYLOAD_APP_DIR" "$APP_DIR"

if [[ -n "$BACKUP_DIR" && -f "$BACKUP_DIR/config.toml" && ! -f "$APP_DIR/config.toml" ]]; then
  cp "$BACKUP_DIR/config.toml" "$APP_DIR/config.toml"
fi

cd "$APP_DIR"

export SVD_BUNDLED_PYTHON_DIR="$APP_DIR/bundled_python"

emit_progress 20 "$(localize "安装运行环境和依赖" "Installing runtime and dependencies")"
echo "[Step] $(localize "安装运行环境并下载最新模型" "Installing runtime and downloading latest model")"
STANDALONE_PYTHON="$(./download_python_runtime.sh)"
SVD_PYTHON_BIN="$STANDALONE_PYTHON" ./install.sh --no-launcher

emit_progress 95 "$(localize "创建应用启动器" "Creating launcher app")"
echo "[Step] $(localize "为已安装运行目录重建启动器" "Rebuilding launcher for installed runtime path")"
./create_launcher.sh --force-rebuild

RESTORE_ON_ERROR=0

echo
emit_progress 100 "$(localize "安装已完成" "Installation completed")"
echo "[Done] $(localize "安装已完成。" "Installation completed.")"
echo "[Note] $(localize "应用位置：$HOME/Applications/FunASR Dictation.app" "App: $HOME/Applications/FunASR Dictation.app")"
echo "[Note] $(localize "桌面快捷方式是可选功能，默认不创建。" "Desktop shortcut is optional and is no longer created by default.")"
echo "[Note] $(localize "如果需要桌面快捷方式，请在安装窗口中点击创建。" "Use the installer window if you want to create a Desktop shortcut.")"
echo "[Note] $(localize "如果创建了桌面快捷方式，卸载时 macOS 可能要求你手动删除。" "If created, macOS may require deleting the Desktop shortcut manually during uninstall.")"
echo "[Note] $(localize "可在此窗口点击打开应用，或稍后从 ~/Applications 启动。" "Open FunASR Dictation from the installer window or from ~/Applications after this window closes.")"
echo "[Note] $(localize "首次启动时，请给 FunASR Dictation 授予麦克风、辅助功能和输入监控权限。" "On first launch, grant Microphone, Accessibility, and Input Monitoring to FunASR Dictation.")"
echo "[Note] $(localize "模型会在安装过程中下载，不打包在 DMG 内。" "Models are downloaded during installation and are not bundled in the DMG.")"
