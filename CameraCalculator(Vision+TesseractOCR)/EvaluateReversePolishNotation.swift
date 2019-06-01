//
//  EvaluateReversePolishNotation.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 19/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation

final class ReversePolishNotationEvaluator {
    func evaluate(expression: String) -> Double {
        
        let tokens = Array(expression).map { String($0) }
        var stack = [Double]()
        
        for token in tokens {
            if let num = Double(token) {
                stack.append(num)
            } else {
                let post = stack.removeLast()
                let prev = stack.removeLast()
                
                stack.append(operate(prev, post, token))
            }
        }
        
        return stack.first ?? 0
    }
    
    private func operate(_ prev: Double, _ post: Double, _ token: String) -> Double {
        switch token {
        case "+":
            return prev + post
        case "-":
            return prev - post
        case "*":
            return prev * post
        default:
            return prev / post
        }
    }
}
