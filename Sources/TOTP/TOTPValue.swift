//
//  TOTPValue.swift
//  TOTP
//  
//  Created by Tomohiro Kumagai on 2024/03/20
//  
//

import Foundation

public struct TOTPValue : Sendable, Codable, Hashable {
    
    public let code: UInt32
    public let digit: Int

    public init(code: UInt32, digit: Int) {

        self.code = code
        self.digit = digit
    }
    
    public init(truncatedCode code: UInt32, using generator: TOTPGenerator) {

        self.init(code: code, digit: generator.digit)
    }
}

public extension TOTPValue {
    
    init(for date: borrowing Date, secretKey: borrowing TOTPKey, using generator: borrowing TOTPGenerator = .standard) {
        
        self = generator.makeValue(for: date, secretKey: secretKey)
    }
    
    var maskedCode: UInt32 {
        code % TOTPGenerator.digitMask(for: digit)
    }
    
    var prettyDescription: String {
        prettyDescription(withSeparator: " ")
    }
    
    func prettyDescription(withSeparator separator: some StringProtocol) -> String {
        
        String(maskedCode, radix: 10)
            .enumerated()
            .map { offset, character in
                
                guard offset != 0 else {
                    return String(character)
                }
                
                return switch offset.isMultiple(of: 3) {
                    
                case true:
                    separator + String(character)
                    
                case false:
                    String(character)
                }
            }
            .joined()
    }
}

extension TOTPValue : CustomStringConvertible {
    
    public var description: String {
        String(format: "%0\(digit)d", maskedCode)
    }
}
