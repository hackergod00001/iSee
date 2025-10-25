//
//  PreferencesManager.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import Foundation
import AppKit

/// Manages app preferences and state persistence
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let isMonitoringEnabled = "isMonitoringEnabled"
        static let launchAtLogin = "launchAtLogin"
        static let autoStartMonitoring = "autoStartMonitoring"
        static let overlayPosition = "overlayPosition"
        static let showWelcomeScreen = "showWelcomeScreen"
        static let notificationsEnabled = "notificationsEnabled"
        static let overlayAutoHideDelay = "overlayAutoHideDelay"
        static let alertThreshold = "alertThreshold"
    }
    
    // MARK: - Published Properties
    @Published var isMonitoringEnabled: Bool {
        didSet {
            userDefaults.set(isMonitoringEnabled, forKey: Keys.isMonitoringEnabled)
        }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            userDefaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }
    
    @Published var autoStartMonitoring: Bool {
        didSet {
            userDefaults.set(autoStartMonitoring, forKey: Keys.autoStartMonitoring)
        }
    }
    
    @Published var overlayPosition: CGPoint {
        didSet {
            let value = NSValue(point: overlayPosition)
            let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
            userDefaults.set(data, forKey: Keys.overlayPosition)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            userDefaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published var overlayAutoHideDelay: TimeInterval {
        didSet {
            userDefaults.set(overlayAutoHideDelay, forKey: Keys.overlayAutoHideDelay)
        }
    }
    
    @Published var alertThreshold: TimeInterval {
        didSet {
            userDefaults.set(alertThreshold, forKey: Keys.alertThreshold)
        }
    }
    
    var showWelcomeScreen: Bool {
        get {
            return userDefaults.bool(forKey: Keys.showWelcomeScreen)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.showWelcomeScreen)
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Load saved preferences or use defaults
        self.isMonitoringEnabled = userDefaults.object(forKey: Keys.isMonitoringEnabled) as? Bool ?? false
        self.launchAtLogin = userDefaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        self.autoStartMonitoring = userDefaults.object(forKey: Keys.autoStartMonitoring) as? Bool ?? true
        self.notificationsEnabled = userDefaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.overlayAutoHideDelay = userDefaults.object(forKey: Keys.overlayAutoHideDelay) as? TimeInterval ?? 10.0
        self.alertThreshold = userDefaults.object(forKey: Keys.alertThreshold) as? TimeInterval ?? 2.0
        
        // Load overlay position
        if let data = userDefaults.data(forKey: Keys.overlayPosition),
           let position = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data) as? NSValue {
            self.overlayPosition = position.pointValue
        } else {
            // Default position: top-center of screen
            self.overlayPosition = CGPoint(x: 0, y: 0) // Will be set to actual screen position later
        }
    }
    
    // MARK: - Public Methods
    
    /// Reset all preferences to defaults
    func resetToDefaults() {
        isMonitoringEnabled = false
        launchAtLogin = false
        notificationsEnabled = true
        overlayAutoHideDelay = 10.0
        alertThreshold = 2.0
        overlayPosition = CGPoint(x: 0, y: 0)
        showWelcomeScreen = true
    }
    
    /// Save current overlay position
    func saveOverlayPosition(_ position: CGPoint) {
        overlayPosition = position
    }
    
    /// Get default overlay position (top-center of main screen)
    func getDefaultOverlayPosition() -> CGPoint {
        guard let screen = NSScreen.main else {
            return CGPoint(x: 100, y: 100)
        }
        
        let screenFrame = screen.frame
        let overlayWidth: CGFloat = 200
        let overlayHeight: CGFloat = 150
        
        // Position near the notch area (top-center)
        let x = screenFrame.midX - overlayWidth / 2
        let y = screenFrame.maxY - overlayHeight - 50 // 50 points below menu bar
        
        return CGPoint(x: x, y: y)
    }
}
