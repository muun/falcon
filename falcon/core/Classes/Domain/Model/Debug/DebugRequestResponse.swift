//
//  DebugRequestResponse.swift
//  core-all
//
//  Created by Lucas Serruya on 21/09/2023.
//

import Foundation

public struct DebugRequestResponse {
    public var statusCode: Int? = nil
    public var headers: [AnyHashable: Any]? = nil
    public var responseBody: String? = nil
    public var error: Error? = nil

    init(response: URLResponse?, data: Data?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            self.statusCode = httpResponse.statusCode
            self.headers = httpResponse.allHeaderFields.filter({ header in
                header.key as? String != "Authorization"
            })

            if let data = data,
                let responseBody = try? JSONSerialization.jsonObject(with: data,
                                                                     options: .allowFragments) {
                self.responseBody = "\(responseBody)"
            }
        }

        self.error = error
    }
}
