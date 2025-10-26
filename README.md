# iSee - Advanced Shoulder Surfer Detection App

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-Beta%20V1.0.0-brightgreen.svg)](https://github.com/hackergod00001/iSee/releases)

iSee is a sophisticated macOS menu bar application that provides real-time shoulder surfer detection using your MacBook's camera. It runs silently in the background and alerts you when someone is looking at your screen, featuring intelligent long-term threat detection, a beautiful Dynamic Island-style notch integration, and comprehensive privacy-first security features.

---
> [!IMPORTANT]
> We don't have an Apple Developer account yet. The application will show a popup on first launch that the app is from an unidentified developer.
> 1. Click **OK** to close the popup.
> 2. Open **System Settings** > **Privacy & Security**.
> 3. Scroll down and click **Open Anyway** next to the warning about the app.
> 4. Confirm your choice if prompted.
>
> You only need to do this once.

## 🚀 Quick Start

### Download & Install
1. Go to [Releases](https://github.com/hackergod00001/iSee/releases)
2. Download `iSee-Beta-V1.0.0.dmg`
3. Install and launch the app
4. Grant camera permission when prompted

### Build from Source
```bash
git clone https://github.com/hackergod00001/iSee.git
cd iSee
open isee.xcodeproj
# Press Cmd+R to build and run
```

## 🎯 Key Features

### 🔍 **Intelligent Detection**
- **Real-time Face Detection**: Uses Apple's Vision framework for accurate detection
- **Long-term Threat Detection**: Menu bar icon turns red when shoulder surfing persists for >1 minute
- **Smart State Management**: Color-coded menu bar icon (Green/Yellow/Orange/Red/Gray)
- **Configurable Thresholds**: Customizable alert timing and sensitivity
- **Rate-limited Notifications**: Prevents notification spam with intelligent cooldown periods

### 🎨 **Beautiful Interface**
- **Dynamic Island Notch Integration**: Camera feed displays in Mac's notch area with smooth animations
- **Matte Black Design**: Seamlessly blends with the notch for a native macOS appearance
- **Menu Bar Integration**: Clean, minimal interface that doesn't clutter your screen
- **Auto-dismissing Overlay**: Camera feed automatically hides after configurable delay (5-30 seconds)
- **Smooth Animations**: Liquid expansion with spring-based animations
- **macOS-style Controls**: Red close button (Mac-style), settings gear, and notification toggle in header
- **Notification Popups**: In-notch notifications with actionable dropdown menus (Preview/Acknowledge)

### 🔒 **Privacy & Security**
- **100% On-Device Processing**: All face detection happens locally
- **No Data Collection**: No images or face data are stored or transmitted
- **Background Operation**: Runs silently without interfering with your work
- **Launch at Login**: Optional automatic startup for continuous protection
- **No Network Access**: Completely offline operation

### ⚙️ **Advanced Controls**
- **Comprehensive Settings**: Fine-tune detection sensitivity and notification preferences
- **Enhanced System Notifications**: Descriptive alerts with actionable buttons
- **Auto-start Monitoring**: Begin protection immediately when app launches
- **Persistent State**: Remembers your preferences across app restarts
- **Alert Cooldown Period**: Configurable time between notifications (1-10 seconds)

## 🎯 Vision & Goal

**Vision**: To create a sophisticated, privacy-first macOS utility that provides seamless shoulder surfer detection through an elegant menu bar interface, enhancing personal data security in professional and public environments.

**Current Goal**: A fully-featured macOS menu bar application with intelligent threat detection, beautiful Dynamic Island-style overlays, and comprehensive user controls for maximum security and usability.

## 🏗️ Architecture

### Core Components

1. **BackgroundMonitoringService** - Orchestrates camera, vision processing, and state management
2. **MenuBarController** - Manages menu bar icon states and user interactions
3. **CameraNotchManager** - Integrates camera feed with NotchNotification framework for Dynamic Island display
4. **NotchNotification Framework** - Custom framework for Mac notch integration (10 files)
5. **NotificationManager** - Handles in-notch notifications with rate limiting and actionable menus
6. **PreferencesManager** - Manages user settings and app state persistence
7. **VisionProcessor** - Analyzes video frames for face detection using Apple's Vision framework
8. **StateController** - Manages security states and implements shoulder surfer detection logic
9. **CameraManager** - Handles AVFoundation camera session and video preview layer
10. **CameraOverlayView** - Provides camera preview and face detection overlay views

### Technology Stack

- **Platform**: macOS 13.0+ (optimized for MacBooks with notch)
- **Language**: Swift 5
- **UI Framework**: SwiftUI + AppKit (NSViewRepresentable for camera preview)
- **Computer Vision**: Apple Vision Framework (VNDetectFaceRectanglesRequest)
- **Camera**: Apple AVFoundation Framework (AVCaptureSession, AVCaptureVideoPreviewLayer)
- **Notifications**: Custom NotchNotification framework for in-notch alerts
- **Background Processing**: NSApplicationDelegate + Combine framework
- **State Management**: Combine publishers and observers

## 🔒 Privacy & Security

- **100% On-Device Processing**: All face detection happens locally using Apple's Vision framework
- **No Data Storage**: No images or face data are stored or transmitted
- **No Network Access**: The app operates entirely offline
- **Transparent Permissions**: Clear explanation of camera usage in privacy policy
- **Open Source**: Full source code available for security audit
- **No Tracking**: No analytics, telemetry, or user tracking

## 🚀 Features

### Core Functionality
- Real-time face detection using front-facing camera with Vision framework
- Multi-face detection with visual bounding boxes in camera feed
- Timer-based alert system (2-second threshold for shoulder surfer detection)
- In-notch notifications with actionable dropdown menus (Preview/Acknowledge)
- Privacy-first design with 100% on-device processing

### User Interface
- Dynamic Island-style notch integration for camera feed
- Live camera preview with face detection overlays (433x260 pixels)
- Color-coded menu bar icon (Green/Yellow/Orange/Red/Gray states)
- In-notch notification popups with Preview and Acknowledge actions
- Settings window for customization and configuration
- Non-intrusive design that blends seamlessly with macOS

### Performance Optimizations
- Frame rate limiting (5 FPS processing with 200ms intervals)
- Frame skipping (processes every 3rd frame for battery efficiency)
- Edge case handling for temporary detection failures (up to 10 consecutive zero-face detections)
- Optimized Vision framework usage (VNDetectFaceRectanglesRequest Revision 3)
- Asynchronous processing queue for non-blocking UI

## 📱 Usage

1. **Launch the app** - It will appear in your menu bar as an eye icon
2. **Grant camera permission** when prompted
3. **Start monitoring** by clicking the menu bar icon and selecting "Start Monitoring"
4. **Monitor the icon color** - it changes based on security state:
   - **🟢 Green**: Safe (no shoulder surfers detected)
   - **🟡 Yellow**: Warning (multiple faces detected)
   - **🟠 Orange**: Alert (shoulder surfer detected, < 1 minute)
   - **🔴 Red**: Long-term alert (shoulder surfer detected for > 1 minute)
   - **⚫ Gray**: Monitoring disabled
5. **View camera feed** by clicking "Toggle Camera Feed" to see the Dynamic Island overlay
6. **Configure settings** by clicking "Settings..." to customize detection and notifications

### Menu Bar Icon States

- **🟢 Green Eye**: Safe state - no unauthorized viewers detected
- **🟡 Yellow Eye**: Warning state - multiple faces detected, monitoring
- **🟠 Orange Eye**: Alert state - shoulder surfer detected (short-term)
- **🔴 Red Eye**: Long-term alert - shoulder surfer detected for >1 minute
- **⚫ Gray Eye**: Monitoring disabled or camera unavailable

### Dynamic Island Notch Features

- **Seamless Notch Integration**: Camera feed displays directly in Mac's notch area
- **Curved Corner Design**: Custom NotchRectangle shape matches notch curvature perfectly
- **Matte Black Background**: Fully opaque black design blends with the notch
- **Mac-style Header Controls**: 
  - Red X close button (left-most, Mac-style positioning)
  - Settings gear icon (right side)
  - Notification toggle bell (right side, changes color when muted/unmuted)
- **Camera Feed**: 433x260 pixels (5:3 aspect ratio) with mirrored selfie view
- **Face Detection Overlays**: Real-time bounding boxes showing detected faces
- **Auto-dismiss**: Configurable delay (5-30 seconds, default 10 seconds)
- **Notification Popups**: In-notch alerts with dropdown menu (Preview/Acknowledge actions)
- **Width Consistency**: Both camera island and notification popups use same 443px width

## 🛠️ Development

### Getting Started

1. **Clone the repository**: `git clone https://github.com/hackergod00001/iSee.git`
2. **Open the project**: Open `isee.xcodeproj` in Xcode 15.0+
3. **Select target**: Choose "My Mac" as the run destination
4. **Build and run**: Press Cmd+R to build and run the app
5. **Grant permissions**: Allow camera and notification access when prompted

### Project Structure

```
isee/
├── iseeApp.swift                      # App entry point with MenuBarExtra
├── AppDelegate.swift                  # Background app lifecycle management
├── MenuBarController.swift            # Menu bar icon and interaction logic
├── MenuBarView.swift                  # Menu bar dropdown interface
├── BackgroundMonitoringService.swift  # Core monitoring orchestration
├── CameraNotchManager.swift           # Notch integration manager
├── CameraOverlayView.swift            # Camera preview and face overlay views
├── CameraManager.swift                # AVFoundation camera session handling
├── VisionProcessor.swift              # Face detection using Vision framework
├── StateController.swift              # Security state management logic
├── NotificationManager.swift          # In-notch notification handling
├── PreferencesManager.swift           # User settings and state persistence
├── LaunchAtLoginManager.swift         # Auto-launch functionality
├── SettingsWindow.swift               # Settings window management
├── SettingsView.swift                 # Comprehensive settings interface
├── Info.plist                         # App configuration and permissions
├── NotchNotification/                 # Custom notch integration framework
│   ├── NotchNotification.swift        # Framework entry point
│   ├── NotchViewModel.swift           # Notch state management
│   ├── NotificationContext.swift      # Notch presentation context
│   ├── NotchView.swift                # Main notch view with animations
│   ├── NotchWindow.swift              # Custom borderless window
│   ├── NotchWindowController.swift    # Window lifecycle management
│   ├── NotchViewController.swift      # View controller for notch
│   ├── NotchContentView.swift         # Content layout view
│   ├── NotchHeaderView.swift          # Header layout view
│   ├── Ext+NSScreen.swift             # NSScreen extensions for notch detection
│   └── NotchRectangle.swift           # Custom shape for curved corners
└── isee.xcodeproj/                    # Xcode project file
```

### Key Classes

#### BackgroundMonitoringService
- Central orchestrator for all monitoring activities
- Manages camera, vision processor, and state controller lifecycle
- Handles overlay showing/hiding based on security state
- Tracks long-term alert duration (>1 minute triggers red icon)
- Auto-starts monitoring on app launch if configured

#### CameraNotchManager
- Integrates camera feed with NotchNotification framework
- Creates and manages the notch-based camera overlay
- Handles notification popups with actionable dropdowns
- Provides reactive notification toggle button
- Ensures consistent 443px width for all notch elements

#### CameraManager
- Manages AVFoundation camera session (AVCaptureSession)
- Handles camera permission requests and authorization
- Provides AVCaptureVideoPreviewLayer for live preview
- Configures video mirroring for front-facing camera
- Delegates video frames to VisionProcessor

#### VisionProcessor
- Processes camera frames using Vision framework (VNDetectFaceRectanglesRequest)
- Implements performance optimizations (5 FPS processing rate)
- Provides face count and normalized bounding box coordinates
- Publishes face observations via Combine publishers
- Handles edge cases and camera processing errors

#### StateController
- Implements core shoulder surfer detection logic
- Manages state transitions: safe → warning → alert
- Timer-based alert triggering (2-second threshold by default)
- Handles edge cases (temporary zero face detections)
- Provides computed properties for UI (statusMessage, alertProgress)

#### NotificationManager
- Handles in-notch notifications using NotchNotification framework
- Implements rate limiting (5-second cooldown between notifications)
- Creates actionable notification popups with Preview/Acknowledge menus
- Integrates with BackgroundMonitoringService for camera overlay
- Manages macOS system notification permissions (fallback)

## 🧪 Testing

The app includes a comprehensive settings panel for configuration:

**Notifications:**
- Enable/disable in-notch notifications
- Request notification permissions (if not authorized)
- Adjust auto-hide delay (5-30 seconds, slider control)

**Monitoring:**
- Auto-start monitoring on app launch
- Launch at login configuration

**Detection:**
- Alert threshold slider (1-10 seconds, adjusts detection sensitivity)

**Real-time Status (Menu Bar):**
- View current security state
- Monitor real-time face count
- Toggle camera feed to see face detection in action

**Testing Guide:**
For detailed testing procedures, see [TESTING_GUIDE.md](TESTING_GUIDE.md)

## 📋 Requirements

### System Requirements
- macOS 13.0 or later (Ventura+)
- MacBook with notch (MacBook Pro 14"/16" 2021+) for optimal experience
- Built-in FaceTime HD camera or compatible external camera
- At least 4GB RAM recommended

### Permissions Required
- **Camera Access**: Required for face detection (requested on first launch)
- **Notification Access**: Optional for system notifications (in-notch notifications work without this)

## 🔧 Configuration

### App Configuration

- **Bundle Identifier**: `com.isee.app`
- **App Name**: iSee
- **Minimum macOS Version**: 13.0
- **Target Devices**: MacBook, iMac, Mac Studio, Mac Pro

### Adjustable Parameters

**Detection & Alerts:**
- **Alert Threshold**: 2.0 seconds (time before shoulder surfer alert triggers)
- **Long-term Alert Duration**: 60 seconds (triggers red menu bar icon for persistent threats)
- **Processing Rate**: ~5 FPS (optimized for battery efficiency)
- **Face Detection**: Vision framework with edge case handling (up to 10 consecutive zero-face detections)

**Notifications:**
- **Notification Rate Limiting**: 5 seconds cooldown between in-notch notifications
- **Auto-hide Delay**: 10 seconds default (configurable 5-30 seconds in Settings)
- **Notification Actions**: Preview (shows camera feed) and Acknowledge (dismisses)

**Camera & Overlay:**
- **Camera Feed Size**: 433x260 pixels (5:3 aspect ratio)
- **Island Width**: 443 pixels (includes 5px horizontal padding)
- **Island Height**: 346 pixels (32px header + 10px top + 260px content + 10px bottom + padding)
- **Video Mirroring**: Enabled by default for selfie-style view

**Startup & Persistence:**
- **Auto-start Monitoring**: Configurable in Settings (default: enabled)
- **Launch at Login**: Optional for continuous protection
- **State Persistence**: All preferences saved to UserDefaults

## 🚧 Limitations & Future Enhancements

### Current Limitations
- **Lighting Dependency**: Requires adequate lighting for accurate face detection
- **Notch Optimization**: UI designed for MacBooks with notch (works on other Macs but less optimized)
- **False Positives**: May detect photos, reflections, or monitor displays as faces
- **Battery Impact**: Continuous camera processing increases battery consumption
- **Single Camera**: Currently supports one camera at a time (front-facing preferred)
- **Face Detection Only**: Uses basic face rectangle detection, not facial recognition

### Potential Enhancements

**Short-term (Next Release):**
- Performance metrics dashboard (CPU, memory, battery usage)
- Detection accuracy statistics and logging
- Customizable alert thresholds per user
- Dark/Light theme support for settings

**Long-term Roadmap:**
- Machine learning model for improved accuracy and fewer false positives
- Multi-camera support (external cameras, different angles)
- Screen content privacy features (automatic screen blur when alert triggers)
- macOS Focus mode integration (automatic monitoring based on focus state)
- Customizable notch themes and animations
- Cloud sync for preferences across multiple Macs
- Advanced analytics dashboard with detection history
- Privacy zone configuration (ignore specific people/faces)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

### Development Setup
1. **Fork the repository** on GitHub
2. **Clone your fork**: `git clone https://github.com/YOUR_USERNAME/iSee.git`
3. **Create a feature branch**: `git checkout -b feature/your-feature-name`
4. **Make your changes** following the coding standards in CONTRIBUTING.md
5. **Add header comments** to new Swift files (see existing files for format)
6. **Test thoroughly** on macOS with notch (or without notch if unavailable)
7. **Commit your changes**: `git commit -m "Description of changes"`
8. **Push to your fork**: `git push origin feature/your-feature-name`
9. **Submit a pull request** with detailed description

### Coding Standards
- All new Swift files must include header comments (see CONTRIBUTING.md)
- Follow Swift naming conventions and code style
- Use Combine for reactive programming patterns
- Document complex logic and algorithms
- Write clear commit messages

### Documentation
- **Architecture**: See [COMPLETE_LOGIC_DOCUMENTATION.md](COMPLETE_LOGIC_DOCUMENTATION.md) for detailed logic flows
- **Quick Reference**: See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for component overview
- **Testing**: See [TESTING_GUIDE.md](TESTING_GUIDE.md) for testing procedures
- **Deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md) for build and release process

---

## 📚 Additional Resources

- **Complete Logic Documentation**: [COMPLETE_LOGIC_DOCUMENTATION.md](COMPLETE_LOGIC_DOCUMENTATION.md)
- **Quick Reference Guide**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Testing Guide**: [TESTING_GUIDE.md](TESTING_GUIDE.md)
- **Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Release Notes**: [RELEASE_NOTES.md](RELEASE_NOTES.md)
- **Contributing Guidelines**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Version**: Beta V1.0.0  
**Last Updated**: October 25, 2025  
**Created by**: Upmanyu Jha

**Note**: This app demonstrates advanced privacy-first security applications using Apple's on-device machine learning capabilities. It's designed for real-world use with comprehensive testing and optimization. The Dynamic Island integration leverages the NotchNotification framework (originally created by 秋星桥, modified for iSee).

---

Copyright © 2025 Upmanyu Jha aka Hackergod00001. All Rights Reserved.
