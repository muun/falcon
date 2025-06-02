//
//  NfcCardGroup.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

final class NfcCardGroup: BaseDebugExecutablesGroup {
    init() {
        let pairCard = CardPairingDebugExecutable()
        let unpairCard = CardUnpairingDebugExecutable()
        let signMessage = SignMessageDebugExecutable()

        super.init(category: "NFC Card",
                   executables: [pairCard,
                                unpairCard,
                                signMessage])
    }
}
