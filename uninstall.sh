#!/usr/bin/env bash
set -e

APP_NAME="Star-runner"
INSTALL_SHARE="/usr/local/share/$APP_NAME"
INSTALL_BIN="/usr/local/bin/$APP_NAME"

if [ "$EUID" -ne 0 ]; then
  echo "⚠ Please run as root (e.g., sudo $0)"
  exit 1
fi

echo "Removing $APP_NAME…"

rm -f "$INSTALL_BIN"
rm -rf "$INSTALL_SHARE"

echo "✔ Removed."
