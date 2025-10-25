//
//  SettingsView.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


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
                Section("In-App Notifications") {
                    Toggle("Enable In-Notch Notifications", isOn: $preferencesManager.notificationsEnabled)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notifications appear directly in the Mac notch area (Dynamic Island style).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Note: These are in-app notifications and won't appear in macOS Settings → Notifications. You can also toggle this using the bell icon in the camera island.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.vertical, 2)
                    
                    HStack {
                        Text("Auto-hide Delay")
                        Spacer()
                        Text("\(Int(preferencesManager.overlayAutoHideDelay)) seconds")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $preferencesManager.overlayAutoHideDelay, in: 5...30, step: 5)
                        .help("How long notification popups stay visible before auto-dismissing")
                }
                
                Section("Monitoring") {
                    Toggle("Auto-start Monitoring", isOn: $preferencesManager.autoStartMonitoring)
                    
                    Toggle("Launch at Login", isOn: $preferencesManager.launchAtLogin)
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