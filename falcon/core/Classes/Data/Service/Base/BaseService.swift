//
//  BaseService.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift

private let authorizationHeader = "Authorization"

private func value(_ headers: [AnyHashable: Any], for header: String) -> String? {

    return headers
        .filter({ entry in
            if let key = entry.key as? String {
                return key.caseInsensitiveCompare(header) == .orderedSame
            } else {
                return false
            }
        })
        .compactMap({ entry in entry.value as? String })
        .first
}

protocol APIConvertible where Output: Encodable {
    associatedtype Output

    func toJson() -> Output
}

protocol ModelConvertible {
    associatedtype Output

    func toModel() -> Output
}

public class BaseService {

    private let preferences: Preferences
    private let urlSession: URLSession
    private let sessionRepository: SessionRepository
    private let sendAuth: Bool

    lazy public var baseURL = getBaseURL()
    private static let maxRetries = 3

    init(preferences: Preferences,
         urlSession: URLSession,
         sessionRepository: SessionRepository,
         sendAuth: Bool) {
        self.preferences = preferences
        self.urlSession = urlSession
        self.sessionRepository = sessionRepository
        self.sendAuth = sendAuth
    }

    public func getBaseURL() -> String {
        fatalError("MUST OVERRIDE")
    }

    func get<T: Decodable>(_ path: String,
                           queryParams: [String: Any]? = [:],
                           andReturn model: T.Type,
                           maxRetries: Int = BaseService.maxRetries) -> Single<T> {
        return doRequest(.get, path, queryParams: queryParams, andReturn: model, maxRetries: maxRetries)
    }

    func post<T: Decodable>(_ path: String,
                            body: Data? = nil,
                            queryParams: [String: Any]? = [:],
                            andReturn model: T.Type,
                            maxRetries: Int = BaseService.maxRetries,
                            shouldForceDeviceCheckToken: Bool = false) -> Single<T> {
        return doRequest(.post,
                         path,
                         body: body,
                         queryParams: queryParams,
                         andReturn: model,
                         maxRetries: maxRetries,
                         shouldForceDeviceCheckToken: shouldForceDeviceCheckToken)
    }

    func patch<T: Decodable>(_ path: String,
                             body: Data? = nil,
                             queryParams: [String: Any]? = [:],
                             andReturn model: T.Type,
                             maxRetries: Int = BaseService.maxRetries) -> Single<T> {
        return doRequest(.patch, path, body: body, queryParams: queryParams, andReturn: model, maxRetries: maxRetries)
    }

    func put<T: Decodable>(_ path: String,
                           body: Data? = nil,
                           queryParams: [String: Any]? = [:],
                           andReturn model: T.Type,
                           maxRetries: Int = BaseService.maxRetries) -> Single<T> {
        return doRequest(.put, path, body: body, queryParams: queryParams, andReturn: model, maxRetries: maxRetries)
    }

    func delete<T: Decodable>(_ path: String,
                              body: Data? = nil,
                              queryParams: [String: Any]? = [:],
                              andReturn model: T.Type,
                              maxRetries: Int = BaseService.maxRetries) -> Single<T> {
        return doRequest(.delete, path, body: body, queryParams: queryParams, andReturn: model, maxRetries: maxRetries)
    }
}

private extension BaseService {
    func logRequest(_ request: BaseRequest) {

        Logger.log(.info, "")
        Logger.log(.info, "> ---")

        let method = request.request.httpMethod ?? "NO HTTP METHOD"
        let urlString = String(describing: request.request.url!)
        Logger.log(.info, "> \(method) \(urlString)")

        if let headers =  request.request.allHTTPHeaderFields {
            for header in headers {

                // Log all headers except authorization which is sensitive data
                guard header.key.caseInsensitiveCompare(authorizationHeader) != .orderedSame else {
                    continue
                }

                Logger.log(.info, "> \(header.key): \(header.value)")
            }
        }

        Logger.log(.info, "")

        if let b = request.request.httpBody {
            Logger.log(.info, "")

            guard let body = try? JSONSerialization.jsonObject(with: b, options: .allowFragments) else {
                return
            }

            Logger.log(.info, "\(body)")
        }

    }

