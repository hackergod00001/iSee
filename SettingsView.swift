import SwiftUI

struct SettingsView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var backgroundService = BackgroundMonitoringService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("iSee Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $preferencesManager.notificationsEnabled)
                        .disabled(!notificationManager.isAuthorized)
                    
                    if !notificationManager.isAuthorized {
                        Button("Request Permissions") {
                            notificationManager.forceRequestPermissions()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                
                Section("Monitoring") {
                    Toggle("Auto-start Monitoring", isOn: $preferencesManager.autoStartMonitoring)
                    
                    Toggle("Launch at Login", isOn: $preferencesManager.launchAtLogin)
                }
                
                Section("Overlay") {
                    HStack {
                        Text("Auto-hide Delay")
                        Spacer()
                        Text("\(Int(preferencesManager.overlayAutoHideDelay)) seconds")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $preferencesManager.overlayAutoHideDelay, in: 5...30, step: 5)
                }
                
                        Section("Detection") {
                            HStack {
                                Text("Alert Cooldown Period")
                                Spacer()
                                Text("\(Int(preferencesManager.alertThreshold)) seconds")
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: $preferencesManager.alertThreshold, in: 1...10, step: 1)
                        }
            }
            .formStyle(.grouped)
            
            Spacer()
        }
        .padding()
        .frame(width: 450, height: 500)
    }
}

#Preview {
    SettingsView()
}