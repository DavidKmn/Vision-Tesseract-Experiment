//
//  TesseractService.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 18/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation
import TesseractOCR

final class TesseractService {
    
    var onDidDetectText: ((String) -> ())?
    
    let context = CIContext()
    
    private let tesseract: G8Tesseract = {
        let tesseract = G8Tesseract(language: "eng")!
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .singleBlock
        return tesseract
    }()
    
    
    func handle(image: UIImage) {
        guard let preprocessedImage = preprocess(image: image) else {
            debugPrint("Failed to preprocess image")
            return }
        tesseract.image = preprocessedImage
        tesseract.recognize()
        let text = tesseract.recognizedText ?? "Not Recognized"
        onDidDetectText?(text)
    }
    
    //  A convenience method for using CoreImage filters to preprocess an image by
    //  1) setting the saturation to 0 to achieve grayscale
    //  2) increasing the contrast by 10% to make black parts blacker, and 3) reducing the exposure
    //  3) by 30% to reduce the amount of "light" in the image.
    private func preprocess(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        guard let processedCIImage = CIFilter.colorsAdjust(inputImage: ciImage, saturaiton: 0, contrast: 1.1)?.outputImage.flatMap({ (blackAndWhiteImage) -> CIImage? in
            return CIFilter.exposureAdjust(inputImage: blackAndWhiteImage, inputEV: 0.7)?.outputImage
        }) else {
            return nil
        }
        
        if let cgImage = context.createCGImage(processedCIImage, from: processedCIImage.extent) {
            let processedUIImage = UIImage(cgImage: cgImage)
            return processedUIImage
        } else { return nil }
    }
  
}
