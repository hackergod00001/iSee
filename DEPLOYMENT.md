# iSee App - Deployment Guide for macOS

## Overview
iSee is a sophisticated privacy-first shoulder surfer detection app for macOS that uses on-device face detection to alert users when someone else is looking at their screen. Features include a beautiful Dynamic Island-style camera overlay, intelligent long-term threat detection, and comprehensive settings for maximum security and usability.

## System Requirements
- **macOS**: 13.0 (Ventura) or later
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel x64
- **Camera**: Built-in or external camera
- **Xcode**: 15.0 or later (for building from source)

## Quick Start (Pre-built App)

### Option 1: Download Pre-built App
1. Go to the [Releases](https://github.com/hackergod00001/iSee/releases) page
2. Download `iSee-v0.1.0.dmg` for the latest version
3. Open the downloaded DMG file
4. Drag iSee.app to your Applications folder
5. Launch iSee from Applications or Spotlight
6. Grant camera permission when prompted

### Option 2: Build from Source

#### Prerequisites
- Xcode 15.0 or later
- macOS 13.0 or later
- Git (for cloning the repository)

#### Build Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/hackergod00001/iSee.git
   cd iSee
   ```

2. **Open in Xcode:**
   ```bash
   open isee.xcodeproj
   ```

3. **Build and Run:**
   - Select your Mac as the target device
   - Press `Cmd + R` to build and run
   - Or use Product → Run from the menu

4. **Alternative: Command Line Build:**
   ```bash
   xcodebuild -project isee.xcodeproj -scheme isee -destination 'platform=macOS' build
   ```

## Usage Instructions

### First Launch
1. **Camera Permission**: The app will request camera access. Click "Allow" to enable face detection.
2. **Auto-start Monitoring**: The app automatically starts monitoring when launched (configurable in Settings).
3. **Menu Bar Icon**: Look for the eye icon in your menu bar - it will be green when safe.
4. **Positioning**: Position yourself in front of the camera so your face is clearly visible.

### Menu Bar Icon States
- **🟢 Green Eye**: Safe state - no unauthorized viewers detected
- **🟡 Yellow Eye**: Warning state - multiple faces detected, monitoring
- **🟠 Orange Eye**: Alert state - shoulder surfer detected (short-term)
- **🔴 Red Eye**: Long-term alert - shoulder surfer detected for >1 minute
- **⚫ Gray Eye**: Monitoring disabled or camera unavailable

### Testing the App
1. **Single Face Test**: Ensure only your face is visible - menu bar icon should be green
2. **Multi-Face Test**: Have someone else look at your screen - should trigger yellow/orange/red states
3. **Dynamic Island Overlay**: Click "Toggle Camera Feed" to see the beautiful camera overlay
4. **Settings**: Click "Settings..." to access comprehensive configuration options
5. **Notifications**: Test system notifications by triggering alerts (requires notification permission)

### Privacy & Security
- **100% On-Device Processing**: All face detection happens locally
- **No Data Storage**: No images or face data are stored or transmitted
- **No Network Access**: The app operates entirely offline
- **Camera Access Only**: The app only accesses the camera, no other permissions

## Troubleshooting

### Common Issues

#### Camera Not Working
- **Check Permissions**: Go to System Preferences → Security & Privacy → Camera
- **Restart App**: Quit and relaunch iSee
- **Check Camera**: Ensure no other apps are using the camera

#### Face Detection Not Working
- **Lighting**: Ensure good lighting conditions
- **Position**: Make sure your face is clearly visible to the camera
- **Distance**: Stay within 1-3 feet of the camera for best results

#### App Won't Launch
- **macOS Version**: Ensure you're running macOS 13.0 or later
- **Architecture**: Check if you're using a supported Mac (Apple Silicon or Intel)
- **Permissions**: Check System Preferences → Security & Privacy → General

### Performance Tips
- **Close Other Apps**: Free up system resources for better performance
- **Good Lighting**: Face detection works best in well-lit environments
- **Stable Position**: Avoid moving around too much while using the app

## Development

### Project Structure
```
isee/
├── iseeApp.swift                   # App entry point with MenuBarExtra
├── AppDelegate.swift               # Background app lifecycle management
├── MenuBarController.swift         # Menu bar icon and interaction logic
├── MenuBarView.swift               # Menu bar dropdown interface
├── BackgroundMonitoringService.swift # Core monitoring orchestration
├── CameraOverlayWindow.swift       # Dynamic Island overlay window
├── CameraOverlayView.swift         # Camera feed with glassmorphism design
├── NotificationManager.swift       # Enhanced system notification handling
├── PreferencesManager.swift        # User settings and state persistence
├── LaunchAtLoginManager.swift      # Auto-launch functionality
├── SettingsWindow.swift            # Settings window management
├── SettingsView.swift              # Comprehensive settings interface
├── CameraManager.swift             # Camera handling and permissions
├── VisionProcessor.swift           # Face detection processing
├── StateController.swift           # Security state management
├── Info.plist                      # App configuration
├── Preview Content/                # SwiftUI preview assets
└── isee.xcodeproj/                 # Xcode project file
```

### Key Features
- **Real-time Face Detection**: Uses Apple's Vision framework with optimized performance
- **Dynamic Island Overlay**: Beautiful liquid-expanding camera feed with glassmorphism
- **Menu Bar Integration**: Clean, minimal interface that doesn't clutter your screen
- **Enhanced Notifications**: Descriptive alerts with actionable buttons and rate limiting
- **Comprehensive Settings**: Full control over detection sensitivity and preferences
- **Long-term Threat Detection**: Red menu bar icon when shoulder surfing persists >1 minute
- **Auto-start Monitoring**: Begins protection immediately when app launches
- **Launch at Login**: Optional automatic startup for continuous protection
- **Privacy-First**: 100% on-device processing, no data collection or network access

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on macOS
5. Submit a pull request

## License
This project is open source. See the main README for license details.

## Support
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/hackergod00001/iSee/issues)
- **Discussions**: Join the conversation on [GitHub Discussions](https://github.com/hackergod00001/iSee/discussions)

## Version History
- **v0.0.1**: Initial pre-release with basic face detection and alerts
- **v0.1.0**: Major update with Dynamic Island overlay, enhanced notifications, comprehensive settings, and long-term threat detection
