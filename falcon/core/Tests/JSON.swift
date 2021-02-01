//
//  JSON.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 05/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest
import core
class JSON: XCTestCase {

    func testEncodeDecode() throws {

        let date = Date.init(timeIntervalSince1970: 10).addingTimeInterval(0.001)
        let model = TestEncodable(date: date)

        let data = JSONEncoder.data(json: model)
        guard let decoded: TestEncodable = JSONDecoder.model(from: data) else {
            XCTFail("decoded is nil")
            return
        }

        // Keep in mind that by default date doesn't print milliseconds so if this fails
        // it will print the same date on both sides.
        XCTAssertEqual(model.date, decoded.date)
    }

    func testDecodeDate() throws {
        let originData = "{\"date\":\"2020-03-02T23:02:03.456Z\"}".data(using: .utf8)!
        guard let decoded: TestEncodable = JSONDecoder.model(from: originData) else {
            XCTFail("decoded is nil")
            return
        }

        let data = JSONEncoder.data(json: decoded)
        XCTAssertEqual(data, originData)
    }

}

private struct TestEncodable: Codable {
    let date: Date
}
