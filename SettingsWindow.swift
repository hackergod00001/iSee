import SwiftUI
import AppKit

/// Manages the settings window
class SettingsWindow: ObservableObject {
    static let shared = SettingsWindow()
    
    private var window: NSWindow?
    private var windowDelegate: WindowDelegate?
    
    private init() {}
    
    func showWindow() {
        if window == nil {
            createWindow()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideWindow() {
        window?.orderOut(nil)
    }
    
    private func createWindow() {
        let contentView = SettingsView()
        let hostingView = NSHostingView(rootView: contentView)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        guard let window = window else { return }
        
        window.contentView = hostingView
        window.title = "iSee Settings"
        window.center()
        window.setFrameAutosaveName("iSeeSettingsWindow")
        
        // Set window delegate
        windowDelegate = WindowDelegate()
        window.delegate = windowDelegate
    }
}

// MARK: - Window Delegate

private class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Window is closing, no special action needed
    }
}
