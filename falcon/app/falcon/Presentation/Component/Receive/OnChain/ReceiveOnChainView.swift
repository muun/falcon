//
//  ReceiveOnChainView.swift
//  falcon
//
//  Created by Manu Herrera on 30/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

enum AddressType: CustomStringConvertible {
    case segwit
    case legacy

    var description: String {
        switch self {
        case .segwit: return L10n.AddressTypeOptionView.segwit
        case .legacy: return L10n.AddressTypeOptionView.legacy
        }
    }

    static let allValues = [segwit, legacy]
}

protocol ReceiveOnChainViewDelegate: ReceiveDelegate {
    func didTapOnCompatibilityAddressInfo()
    func didTapOnAddress(address: String)
    func didTapOnAddressTypeControl()
}

final class ReceiveOnChainView: UIView {

    private let stackView = UIStackView()
    private let qrCodeView = QRCodeWithActionsView()
    private let advancedOptionsView = OnChainAdvancedOptionsView()

    private let segwitAddress: String
    private let legacyAddress: String
    private weak var delegate: ReceiveOnChainViewDelegate?

    var addressType: AddressType = .segwit {
        didSet {
            updateQRCode()
            advancedOptionsView.setAddressType(addressType)
        }
    }

    private var currentAddress: String {
        (addressType == .segwit) ? segwitAddress : legacyAddress
    }

    private var customAmountInBTC: Decimal?

    init(segwit: String, legacy: String, delegate: ReceiveOnChainViewDelegate?) {
        segwitAddress = segwit
        legacyAddress = legacy
        self.delegate = delegate

        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpStackView()
        setUpQRCodeView()
        setUpAdvancedOptionsView()

        makeViewTestable()
    }

    // MARK: - Views Layout and configuration -

    fileprivate func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    fileprivate func setUpQRCodeView() {
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.delegate = self
        stackView.addArrangedSubview(qrCodeView)
        stackView.setCustomSpacing(24, after: qrCodeView)

        NSLayoutConstraint.activate([
            qrCodeView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: .sideMargin),
            qrCodeView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -.sideMargin)
        ])
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

    private func addressWithOptionalAmount() -> String {
        if let amount = customAmountInBTC {
            return "bitcoin:\(currentAddress)?amount=\(amount)"
        }
        return currentAddress
    }

    private func updateQRCode() {
        if let amount = customAmountInBTC {
            let uri = "bitcoin:\(currentAddress)?amount=\(amount)"

            qrCodeView.data = uri.data(using: .utf8)
        } else {
            // Uppercase segwit addresses to trigger alphanumeric mode in
            // the QR code, which reduces QR density
            // TODO: Bring back the uppercase once all wallets support it
            let stringData: Data?
            if addressType == .segwit {
                stringData = segwitAddress.data(using: .utf8)
            } else {
                stringData = legacyAddress.data(using: .utf8)
            }

            qrCodeView.data = stringData

        }

        qrCodeView.label = currentAddress
    }

    // MARK: - View Controller Actions -

    func setAmount(_ amount: BitcoinAmount?) {
        customAmountInBTC = amount?.inSatoshis.toBTCDecimal()

        updateQRCode()

        advancedOptionsView.setAmount(amount)
    }

    func resetOptions() {
        customAmountInBTC = nil
        addressType = .segwit

        advancedOptionsView.setAmount(nil)
        advancedOptionsView.setAddressType(.segwit)
    }

}

extension ReceiveOnChainView: QRCodeWithActionsViewDelegate {

    internal func didTapQRCode() {
        delegate?.didTapOnCopy(addressWithOptionalAmount())
    }

    func didTapLabel() {
        delegate?.didTapOnAddress(address: currentAddress)
    }

    func didTapOnCopy() {
        delegate?.didTapOnCopy(addressWithOptionalAmount())
    }

    func didTapOnShare() {
        delegate?.didTapOnShare(addressWithOptionalAmount())
    }

}

extension ReceiveOnChainView: OnChainAdvancedOptionsViewDelegate {

    func didTapOnCompatibilityAddressInfo() {
        delegate?.didTapOnCompatibilityAddressInfo()
    }

    func didTapOnAddressTypeControl() {
        delegate?.didTapOnAddressTypeControl()
    }

    func didTapAddAmount() {
        delegate?.didTapOnAddAmount()
    }

    func didToggleOptions(visible: Bool) {
        delegate?.didToggleOptions(visible: visible)
    }

}

extension ReceiveOnChainView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    func makeViewTestable() {
        makeViewTestable(qrCodeView, using: .qrCodeWithActions)
    }
}
