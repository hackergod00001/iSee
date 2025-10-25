# iSee Release Notes

## 🎉 Beta V1.0.0 - October 25, 2025

### ✨ Latest Updates & Fixes

#### 🔧 **DMG Creation & Build System**
- **Fixed Version Extraction**: Correctly parses version from README.md (`**Version**: Beta V1.0.0`)
- **Improved Version Processing**: Converts spaces to hyphens and lowercase for proper DMG naming
- **Dynamic DMG Naming**: DMG files now properly named as `iSee-beta-v1.0.0.dmg` instead of generic names
- **Enhanced Error Handling**: Better error handling for documentation copying and DMG creation
- **Automated Releases**: DMG creation script now automatically extracts version and creates properly named files
- **Build Optimization**: Improved build process with better cleanup and organization

#### 🐛 **Bug Fixes & Improvements**
- **Notification System**: Fixed notification popups not appearing (removed blocking permission checks)
- **Bounding Box Mirroring**: Fixed face detection bounding boxes appearing on wrong side in camera preview
- **Camera Preview**: Resolved black screen issues in camera feed
- **Icon Synchronization**: Fixed notification icon not updating when toggled in settings
- **UI Alignment**: Improved header icon spacing and alignment in Dynamic Island
- **Swift Compilation**: Fixed `defaultInterval` access level issue in NotchNotification framework

#### 🎨 **UI/UX Enhancements**
- **Dynamic Island Integration**: Seamless integration with NotchNotification framework
- **Improved Icon Layout**: Better spacing and alignment for header icons (X, gear, notification)
- **Notification Popup Width**: Fixed width consistency between island and notification popups
- **Corner Rounding**: Proper rounded corners matching notch shape for island and popups
- **Color Consistency**: Improved icon colors (red X, yellow notification, gray gear)

#### 🚀 **CI/CD & Automation**
- **GitHub Actions Workflows**: Enhanced CI/CD with build, test, and release automation
- **Dynamic Versioning**: Automatic version extraction from README.md for consistent releases
- **DMG Automation**: Automated DMG creation with proper naming and organization
- **Branch Synchronization**: Automatic sync between main and master branches
- **Build Validation**: Comprehensive build testing and validation workflows

---

## 🎉 v0.1.0 - October 19, 2025

### ✨ New Features & Improvements

#### 🎨 **Enhanced Dynamic Island Overlay**
- **Liquid Expansion Animation**: Organic blob-like expansion from camera location with elastic spring effects
- **Glassmorphism Design**: Ultra-thin material background with subtle borders and shadows
- **Camera Hardware Integration**: Darkened area representing physical camera with green status indicator
- **macOS-style Controls**: Native close button (red circle with X) and settings gear icon
- **Improved Layout**: X button on left, Settings gear on right, Camera area in center
- **Auto-dismiss**: Automatically collapses after 10 seconds with smooth animation

#### 🔔 **Enhanced Notification System**
- **Descriptive Alert Messages**: 
  - "🚨 Shoulder Surfer Detected!" with actionable advice
  - "⚠️ Multiple People Detected" with cautionary guidance
- **Improved Action Buttons**: "👁️ View Camera Feed" and "✓ Acknowledged" with icons
- **Rate Limiting**: Intelligent cooldown periods to prevent notification spam
- **System Integration**: Native macOS notification banners with proper presentation

#### ⚙️ **Comprehensive Settings Panel**
- **Alert Cooldown Period**: Configurable time between notifications (1-10 seconds)
- **Auto-start Monitoring**: Enabled by default, configurable option
- **Launch at Login**: Optional automatic startup for continuous protection
- **Overlay Auto-hide Delay**: Configurable overlay display duration (5-30 seconds)
- **Notification Permissions**: Built-in permission request with status display
- **Detection Thresholds**: Fine-tune sensitivity and alert timing

#### 🎯 **Menu Bar Enhancements**
- **Improved Icon States**: Enhanced color coding with Gray for disabled state
- **Better Visual Hierarchy**: Optimized spacing, font sizes, and layout
- **Dynamic Color Updates**: Real-time color changes based on monitoring state
- **Long-term Alert Indicator**: Red icon when shoulder surfing persists >1 minute

