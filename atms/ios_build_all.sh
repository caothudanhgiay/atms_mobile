#!/bin/bash

# =======================================================
# HUONG DAN CHAY FILE NAY:
# 1. Mo Terminal tren MacOS tai thu muc goc cua project.
# 2. Cap quyen thuc thi (neu chua co): chmod +x ios_build_all.sh
# 3. Chay lenh: ./ios_build_all.sh
# =======================================================

echo "======================================================="
echo "STARTING BUILD PROCESS FOR ANDROID & IOS"
echo "======================================================="

# 1. Clean & Pub get
flutter clean
flutter pub get

# 2. Build Android
#echo "Building Android..."
#flutter build apk --release
#flutter build appbundle --release

# 3. Build iOS (File .ipa để deploy App Store/TestFlight)
echo "Building iOS IPA..."

# Lấy versionName và versionCode từ Xcode project
VERSION_NAME=$(grep -m 1 "MARKETING_VERSION" ios/Runner.xcodeproj/project.pbxproj | cut -d'=' -f2 | tr -d ' ;' | xargs)
VERSION_CODE=$(grep -m 1 "CURRENT_PROJECT_VERSION" ios/Runner.xcodeproj/project.pbxproj | cut -d'=' -f2 | tr -d ' ;' | xargs)

echo "Version Name: $VERSION_NAME"
echo "Version Code: $VERSION_CODE"

# Lệnh này sẽ tạo ra folder build/ios/ipa/
flutter build ipa --release --export-method app-store

# 4. Copy và đổi tên file IPA
OUTPUT_DIR="build_output"
mkdir -p $OUTPUT_DIR

# Tìm file .ipa bất kỳ trong thư mục build/ios/ipa
IPA_SOURCE=$(find build/ios/ipa -name "*.ipa" -type f | head -n 1)
IPA_DEST="$OUTPUT_DIR/atms${VERSION_NAME}(${VERSION_CODE}).ipa"

if [ -n "$IPA_SOURCE" ] && [ -f "$IPA_SOURCE" ]; then
    cp "$IPA_SOURCE" "$IPA_DEST"
    echo "IPA found: $IPA_SOURCE"
    echo "IPA copied to: $IPA_DEST"
else
    echo "Error: No .ipa file found in build/ios/ipa/"
    echo "Check if 'flutter build ipa' completed successfully."
fi

echo "======================================================="
echo "BUILD COMPLETED!"
echo "-------------------------------------------------------"
#echo "ANDROID APK:  build/app/outputs/flutter-apk/app-release.apk"
#echo "ANDROID AAB:  build/app/outputs/bundle/release/app-release.aab"
echo "IOS IPA:      $IPA_DEST"
echo "======================================================="
