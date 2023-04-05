//
//  ReceiveUnifiedView.swift
//  Muun
//
//  Created by Lucas Serruya on 23/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit
import core

protocol ReceiveUnifiedViewDelegate: ReceiveDelegate {
    func didTapOn(URI: BitcoinURIViewModel)
    func didTapOnRequestNewUnfiedQR()
    func didTapOnAddressTypeControl()
}

final class ReceiveUnifiedView: UIView {

    private let stackView = UIStackView()
    private let expirationNoticeView = NoticeView()
    private let qrCodeView = QRCodeWithActionsView()
    private let advancedOptionsView = UnifiedAdvancedOptionsView()
    private let overlayView = UIView()
    private let createAnotherInvoiceButton = SmallButtonView()

    private var invoiceInfo: IncomingInvoiceInfo?
    private var bitcoinUri: BitcoinURIViewModel?
    private var timer = Timer()

    var addressType: AddressTypeViewModel {
        didSet {
            advancedOptionsView.setAddressType(addressType)
        }
    }

    private lazy var constraintsWhenNoticeIsHidden = [
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    ]
    private lazy var constraintsWhenNoticeIsVisible = [
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
    ]

    // We display a expiration warning message when the invoice has only 3 minutes remaining of expiration time
    private let expirationMessageThresholdInSecs = 180

    private weak var delegate: ReceiveUnifiedViewDelegate?

