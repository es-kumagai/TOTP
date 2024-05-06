//
//  TOTPKey.swift
//  TOTP
//  
//  Created by Tomohiro Kumagai on 2024/03/20
//  
//

import Foundation
import Ocean

public struct TOTPKey : Sendable, Hashable, Codable, RawRepresentable, Equatable {
    
    public let rawValue: Data
    
    public init(rawValue: Data) {
        self.rawValue = rawValue
    }
}

public extension TOTPKey {
    
    init?(key: borrowing some StringProtocol, encoding: String.Encoding = .utf8) {
        
        guard let data = key.data(using: encoding) else {
            return nil
        }
        
        rawValue = data
    }
    
    init?(base32encodedKey key: borrowing some StringProtocol) {
        
        guard let key = key.replacingOccurrences(of: " ", with: "").uppercased().data(using: .ascii) else {
            return nil
        }

        guard let data = Data(base32Encoded: key) else {
            return nil
        }

        rawValue = data
    }
    
    var rawString: String! {
        rawString(using: .utf8)
    }
    
    func rawString(using encoding: String.Encoding) -> String! {
        String(data: rawValue, encoding: encoding)
    }
    
    var base32EncodedString: String {
        rawValue.base32EncodedString()
    }
}

extension TOTPKey : CustomStringConvertible {
    
    public var description: String {
        rawValue.base32EncodedString()
    }
}
