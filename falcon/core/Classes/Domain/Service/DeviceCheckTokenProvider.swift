//
//  DeviceCheckTokenProvider.swift
//  core-all
//
//  Created by Lucas Serruya on 09/02/2023.
//

public class DeviceCheckTokenProvider {
    private let refreshTimeInSeconds: TimeInterval = 60
    private let paranoidRefreshTimeInSeconds: TimeInterval = 10
    private let attemptsLeftToGenerateTokenOnRequestSucceed = 1
    private var attemptsBurnToGenerateTokenOnRequestSucceed = 0
    private var rateLimitedToken: String?
    private var cachedDeviceToken: String?
    private let deviceCheckAdapter: DeviceCheckAdapter
    private let timer: MUTimer

    init(deviceCheckAdapter: DeviceCheckAdapter, timer: MUTimer) {
        self.deviceCheckAdapter = deviceCheckAdapter
        self.timer = timer
    }

    /// Provides device check token
    /// - parameter ignoreRateLimit: if *true* Token will be provided rotating value each 60 seconds unless DCDevice API is not supported by the device.
    /// If *false* after the token is provided you will need to wait 60 seconds to get a new one.
    func provide(ignoreRateLimit: Bool) -> String? {
        guard ignoreRateLimit else {
            let token = rateLimitedToken
            rateLimitedToken = nil
            return token
        }

        if deviceCheckAdapter.isSupported() && cachedDeviceToken == nil {
            Logger.log(error: NSError(domain: "device_check_persistent_token_not_found",
                                      code: 1))
        }

        return cachedDeviceToken
    }

    public func start() {
        guard deviceCheckAdapter.isSupported() else {
            return
        }
        checkForToken()
    }

    func reactToRequestSucceded() {
        // Check for paranoid mode so I don't have a race condition with first token generation
        // already triggered by didFinishLaunchWithOptions.
        if isInParanoidMode() && hasReachedMaxAttemptsForRequestSucceed() {
            attemptsBurnToGenerateTokenOnRequestSucceed += 1
            checkForToken()
        }
    }

    public func reactToForegroundAppState() {
        // Check for paranoid mode so I don't have a race condition with first token generation
        // already triggered by didFinishLaunchWithOptions.
        if isInParanoidMode() {
            checkForToken()
        }
    }
}

private extension DeviceCheckTokenProvider {
    func autoRefreshTokenNormalMode() {
        guard !isInNormalMode() else {
            return
        }

        startTimer(refreshTime: refreshTimeInSeconds)
    }

    func autoRefreshTokenParanoidMode() {
        guard !isInParanoidMode() else {
            return
        }
        startTimer(refreshTime: paranoidRefreshTimeInSeconds)
    }

    @objc
    func checkForToken() {
        guard rateLimitedToken == nil, deviceCheckAdapter.isSupported() else {
            return
        }

        deviceCheckAdapter.generateToken { token, error in
            guard let cachedTokenBetweenPeriods = token, error == nil else {
                error.map { Logger.log(error: $0) }
                if self.neverSuccededGeneratingAToken() {
                    self.autoRefreshTokenParanoidMode()
                }
                return
            }
            let encodedDeviceToken = cachedTokenBetweenPeriods.base64EncodedString()
            self.rateLimitedToken = encodedDeviceToken
            self.cachedDeviceToken = encodedDeviceToken
            self.autoRefreshTokenNormalMode()
        }
    }

    func startTimer(refreshTime: TimeInterval) {
        timer.stop()
        timer.start(timeInterval: refreshTime,
                    target: self,
                    selector: #selector(self.checkForToken),
                    repeats: true)
    }

    func neverSuccededGeneratingAToken() -> Bool {
        return cachedDeviceToken == nil
    }

    func isInParanoidMode() -> Bool {
        timer.timeInterval == paranoidRefreshTimeInSeconds
    }

    func isInNormalMode() -> Bool {
        timer.timeInterval == refreshTimeInSeconds
    }

    private func hasReachedMaxAttemptsForRequestSucceed() -> Bool {
        return attemptsBurnToGenerateTokenOnRequestSucceed < attemptsLeftToGenerateTokenOnRequestSucceed
    }
}
