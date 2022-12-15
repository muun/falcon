//
//  NewOpAmountPresenterTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 10/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun
import XCTest

class NewOpAmountPresenterTest: XCTestCase, PresenterInstantior, NewOpAmountPresenterDelegate {
    func showMessage(_ message: String) {
    }
    
    func pushTo(_ vc: Muun.MUViewController) {
    }

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    }

    
    lazy var presenter = instancePresenter(NewOpAmountPresenter.init, delegate: self)
    
    func test_ToSmallValueInUSD() {
//        XCTAssertEqual(presenter.validityCheck("9999999999999999999999999", currency: CurrencyHelper.allCurrencies["USD"]!), .tooBig)
        //TODO: Implement. This is tech debt because a error on this layer could create big issues
    }
    
    func test_ToBigValueInUSD() {
        //TODO: Implement
    }
    
    func test_ToSmallValueInBTC() {
        //TODO: Implement
    }
    
    func test_ToBigValueInBTC() {
        //TODO: Implement
    }
    
    func test_ToSmallValueInSAT() {
        //TODO: Implement
    }
    
    func test_ToBigValueInSAT() {
        //TODO: Implement
    }
}
