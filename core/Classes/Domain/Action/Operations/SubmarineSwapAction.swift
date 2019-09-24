//
//  SubmarineSwapAction.swift
//  falcon
//
//  Created by Manu Herrera on 05/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public class SubmarineSwapAction: AsyncAction<(SubmarineSwap)> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository

    init(houstonService: HoustonService, keysRepository: KeysRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository

        super.init(name: "SubmarineSwapAction")
    }

    public func run(invoice: String) {
        runSingle(
            houstonService.prepareSubmarineSwap(invoice: invoice)
                .map({ swap in
                    let isValid = try doWithError({ err in
                        LibwalletValidateSubmarineSwap(invoice,
                                                       try self.keysRepository.getBasePublicKey().key,
                                                       try self.keysRepository.getCosigningKey().key,
                                                       swap,
                                                       Environment.current.network,
                                                       err)
                    })

                    if isValid {
                        return swap
                    } else {
                        throw MuunError(Errors.invalidSwap)
                    }
                })
        )
    }

    enum Errors: Error {
        case invalidSwap
    }

}
