# iSee - Advanced Shoulder Surfer Detection App

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-brightgreen.svg)](https://github.com/hackergod00001/iSee/releases)

iSee is a sophisticated macOS menu bar application that provides real-time shoulder surfer detection using your MacBook's camera. It runs silently in the background and alerts you when someone is looking at your screen, featuring intelligent long-term threat detection, a beautiful Dynamic Island-style camera overlay, and comprehensive privacy-first security features.

## 🚀 Quick Start

### Download & Install
1. Go to [Releases](https://github.com/hackergod00001/iSee/releases)
2. Download `iSee-v0.1.0.dmg`
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
- **Dynamic Island Overlay**: Liquid-expanding camera feed with glassmorphism design
- **Menu Bar Integration**: Clean, minimal interface that doesn't clutter your screen
- **Auto-dismissing Overlay**: Camera feed automatically hides after 10 seconds
- **Smooth Animations**: Organic blob-like expansion with elastic spring effects
- **macOS-style Controls**: Native close button (red circle with X) and settings gear icon
- **Camera Hardware Integration**: Darkened camera area representation in overlay

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
3. **CameraOverlayWindow** - Creates the Dynamic Island-style camera feed overlay
4. **NotificationManager** - Handles system notifications with rate limiting
5. **PreferencesManager** - Manages user settings and app state persistence
6. **VisionProcessor** - Analyzes video frames for face detection using Apple's Vision framework
7. **StateController** - Manages security states and implements shoulder surfer detection logic

### Technology Stack

- **Platform**: macOS 13.0+
- **Language**: Swift 5
- **UI Framework**: SwiftUI + AppKit
- **Computer Vision**: Apple Vision Framework
- **Camera**: Apple AVFoundation Framework
- **Notifications**: UserNotifications Framework
- **Background Processing**: NSApplicationDelegate

## 🔒 Privacy & Security

- **100% On-Device Processing**: All face detection happens locally using Apple's Vision framework
- **No Data Storage**: No images or face data are stored or transmitted
- **No Network Access**: The app operates entirely offline
- **Transparent Permissions**: Clear explanation of camera usage in privacy policy
- **Open Source**: Full source code available for security audit
- **No Tracking**: No analytics, telemetry, or user tracking

## 🚀 Features

### Core Functionality
- Real-time face detection using front-facing camera
- Multi-face detection with visual bounding boxes
- Timer-based alert system (2-second threshold)
- Smooth animated notifications
- Privacy-first design with on-device processing

### User Interface
- Live camera preview with face detection overlays
- Color-coded security status indicators
- Animated notification banners
- Settings panel for testing and configuration
- Non-intrusive design that doesn't block screen content

### Performance Optimizations
- Frame rate limiting (5 FPS processing)
- Frame skipping for battery efficiency
- Edge case handling for temporary detection failures
- Optimized Vision framework usage

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

### Dynamic Island Overlay Features

- **Liquid Expansion Animation**: Organic blob-like expansion from camera location
- **Glassmorphism Design**: Ultra-thin material background with subtle borders
- **Camera Hardware Integration**: Darkened area representing physical camera
- **macOS-style Controls**: Native close button (red circle with X) and settings gear
- **Auto-dismiss**: Automatically collapses after 10 seconds
- **Mirrored Camera Feed**: Selfie-style view for natural interaction
- **Face Detection Overlays**: Real-time bounding boxes with "You" and "Other" labels

## 🛠️ Development

### Getting Started

1. **Open the project**: Open `isee.xcodeproj` in Xcode
2. **Select target device**: Choose iPhone or iPad simulator
3. **Build and run**: Press Cmd+R to build and run the app
4. **Grant permissions**: Allow camera access when prompted

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
├── NotificationManager.swift       # System notification handling
├── PreferencesManager.swift        # User settings and state persistence
├── LaunchAtLoginManager.swift      # Auto-launch functionality
├── SettingsWindow.swift            # Settings window management
├── SettingsView.swift              # Comprehensive settings interface
├── CameraManager.swift             # Camera handling and permissions
├── VisionProcessor.swift           # Face detection processing
├── StateController.swift           # Security state management
├── Info.plist                      # App configuration
├── Preview Content/                # SwiftUI preview assets
│   └── Preview Assets.xcassets/
└── isee.xcodeproj/                 # Xcode project file
```

### Key Classes

#### CameraManager
- Manages AVFoundation camera session
- Handles permission requests
- Provides video frame data to VisionProcessor
- Optimized for front-facing camera usage

#### VisionProcessor
- Processes camera frames using VNDetectFaceRectanglesRequest
- Implements performance optimizations (frame skipping, rate limiting)
- Provides face count and bounding box data
- Handles edge cases and error conditions

#### StateController
- Implements core shoulder surfer detection logic
- Manages state transitions (safe → warning → alert)
- Handles timer-based alert triggering
- Provides user-friendly status messages

#### NotificationManager
- Handles system notification permissions and delivery
- Provides rate-limited notifications for security alerts
- Manages notification categories and actions
- Integrates with macOS notification center

## 🧪 Testing

The app includes a comprehensive settings panel for testing:

- **Simulate different face counts** (0, 1, 2+ faces)
- **Monitor real-time status** and processing information
- **Test state transitions** and timer functionality

## 📋 Requirements

- macOS 13.0 or later
- MacBook with built-in camera (or external camera)
- Camera permission granted by user
- Notification permission for alerts (optional)

## 🔧 Configuration

### App Configuration

- **Bundle Identifier**: `com.isee.app`
- **App Name**: iSee
- **Minimum macOS Version**: 13.0
- **Target Devices**: MacBook, iMac, Mac Studio, Mac Pro

### Adjustable Parameters

- **Alert Cooldown Period**: 2.0 seconds (configurable in Settings, 1-10 seconds range)
- **Long-term Alert Duration**: 60 seconds (triggers red menu bar icon)
- **Overlay Auto-hide Delay**: 10 seconds (configurable in Settings, 5-30 seconds range)
- **Processing Rate**: ~5 FPS (optimized for battery life)
- **Notification Rate Limiting**: 5 seconds cooldown between notifications
- **Auto-start Monitoring**: Enabled by default, configurable in Settings
- **Launch at Login**: Optional automatic startup for continuous protection

## 🚧 Limitations & Future Enhancements

### Current Limitations
- Requires good lighting conditions for accurate face detection
- May have false positives with photos or reflections
- Battery usage increases with continuous camera processing
- Limited to built-in camera only

### Potential Enhancements
- Machine learning model for improved accuracy
- Multiple camera support (external cameras)
- Advanced privacy features (blur sensitive content)
- Integration with Focus modes
- Customizable overlay themes
- Advanced analytics and reporting
- **View performance metrics** and detection accuracy (upcoming next relase)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on macOS
5. Submit a pull request

---

**Note**: This app demonstrates advanced privacy-first security applications using Apple's on-device machine learning capabilities. It's designed for real-world use with comprehensive testing and optimization.

