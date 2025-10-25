# iSee Quick Reference Guide

**Version:** Beta V1.0.0  
**Last Updated:** October 25, 2025

## For Developers

### File Organization

| Category | Files | Purpose |
|----------|-------|---------|
| **App Entry** | `iseeApp.swift`, `AppDelegate.swift` | App lifecycle & initialization |
| **Menu Bar** | `MenuBarController.swift`, `MenuBarView.swift` | Menu bar icon & menu |
| **Camera** | `CameraManager.swift`, `VisionProcessor.swift` | Camera & face detection |
| **UI Integration** | `CameraNotchManager.swift`, `CameraOverlayView.swift` | Camera UI in notch |
| **Services** | `BackgroundMonitoringService.swift`, `StateController.swift` | Monitoring orchestration |
| **Notifications** | `NotificationManager.swift` | Alert system |
| **Settings** | `SettingsView.swift`, `SettingsWindow.swift`, `PreferencesManager.swift` | User preferences |
| **Framework** | `NotchNotification/*.swift` (10 files) | Dynamic Island UI |

### Common Tasks

#### Adding a New Setting

1. Add property to `PreferencesManager.swift`:
```swift
@AppStorage("myNewSetting") var myNewSetting: Bool = false
```

2. Add UI control to `SettingsView.swift`:
```swift
Toggle("My New Setting", isOn: $preferencesManager.myNewSetting)
```

3. Use setting anywhere:
```swift
if PreferencesManager.shared.myNewSetting {
    // ...
}
```

#### Showing a Notification

```swift
CameraNotchManager.showNotificationWithActions(
    title: "Alert Title",
    message: "Alert message",
    isError: true,
    onPreview: {
        // Show camera overlay
        BackgroundMonitoringService.shared.showOverlay()
    },
    onAcknowledge: {
        // User acknowledged
        print("Acknowledged")
    }
)
```

#### Showing Camera Overlay

```swift
CameraNotchManager.shared.showCameraOverlay(
    cameraManager: cameraManager,
    visionProcessor: visionProcessor,
    onDismiss: {
        // Called when overlay closes
    }
)
```

#### Modifying Face Detection Logic

Edit `StateController.swift`:
```swift
func updateFaceCount(_ count: Int) {
    switch count {
    case 0:
        currentState = .error
    case 1:
        currentState = .safe
    case 2:
        currentState = .warning
    default:
        currentState = .alert
    }
}
```

### Key Singleton References

```swift
BackgroundMonitoringService.shared  // Main orchestrator
CameraNotchManager.shared            // UI integration
NotificationManager.shared           // Notifications
PreferencesManager.shared            // Settings
SettingsWindow.shared                // Settings window
```

### Important Dimensions

#### Camera Overlay
- Camera preview: **433×260px** (5:3 aspect ratio)
- Face detection overlay: **433×260px** (matches camera)
- Horizontal padding: **5px** each side
- Vertical padding: **10px** top and bottom
- Total content area: **443×280px**
- Header height: **32px**
- Total island height: **346px**

#### Notification Popup
- Width: **443px** (matches camera island)
- Padding: **12px** horizontal, **12px** vertical

### State Machine

```
SecurityState enum:
├── .safe    → 1 face detected (just user)
├── .warning → 2 faces detected (potential threat)
├── .alert   → 3+ faces detected (shoulder surfer!)
└── .error   → 0 faces (no one present)
```

### Build Commands

```bash
# Debug build
xcodebuild -project isee.xcodeproj -scheme isee -configuration Debug build

# Release build
xcodebuild -project isee.xcodeproj -scheme isee -configuration Release build

# Create DMG
./scripts/create_dmg.sh

# Run from build directory
open /Users/$USER/Library/Developer/Xcode/DerivedData/isee-*/Build/Products/Debug/isee.app
```

### Testing Checklist

- [ ] Camera permission granted
- [ ] Face detection working (1 face → safe)
- [ ] Multiple faces trigger warning/alert
- [ ] Notifications appear in notch
- [ ] Camera overlay shows in notch
- [ ] Preview/Acknowledge buttons work
- [ ] Settings persist across launches
- [ ] Toggle monitoring works
- [ ] Toggle camera feed works
- [ ] Notification bell toggle works
- [ ] Auto-hide delay works
- [ ] Launch at login works

### Debugging Tips

#### Camera Not Working
1. Check camera permission: `System Preferences → Privacy & Security → Camera`
2. Check console: `cameraManager.isAuthorized`
3. Verify session running: `cameraManager.isSessionRunning`

#### Face Detection Not Working
1. Check camera is started: `cameraManager.startSession()`
2. Check Vision processor connected: `cameraManager.visionProcessor != nil`
3. Check console for Vision errors
4. Verify good lighting conditions

#### Overlay Not Showing
1. Check `isOverlayVisible` state
2. Verify `CameraNotchManager.shared.showCameraOverlay()` called
3. Check console for NotchNotification errors
4. Verify Mac has a notch (or test on notched Mac)

#### Notifications Not Showing
1. Check notification permission: `notificationManager.isAuthorized`
2. Verify notifications enabled: `preferencesManager.notificationsEnabled`
3. Check rate limiting (5s cooldown)
4. Verify state change occurred

### Common Issues

| Issue | Solution |
|-------|----------|
| Black camera preview | Ensure `previewLayer` is lazy var, not computed property |
| Camera preview greyish | Check `backgroundLayer.backgroundColor = .black` |
| Notification icon not updating | Use `@ObservedObject` in button view |
| Overlapping notifications | Call `dismissCurrentNotification()` before showing new one |
| Icons clipped by curves | Add padding to avoid curved corners |
| Circular dependency crash | Use dependency injection, not singleton in init |

### Performance Tips

1. **Camera Processing:** Runs on `sessionQueue` (background)
2. **Vision Processing:** Delegate called on background queue
3. **UI Updates:** Always dispatch to main thread
4. **State Updates:** Use `@Published` for automatic updates
5. **Memory:** Use `weak self` in closures to prevent retain cycles

### Code Style

- Use `// MARK:` for section organization
- Group related properties together
- Document public APIs with `///`
- Use meaningful variable names
- Prefer `guard` over nested `if`
- Use `weak self` in closures

### Git Workflow

```bash
# Feature branch
git checkout -b feature/my-feature

# Commit with descriptive message
git commit -m "Add: New feature description"

# Push and create PR
git push origin feature/my-feature
```

### Documentation

| File | Purpose |
|------|---------|
| `README.md` | Project overview & getting started |
| `PROJECT_STRUCTURE.md` | Complete project structure & flow |
| `ARCHITECTURE_WIRING.md` | Detailed component wiring |
| `TESTING_GUIDE.md` | Testing instructions |
| `DEPLOYMENT.md` | Build & release process |
| `QUICK_REFERENCE.md` | This file |

### Useful Links

- [AVFoundation Documentation](https://developer.apple.com/av-foundation/)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Combine Framework](https://developer.apple.com/documentation/combine)

---

**Version:** Beta V1.0.0  
**Maintained by:** Upmanyu Jha  
**Documentation:** See `COMPLETE_LOGIC_DOCUMENTATION.md` for detailed logic reference

