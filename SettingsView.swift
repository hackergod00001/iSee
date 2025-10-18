import SwiftUI

/// SettingsView provides configuration options for testing and fine-tuning
struct SettingsView: View {
    @ObservedObject var stateController: StateController
    @ObservedObject var visionProcessor: VisionProcessor
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Status Section
                Section("Current Status") {
                    HStack {
                        Text("Security State")
                        Spacer()
                        Text(stateController.statusMessage)
                            .foregroundColor(stateColor)
                    }
                    
                    HStack {
                        Text("Face Count")
                        Spacer()
                        Text("\(visionProcessor.faceCount)")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Processing")
                        Spacer()
                        Text(visionProcessor.isProcessing ? "Active" : "Idle")
                            .foregroundColor(visionProcessor.isProcessing ? .green : .gray)
                    }
                    
                    if stateController.isInWarningState {
                        HStack {
                            Text("Time Until Alert")
                            Spacer()
                            Text(String(format: "%.1fs", stateController.timeUntilAlert))
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("Alert Progress")
                            Spacer()
                            ProgressView(value: stateController.alertProgress)
                                .frame(width: 100)
                        }
                    }
                }
                
                // Controls Section
                Section("Controls") {
                    Button("Reset to Safe State") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.blue)
                    
                    Button(stateController.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                        if stateController.isMonitoring {
                            stateController.stopMonitoring()
                        } else {
                            stateController.startMonitoring()
                        }
                    }
                    .foregroundColor(stateController.isMonitoring ? .red : .green)
                }
                
                // Test Section
                Section("Testing") {
                    Button("Simulate 2 Faces") {
                        stateController.updateFaceCount(2)
                    }
                    .foregroundColor(.orange)
                    
                    Button("Simulate 1 Face") {
                        stateController.updateFaceCount(1)
                    }
                    .foregroundColor(.green)
                    
                    Button("Simulate 0 Faces") {
                        stateController.updateFaceCount(0)
                    }
                    .foregroundColor(.red)
                }
                
                // Information Section
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shoulder Surfer Detection")
                            .font(.headline)
                        
                        Text("This app uses on-device face detection to alert you when someone else is looking at your screen. All processing is done locally for your privacy.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Alert Threshold: 2.0 seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Processing Rate: ~5 FPS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Reset to Safe State", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                stateController.resetToSafe()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset the security state to safe and clear any active alerts.")
        }
    }
    
    private var stateColor: Color {
        switch stateController.currentState {
        case .safe:
            return .green
        case .warning:
            return .orange
        case .alert:
            return .red
        case .error:
            return .gray
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            stateController: StateController(),
            visionProcessor: VisionProcessor()
        )
    }
}

