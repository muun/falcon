//
//  SendEncryptedKeysEmailAction.swift
//  core
//
//  Created by Manu Herrera on 17/10/2019.
//

import Foundation

public class SendEncryptedKeysEmailAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let encryptedUserKeySelector: EncryptedUserKeySelector

    init(houstonService: HoustonService, encryptedUserKeySelector: EncryptedUserKeySelector) {
        self.houstonService = houstonService
        self.encryptedUserKeySelector = encryptedUserKeySelector

        super.init(name: "SendEncryptedKeysEmailAction")
    }

    public func run() {
        let key = encryptedUserKeySelector.get()
        let single = key.flatMap { encryptedKey in
            self.houstonService.sendEncryptedKeysEmail(encryptedKey: SendEncryptedKeys(userKey: encryptedKey))
        }
        runSingle(single)
    }

}
