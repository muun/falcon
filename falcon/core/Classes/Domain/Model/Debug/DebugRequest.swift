//
//  DebugRequest.swift
//  core-all
//
//  Created by Lucas Serruya on 21/09/2023.
//

import Foundation

public struct DebugRequest {
    public let url: String
    public let method: String
    public var headers: [String : String]? = nil
    public var body: String? = nil

    public let response: DebugRequestResponse

    init(request: BaseRequest, response: URLResponse?, data: Data?, error: Error?) {
        self.url = String(describing: request.request.url!)
        self.method = request.request.httpMethod ?? "NO HTTP METHOD"
        self.headers = request.request.allHTTPHeaderFields?.filter({ header in
            header.key != "Authorization"
        })
        if let b = request.request.httpBody,
           let body = try? JSONSerialization.jsonObject(with: b, options: .allowFragments) {
            self.body = "\(body)"
        }

        self.response = DebugRequestResponse(response: response, data: data, error: error)
    }
}
