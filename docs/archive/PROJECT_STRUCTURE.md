# iSee Project Structure & Flow

## Project Overview

iSee is a macOS menu bar application that detects shoulder surfers using the front-facing camera and face detection. It displays a dynamic island-style overlay in the Mac notch when multiple faces are detected.

## Directory Structure

```
isee/
├── Core Application Files
│   ├── iseeApp.swift                      # SwiftUI app entry point
│   ├── AppDelegate.swift                  # App lifecycle management
│   └── Info.plist                         # App configuration & permissions
│
├── Menu Bar & UI
│   ├── MenuBarController.swift            # Controls menu bar icon & menu
│   ├── MenuBarView.swift                  # Menu bar UI content
│   ├── SettingsView.swift                 # Settings panel UI
│   └── SettingsWindow.swift               # Settings window controller
│
├── Camera & Vision System
│   ├── CameraManager.swift                # AVFoundation camera session management
│   ├── CameraOverlayView.swift            # Camera preview & face detection overlay views
│   ├── CameraNotchManager.swift           # Integrates camera with NotchNotification framework
│   └── VisionProcessor.swift              # Face detection using Vision framework
│
├── Background Services
│   ├── BackgroundMonitoringService.swift  # Orchestrates monitoring, camera, overlay
│   ├── StateController.swift              # Security state machine (safe/warning/alert/error)
│   ├── NotificationManager.swift          # User notifications via NotchNotification
│   ├── PreferencesManager.swift           # User preferences persistence
│   └── LaunchAtLoginManager.swift         # Launch at login functionality
│
├── NotchNotification Framework            # Dynamic Island-style notifications
│   ├── NotchNotification.swift            # Public API for simple notifications
│   ├── NotificationContext.swift          # Creates and presents NotchWindow
│   ├── NotchViewModel.swift               # State management & animations
│   ├── NotchView.swift                    # Main SwiftUI view with curved shape
│   ├── NotchHeaderView.swift              # Header layout (icons)
│   ├── NotchContentView.swift             # Content layout
│   ├── NotchWindow.swift                  # Custom NSWindow (borderless, transparent)
│   ├── NotchWindowController.swift        # Window lifecycle management
│   ├── NotchViewController.swift          # NSViewController bridge
│   └── Ext+NSScreen.swift                 # NSScreen extensions for notch detection
│
├── Documentation
│   ├── README.md                          # Project overview & getting started
│   ├── CONTRIBUTING.md                    # Contribution guidelines
│   ├── DEPLOYMENT.md                      # Build & deployment instructions
│   ├── RELEASE_NOTES.md                   # Version history
│   ├── RELEASE_WORKFLOW.md                # Release process
│   ├── TESTING_GUIDE.md                   # Testing instructions
│   ├── CHANGES_SUMMARY.md                 # High-level changes log
│   ├── IMPLEMENTATION_SUMMARY.md          # Architecture overview
│   ├── ISLAND_ARCHITECTURE_EXPLAINED.md   # NotchNotification integration details
│   ├── DISCUSSIONS_WELCOME.md             # Community guidelines
│   └── PROJECT_STRUCTURE.md               # This file
│
├── Scripts
│   └── create_dmg.sh                      # DMG creation script for releases
│
├── Releases
│   └── iSee-v0.1.0.dmg                    # Release artifacts
│
└── Xcode Project
    └── isee.xcodeproj/                    # Xcode project file
```

## Application Flow

### 1. App Launch (`iseeApp.swift`)

```
iseeApp (SwiftUI App)
├── Configures AppDelegate
├── Creates MenuBarExtra (menu bar icon)
└── Initializes PreferencesManager
```

**Key Components:**
- `iseeApp.swift` - Main entry point, sets up `NSApplicationDelegateAdaptor`
- `AppDelegate.swift` - Handles app lifecycle, creates `MenuBarController`

### 2. Menu Bar Initialization (`MenuBarController.swift`)

```
MenuBarController
├── Creates NSStatusItem (menu bar icon)
├── Sets up menu with:
│   ├── Toggle Monitoring (start/stop)
│   ├── Toggle Camera Feed (show/hide overlay)
│   ├── Settings
│   └── Quit
└── Observes BackgroundMonitoringService state
```

**Key Components:**
- `MenuBarController.swift` - Creates and manages menu bar icon
- `MenuBarView.swift` - SwiftUI view for menu content (alternative approach)

### 3. Monitoring Flow (`BackgroundMonitoringService.swift`)

