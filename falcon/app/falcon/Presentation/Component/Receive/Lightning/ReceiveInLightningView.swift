//
//  ReceiveInLightningView.swift
//  falcon
//
//  Created by Manu Herrera on 05/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

protocol ReceiveDelegate: AnyObject {
    func didTapOnShare(_ shareText: String)
    func didTapOnCopy(_ copyText: String)
    func didTapOnAddAmount()
    func didToggleOptions(visible: Bool)
}

protocol ReceiveInLightningViewDelegate: ReceiveDelegate {
    func didTapOnCompatibilityAddressInfo()
    func didTapOnInvoice(_ invoice: String)
    func didTapOnRequestNewInvoice()
}

struct IncomingInvoiceInfo {
    // The raw string representation of the invoice
    let rawInvoice: String

    // This is the expiration date of the invoice represented in unix time
    // Optional for future compatibility with invoices without expiration date
    let expiresAt: Double?

    var expirationTimeInSeconds: Int? {
        guard let expiresAt = expiresAt else {
            return nil
        }
        return Int(expiresAt - Date().timeIntervalSince1970)
    }

    var formattedExpirationTime: String? {
        guard let seconds = expirationTimeInSeconds else {
            return nil
        }

        let formatter = DateFormatter()
        if seconds < 60 * 60 {
            formatter.dateFormat = "mm:ss"
        } else {
            formatter.dateFormat = "HH:mm:ss"
        }
        formatter.timeZone = TimeZone(identifier: "UTC")
        // Override 24-hour vs 12-hour device setting
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let timeInterval = Double(seconds)
        let timeRemaining = Date(timeIntervalSince1970: timeInterval)

        return formatter.string(from: timeRemaining)
    }

    static func from(raw: String) -> IncomingInvoiceInfo {
        let unixExpiration = getUnixExpirationTime(raw)
        let info = IncomingInvoiceInfo(rawInvoice: raw, expiresAt: unixExpiration)

        return info
    }

    static private func getUnixExpirationTime(_ rawInvoice: String) -> Double {
        do {
            let paymentIntent = try AddressHelper.parse(rawInvoice)
            switch paymentIntent {
            case .submarineSwap(let invoice):
                return Double(invoice.expiry)
            default:
                Logger.fatal("Trying to parse something that is not a lightning invoice: \(rawInvoice)")
            }
        } catch {
            Logger.fatal("Trying to parse something that is not a lightning invoice: \(rawInvoice)")
        }
    }
}

final class ReceiveInLightningView: UIView {

    private let stackView = UIStackView()
    private let expirationNoticeView = NoticeView()
    private let qrCodeView = QRCodeWithActionsView()
    private let advancedOptionsView = LightningAdvancedOptionsView()
    private let createInvoiceView = CreateInvoiceView()

    private var invoiceInfo: IncomingInvoiceInfo?
    private var timer = Timer()

    private lazy var constraintsWhenNoticeIsHidden = [
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    ]
    private lazy var constraintsWhenNoticeIsVisible = [
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
    ]

    // We display a expiration warning message when the invoice has only 3 minutes remaining of expiration time
    private let expirationMessageThresholdInSecs = 180

    var isHighFeesFlow = false {
        willSet {
            if newValue {
                displayHighFeesAndStopTimer()
            } else {
                hideInvoiceExpiredView()
            }
        }
    }

    private weak var delegate: ReceiveInLightningViewDelegate?

    init(delegate: ReceiveInLightningViewDelegate?) {
        self.delegate = delegate

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

        NSLayoutConstraint.activate([
            advancedOptionsView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            advancedOptionsView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private func setUpOverlayView() {
        createInvoiceView.addAsFullSizeSubviewBindingDelegateTo(superView: self)
        hideInvoiceExpiredView()
    }

    private func hideInvoiceExpiredView() {
        createInvoiceView.hide()
    }

    private func displayInvoiceExpiredViewAndStopTimer() {
        let text = L10n.ReceiveInLightningView.s5
            .attributedForDescription(alignment: .center)
        createInvoiceView.display(text: text,
                                  buttonText: L10n.ReceiveInLightningView.s6)
        timer.invalidate()
    }

    private func displayHighFeesAndStopTimer() {
        let text = L10n.ReceiveInLightningView.s7
            .attributedForDescription(alignment: .center)
        createInvoiceView.display(text: text,
                                  buttonText: L10n.ReceiveInLightningView.s8)
        timer.invalidate()
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
            displayInvoiceExpiredViewAndStopTimer()
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

    func displayInvoice(_ invoiceInfo: IncomingInvoiceInfo?) {
        guard let invoiceInfo = invoiceInfo else {
            setExpirationNoticeHidden(true)
            qrCodeView.loadingText = L10n.ReceiveInLightningView.loading
            qrCodeView.isLoading = true

            advancedOptionsView.setExpirationTime(nil)
            timer.invalidate()
            return
        }

        qrCodeView.data = invoiceInfo.rawInvoice.uppercased().data(using: .utf8)
        qrCodeView.label = invoiceInfo.rawInvoice
        qrCodeView.isLoading = false

        // Reset the view to initial state when displaying a new invoice
        hideInvoiceExpiredView()
        setExpirationNoticeHidden(true)
        timer.invalidate()

        self.invoiceInfo = invoiceInfo
        // Restart the timer, it will take care of handling the expiration time of the invoice
        startTimer()
    }
}

extension ReceiveInLightningView: CreateInvoiceViewDelegate {

    internal func button(didPress button: SmallButtonView) {
        delegate?.didTapOnRequestNewInvoice()
    }

}

extension ReceiveInLightningView: QRCodeWithActionsViewDelegate {

    internal func didTapQRCode() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnCopy(invoiceInfo.rawInvoice)
    }

    internal func didTapLabel() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnInvoice(invoiceInfo.rawInvoice)
    }

    internal func didTapOnCopy() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnCopy(invoiceInfo.rawInvoice)
    }

    internal func didTapOnShare() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnShare(invoiceInfo.rawInvoice)
    }

}

extension ReceiveInLightningView: NoticeViewDelegate {

    func didTapOnMessage() {
        delegate?.didTapOnRequestNewInvoice()
    }

}

extension ReceiveInLightningView: LightningAdvancedOptionsViewDelegate {

    func didTapAddAmount() {
        delegate?.didTapOnAddAmount()
    }

    func didToggleOptions(visible: Bool) {
        delegate?.didToggleOptions(visible: visible)
    }

}

extension ReceiveInLightningView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    private func makeViewTestable() {
        makeViewTestable(qrCodeView, using: .qrCodeWithActions)
    }
}

fileprivate extension Selector {
    static let updateTimer = #selector(ReceiveInLightningView.updateTimer)
}
