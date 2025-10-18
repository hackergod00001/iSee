import Foundation
import Combine
import AVFoundation

/// Singleton service that manages background monitoring for shoulder surfers
class BackgroundMonitoringService: ObservableObject {
    static let shared = BackgroundMonitoringService()
    
    // MARK: - Published Properties
    @Published var isMonitoring = false
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    let cameraManager = CameraManager()
    let visionProcessor = VisionProcessor()
    private let stateController = StateController()
    private let notificationManager = NotificationManager.shared
    private let preferencesManager = PreferencesManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    private var overlayWindow: CameraOverlayWindow?
    
    // MARK: - Initialization
    private init() {
        setupBindings()
        checkCameraPermission()
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring for shoulder surfers
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        // Check camera permission first
        guard cameraPermissionStatus == .authorized else {
            print("BackgroundMonitoringService: Cannot start monitoring - camera not authorized")
            return
        }
        
        // Connect camera manager to vision processor
        cameraManager.visionProcessor = visionProcessor
        
        // Start monitoring
        stateController.startMonitoring()
        
        DispatchQueue.main.async {
            print("BackgroundMonitoringService: Setting isMonitoring to true")
            self.isMonitoring = true
            self.preferencesManager.isMonitoringEnabled = true
            print("BackgroundMonitoringService: isMonitoring is now: \(self.isMonitoring)")
        }
        
        print("BackgroundMonitoringService: Started monitoring")
    }
    
    /// Stop monitoring
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        // Stop state controller
        stateController.stopMonitoring()
        
        // Hide overlay if showing
        hideOverlay()
        
        // Disconnect camera
        cameraManager.visionProcessor = nil
        
        DispatchQueue.main.async {
            print("BackgroundMonitoringService: Setting isMonitoring to false")
            self.isMonitoring = false
            self.preferencesManager.isMonitoringEnabled = false
            print("BackgroundMonitoringService: isMonitoring is now: \(self.isMonitoring)")
        }
        
        print("BackgroundMonitoringService: Stopped monitoring")
    }
    
    /// Toggle monitoring state
    func toggleMonitoring() {
        DispatchQueue.main.async {
            if self.isMonitoring {
                self.stopMonitoring()
            } else {
                self.startMonitoring()
            }
        }
    }
    
    /// Show camera overlay window
    func showOverlay() {
        guard isMonitoring else { return }
        
        if overlayWindow == nil {
            overlayWindow = CameraOverlayWindow()
        }
        
        overlayWindow?.showWithLiquidExpansion() // Use new liquid expansion method
    }
    
    /// Hide camera overlay window
    func hideOverlay() {
        overlayWindow?.hideWindow()
    }
    
    /// Toggle overlay visibility
    func toggleOverlay() {
        if overlayWindow?.isVisible == true {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor state changes for notifications and overlay
        stateController.$currentState
            .sink { [weak self] state in
                self?.currentState = state
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Monitor face count changes
        visionProcessor.$faceCount
            .sink { [weak self] faceCount in
                self?.faceCount = faceCount
                self?.stateController.updateFaceCount(faceCount)
            }
            .store(in: &cancellables)
        
        // Update status message when state changes
        stateController.$currentState
            .sink { [weak self] state in
                self?.statusMessage = self?.getStatusMessage(for: state) ?? "Ready"
            }
            .store(in: &cancellables)
        
        // Monitor camera authorization changes
        cameraManager.$isAuthorized
            .sink { [weak self] isAuthorized in
                self?.cameraPermissionStatus = isAuthorized ? .authorized : .denied
                
                if isAuthorized && self?.isMonitoring == true {
                    self?.stateController.startMonitoring()
                } else if !isAuthorized {
                    self?.stateController.stopMonitoring()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange(_ state: StateController.SecurityState) {
        // Handle notifications with rate limiting
        if preferencesManager.notificationsEnabled {
            notificationManager.handleStateChange(to: state)
        }
        
        // Handle alert duration tracking for long-term surfing indicator
        handleAlertDurationTracking(for: state)
        
        switch state {
        case .alert:
            // Show overlay when shoulder surfer detected
            showOverlay()
            
        case .safe:
            // Hide overlay when returning to safe state
            hideOverlay()
            
        case .warning:
            // Overlay can stay visible during warning state
            break
            
        case .error:
            // Hide overlay on error
            hideOverlay()
        }
    }
    
    private func handleAlertDurationTracking(for state: StateController.SecurityState) {
        switch state {
        case .alert:
            // Start tracking alert duration if not already tracking
            if alertStartTime == nil {
                alertStartTime = Date()
                startAlertDurationTimer()
                print("BackgroundMonitoringService: Started tracking alert duration")
            }
            
        case .safe, .warning, .error:
            // Stop tracking when no longer in alert state
            if alertStartTime != nil {
                stopAlertDurationTimer()
                alertStartTime = nil
                isLongTermAlert = false
                print("BackgroundMonitoringService: Stopped tracking alert duration")
            }
        }
    }
    
    private func startAlertDurationTimer() {
        stopAlertDurationTimer() // Stop any existing timer
        
        alertDurationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAlertDuration()
        }
    }
    
    private func stopAlertDurationTimer() {
        alertDurationTimer?.invalidate()
        alertDurationTimer = nil
    }
    
    private func checkAlertDuration() {
        guard let startTime = alertStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let oneMinute: TimeInterval = 60.0
        
        if duration >= oneMinute && !isLongTermAlert {
            isLongTermAlert = true
            print("BackgroundMonitoringService: Long-term alert detected - duration: \(Int(duration))s")
        }
    }
    
    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    private func getStatusMessage(for state: StateController.SecurityState) -> String {
        switch state {
        case .safe:
            return "Safe - No shoulder surfers detected"
        case .warning:
            return "Warning - Multiple faces detected"
        case .alert:
            return "Alert - Shoulder surfer detected!"
        case .error:
            return "Error - Camera or processing issue"
        }
    }
    
    // MARK: - Published Properties for UI
    @Published var currentState: StateController.SecurityState = .safe
    @Published var faceCount: Int = 0
    @Published var statusMessage: String = "Ready"
    @Published var isLongTermAlert: Bool = false // New: tracks if alert has been active for >1 minute
    
    // MARK: - Private Properties for Alert Duration Tracking
    private var alertStartTime: Date?
    private var alertDurationTimer: Timer?
    
    // MARK: - Computed Properties
}
