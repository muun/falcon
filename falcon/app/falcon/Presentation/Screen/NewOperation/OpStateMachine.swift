//
//  OpStateMachine.swift
//  falcon
//
//  Created by Juan Pablo Civile on 01/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum FeeState: Equatable {
    case finalFee(_ fee: BitcoinAmount, rate: FeeRate)
    case feeNeedsChange(displayFee: BitcoinAmount, rate: FeeRate)
    // Consider removing this from here and making this a throw wherever it goes 🤷‍♂️
    case noPossibleFee

    func getFeeAmount() -> BitcoinAmount? {
        switch self {
        case .finalFee(let btcAmount, _):
            return btcAmount
        default:
            return nil
        }
    }

    static func == (lhs: FeeState, rhs: FeeState) -> Bool {
        switch (lhs, rhs) {
        case (.finalFee(let lhsFee, let lhsRate), .finalFee(let rhsFee, let rhsRate)):
            return lhsFee.inSatoshis == rhsFee.inSatoshis && lhsRate == rhsRate
        case (.feeNeedsChange(let lhsFee, let lhsRate), .feeNeedsChange(let rhsFee, let rhsRate)):
            return lhsFee.inSatoshis == rhsFee.inSatoshis && lhsRate == rhsRate
        case (.noPossibleFee, .noPossibleFee):
            return true
        default:
            return false
        }
    }
}

protocol NewOpStateMachineDelegate: BasePresenterDelegate {
    func requestNextStep(_ data: NewOpState)
    func requestFinish(_ operation: core.Operation)

    func operationCompleted(_ operation: core.Operation)

    // Errors
    func operationError()
    func showExchangeRateWindowTooOldError()
    func notEnoughBalance(amountPlusFee: MonetaryAmount, totalBalance: MonetaryAmount)
    func expiredInvoice()
    func invalidAddress()
    func swapError(_ error: NewOpError)
    func amountBelowDust()
    func invoiceMissingAmount()
    func unexpectedError()

    func setExpires(_ expiresTime: Double)
    func cancel(confirm: Bool)
}

protocol NewOperationTransitions: AnyObject {
    func back()
}

protocol OpStateMachine: NewOperationTransitions {
    func setUp()
    func tearDown()
}

enum NewOpNextStep {
    case view(_ view: MUView, filledData: [MUView])
    case modal(_ viewController: MUViewController)
}

protocol OpViewBuilder {
    func getNextStep(state: NewOpState) -> NewOpNextStep
    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)?
    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool
}
