//
//  MainViewController.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 19/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import UIKit
import AnchorKit

class MainViewController: UIViewController {
    private let cameraController = CameraController()
    private let visionService = VisionService()
    private let boxService = BoxService()
    private let rpnEvaluator = ReversePolishNotationEvaluator()
    private let tesseractService = TesseractService()
    private let mathParser = MathematicalExpressionParser()
    
    private lazy var recognisedTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        label.alpha = 0
        return label
    }()
    
    private lazy var calculatedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textColor = .green
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraController.willMove(toParent: self)
        addChild(cameraController)
        self.view.addSubview(cameraController.view)
        cameraController.view.frame = self.view.frame
        cameraController.didMove(toParent: self)
        
        view.addSubview(recognisedTextLabel)
        view.addSubview(calculatedLabel)
                
        recognisedTextLabel.layout {
            $0.bottom == self.view.safeAreaLayoutGuide.bottomAnchor - 20
        }
        
        calculatedLabel.centerInSuperview()
        
        cameraController.onDidCaptureBuffer = { [weak self] buffer in
            self?.calculatedLabel.alpha = 0
            self?.visionService.handle(buffer: buffer)
        }
        
        visionService.onDidTextText = { [weak self] image, textObservations in
            guard let self = self else { return }
            self.boxService.handle(overlayLayer: self.cameraController.overlayLayer, image: image, textObservationResults: textObservations, onView: self.cameraController.view)
        }
        
        boxService.onDidDetectImage = { [weak self] image in
            self?.tesseractService.handle(image: image)
        }
        
        tesseractService.onDidDetectText = { [weak self] detextedText in
            guard let self = self else { return }
            let unsolvedRPNText = self.mathParser.parse(input: detextedText)
            let finalResult = self.rpnEvaluator.evaluate(expression: unsolvedRPNText)
            self.show(result: finalResult)
            
        }
    }
    
    private func show(result: Double) {
        calculatedLabel.text = "\(result)"
        calculatedLabel.transform = .identity
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.calculatedLabel.alpha = 1.0
                self.calculatedLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
        },
            completion: nil
        )
    }
}
