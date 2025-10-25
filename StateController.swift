//
//  StateController.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import Foundation
import Combine

/// StateController manages the security state based on face detection results
/// Implements the core "shoulder surfer" detection logic with timer-based alerts
class StateController: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentState: SecurityState = .safe
    @Published var alertLevel: AlertLevel = .none
    @Published var timeInCurrentState: TimeInterval = 0
    @Published var isMonitoring = false
    
    // MARK: - Private Properties
    private var faceCountTimer: Timer?
    private var stateTimer: Timer?
    private let alertThreshold: TimeInterval = 2.0 // 2 seconds before alert
    private let stateUpdateInterval: TimeInterval = 0.1 // Update every 100ms
    
    // Edge case handling
    private var consecutiveZeroFaceCount = 0
    private let maxConsecutiveZeroFaces = 10 // Reset after 10 consecutive zero face detections
    private var lastValidFaceCount = 1 // Assume user is present initially
    
    // MARK: - Security State Enum
    enum SecurityState {
        case safe           // 1 face detected (normal state)
        case warning        // 2+ faces detected, but not yet alert threshold
        case alert          // 2+ faces detected for sustained period
        case error          // Camera or processing error
        
        var description: String {
            switch self {
            case .safe:
                return "Safe - You're alone"
            case .warning:
                return "Warning - Multiple faces detected"
            case .alert:
                return "ALERT - Shoulder surfer detected!"
            case .error:
                return "Error - Camera issue"
            }
        }
        
        var color: String {
            switch self {
            case .safe:
                return "green"
            case .warning:
                return "orange"
            case .alert:
                return "red"
            case .error:
                return "gray"
            }
        }
    }
    
    // MARK: - Alert Level Enum
    enum AlertLevel {
        case none
        case low
        case medium
        case high
        
        var description: String {
            switch self {
            case .none:
                return ""
            case .low:
                return "Someone nearby"
            case .medium:
                return "Multiple people detected"
            case .high:
                return "SHOULDER SURFER ALERT!"
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        startStateTimer()
    }
    
    deinit {
        stopAllTimers()
    }
    
    // MARK: - Public Methods
    
    /// Update face count and trigger state logic
    /// - Parameter faceCount: Number of faces detected in current frame
    func updateFaceCount(_ faceCount: Int) {
        guard isMonitoring else { return }
        
        // Handle edge case: temporary zero face detection
        if faceCount == 0 {
            consecutiveZeroFaceCount += 1
            if consecutiveZeroFaceCount < maxConsecutiveZeroFaces {
                // Use last valid face count to avoid false state changes
                processFaceCount(lastValidFaceCount)
                return
            } else {
                // Too many consecutive zeros - likely camera issue
                updateState(.error)
                return
            }
        } else {
            // Reset consecutive zero counter
            consecutiveZeroFaceCount = 0
            lastValidFaceCount = faceCount
        }
        
        processFaceCount(faceCount)
    }
    
    private func processFaceCount(_ faceCount: Int) {
        switch faceCount {
        case 0:
            // No faces detected - could be camera error or user moved away
            updateState(.error)
            
        case 1:
            // Normal state - user is alone
            updateState(.safe)
            
        case 2...:
            // Multiple faces detected - potential shoulder surfer
            handleMultipleFaces()
            
        default:
            break
        }
    }
    
    /// Start monitoring for shoulder surfers
    func startMonitoring() {
        isMonitoring = true
        print("StateController: Started monitoring for shoulder surfers")
    }
    
    /// Stop monitoring
    func stopMonitoring() {
        isMonitoring = false
        stopAllTimers()
        updateState(.safe)
        print("StateController: Stopped monitoring")
    }
    
    /// Reset to safe state
    func resetToSafe() {
        stopAllTimers()
        updateState(.safe)
        alertLevel = .none
        timeInCurrentState = 0
    }
    
    // MARK: - Private Methods
    
    private func updateState(_ newState: SecurityState) {
        guard newState != currentState else { return }
        
        let previousState = currentState
        currentState = newState
        timeInCurrentState = 0
        
        // Update alert level based on state
        updateAlertLevel(for: newState)
        
        // Log state change
        print("StateController: State changed from \(previousState.description) to \(newState.description)")
        
        // Handle state-specific actions
        handleStateChange(from: previousState, to: newState)
    }
    
    private func handleMultipleFaces() {
        switch currentState {
        case .safe:
            // Transition to warning state
            updateState(.warning)
            startFaceCountTimer()
            
        case .warning:
            // Continue in warning state, timer should be running
            break
            
        case .alert:
            // Already in alert state, maintain it
            break
            
        case .error:
            // Transition from error to warning
            updateState(.warning)
            startFaceCountTimer()
        }
    }
    
    private func startFaceCountTimer() {
        stopFaceCountTimer()
        
        faceCountTimer = Timer.scheduledTimer(withTimeInterval: alertThreshold, repeats: false) { [weak self] _ in
            self?.handleAlertThresholdReached()
        }
        
        print("StateController: Started alert timer (\(alertThreshold)s)")
    }
    
    private func stopFaceCountTimer() {
        faceCountTimer?.invalidate()
        faceCountTimer = nil
    }
    
    private func handleAlertThresholdReached() {
        // Check if we're still in warning state (multiple faces still detected)
        if currentState == .warning {
            updateState(.alert)
            print("StateController: Alert threshold reached - triggering shoulder surfer alert!")
        }
    }
    
    private func startStateTimer() {
        stateTimer = Timer.scheduledTimer(withTimeInterval: stateUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateTimeInCurrentState()
        }
    }
    
    private func stopStateTimer() {
        stateTimer?.invalidate()
        stateTimer = nil
    }
    
    private func stopAllTimers() {
        stopFaceCountTimer()
        stopStateTimer()
    }
    
    private func updateTimeInCurrentState() {
        timeInCurrentState += stateUpdateInterval
    }
    
    private func updateAlertLevel(for state: SecurityState) {
        switch state {
        case .safe:
            alertLevel = .none
        case .warning:
            alertLevel = .low
        case .alert:
            alertLevel = .high
        case .error:
            alertLevel = .none
        }
    }
    
    private func handleStateChange(from previousState: SecurityState, to newState: SecurityState) {
        switch (previousState, newState) {
        case (.warning, .safe), (.alert, .safe):
            // Returning to safe state - stop any timers
            stopFaceCountTimer()
            
        case (.safe, .warning), (.error, .warning):
            // Entering warning state - start alert timer
            startFaceCountTimer()
            
        case (.warning, .alert):
            // Escalating to alert state
            stopFaceCountTimer()
            
        default:
            break
        }
    }
}

// MARK: - StateController Extensions
extension StateController {
    
    /// Get the current security status as a user-friendly message
    var statusMessage: String {
        return currentState.description
    }
    
    /// Check if currently in an alert state
    var isInAlertState: Bool {
        return currentState == .alert
    }
    
    /// Check if currently in warning state
    var isInWarningState: Bool {
        return currentState == .warning
    }
    
    /// Get time remaining until alert (if in warning state)
    var timeUntilAlert: TimeInterval {
        guard currentState == .warning else { return 0 }
        return max(0, alertThreshold - timeInCurrentState)
    }
    
    /// Get progress towards alert threshold (0.0 to 1.0)
    var alertProgress: Double {
        guard currentState == .warning else { return 0 }
        return min(1.0, timeInCurrentState / alertThreshold)
    }
}
