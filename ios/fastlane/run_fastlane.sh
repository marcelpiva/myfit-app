#!/bin/bash
# Build and upload script that avoids Ruby version conflicts
# Usage: ./run_fastlane.sh beta

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="$(dirname "$IOS_DIR")"

cd "$IOS_DIR"

case "$1" in
  beta)
    echo "==> Incrementing build number..."
    BUILD_NUMBER=$(date +%Y%m%d%H%M)
    agvtool new-version -all "$BUILD_NUMBER"

    echo "==> Running pod install..."
    cd "$IOS_DIR"
    pod install

    echo "==> Building IPA with production environment..."
    cd "$APP_DIR"
    flutter build ipa --release --dart-define=ENV=prod --export-options-plist=ios/ExportOptions.plist

    echo "==> Uploading to TestFlight..."
    cd "$IOS_DIR"
    xcrun altool --upload-app --type ios \
      -f "$APP_DIR/build/ios/ipa/My Fit.ipa" \
      --apiKey T64HTCDT7X \
      --apiIssuer 69a6de78-3c62-47e3-e053-5b8c7c11a4d1

    echo "==> Successfully uploaded to TestFlight!"
    ;;
  upload_only)
    echo "==> Uploading to TestFlight..."
    xcrun altool --upload-app --type ios \
      -f "$APP_DIR/build/ios/ipa/My Fit.ipa" \
      --apiKey T64HTCDT7X \
      --apiIssuer 69a6de78-3c62-47e3-e053-5b8c7c11a4d1

    echo "==> Successfully uploaded to TestFlight!"
    ;;
  *)
    echo "Usage: $0 {beta|upload_only}"
    exit 1
    ;;
esac
