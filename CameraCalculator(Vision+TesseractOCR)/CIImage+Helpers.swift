//
//  CIImage+Helpers.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 18/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation
import CoreImage

extension CIFilter {
    static func exposureAdjust(inputImage: CIImage, inputEV: NSNumber = 0) -> CIFilter? {
        guard let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputEV, forKey: kCIInputEVKey)
        return filter
    }
    
    static func colorsAdjust(inputImage: CIImage, saturaiton: NSNumber, contrast: NSNumber) -> CIFilter? {
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputSaturationKey)
        filter.setValue(1.1, forKey: kCIInputContrastKey)
        return filter
    }
}
