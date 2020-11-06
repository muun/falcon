//
//  GetKeySetAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 21/09/2020.
//

import Libwallet
import RxSwift

public class GetKeySetAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let storeKeySetAction: StoreKeySetAction

    init(houstonService: HoustonService, storeKeySetAction: StoreKeySetAction) {
        self.houstonService = houstonService
        self.storeKeySetAction = storeKeySetAction

        super.init(name: "GetKeySetAction")
    }

    public func run(recoveryCode: String) {
        let comp = self.houstonService.fetchKeySet()
            .do(onSuccess: { (keySet) in
                self.storeKeySetAction.run(keySet: keySet, userInput: recoveryCode)
            })
            .asCompletable()

        runCompletable(comp)
    }

}
