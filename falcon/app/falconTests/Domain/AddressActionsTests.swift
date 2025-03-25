//
//  AddressActionsTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 08/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

import RxSwift

@testable import Muun

class AddressActionsTests: MuunTestCase {
    
    override func setUp() {
        super.setUp()
        
        // TODO: Setup user private key and muun cosigning key
        let keyRepository: KeysRepository = resolve()

        let muunKey = WalletPublicKey.fromBase58("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB", on: DerivationSchema.external.path)
        let swapServerKey = WalletPublicKey.fromBase58("xpub6DE1bvvTaMkDaAghedChtufg3rDPeYdWt9sM5iTwBVYe9X6bmLenQrSexSa1qDscYtidSMUEo9u7TuXg48Y3hBXQr7Yw8zUaEToH1rVgvif", on: DerivationSchema.external.path)
        let userKey = WalletPrivateKey.fromBase58("xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi", on: DerivationSchema.base.path)
        
        keyRepository.store(cosigningKey: muunKey)
        keyRepository.store(swapServerKey: swapServerKey)
        try! keyRepository.store(key: userKey)
        
        _ = try! keyRepository.getBasePrivateKey()
    }
    
    func testAfterSignUp() throws {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)

        let addressActions: AddressActions = resolve()
        let keyRepository: KeysRepository = resolve()
        let syncExternalAddresses: SyncExternalAddresses = resolve()
        
        // Mimic sign up
        keyRepository.updateMaxUsedIndex(0)
        keyRepository.updateMaxWatchingIndex(10)
        
        _ = try addressActions.generateExternalAddresses()
        wait(for: syncExternalAddresses.getValue())
        
        XCTAssertEqual(keyRepository.getMaxUsedIndex(), 1)
        XCTAssertEqual(keyRepository.getMaxWatchingIndex(), 11)
        XCTAssertEqual(fake.updateCalls, 1)
    }
    
    func testRandomAddress() throws {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        let addressActions: AddressActions = resolve()
        let keyRepository: KeysRepository = resolve()
        let syncExternalAddresses: SyncExternalAddresses = resolve()
        
        // Mimic sign up
        keyRepository.updateMaxUsedIndex(10)
        keyRepository.updateMaxWatchingIndex(10)
        
        _ = try addressActions.generateExternalAddresses()
        expectTimeout(for: syncExternalAddresses.getValue())
        
        XCTAssertEqual(keyRepository.getMaxUsedIndex(), 10)
        XCTAssertEqual(keyRepository.getMaxWatchingIndex(), 10)
        XCTAssertEqual(fake.updateCalls, 0)
    }
}
