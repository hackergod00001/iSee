//
//  CameraManager.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import AVFoundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// CameraManager handles all camera operations using AVFoundation
/// Provides a live camera feed from the front-facing camera
class CameraManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var error: CameraError?
    
    // MARK: - Private Properties
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    // Vision processing
    var visionProcessor: VisionProcessor?
    
    // MARK: - Public Properties
    // Store preview layer as property (not computed) to prevent creating new layer each time
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        
        // Explicitly set connection properties for proper video display
        if let connection = layer.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true  // Mirror for front camera (like FaceTime)
            }
        }
        
        return layer
    }()
    
    // MARK: - Initialization
    override init() {
        super.init()
        checkAuthorization()
    }
    
    // MARK: - Public Methods
    
    /// Start the camera session
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = self.captureSession.isRunning
                }
            }
        }
    }
    
    /// Stop the camera session
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = self.captureSession.isRunning
                }
            }
        }
    }
    
    /// Setup camera configuration
    func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.configureCaptureSession()
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.isAuthorized = true
            }
            setupCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.error = .permissionDenied
                    }
                }
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.error = .permissionDenied
            }
            
        @unknown default:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.error = .unknown
            }
        }
    }
    
    private func configureCaptureSession() {
        captureSession.beginConfiguration()
        
        // Set session preset for optimal performance
        if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
        }
        
        // Add video input (front camera)
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            DispatchQueue.main.async {
                self.error = .deviceNotFound
            }
            captureSession.commitConfiguration()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                DispatchQueue.main.async {
                    self.error = .cannotAddInput
                }
                captureSession.commitConfiguration()
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.error = .inputCreationFailed
            }
            captureSession.commitConfiguration()
            return
        }
        
        // Configure video output
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            DispatchQueue.main.async {
                self.error = .cannotAddOutput
            }
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration()
        
        // Start the session
        DispatchQueue.main.async {
            self.startSession()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Send frame to VisionProcessor for face detection
        visionProcessor?.processFrame(sampleBuffer)
    }
}

// MARK: - Camera Error Types
enum CameraError: LocalizedError {
    case permissionDenied
    case deviceNotFound
    case cannotAddInput
    case cannotAddOutput
    case inputCreationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission is required to detect shoulder surfers"
        case .deviceNotFound:
            return "Front camera not found on this device"
        case .cannotAddInput:
            return "Cannot add camera input to capture session"
        case .cannotAddOutput:
            return "Cannot add video output to capture session"
        case .inputCreationFailed:
            return "Failed to create camera input"
        case .unknown:
            return "An unknown camera error occurred"
        }
    }
}
