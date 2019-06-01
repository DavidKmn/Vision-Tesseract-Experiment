//
//  BoxServce.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 18/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//
import UIKit
import Vision

final class BoxService {
    
    var onDidDetectImage: ((UIImage) -> ())?
    
    func handle(overlayLayer: CALayer, image: UIImage, textObservationResults: [VNTextObservation], onView view: UIView) {
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let results = textObservationResults.filter { $0.confidence > 0.7 }
        
        // BOX
        results.forEach {
            drawBox(overlayLayer: overlayLayer, normalisedRect: normalise(box: $0))
        }
        
        // IMAGE
        guard let biggestResult = results.max(by: { obs1, obs2 in  obs1.boundingBox.width > obs2.boundingBox.width }) else { return }
        
        let normalisedRect = normalise(box: biggestResult)
        if let croppedImage = cropImage(image, normalisedRect: normalisedRect) {
            onDidDetectImage?(croppedImage)
        }
    }
    
    func normalise(box: VNTextObservation) -> CGRect {
        return CGRect(
            x: box.boundingBox.origin.x,
            y: 1 - box.boundingBox.origin.y - box.boundingBox.height,
            width: box.boundingBox.width,
            height: box.boundingBox.height
        )
    }
    
    func drawBox(overlayLayer: CALayer, normalisedRect: CGRect) {
        let x = normalisedRect.origin.x * overlayLayer.frame.size.width
        let y = normalisedRect.origin.y * overlayLayer.frame.size.height
        let width = normalisedRect.width * overlayLayer.frame.size.width
        let height = normalisedRect.height * overlayLayer.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: x, y: y, width: width, height: height)
        outline.borderWidth = 2
        outline.borderColor = UIColor.red.cgColor
        
        overlayLayer.addSublayer(outline)
    }
    
    private func cropImage(_ image: UIImage, normalisedRect: CGRect) -> UIImage? {
        let x = normalisedRect.origin.x * image.size.width
        let y = normalisedRect.origin.y * image.size.height
        let width = normalisedRect.width * image.size.width
        let height = normalisedRect.height * image.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height).scaleUp(scale: 0.1)
        
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage
    }
}

fileprivate extension CGRect {
    func scaleUp(scale: CGFloat) -> CGRect {
        return self.insetBy(
            dx: -self.size.width * scale,
            dy: -self.size.height * scale
        )
    }
}