    func logResponse(_ response: URLResponse, data: Data) {

        if let httpResponse = response as? HTTPURLResponse {

            Logger.log(.info, "")
            Logger.log(.info, "< ---")

            let statusCode = httpResponse.statusCode
            Logger.log(.info, "< \(statusCode)")

            for header in httpResponse.allHeaderFields {

                // Log all headers except authorization which is sensitive data
                guard let key = header.key as? String,
                    key.caseInsensitiveCompare(authorizationHeader) != .orderedSame else {
                    continue
                }

                Logger.log(.info, "< \(header.key): \(header.value)")
            }

            Logger.log(.info, "")

            guard let body = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                return
            }

            Logger.log(.info, "\(body)")
            Logger.log(.info, "")

        }
    }

    func log(_ request: BaseRequest, _ response: URLResponse?, _ data: Data?) {

        #if DEBUG
        self.logRequest(request)

        if let r = response, let d = data {
            self.logResponse(r, data: d)
        }
        #endif

    }

    func doRequest<T: Decodable>(_ method: HTTPMethod,
                                 _ path: String,
                                 body: Data? = nil,
                                 queryParams: [String: Any]? = [:],
                                 andReturn model: T.Type,
                                 maxRetries: Int = BaseService.maxRetries,
                                 shouldForceDeviceCheckToken: Bool = false) -> Single<T> {

        guard let url = URL(string: "\(self.baseURL)/\(path)") else {
            fatalError("URL NOT VALID")
        }

        var request = BaseRequest(url, method, body: body, queryParams: queryParams)
            .addHeader(key: "Content-Type", value: "application/json")
            .addHeader(key: "Accept", value: "application/json")
            .addHeader(key: "X-Client-Version", value: Constant.buildVersion)
            .addHeader(key: "X-Client-Version-Name", value: Constant.buildVersionName)
            .addHeader(key: "X-Client-Language", value: Locale.current.languageCode ?? "en")
            .addHeader(key: "X-Client-Type", value: "FALCON")
            .addHeader(key: "X-Idempotency-Key", value: UUID().uuidString)
            .addHeader(key: "X-Retry-Count", value: "1")

        if let backgroundExecutionMetrics = BackgroundExcecutionMetricsProvider.run() {
            request = request.addHeader(key: "X-Background-Execution-Metrics",
                                        value: backgroundExecutionMetrics)
        }

        if sendAuth {
            // Only send the authKey when necessary
            if let authKey = try? sessionRepository.getAuthToken() {
                request = request.addHeader(key: authorizationHeader, value: authKey)
            }
        }

        let tokenProvider = DeviceCheckTokenProvider.shared
        let token = tokenProvider.provide(ignoreRateLimit: shouldForceDeviceCheckToken)
        token.map { request = request.addHeader(key: "X-Device-Token", value: $0) }

        return Single.create { single in

            self.performHTTPRequest(request: request, model: model, maxRetries: maxRetries, success: { (response) in
                single(.success(response))
            }, failure: { (error) in
                single(.error(error))
            })

            return Disposables.create()
        }
    }

    func performHTTPRequest<T: Decodable>(request: BaseRequest,
                                                  model: T.Type,
                                                  maxRetries: Int,
                                                  success: @escaping (T) -> Void,
                                                  failure: @escaping (Error) -> Void) {
        let dataTask = self.urlSession.dataTask(with: request.request) { (data, response, error) in

            self.log(request, response, data)

            if let someError = self.parseError(data: data, error: error, response: response) {
                if self.shouldRetry(error: someError) && maxRetries > 1 {
                    Logger.log(.info, "Retrying...")
                    let newRequest = self.updateRetryCountHeader(request)

                    self.performHTTPRequest(request: newRequest,
                                            model: model,
                                            maxRetries: maxRetries - 1,
                                            success: success,
                                            failure: failure)

                } else {
                    failure(someError)
                }
                return
            }

            if let httpResp = response as? HTTPURLResponse {

                do {
                    _ = try self.sessionRepository.getAuthToken()
                } catch {
                    if let auth = value(httpResp.allHeaderFields, for: authorizationHeader) {
                        try? self.sessionRepository.storeAuthToken(auth)
                    }
                }

                if let sessionStatusString = value(httpResp.allHeaderFields, for: "X-Session-Status"),
                    let sessionStatus = SessionStatus(rawValue: sessionStatusString) {

                    self.sessionRepository.setStatus(sessionStatus)
                }

                let dataToParse: Data?
                if httpResp.statusCode == 204 {
                    dataToParse = "{}".data(using: .utf8)
                } else {
                    dataToParse = data
                }

                if let parsedResponse: T = self.parseData(data: dataToParse, model: model) {
                    success(parsedResponse)
                } else {
                    let decodedString = String(data: dataToParse ?? Data(), encoding: .utf8) ?? ""
                    Logger.log(
                        .warn,
                        """
                        Failed to decode object of type: \(model.self).
                        Decoded String: \(decodedString))
                        """
                    )
                    failure(MuunError(ServiceError.codableError))
                }
            }
        }

        dataTask.resume()
    }

    func updateRetryCountHeader(_ request: BaseRequest) -> BaseRequest {
        let retryCount = request.request.value(forHTTPHeaderField: "X-Retry-Count") ?? "1"
        let retryInt = Int(retryCount) ?? 1

        return request.updateHeader(key: "X-Retry-Count", value: String(describing: retryInt + 1))
    }

    func shouldRetry(error: Error) -> Bool {
        if let muunError = error as? MuunError, let e = muunError.kind as? ServiceError {
            switch e {

            case .serviceFailure, .timeOut:
                return true

            default:
                return false
            }
        }

        return false
    }

    func parseError(data: Data?, error: Error?, response: URLResponse?) -> Error? {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 500 {
                return MuunError(ServiceError.serviceFailure)
            }
        }

        if let e = error as? URLError {
            switch e.code {
            case .timedOut:
                return MuunError(ServiceError.timeOut)

            case .cannotFindHost,
                 .cannotConnectToHost,
                 .notConnectedToInternet,
                 .dataNotAllowed,
                 .networkConnectionLost,
                 .resourceUnavailable,
                 .secureConnectionFailed:
                return MuunError(ServiceError.internetError)

            default:
                return MuunError(e)
            }

        } else if let e = error {
            return MuunError(e)
        }

        guard let data = data else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .customISO8601
        do {
            let error = try jsonDecoder.decode(DeveloperError.self, from: data)
            return MuunError(ServiceError.customError(error))
        } catch {
            return nil
        }
    }

    func parseData<T: Decodable> (data: Data?, model: T.Type) -> T? {
        guard let data = data else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .customISO8601
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
