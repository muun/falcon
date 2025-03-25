//
//  NewOpAmountView.swift
//  falcon
//
//  Created by Manu Herrera on 17/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit


protocol OpAmountTransitions: NewOperationTransitions {
    func didEnter(amount: BitcoinAmount, data: NewOperationStateLoaded, takeFeeFromAmount: Bool)
    func requestCurrencyPicker(data: NewOperationStateLoaded, currency: Currency)
}

class NewOpAmountView: MUView, PresenterInstantior {

    @IBOutlet private weak var inputContainerView: UIView!
    @IBOutlet private weak var allFundsButton: LinkButtonView!
    private var amountInputView: AmountInputView!

    weak var delegate: NewOpViewDelegate?
    weak var transitionsDelegate: OpAmountTransitions?
    private let data: NewOperationStateLoaded
    private var useAllFunds = false
    private var inputCurrency: Currency {
        return amountInputView.currency
    }

    fileprivate lazy var presenter = instancePresenter(NewOpAmountPresenter.init, delegate: self, state: data)

    init(data: NewOpData.Amount,
         delegate: NewOpViewDelegate?,
         transitionsDelegate: OpAmountTransitions?) {
        self.data = data
        self.delegate = delegate
        self.transitionsDelegate = transitionsDelegate

        super.init(frame: CGRect.zero)

        updateUI(data: data)
        validate(amount: amountInputView.value)
        delegate?.update(buttonText: L10n.NewOpAmountView.s1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
            _ = amountInputView.becomeFirstResponder()
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            presenter.tearDown()
        } else {
            presenter.setUp()
        }
    }

    override func setUp() {
        super.setUp()

        setUpView()
        makeViewTestable()
    }

    private func setUpView() {
        setUpAllFundsButton()
        setUpAmountView()
    }

    private func setUpAmountView() {
        amountInputView = AmountInputView(delegate: self, converter: presenter.convert)
        amountInputView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(amountInputView)

        NSLayoutConstraint.activate([
            amountInputView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            amountInputView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            amountInputView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
            amountInputView.topAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }

    private func setUpAllFundsButton() {
        allFundsButton.buttonText = L10n.NewOpAmountView.s3
        allFundsButton.delegate = self
    }

    func updateUI(data: NewOpData.Amount) {
        presenter.data = data
        // NOTE: it's important that we set the currency before the value to avoid
        // unwanted currency conversions.

        amountInputView.currency = data.selectedCurrency

        let currency = data.selectedCurrency

        if data.amount.inSatoshis.asDecimal() > 0 {
            amountInputView.value = data.amount.inInputCurrency.toAmountWithoutCode(btcCurrencyFormat: .short,
                                                                                    currencyOfAmount: currency)
        }

        let amount = data.totalBalance.inInputCurrency.toAmountWithoutCode(currencyOfAmount: currency)
        amountInputView?.subtitle = L10n.NewOpAmountView.s2(
            amount,
            currency.displayCode
        )

        allFundsButton.isEnabled = data.totalBalance.inSatoshis > Satoshis.zero

        validate(amount: amountInputView.value)
    }

    func validate(amount: String) {
        let newState = presenter.validityCheck(amount, currency: inputCurrency)

        amountInputView.state = newState
        switch newState {
        case .zero:
            delegate?.readyForNextState(false, error: nil)

        case .tooBig:
            delegate?.readyForNextState(false, error: L10n.NewOpAmountView.s4)

        case .tooSmall:
            delegate?.readyForNextState(false, error: L10n.NewOpAmountView.s5)

        case .valid:
            delegate?.readyForNextState(true, error: nil)
        }
    }
}

extension NewOpAmountView: NewOperationChildView {

    var willDisplayKeyboard: Bool {
        return true
    }

}

extension NewOpAmountView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        let totalBalanceAmount = presenter.totalBalance(in: inputCurrency.code).amount
        let allFundsString = inputCurrency.toAmountWithoutCode(amount: totalBalanceAmount,
                                                           btcCurrencyFormat: .long)
        amountInputView.value = allFundsString
        useAllFunds = true

        pushNextState()
    }

}

extension NewOpAmountView: AmountInputViewDelegate {

    func didInput(amount: String, currency: Currency) {
        useAllFunds = false
        validate(amount: amount)
    }

    func didTapCurrency() {
        transitionsDelegate?.requestCurrencyPicker(data: data, currency: inputCurrency)
    }

}

extension NewOpAmountView: NewOperationChildViewDelegate {

    func pushNextState() {
        let input = amountInputView.value
        let amount: BitcoinAmount
        let isUsingAllFunds = useAllFunds || presenter.isSendingAllFundsManually(value: input, currency: inputCurrency)

        if isUsingAllFunds {
            amount = presenter.allFunds(in: inputCurrency.code)
        } else {
            amount = presenter.amount(from: input, in: inputCurrency)
        }

        transitionsDelegate?.didEnter(amount: amount, data: data, takeFeeFromAmount: isUsingAllFunds)
    }

}

extension NewOpAmountView: NewOpAmountPresenterDelegate {}

extension NewOpAmountView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp.AmountView

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(allFundsButton, using: .useAllFunds)
        makeViewTestable(amountInputView, using: .input)
    }
}