    init(delegate: ReceiveUnifiedViewDelegate?,
         addressType: AddressTypeViewModel) {
        self.delegate = delegate
        self.addressType = addressType
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            timer.invalidate()
        }
    }

    private func setUpView() {
        setUpStackView()
        setUpExpiryNotice()
        setUpQRCodeView()
        setUpAdvancedOptionsView()
        setUpOverlayView()

        makeViewTestable()
    }

    // MARK: - Views Layout and configuration -

    fileprivate func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = .sideMargin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate(constraintsWhenNoticeIsHidden)
    }

    fileprivate func setUpQRCodeView() {
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.delegate = self
        stackView.addArrangedSubview(qrCodeView)
        stackView.setCustomSpacing(24, after: qrCodeView)

        NSLayoutConstraint.activate([
            qrCodeView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: .sideMargin),
            qrCodeView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -.sideMargin),
            qrCodeView.topAnchor.constraint(equalTo: expirationNoticeView.bottomAnchor, constant: .sideMargin)
        ])
    }

    fileprivate func setUpExpiryNotice() {
        expirationNoticeView.style = .notice
        expirationNoticeView.text = L10n.ReceiveInLightningView.s1("")
            .attributedForDescription()
        expirationNoticeView.delegate = self

        expirationNoticeView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(expirationNoticeView)

        NSLayoutConstraint.activate([
            expirationNoticeView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: .sideMargin),
            expirationNoticeView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func setExpirationNoticeHidden(_ isHidden: Bool) {
        expirationNoticeView.isHidden = isHidden

        if isHidden {
            NSLayoutConstraint.deactivate(constraintsWhenNoticeIsVisible)
            NSLayoutConstraint.activate(constraintsWhenNoticeIsHidden)
        } else {
            NSLayoutConstraint.deactivate(constraintsWhenNoticeIsHidden)
            NSLayoutConstraint.activate(constraintsWhenNoticeIsVisible)
        }
    }

    fileprivate func setUpAdvancedOptionsView() {
        advancedOptionsView.translatesAutoresizingMaskIntoConstraints = false
        advancedOptionsView.delegate = self
        stackView.addArrangedSubview(advancedOptionsView)
        advancedOptionsView.setAddressType(addressType)

        NSLayoutConstraint.activate([
            advancedOptionsView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            advancedOptionsView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private func setUpOverlayView() {
        overlayView.backgroundColor = Asset.Colors.background.color
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true

        addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let overlayStackView = UIStackView()
        overlayStackView.translatesAutoresizingMaskIntoConstraints = false
        overlayStackView.spacing = 16
        overlayStackView.alignment = .center
        overlayStackView.axis = .vertical
        overlayView.addSubview(overlayStackView)

        NSLayoutConstraint.activate([
            overlayStackView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: .sideMargin),
            overlayStackView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -.sideMargin),
            overlayStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let expiredLabel = UILabel()
        expiredLabel.style = .description
        expiredLabel.attributedText = L10n.ReceiveInLightningView.s5
            .attributedForDescription(alignment: .center)
        expiredLabel.translatesAutoresizingMaskIntoConstraints = false
        expiredLabel.numberOfLines = 0
        overlayStackView.addArrangedSubview(expiredLabel)
        NSLayoutConstraint.activate([
            expiredLabel.leadingAnchor.constraint(equalTo: overlayStackView.leadingAnchor),
            expiredLabel.trailingAnchor.constraint(equalTo: overlayStackView.trailingAnchor)
        ])

        createAnotherInvoiceButton.isEnabled = true
        createAnotherInvoiceButton.buttonText = L10n.ReceiveInLightningView.s6
        createAnotherInvoiceButton.delegate = self
        createAnotherInvoiceButton.backgroundColor = .clear
        overlayStackView.addArrangedSubview(createAnotherInvoiceButton)

        NSLayoutConstraint.activate([
            createAnotherInvoiceButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func displayInvoiceExpiredView() {
        overlayView.isHidden = false
    }

    private func startTimer() {
        updateTimer()

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: .updateTimer,
            userInfo: nil,
            repeats: true
        )
    }

    // MARK: - View actions -

    @objc fileprivate func updateTimer() {

        guard let expirationTimeRemainingInSecs = invoiceInfo?.expirationTimeInSeconds,
              let formattedTime = invoiceInfo?.formattedExpirationTime else {
            return
        }

        if expirationTimeRemainingInSecs <= 0 {
            displayInvoiceExpiredView()
            timer.invalidate()
            return
        }

        advancedOptionsView.setExpirationTime(formattedTime)

        if expirationTimeRemainingInSecs < expirationMessageThresholdInSecs {
            setExpirationNoticeHidden(false)
            updateExpireLabel(formattedTime: formattedTime)
        } else {
            setExpirationNoticeHidden(true)
        }
    }

    private func updateExpireLabel(formattedTime: String) {
        expirationNoticeView.text = L10n.ReceiveInLightningView.s1(formattedTime)
            .set(font: Constant.Fonts.system(size: .opHelper))
            .set(bold: formattedTime, color: Asset.Colors.muunGrayDark.color)
            .set(underline: L10n.ReceiveInLightningView.s2, color: Asset.Colors.muunBlue.color)
    }

    // MARK: - View Controller actions -

    func setAmount(_ bitcoinAmount: BitcoinAmountWithSelectedCurrency?) {
        advancedOptionsView.setAmount(bitcoinAmount)
    }

    func display(bitcoinURIViewModel: BitcoinURIViewModel?) {
        guard let bitcoinURIViewModel = bitcoinURIViewModel else {
            setExpirationNoticeHidden(true)
            qrCodeView.loadingText = L10n.ReceiveUnifiedView.loading
            qrCodeView.isLoading = true

            advancedOptionsView.setExpirationTime(nil)
            timer.invalidate()
            return
        }

        qrCodeView.data = bitcoinURIViewModel.uri.data(using: .utf8)
        qrCodeView.label = "🧪 " + bitcoinURIViewModel.address
        qrCodeView.isLoading = false

        // Reset the view to initial state when displaying a new invoice
        overlayView.isHidden = true
        setExpirationNoticeHidden(true)
        timer.invalidate()

        self.invoiceInfo = bitcoinURIViewModel.invoice
        self.bitcoinUri = bitcoinURIViewModel
        // Restart the timer, it will take care of handling the expiration time of the invoice
        startTimer()
    }
}

extension ReceiveUnifiedView: SmallButtonViewDelegate {

    internal func button(didPress button: SmallButtonView) {
        if button == createAnotherInvoiceButton {
            delegate?.didTapOnRequestNewUnfiedQR()
        }
    }

}

extension ReceiveUnifiedView: QRCodeWithActionsViewDelegate {

    internal func didTapQRCode() {
        guard let bitcoinUri = bitcoinUri else { return }
        delegate?.didTapOnCopy(bitcoinUri.uri)
    }

    internal func didTapLabel() {
        guard let bitcoinUri = bitcoinUri else { return }
        delegate?.didTapOn(URI: bitcoinUri)
    }

    internal func didTapOnCopy() {
        guard let bitcoinUri = bitcoinUri else { return }
        delegate?.didTapOnCopy(bitcoinUri.uri)
    }

    internal func didTapOnShare() {
        guard let bitcoinUri = bitcoinUri else { return }
        delegate?.didTapOnShare(bitcoinUri.uri)
    }

}

extension ReceiveUnifiedView: NoticeViewDelegate {

    func didTapOnMessage() {
        delegate?.didTapOnRequestNewUnfiedQR()
    }

}

extension ReceiveUnifiedView: UnifiedAdvancedOptionsViewDelegate {
    func didTapAddAmount() {
        delegate?.didTapOnAddAmount()
    }

    func didToggleOptions(visible: Bool) {
        delegate?.didToggleOptions(visible: visible)
    }

    func didTapOnAddressTypeControl() {
        delegate?.didTapOnAddressTypeControl()
    }
}

extension ReceiveUnifiedView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    private func makeViewTestable() {
        makeViewTestable(qrCodeView, using: .qrCodeWithActions)
    }
}

fileprivate extension Selector {
    static let updateTimer = #selector(ReceiveUnifiedView.updateTimer)
}
