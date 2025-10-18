#!/bin/bash

# Create DMG for iSee v0.1.0
APP_NAME="iSee"
VERSION="v0.1.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DMG="temp_${DMG_NAME}"

echo "🚀 Building iSee ${VERSION} DMG..."

# Clean up any existing DMG files
rm -f "${DMG_NAME}" "${TEMP_DMG}"

# Build the app in Release configuration
echo "📦 Building app in Release configuration..."
xcodebuild -project isee.xcodeproj -scheme isee -configuration Release -derivedDataPath ./build clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create release directory
mkdir -p release

# Copy the built app to release directory
echo "📋 Copying app to release directory..."
cp -R "./build/Build/Products/Release/isee.app" "./release/"

# Create temporary DMG
echo "💿 Creating temporary DMG..."
hdiutil create -srcfolder release -volname "${APP_NAME}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 100m "${TEMP_DMG}"

# Mount the DMG
echo "🔗 Mounting temporary DMG..."
MOUNT_DIR="/Volumes/${APP_NAME}"
hdiutil attach "${TEMP_DMG}" -readwrite -noverify -noautoopen

# Create Applications symlink
echo "📁 Creating Applications symlink..."
ln -s /Applications "${MOUNT_DIR}/Applications"

# Copy documentation files
echo "📄 Copying documentation..."
cp README.md "${MOUNT_DIR}/"
cp RELEASE_NOTES.md "${MOUNT_DIR}/"
cp DEPLOYMENT.md "${MOUNT_DIR}/"

# Unmount
echo "🔓 Unmounting temporary DMG..."
hdiutil detach "${MOUNT_DIR}"

# Convert to final DMG
echo "🎯 Converting to final DMG..."
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"

# Clean up
echo "🧹 Cleaning up..."
rm -f "${TEMP_DMG}"
rm -rf "./build"
rm -rf "./release"

echo ""
echo "✅ Successfully created ${DMG_NAME}"
echo "📦 Size: $(du -h "${DMG_NAME}" | cut -f1)"
echo "🎉 Ready for GitHub release!"
