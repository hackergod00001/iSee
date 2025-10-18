import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var visionProcessor = VisionProcessor()
    @StateObject private var stateController = StateController()
    @State private var showingPermissionAlert = false
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(cameraManager: cameraManager, visionProcessor: visionProcessor)
                .ignoresSafeArea()
            
            // Face Detection Overlays
            FaceDetectionOverlayView(visionProcessor: visionProcessor)
                .ignoresSafeArea()
            
            // Notification Banner
            NotificationBanner(stateController: stateController)
                .ignoresSafeArea(edges: .top)
            
            // Overlay UI
            VStack {
                // Top controls
                HStack {
                    Spacer()
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(cameraManager.isAuthorized ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(cameraManager.isAuthorized ? "Camera Active" : "Camera Inactive")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                    
                    // Face count indicator
                    if visionProcessor.faceCount > 0 {
                        Text("\(visionProcessor.faceCount) Face(s)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                    
                    // Security state indicator
                    Text(stateController.statusMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(stateController.isInAlertState ? Color.red.opacity(0.8) : 
                                   stateController.isInWarningState ? Color.orange.opacity(0.8) : 
                                   Color.green.opacity(0.8))
                        .cornerRadius(12)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Connect vision processor to camera manager
            cameraManager.visionProcessor = visionProcessor
            
            // Start monitoring when camera is authorized
            if cameraManager.isAuthorized {
                stateController.startMonitoring()
            }
            
            if !cameraManager.isAuthorized {
                showingPermissionAlert = true
            }
        }
        .onChange(of: cameraManager.isAuthorized) { isAuthorized in
            if isAuthorized {
                stateController.startMonitoring()
            } else {
                stateController.stopMonitoring()
            }
        }
        .onChange(of: visionProcessor.faceCount) { faceCount in
            stateController.updateFaceCount(faceCount)
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                #if canImport(UIKit)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #elseif canImport(AppKit)
                if let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                    NSWorkspace.shared.open(settingsUrl)
                }
                #endif
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This app needs camera access to detect when someone is looking at your screen. All processing is done on-device for your privacy.")
        }
        .sheet(isPresented: $showingSettings) {
            Text("Settings View - Coming Soon")
                .padding()
        }
    }
}

// MARK: - Camera Preview View
#if canImport(UIKit)
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame if needed
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
#elseif canImport(AppKit)
struct CameraPreviewView: NSViewRepresentable {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = view.bounds
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        view.wantsLayer = true
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update preview layer frame if needed
        if let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = nsView.bounds
        }
    }
}
#endif

// MARK: - Face Detection Overlay View
struct FaceDetectionOverlayView: View {
    @ObservedObject var visionProcessor: VisionProcessor
    @State private var previewSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(visionProcessor.detectedFaces.enumerated()), id: \.offset) { index, face in
                    FaceBoundingBoxView(
                        face: face,
                        index: index,
                        previewSize: geometry.size
                    )
                }
            }
            .onAppear {
                previewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                previewSize = newSize
            }
        }
    }
}

// MARK: - Face Bounding Box View
struct FaceBoundingBoxView: View {
    let face: VNFaceObservation
    let index: Int
    let previewSize: CGSize
    
    private var boundingBox: CGRect {
        let visionBox = face.boundingBox
        
        // Convert Vision's bottom-left origin to top-left
        let convertedRect = CGRect(
            x: visionBox.origin.x,
            y: 1.0 - visionBox.origin.y - visionBox.height,
            width: visionBox.width,
            height: visionBox.height
        )
        
        // Scale to preview size
        return CGRect(
            x: convertedRect.origin.x * previewSize.width,
            y: convertedRect.origin.y * previewSize.height,
            width: convertedRect.width * previewSize.width,
            height: convertedRect.height * previewSize.height
        )
    }
    
    var body: some View {
        Rectangle()
            .stroke(
                index == 0 ? Color.green : Color.red,
                lineWidth: 3
            )
            .frame(
                width: boundingBox.width,
                height: boundingBox.height
            )
            .position(
                x: boundingBox.midX,
                y: boundingBox.midY
            )
            .overlay(
                Text(index == 0 ? "You" : "Other")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .position(
                        x: boundingBox.midX,
                        y: boundingBox.minY - 10
                    )
            )
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
