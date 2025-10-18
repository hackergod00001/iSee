#!/bin/bash

# Create DMG for iSee v0.0.1
APP_NAME="iSee"
VERSION="v0.0.1"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DMG="temp_${DMG_NAME}"

# Clean up any existing DMG files
rm -f "${DMG_NAME}" "${TEMP_DMG}"

# Create temporary DMG
hdiutil create -srcfolder release -volname "${APP_NAME}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 100m "${TEMP_DMG}"

# Mount the DMG
MOUNT_DIR="/Volumes/${APP_NAME}"
hdiutil attach "${TEMP_DMG}" -readwrite -noverify -noautoopen

# Create Applications symlink
ln -s /Applications "${MOUNT_DIR}/Applications"

# Copy README
cp README.md "${MOUNT_DIR}/"

# Unmount
hdiutil detach "${MOUNT_DIR}"

# Convert to final DMG
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"

# Clean up
rm -f "${TEMP_DMG}"

echo "✅ Created ${DMG_NAME}"
echo "📦 Size: $(du -h "${DMG_NAME}" | cut -f1)"
