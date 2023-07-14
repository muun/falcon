//
//  ICloudCapabilitiesProvider.swift
//  core-all
//
//  Created by Juan Pablo Civile on 12/07/2023.
//

import Foundation
import CloudKit

public class ICloudCapabilitiesProvider {

    private let keychainRepository: KeychainRepository
    private let key = KeychainRepository.storedKeys.iCloudRecordId.rawValue

    init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    public func setup() {
        if (try? keychainRepository.has(key)) ?? false {
            return
        }

        CKContainer.default().fetchUserRecordID { userRecord, err in
            if let err = err {
                Logger.log(error: err)
                return
            }

            guard let userRecord = userRecord else {
                Logger.log(.err, "Got nil userRecord with nil error")
                return
            }

            try? self.keychainRepository.store(userRecord.recordName, at: self.key)
        }
    }

    public func fetchRecordId() -> String? {
        return try? keychainRepository.get(key)
    }
}
