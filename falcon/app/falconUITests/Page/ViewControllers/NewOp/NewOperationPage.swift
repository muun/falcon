//
//  NewOperationPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class NewOperationPage: UIElementPage<UIElements.Pages.NewOp> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)
    private lazy var amountFilledDataLabel = button(.amountFilledData)
    private lazy var feeFilledDataLabel = button(.feeFilledData)
    private lazy var feeView = button(.feeView)
    private lazy var descriptionFilledDataLabel = label(.descriptionFilledData)
    private lazy var destinationFilledDataLabel = label(.destinationFilledData)

    init() {
        super.init(root: Root.root)
    }

    /// Tap the continue button
    /// This won't return a new Page like in other cases since it's allways contextual where we go
    func touchContinueButton() {
        continueButton.wait(1)
        continueButton.mainButtonTap()
    }

    func touchEditFee() -> SelectFeePage {
        feeView.tap()
        return SelectFeePage()
    }

    func waitForConfirm() {
        _ = destinationFilledDataLabel.waitForExistence(timeout: 2)
    }

    func isContinueEnabled() -> Bool {
        return continueButton.isEnabled()
    }

    func hasAmountFilledData() -> Bool {
        return amountFilledDataLabel.exists
    }

    func hasDescriptionFilledData() -> Bool {
        return descriptionFilledDataLabel.exists
    }

    func hasDestinationFilledData() -> Bool {
        return destinationFilledDataLabel.exists
    }

    func hasAmountAndFeeFilledData() -> Bool {
        return amountFilledDataLabel.exists && feeFilledDataLabel.exists
    }

    // swiftlint:disable large_tuple
    func filledData() -> (to: String, amount: String, fee: String, description: String) {

        func amount(_ from: String) -> String {
            return String(from.split(separator: " ").first!)
        }

        return (destinationFilledDataLabel.label,
                amount(amountFilledDataLabel.label),
                amount(feeFilledDataLabel.label),
                descriptionFilledDataLabel.label)
    }
    // swiftlint:enable large_tuple

    func selectMediumFee() {
        let selectFeePage = touchEditFee()
        selectFeePage.selectFee(index: 2)
    }

    func manuallyEnterFee(amount: Decimal) {
        let selectFeePage = touchEditFee()
        let manuallyEnterFeePage = selectFeePage.tapEnterFeeManually()
        manuallyEnterFeePage.checkWarnings()
        manuallyEnterFeePage.changeFee(satsPerVByte: amount)
    }
}
