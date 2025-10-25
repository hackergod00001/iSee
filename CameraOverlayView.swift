//
//  CameraOverlayView.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import SwiftUI
import Vision
import AVFoundation

/// Overlay appearance style options
enum OverlayStyle: String, CaseIterable, Identifiable {
    case matteBlack = "Matte Black"
    case glassmorphism = "Glass (Translucent)"
    
    var id: String { rawValue }
}

/// Dynamic Island-style camera overlay view with liquid expansion animation
struct CameraOverlayView: View {
    @ObservedObject private var backgroundService = BackgroundMonitoringService.shared
    @State private var animationPhase: AnimationPhase = .hidden
    @State private var scale: CGFloat = 0.1
    @State private var cornerRadius: CGFloat = 100
    @AppStorage("overlayStyle") private var overlayStyle: String = OverlayStyle.matteBlack.rawValue
    
    enum AnimationPhase {
        case hidden, expanding, expanded, collapsing
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // NotchDrop-style background layer
            notchBackgroundLayer
                .zIndex(0)
            
            // Content layer on top
            VStack(spacing: 0) {
                // Top bar with camera integration
                topBarView
                
                // Camera feed area
                cameraFeedView
            }
            .frame(width: 340, height: 220)
            .zIndex(1)
        }
        .frame(width: 340 + cornerRadius * 2, height: 220)
        .scaleEffect(scale)
        .onAppear {
            startLiquidExpansion()
        }
    }
    
    // MARK: - NotchDrop-style Background
    
    /// Background layer inspired by NotchDrop's design
    private var notchBackgroundLayer: some View {
        Rectangle()
            .foregroundStyle(.black)  // Matte black like NotchDrop
            .mask(notchBackgroundMask)
            .frame(width: 340 + cornerRadius * 2, height: 220)
            .shadow(
                color: .black.opacity(scale > 0.5 ? 1 : 0),
                radius: 16
            )
    }
    
    /// Custom mask for NotchDrop-style rounded corners
    private var notchBackgroundMask: some View {
        Rectangle()
            .foregroundStyle(.black)
            .frame(width: 340, height: 220)
            .clipShape(
                .rect(
                    bottomLeadingRadius: cornerRadius,
                    bottomTrailingRadius: cornerRadius
                )
            )
            .overlay {
                // Top-left curved corner
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .frame(width: cornerRadius, height: cornerRadius)
                        .foregroundStyle(.black)
                    Rectangle()
                        .clipShape(.rect(topTrailingRadius: cornerRadius))
                        .foregroundStyle(.white)
                        .frame(
                            width: cornerRadius + 8,
                            height: cornerRadius + 8
                        )
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: -cornerRadius - 8 + 0.5, y: -0.5)
            }
            .overlay {
                // Top-right curved corner
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .frame(width: cornerRadius, height: cornerRadius)
                        .foregroundStyle(.black)
                    Rectangle()
                        .clipShape(.rect(topLeadingRadius: cornerRadius))
                        .foregroundStyle(.white)
                        .frame(
                            width: cornerRadius + 8,
                            height: cornerRadius + 8
                        )
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: cornerRadius + 8 - 0.5, y: -0.5)
            }
    }
    
    // MARK: - Computed Properties
    
    /// Get overlay background material based on user preference
    private var overlayBackgroundMaterial: AnyShapeStyle {
        let style = OverlayStyle(rawValue: overlayStyle) ?? .matteBlack
        
        switch style {
        case .matteBlack:
            return AnyShapeStyle(Color.black)  // Fully opaque black
        case .glassmorphism:
            return AnyShapeStyle(.ultraThinMaterial)  // Translucent glass effect
        }
    }
    
    // MARK: - Top Bar View (Camera Hardware Area)
    
    private var topBarView: some View {
        HStack(spacing: 0) {
            // Close button (left) - macOS style
            Button(action: closeOverlay) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)  // Red for close button
                    .frame(width: 30, height: 44)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Empty center area (behind notch)
            Spacer()
            
            // Settings button (right)
            Button(action: openSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)  // Gray for settings button
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
        ) {
            scale = 1.03
            cornerRadius = 16
        }
        
        // Settle to final scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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
        view.wantsLayer = true
        
        // Create clean background layer
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = NSColor.black.cgColor  // Black background for clean look
        view.layer = backgroundLayer
        
        // Get preview layer and set explicit initial frame (433x260)
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = CGRect(x: 0, y: 0, width: 433, height: 260)
        previewLayer.videoGravity = .resizeAspectFill
        
        // Ensure layer is set up correctly
        view.layer?.addSublayer(previewLayer)
        
        // Force immediate layout
        view.layoutSubtreeIfNeeded()
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update frame on main thread and force redisplay
        DispatchQueue.main.async {
            if let previewLayer = nsView.layer?.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = nsView.bounds
                previewLayer.setNeedsDisplay()
            }
        }
    }
}
#endif

// MARK: - Face Detection Overlay View

struct FaceDetectionOverlayView: View {
    @ObservedObject var visionProcessor: VisionProcessor
    @State private var previewSize: CGSize = .zero  // Will be set dynamically from geometry
    
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
        // Also flip horizontally to match mirrored camera preview
        let convertedRect = CGRect(
            x: 1.0 - visionBox.origin.x - visionBox.width,  // Flip X for mirrored view
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