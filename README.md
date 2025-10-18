# iSee - Shoulder Surfer Detection App

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

iSee is a lightweight, privacy-first utility for Apple devices (iPhone & MacBook) that proactively notifies users when an unauthorized person is looking at their screen, enhancing personal data security in public or shared spaces.

## 🚀 Quick Start

### Download & Install
1. Go to [Releases](https://github.com/hackergod00001/iSee/releases)
2. Download `iSee-v0.0.1.dmg`
3. Install and launch the app
4. Grant camera permission when prompted

### Build from Source
```bash
git clone https://github.com/hackergod00001/iSee.git
cd iSee
open isee.xcodeproj
# Press Cmd+R to build and run
```

## 📱 Features

- **Real-time Face Detection**: Uses Apple's Vision framework for accurate detection
- **Privacy-First Design**: 100% on-device processing, no data collection
- **Cross-Platform**: Works on both macOS and iOS
- **Smart Alerts**: Configurable thresholds for shoulder surfer detection
- **Performance Optimized**: Efficient processing with minimal battery impact

## 🎯 Vision & Goal

**Vision**: To Create a lightweight, privacy-first utility for Apple devices that proactively notifies users when an unauthorized person is looking at their screen, enhancing personal data security.

**PoC Goal**: A functional iOS application that uses the front-facing camera to continuously detect faces and trigger alerts when multiple people are detected for a sustained period.

## 🏗️ Architecture

### Core Components

1. **CameraManager** - Handles camera access and video stream using AVFoundation
2. **VisionProcessor** - Analyzes video frames for face detection using Apple's Vision framework
3. **StateController** - Manages security states and implements the shoulder surfer detection logic
4. **NotificationBanner** - Provides non-intrusive visual alerts with smooth animations

### Technology Stack

- **Platform**: iOS 16+
- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Computer Vision**: Apple Vision Framework
- **Camera**: Apple AVFoundation Framework

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

1. **Launch the app** and grant camera permission
2. **Position your device** so the front camera can see your face
3. **Monitor the status indicators** at the bottom of the screen
4. **Receive alerts** when multiple people are detected for 2+ seconds
5. **Use settings** to test different scenarios and view detailed status

### Security States

- **🟢 Safe**: 1 face detected (normal state)
- **🟠 Warning**: 2+ faces detected, counting down to alert
- **🔴 Alert**: 2+ faces detected for sustained period
- **⚫ Error**: Camera issues or no faces detected

## 🛠️ Development

### Getting Started

1. **Open the project**: Open `isee.xcodeproj` in Xcode
2. **Select target device**: Choose iPhone or iPad simulator
3. **Build and run**: Press Cmd+R to build and run the app
4. **Grant permissions**: Allow camera access when prompted

### Project Structure

```
isee/
├── iseeApp.swift                   # App entry point
├── ContentView.swift               # Main UI with camera preview
├── CameraManager.swift             # Camera handling and permissions
├── VisionProcessor.swift           # Face detection processing
├── StateController.swift           # Security state management
├── NotificationBanner.swift        # Alert UI components
├── SettingsView.swift              # Configuration and testing
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

#### NotificationBanner
- Displays animated security alerts
- Shows progress bars for warning states
- Provides dismiss functionality for alerts
- Non-intrusive design with smooth transitions

## 🧪 Testing

The app includes a comprehensive settings panel for testing:

- **Simulate different face counts** (0, 1, 2+ faces)
- **Monitor real-time status** and processing information
- **Test state transitions** and timer functionality
- **View performance metrics** and detection accuracy

## 📋 Requirements

- iOS 16.0 or later
- iPhone or iPad with front-facing camera
- Camera permission granted by user

## 🔧 Configuration

### App Configuration

- **Bundle Identifier**: `com.isee.app`
- **App Name**: iSee
- **Minimum iOS Version**: 16.0
- **Target Devices**: iPhone and iPad

### Adjustable Parameters

- **Alert Threshold**: 2.0 seconds (configurable in StateController)
- **Processing Rate**: ~5 FPS (configurable in VisionProcessor)
- **Frame Skip Interval**: Every 3rd frame (configurable in VisionProcessor)
- **Consecutive Zero Tolerance**: 10 frames (configurable in StateController)

## 🚧 Limitations & Future Enhancements

### Current Limitations
- Requires good lighting conditions for accurate face detection
- May have false positives with photos or reflections
- Battery usage increases with continuous camera processing
- Limited to front-facing camera only

### Potential Enhancements
- Machine learning model for improved accuracy
- Background processing capabilities
- Customizable alert thresholds
- Integration with system notifications
- macOS version for laptop users
- Advanced privacy features (blur sensitive content)

## 📄 License

This project is a proof-of-concept demonstration of privacy-first security applications using Apple's on-device machine learning capabilities.

## 🤝 Contributing

This is a proof-of-concept project. For production use, consider:
- Comprehensive testing across different devices and lighting conditions
- User experience research and optimization
- Security audit and penetration testing
- Performance optimization for battery life
- Accessibility improvements

---

**Note**: This app is designed as a proof-of-concept to demonstrate the feasibility of privacy-first shoulder surfer detection. For production deployment, additional testing, optimization, and security considerations would be required.

