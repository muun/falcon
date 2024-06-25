//
//  ManuallyEnterFeeViewController.swift
//  falcon
//
//  Created by Manu Herrera on 23/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class ManuallyEnterFeeViewController: MUViewController {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var textFieldBottomBar: UIView!
    @IBOutlet fileprivate weak var satsPerByteLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var timeImageView: UIImageView!
    @IBOutlet fileprivate weak var btcLabel: AmountLabel!
    @IBOutlet fileprivate weak var inInputLabel: AmountLabel!
    @IBOutlet fileprivate weak var warningView: UIView!
    @IBOutlet fileprivate weak var warningImageView: UIImageView!
    @IBOutlet fileprivate weak var warningLabel: UILabel!
    @IBOutlet var warningViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var buttonViewBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(ManuallyEnterFeePresenter.init,
                                                       delegate: self,
                                                       state: state)
    private weak var delegate: SelectFeeDelegate?

    private let originalFeeState: FeeState
    private var selectedFee: FeeState?
    private let state: FeeEditorState

    private let highImage = Asset.Assets.warningHigh.image
    private let lowImage = Asset.Assets.warningLow.image
    private let redColor = Asset.Colors.muunRed.color
    private let warnColor = Asset.Colors.muunWarning.color
    private let selectedCurrency: Currency

    override var screenLoggingName: String {
        return "manually_enter_fee"
    }

    init(delegate: SelectFeeDelegate?, state: FeeEditorState, selectedCurrency: Currency) {
        self.delegate = delegate
        self.originalFeeState = state.feeState
        self.selectedFee = state.feeState
        self.state = state
        self.selectedCurrency = selectedCurrency

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addKeyboardObservers()
        setUpNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.ManuallyEnterFeeViewController.s1
    }

    private func setUpView() {
        setUpCardView()
        setUpLabels()
        setUpTextField()
        setUpConfirmButton()
        makeViewTestable()
    }

    fileprivate func setUpCardView() {
        cardView.layer.cornerRadius = 4
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = Asset.Colors.cardViewBorder.color.cgColor
        cardView.backgroundColor = Asset.Colors.background.color

        warningView.isHidden = true
    }

    fileprivate func setUpLabels() {
        titleLabel.style = .description
        let titleText = L10n.ManuallyEnterFeeViewController.s2
        titleLabel.attributedText = titleText
            .set(font: titleLabel.font)
            .set(underline: L10n.ManuallyEnterFeeViewController.s3, color: Asset.Colors.muunBlue.color)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .titleLabelTouched))

        satsPerByteLabel.style = .description
        satsPerByteLabel.text = L10n.ManuallyEnterFeeViewController.s4

        timeLabel.textColor = Asset.Colors.muunGrayDark.color
        timeLabel.font = Constant.Fonts.system(size: .helper)
        timeLabel.isHidden = true
        timeImageView.isHidden = true

        btcLabel.textColor = Asset.Colors.title.color
        btcLabel.font = Constant.Fonts.system(size: .desc, weight: .medium)
        btcLabel.isHidden = true

        inInputLabel.textColor = Asset.Colors.muunGrayDark.color
        inInputLabel.font = Constant.Fonts.system(size: .helper)
        inInputLabel.isHidden = true

        warningLabel.textColor = Asset.Colors.muunGrayDark.color
        warningLabel.font = Constant.Fonts.system(size: .helper)
    }

    fileprivate func setUpTextField() {
        textField.font = Constant.Fonts.description
        textField.textColor = Asset.Colors.title.color
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.muunGrayLight.color]
        )
        textFieldBottomBar.backgroundColor = Asset.Colors.muunBlue.color
        textField.becomeFirstResponder()
    }

    private func setUpConfirmButton() {
        buttonView.style = .primary
        buttonView.delegate = self
        buttonView.buttonText = L10n.ManuallyEnterFeeViewController.s5
        buttonView.isEnabled = false
    }

    @objc fileprivate func titleLabelTouched() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.manualFee)
        navigationController!.present(overlayVc, animated: true)
    }

    private func updateCardView(_ feeRate: FeeRate?) {
        if let feeRate = feeRate {

            timeImageView.isHidden = false
            timeLabel.isHidden = false

            // TODO currently forgets input currency, which is important for amount display
            let fee = state.calculateFee(feeRate)
            let feeState = fee.adapt()

            let feeAmount: BitcoinAmount
            switch feeState {
            case .finalFee(let amount, _):
                feeAmount = amount
            case .feeNeedsChange(let amount, _):
                feeAmount = amount
            case .noPossibleFee:
                return
            }

            var feeAmountWithCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: feeAmount,
                                                                          selectedCurrency: selectedCurrency)
            btcLabel.setAmount(from: feeAmountWithCurrency,
                               in: .inBTC)
            btcLabel.isHidden = false

            if feeAmount.inInputCurrency.currency != "BTC" {
                let currency = GetCurrencyForCode().runAssumingCrashPosibility(code: feeAmount.inInputCurrency.currency)
                feeAmountWithCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: feeAmount,
                                                                          selectedCurrency: currency)
                inInputLabel.setHelperText(for: feeAmountWithCurrency, in: .inInput)
                inInputLabel.isHidden = false
            } else if feeAmount.inPrimaryCurrency.currency != "BTC" {
                let currency = GetCurrencyForCode().runAssumingCrashPosibility(code: feeAmount.inInputCurrency.currency)
                feeAmountWithCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: feeAmount,
                                                                          selectedCurrency: currency)
                inInputLabel.setHelperText(for: feeAmountWithCurrency, in: .inPrimary)
                inInputLabel.isHidden = false
            } else {
                inInputLabel.isHidden = true
            }

            let timeString = presenter.timeToConfirm(fee)
            timeLabel.text = L10n.ManuallyEnterFeeViewController.s7(timeString)

            selectedFee = feeState
            presenter.checkWarnings(feeState)

        } else {
            selectedFee = nil
            timeLabel.isHidden = true
            timeImageView.isHidden = true
            btcLabel.isHidden = true
            inInputLabel.isHidden = true
            warningView.isHidden = true
            buttonView.isEnabled = false
        }
    }
}

