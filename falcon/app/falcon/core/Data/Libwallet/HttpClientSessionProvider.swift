//
//  Untitled.swift
//  falcon
//
//  Created by Juan Pablo Civile on 18/02/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Libwallet

class HttpClientSessionProvider: NSObject, App_provided_dataHttpClientSessionProviderProtocol {

    private let authTokenSchemePrefix = "Bearer"

    private let sessionRepository: SessionRepository
    private let preferences: Preferences
    private let houstonService: HoustonService
    private let backgroundExecutionMetricsProvider: BackgroundExecutionMetricsProvider
    private let deviceCheckTokenProvider: DeviceCheckTokenProvider

    init(sessionRepository: SessionRepository,
         preferences: Preferences,
         houstonService: HoustonService,
         backgroundExecutionMetricsProvider: BackgroundExecutionMetricsProvider,
         deviceCheckTokenProvider: DeviceCheckTokenProvider) {
        self.sessionRepository = sessionRepository
        self.preferences = preferences
        self.houstonService = houstonService
        self.backgroundExecutionMetricsProvider = backgroundExecutionMetricsProvider
        self.deviceCheckTokenProvider = deviceCheckTokenProvider
    }

    func session() throws -> App_provided_dataSession {
        let session = App_provided_dataSession()

        // In Falcon, the token is stored with the "Bearer " prefix, while in Apollo
        // the token is stored without it.
        // Since storing the token with the prefix is suboptimal, we remove it here
        // because the houston client of libwallet expects the raw token without the prefix.
        session.authToken = getBearerTokenWithoutPrefix()

        session.baseURL = houstonService.getBaseURL()
        session.clientType = "FALCON"
        session.clientVersion = Constant.buildVersion
        session.clientVersionName = Constant.buildVersionName
        session.language = Locale.current.languageCode ?? "en"
        if let backgroundExecutionMetrics = backgroundExecutionMetricsProvider.run() {
            session.backgroundExecutionMetrics = backgroundExecutionMetrics
        }
        if let token = deviceCheckTokenProvider.provide(ignoreRateLimit: false) {
            session.deviceToken = token
        }

        return session
    }

    func setSessionStatus(_ status: String?) {
        if let status = status,
           let sessionStatus = SessionStatus(rawValue: status) {
            sessionRepository.setStatus(sessionStatus)
        }
    }

    func setMinClientVersion(_ minClientVersion: String?) {
        // The body of this method is empty since FALCON does not store the minClientVersion
    }

    func setAuthToken(_ authToken: String?) {
        if let authToken = authToken,
           !authToken.isEmpty {
                do {
                    // In Falcon, the token is stored with the "Bearer " prefix, while in Apollo
                    // the token is stored without it.
                    // Although storing the token with the prefix is suboptimal, we must preserve this
                    // behavior because other parts of the Falcon app rely on the prefixed token.
                    try self.sessionRepository.storeAuthToken("\(authTokenSchemePrefix) \(authToken)")
                } catch {
                    Logger.log(error: error)
                }
            }
    }

    private func getBearerTokenWithoutPrefix() -> String {
        let authToken: String
        do {
            authToken = try sessionRepository.getAuthToken()
        } catch {
            authToken = ""
        }
        let prefixWithSpace = "\(authTokenSchemePrefix) "
        if authToken.range(of: prefixWithSpace, options: [.caseInsensitive, .anchored]) != nil {
            return String(authToken.dropFirst(prefixWithSpace.count))
        }
        return ""
    }

}
