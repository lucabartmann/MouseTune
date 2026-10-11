#!/bin/bash
# Packages build/MouseTune.app into build/dist/{zip,dmg,SHA256SUMS}.
# Usage: scripts/package.sh [version]   (default: version.txt)
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-$(tr -d '[:space:]' < version.txt)}"
APP=build/MouseTune.app
DIST=build/dist
[[ -d "$APP" ]] || { echo "Run ./build.sh first" >&2; exit 1; }

rm -rf "$DIST" && mkdir -p "$DIST"
ditto -c -k --keepParent "$APP" "$DIST/MouseTune-$VERSION.zip"

STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "MouseTune" -srcfolder "$STAGE" -ov -format UDZO "$DIST/MouseTune-$VERSION.dmg" >/dev/null
rm -rf "$STAGE"

(cd "$DIST" && shasum -a 256 MouseTune-* > SHA256SUMS)
ls -lh "$DIST"
