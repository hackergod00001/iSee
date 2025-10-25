# iSee Architecture & Wiring Diagram

## Complete Application Wiring

This document provides a detailed view of how all components in the iSee application are connected and interact with each other.

## Component Dependency Graph

```
┌─────────────────────────────────────────────────────────────────┐
│                        iseeApp.swift                            │
│                     (SwiftUI App Entry)                         │
└────────────┬────────────────────────────┬───────────────────────┘
             │                            │
             ↓                            ↓
    ┌────────────────┐          ┌───────────────────┐
    │ AppDelegate    │          │ PreferencesManager│
    │                │          │ (Singleton)       │
    └───────┬────────┘          └─────────┬─────────┘
            │                             │
            ↓                             │ persists to
    ┌─────────────────┐                   │ UserDefaults
    │MenuBarController│                   │
    │                 │◄──────────────────┘
    └───────┬─────────┘
            │
            │ observes & controls
            ↓
┌───────────────────────────────────────────────────────────────┐
│              BackgroundMonitoringService                      │
│                    (Orchestrator Singleton)                   │
└─┬─────────┬─────────┬──────────┬─────────┬────────────────────┘
  │         │         │          │         │
  │         │         │          │         │
  ↓         ↓         ↓          ↓         ↓
┌────┐  ┌────────┐ ┌──────┐ ┌────────┐ ┌──────────┐
│Cam │  │Vision  │ │State │ │Notif   │ │Prefs     │
│Mgr │  │Process │ │Ctrl  │ │Mgr     │ │Mgr       │
└─┬──┘  └───┬────┘ └──┬───┘ └───┬────┘ └──────────┘
  │         │         │         │
  │ frames  │ faces   │ state   │ alerts
  │         │         │         │
  └────┬────┴────┬────┴────┬────┘
       │         │         │
       ↓         ↓         ↓
    ┌──────────────────────────┐
    │   CameraNotchManager     │
    │  (UI Integration Layer)  │
    └───────────┬──────────────┘
                │
                ↓
    ┌───────────────────────────┐
    │  NotchNotification        │
    │  Framework                │
    └───────────────────────────┘
```

## Detailed Component Wiring

### 1. App Entry Point

**File:** `iseeApp.swift`

```swift
@main
struct iseeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("iSee", systemImage: "eye") {
            MenuBarView()
        }
    }
}
```

**Wiring:**
- Initializes `AppDelegate` via `@NSApplicationDelegateAdaptor`
- Creates menu bar extra UI
- SwiftUI manages lifecycle

**Dependencies:**
- `AppDelegate.swift`
- `MenuBarView.swift`

---

### 2. App Delegate

**File:** `AppDelegate.swift`

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()
        // Request notification permissions
        NotificationManager.shared.requestPermission()
    }
}
```

**Wiring:**
- Called by macOS on app launch
- Creates `MenuBarController` (critical orchestration point)
- Requests notification permissions

**Dependencies:**
- `MenuBarController.swift`
- `NotificationManager.swift`

---

### 3. Menu Bar Controller

**File:** `MenuBarController.swift`

```swift
class MenuBarController {
    private var statusItem: NSStatusItem
    private let backgroundService = BackgroundMonitoringService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Create status bar icon
        // Observe backgroundService.isMonitoring
        // Update menu based on state
    }
}
```

**Wiring:**
- Creates `NSStatusItem` (menu bar icon)
- Observes `BackgroundMonitoringService.shared.$isMonitoring`
- Provides UI controls:
  - Toggle Monitoring → `backgroundService.toggleMonitoring()`
  - Toggle Camera Feed → `backgroundService.toggleOverlay()`
  - Settings → `SettingsWindow.shared.showWindow()`
  - Quit → `NSApp.terminate()`

**Dependencies:**
- `BackgroundMonitoringService.swift` (Combine observer)
- `SettingsWindow.swift`

---

### 4. Background Monitoring Service (Orchestrator)

**File:** `BackgroundMonitoringService.swift`

```swift
class BackgroundMonitoringService: ObservableObject {
    static let shared = BackgroundMonitoringService()
    
    @Published var isMonitoring = false
    
    let cameraManager = CameraManager()
    let visionProcessor = VisionProcessor()
    private let stateController = StateController()
    private let notificationManager = NotificationManager.shared
    private let preferencesManager = PreferencesManager.shared
    
    private var cancellables = Set<AnyCancellable>()
}
```

**Wiring Connections:**

#### A. To Camera System
```swift
func startMonitoring() {
    cameraManager.visionProcessor = visionProcessor  // Connect output
    cameraManager.startSession()                     // Start capture
}
```

#### B. From Vision Processor
```swift
visionProcessor.$faceCount
    .sink { [weak self] faceCount in
        self?.stateController.updateFaceCount(faceCount)
    }
    .store(in: &cancellables)