```
User clicks "Start Monitoring"
    ↓
BackgroundMonitoringService.startMonitoring()
    ↓
1. Check camera permission (CameraManager)
2. Connect CameraManager → VisionProcessor
3. Start camera session (CameraManager.startSession())
4. Start StateController monitoring
5. Set isMonitoring = true
    ↓
Camera feed → VisionProcessor → Face Detection
    ↓
VisionProcessor publishes faceCount changes
    ↓
StateController receives faceCount updates
    ↓
StateController determines security state:
    - 0 faces → .error (no one present)
    - 1 face  → .safe (just you)
    - 2 faces → .warning (potential shoulder surfer)
    - 3+ faces → .alert (shoulder surfer detected!)
    ↓
BackgroundMonitoringService observes state changes
    ↓
Triggers actions:
    - .alert → showOverlay() + showNotification()
    - .safe → hideOverlay()
```

**Key Components:**
- `BackgroundMonitoringService.swift` - Orchestrates entire monitoring process
- `StateController.swift` - State machine for security states
- `CameraManager.swift` - AVFoundation camera session
- `VisionProcessor.swift` - Vision framework face detection

### 4. Camera System (`CameraManager.swift` + `VisionProcessor.swift`)

```
CameraManager
├── AVCaptureSession (front camera)
├── AVCaptureVideoPreviewLayer (for display)
└── AVCaptureVideoDataOutput (sends frames to VisionProcessor)
    ↓
VisionProcessor (AVCaptureVideoDataOutputSampleBufferDelegate)
├── Receives CMSampleBuffer frames
├── Converts to CVPixelBuffer
├── Runs VNDetectFaceRectanglesRequest
├── Publishes faceCount and faceObservations
└── Updates on main thread
```

**Key Components:**
- `CameraManager.swift` - Camera session setup & management
- `VisionProcessor.swift` - Face detection processing
- `CameraOverlayView.swift` - Contains `CameraPreviewView` and `FaceDetectionOverlayView`

### 5. Overlay Display (`CameraNotchManager.swift`)

```
BackgroundMonitoringService.showOverlay()
    ↓
CameraNotchManager.shared.showCameraOverlay(
    cameraManager: CameraManager,
    visionProcessor: VisionProcessor
)
    ↓
Creates NotificationContext with:
├── Header Leading: X button (close)
├── Header Trailing: Gear (settings) + Bell (notifications toggle)
└── Body: SimpleCameraNotchView
    ├── CameraPreviewView (433x260px)
    └── FaceDetectionOverlayView (433x260px with bounding boxes)
    ↓
NotificationContext.open(forInterval: delay)
    ↓
Creates NotchWindow → NotchView → Animates open
    ↓
Auto-dismisses after delay OR user closes
```

**Key Components:**
- `CameraNotchManager.swift` - Bridges camera system with NotchNotification
- `NotchNotification/NotificationContext.swift` - Creates and presents notification
- `NotchNotification/NotchView.swift` - Renders curved notch shape
- `CameraOverlayView.swift` - Camera preview and face detection UI

### 6. Notifications (`NotificationManager.swift`)

```
StateController state changes
    ↓
BackgroundMonitoringService.handleStateChange()
    ↓
NotificationManager.handleStateChange()
    ↓
Rate limiting check (5s cooldown)
    ↓
CameraNotchManager.showNotificationWithActions()
    ↓
Creates NotificationWithActionsView with:
├── Title & Message
├── Dropdown menu:
│   ├── Preview (shows camera overlay)
│   └── Acknowledge (dismisses)
└── Auto-dismiss after delay
```

**Key Components:**
- `NotificationManager.swift` - Notification logic & rate limiting
- `CameraNotchManager.swift` - `NotificationWithActionsView` for notifications
- `NotchNotification/` - Framework for displaying notifications

### 7. Settings & Preferences (`SettingsView.swift`)

```
User opens Settings
    ↓
SettingsWindow.shared.showWindow()
    ↓
SettingsView displays:
├── Notifications
│   ├── Enable/Disable toggle
│   ├── Request Permissions button
│   └── Auto-hide Delay slider (5-30s)
├── Monitoring
│   ├── Auto-start Monitoring
│   └── Launch at Login
└── Detection
    └── Alert Cooldown Period (1-10s)
    ↓
Changes saved to PreferencesManager
    ↓
PreferencesManager syncs to UserDefaults
```

**Key Components:**
- `SettingsView.swift` - SwiftUI settings UI
- `SettingsWindow.swift` - Window management
- `PreferencesManager.swift` - Preferences persistence

## Data Flow Diagram

