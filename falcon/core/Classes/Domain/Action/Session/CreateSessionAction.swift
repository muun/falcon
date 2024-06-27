//
//  CreateSessionAction.swift
//  falcon
//
//  Created by Manu Herrera on 14/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class CreateSessionAction: AsyncAction<CreateSessionOk> {

    private let houstonService: HoustonService
    private let logoutAction: LogoutAction
    private let preferences: Preferences
    private let clientSelector: ClientSelector

    init(houstonService: HoustonService,
                logoutAction: LogoutAction,
                preferences: Preferences,
                clientSelector: ClientSelector) {
        self.houstonService = houstonService
        self.logoutAction = logoutAction
        self.preferences = preferences
        self.clientSelector = clientSelector

        super.init(name: "CreateSessionAction")
    }

    public func run(email: String, gcmToken: String?) {
        // We have to wipe everything to avoid edgy bugs with the notifications
        logoutAction.run(notifyHouston: false)
        self.preferences.set(value: false, forKey: .hasResolvedARcChallenge)
        self.preferences.set(value: false, forKey: .welcomeMessageSeen)
        let session = CreateLoginSession(
            client: clientSelector.run(),
            email: email,
            gcmToken: gcmToken
        )

        let single = logoutAction.getValue()
            .catchErrorJustReturn(()) // If logout fails, it's all cool
            .flatMap { _ in
                return self.houstonService.createSession(session: session)
            }.do(onSuccess: { _ in
                self.preferences.set(value: session.email, forKey: .email)
            })

        runSingle(single)
    }

}
