#!/bin/bash
set -e

BUILD_DIR=build/ios
PROJECT=Glucocalc.xcodeproj
SCHEME=Glucocalc
TEAM=9Q77WK7W3R
BUNDLE=com.jocala.glucocalc
DEVICE=${1:-jpad}

echo "=== Building Glucocalc for iOS ==="
xcodegen generate 2>/dev/null

xcodebuild -project "$PROJECT" -scheme "$SCHEME" -sdk iphoneos \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$BUILD_DIR" \
  DEVELOPMENT_TEAM="$TEAM" build

echo ""
echo "=== Installing to $DEVICE ==="
xcrun devicectl device install app --device "$DEVICE" "$BUILD_DIR/Build/Products/Debug-iphoneos/Glucocalc.app"

echo ""
echo "=== Launching ==="
xcrun devicectl device process launch --device "$DEVICE" "$BUNDLE"

echo ""
echo "Done!"
