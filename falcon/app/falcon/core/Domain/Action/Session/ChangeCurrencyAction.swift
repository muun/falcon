//
//  ChangeCurrencyAction.swift
//  falcon
//
//  Created by Manu Herrera on 03/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public class ChangeCurrencyAction: AsyncAction<User> {

    private let houstonService: HoustonService
    private let userRepository: UserRepository

    init(houstonService: HoustonService, userRepository: UserRepository) {
        self.houstonService = houstonService
        self.userRepository = userRepository

        super.init(name: "ChangeCurrencyAction")
    }

    public func run(user: User) {
        runSingle(houstonService.updateCurrency(user: user).do(onSuccess: { (user) in
            self.userRepository.setUser(user)
        }))
    }

}
