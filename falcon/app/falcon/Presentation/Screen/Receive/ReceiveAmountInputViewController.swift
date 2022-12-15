//
//  ReceiveAmountInputViewController.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol ReceiveAmountInputViewControllerDelegate: AnyObject {
    func didConfirm(bitcoinAmount: BitcoinAmountWithSelectedCurrency?)
}

class ReceiveAmountInputViewController: MUViewController {

    private var amountInput: AmountInputView!
    private let confirmButton = ButtonView()
    private var bottomAnchorOnSafeArea: NSLayoutYAxisAnchor {
        view.safeAreaLayoutGuide.bottomAnchor
    }
    private lazy var bottomConstraint = confirmButton.bottomAnchor.constraint(equalTo: bottomAnchorOnSafeArea)

    private weak var delegate: ReceiveAmountInputViewControllerDelegate?

    private lazy var presenter = instancePresenter(ReceiveAmountInputPresenter.init, delegate: self)

    private var initialAmount: MonetaryAmountWithCompleteDataOfCurrency?

    private let receiveType: ReceiveType

    init(delegate: ReceiveAmountInputViewControllerDelegate,
         amount: MonetaryAmountWithCompleteDataOfCurrency?,
         receiveType: ReceiveType) {

        self.delegate = delegate
        self.initialAmount = amount
        self.receiveType = receiveType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override var screenLoggingName: String {
        return "receive_amount_input"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch receiveType {
        case .lightning:
            title = L10n.ReceiveAmountInputViewController.titleLightning
        case .onChain:
            title = L10n.ReceiveAmountInputViewController.titleOnChain
        case .unified:
            title = L10n.ReceiveAmountInputViewController.editAmount
        }

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addClipboardObserver()
        addKeyboardObservers()

        _ = amountInput.becomeFirstResponder()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeClipboardObserver()
        removeKeyboardObservers()

        presenter.tearDown()
    }

    private func setUpView() {
        let amountContainerView = UIView()
        amountContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountContainerView)

        amountInput = AmountInputView(delegate: self, converter: presenter.convert)
        amountInput.translatesAutoresizingMaskIntoConstraints = false

        if let amount = initialAmount {
            amountInput.currency = amount.currency
            if amount.monetaryAmount.amount != 0 {
                amountInput.value = amount.toAmountWithoutCode(btcCurrencyFormat: .short)
            }
        }

        validate(amount: amountInput.value, currency: amountInput.currency)

        amountContainerView.addSubview(amountInput)

        confirmButton.delegate = self
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            amountContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            amountContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            amountContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            amountContainerView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor),

            amountInput.leadingAnchor.constraint(equalTo: amountContainerView.leadingAnchor, constant: .sideMargin),
            amountInput.trailingAnchor.constraint(equalTo: amountContainerView.trailingAnchor, constant: -.sideMargin),
            amountInput.centerXAnchor.constraint(equalTo: amountContainerView.centerXAnchor),
            amountInput.centerYAnchor.constraint(equalTo: amountContainerView.centerYAnchor),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
        ])
    }

    private func validate(amount: String, currency: Currency) {
        let state = presenter.validityCheck(
            amount: amount,
            currency: currency,
            for: receiveType
        )
        switch state {
        case .zero:
            if initialAmount != nil {
                confirmButton.isEnabled = true
                confirmButton.buttonText = L10n.ReceiveAmountInputViewController.remove
            } else {
                confirmButton.isEnabled = false
                confirmButton.buttonText = L10n.ReceiveAmountInputViewController.confirm
            }
        case .tooSmall:
            confirmButton.isEnabled = false
            confirmButton.buttonText = L10n.ReceiveAmountInputViewController.tooSmall
        case .tooBig:
            confirmButton.isEnabled = false
            confirmButton.buttonText = L10n.ReceiveAmountInputViewController.tooBig
        default:
            confirmButton.isEnabled = true
            confirmButton.buttonText = L10n.ReceiveAmountInputViewController.confirm
        }

        if state == .tooBig {
            amountInput.subtitle = ""
        } else {
            let secondaryAmount = presenter.getSecondaryAmount(amount: amount, currency: currency)
            secondaryAmount.map {
                amountInput.subtitle = $0.toAmountPlusCode()
            }
        }
    }

    func updateInfo(newCurrency: Currency) {
        amountInput.currency = newCurrency
        validate(amount: amountInput.value, currency: amountInput.currency)
    }

}

extension ReceiveAmountInputViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        dismiss(animated: true, completion: nil)

        if amountInput.value.isEmpty {
            delegate?.didConfirm(bitcoinAmount: nil)
        } else {
            let bitcoinAmountWithCurrency = presenter.amountWithCurrency(
                from: amountInput.value,
                in: amountInput.currency
            )

            if bitcoinAmountWithCurrency.bitcoinAmount.inSatoshis == Satoshis(value: 0) {
                delegate?.didConfirm(bitcoinAmount: nil)
            } else {
                delegate?.didConfirm(bitcoinAmount: bitcoinAmountWithCurrency)
            }
        }
    }

}

extension ReceiveAmountInputViewController: AmountInputViewDelegate {

    func didInput(amount: String, currency: Currency) {
        validate(amount: amount, currency: currency)
    }

    func didTapCurrency() {
        let vc = CurrencyPickerViewController.createForCurrencySelection(
            exchangeRateWindow: presenter.getExchangeRateWindow().toLibwallet(),
            delegate: self,
            selectedCurrency: nil
        )
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        navigationController?.present(nc, animated: true)
    }

}

extension ReceiveAmountInputViewController: CurrencyPickerDelegate {

    func didSelectCurrency(_ currency: Currency) {
        updateInfo(newCurrency: currency)
    }

}

// Keyboard actions
extension ReceiveAmountInputViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateButtonTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateButtonTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateButtonTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.bottomConstraint.constant = -height

            self.view.layoutIfNeeded()
        }
    }

}

extension ReceiveAmountInputViewController: ReceiveAmountInputPresenterDelegate {

}
