//
//  DeviceCheckTokenProvider.swift
//  core-all
//
//  Created by Lucas Serruya on 09/02/2023.
//

import DeviceCheck

public class DeviceCheckTokenProvider {
    public static let shared = DeviceCheckTokenProvider()

    private let refreshTimeInSedonds = 60;
    private var rateLimitedToken: String?
    private var cachedDeviceToken: String?
    private var timer: Timer?

    /// Provides device check token
    /// - parameter ignoreRateLimit: if *true* Token will be provided rotating value each 60 seconds unless DCDevice API is not supported by the device.
    /// If *false* after the token is provided you will need to wait 60 seconds to get a new one.
    func provide(ignoreRateLimit: Bool) -> String? {
        guard ignoreRateLimit else {
            let token = rateLimitedToken
            rateLimitedToken = nil
            return token
        }

        if DCDevice.current.isSupported && cachedDeviceToken == nil {
            Logger.log(error: NSError(domain: "device_check_persistent_token_not_found",
                                      code: 1))
        }

        return cachedDeviceToken
    }

    public func start() {
        checkForToken()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshTimeInSedonds),
                                     target: self,
                                     selector: #selector(self.checkForToken),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc
    private func checkForToken() {
        guard rateLimitedToken == nil, DCDevice.current.isSupported else {
            return
        }

        DCDevice.current.generateToken { token, error in
            guard let cachedTokenBetweenPeriods = token, error == nil else {
                error.map { Logger.log(error: $0) }
                return
            }
            let encodedDeviceToken = cachedTokenBetweenPeriods.base64EncodedString()
            self.rateLimitedToken = encodedDeviceToken
            self.cachedDeviceToken = encodedDeviceToken
        }
    }
}
