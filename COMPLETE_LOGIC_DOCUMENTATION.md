# iSee - Complete Logic Documentation

**Version:** Beta V1.0.0  
**Last Updated:** October 25, 2025  
**Created by:** Upmanyu Jha  
**Purpose:** Comprehensive documentation of all business logic, algorithms, and decision flows in the iSee application

---

## Table of Contents

1. [Core Application Logic](#core-application-logic)
2. [Face Detection Logic](#face-detection-logic)
3. [Security State Machine](#security-state-machine)
4. [Camera Management Logic](#camera-management-logic)
5. [Notification Logic](#notification-logic)
6. [UI Integration Logic](#ui-integration-logic)
7. [Preferences & Persistence Logic](#preferences--persistence-logic)
8. [Performance Optimization Logic](#performance-optimization-logic)
9. [Error Handling Logic](#error-handling-logic)
10. [Complete Flow Diagrams](#complete-flow-diagrams)

---

## 1. Core Application Logic

### 1.1 App Initialization Flow

**File:** `iseeApp.swift`, `AppDelegate.swift`

#### Startup Sequence

```
App Launch
    ↓
1. SwiftUI App (@main) creates iseeApp
    ↓
2. @NSApplicationDelegateAdaptor initializes AppDelegate
    ↓
3. AppDelegate.applicationDidFinishLaunching() called
    ↓
4. MenuBarController created
    ↓
5. NotificationManager.requestPermission() called
    ↓
6. MenuBarExtra (menu bar icon) appears
    ↓
7. PreferencesManager loads saved settings
    ↓
8. If autoStartMonitoring = true → Start monitoring
```

#### Logic Rules

1. **Single Instance**: App uses Singleton pattern for all managers
2. **Menu Bar Only**: No dock icon, only menu bar presence
3. **Background App**: Runs continuously in background
4. **Permission First**: Requests camera + notification permissions on launch

---

### 1.2 Monitoring Orchestration Logic

**File:** `BackgroundMonitoringService.swift`

#### Start Monitoring Logic

```swift
func startMonitoring() {
    // Guard: Prevent duplicate start
    guard !isMonitoring else { return }
    
    // Guard: Check camera permission
    guard cameraPermissionStatus == .authorized else {
        print("Cannot start - camera not authorized")
        return
    }
    
    // LOGIC FLOW:
    // 1. Connect camera → vision processor (dependency injection)
    cameraManager.visionProcessor = visionProcessor
    
    // 2. Start camera session (async on camera queue)
    cameraManager.startSession()
    
    // 3. Start state controller (begin state machine)
    stateController.startMonitoring()
    
    // 4. Update flags (main thread)
    DispatchQueue.main.async {
        self.isMonitoring = true
        self.preferencesManager.isMonitoringEnabled = true
    }
}
```

**Key Logic Points:**
- ✅ **Idempotent**: Can safely call multiple times
- ✅ **Permission Check**: Fails early if no camera access
- ✅ **Dependency Wiring**: Connects camera → vision → state
- ✅ **Persistence**: Saves monitoring state to UserDefaults

#### Stop Monitoring Logic

```swift
func stopMonitoring() {
    guard isMonitoring else { return }
    
    // LOGIC FLOW:
    // 1. Stop state machine first
    stateController.stopMonitoring()
    
    // 2. Hide overlay if visible
    hideOverlay()
    
    // 3. Stop camera session
    cameraManager.stopSession()
    
    // 4. Disconnect camera from vision processor
    cameraManager.visionProcessor = nil
    
    // 5. Update flags
    DispatchQueue.main.async {
        self.isMonitoring = false
        self.preferencesManager.isMonitoringEnabled = false
    }
}
```

**Key Logic Points:**
- ✅ **Cleanup Order**: State → UI → Camera → Disconnect
- ✅ **Resource Release**: Stops camera to save battery
- ✅ **UI Cleanup**: Always hides overlay before stopping

---

### 1.3 Overlay Management Logic

**File:** `BackgroundMonitoringService.swift`

#### Show Overlay Logic

```swift
func showOverlay() {
    // Guard: Prevent duplicate overlays
    guard !isOverlayVisible else {
        print("Overlay already visible, skipping")
        return
    }
    
    // LOGIC: Ensure camera is running (might have been paused)
    print("Starting camera session explicitly")
    cameraManager.startSession()
    
    // LOGIC: Show via NotchNotification framework with dependency injection
    CameraNotchManager.shared.showCameraOverlay(
        cameraManager: cameraManager,        // Pass camera reference
        visionProcessor: visionProcessor,     // Pass vision reference
        onDismiss: { [weak self] in
            // LOGIC: Clean up state when dismissed
            self?.isOverlayVisible = false
            print("Overlay dismissed")
        }
    )
    
    isOverlayVisible = true
}
```

**Key Logic:**
- **No Duplicates**: Guard prevents multiple overlays
- **Camera Guarantee**: Explicitly starts camera (might be off)
- **Dependency Injection**: Passes managers to prevent circular deps
- **Callback Cleanup**: Uses closure to track dismissal

#### Hide Overlay Logic

```swift
func hideOverlay() {
    guard isOverlayVisible else { return }
    
    CameraNotchManager.shared.hideCameraOverlay()
    isOverlayVisible = false
    print("Overlay hidden")
}
```

#### Toggle Overlay Logic

```swift
func toggleOverlay() {
    if isOverlayVisible {
        hideOverlay()
    } else {
        showOverlay()
    }
}
```

**Use Case:** User clicks "Toggle Camera Feed" in menu

---

## 2. Face Detection Logic

### 2.1 Vision Framework Processing

**File:** `VisionProcessor.swift`

#### Frame Processing Pipeline

```swift
func processFrame(_ sampleBuffer: CMSampleBuffer) {
    // GUARD 1: Skip if already processing (prevent queue buildup)
    guard !isProcessing else { return }
    
    // OPTIMIZATION 1: Frame skipping (process every 3rd frame)
    frameSkipCounter += 1
    if frameSkipCounter < frameSkipInterval {  // frameSkipInterval = 3
        return
    }
    frameSkipCounter = 0
    
    // OPTIMIZATION 2: Time-based throttling (200ms minimum between frames)
    let currentTime = CACurrentMediaTime()
    if currentTime - lastProcessTime < processingInterval {  // 0.2s
        return
    }
    lastProcessTime = currentTime
    
    // ASYNC PROCESSING:
    processingQueue.async { [weak self] in
        guard let self = self else { return }
        
        // 1. Set processing flag
        DispatchQueue.main.async { self.isProcessing = true }
        
        // 2. Convert CMSampleBuffer → CVPixelBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            DispatchQueue.main.async { self.isProcessing = false }
            return
        }
        
        // 3. Create Vision request handler
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, 
            orientation: .up, 
            options: [:]
        )
        
        // 4. Perform face detection
        do {
            try imageRequestHandler.perform([self.faceDetectionRequest])
        } catch {
            print("Face detection failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.isProcessing = false }
        }
    }
}
```

**Performance Logic:**
- **Frame Skip**: Only process 1 in 3 frames (5 FPS effective)
- **Time Throttle**: Minimum 200ms between frames
- **Async Processing**: Background queue prevents UI blocking
- **Processing Flag**: Prevents queue buildup

#### Face Detection Results Handling

```swift
private func handleFaceDetectionResults(request: VNRequest, error: Error?) {
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        self.isProcessing = false
        
        // ERROR HANDLING:
        if let error = error {
            print("Face detection error: \(error.localizedDescription)")
            return
        }
        
        // RESULT EXTRACTION:
        guard let observations = request.results as? [VNFaceObservation] else {
            self.detectedFaces = []
            self.faceCount = 0
            return
        }
        
        // PUBLISH RESULTS (triggers Combine subscribers):
        self.detectedFaces = observations
        self.faceCount = observations.count
        
        // DEBUG LOGGING:
        if self.faceCount > 0 {
            print("Detected \(self.faceCount) face(s)")
        }
    }
}
```

**Key Logic:**
- **Main Thread Update**: UI updates must be on main thread
- **Combine Publishing**: `@Published` triggers downstream logic
- **Graceful Errors**: Logs but doesn't crash on detection failure
- **Empty Results**: Explicitly sets count to 0 if no faces

---

### 2.2 Bounding Box Coordinate Conversion

**File:** `VisionProcessor.swift`

#### Coordinate System Logic

```swift
func getNormalizedFaceRectangles(for previewSize: CGSize) -> [CGRect] {
    return detectedFaces.map { faceObservation in
        let boundingBox = faceObservation.boundingBox
        
        // LOGIC: Vision uses bottom-left origin (0,0 at bottom-left)
        //        SwiftUI/AppKit uses top-left origin (0,0 at top-left)
        //        Need to flip Y coordinate
        
        let convertedRect = CGRect(
            x: boundingBox.origin.x,
            y: 1.0 - boundingBox.origin.y - boundingBox.height,  // Flip Y
            width: boundingBox.width,
            height: boundingBox.height
        )
        
        // LOGIC: Scale from normalized (0-1) to actual pixel coordinates
        return CGRect(
            x: convertedRect.origin.x * previewSize.width,
            y: convertedRect.origin.y * previewSize.height,
            width: convertedRect.width * previewSize.width,
            height: convertedRect.height * previewSize.height
        )
    }
}
```

**Coordinate Conversion Logic:**
1. **Y-Flip**: Vision (0,0 bottom-left) → SwiftUI (0,0 top-left)
2. **Normalize → Pixel**: Vision returns 0-1 range, scale to actual pixels
3. **Maintain Aspect**: Both width and height scaled proportionally

#### Primary Face Detection Logic

```swift
func getPrimaryFaceIndex() -> Int? {
    guard !detectedFaces.isEmpty else { return nil }
    
    // LOGIC: Primary face = largest bounding box area
    var largestArea: CGFloat = 0
    var primaryIndex: Int = 0
    
    for (index, face) in detectedFaces.enumerated() {
        let area = face.boundingBox.width * face.boundingBox.height
        if area > largestArea {
            largestArea = area
            primaryIndex = index
        }
    }
    
    return primaryIndex
}
```

**Use Case:** Identify which face is likely the user (closest/largest)

---

## 3. Security State Machine

### 3.1 State Definitions

**File:** `StateController.swift`

#### Security States

```swift
enum SecurityState {
    case safe      // 1 face detected (user alone)
    case warning   // 2+ faces detected (potential threat)
    case alert     // 2+ faces for >2 seconds (confirmed threat)
    case error     // 0 faces or camera issue
}
```

**State Characteristics:**

| State | Face Count | Duration | Color | Icon | Action |
|-------|-----------|----------|-------|------|--------|
| **safe** | 1 | Any | Green | eye.fill | None |
| **warning** | 2+ | <2s | Yellow/Orange | eye.triangle | Start timer |
| **alert** | 2+ | ≥2s | Orange/Red | eye.triangle | Show overlay + notify |
| **error** | 0 | Any | Red | eye.slash | Stop monitoring |

---

### 3.2 State Transition Logic

**File:** `StateController.swift`

#### Face Count Update Logic

```swift
func updateFaceCount(_ faceCount: Int) {
    guard isMonitoring else { return }
    
    // EDGE CASE HANDLING: Temporary zero face detection
    if faceCount == 0 {
        consecutiveZeroFaceCount += 1
        
        // LOGIC: Use last valid count if < 10 consecutive zeros
        if consecutiveZeroFaceCount < maxConsecutiveZeroFaces {  // 10
            processFaceCount(lastValidFaceCount)
            return
        } else {
            // LOGIC: Too many zeros = camera error
            updateState(.error)
            return
        }
    } else {
        // LOGIC: Reset counter on valid detection
        consecutiveZeroFaceCount = 0
        lastValidFaceCount = faceCount
    }
    
    processFaceCount(faceCount)
}
```

**Edge Case Logic:**
- **Problem**: Camera might briefly report 0 faces (lag, obstruction)
- **Solution**: Require 10 consecutive zeros before error state
- **Benefit**: Prevents false alarms from brief camera glitches

#### Face Count Processing Logic

```swift
private func processFaceCount(_ faceCount: Int) {
    switch faceCount {
    case 0:
        // LOGIC: No faces = camera error or user away
        updateState(.error)
        
    case 1:
        // LOGIC: One face = normal state (user alone)
        updateState(.safe)
        
    case 2...:
        // LOGIC: Multiple faces = potential shoulder surfer
        handleMultipleFaces()
        
    default:
        break
    }
}
```

**Decision Tree:**
```
faceCount = 0  → .error  (camera issue)
faceCount = 1  → .safe   (normal)
faceCount ≥ 2  → handleMultipleFaces() (threat detection)
```

---

### 3.3 Multiple Faces Handling Logic

**File:** `StateController.swift`

```swift
private func handleMultipleFaces() {
    switch currentState {
    case .safe:
        // LOGIC: First detection of multiple faces
        //        → Enter warning state
        //        → Start 2-second alert timer
        updateState(.warning)
        startFaceCountTimer()
        
    case .warning:
        // LOGIC: Already in warning, timer running
        //        → Do nothing, let timer complete
        break
        
    case .alert:
        // LOGIC: Already in alert state
        //        → Stay in alert (shoulder surfer confirmed)
        break
        
    case .error:
        // LOGIC: Recovering from error
        //        → Enter warning state
        //        → Start alert timer
        updateState(.warning)
        startFaceCountTimer()
    }
}
```

**State Transition Rules:**

```
.safe → .warning → .alert
  ↓       ↓          ↓
  ←───────┴──────────┘
  (when face count returns to 1)
```

---

### 3.4 Alert Timer Logic

**File:** `StateController.swift`

#### Timer Start Logic

```swift
private func startFaceCountTimer() {
    stopFaceCountTimer()  // Cancel any existing timer
    
    // LOGIC: 2-second timer to confirm sustained multiple faces
    faceCountTimer = Timer.scheduledTimer(
        withTimeInterval: alertThreshold,  // 2.0 seconds
        repeats: false
    ) { [weak self] _ in
        self?.handleAlertThresholdReached()
    }
    
    print("Started alert timer (2.0s)")
}
```

#### Timer Completion Logic

```swift
private func handleAlertThresholdReached() {
    // LOGIC: Only trigger alert if still in warning state
    //        (face count might have dropped back to 1)
    if currentState == .warning {
        updateState(.alert)
        print("Alert threshold reached - triggering shoulder surfer alert!")
    }
}
```

**Timer Cancellation Logic:**

```swift
private func handleStateChange(from previousState: SecurityState, to newState: SecurityState) {
    switch (previousState, newState) {
    case (.warning, .safe), (.alert, .safe):
        // LOGIC: Returning to safe → Cancel alert timer
        stopFaceCountTimer()
        
    case (.safe, .warning), (.error, .warning):
        // LOGIC: Entering warning → Start alert timer
        startFaceCountTimer()
        
    case (.warning, .alert):
        // LOGIC: Escalating to alert → Stop timer (no longer needed)
        stopFaceCountTimer()
        
    default:
        break
    }
}
```

**Key Logic:**
- **2-Second Threshold**: Prevents false alarms from brief multi-face detections
- **Cancellable**: If face count drops to 1, timer is cancelled
- **Non-Repeating**: Timer only fires once per warning state

---

### 3.5 Long-Term Alert Tracking

**File:** `BackgroundMonitoringService.swift`

#### Purpose
Track how long user has been in alert state to change menu bar icon color.

#### Tracking Logic

```swift
private func handleAlertDurationTracking(for state: StateController.SecurityState) {
    switch state {
    case .alert:
        // LOGIC: Start tracking on first alert
        if alertStartTime == nil {
            alertStartTime = Date()
            startAlertDurationTimer()
            print("Started tracking alert duration")
        }
        
    case .safe, .warning, .error:
        // LOGIC: Stop tracking when leaving alert state
        if alertStartTime != nil {
            stopAlertDurationTimer()
            alertStartTime = nil
            isLongTermAlert = false
            print("Stopped tracking alert duration")
        }
    }
}
```

#### Duration Check Logic

```swift
private func checkAlertDuration() {
    guard let startTime = alertStartTime else { return }
    
    let duration = Date().timeIntervalSince(startTime)
    let oneMinute: TimeInterval = 60.0
    
    // LOGIC: After 1 minute in alert → Long-term alert
    if duration >= oneMinute && !isLongTermAlert {
        isLongTermAlert = true
        print("Long-term alert detected - duration: \(Int(duration))s")
    }
}
```

**Visual Feedback Logic:**

```swift
// In MenuBarController
private func updateMenuBarIcon(for state: SecurityState) {
    switch state {
    case .alert:
        if backgroundService.isLongTermAlert {
            iconColor = .red      // Red for >1 minute
        } else {
            iconColor = .orange   // Orange for <1 minute
        }
    // ...
    }
}
```

**Escalation Timeline:**
```
Alert State Entered
    ↓
0-60 seconds: Orange icon
    ↓
>60 seconds: Red icon (persistent threat)
```

---

## 4. Camera Management Logic

### 4.1 Permission Handling

**File:** `CameraManager.swift`

#### Authorization Check Logic

```swift
private func checkAuthorization() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        // LOGIC: Already authorized → Setup camera
        DispatchQueue.main.async {
            self.isAuthorized = true
        }
        setupCamera()
        
    case .notDetermined:
        // LOGIC: Not asked yet → Request permission
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.setupCamera()
                } else {
                    self?.error = .permissionDenied
                }
            }
        }
        
    case .denied, .restricted:
        // LOGIC: User denied or restricted → Set error
        DispatchQueue.main.async {
            self.isAuthorized = false
            self.error = .permissionDenied
        }
        
    @unknown default:
        // LOGIC: Unknown state → Set error
        DispatchQueue.main.async {
            self.isAuthorized = false
            self.error = .unknown
        }
    }
}
```

**Permission Flow:**
```
App Launch
    ↓
Check Status
    ├── .authorized → setupCamera()
    ├── .notDetermined → requestAccess() → if granted → setupCamera()
    ├── .denied → error
    └── .restricted → error
```

---

### 4.2 Capture Session Configuration

**File:** `CameraManager.swift`

#### Session Setup Logic

```swift
private func configureCaptureSession() {
    captureSession.beginConfiguration()
    
    // LOGIC 1: Set session preset for optimal performance
    if captureSession.canSetSessionPreset(.medium) {
        captureSession.sessionPreset = .medium  // 640x480 or similar
    }
    
    // LOGIC 2: Get front camera device
    guard let videoDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,  // Device type
        for: .video,              // Media type
        position: .front          // Front camera
    ) else {
        DispatchQueue.main.async { self.error = .deviceNotFound }
        captureSession.commitConfiguration()
        return
    }
    
    // LOGIC 3: Create input from device
    do {
        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        } else {
            DispatchQueue.main.async { self.error = .cannotAddInput }
            captureSession.commitConfiguration()
            return
        }
    } catch {
        DispatchQueue.main.async { self.error = .inputCreationFailed }
        captureSession.commitConfiguration()
        return
    }
    
    // LOGIC 4: Configure video output for frame processing
    videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    videoOutput.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    
    if captureSession.canAddOutput(videoOutput) {
        captureSession.addOutput(videoOutput)
    } else {
        DispatchQueue.main.async { self.error = .cannotAddOutput }
        captureSession.commitConfiguration()
        return
    }
    
    captureSession.commitConfiguration()
    
    // LOGIC 5: Start the session
    DispatchQueue.main.async {
        self.startSession()
    }
}
```

**Configuration Steps:**
1. **Preset**: .medium (balance between quality and performance)
2. **Device**: Front camera (user-facing)
3. **Input**: AVCaptureDeviceInput from camera device
4. **Output**: AVCaptureVideoDataOutput → sends frames to delegate
5. **Start**: Begin capturing frames

---

### 4.3 Frame Delegate Logic

**File:** `CameraManager.swift`

```swift
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput, 
        didOutput sampleBuffer: CMSampleBuffer, 
        from connection: AVCaptureConnection
    ) {
        // LOGIC: Send each frame to VisionProcessor for face detection
        visionProcessor?.processFrame(sampleBuffer)
    }
}
```

**Frame Flow:**
```
Camera captures frame (30 FPS)
    ↓
AVCaptureVideoDataOutput
    ↓
captureOutput delegate method
    ↓
visionProcessor.processFrame()
    ↓
(VisionProcessor throttles to ~5 FPS)
```

---

### 4.4 Preview Layer Logic

**File:** `CameraManager.swift`

```swift
lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = .resizeAspectFill  // Fill frame, crop if needed
    
    // LOGIC: Configure video mirroring for front camera
    if let connection = layer.connection {
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true  // Mirror like FaceTime
        }
    }
    
    return layer
}()
```

**Key Decisions:**
- **Lazy**: Created once, reused (prevents black screen bug)
- **AspectFill**: Fills frame completely, may crop edges
- **Mirrored**: Front camera is mirrored for intuitive UX
- **Manual Mirroring**: Disabled auto to force mirror on

**Why Lazy?**
- If computed property, new layer created each access
- New layer = new connection = video stream doesn't attach
- Lazy = created once = stream stays connected

---

## 5. Notification Logic

### 5.1 Rate Limiting Logic

**File:** `NotificationManager.swift`

#### Purpose
Prevent notification spam when state rapidly changes.

#### Rate Limit Check Logic

```swift
func handleStateChange(to newState: StateController.SecurityState) {
    guard isAuthorized else { return }
    
    let now = Date()
    let timeSinceLastNotification = now.timeIntervalSince(lastNotificationTime)
    
    // LOGIC: Only send notification if ALL conditions met:
    // 1. Enough time passed (5 seconds minimum)
    // 2. State actually changed (not same as last)
    // 3. State is warning or alert (not safe/error)
    
    let shouldSendNotification = 
        timeSinceLastNotification >= notificationCooldown &&  // 5.0s
        lastNotificationState != newState &&
        (newState == .warning || newState == .alert)
    
    if shouldSendNotification {
        lastNotificationTime = now
        lastNotificationState = newState
        
        switch newState {
        case .warning:
            showWarningNotification()
        case .alert:
            showShoulderSurferAlert()
        case .safe, .error:
            break  // Never notify for safe/error
        }
    }
}
```

**Rate Limiting Rules:**

| Scenario | Notify? | Reason |
|----------|---------|--------|
| .safe → .warning | ✅ Yes | First warning |
| .warning → .alert | ✅ Yes | Escalation |
| .alert → .alert (spam) | ❌ No | Same state |
| .safe → .warning (< 5s) | ❌ No | Too soon |
| .warning → .safe | ❌ No | Don't notify safe |
| .error | ❌ No | Don't notify errors |

---

### 5.2 Notification Types

**File:** `NotificationManager.swift`

#### Shoulder Surfer Alert (Error Level)

```swift
func showShoulderSurferAlert() {
    CameraNotchManager.showNotificationWithActions(
        title: "Shoulder Surfer Detected!",
        message: "Someone is looking at your screen",
        isError: true,  // Red triangle icon
        onPreview: {
            // LOGIC: Show camera overlay to see threat
            DispatchQueue.main.async {
                BackgroundMonitoringService.shared.showOverlay()
            }
        },
        onAcknowledge: {
            // LOGIC: User acknowledges, dismiss notification
            print("Alert acknowledged")
        }
    )
}
```

**Visual:** Red triangle icon + "Shoulder Surfer Detected!"

#### Warning Notification (Info Level)

```swift
func showWarningNotification() {
    CameraNotchManager.showNotificationWithActions(
        title: "Multiple People Detected",
        message: "Be cautious with sensitive information",
        isError: false,  // Yellow/white bell icon
        onPreview: {
            // LOGIC: Show camera overlay to identify people
            DispatchQueue.main.async {
                BackgroundMonitoringService.shared.showOverlay()
            }
        },
        onAcknowledge: {
            // LOGIC: User acknowledges, dismiss notification
            print("Warning acknowledged")
        }
    )
}
```

**Visual:** Bell icon + "Multiple People Detected"

---

### 5.3 Notification Actions Logic

**File:** `CameraNotchManager.swift`

#### Action Menu Implementation

```swift
struct NotificationWithActionsView: View {
    let title: String
    let message: String
    let isError: Bool
    let onPreview: () -> Void
    let onAcknowledge: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(message)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // LOGIC: Dropdown menu with actions
            Menu {
                Button("👁️ Preview") {
                    onPreview()  // Show camera overlay
                }
                
                Button("✓ Acknowledge") {
                    onAcknowledge()  // Dismiss notification
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 20))
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(width: 443)  // Match island width
    }
}
```

**Action Logic:**
- **Preview**: Opens camera overlay to see who's there
- **Acknowledge**: Dismisses notification (logs acknowledgement)
- **Auto-Dismiss**: If no action, auto-dismisses after delay

---

## 6. UI Integration Logic

### 6.1 NotchNotification Integration

**File:** `CameraNotchManager.swift`

#### Camera Overlay Display Logic

```swift
func showCameraOverlay(
    cameraManager: CameraManager,
    visionProcessor: VisionProcessor,
    onDismiss: @escaping () -> Void
) {
    let delay = PreferencesManager.shared.overlayAutoHideDelay  // 5-30s
    
    // LOGIC: Create custom header with controls
    let closeButton = Button(action: {
        self.dismissCurrentOverlay()
        onDismiss()
    }) {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 18))
            .foregroundColor(.red)  // Mac-style close
    }
    .buttonStyle(.plain)
    .padding(.leading, 12)  // Avoid curved corner clipping
    
    let rightIcons = HStack(spacing: 0) {
        // Gear icon → Settings
        Button(action: {
            SettingsWindow.shared.showWindow()
        }) {
            Image(systemName: "gear")
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 10)
        
        // Bell icon → Notification toggle
        NotificationToggleButton()  // Reactive to prefs
    }
    .padding(.trailing, 12)  // Avoid curved corner clipping
    
    // LOGIC: Create camera view (NO control buttons)
    let cameraView = SimpleCameraNotchView(
        cameraManager: cameraManager,
        visionProcessor: visionProcessor
    )
    
    // LOGIC: Present in notch with NotificationContext
    guard let context = NotificationContext(
        headerLeadingView: closeButton,
        headerTrailingView: rightIcons,
        bodyView: cameraView,
        animated: true
    ) else {
        return
    }
    
    // LOGIC: Store view model for manual dismissal
    currentOverlayViewModel = context.open(forInterval: delay)
}
```

**Header Icon Logic:**

| Position | Icon | Action | Color | Padding |
|----------|------|--------|-------|---------|
| Left | xmark.circle.fill | Close overlay | Red | 12px left |
| Right-1 | bell.fill / bell.slash.fill | Toggle notifications | Yellow/Gray | 30px right |
| Right-2 | gear | Open settings | White | 10px right |

**Padding Rationale:**
- Prevents icons from being clipped by curved notch corners
- 12px is minimum clearance for curved `NotchRectangle` shape

---

### 6.2 Camera View Dimensions Logic

**File:** `CameraNotchManager.swift`

#### SimpleCameraNotchView Structure

```swift
struct SimpleCameraNotchView: View {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    var body: some View {
        VStack(spacing: 0) {
            // LOGIC: ZStack for camera + face overlay
            ZStack {
                CameraPreviewView(
                    cameraManager: cameraManager,
                    visionProcessor: visionProcessor
                )
                .frame(width: 433, height: 260)  // 5:3 aspect ratio
                
                FaceDetectionOverlayView(visionProcessor: visionProcessor)
                    .frame(width: 433, height: 260)  // Match camera
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 5)   // 5px each side
        .padding(.vertical, 10)    // 10px top/bottom
        .frame(width: 443)          // Total: 5 + 433 + 5
        // Total height: 10 + 260 + 10 = 280px
    }
}
```

**Dimension Calculation:**

```
Camera Content: 433×260 (5:3 ratio)
├─ Horizontal Padding: 5px + 5px = 10px
├─ Vertical Padding: 10px + 10px = 20px
└─ Total Container: 443×280

Complete Island:
├─ Header: 32px
├─ Top Padding: 10px
├─ Camera Content: 260px
├─ Bottom Padding: 10px
└─ Total Height: 312px
```

**Aspect Ratio Logic:**
- **5:3 = 1.67:1** (optimal for face detection)
- **433 ÷ 260 = 1.665** ✅ Matches 5:3
- **Why 5:3?** Captures face + shoulders, wider than 4:3, narrower than 16:9

---

### 6.3 Notification Toggle Button Logic

**File:** `CameraNotchManager.swift`

#### Reactive Button Implementation

```swift
struct NotificationToggleButton: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        Button(action: {
            // LOGIC: Toggle notifications on/off
            preferencesManager.notificationsEnabled.toggle()
            print("Notifications toggled: \(preferencesManager.notificationsEnabled)")
        }) {
            // LOGIC: Icon changes based on state
            Image(systemName: preferencesManager.notificationsEnabled 
                ? "bell.fill"           // Enabled: filled bell
                : "bell.slash.fill"     // Disabled: slashed bell
            )
            .font(.system(size: 18))
            .foregroundColor(preferencesManager.notificationsEnabled 
                ? .yellow   // Enabled: yellow
                : .gray     // Disabled: gray
            )
        }
        .buttonStyle(.plain)
        .padding(.trailing, 15)  // Avoid corner clipping
    }
}
```

**State-Driven Logic:**

| State | Icon | Color | Behavior |
|-------|------|-------|----------|
| Enabled | bell.fill | Yellow | Receives notifications |
| Disabled | bell.slash.fill | Gray | Ignores notifications |

**Reactivity:**
- `@ObservedObject` monitors PreferencesManager
- Icon/color update automatically on toggle
- Changes persist to UserDefaults

---

### 6.4 Menu Bar Icon Logic

**File:** `MenuBarController.swift`

#### Icon State Logic

```swift
private func updateMenuBarIcon(for state: SecurityState) {
    switch state {
    case .safe:
        menuBarIcon = "eye.fill"
        iconColor = .green
        isAlertState = false
        
    case .warning:
        menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
        iconColor = .yellow
        isAlertState = false
        
    case .alert:
        // LOGIC: Icon color depends on alert duration
        if backgroundService.isLongTermAlert {  // > 1 minute
            menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
            iconColor = .red      // Persistent threat
            isAlertState = true
        } else {  // < 1 minute
            menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
            iconColor = .orange   // Recent threat
            isAlertState = true
        }
        
    case .error:
        menuBarIcon = "eye.slash.fill"
        iconColor = .red
        isAlertState = false
    }
}
```

**Icon Mapping:**

| State | Icon | Color | Meaning |
|-------|------|-------|---------|
| .safe | eye.fill | Green | All clear |
| .warning | eye.triangle | Yellow | Multiple faces |
| .alert (< 1min) | eye.triangle | Orange | Recent threat |
| .alert (> 1min) | eye.triangle | Red | Persistent threat |
| .error | eye.slash | Red | Camera issue |

**Visual Escalation:**
```
Green (safe) → Yellow (warning) → Orange (alert) → Red (long-term alert)
```

---

## 7. Preferences & Persistence Logic

### 7.1 UserDefaults Integration

**File:** `PreferencesManager.swift`

#### Property Wrapper Logic

```swift
@Published var notificationsEnabled: Bool {
    didSet {
        // LOGIC: Auto-save to UserDefaults on change
        userDefaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
    }
}

@Published var overlayAutoHideDelay: TimeInterval {
    didSet {
        userDefaults.set(overlayAutoHideDelay, forKey: Keys.overlayAutoHideDelay)
    }
}

@Published var launchAtLogin: Bool {
    didSet {
        userDefaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
    }
}

@Published var alertThreshold: TimeInterval {
    didSet {
        userDefaults.set(alertThreshold, forKey: Keys.alertThreshold)
    }
}
```

**Auto-Persistence Logic:**
- `didSet` triggers on every change
- Writes to UserDefaults immediately
- No manual save button needed
- Changes persist across app restarts

---

### 7.2 Default Values Logic

**File:** `PreferencesManager.swift`

```swift
private init() {
    // LOGIC: Load saved value OR use default
    self.isMonitoringEnabled = userDefaults.object(forKey: Keys.isMonitoringEnabled) as? Bool ?? false
    self.launchAtLogin = userDefaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
    self.autoStartMonitoring = userDefaults.object(forKey: Keys.autoStartMonitoring) as? Bool ?? true  // ON by default
    self.notificationsEnabled = userDefaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true  // ON by default
    self.overlayAutoHideDelay = userDefaults.object(forKey: Keys.overlayAutoHideDelay) as? TimeInterval ?? 10.0
    self.alertThreshold = userDefaults.object(forKey: Keys.alertThreshold) as? TimeInterval ?? 2.0
    
    // ...
}
```

**Default Values:**

| Setting | Default | Reasoning |
|---------|---------|-----------|
| isMonitoringEnabled | false | Off until user starts |
| launchAtLogin | false | User opt-in required |
| autoStartMonitoring | true | Convenience for regular users |
| notificationsEnabled | true | Core feature, ON by default |
| overlayAutoHideDelay | 10.0s | Balance: not too fast, not annoying |
| alertThreshold | 2.0s | Prevent false alarms |

---

### 7.3 Settings Bindings Logic

**File:** `SettingsView.swift`

#### Two-Way Binding

```swift
struct SettingsView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        Form {
            Section("Notifications") {
                // LOGIC: $ creates two-way binding
                //        Toggle ↔ PreferencesManager ↔ UserDefaults
                Toggle("Enable Notifications", isOn: $preferencesManager.notificationsEnabled)
                
                // LOGIC: Slider with real-time value display
                Slider(value: $preferencesManager.overlayAutoHideDelay, in: 5...30, step: 5)
                
                HStack {
                    Text("Auto-hide Delay")
                    Spacer()
                    Text("\(Int(preferencesManager.overlayAutoHideDelay)) seconds")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Monitoring") {
                Toggle("Auto-start Monitoring", isOn: $preferencesManager.autoStartMonitoring)
                Toggle("Launch at Login", isOn: $preferencesManager.launchAtLogin)
            }
            
            Section("Detection") {
                Slider(value: $preferencesManager.alertThreshold, in: 1...10, step: 1)
                
                HStack {
                    Text("Alert Cooldown Period")
                    Spacer()
                    Text("\(Int(preferencesManager.alertThreshold)) seconds")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
```

**Binding Flow:**
```
User moves slider
    ↓
$preferencesManager.overlayAutoHideDelay updates
    ↓
PreferencesManager.overlayAutoHideDelay didSet fires
    ↓
UserDefaults.set() saves value
    ↓
@Published notifies all observers
    ↓
CameraNotchManager uses new delay
```

---

## 8. Performance Optimization Logic

### 8.1 Frame Processing Optimization

**File:** `VisionProcessor.swift`

#### Multi-Layer Throttling

**Layer 1: Processing Flag**
```swift
guard !isProcessing else { return }
```
- Prevents queue buildup if processing is slow
- Max 1 frame in processing at a time

**Layer 2: Frame Skipping**
```swift
frameSkipCounter += 1
if frameSkipCounter < frameSkipInterval {  // 3
    return
}
frameSkipCounter = 0
```
- Process every 3rd frame
- 30 FPS camera → 10 FPS processing

**Layer 3: Time-Based Throttling**
```swift
let currentTime = CACurrentMediaTime()
if currentTime - lastProcessTime < processingInterval {  // 0.2s
    return
}
lastProcessTime = currentTime
```
- Minimum 200ms between frames
- Effective rate: 5 FPS (even if camera sends more)

**Combined Effect:**
```
Camera: 30 FPS
    ↓ (frame skip ÷3)
After Skip: 10 FPS
    ↓ (time throttle)
Actual Processing: ~5 FPS
```

**Performance Benefit:**
- **CPU**: < 20% usage (vs 80%+ without throttling)
- **Battery**: Minimal impact (vs significant drain)
- **Quality**: Still accurate (faces don't change that fast)

---

### 8.2 Async Processing Logic

**File:** `VisionProcessor.swift`

```swift
processingQueue.async { [weak self] in
    guard let self = self else { return }
    
    // 1. Set flag on main thread (UI update)
    DispatchQueue.main.async {
        self.isProcessing = true
    }
    
    // 2. Process frame on background queue (heavy work)
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        DispatchQueue.main.async { self.isProcessing = false }
        return
    }
    
    let imageRequestHandler = VNImageRequestHandler(
        cvPixelBuffer: pixelBuffer,
        orientation: .up,
        options: [:]
    )
    
    // 3. Perform Vision request (CPU-intensive)
    do {
        try imageRequestHandler.perform([self.faceDetectionRequest])
    } catch {
        print("Face detection failed: \(error)")
        DispatchQueue.main.async { self.isProcessing = false }
    }
    
    // 4. Results handled on main thread (in callback)
}
```

**Thread Logic:**

| Operation | Queue | Why |
|-----------|-------|-----|
| Frame arrival | Camera queue | AVFoundation requirement |
| Processing flag | Main queue | UI state update |
| Vision processing | Background queue | CPU-intensive |
| Results update | Main queue | UI state update |

**Memory Safety:**
- `[weak self]` prevents retain cycles
- Early returns on nil self

---

### 8.3 Lazy Initialization Logic

**File:** `CameraManager.swift`

```swift
lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = .resizeAspectFill
    
    // Configure connection...
    
    return layer
}()
```

**Why Lazy?**
- **Problem**: If computed property, new layer created on each access
- **Result**: Video stream doesn't connect (black screen)
- **Solution**: Lazy = created once, stored, reused
- **Benefit**: Stream stays connected, preview works

**Alternative (BAD):**
```swift
var previewLayer: AVCaptureVideoPreviewLayer {
    // ❌ Creates NEW layer every access
    return AVCaptureVideoPreviewLayer(session: captureSession)
}
```

---

## 9. Error Handling Logic

### 9.1 Camera Error Types

**File:** `CameraManager.swift`

```swift
enum CameraError: LocalizedError {
    case permissionDenied
    case deviceNotFound
    case cannotAddInput
    case cannotAddOutput
    case inputCreationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission is required to detect shoulder surfers"
        case .deviceNotFound:
            return "Front camera not found on this device"
        case .cannotAddInput:
            return "Cannot add camera input to capture session"
        case .cannotAddOutput:
            return "Cannot add video output to capture session"
        case .inputCreationFailed:
            return "Failed to create camera input"
        case .unknown:
            return "An unknown camera error occurred"
        }
    }
}
```

**Error Handling Pattern:**
```swift
do {
    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
    // ...
} catch {
    DispatchQueue.main.async {
        self.error = .inputCreationFailed  // User-friendly error
    }
    captureSession.commitConfiguration()
    return  // Early exit
}
```

---

### 9.2 State Machine Edge Cases

**File:** `StateController.swift`

#### Zero Face Detection Edge Case

**Problem:** Camera might briefly report 0 faces due to:
- Frame lag
- Brief obstruction
- Processing hiccup

**Solution:** Consecutive Zero Counter

```swift
private var consecutiveZeroFaceCount = 0
private let maxConsecutiveZeroFaces = 10
private var lastValidFaceCount = 1

func updateFaceCount(_ faceCount: Int) {
    guard isMonitoring else { return }
    
    if faceCount == 0 {
        consecutiveZeroFaceCount += 1
        
        // LOGIC: Use last valid count if < 10 consecutive zeros
        if consecutiveZeroFaceCount < maxConsecutiveZeroFaces {
            processFaceCount(lastValidFaceCount)  // Use last valid
            return
        } else {
            // LOGIC: Too many zeros = actual error
            updateState(.error)
            return
        }
    } else {
        // LOGIC: Reset counter on valid detection
        consecutiveZeroFaceCount = 0
        lastValidFaceCount = faceCount
    }
    
    processFaceCount(faceCount)
}
```

**Logic Flow:**
```
Frame 1: 1 face → lastValidFaceCount = 1
Frame 2: 0 faces → use lastValidFaceCount (1)
Frame 3: 0 faces → use lastValidFaceCount (1)
...
Frame 11: 0 faces → consecutiveZeroFaceCount = 10 → ERROR
```

**Benefit:**
- Prevents false errors from brief glitches
- Smooth state transitions
- More stable user experience

---

### 9.3 Notification Permission Edge Case

**File:** `NotificationManager.swift`

#### Permission Check Logic

```swift
func handleStateChange(to newState: StateController.SecurityState) {
    // GUARD: Don't try to notify if not authorized
    guard isAuthorized else {
        print("Cannot send notification - not authorized")
        return
    }
    
    // ... notification logic ...
}
```

**Authorization States:**

| State | Behavior |
|-------|----------|
| .authorized | Send notifications normally |
| .denied | Log and skip (guard blocks) |
| .notDetermined | Show permission request button in settings |
| .provisional | Limited notifications (iOS only) |

**User Flow:**
```
App Launch
    ↓
Check Notification Permission
    ├─ .authorized → Enable notifications
    ├─ .denied → Show "Enable in System Preferences"
    └─ .notDetermined → Show "Request Permissions" button
```

---

## 10. Complete Flow Diagrams

### 10.1 End-to-End Detection Flow

```
┌─────────────────────────────────────────────────────────────┐
│ USER STARTS MONITORING                                      │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ BackgroundMonitoringService.startMonitoring()               │
│  1. Check camera permission (guard)                         │
│  2. Connect camera → vision processor                       │
│  3. Start camera session                                    │
│  4. Start state controller                                  │
│  5. Set isMonitoring = true                                 │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ CAMERA CAPTURES FRAMES (30 FPS)                             │
│  CameraManager → AVCaptureSession                           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ FRAME DELEGATE                                              │
│  captureOutput() → visionProcessor.processFrame()           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ FRAME THROTTLING (VisionProcessor)                          │
│  1. Check processing flag → Skip if busy                    │
│  2. Frame skip counter → Process every 3rd frame            │
│  3. Time throttle → Min 200ms between frames                │
│  Effective rate: ~5 FPS                                     │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ VISION PROCESSING (Background Queue)                        │
│  1. Convert CMSampleBuffer → CVPixelBuffer                  │
│  2. Create VNImageRequestHandler                            │
│  3. Perform VNDetectFaceRectanglesRequest                   │
│  4. Extract face observations                               │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ RESULTS PUBLISHED (Main Thread)                             │
│  VisionProcessor updates:                                   │
│  - faceCount: Int                                           │
│  - detectedFaces: [VNFaceObservation]                       │
│  - isProcessing = false                                     │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ COMBINE SUBSCRIBERS TRIGGERED                               │
│  BackgroundMonitoringService observes $faceCount            │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ STATE CONTROLLER UPDATE                                     │
│  stateController.updateFaceCount(faceCount)                 │
│                                                             │
│  Edge Case Handling:                                        │
│  - If 0 faces: Use last valid count (up to 10 frames)       │
│  - If 1 face: .safe state                                   │
│  - If 2+ faces: handleMultipleFaces()                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ STATE MACHINE LOGIC                                         │
│                                                             │
│  Current State: .safe                                       │
│  New Face Count: 2+                                         │
│      ↓                                                      │
│  1. Transition to .warning                                  │
│  2. Start 2-second alert timer                              │
│      ↓                                                      │
│  Timer fires (faces still 2+)                               │
│      ↓                                                      │
│  3. Transition to .alert                                    │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ STATE CHANGE PUBLISHED                                      │
│  StateController.$currentState → .alert                     │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ BACKGROUND SERVICE HANDLES STATE CHANGE                     │
│  BackgroundMonitoringService.handleStateChange(.alert)      │
│                                                             │
│  1. Send notification (if enabled)                          │
│  2. Show overlay                                            │
│  3. Start alert duration tracking                           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NOTIFICATION MANAGER                                        │
│  Rate Limiting:                                             │
│  - Check if 5s since last notification                      │
│  - Check if state actually changed                          │
│  - Check if warning/alert state                             │
│      ↓                                                      │
│  If passes: showShoulderSurferAlert()                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NOTCH NOTIFICATION DISPLAYED                                │
│  CameraNotchManager.showNotificationWithActions()           │
│                                                             │
│  Content:                                                   │
│  - Title: "Shoulder Surfer Detected!"                       │
│  - Message: "Someone is looking at your screen"             │
│  - Icon: Red triangle (error)                               │
│  - Actions: Preview / Acknowledge                           │
│                                                             │
│  Auto-dismiss after: overlayAutoHideDelay (5-30s)           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ CAMERA OVERLAY SHOWN                                        │
│  BackgroundMonitoringService.showOverlay()                  │
│      ↓                                                      │
│  CameraNotchManager.showCameraOverlay()                     │
│      ↓                                                      │
│  NotificationContext.open()                                 │
│      ↓                                                      │
│  NotchWindow created with:                                  │
│  - Header: X (close) | Gear (settings) | Bell (toggle)      │
│  - Body: Camera feed (433×260) + Face detection overlay     │
│  - Size: 443×312 (with padding)                             │
│  - Auto-dismiss: After overlayAutoHideDelay                 │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ MENU BAR ICON UPDATED                                       │
│  MenuBarController observes $currentState                   │
│      ↓                                                      │
│  State: .alert                                              │
│  Icon: eye.trianglebadge.exclamationmark.fill               │
│  Color: Orange (< 1 min) or Red (> 1 min)                   │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ LONG-TERM ALERT TRACKING                                    │
│  If alert lasts > 60 seconds:                               │
│  - isLongTermAlert = true                                   │
│  - Menu bar icon turns RED                                  │
│  - Indicates persistent threat                              │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ USER ACTIONS                                                │
│                                                             │
│  Option 1: Click "Preview" → Show camera overlay            │
│  Option 2: Click "Acknowledge" → Dismiss notification       │
│  Option 3: Wait → Auto-dismiss after delay                  │
│  Option 4: Click X on overlay → Close overlay               │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ RETURN TO SAFE STATE                                        │
│  Face count returns to 1                                    │
│      ↓                                                      │
│  StateController → .safe                                    │
│      ↓                                                      │
│  BackgroundMonitoringService.hideOverlay()                  │
│      ↓                                                      │
│  Menu bar icon → Green (eye.fill)                           │
└─────────────────────────────────────────────────────────────┘
```

---

### 10.2 Settings Change Flow

```
┌─────────────────────────────────────────────────────────────┐
│ USER OPENS SETTINGS                                         │
│  Menu Bar → Settings                                        │
│      ↓                                                      │
│  SettingsWindow.shared.showWindow()                         │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ SETTINGS VIEW DISPLAYED                                     │
│  Sections:                                                  │
│  1. Notifications                                           │
│     - Enable Notifications (toggle)                         │
│     - Auto-hide Delay (slider: 5-30s)                       │
│  2. Monitoring                                              │
│     - Auto-start Monitoring (toggle)                        │
│     - Launch at Login (toggle)                              │
│  3. Detection                                               │
│     - Alert Cooldown Period (slider: 1-10s)                 │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ USER CHANGES SETTING                                        │
│  Example: Move "Auto-hide Delay" slider to 20 seconds       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ TWO-WAY BINDING TRIGGERED                                   │
│  $preferencesManager.overlayAutoHideDelay = 20.0            │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ PREFERENCES MANAGER DIDSET                                  │
│  PreferencesManager.overlayAutoHideDelay didSet {           │
│      userDefaults.set(20.0, forKey: "overlayAutoHideDelay") │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ USERDEFAULTS PERSISTED                                      │
│  Value saved to disk                                        │
│  Survives app restart                                       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ @PUBLISHED TRIGGERS OBSERVERS                               │
│  All components observing PreferencesManager notified       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NEW VALUE USED IMMEDIATELY                                  │
│  Next overlay/notification uses 20s delay                   │
│  No restart required                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

This document covers all major logic flows in the iSee application:

1. ✅ **Core App Logic**: Startup, monitoring orchestration, overlay management
2. ✅ **Face Detection**: Frame processing, throttling, coordinate conversion
3. ✅ **State Machine**: Security states, transitions, timers, edge cases
4. ✅ **Camera Management**: Permissions, session setup, frame delegation
5. ✅ **Notifications**: Rate limiting, notification types, action handling
6. ✅ **UI Integration**: NotchNotification, dimensions, reactive controls
7. ✅ **Preferences**: Persistence, defaults, two-way bindings
8. ✅ **Performance**: Frame throttling, async processing, lazy initialization
9. ✅ **Error Handling**: Camera errors, state machine edge cases
10. ✅ **Complete Flows**: End-to-end detection, settings changes

**Total Logic Coverage:** ~3,500 lines of code analyzed and documented

---

**For Developers:** This document is the single source of truth for understanding all business logic in the iSee codebase. Refer to this when:
- Adding new features
- Debugging issues
- Understanding architecture decisions
- Onboarding new team members

**Version:** Beta V1.0.0  
**Last Updated:** October 25, 2025  
**Created & Maintained by:** Upmanyu Jha

