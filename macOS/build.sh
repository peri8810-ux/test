#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_PATH="$WORKSPACE_DIR/Kostenklar.app"
BUILD_DIR="$(/usr/bin/mktemp -d "$WORKSPACE_DIR/.kostenklar-build.XXXXXX")"
TEMP_APP="$BUILD_DIR/Kostenklar.app"
trap 'rm -rf "$BUILD_DIR"' EXIT

if [[ ! -f "$WORKSPACE_DIR/MarioTestapp.html" ]]; then
  echo "Fehler: MarioTestapp.html wurde nicht gefunden." >&2
  exit 1
fi

/usr/bin/osacompile -o "$TEMP_APP" "$SCRIPT_DIR/launcher.applescript"
cp "$WORKSPACE_DIR/MarioTestapp.html" "$TEMP_APP/Contents/Resources/MarioTestapp.html"
/usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string ch.kostenklar.app' "$TEMP_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string Kostenklar' "$TEMP_APP/Contents/Info.plist"
/usr/bin/codesign --force --deep --sign - "$TEMP_APP"

if [[ -e "$APP_PATH" ]]; then
  if [[ ! -f "$APP_PATH/Contents/Info.plist" ]]; then
    echo "Fehler: Am Ausgabeort liegt keine Kostenklar-App." >&2
    exit 1
  fi
  /bin/rm -rf "$APP_PATH"
fi
/bin/mv "$TEMP_APP" "$APP_PATH"
echo "Kostenklar.app wurde erstellt: $APP_PATH"
