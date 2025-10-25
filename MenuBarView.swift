//
//  MenuBarView.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import SwiftUI

/// SwiftUI view for the menu bar dropdown
struct MenuBarView: View {
    @ObservedObject var controller: MenuBarController
    @ObservedObject var backgroundService = BackgroundMonitoringService.shared
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                    // Header - Clean with icon
                    HStack(alignment: .center, spacing: 4) {
                        Text("iSee")
                            .font(.system(size: 12, weight: .semibold))
                        
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 2)
            
            Divider()
            
            // Monitoring toggle
            Button(action: {
                print("MenuBarView: Toggle button clicked, current state: \(backgroundService.isMonitoring)")
                controller.toggleMonitoring()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: backgroundService.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundColor(backgroundService.isMonitoring ? Color.orange : Color.blue)
                        .font(.system(size: 12))
                    
                    Text(backgroundService.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                        .foregroundColor(.primary)
                        .font(.system(size: 12))
                    
                    Spacer()
                }
            }
            .onAppear {
                print("MenuBarView: Button appeared, isMonitoring: \(backgroundService.isMonitoring)")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            
            // Camera overlay controls
            if backgroundService.isMonitoring {
                Divider()
                
                Button(action: {
                    controller.toggleOverlay()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        
                        Text("Toggle Camera Feed")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                        
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            }
            
            Divider()
            
            // Status information - More compact
            if backgroundService.isMonitoring {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("Status:")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(backgroundService.statusMessage)
                            .font(.system(size: 10))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Faces:")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text("\(backgroundService.faceCount)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                
                Divider()
            }
            
            
            // Settings
            Button(action: {
                controller.openSettings()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    
                    Text("Settings...")
                        .foregroundColor(.primary)
                        .font(.system(size: 12))
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            
            Divider()
            
            // Quit
            Button(action: {
                controller.quitApp()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "power")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    
                    Text("Quit iSee")
                        .foregroundColor(.primary)
                        .font(.system(size: 12))
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .frame(width: 200)
    }
}