```

#### C. From State Controller
```swift
stateController.$currentState
    .sink { [weak self] state in
        self?.handleStateChange(state)
    }
    .store(in: &cancellables)
```

#### D. To Notification Manager
```swift
func handleStateChange(_ state: StateController.SecurityState) {
    if preferencesManager.notificationsEnabled {
        notificationManager.handleStateChange(to: state)
    }
    // Handle overlay display based on state
}
```

#### E. To Camera Notch Manager
```swift
func showOverlay() {
    CameraNotchManager.shared.showCameraOverlay(
        cameraManager: cameraManager,
        visionProcessor: visionProcessor,
        onDismiss: { /* ... */ }
    )
}
```

**Dependencies:**
- `CameraManager.swift` (owns)
- `VisionProcessor.swift` (owns)
- `StateController.swift` (owns)
- `NotificationManager.swift` (singleton reference)
- `PreferencesManager.swift` (singleton reference)
- `CameraNotchManager.swift` (singleton reference)

---

### 5. Camera Manager

**File:** `CameraManager.swift`

```swift
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = { /* ... */ }()
    
    var visionProcessor: VisionProcessor?  // Injected by BackgroundMonitoringService
}
```

**Wiring:**
- Creates `AVCaptureSession` with front camera
- Configures `AVCaptureVideoDataOutput` → sends frames to `VisionProcessor`
- Provides `previewLayer` for UI display
- `videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)`

**Data Flow:**
```
Camera frames → AVCaptureSession → AVCaptureVideoDataOutput 
    → captureOutput(_:didOutput:from:) 
    → visionProcessor.processFrame()
```

**Dependencies:**
- `VisionProcessor.swift` (injected reference)
- AVFoundation framework

---

### 6. Vision Processor

**File:** `VisionProcessor.swift`

```swift
class VisionProcessor: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var faceCount: Int = 0
    @Published var faceObservations: [VNFaceObservation] = []
    
    func captureOutput(_ output: AVCaptureOutput, 
                      didOutput sampleBuffer: CMSampleBuffer, 
                      from connection: AVCaptureConnection) {
        // Process frame with Vision framework
        // Update faceCount and faceObservations on main thread
    }
}
```

**Wiring:**
- Implements `AVCaptureVideoDataOutputSampleBufferDelegate`
- Called by `CameraManager` for each video frame
- Runs `VNDetectFaceRectanglesRequest`
- Publishes results via `@Published` properties

**Data Flow:**
```
CMSampleBuffer → CVPixelBuffer → VNImageRequestHandler 
    → VNDetectFaceRectanglesRequest 
    → [VNFaceObservation] 
    → @Published faceCount
```

**Observers:**
- `BackgroundMonitoringService` (observes `$faceCount`)

**Dependencies:**
- Vision framework
- AVFoundation (for delegate protocol)

---

### 7. State Controller

**File:** `StateController.swift`

```swift
class StateController: ObservableObject {
    @Published var currentState: SecurityState = .safe
    
    enum SecurityState {
        case safe, warning, alert, error
    }
    
    func updateFaceCount(_ count: Int) {
        // Determine state based on face count
        // Publish state changes
    }
}
```

**Wiring:**
- Receives face count from `BackgroundMonitoringService`
- Applies business logic to determine security state:
  - 0 faces → `.error`
  - 1 face → `.safe`
  - 2 faces → `.warning`
  - 3+ faces → `.alert`
- Publishes state changes

**State Transitions:**
```
faceCount changes → updateFaceCount() 
    → determine new state 
    → currentState = newState 
    → @Published triggers observers
```

**Observers:**
- `BackgroundMonitoringService` (observes `$currentState`)

**Dependencies:** None (pure state machine)

---

### 8. Notification Manager

**File:** `NotificationManager.swift`

```swift
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    func handleStateChange(to newState: StateController.SecurityState) {
        // Rate limiting logic
        // Call CameraNotchManager for notch notifications
    }
}
```

**Wiring:**
- Receives state changes from `BackgroundMonitoringService`
- Rate limits notifications (5s cooldown)
- Delegates to `CameraNotchManager` for UI

**Data Flow:**
```
SecurityState change → handleStateChange() 
    → rate limit check 
    → CameraNotchManager.showNotificationWithActions()
```

**Dependencies:**
- `CameraNotchManager.swift` (static methods)
- `PreferencesManager.swift` (notification settings)

---

### 9. Camera Notch Manager (UI Integration Layer)

**File:** `CameraNotchManager.swift`

```swift
class CameraNotchManager {
    static let shared = CameraNotchManager()
    
