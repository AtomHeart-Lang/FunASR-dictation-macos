#!/usr/bin/env bash
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/com.lee.funasr.menubar.plist"
LABEL="com.lee.funasr.menubar"
LEGACY_PLIST="$HOME/Library/LaunchAgents/com.lee.sensevoice.menubar.plist"
LEGACY_LABEL="com.lee.sensevoice.menubar"
DOMAIN="gui/$(id -u)"
AUTOSTART_DIR="$HOME/Library/Application Support/FunASRDictation"
AUTOSTART_RUNNER="$AUTOSTART_DIR/autostart_runner.sh"
AUTOSTART_LOG_DIR="$HOME/Library/Logs/FunASRDictation"
LEGACY_AUTOSTART_DIR="$HOME/Library/Application Support/SenseVoiceDictation"
LEGACY_AUTOSTART_RUNNER="$LEGACY_AUTOSTART_DIR/autostart_runner.sh"
LEGACY_AUTOSTART_LOG_DIR="$HOME/Library/Logs/SenseVoiceDictation"

launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootout "$DOMAIN" "$PLIST" >/dev/null 2>&1 || true
launchctl disable "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootout "$DOMAIN/$LEGACY_LABEL" >/dev/null 2>&1 || true
launchctl bootout "$DOMAIN" "$LEGACY_PLIST" >/dev/null 2>&1 || true
launchctl disable "$DOMAIN/$LEGACY_LABEL" >/dev/null 2>&1 || true

rm -f "$PLIST"
rm -f "$LEGACY_PLIST"
rm -f "$AUTOSTART_RUNNER"
rm -f "$LEGACY_AUTOSTART_RUNNER"
rmdir "$AUTOSTART_DIR" >/dev/null 2>&1 || true
rmdir "$LEGACY_AUTOSTART_DIR" >/dev/null 2>&1 || true
rm -f "$AUTOSTART_LOG_DIR"/launchagent.out.log "$AUTOSTART_LOG_DIR"/launchagent.err.log "$AUTOSTART_LOG_DIR"/autostart_wait.log "$AUTOSTART_LOG_DIR"/menubar_runtime.log
rm -f "$LEGACY_AUTOSTART_LOG_DIR"/launchagent.out.log "$LEGACY_AUTOSTART_LOG_DIR"/launchagent.err.log "$LEGACY_AUTOSTART_LOG_DIR"/autostart_wait.log "$LEGACY_AUTOSTART_LOG_DIR"/menubar_runtime.log
rmdir "$AUTOSTART_LOG_DIR" >/dev/null 2>&1 || true
rmdir "$LEGACY_AUTOSTART_LOG_DIR" >/dev/null 2>&1 || true

echo "[OK] Autostart disabled."
