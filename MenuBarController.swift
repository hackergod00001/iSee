import SwiftUI
import AppKit
import Combine

/// Controller for the menu bar interface
class MenuBarController: ObservableObject {
    
    // MARK: - Published Properties
    @Published var menuBarIcon: String = "eye"
    @Published var iconColor: Color = .gray
    @Published var isAlertState: Bool = false
    
    // MARK: - Private Properties
    private let backgroundService = BackgroundMonitoringService.shared
    private let preferencesManager = PreferencesManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor state changes to update menu bar icon
        backgroundService.$currentState
            .sink { [weak self] state in
                self?.updateMenuBarIcon(for: state)
            }
            .store(in: &cancellables)
        
        // Monitor long-term alert state for persistent red icon
        backgroundService.$isLongTermAlert
            .sink { [weak self] isLongTerm in
                self?.updateMenuBarIconForLongTermAlert(isLongTerm)
            }
            .store(in: &cancellables)
        
        // Monitor monitoring state
        backgroundService.$isMonitoring
            .sink { [weak self] isMonitoring in
                self?.updateMenuBarIconForMonitoring(isMonitoring)
            }
            .store(in: &cancellables)
    }
    
    private func updateMenuBarIcon(for state: StateController.SecurityState) {
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
            // Use different icon based on whether it's a long-term alert
            if backgroundService.isLongTermAlert {
                menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
                iconColor = .red
                isAlertState = true
            } else {
                menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
                iconColor = .orange
                isAlertState = true
            }
            
        case .error:
            menuBarIcon = "eye.slash.fill"
            iconColor = .red
            isAlertState = false
        }
    }
    
    private func updateMenuBarIconForLongTermAlert(_ isLongTerm: Bool) {
        // Only update if we're currently in alert state
        if backgroundService.currentState == .alert {
            if isLongTerm {
                menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
                iconColor = .red
                isAlertState = true
                print("MenuBarController: Updated to long-term alert (red icon)")
            } else {
                menuBarIcon = "eye.trianglebadge.exclamationmark.fill"
                iconColor = .orange
                isAlertState = true
                print("MenuBarController: Updated to short-term alert (orange icon)")
            }
        }
    }
    
    private func updateMenuBarIconForMonitoring(_ isMonitoring: Bool) {
        if !isMonitoring {
            menuBarIcon = "eye.slash.fill"
            iconColor = .gray
            isAlertState = false
        }
    }
    
    // MARK: - Public Methods
    
    func toggleMonitoring() {
        backgroundService.toggleMonitoring()
    }
    
    func showOverlay() {
        backgroundService.showOverlay()
    }
    
    func hideOverlay() {
        backgroundService.hideOverlay()
    }
    
    func toggleOverlay() {
        backgroundService.toggleOverlay()
    }
    
    func openSettings() {
        SettingsWindow.shared.showWindow()
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
