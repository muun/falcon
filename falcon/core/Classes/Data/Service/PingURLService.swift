//
//  PingDomainService.swift
//  core-all
//
//  Created by Lucas Serruya on 26/10/2023.
//

import Foundation
import RxSwift

class PingURLService {
    func run(url: String) -> Single<Bool> {
        return Single.create { callback in
            let url = URL(string: url)

            let urlSessionConfig = URLSessionConfiguration.default
            urlSessionConfig.timeoutIntervalForRequest = 10.0
            let urlSession = URLSession(configuration: urlSessionConfig)

            let task = urlSession.dataTask(with: url!) { data, response, error in
                if let error = error as? URLError,
                   (error.code == .timedOut || error.code == .notConnectedToInternet) {
                    callback(.success(false))
                } else {
                    callback(.success(true))
                }
            }

            task.resume()
            return Disposables.create()
        }
    }
}
