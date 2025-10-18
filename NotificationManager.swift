import Foundation
import UserNotifications

/// Manages system notifications for shoulder surfer alerts
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private let center = UNUserNotificationCenter.current()
    
    // Rate limiting properties
    private var lastNotificationTime: Date = Date.distantPast
    private let notificationCooldown: TimeInterval = 5.0 // 5 seconds for testing
    private var lastNotificationState: StateController.SecurityState?
    
    override init() {
        super.init()
        center.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Request notification permission from the user
    func requestPermission() {
        print("NotificationManager: Requesting notification permission...")
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if let error = error {
                    print("NotificationManager: Permission request failed: \(error)")
                } else {
                    print("NotificationManager: Permission granted: \(granted)")
                    if granted {
                        print("NotificationManager: Notifications are now enabled")
                    } else {
                        print("NotificationManager: User denied notification permission")
                    }
                }
            }
        }
    }
    
    /// Show shoulder surfer alert notification
    func showShoulderSurferAlert() {
        guard isAuthorized else {
            print("NotificationManager: Cannot show notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 Shoulder Surfer Detected!"
        content.body = "Someone is looking at your screen. Consider covering sensitive information or moving to a private location."
        content.sound = .default
        content.categoryIdentifier = "SHOULDER_SURFER_ALERT"
        
        // Add action buttons
        let showFeedAction = UNNotificationAction(
            identifier: "SHOW_FEED",
            title: "👁️ View Camera Feed",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "✓ Acknowledged",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "SHOULDER_SURFER_ALERT",
            actions: [showFeedAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([category])
        
        let request = UNNotificationRequest(
            identifier: "shoulder-surfer-alert",
            content: content,
            trigger: nil // Show immediately
        )
        
        center.add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to show notification: \(error)")
            } else {
                print("NotificationManager: Shoulder surfer alert notification sent")
            }
        }
    }
    
    /// Show warning notification for multiple faces detected
    func showWarningNotification() {
        guard isAuthorized else {
            print("NotificationManager: Cannot show notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Multiple People Detected"
        content.body = "More than one person is visible. Be cautious with sensitive information on your screen."
        content.sound = .default
        content.categoryIdentifier = "WARNING_ALERT"
        
        // Add action buttons
        let showFeedAction = UNNotificationAction(
            identifier: "SHOW_FEED",
            title: "👁️ View Camera Feed",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "✓ Acknowledged",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "WARNING_ALERT",
            actions: [showFeedAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([category])
        
        let request = UNNotificationRequest(
            identifier: "warning-alert",
            content: content,
            trigger: nil // Show immediately
        )
        
        center.add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to show warning notification: \(error)")
            } else {
                print("NotificationManager: Warning notification sent")
            }
        }
    }
    
    /// Show camera permission notification
    func showCameraPermissionAlert() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Camera Permission Required"
        content.body = "iSee needs camera access to detect shoulder surfers. Please enable camera permission in System Preferences."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "camera-permission-alert",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to show camera permission notification: \(error)")
            }
        }
    }
    
    /// Show welcome notification on first launch
    func showWelcomeNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Welcome to iSee!"
        content.body = "Your privacy protection is now active. Click the menu bar icon to start monitoring."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "welcome-notification",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to show welcome notification: \(error)")
            }
        }
    }
    
    /// Handle state changes with rate limiting
    func handleStateChange(to newState: StateController.SecurityState) {
        print("NotificationManager: State changed to \(newState)")
        print("NotificationManager: isAuthorized = \(isAuthorized)")
        
        guard isAuthorized else { 
            print("NotificationManager: Cannot send notification - not authorized")
            return 
        }
        
        // Check if we should send a notification
        let now = Date()
        let timeSinceLastNotification = now.timeIntervalSince(lastNotificationTime)
        
        print("NotificationManager: Time since last notification: \(timeSinceLastNotification)s")
        print("NotificationManager: Last notification state: \(String(describing: lastNotificationState))")
        
        // Only send notification if:
        // 1. Enough time has passed since last notification (rate limiting)
        // 2. State has actually changed
        // 3. State is warning or alert (not safe or error)
        let shouldSendNotification = timeSinceLastNotification >= notificationCooldown &&
                                   lastNotificationState != newState &&
                                   (newState == .warning || newState == .alert)
        
        print("NotificationManager: Should send notification: \(shouldSendNotification)")
        
        if shouldSendNotification {
            lastNotificationTime = now
            lastNotificationState = newState
            
            switch newState {
            case .warning:
                print("NotificationManager: Sending warning notification")
                showWarningNotification()
            case .alert:
                print("NotificationManager: Sending alert notification")
                showShoulderSurferAlert()
            case .safe, .error:
                // Don't send notifications for safe or error states
                print("NotificationManager: Not sending notification for \(newState) state")
                break
            }
        } else {
            print("NotificationManager: Skipping notification due to rate limiting or state conditions")
        }
    }
    
    /// Test notification method for debugging
    func sendTestNotification() {
        guard isAuthorized else {
            print("NotificationManager: Cannot send test notification - not authorized")
            print("NotificationManager: Current authorization status: \(isAuthorized)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "iSee Test Notification"
        content.body = "This is a test notification to verify the system is working"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to send test notification: \(error)")
            } else {
                print("NotificationManager: Test notification sent successfully")
            }
        }
    }
    
    /// Force request permissions again (for debugging)
    func forceRequestPermissions() {
        print("NotificationManager: Force requesting permissions...")
        requestPermission()
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
                print("NotificationManager: Current authorization status: \(settings.authorizationStatus.rawValue)")
                print("NotificationManager: isAuthorized set to: \(self?.isAuthorized ?? false)")
                
                switch settings.authorizationStatus {
                case .authorized:
                    print("NotificationManager: ✅ Notifications are authorized")
                case .denied:
                    print("NotificationManager: ❌ Notifications are denied")
                case .notDetermined:
                    print("NotificationManager: ⚠️ Notification permission not determined")
                case .provisional:
                    print("NotificationManager: ⚠️ Notifications are provisional")
                case .ephemeral:
                    print("NotificationManager: ⚠️ Notifications are ephemeral")
                @unknown default:
                    print("NotificationManager: ❓ Unknown authorization status")
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "SHOW_FEED":
            // Show camera overlay
            DispatchQueue.main.async {
                BackgroundMonitoringService.shared.showOverlay()
            }
            
        case "DISMISS":
            // Just dismiss the notification
            break
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            DispatchQueue.main.async {
                BackgroundMonitoringService.shared.showOverlay()
            }
            
        default:
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        print("NotificationManager: Will present notification: \(notification.request.content.title)")
        completionHandler([.banner, .sound, .badge])
    }
}