```
┌─────────────────┐
│   User Input    │
│  (Menu Bar)     │
└────────┬────────┘
         ↓
┌─────────────────────────────┐
│ BackgroundMonitoringService │
│  (Orchestrator)              │
└──┬──────────────────────┬───┘
   ↓                      ↓
┌──────────────┐   ┌────────────────┐
│ CameraManager│   │ StateController│
│ (AVFoundation)│  │ (State Machine)│
└──┬───────────┘   └────────┬───────┘
   ↓                        ↓
┌──────────────┐   ┌──────────────────┐
│VisionProcessor│  │NotificationManager│
│ (Face Detect) │  │  (Alerts)         │
└──┬───────────┘   └────────┬─────────┘
   ↓                        ↓
┌────────────────────────────────────┐
│      CameraNotchManager             │
│  (UI Integration Layer)             │
└──┬─────────────────────────────┬───┘
   ↓                             ↓
┌────────────────┐   ┌──────────────────────┐
│CameraOverlayView│  │ NotchNotification     │
│ (Camera UI)     │  │ (Dynamic Island UI)   │
└─────────────────┘  └───────────────────────┘
```

## Key Design Patterns

### 1. **Singleton Pattern**
- `BackgroundMonitoringService.shared`
- `CameraNotchManager.shared`
- `NotificationManager.shared`
- `PreferencesManager.shared`

### 2. **Observer Pattern (Combine)**
- `@Published` properties for reactive state updates
- `AnyCancellable` subscriptions for state monitoring
- Example: `VisionProcessor.$faceCount` → `StateController.updateFaceCount()`

### 3. **Dependency Injection**
- `CameraNotchManager.showCameraOverlay()` accepts `CameraManager` and `VisionProcessor`
- Prevents circular dependencies between singletons

### 4. **State Machine**
- `StateController.SecurityState` enum: `.safe`, `.warning`, `.alert`, `.error`
- Clean state transitions with published updates

### 5. **Delegate Pattern**
- `AVCaptureVideoDataOutputSampleBufferDelegate` for frame processing
- `UNUserNotificationCenterDelegate` for notification handling

## Critical Integrations

### NotchNotification Framework Integration

The app uses a custom `NotchNotification` framework (adapted from `NotchDrop`) to create Dynamic Island-style notifications in the Mac notch.

**Integration Points:**
1. `CameraNotchManager.swift` - Primary integration layer
2. `NotificationContext` - Creates and presents NotchWindow
3. `NotchView` - Custom curved shape matching notch design
4. Custom header views - X, Gear, Bell icons
5. Custom body views - Camera feed or notification content

**Key Features:**
- Automatic notch detection via `NSScreen` extensions
- Curved corners using custom `NotchRectangle` shape
- Smooth animations with `interpolatingSpring`
- Auto-dismiss with configurable intervals
- Manual dismiss via `forceClose()`

### Camera Preview Integration

**Dimensions:**
- Camera preview: 433×260px (5:3 aspect ratio)
- Face detection overlay: 433×260px (matches camera)
- Padding: 5px horizontal, 10px vertical
- Total content area: 443×280px
- Header height: 32px
- Total island height: 346px

**Implementation:**
- `CameraPreviewView` (NSViewRepresentable) wraps `AVCaptureVideoPreviewLayer`
- `FaceDetectionOverlayView` draws bounding boxes over detected faces
- Layers maintain aspect ratio and proper sizing
- Black background for clean appearance

## Error Handling

### Camera Permission
```
CameraManager checks authorization status
├── .authorized → Setup camera
├── .notDetermined → Request permission
└── .denied/.restricted → Show error, disable monitoring
```

### State Transitions
```
StateController monitors for:
├── Camera disconnection → .error state
├── Vision processing failure → .error state
└── Invalid state transitions → Logged
```

### Build & Runtime
- Swift error handling with `do-catch` blocks
- Main thread enforcement for UI updates
- Background queue for camera processing
- Rate limiting for notifications

## Testing

See `TESTING_GUIDE.md` for comprehensive testing instructions.

**Key Test Areas:**
1. Camera permissions & authorization
2. Face detection accuracy
3. State transitions (safe → warning → alert)
4. Overlay display & dismissal
5. Notification rate limiting
6. Settings persistence
7. Launch at login

## Build & Deployment

See `DEPLOYMENT.md` for full build instructions.

**Quick Build:**
```bash
xcodebuild -project isee.xcodeproj -scheme isee -configuration Release build
```

**Create DMG:**
```bash
./scripts/create_dmg.sh
```

## Future Improvements

Potential enhancements documented in `README.md`:
1. ML-based threat level classification
2. Privacy-preserving on-device processing
3. Customizable alert thresholds
4. Keyboard shortcuts for quick actions
5. Multiple camera support

---

**Last Updated:** October 2025  
**Version:** 0.1.0  
**Maintained by:** iSee Development Team

