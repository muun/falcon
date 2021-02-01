//
//  Regtest.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

// This func is just too long
// swiftlint:disable function_body_length
@discardableResult
private func regtest(method: String, _ params: [Any]) -> [String: Any] {

    struct ValueEncodable: Encodable {

        let value: Any

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            if let value = value as? String {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? Int {
                try container.encode(value)
            } else if let value = value as? Decimal {
                try container.encode(value)
            }
        }
    }

    struct RPC: Encodable {
        let jsonrpc: String = "1.0"
        let id: String = "uitest"
        let method: String
        let params: [ValueEncodable]

        init(method: String, params: [ValueEncodable]) {
            self.method = method
            self.params = params
        }
    }

    let body = RPC(method: method, params: params.map(ValueEncodable.init(value: )))
    let encoder = JSONEncoder()

    let url = URL(string: "http://localhost:18443")!
    var request = URLRequest(url: url)
    request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
    // This was copied & pasted from curl
    request.addValue("Basic dXNlcjoxMjM=", forHTTPHeaderField: "Authorization")
    do {
        request.httpBody = try encoder.encode(body)
    } catch {
        preconditionFailure("Body must be encodable")
    }
    request.httpMethod = "POST"

    var out: [String: Any] = [:]
    let semaphore = DispatchSemaphore(value: 0)

    let task = URLSession.shared.dataTask(with: request) { (body, response, error) in

        if error != nil,
            let response = response as? HTTPURLResponse,
            response.statusCode != 200 {

            preconditionFailure("request failed")
        } else if let body = body,
            let response = try? JSONSerialization.jsonObject(with: body, options: []),
            let dictResponse = response as? [String: Any] {
            if let result = dictResponse["result"] as? [String: Any] {
                out = result
            } else if let result = dictResponse["result"] {
                out = ["result": result]
            }
        }

        semaphore.signal()
    }

    task.resume()
    semaphore.wait()

    return out
}
// swiftlint:enable function_body_length
