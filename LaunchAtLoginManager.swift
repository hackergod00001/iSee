import Foundation
import ServiceManagement

/// Manages launch at login functionality using SMAppService
class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()
    
    @Published var isEnabled: Bool {
        didSet {
            updateLaunchAtLogin()
        }
    }
    
    private let preferencesManager = PreferencesManager.shared
    
    private init() {
        // Load saved preference
        self.isEnabled = preferencesManager.launchAtLogin
        
        // Sync with actual system state
        syncWithSystemState()
    }
    
    // MARK: - Public Methods
    
    /// Enable launch at login
    func enable() {
        isEnabled = true
    }
    
    /// Disable launch at login
    func disable() {
        isEnabled = false
    }
    
    /// Toggle launch at login
    func toggle() {
        isEnabled.toggle()
    }
    
    /// Check if app is currently set to launch at login
    func isCurrentlyEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
    
    // MARK: - Private Methods
    
    private func updateLaunchAtLogin() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
                print("LaunchAtLoginManager: Successfully enabled launch at login")
            } else {
                try SMAppService.mainApp.unregister()
                print("LaunchAtLoginManager: Successfully disabled launch at login")
            }
            
            // Save preference
            preferencesManager.launchAtLogin = isEnabled
            
        } catch {
            print("LaunchAtLoginManager: Failed to update launch at login: \(error)")
            
            // Revert the change on failure
            DispatchQueue.main.async {
                self.isEnabled = !self.isEnabled
            }
        }
    }
    
    private func syncWithSystemState() {
        let systemState = isCurrentlyEnabled()
        
        if systemState != isEnabled {
            DispatchQueue.main.async {
                self.isEnabled = systemState
                self.preferencesManager.launchAtLogin = systemState
            }
        }
    }
}

// MARK: - SMAppService Extension

extension SMAppService {
    static var mainApp: SMAppService {
        return SMAppService()
    }
}
