//
//  AuthorizeRCLoginAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 21/09/2020.
//

import Foundation
import RxSwift

public class AuthorizeRCLoginAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let preferences: Preferences

    public init(houstonService: HoustonService,
                preferences: Preferences) {
        self.houstonService = houstonService
        self.preferences = preferences

        super.init(name: "AuthorizeRCLoginAction")
    }

    public func run(uuid: String) {
        runSingle(houstonService.authorizeLoginWithRecoveryCode(linkAction: LinkAction(uuid: uuid))
            .flatMap({ [weak self] () in
                self?.preferences.set(value: true, forKey: .hasResolvedARcChallenge)
                self?.preferences.set(value: true, forKey: .welcomeMessageSeen)
                return Single.just(())
        }))
    }

}
