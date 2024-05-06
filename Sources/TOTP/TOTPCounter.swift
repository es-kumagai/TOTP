//
//  TOTPCounter.swift
//  TOTP
//  
//  Created by Tomohiro Kumagai on 2024/03/20
//  
//

import Foundation

public struct TOTPCounter : Sendable {
    
    public let data: Data
    
    public init(data: Data) {
        
        self.data = data
    }
}

public extension TOTPCounter {
    
    init(_ value: borrowing UInt64) {

        var value = value.bigEndian
        
        data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
    
    init(_ value: some BinaryInteger) {
        
        self.init(UInt64(value))
    }
    
    init(_ timeInterval: borrowing TimeInterval, timeStep: borrowing some BinaryInteger) {
        
        self.init(UInt64(timeInterval) / numericCast(timeStep))
    }
    
    init(_ date: Date, timeStep: borrowing some BinaryInteger) {
        
        self.init(date.timeIntervalSince1970, timeStep: timeStep)
    }
    
    var value: UInt64 {
        data.reduce(into: 0) { $0 = $0 * 0x100 + UInt64($1) }
    }
}

extension TOTPCounter : Equatable {

    public static func == (lhs: TOTPCounter, rhs: TOTPCounter) -> Bool {
        
        lhs.data == rhs.data
    }
}

extension TOTPCounter : CustomStringConvertible {
    
    public var description: String {
        String(value)
    }
}

extension TOTPCounter : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        String(reflecting: data)
    }
}

extension TOTPCounter : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt64) {
        self.init(value)
    }
}

extension TOTPCounter : DataProtocol, ContiguousBytes {

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try data.withUnsafeBytes(body)
    }
    
    public var regions: [Data] {
        [data]
    }
    
    public var startIndex: Int {
        data.startIndex
    }
    
    public var endIndex: Int {
        data.endIndex
    }
    
    public subscript(position: Int) -> UInt8 {
        data[position]
    }
    
    public func index(after i: Int) -> Int {
        data.index(after: i)
    }
    
    public func index(before i: Int) -> Int {
        data.index(before: i)
    }
}