    private var currentOverlayViewModel: NotchViewModel?
    private var currentNotificationViewModel: NotchViewModel?
    
    func showCameraOverlay(cameraManager: CameraManager, 
                          visionProcessor: VisionProcessor, 
                          onDismiss: @escaping () -> Void) {
        // Create NotificationContext with camera view
    }
    
    static func showNotificationWithActions(title: String, 
                                           message: String, 
                                           isError: Bool, 
                                           onPreview: @escaping () -> Void, 
                                           onAcknowledge: @escaping () -> Void) {
        // Create NotificationContext with notification view
    }
}
```

**Wiring:**

#### For Camera Overlay:
```swift
CameraManager + VisionProcessor 
    → SimpleCameraNotchView(cameraManager, visionProcessor)
    → NotificationContext(leadingView: X button, 
                         trailingView: Gear + Bell, 
                         bodyView: SimpleCameraNotchView)
    → NotificationContext.open()
    → NotchViewModel
```

#### For Notifications:
```swift
title, message, callbacks 
    → NotificationWithActionsView(title, message, onPreview, onAcknowledge)
    → NotificationContext(leadingView: Icon, 
                         trailingView: EmptyView, 
                         bodyView: NotificationWithActionsView)
    → NotificationContext.open()
    → NotchViewModel
```

**Dependencies:**
- `CameraManager.swift` (parameter)
- `VisionProcessor.swift` (parameter)
- `CameraOverlayView.swift` (CameraPreviewView, FaceDetectionOverlayView)
- `NotchNotification/NotificationContext.swift`
- `PreferencesManager.swift` (for delays and notification settings)
- `SettingsWindow.swift` (gear icon action)
- `BackgroundMonitoringService.swift` (preview action)

---

### 10. Camera Overlay View

**File:** `CameraOverlayView.swift`

```swift
struct CameraPreviewView: NSViewRepresentable {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    func makeNSView(context: Context) -> NSView {
        // Create NSView with previewLayer
    }
}

struct FaceDetectionOverlayView: View {
    @ObservedObject var visionProcessor: VisionProcessor
    