extension ManuallyEnterFeeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.count >= 6 {
                return false
            }

            if let amount = LocaleAmountFormatter.number(from: updatedText) {
                let feeRate = FeeRate(satsPerVByte: amount)
                updateCardView(feeRate)
            } else if updatedText == "" {
                updateCardView(nil)
            } else {
                return false
            }

        }

        return true
    }
}

extension ManuallyEnterFeeViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        if case .finalFee(let fee, let rate) = selectedFee {
            delegate?.selected(fee: fee, rate: rate)
            view.endEditing(true)
            navigationController?.dismiss(animated: true)
        }
    }

}

// Keyboard actions
extension ManuallyEnterFeeViewController {

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
            self.buttonViewBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension ManuallyEnterFeeViewController: ManuallyEnterFeePresenterDelegate {

    func feeIsTooLow(minFee: String) {
        let warningText = L10n.ManuallyEnterFeeViewController.s8(minFee)
        showWarning(warningText, image: highImage, warningColor: redColor, buttonEnabled: false)
    }

    func feeBelowMempoolMinimum(minFee: String) {
        let warningText = L10n.ManuallyEnterFeeViewController.s13(minFee)
        showWarning(warningText, image: highImage, warningColor: redColor, buttonEnabled: false)
    }

    func feeIsTooHigh(maxFee: String) {
        let warningText = L10n.ManuallyEnterFeeViewController.s9(maxFee)
        showWarning(warningText, image: highImage, warningColor: redColor, buttonEnabled: false)
    }

    func insufficientFunds() {
        let warningText = L10n.ManuallyEnterFeeViewController.s11
        showWarning(warningText, image: highImage, warningColor: redColor, buttonEnabled: false)
    }

    func feeIsVeryLow() {
        let warningText = L10n.ManuallyEnterFeeViewController.s12
        showWarning(warningText, image: lowImage, warningColor: warnColor, buttonEnabled: true)
    }

    private func showWarning(_ text: String, image: UIImage?, warningColor: UIColor, buttonEnabled: Bool) {
        buttonView.isEnabled = buttonEnabled
        warningView.isHidden = false

        var attrsString = text.set(font: warningLabel.font)
        if let coloredText = text.split(separator: ".").first?.description {
            attrsString = attrsString.set(tint: coloredText, color: warningColor)
        }

        warningLabel.attributedText = attrsString
        warningImageView.image = image
        textFieldBottomBar.backgroundColor = warningColor
    }

    func noWarnings() {
        warningView.isHidden = true
        buttonView.isEnabled = true
        textFieldBottomBar.backgroundColor = Asset.Colors.muunBlue.color
    }

}

fileprivate extension Selector {
    static let titleLabelTouched = #selector(ManuallyEnterFeeViewController.titleLabelTouched)
}

extension ManuallyEnterFeeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.ManuallyEnterFeePage

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
        self.makeViewTestable(textField, using: .textField)
        self.makeViewTestable(buttonView, using: .button)
        self.makeViewTestable(warningLabel, using: .warningLabel)
    }

}
