//
//  MathematicalExpressionParser.swift
//  CameraCalculator(Vision+TesseractOCR)
//
//  Created by David Kaufman on 19/05/2019.
//  Copyright © 2019 David Kaufman. All rights reserved.
//

import Foundation

class MathematicalExpressionParser {
    
    static var precedence: [String: Int] = [
        "^" : 4,
        "*" : 3,
        "/" : 3,
        "+" : 2,
        "-" : 2
    ]
    
    static var associativity: [String: AssociativityType] = [
        "^" : .right,
        "*" : .left,
        "/" : .left,
        "+" : .left,
        "-" : .left
    ]
    
    enum AssociativityType: String {
        case left = "left"
        case right = "right"
    }
    
    enum Token {
        case `operator`(op: String, precedence: Int, associativity: AssociativityType)
        case digit(String)
        case parensOpen
        case parensClose
        
        var stringValue: String {
            switch self {
            case .operator(let op, _,_):
                return op
            case .digit(let d):
                return d
            case .parensOpen:
                return "("
            case .parensClose:
                return ")"
            }
        }
        
        typealias Generator = (String) -> Token
        
        static var generators: [String: Generator] {
            return [
                "\\*|\\/|\\+|\\-": { .operator(op: $0, precedence: precedence[$0]!, associativity: associativity[$0]!) },
                "\\-?([0-9]*\\.[0-9]+|[0-9]+)": { .digit($0) },
                "\\(": { _ in .parensOpen },
                "\\)": { _ in .parensClose }
            ]
        }
    }
    
    class Lexer {
        let tokens: [Token]
        
        init(text: String) {
            let set = Set("0123456789()+-*/")
            let trimmedText = text
                .filter({set.contains($0)})
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            var result = [Token]()
            
            trimmedText.forEach { (character) in
                Token.generators.forEach( { args in
                    let (regex, generator) = args
                    
                    let stringChar = String(character)
                    let range = NSRange(location: 0, length: stringChar.utf16.count)
                    let expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
                    
                    if expression.firstMatch(in: stringChar, options: [], range: range) != nil {
                        let token = generator(stringChar)
                        result.append(token)
                    } else {
                        debugPrint("Could not parse \(stringChar)")
                    }
                    
                })
            }
            
            self.tokens = result
        }
    }
    
    
    func parse(input: String) -> String {
        var operationsStack = [Token]()
        var outputQueue = [String]()
        
        let tokens = Lexer(text: input).tokens
        
        tokens.forEach { (token) in
            switch token {
            //If the token is an operator, o1, then:
            case .operator(_, let precedence1, let associativity1):
                while case .operator(let op2, let precedence2, _)? = operationsStack.peek() {
                    if (associativity1 == .left && precedence1 <= precedence2)
                        || (associativity1 == .right && precedence1 < precedence2)
                    {
                        operationsStack.removeLast()
                        outputQueue.push(op2)
                    }
                }
                operationsStack.push(token)
            case .digit(let d):
                //If the token is a number, then push it to the output queue
                outputQueue.push(d)
            case .parensOpen:
                operationsStack.push(token)
            case .parensClose:
                //Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue.
                while case .parensOpen? = operationsStack.peek() {
                    outputQueue.push(")")
                }
                _ = operationsStack.pop()
            }
        }
        
        return String([outputQueue, operationsStack.map({$0.stringValue}).reversed()].flatMap({$0}).flatMap({$0}))
    }
    
}

fileprivate extension Array {
    mutating func push(_ element: Element) {
        self.append(element)
    }
    
    func peek() -> Element? {
        return self.last
    }
    
    mutating func pop() -> Element {
        return self.removeLast()
    }
}
