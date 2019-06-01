//
//  CameraController.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 17/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

final class CameraController: UIViewController {
    
    let avCaptureSession = AVCaptureSession()
    let cameraLayer = AVCaptureVideoPreviewLayer()
    let overlayLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAVSession()
        
        avCaptureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        cameraLayer.frame = view.bounds
        overlayLayer.frame = view.bounds
    }
    
    private func setupAVSession() {
        avCaptureSession.beginConfiguration()
        avCaptureSession.sessionPreset = .high
        
        defer {
            avCaptureSession.commitConfiguration()
        }
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: backCamera), avCaptureSession.canAddInput(input) else {
            return
        }
        
        avCaptureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        
        guard avCaptureSession.canAddOutput(output) else { return }
        
        avCaptureSession.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        cameraLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        view.layer.addSublayer(overlayLayer)
    }
    
    var onDidCaptureBuffer: ((CMSampleBuffer) -> ())?
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onDidCaptureBuffer?(sampleBuffer)
    }
}
