//
//  IncomingSwapRepositoryTests.swift
//  falconTests
//
//  Created by Federico Bond on 14/01/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import XCTest
import Firebase

@testable import Muun

class IncomingSwapRepositoryTests: MuunTestCase {

    var incomingSwapRepository: IncomingSwapRepository!

    override func setUp() {
        super.setUp()
        incomingSwapRepository = resolve()
    }

    func testUpdateSetsSwapPreimage() {
        let incomingSwap = Factory.incomingSwap(uuid: "1234")
        wait(for: incomingSwapRepository.write(objects: [incomingSwap]))

        XCTAssertNil(incomingSwap.preimage)

        wait(for: incomingSwapRepository.update(preimage: Data(hex: "deadbeef"), for: incomingSwap))

        let swap = incomingSwapRepository.object(with: "1234")!
        XCTAssertEqual(swap.preimage, Data(hex: "deadbeef"))
    }

    func testWriteAlsoWritesHtlcs() {
        let incomingSwap = Factory.incomingSwap(uuid: "4567")
        wait(for: incomingSwapRepository.write(objects: [incomingSwap]))

        let storedSwap = incomingSwapRepository.object(with: "4567")

        guard let swap = storedSwap else {
            XCTFail("expected swap to be found")
            return
        }
        XCTAssertNotNil(incomingSwap.htlc)
        XCTAssertEqual(swap.htlc!.uuid, incomingSwap.htlc!.uuid)
    }
}
