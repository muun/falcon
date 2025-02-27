//
//  DebugRequestResponse.swift
//
//  Created by Lucas Serruya on 21/09/2023.
//

import Foundation

public struct DebugRequestResponse {
    public var statusCode: Int?
    public var headers: [AnyHashable: Any]?
    public var responseBody: String?
    public var error: Error?

    init(response: URLResponse?, data: Data?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            self.statusCode = httpResponse.statusCode
            self.headers = httpResponse.allHeaderFields.filter({ header in
                header.key as? String != "Authorization"
            })
            // swiftlint:disable force_error_handling
            if let data = data,
                let responseBody = try? JSONSerialization.jsonObject(with: data,
                                                                     options: .allowFragments) {
                self.responseBody = "\(responseBody)"
            }
        }

        self.error = error
    }
}
