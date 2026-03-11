#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${SVD_INSTALL_ROOT:-$HOME/Library/Application Support/FunASRDictation}"
RUNTIME_ROOT="$INSTALL_ROOT/python-runtime"
PYTHON_DIR="$RUNTIME_ROOT/python"
PYTHON_BIN="$PYTHON_DIR/bin/python3.11"
RELEASE_TAG="20260303"
VERSION="3.11.15+20260303"

emit_progress() {
  local percent="$1"
  shift
  echo "[Progress] $percent $*" >&2
}

pick_asset() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    arm64|aarch64)
      PYTHON_ARCHIVE="cpython-${VERSION}-aarch64-apple-darwin-install_only_stripped.tar.gz"
      PYTHON_SHA256="3ac3262428d899422dcf07ec0c69f8c99abc78ba36b497ffcb0f981d28ae0136"
      ;;
    x86_64)
      PYTHON_ARCHIVE="cpython-${VERSION}-x86_64-apple-darwin-install_only_stripped.tar.gz"
      PYTHON_SHA256="9038d161defcbedc0b723fa48f60890057d18a89167609d594299432f2e059f1"
      ;;
    *)
      echo "[ERROR] Unsupported macOS architecture: $arch"
      exit 1
      ;;
  esac
  PYTHON_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${RELEASE_TAG}/${PYTHON_ARCHIVE//+/%%2B}"
  PYTHON_URL="${PYTHON_URL//%%2B/%2B}"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[ERROR] This script only supports macOS."
  exit 1
fi

pick_asset

if [[ -x "$PYTHON_BIN" ]]; then
  if "$PYTHON_BIN" -V >/dev/null 2>&1; then
    emit_progress 32 "Using existing standalone Python runtime"
    echo "[OK] Standalone Python already available: $PYTHON_BIN" >&2
    echo "$PYTHON_BIN"
    exit 0
  fi
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[ERROR] curl is required to download the standalone Python runtime."
  exit 1
fi

TMP_DIR="$(mktemp -d /tmp/funasr-python-runtime.XXXXXX)"
ARCHIVE_PATH="$TMP_DIR/$PYTHON_ARCHIVE"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$INSTALL_ROOT"

emit_progress 24 "Downloading standalone Python runtime"
echo "[Step] Downloading standalone Python runtime" >&2
curl --fail --location --progress-bar "$PYTHON_URL" -o "$ARCHIVE_PATH"

actual_sha="$(shasum -a 256 "$ARCHIVE_PATH" | awk '{print $1}')"
if [[ "$actual_sha" != "$PYTHON_SHA256" ]]; then
  echo "[ERROR] Standalone Python checksum mismatch." >&2
  echo "Expected: $PYTHON_SHA256" >&2
  echo "Actual:   $actual_sha" >&2
  exit 1
fi

emit_progress 32 "Extracting standalone Python runtime"
echo "[Step] Extracting standalone Python runtime" >&2
rm -rf "$RUNTIME_ROOT"
mkdir -p "$RUNTIME_ROOT"
tar -xzf "$ARCHIVE_PATH" -C "$RUNTIME_ROOT"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "[ERROR] Standalone Python extracted, but executable not found: $PYTHON_BIN" >&2
  exit 1
fi

emit_progress 36 "Standalone Python runtime is ready"
echo "[OK] Standalone Python ready: $PYTHON_BIN" >&2
echo "$PYTHON_BIN"
