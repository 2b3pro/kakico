#!/bin/bash
# Builds Snapmark.app — a native arm64, ad-hoc-signed macOS app bundle.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${1:-release}"
APP="$ROOT/build/Snapmark.app"

echo "==> swift build -c $CONFIG"
cd "$ROOT"
swift build -c "$CONFIG"

BIN="$(swift build -c "$CONFIG" --show-bin-path)/Snapmark"
if [[ ! -f "$BIN" ]]; then
    echo "error: built binary not found at $BIN" >&2
    exit 1
fi

echo "==> assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Snapmark"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

echo "==> ad-hoc code signing"
codesign --force --deep --sign - "$APP"

echo "==> verifying"
codesign --verify --verbose "$APP"
echo "arch: $(lipo -archs "$APP/Contents/MacOS/Snapmark")"
echo "Built: $APP"
