#!/bin/bash

# Create DMG for iSee - Version extracted dynamically from README.md
APP_NAME="iSee"

# Extract version from README.md
if [ -f "README.md" ]; then
    VERSION=$(grep -m 1 "\*\*Version\*\*:" README.md | sed 's/.*\*\*Version\*\*: //' | xargs)
    # Convert spaces to hyphens and convert to lowercase
    VERSION=$(echo "$VERSION" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    echo "📋 Version extracted: ${VERSION}"
else
    # Fallback to default version if README.md not found
    VERSION="v1.0.0"
    echo "⚠️  README.md not found, using default version: ${VERSION}"
fi

DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DMG="temp_${DMG_NAME}"

echo "🚀 Building iSee ${VERSION} DMG..."
echo "📋 Version extracted from README.md"

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

# Wait for mount to complete
sleep 2

# Create Applications symlink
echo "📁 Creating Applications symlink..."
ln -s /Applications "${MOUNT_DIR}/Applications"

# Copy documentation files
echo "📄 Copying documentation..."
if [ -f "README.md" ]; then
    cp README.md "${MOUNT_DIR}/" 2>/dev/null || echo "⚠️  Could not copy README.md (read-only filesystem)"
fi
if [ -f "RELEASE_NOTES.md" ]; then
    cp RELEASE_NOTES.md "${MOUNT_DIR}/" 2>/dev/null || echo "⚠️  Could not copy RELEASE_NOTES.md (read-only filesystem)"
fi
if [ -f "DEPLOYMENT.md" ]; then
    cp DEPLOYMENT.md "${MOUNT_DIR}/" 2>/dev/null || echo "⚠️  Could not copy DEPLOYMENT.md (read-only filesystem)"
fi

# Unmount
echo "🔓 Unmounting temporary DMG..."
hdiutil detach "${MOUNT_DIR}"

# Convert to final DMG
echo "🎯 Converting to final DMG..."
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"

# Check if DMG creation was successful
if [ $? -ne 0 ]; then
    echo "❌ DMG conversion failed!"
    exit 1
fi

# Move DMG to releases folder
echo "📁 Moving DMG to releases folder..."
mkdir -p releases
mv "${DMG_NAME}" "releases/"

# Clean up
echo "🧹 Cleaning up..."
rm -f "${TEMP_DMG}"
rm -rf "./build"
rm -rf "./release"

echo ""
echo "✅ Successfully created releases/${DMG_NAME}"
echo "📦 Size: $(du -h "releases/${DMG_NAME}" | cut -f1)"
echo "🎉 Ready for GitHub release!"
