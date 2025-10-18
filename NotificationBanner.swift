import SwiftUI

/// NotificationBanner displays security alerts with smooth animations
/// Provides non-intrusive notifications for shoulder surfer detection
struct NotificationBanner: View {
    @ObservedObject var stateController: StateController
    @State private var isVisible = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack {
            if shouldShowBanner {
                bannerContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
            }
            
            Spacer()
        }
        .onChange(of: shouldShowBanner) { shouldShow in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = shouldShow
            }
        }
        .onAppear {
            isVisible = shouldShowBanner
        }
    }
    
    // MARK: - Computed Properties
    
    private var shouldShowBanner: Bool {
        return stateController.isInWarningState || stateController.isInAlertState
    }
    
    private var bannerContent: some View {
        HStack(spacing: 12) {
            // Alert icon
            alertIcon
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
            
            VStack(alignment: .leading, spacing: 4) {
                // Alert title
                Text(alertTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Alert message
                Text(alertMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                // Progress bar for warning state
                if stateController.isInWarningState {
                    progressBar
                }
            }
            
            Spacer()
            
            // Dismiss button (only for alert state)
            if stateController.isInAlertState {
                Button(action: {
                    stateController.resetToSafe()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(alertBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .onAppear {
            if stateController.isInAlertState {
                pulseAnimation = true
            }
        }
        .onChange(of: stateController.isInAlertState) { isAlert in
            pulseAnimation = isAlert
        }
    }
    
    private var alertIcon: some View {
        Group {
            if stateController.isInAlertState {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            } else if stateController.isInWarningState {
                Image(systemName: "eye.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var alertTitle: String {
        if stateController.isInAlertState {
            return "SHOULDER SURFER DETECTED!"
        } else if stateController.isInWarningState {
            return "Multiple People Detected"
        }
        return ""
    }
    
    private var alertMessage: String {
        if stateController.isInAlertState {
            return "Someone else is looking at your screen. Protect your privacy!"
        } else if stateController.isInWarningState {
            let timeRemaining = String(format: "%.1f", stateController.timeUntilAlert)
            return "Alert in \(timeRemaining)s if multiple people remain visible"
        }
        return ""
    }
    
    private var alertBackground: some View {
        Group {
            if stateController.isInAlertState {
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else if stateController.isInWarningState {
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Progress
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * stateController.alertProgress, height: 4)
                    .cornerRadius(2)
                    .animation(.linear(duration: 0.1), value: stateController.alertProgress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Notification Banner Extensions
extension NotificationBanner {
    
    /// Create a compact notification for subtle alerts
    static func compact(stateController: StateController) -> some View {
        HStack {
            Image(systemName: stateController.isInAlertState ? "exclamationmark.triangle.fill" : "eye.fill")
                .foregroundColor(.white)
            
            Text(stateController.isInAlertState ? "Shoulder Surfer!" : "Multiple People")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(stateController.isInAlertState ? Color.red : Color.orange)
        )
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview
struct NotificationBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Warning state preview
            NotificationBanner(stateController: {
                let controller = StateController()
                controller.updateFaceCount(2)
                return controller
            }())
            
            Spacer()
            
            // Alert state preview
            NotificationBanner(stateController: {
                let controller = StateController()
                controller.updateFaceCount(2)
                // Simulate alert state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    controller.updateFaceCount(2)
                }
                return controller
            }())
        }
        .background(Color.black)
    }
}

