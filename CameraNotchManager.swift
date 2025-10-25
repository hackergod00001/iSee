//
//  CameraNotchManager.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import SwiftUI
import Combine
import AppKit

/// Reactive notification toggle button that observes PreferencesManager
struct NotificationToggleButton: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        Button(action: {
            preferencesManager.notificationsEnabled.toggle()
            print("Notifications toggled: \(preferencesManager.notificationsEnabled)")
        }) {
            Image(systemName: preferencesManager.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                .font(.system(size: 18))
                .foregroundColor(preferencesManager.notificationsEnabled ? .yellow : .gray)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 33)  // Extra padding on right side for safe clearance from curve
    }
}

/// Manager for showing camera overlay and notifications in the Mac notch using NotchNotification
class CameraNotchManager {
    static let shared = CameraNotchManager()
    
    // Store current view models for dismiss control
    private var currentOverlayViewModel: NotchViewModel?
    private var currentNotificationViewModel: NotchViewModel?
    
    private init() {
        // Simple singleton, no initialization needed
    }
    
    /// Show camera overlay in the notch (NO control buttons, just camera feed)
    /// - Parameters:
    ///   - cameraManager: The camera manager providing the video feed
    ///   - visionProcessor: The vision processor for face detection
    ///   - onDismiss: Callback when overlay is dismissed
    func showCameraOverlay(
        cameraManager: CameraManager,
        visionProcessor: VisionProcessor,
        onDismiss: @escaping () -> Void
    ) {
        let delay = PreferencesManager.shared.overlayAutoHideDelay
        
        // Create custom header views
        let closeButton = Button(action: {
            self.dismissCurrentOverlay()
            onDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.red)  // Red for close button
        }
        .buttonStyle(.plain)
        .padding(.leading, 12)  // Move icon right to avoid clipping by top-left curve
        
        let rightIcons = HStack(spacing: 0) {  // No spacing between gear and bell icons
            Button(action: {
                // Open settings window
                SettingsWindow.shared.showWindow()
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 10)  // Add spacing between gear and notification icons
            
            // Use reactive notification toggle button
            NotificationToggleButton()
        }
        .padding(.trailing, 12)  // Move icons left to avoid clipping by top-right curve
        
        // Create simple camera view WITHOUT control buttons
        let cameraView = SimpleCameraNotchView(
            cameraManager: cameraManager,
            visionProcessor: visionProcessor
        )
        
        // Present in notch with custom headers
        guard let context = NotificationContext(
            headerLeadingView: closeButton,
            headerTrailingView: rightIcons,
            bodyView: cameraView,
            animated: true
        ) else {
            return
        }
        
        currentOverlayViewModel = context.open(forInterval: delay)
    }
    
    /// Show alert/warning notification with action menu dropdown
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    ///   - isError: Whether this is an error (shows red icon)
    ///   - onPreview: Callback when Preview is selected
    ///   - onAcknowledge: Callback when Acknowledge is selected
    static func showNotificationWithActions(
        title: String,
        message: String,
        isError: Bool = false,
        onPreview: @escaping () -> Void,
        onAcknowledge: @escaping () -> Void
    ) {
        let delay = PreferencesManager.shared.overlayAutoHideDelay
        
        // Dismiss any existing notification first to prevent overlapping
        shared.dismissCurrentNotification()
        
        // Create notification view with dropdown menu and dismiss callback
        let notificationView = NotificationWithActionsView(
            title: title,
            message: message,
            isError: isError,
            onPreview: onPreview,
            onAcknowledge: {
                // Dismiss notification when acknowledged
                shared.dismissCurrentNotification()
                onAcknowledge()
            }
        )
        
        // Wrap icon with padding to prevent clipping by curved corners
        let leadingIcon = Image(systemName: isError ? "exclamationmark.triangle.fill" : "bell.fill")
            .foregroundColor(isError ? .red : .white)
            .padding(.leading, 12)   // Inset from left curve
            .padding(.top, 4)        // Clearance from top curve
        
        guard let context = NotificationContext(
            headerLeadingView: leadingIcon,
            headerTrailingView: EmptyView(),
            bodyView: notificationView,
            animated: true
        ) else {
            return
        }
        
        // Store the notification view model so we can dismiss it
        shared.currentNotificationViewModel = context.open(forInterval: delay)
    }
    
    /// Dismiss the current camera overlay immediately
    func dismissCurrentOverlay() {
        currentOverlayViewModel?.forceClose()
        currentOverlayViewModel = nil
    }
    
    /// Dismiss the current notification immediately
    func dismissCurrentNotification() {
        currentNotificationViewModel?.forceClose()
        currentNotificationViewModel = nil
    }
    
    /// Hide camera overlay (same as dismiss)
    func hideCameraOverlay() {
        dismissCurrentOverlay()
    }
    
    /// Show a simple notification message in the notch (no actions)
    static func showNotification(message: String, interval: TimeInterval? = nil) {
        let delay = interval ?? PreferencesManager.shared.overlayAutoHideDelay
        NotchNotification.present(message: message, interval: delay)
    }
    
    /// Show an error notification in the notch (no actions)
    static func showError(_ message: String, interval: TimeInterval? = nil) {
        let delay = interval ?? PreferencesManager.shared.overlayAutoHideDelay
        NotchNotification.present(error: message, interval: delay)
    }
}

// MARK: - Simple Camera Notch View (No Control Buttons)

struct SimpleCameraNotchView: View {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera feed with face detection overlay (433x260 - 5:3 ratio)
            ZStack {
                CameraPreviewView(
                    cameraManager: cameraManager,
                    visionProcessor: visionProcessor
                )
                .frame(width: 433, height: 260)
                .onAppear {
                    // Ensure camera session is running when view appears
                    cameraManager.startSession()
                    
                    // Force preview layer frame update after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let connection = cameraManager.previewLayer.connection {
                            // Reconfigure connection when view appears
                            if connection.isVideoMirroringSupported {
                                connection.isVideoMirrored = true
                            }
                        }
                    }
                }
                
                FaceDetectionOverlayView(visionProcessor: visionProcessor)
                    .frame(width: 433, height: 260)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 5)  // 5px on each side
        .padding(.vertical, 10)   // 10px top and bottom
        .frame(width: 443)         // Total width: 5 + 433 + 5 = 443px
        // Total height: 10 (top) + 260 (camera) + 10 (bottom) = 280px
    }
}

// MARK: - Notification View with Actions Dropdown

struct NotificationWithActionsView: View {
    let title: String
    let message: String
    let isError: Bool
    let onPreview: () -> Void
    let onAcknowledge: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Notification content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Dropdown menu button
            Menu {
                Button("👁️ Preview") {
                    onPreview()
                }
                
                Button("✓ Acknowledge") {
                    onAcknowledge()
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 12)  // Horizontal padding for content
        .padding(.vertical, 12)    // Vertical padding for content
        .frame(width: 443)         // Match camera island total width
    }
}

// Note: CameraPreviewView, FaceDetectionOverlayView, and FaceBoundingBoxView
// are already defined in CameraOverlayView.swift and reused here.
