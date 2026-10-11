#!/bin/bash
# Builds build/MouseTune.app.
#   SIGN_IDENTITY  codesign identity (default "-" = ad hoc)
#   VERSION        marketing version (default: contents of version.txt)
#   BUILD_NUMBER   CFBundleVersion (default: 1)
#   --zip          also create build/MouseTune.zip
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${VERSION:-$(tr -d '[:space:]' < version.txt)}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"

swift build -c release
BIN="$(swift build -c release --show-bin-path)/MouseTune"

APP=build/MouseTune.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/MouseTune"
cp Info.plist "$APP/Contents/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP/Contents/Info.plist"

codesign --force --deep --sign "${SIGN_IDENTITY:--}" "$APP"

if [[ "${1:-}" == "--zip" ]]; then
    ditto -c -k --keepParent "$APP" build/MouseTune.zip
    echo "Zip: $(pwd)/build/MouseTune.zip"
fi

echo
echo "Done: $(pwd)/$APP (v$VERSION)"
echo "Install: cp -R build/MouseTune.app /Applications/ && open /Applications/MouseTune.app"
