//
//  BaseRequest.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

// We should reconsider using URLRequest instead of BaseRequest

import Foundation

class BaseRequest {

    private var url: URL
    private var method: HTTPMethod
    private var body: Data?
    private var queryParams: [String: Any]?

    public var request: URLRequest

    public init(_ url: URL,
                _ method: HTTPMethod,
                body: Data? = nil,
                queryParams: [String: Any]? = nil) {

        self.url = url
        self.method = method
        self.queryParams = queryParams
        self.body = body

        if let qp = queryParams, qp.count > 0 {

            var urlComponents = URLComponents(string: self.url.absoluteString)!
            urlComponents.queryItems = []

            for item in qp {
                let queryItem = URLQueryItem(name: item.key, value: String(describing: item.value))
                urlComponents.queryItems?.append(queryItem)
            }

            self.url = urlComponents.url!

        }

        request = URLRequest(url: self.url, timeoutInterval: Constant.requestTimeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = body

    }

    public func addHeader(key: String, value: String) -> Self {
        request.addValue(value, forHTTPHeaderField: key)

        return self
    }

    func updateHeader(key: String, value: String) -> Self {
        request.setValue(value, forHTTPHeaderField: key)

        return self
    }

}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
