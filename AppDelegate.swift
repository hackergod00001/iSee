//
//  AppDelegate.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import AppKit
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("iSee: AppDelegate.applicationDidFinishLaunching called")
        
        // Hide from dock - app will only show in menu bar
        NSApp.setActivationPolicy(.accessory)
        print("iSee: Set activation policy to accessory")
        
        // Initialize preferences manager
        let preferencesManager = PreferencesManager.shared
        print("iSee: PreferencesManager initialized")
        
        // Request notification permissions
        NotificationManager.shared.requestPermission()
        print("iSee: Requested notification permissions")
        
        // Auto-start monitoring if enabled
        if preferencesManager.autoStartMonitoring {
            // Check camera permission first
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if cameraStatus == .authorized {
                BackgroundMonitoringService.shared.startMonitoring()
                print("iSee: Auto-started monitoring (camera authorized)")
            } else if cameraStatus == .notDetermined {
                // Request camera permission
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted && preferencesManager.autoStartMonitoring {
                            BackgroundMonitoringService.shared.startMonitoring()
                            print("iSee: Auto-started monitoring after camera permission granted")
                        }
                    }
                }
            } else {
                print("iSee: Cannot auto-start monitoring - camera not authorized")
            }
        } else {
            // Restore last monitoring state if auto-start is disabled
            if preferencesManager.isMonitoringEnabled {
                BackgroundMonitoringService.shared.startMonitoring()
                print("iSee: Monitoring started from saved state")
            }
        }
        
        print("iSee: App launched in background mode - menu bar icon should appear")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Stop monitoring and save state
        BackgroundMonitoringService.shared.stopMonitoring()
        print("iSee: App terminating")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Prevent app from showing windows when clicked in dock (since we're hiding from dock)
        return false
    }
}