    var body: some View {
        // Draw bounding boxes for detected faces
    }
}
```

**Wiring:**
- `CameraPreviewView` wraps `cameraManager.previewLayer`
- `FaceDetectionOverlayView` observes `visionProcessor.$faceObservations`
- Both rendered by `SimpleCameraNotchView` in `CameraNotchManager`

**Dependencies:**
- `CameraManager.swift` (receives previewLayer)
- `VisionProcessor.swift` (observes face observations)

---

### 11. NotchNotification Framework

**Files:** `NotchNotification/*.swift`

#### NotificationContext
```swift
struct NotificationContext {
    init?(headerLeadingView: some View, 
          headerTrailingView: some View, 
          bodyView: some View, 
          animated: Bool)
    
    func open(forInterval interval: TimeInterval) -> NotchViewModel
}
```

**Wiring:**
- Entry point for creating notch notifications
- Creates `NotchWindow` and `NotchViewModel`
- Returns `NotchViewModel` for external control

#### NotchViewModel
```swift
class NotchViewModel: ObservableObject {
    @Published var status: NotchStatus = .closed
    
    var notchOpenedSize: CGSize
    var headerView: AnyView
    var bodyView: AnyView
    
    func forceClose()
    func scheduleClose(after interval: TimeInterval)
}
```

**Wiring:**
- Manages notification state and animations
- Controls open/close timing
- Exposes `forceClose()` for manual dismissal

#### NotchView
```swift
struct NotchView: View {
    @StateObject var vm: NotchViewModel
    
    var body: some View {
        ZStack {
            notch.clipShape(NotchRectangle(...))
            VStack {
                vm.headerView
                vm.bodyView
            }
            .clipShape(NotchRectangle(...))
        }
        .animation(vm.animation, value: vm.status)
    }
}
```

**Wiring:**
- Renders the actual notch UI
- Uses `NotchRectangle` for curved corners
- Animates based on `vm.status`

**Dependencies:**
- `Ext+NSScreen.swift` (notch detection)
- SwiftUI framework

---

### 12. Preferences Manager

**File:** `PreferencesManager.swift`

```swift
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var notificationsEnabled: Bool
    @Published var overlayAutoHideDelay: Double
    @Published var isMonitoringEnabled: Bool
    @Published var autoStartMonitoring: Bool
    @Published var launchAtLogin: Bool
    @Published var alertThreshold: Double
    
    // All synced to UserDefaults
}
```

**Wiring:**
- Persists all settings to `UserDefaults`
- Observed by:
  - `SettingsView` (UI bindings)
  - `BackgroundMonitoringService` (monitoring state)
  - `NotificationManager` (notification settings)
  - `CameraNotchManager` (auto-hide delay)
  - `NotificationToggleButton` (bell icon state)

**Dependencies:** UserDefaults

---

### 13. Settings View

**File:** `SettingsView.swift`

```swift
struct SettingsView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var backgroundService = BackgroundMonitoringService.shared
    
    var body: some View {
        Form {
            // Notifications section
            // Monitoring section
            // Detection section
        }
    }
}
```

**Wiring:**
- Two-way bindings to `PreferencesManager` via `$` syntax
- Observes multiple managers for UI state
- Displayed by `SettingsWindow`

**Dependencies:**
- `PreferencesManager.swift` (settings bindings)
- `NotificationManager.swift` (permission status)
- `BackgroundMonitoringService.swift` (monitoring state)

---

## Data Flow Examples

### Example 1: Face Detected → Alert → Overlay Shown

```
1. Camera captures frame
   CameraManager.captureSession
   
2. Frame sent to Vision
   → AVCaptureVideoDataOutput
   → VisionProcessor.captureOutput()
   
3. Vision detects 3 faces
   → VNDetectFaceRectanglesRequest
   → visionProcessor.faceCount = 3
   
4. State Controller receives update
   → BackgroundMonitoringService observes $faceCount
   → stateController.updateFaceCount(3)
   → currentState = .alert
   
5. Background Service handles state change
   → BackgroundMonitoringService observes $currentState
   → handleStateChange(.alert)
   
6. Notification shown
   → notificationManager.handleStateChange(to: .alert)
   → CameraNotchManager.showNotificationWithActions()
   → NotificationContext.open()
   
7. Overlay shown
   → BackgroundMonitoringService.showOverlay()
   → CameraNotchManager.showCameraOverlay()
   → NotificationContext.open()
```

### Example 2: User Toggles Monitoring

```
1. User clicks menu
   → MenuBarController menu item
   
2. Toggle monitoring
   → backgroundService.toggleMonitoring()
   
3. Start monitoring
   → BackgroundMonitoringService.startMonitoring()
   
4. Camera starts
   → cameraManager.startSession()
   → AVCaptureSession.startRunning()
   
5. Vision connected
   → cameraManager.visionProcessor = visionProcessor
   
6. State controller starts
   → stateController.startMonitoring()
   
7. Menu updates
   → MenuBarController observes $isMonitoring
   → Updates menu text to "Stop Monitoring"
```

### Example 3: Notification Bell Toggle

```
1. User clicks bell icon in island
   → NotificationToggleButton
   
2. Toggle preference
   → preferencesManager.notificationsEnabled.toggle()
   
3. Icon updates
   → NotificationToggleButton observes @Published property
   → Re-renders with new icon (bell.fill vs bell.slash.fill)
   → Changes color (yellow vs gray)
   
4. Future notifications affected
   → NotificationManager checks preferencesManager.notificationsEnabled
   → Skips sending if disabled
```

## Critical Wiring Patterns

### 1. Singleton Access
```swift
BackgroundMonitoringService.shared
CameraNotchManager.shared
NotificationManager.shared
PreferencesManager.shared
SettingsWindow.shared
```

### 2. Dependency Injection
```swift
// Prevents circular dependencies
CameraNotchManager.showCameraOverlay(
    cameraManager: CameraManager,
    visionProcessor: VisionProcessor
)
```

### 3. Combine Publishers
```swift
visionProcessor.$faceCount
    .sink { faceCount in /* ... */ }
    .store(in: &cancellables)
```

### 4. Delegate Callbacks
```swift
// AVFoundation delegate
videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
```

### 5. Closure Callbacks
```swift
showCameraOverlay(onDismiss: { [weak self] in
    self?.isOverlayVisible = false
})
```

## Summary

The iSee application follows a layered architecture:

1. **Presentation Layer:** SwiftUI views, menu bar UI
2. **Integration Layer:** `CameraNotchManager` (bridges services and UI)
3. **Service Layer:** Background services, state management
4. **Data Layer:** Camera, Vision, preferences persistence

All components are loosely coupled through:
- Combine framework for reactive updates
- Dependency injection for tight dependencies
- Singleton pattern for shared services

This architecture ensures:
- ✅ Testability (dependencies can be mocked)
- ✅ Maintainability (clear separation of concerns)
- ✅ Scalability (easy to add new features)
- ✅ Performance (efficient data flow)

---

**Document Version:** 1.0  
**Last Updated:** October 25, 2025  
**See Also:** `PROJECT_STRUCTURE.md`, `IMPLEMENTATION_SUMMARY.md`

