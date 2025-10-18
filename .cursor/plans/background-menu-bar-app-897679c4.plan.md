<!-- 897679c4-9730-4597-a94d-2fc3eb12279d 02d1021b-b03c-45ef-b681-60415d23bbd7 -->
# Transform iSee into Background Menu Bar App

## Overview

Convert iSee from a standard macOS window app to a menu bar-only background monitoring app with system notifications and camera feed overlay on alerts.

## Architecture Changes

### 1. App Structure Transformation

**File: `iseeApp.swift`**

- Remove `WindowGroup` scene entirely
- Add `MenuBarExtra` scene (macOS 13.0+) for menu bar icon
- Add `@NSApplicationDelegateAdaptor` to prevent dock icon
- Initialize background monitoring services on app launch

**New File: `AppDelegate.swift`**

- Create AppDelegate class to hide dock icon: `NSApp.setActivationPolicy(.accessory)`
- Handle app lifecycle (launch, termination)
- Persist monitoring state using UserDefaults

### 2. Menu Bar Interface

**New File: `MenuBarController.swift`**

- Create menu bar icon with two visual states:
  - Default state: Eye icon with camera symbol
  - Alert state: Red exclamation badge on icon
- Menu structure:
  - "Monitoring: ON/OFF" toggle (shows current state)
  - "Show Camera Feed" (if hidden)
  - "Settings..."
  - "Quit iSee"
- Use `NSStatusBar.system.statusItem()` for menu bar integration
- Implement icon animation: subtle pulse during monitoring, red flash on alert

### 3. Background Monitoring Service

**New File: `BackgroundMonitoringService.swift`**

- Singleton service managing camera, vision processor, and state controller
- Runs continuously when monitoring is enabled
- No UI dependencies - all processing headless
- Properties:
  - `cameraManager: CameraManager`
  - `visionProcessor: VisionProcessor`
  - `stateController: StateController`
  - `isMonitoring: Bool` (persisted)
- Methods:
  - `startMonitoring()` - Initialize camera and face detection
  - `stopMonitoring()` - Release camera resources
  - `toggleMonitoring()` - Switch state
- Connect to StateController to observe alert state changes

### 4. System Notifications

**New File: `NotificationManager.swift`**

- Request notification permission on first launch
- Show banner notification when `StateController` enters `.alert` state
- Notification content:
  - Title: "Shoulder Surfer Detected!"
  - Body: "Someone is watching your screen"
  - Sound: System alert sound
  - Action buttons: "Show Feed", "Dismiss"
- Handle notification interactions to show/hide camera overlay
- Add to Info.plist: `NSUserNotificationsUsageDescription`

### 5. Camera Feed Overlay Window

**New File: `CameraOverlayWindow.swift`**

- Create borderless, always-on-top `NSWindow`
- Position: Top-center of screen, below menu bar (near notch area)
- Size: 200x150 points (small thumbnail)
- Properties:
  - `level = .floating` (always on top)
  - `collectionBehavior = [.canJoinAllSpaces, .stationary]`
  - `isMovableByWindowBackground = true` (draggable)
  - `titlebarAppearsTransparent = true`
  - `styleMask = [.borderless, .nonactivatingPanel]`
- Content: SwiftUI `CameraPreviewView` + face detection overlays
- Show only when alert is active
- Auto-hide after 10 seconds or when returning to safe state
- Add close button (small X in corner)

**New File: `CameraOverlayView.swift`**

- SwiftUI view containing camera preview
- Reuse existing `CameraPreviewView` and `FaceDetectionOverlayView`
- Add compact status indicator showing face count
- Rounded corners and subtle shadow for polish

### 6. Launch at Login Support

**New File: `LaunchAtLoginManager.swift`**

- Use `SMAppService` (macOS 13.0+) for modern launch at login
- Add toggle in menu: "Launch at Login"
- Persist preference in UserDefaults
- Register/unregister with:
  ```swift
  try SMAppService.mainApp.register()
  try SMAppService.mainApp.unregister()
  ```


### 7. State Persistence

**New File: `PreferencesManager.swift`**

- UserDefaults wrapper for app preferences:
  - `isMonitoringEnabled: Bool` - Last monitoring state
  - `launchAtLogin: Bool` - Launch at login preference
  - `overlayPosition: CGPoint` - Last overlay window position
  - `showWelcomeScreen: Bool` - First launch flag
