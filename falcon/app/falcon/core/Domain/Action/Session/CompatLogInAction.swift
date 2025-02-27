//
//  CompatLogInAction.swift
//  Created by Manu Herrera on 03/11/2020.
//

import Foundation
import RxSwift

public class CompatLogInAction: AsyncAction<KeySet> {

    private let houstonService: HoustonService
    private let storeKeySetAction: StoreKeySetAction
    private let setUpChallengeAction: SetupChallengeAction

    init(houstonService: HoustonService,
         storeKeySetAction: StoreKeySetAction,
         setUpChallengeAction: SetupChallengeAction) {
        self.houstonService = houstonService
        self.storeKeySetAction = storeKeySetAction
        self.setUpChallengeAction = setUpChallengeAction

        super.init(name: "CompatLogInAction")
    }

    public func run(userInput: String) {
        let single: Single<KeySet> = houstonService.loginCompatWithoutChallenge()
            .flatMap({ keySet -> Single<KeySet> in
                self.storeKeySetAction.run(keySet: keySet, userInput: userInput)
                return Single.just(keySet)
            })
            .flatMap({ keySet in
                self.setUpChallengeAction.run(type: .PASSWORD, userInput: userInput)
                // We need this to be sync
                return self.setUpChallengeAction.getValue().flatMap({ _ in Single.just(keySet) })
            })

        runSingle(single)

    }

}
