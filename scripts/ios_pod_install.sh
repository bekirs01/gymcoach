#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "CocoaPods kuruluyor..."
cd "$ROOT"
flutter pub get
cd "$ROOT/ios"
pod install --repo-update

echo ""
echo "Tamam. Xcode'da ios/Runner.xcworkspace dosyasını aç (Runner.xcodeproj değil)."
echo "Sonra Product → Clean Build Folder, ardından Run."
