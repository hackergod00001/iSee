# Release Workflow for iSee

## Overview

This document outlines the proper workflow for creating and distributing iSee releases without storing binary files in the git repository.

## Why DMG Files Are Not in Repository

- **Repository Size**: Binary files bloat the repository and slow down clones
- **Version Control**: Binary files don't benefit from git's diff/merge capabilities
- **Storage Efficiency**: GitHub releases provide better storage for binary assets
- **Security**: Prevents accidental inclusion of large binary files in commits

## Release Process

### 1. Prepare Release

```bash
# Ensure all changes are committed
git status

# Update version numbers in:
# - RELEASE_NOTES.md
# - create_dmg.sh (VERSION variable)
# - Any version references in code
```

### 2. Create DMG Locally

```bash
# Make script executable
chmod +x create_dmg.sh

# Build and create DMG
./create_dmg.sh
```

This will create `iSee-v0.1.0.dmg` locally (not committed to git).

### 3. Create GitHub Release

1. **Go to GitHub**: https://github.com/hackergod00001/iSee
2. **Click "Releases"** → **"Create a new release"**
3. **Fill in details**:
   - **Tag**: `v0.1.0` (must match version in create_dmg.sh)
   - **Title**: `iSee v0.1.0 - Dynamic Island & Enhanced Features`
   - **Description**: Copy content from `RELEASE_NOTES.md`
4. **Attach DMG**: Drag and drop `iSee-v0.1.0.dmg` to the release
5. **Publish Release**

### 4. Clean Up

```bash
# Remove local DMG file (optional)
rm iSee-v0.1.0.dmg

# Push any remaining changes
git push origin main:master
git push origin main
```

## File Structure

```
isee/
├── create_dmg.sh          # Script to build DMG locally
├── RELEASE_NOTES.md       # Release documentation
├── RELEASE_WORKFLOW.md    # This file
├── README.md              # Project documentation
├── DEPLOYMENT.md          # Usage instructions
└── .gitignore             # Excludes *.dmg files
```

## Benefits of This Approach

1. **Clean Repository**: Only source code and documentation
2. **Fast Clones**: No large binary files to download
3. **Proper Releases**: DMG files attached to GitHub releases
4. **Version Control**: Each release has its own DMG
5. **Easy Distribution**: Users download from releases page

## For Contributors

- **Never commit DMG files** - they're automatically ignored
- **Use create_dmg.sh** to build locally for testing
- **Create releases through GitHub** for distribution
- **Update RELEASE_NOTES.md** for each new version

## For Users

- **Download from GitHub Releases**: https://github.com/hackergod00001/iSee/releases
- **Latest version**: Always available on the releases page
- **Installation**: Drag DMG to Applications folder
- **Documentation**: Included in each release

## Automation (Future)

Consider implementing GitHub Actions to:
- Automatically build DMG on tag creation
- Attach DMG to releases automatically
- Run tests before building
- Sign the app for distribution

This would eliminate the need for manual DMG creation and uploading.
