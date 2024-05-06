//
//  TOTPGenerator.swift
//  TOTP
//  
//  Created by Tomohiro Kumagai on 2024/03/20
//  
//

import Foundation
import Crypto

public struct TOTPGenerator : Sendable {
    
    public let timeStep: Int
    public let digit: Int

    public init(timeStep: Int = Self.standardTimeStep, digit: Int = Self.standardDigit) {

        self.timeStep = timeStep
        self.digit = digit
    }
}

public extension TOTPGenerator {
    
    static let standardTimeStep = 30
    static let standardDigit = 6
    
    static let standard = TOTPGenerator()
    
    func counter(for date: Date) -> TOTPCounter {
        TOTPCounter(date.timeIntervalSince1970, timeStep: timeStep)
    }
    
    func makeValue(for date: borrowing Date, secretKey: borrowing TOTPKey) -> TOTPValue {

        let counter = counter(for: date)
        let messageAuthenticationCode = hashedAuthenticationCode(for: counter, key: secretKey)
        
        let truncatedCode = truncatingHashedAuthenticationCode(messageAuthenticationCode)
        
        return TOTPValue(truncatedCode: truncatedCode, using: self)
    }
}

extension TOTPGenerator {
    
    func hashedAuthenticationCode(for message: borrowing some DataProtocol, key: borrowing TOTPKey) -> some MessageAuthenticationCode {
        
        var hmacSHA1 = HMAC<Insecure.SHA1>(key: SymmetricKey(data: key.rawValue))
            
        hmacSHA1.update(data: message)
        return hmacSHA1.finalize()
    }
    
    func truncatingHashedAuthenticationCode(_ code: some MessageAuthenticationCode) -> UInt32 {

        precondition(code.byteCount > 0, "Code must not be empty.")
        
        let offset = targetOffsetOfHashedAuthenticationCode(code)
        let code = targetCodePartOfHashedAuthenticationCode(code, offset: offset) & 0x7FFFFFFF
        return code
    }
    
    func targetOffsetOfHashedAuthenticationCode(_ code: borrowing some MessageAuthenticationCode) -> UInt8 {
        
        code.withUnsafeBytes { bytes in
            bytes.last! & 0x0F
        }
    }
    
    func targetCodePartOfHashedAuthenticationCode(_ code: borrowing some MessageAuthenticationCode, offset: UInt8) -> UInt32 {
 
        code.withUnsafeBytes { bytes in
            bytes.loadUnaligned(fromByteOffset: Int(offset), as: UInt32.self).bigEndian
        }
    }
    
    var digitMask: UInt32 {
        Self.digitMask(for: digit)
    }
    
    static func digitMask(for digit: Int) -> UInt32 {
        Array(repeating: 10, count: digit).reduce(into: 1, *=)
    }
}
