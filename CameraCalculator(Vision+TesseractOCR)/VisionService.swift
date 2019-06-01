//
//  VisionService.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 19/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation
import Vision
import UIKit
import AVFoundation

class VisionService {
    
    var onDidTextText: ((_ fromImage: UIImage, _ text: [VNTextObservation]) -> ())?
    
    private func makeRequest(withImage uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            assertionFailure()
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [VNImageOption : Any]())
        
        let request = VNDetectTextRectanglesRequest { [weak self] (req, error) in
            DispatchQueue.main.async {
                self?.handle(image: uiImage, request: req, error: error)
            }
        }
        
        request.reportCharacterBoxes = true
        
        do {
            try handler.perform([request])
        } catch let reqError {
            print(reqError as Any)
        }
    }
    
    
    func handle(buffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        let uiImage = UIImage(ciImage: ciImage)
        
        makeRequest(withImage: uiImage)
    }
    
    private func handle(image: UIImage, request: VNRequest, error: Error?) {
        guard let textObervation = request.results as? [VNTextObservation] else { return }
        onDidTextText?(image, textObervation)
    }
}
