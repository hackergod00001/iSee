import SwiftUI
import AppKit

/// Manages the floating camera overlay window
class CameraOverlayWindow: ObservableObject {
    private var window: NSWindow?
    private var windowDelegate: WindowDelegate? // Store delegate to prevent deallocation
    private let preferencesManager = PreferencesManager.shared
    private var autoHideTimer: Timer?
    
    var isVisible: Bool {
        return window?.isVisible == true
    }
    
    // MARK: - Public Methods
    
    func showWindow() {
        if window == nil {
            createWindow()
        }
        
        // Position window
        positionWindow()
        
        // Show window
        window?.makeKeyAndOrderFront(nil)
        
        // Start auto-hide timer
        startAutoHideTimer()
        
        print("CameraOverlayWindow: Showing overlay window")
    }
    
    func hideWindow() {
        window?.orderOut(nil)
        stopAutoHideTimer()
        print("CameraOverlayWindow: Hiding overlay window")
    }
    
    func toggleWindow() {
        if isVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    // MARK: - Private Methods
    
    private func createWindow() {
        let contentView = CameraOverlayView()
        let hostingView = NSHostingView(rootView: contentView)
        
        // Dynamic Island style: full expanded size but initially hidden
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 220), // Full expanded size
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        guard let window = window else { return }
        
        // Configure window properties for Dynamic Island effect
        window.contentView = hostingView
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = true
        window.ignoresMouseEvents = false
        window.alphaValue = 0 // Start invisible
        
        // Make window draggable
        window.isMovable = true
        
        // Set up window delegate for position tracking
        windowDelegate = WindowDelegate(overlayWindow: self)
        window.delegate = windowDelegate
    }
    
    private func positionWindow() {
        guard let window = window else { return }
        
        // Get saved position or use default Dynamic Island position
        let savedPosition = preferencesManager.overlayPosition
        let defaultPosition = getDynamicIslandPosition()
        
        let position = (savedPosition == CGPoint.zero) ? defaultPosition : savedPosition
        
        // Ensure window is on screen
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        var finalPosition = position
        
        // Clamp to screen bounds
        finalPosition.x = max(screenFrame.minX, min(finalPosition.x, screenFrame.maxX - window.frame.width))
        finalPosition.y = max(screenFrame.minY, min(finalPosition.y, screenFrame.maxY - window.frame.height))
        
        window.setFrameOrigin(finalPosition)
    }
    
    private func getDynamicIslandPosition() -> CGPoint {
        guard let screen = NSScreen.main else { return CGPoint.zero }
        
        let screenWidth = screen.visibleFrame.width
        let windowWidth: CGFloat = 340
        let windowHeight: CGFloat = 220
        
        // Position at top-center, very close to top edge (near camera)
        let centerX = screenWidth / 2 - windowWidth / 2
        let topY = screen.visibleFrame.maxY - windowHeight - 10 // 10pt from very top
        
        return CGPoint(x: centerX, y: topY)
    }
    
    private func startAutoHideTimer() {
        stopAutoHideTimer()
        
        // 10-second auto-hide for Dynamic Island
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.collapseAndHide()
        }
    }
    
    func stopAutoHideTimer() {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
    }
    
    func saveCurrentPosition() {
        guard let window = window else { return }
        preferencesManager.saveOverlayPosition(window.frame.origin)
    }
    
    // MARK: - Liquid Expansion Animation
    
    func showWithLiquidExpansion() {
        if window == nil {
            createWindow()
        }
        
        guard let window = window else { return }
        
        // Position window at top-center
        positionWindow()
        
        // Start invisible and small
        window.alphaValue = 0
        let expandedOrigin = getExpandedOrigin()
        window.setFrame(NSRect(origin: expandedOrigin, size: CGSize(width: 20, height: 20)), display: false)
        window.makeKeyAndOrderFront(nil)
        
        // Animate expansion
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.7
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.34, 1.56, 0.64, 1)
            window.animator().alphaValue = 1.0
            window.animator().setFrame(NSRect(origin: expandedOrigin, size: CGSize(width: 340, height: 220)), display: true)
        })
        
        startAutoHideTimer()
        print("CameraOverlayWindow: Showing overlay with liquid expansion")
    }
    
    private func getExpandedOrigin() -> CGPoint {
        guard let screen = NSScreen.main else { return CGPoint.zero }
        
        let screenWidth = screen.visibleFrame.width
        let windowWidth: CGFloat = 340
        let windowHeight: CGFloat = 220
        
        // Calculate position to keep window centered during expansion
        let centerX = screenWidth / 2 - windowWidth / 2
        let topY = screen.visibleFrame.maxY - windowHeight - 10
        
        return CGPoint(x: centerX, y: topY)
    }
    
    private func collapseAndHide() {
        guard let window = window else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
            window.animator().setFrame(
                NSRect(origin: window.frame.origin, size: CGSize(width: 20, height: 20)),
                display: true
            )
        }, completionHandler: {
            window.orderOut(nil)
        })
        
        stopAutoHideTimer()
        print("CameraOverlayWindow: Collapsed and hidden overlay")
    }
}

// MARK: - Window Delegate

private class WindowDelegate: NSObject, NSWindowDelegate {
    private weak var overlayWindow: CameraOverlayWindow?
    
    init(overlayWindow: CameraOverlayWindow) {
        self.overlayWindow = overlayWindow
    }
    
    func windowDidMove(_ notification: Notification) {
        overlayWindow?.saveCurrentPosition()
    }
    
    func windowWillClose(_ notification: Notification) {
        overlayWindow?.stopAutoHideTimer()
    }
}
