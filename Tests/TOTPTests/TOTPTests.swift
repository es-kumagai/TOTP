//
//  TOTPTests.swift
//  TOTPTests
//
//  Created by Tomohiro Kumagai on 2024/03/20
//
//

import XCTest
@testable import TOTP

final class TOTPTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testRFC4226Sample() throws {
        
        let generator = TOTPGenerator()
        
        let secret = "12345678901234567890"
        
        let expectedHMACValues = [
            "cc93cf18508d94934c64b65d8ba7667fb7cde4b0",
            "75a48a19d4cbe100644e8ac1397eea747a2d33ab",
            "0bacb7fa082fef30782211938bc1c5e70416ff44",
            "66c28227d03a2d5529262ff016a1e6ef76557ece",
            "a904c900a64b35909874b33e61c5938a8e15ed1c",
            "a37e783d7b7233c083d4f62926c7a25f238d0316",
            "bc9cd28561042c83f219324d3c607256c03272ae",
            "a4fb960c0bc06e1eabb804e5b397cdc4b45596fa",
            "1b3c89f65e6c9e883012052823443f048b4332db",
            "1637409809a679dc698207310c8c7fc07290d9e5",
        ]
        
        let expectedTruncatedHexValues = [
            "4c93cf18",
            "41397eea",
            "82fef30",
            "66ef7655",
            "61c5938a",
            "33c083d4",
            "7256c032",
            "4e5b397",
            "2823443f",
            "2679dc69",
        ]
        
        let expectedTruncatedDecimalValues = [
            "1284755224",
            "1094287082",
            "137359152",
            "1726969429",
            "1640338314",
            "868254676",
            "1918287922",
            "82162583",
            "673399871",
            "645520489",
        ]
        
        let expectedHOTPValues = [
            "755224",
            "287082",
            "359152",
            "969429",
            "338314",
            "254676",
            "287922",
            "162583",
            "399871",
            "520489",
        ]
        
        for count in 0 ... 9 {
            
            let secret = TOTPKey(key: secret)!
            let counter = TOTPCounter(count)
            let hashedAuthenticationCode = generator.hashedAuthenticationCode(for: counter, key: secret)
            let truncatedCode = generator.truncatingHashedAuthenticationCode(hashedAuthenticationCode)
            let totpValue = TOTPValue(truncatedCode: truncatedCode, using: generator)
            
            XCTAssertEqual(counter.value, UInt64(count))
            XCTAssertEqual(hashedAuthenticationCode.description, "HMAC with SHA1: \(expectedHMACValues[count])", "Unexpected HMAC value in \(count)")
            XCTAssertEqual(String(truncatedCode, radix: 16), expectedTruncatedHexValues[count], "Unexpected truncated hex value in \(count)")
            XCTAssertEqual(String(truncatedCode, radix: 10), expectedTruncatedDecimalValues[count], "Unexpected truncated decimal value in \(count)")
            XCTAssertEqual(totpValue.description, expectedHOTPValues[count], "Unexpected TOTP value in \(count)")
        }
    }
    
    func testGenerator() throws {
        
        let generator = TOTPGenerator()
        
        XCTAssertEqual(generator.timeStep, 30)
        
        let key1 = TOTPKey(base32encodedKey: "2a6h 5lw5 gz5t ko64 ukgp t5qt pqne chbv")!
        let date1 = Date(timeIntervalSince1970: 1710867940.787168)
        let counter1 = generator.counter(for: date1)
        let hashedAuthenticationCode1 = generator.hashedAuthenticationCode(for: counter1, key: key1)
        let offset1 = generator.targetOffsetOfHashedAuthenticationCode(hashedAuthenticationCode1)
        let codePart1 = generator.targetCodePartOfHashedAuthenticationCode(hashedAuthenticationCode1, offset: offset1)
        let digitMask1 = generator.digitMask
        let truncatedCode1 = generator.truncatingHashedAuthenticationCode(hashedAuthenticationCode1)
        let totpValue1 = TOTPValue(truncatedCode: truncatedCode1, using: generator)

        XCTAssertEqual(counter1, 57028931)
        XCTAssertEqual(hashedAuthenticationCode1.description, "HMAC with SHA1: cd9cd4dd72d1c6811a5d2ea1163c4c221471ff28")
        XCTAssertEqual(offset1, 8)
        XCTAssertEqual(String(codePart1, radix: 16), "1a5d2ea1")
        XCTAssertEqual(digitMask1, 1000000)
        XCTAssertEqual(truncatedCode1, 442314401)
        XCTAssertEqual(totpValue1.description, "314401")
    }

    func testMakeValue() throws {

        let generator = TOTPGenerator()
        let key1 = TOTPKey(base32encodedKey: "2a6h 5lw5 gz5t ko64 ukgp t5qt pqne chbv")!

        let date1 = Date(timeIntervalSince1970: 1710867940.787168)
        let date2 = Date(timeIntervalSince1970: 1711206002)
        
        let value1 = generator.makeValue(for: date1, secretKey: key1)
        let value2 = generator.makeValue(for: date2, secretKey: key1)
        
        XCTAssertEqual(key1.base32EncodedString, "2A6H5LW5GZ5TKO64UKGPT5QTPQNECHBV")
        
        XCTAssertEqual(value1.description, "314401")
        XCTAssertEqual(value1.prettyDescription, "314 401")
        XCTAssertEqual(value2.description, "750300")
        XCTAssertEqual(value2.prettyDescription, "750 300")
    }
}
