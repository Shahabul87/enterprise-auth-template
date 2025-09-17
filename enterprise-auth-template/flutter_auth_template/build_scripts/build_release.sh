#!/bin/bash

# Build script with obfuscation and optimization

echo "Building Flutter app with obfuscation..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for Android with obfuscation
echo "Building Android APK with obfuscation..."
flutter build apk --obfuscate --split-debug-info=build/debug-info --release --target-platform android-arm,android-arm64,android-x64

# Build for Android App Bundle with obfuscation
echo "Building Android App Bundle with obfuscation..."
flutter build appbundle --obfuscate --split-debug-info=build/debug-info --release

# Build for iOS with obfuscation
echo "Building iOS with obfuscation..."
flutter build ios --obfuscate --split-debug-info=build/debug-info --release

echo "Build complete! Debug symbols saved in build/debug-info/"
echo "Remember to upload debug symbols to your crash reporting service."