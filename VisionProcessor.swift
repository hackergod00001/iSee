//
//  VisionProcessor.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


import Vision
import AVFoundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// VisionProcessor handles face detection using Apple's Vision framework
/// Processes camera frames to detect and count faces in real-time
class VisionProcessor: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var detectedFaces: [VNFaceObservation] = []
    @Published var faceCount: Int = 0
    @Published var isProcessing = false
    
    // MARK: - Private Properties
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest!
    private let processingQueue = DispatchQueue(label: "vision.processing.queue", qos: .userInitiated)
    
    // Performance optimization
    private var lastProcessTime: CFTimeInterval = 0
    private let processingInterval: CFTimeInterval = 0.2 // Process every 200ms (5 FPS)
    private var frameSkipCounter = 0
    private let frameSkipInterval = 3 // Process every 3rd frame
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Create face detection request
        self.faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            self?.handleFaceDetectionResults(request: request, error: error)
        }
        
        // Configure the request for optimal performance
        self.faceDetectionRequest.revision = VNDetectFaceRectanglesRequestRevision3
    }
    
    // MARK: - Public Methods
    
    /// Process a camera frame for face detection
    /// - Parameter sampleBuffer: The camera frame to analyze
    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard !isProcessing else { return }
        
        // Performance optimization: Skip frames and limit processing frequency
        frameSkipCounter += 1
        if frameSkipCounter < frameSkipInterval {
            return
        }
        frameSkipCounter = 0
        
        let currentTime = CACurrentMediaTime()
        if currentTime - lastProcessTime < processingInterval {
            return
        }
        lastProcessTime = currentTime
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessing = true
            }
            
            // Convert CMSampleBuffer to CVPixelBuffer
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }
            
            // Create image request handler
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            
            do {
                // Perform face detection
                try imageRequestHandler.perform([self.faceDetectionRequest])
            } catch {
                print("Face detection failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleFaceDetectionResults(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isProcessing = false
            
            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else {
                self.detectedFaces = []
                self.faceCount = 0
                return
            }
            
            // Update detected faces and count
            self.detectedFaces = observations
            self.faceCount = observations.count
            
            // Log face detection results for debugging
            if self.faceCount > 0 {
                print("Detected \(self.faceCount) face(s)")
            }
        }
    }
}

// MARK: - Face Detection Extensions
extension VisionProcessor {
    
    /// Get face bounding boxes normalized to the camera preview
    /// - Parameter previewSize: The size of the camera preview view
    /// - Returns: Array of normalized face rectangles
    func getNormalizedFaceRectangles(for previewSize: CGSize) -> [CGRect] {
        return detectedFaces.map { faceObservation in
            // Convert Vision's normalized coordinates to preview coordinates
            let boundingBox = faceObservation.boundingBox
            
            // Vision uses bottom-left origin, we need top-left
            let convertedRect = CGRect(
                x: boundingBox.origin.x,
                y: 1.0 - boundingBox.origin.y - boundingBox.height,
                width: boundingBox.width,
                height: boundingBox.height
            )
            
            // Scale to preview size
            return CGRect(
                x: convertedRect.origin.x * previewSize.width,
                y: convertedRect.origin.y * previewSize.height,
                width: convertedRect.width * previewSize.width,
                height: convertedRect.height * previewSize.height
            )
        }
    }
    
    /// Check if a specific face is likely the primary user (largest face)
    /// - Returns: The index of the primary face, or nil if no faces detected
    func getPrimaryFaceIndex() -> Int? {
        guard !detectedFaces.isEmpty else { return nil }
        
        // Find the face with the largest bounding box area
        var largestArea: CGFloat = 0
        var primaryIndex: Int = 0
        
        for (index, face) in detectedFaces.enumerated() {
            let area = face.boundingBox.width * face.boundingBox.height
            if area > largestArea {
                largestArea = area
                primaryIndex = index
            }
        }
        
        return primaryIndex
    }
}