### 🔧 Technical Details
- **Platform**: macOS 13.0+ (Ventura and later)
- **Architecture**: Universal (Apple Silicon M1/M2/M3/M4 and Intel x64)
- **Framework**: SwiftUI + AppKit with AVFoundation, Vision, and UserNotifications
- **Bundle ID**: com.isee.app
- **App Size**: ~200KB DMG (Beta V1.0.0), ~168KB DMG (v0.1.0)
- **Background Processing**: NSApplicationDelegate with accessory activation policy
- **Animation Engine**: Core Animation with custom timing functions for liquid expansion
- **State Management**: Combine framework for reactive UI updates
- **Persistence**: UserDefaults with NSKeyedArchiver for complex data types

### 🛡️ Privacy & Security
- **No Data Collection**: Zero analytics, telemetry, or user tracking
- **On-Device Processing**: All face detection happens locally
- **No Network Access**: App operates entirely offline
- **Transparent Permissions**: Clear camera usage explanation
- **Open Source**: Full source code available for security audit

### 📱 User Experience
- **Menu Bar Icon States**: 
  - 🟢 Green: Safe (no shoulder surfers)
  - 🟡 Yellow: Warning (multiple faces detected)
  - 🟠 Orange: Alert (shoulder surfer detected, < 1 minute)
  - 🔴 Red: Long-term alert (shoulder surfer detected for > 1 minute)
  - ⚫ Gray: Monitoring disabled
- **Dynamic Island Overlay**: Liquid-expanding camera feed with auto-dismiss after 10 seconds
- **System Notifications**: Native macOS notifications with smart rate limiting
- **Comprehensive Settings**: Full control over detection, notifications, and preferences
- **Easy Setup**: One-click camera permission and immediate protection

### 🚀 Installation
1. Download `iSee-v0.1.0.dmg` from the releases page
2. Open the DMG file
3. Drag iSee.app to Applications folder
4. Launch and grant camera permission
5. Start protecting your screen!

### 🐛 Known Issues
- Face detection may be less accurate in very low light conditions
- Requires camera permission for full functionality
- Notification permissions are optional but recommended for alerts

### 🔮 Upcoming Features (v1.0.1)
- Multiple camera support (external cameras)
- Advanced privacy features (blur sensitive content)
- Integration with Focus modes
- Customizable overlay themes
- Advanced analytics and reporting
- Performance metrics dashboard
- Custom notification sounds
- Advanced detection algorithms

### 📞 Support
- **Issues**: [GitHub Issues](https://github.com/hackergod00001/iSee/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hackergod00001/iSee/discussions)
- **Documentation**: See README.md and DEPLOYMENT.md

### 👥 Contributors

**Development Team:**
- **Upmanyu Jha** - Project Lead, Core Development, UI/UX Design, Technical Implementation, Code Architecture, Feature Development
- **AI Assistant (Claude)** - Technical Implementation, Dev Support

**Key Contributions:**
- **Core Architecture**: Background monitoring service, menu bar integration
- **Dynamic Island UI**: Liquid expansion animations, glassmorphism effects
- **Vision Processing**: Face detection, shoulder surfer identification
- **System Integration**: Notifications, launch at login, preferences management
- **Documentation**: Comprehensive guides, release notes, deployment instructions

### 🙏 Acknowledgments
- Built with Apple's Vision and AVFoundation frameworks
- SwiftUI for modern, native UI
- Open source community for inspiration and feedback

---

**Latest Download**: [iSee-beta-v1.0.0.dmg](https://github.com/hackergod00001/iSee/releases/download/beta-v1.0.0/iSee-beta-v1.0.0.dmg) (200K)

**Previous Version**: [iSee-v0.1.0.dmg](https://github.com/hackergod00001/iSee/releases/download/v0.1.0/iSee-v0.1.0.dmg) (168K)

**Source Code**: [GitHub Repository](https://github.com/hackergod00001/iSee)

**License**: MIT License