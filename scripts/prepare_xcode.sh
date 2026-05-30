#!/usr/bin/env bash
# Xcode ile çalışmadan önce bir kez çalıştırın.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "→ flutter pub get"
flutter pub get

echo "→ pod install (simülatör + ML Kit düzeltmeleri uygulanır)"
cd ios
pod install
cd ..

echo ""
echo "✓ Hazır."
echo ""
echo "Xcode'da ŞUNU aç:"
echo "  $ROOT/ios/Runner.xcworkspace"
echo ""
echo "ŞUNU AÇMA:"
echo "  ios/Runner.xcodeproj   ← Flutter.h hatası verir"
echo ""
echo "Xcode'da:"
echo "  1) Product → Clean Build Folder (⇧⌘K)"
echo "  2) iPhone simülatör seç"
echo "  3) Run (⌘R)"
echo ""
echo "Not: Her 'flutter pub get' sonrası pod install otomatik önerilir."
echo "     Simülatörde ML Kit (pose) kapalı; gerçek cihazda çalışır."
