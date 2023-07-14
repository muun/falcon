//
//  CreateRCLoginSessionAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 09/09/2020.
//

import Foundation
import Libwallet
import RxSwift

public class CreateRCLoginSessionAction: AsyncAction<Challenge> {

    private let houstonService: HoustonService
    private let logoutAction: LogoutAction
    private let preferences: Preferences
    private let clientSelector: ClientSelector

    init(houstonService: HoustonService,
         logoutAction: LogoutAction,
         preferences: Preferences,
         clientSelector: ClientSelector) {
        self.preferences = preferences
        self.houstonService = houstonService
        self.logoutAction = logoutAction
        self.clientSelector = clientSelector

        super.init(name: "CreateRCLoginSessionAction")
    }

    public func run(gcmToken: String, recoveryCode: String) {
        // We have to wipe everything to avoid edgy bugs with the notifications
        logoutAction.run(notifyHouston: false)

        do {
            let rc = try RecoveryCode(code: recoveryCode)
            if rc.version == 1 {
                throw MuunError(Errors.invalidRCVersion)
            }

            let createRcSession = CreateRcLoginSession(
                client: clientSelector.run(),
                gcmToken: gcmToken,
                challengeKey: try rc.toKey()
            )
            runSingle(houstonService.createRecoveryCodeLoginSession(createRcSession).flatMap { [weak self] challenge in
                self?.preferences.set(value: true, forKey: .hasResolvedARcChallenge)
                self?.preferences.set(value: true, forKey: .welcomeMessageSeen)
                return Single.just(challenge)
            })

        } catch {
            runSingle(Single.error(error))
        }

    }

    enum Errors: Error {
        case invalidRCVersion
    }

}