- Restore monitoring state on app relaunch
- Save overlay position when dragged

### 8. Settings Window

**Update File: `SettingsView.swift`**

- Convert to standalone window (not sheet)
- Settings sections:

  1. Monitoring: Enable/disable, sensitivity slider
  2. Notifications: Enable/disable, sound toggle
  3. Overlay: Auto-hide delay, position reset
  4. General: Launch at login, camera permission status
  5. About: Version, privacy policy, GitHub link

- Open from menu bar: "Settings..."
- Create `SettingsWindow.swift` wrapper for NSWindow presentation

## File Modifications

### `iseeApp.swift` - Complete Rewrite

```swift
import SwiftUI

@main
struct iseeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarController = MenuBarController()
    
    var body: some Scene {
        MenuBarExtra("iSee", systemImage: menuBarController.menuBarIcon) {
            MenuBarView(controller: menuBarController)
        }
        .menuBarExtraStyle(.menu)
    }
}
```

### `AppDelegate.swift` - New File

```swift
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // Hide from dock
        
        // Restore last monitoring state
        if PreferencesManager.shared.isMonitoringEnabled {
            BackgroundMonitoringService.shared.startMonitoring()
        }
    }
}
```

### `StateController.swift` - Add Notification Trigger

- Add observer pattern or Combine publisher
- Emit event when entering `.alert` state
- BackgroundMonitoringService subscribes and triggers notifications

### `Info.plist` - Add Permissions

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>iSee needs notification permission to alert you when shoulder surfers are detected.</string>
<key>LSUIElement</key>
<true/>  <!-- Alternative to dock hiding -->
<key>LSBackgroundOnly</key>
<false/>
```

### `CameraManager.swift`, `VisionProcessor.swift` - No changes needed

These can run headlessly without UI

### Remove `ContentView.swift`

No longer needed - functionality split into menu bar and overlay

## Implementation Steps

1. Create new files: AppDelegate, MenuBarController, BackgroundMonitoringService
2. Rewrite iseeApp.swift to use MenuBarExtra
3. Create NotificationManager and request permissions
4. Implement CameraOverlayWindow and CameraOverlayView
5. Create PreferencesManager for state persistence
6. Update StateController to emit alert events
7. Wire BackgroundMonitoringService to respond to alerts
8. Create LaunchAtLoginManager
9. Update SettingsView for standalone window
10. Remove ContentView.swift and update Xcode project
11. Update Info.plist with new permissions
12. Test monitoring state persistence
13. Test notifications and overlay behavior
14. Build and verify menu bar app functions correctly

## Technical Notes

- MenuBarExtra requires macOS 13.0+ (already our deployment target)
- NSWindow for overlay provides more control than SwiftUI Window
- SMAppService is modern replacement for deprecated login item APIs
- UNUserNotificationCenter for native macOS notifications
- All background monitoring must handle camera permission checks
- Window level .floating ensures overlay stays above other apps
- Use .accessory activation policy to hide from dock while showing menu bar

## Testing Checklist

- [ ] App launches with menu bar icon only (no dock icon)
- [ ] Toggle monitoring on/off from menu bar
- [ ] Camera starts when monitoring enabled
- [ ] System notification appears on shoulder surfer detection
- [ ] Camera overlay shows near notch on alert
- [ ] Overlay is draggable and remembers position
- [ ] Monitoring state persists across app relaunches
- [ ] Launch at login works correctly
- [ ] Settings window opens and saves preferences
- [ ] Menu bar icon changes state (normal/alert)
- [ ] Notifications have action buttons that work
- [ ] Camera resources released when monitoring disabled

## Version Update

Update version to v0.1.0 to reflect major functionality change

### To-dos

- [ ] Create AppDelegate, MenuBarController, and BackgroundMonitoringService files
- [ ] Rewrite iseeApp.swift to use MenuBarExtra instead of WindowGroup
- [ ] Create NotificationManager and request notification permissions
- [ ] Implement CameraOverlayWindow with draggable floating window near notch
- [ ] Create PreferencesManager for monitoring state and preferences persistence
- [ ] Update StateController to publish alert events using Combine
- [ ] Implement LaunchAtLoginManager using SMAppService
- [ ] Convert SettingsView to standalone window with new preferences
- [ ] Add notification permission and background app keys to Info.plist
- [ ] Remove ContentView.swift and update Xcode project references
- [ ] Test all features: monitoring, notifications, overlay, persistence, launch at login