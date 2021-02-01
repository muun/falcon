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

    init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "CreateRCLoginSessionAction")
    }

    public func run(gcmToken: String, recoveryCode: String) {

        do {
            let rc = try RecoveryCode(code: recoveryCode)
            if rc.version == 1 {
                throw MuunError(Errors.invalidRCVersion)
            }

            let createRcSession = CreateRcLoginSession(
                client: Client.buildCurrent(),
                gcmToken: gcmToken,
                challengeKey: try rc.toKey()
            )
            runSingle(houstonService.createRecoveryCodeLoginSession(createRcSession))

        } catch {
            runSingle(Single.error(error))
        }

    }

    enum Errors: Error {
        case invalidRCVersion
    }

}
