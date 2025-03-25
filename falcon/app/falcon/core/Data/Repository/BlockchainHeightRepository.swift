//
//  BlockchainHeightRepository.swift
//
//  Created by Manu Herrera on 24/09/2019.
//

import Foundation
import RxSwift

public class BlockchainHeightRepository {

    private let preferences: Preferences

    public init(preferences: Preferences) {
        self.preferences = preferences
    }

    func setBlockchainHeight(_ blockchainHeight: Int) {
        preferences.set(value: blockchainHeight, forKey: .blockchainHeight)
    }

    public func getCurrentBlockchainHeight() -> Int {
        return preferences.integer(forKey: .blockchainHeight)
    }

    public func watch() -> Observable<Int?> {
        return preferences.watchInteger(key: .blockchainHeight)
    }

}
