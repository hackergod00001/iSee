import SwiftUI
import Vision
import AVFoundation

/// Dynamic Island-style camera overlay view with liquid expansion animation
struct CameraOverlayView: View {
    @ObservedObject private var backgroundService = BackgroundMonitoringService.shared
    @State private var animationPhase: AnimationPhase = .hidden
    @State private var scale: CGFloat = 0.1
    @State private var cornerRadius: CGFloat = 100
    
    enum AnimationPhase {
        case hidden, expanding, expanded, collapsing
    }
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            
            // Content overlay
            VStack(spacing: 0) {
                // Top bar with camera integration
                topBarView
                
                Divider()
                    .opacity(0.3)
                
                // Camera feed area
                cameraFeedView
            }
        }
        .frame(width: 340, height: 220)
        .scaleEffect(scale)
        .onAppear {
            startLiquidExpansion()
        }
    }
    
    // MARK: - Top Bar View (Camera Hardware Area)
    
    private var topBarView: some View {
        HStack(spacing: 0) {
            // Close button (left) - macOS style
            Button(action: closeOverlay) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 30, height: 44)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Camera area (center) - darkened to represent hardware
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("Camera")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 44)
            .background(Color.black.opacity(0.3))
            .cornerRadius(22)
            
            Spacer()
            
            // Settings button (right)
            Button(action: openSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(width: 30, height: 44)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
    }
    
    // MARK: - Camera Feed View
    
    private var cameraFeedView: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(
                cameraManager: backgroundService.cameraManager,
                visionProcessor: backgroundService.visionProcessor
            )
            .frame(width: 324, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Face detection overlays
            FaceDetectionOverlayView(visionProcessor: backgroundService.visionProcessor)
                .frame(width: 324, height: 160)
        }
        .padding(8)
    }
    
    // MARK: - Liquid Expansion Animation
    
    private func startLiquidExpansion() {
        animationPhase = .expanding
        
        withAnimation(
            .interpolatingSpring(
                stiffness: 200,
                damping: 15,
                initialVelocity: 5
            )
            .delay(0.1)
        ) {
            scale = 1.05
            cornerRadius = 16
        }
        
        // Settle to final scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                scale = 1.0
                animationPhase = .expanded
            }
        }
    }
    
    // MARK: - Actions
    
    private func openSettings() {
        SettingsWindow.shared.showWindow()
    }
    
    private func closeOverlay() {
        backgroundService.hideOverlay()
    }
}

// MARK: - Camera Preview View

#if canImport(UIKit)
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    let visionProcessor: VisionProcessor
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 324, height: 160))
        
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
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
        previewLayer.frame = CGRect(x: 0, y: 0, width: 324, height: 160)
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        view.wantsLayer = true
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = CGRect(x: 0, y: 0, width: 324, height: 160)
        }
    }
}
#endif

// MARK: - Face Detection Overlay View

struct FaceDetectionOverlayView: View {
    @ObservedObject var visionProcessor: VisionProcessor
    @State private var previewSize: CGSize = CGSize(width: 324, height: 160)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(visionProcessor.detectedFaces.enumerated()), id: \.offset) { index, face in
                    FaceBoundingBoxView(
                        face: face,
                        index: index,
                        previewSize: previewSize
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
                lineWidth: 2
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
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white)
                    .padding(2)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 2))
                    .position(
                        x: boundingBox.midX,
                        y: boundingBox.minY - 8
                    )
            )
    }
}