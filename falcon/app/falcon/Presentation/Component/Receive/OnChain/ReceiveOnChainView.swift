//
//  ReceiveOnChainView.swift
//  falcon
//
//  Created by Manu Herrera on 30/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

enum AddressTypeViewModel: String, MUActionSheetOption {
    case segwit
    case legacy
    case taproot

    var name: String {
        switch self {
        case .segwit: return L10n.AddressTypeOptionView.segwit
        case .legacy: return L10n.AddressTypeOptionView.legacy
        case .taproot: return L10n.AddressTypeOptionView.taproot
        }
    }

    var description: NSAttributedString {
        switch self {
        case .legacy:
            return L10n.AddressTypeOptionView.legacyDescription.toAttributedString()
        case .segwit:
            return L10n.AddressTypeOptionView.segwitDescription.toAttributedString()
        case .taproot:
            return L10n.AddressTypeOptionView.taprootDescription.toAttributedString()
        }
    }

    static func from(model: AddressType) -> AddressTypeViewModel {
        return AddressTypeViewModel(rawValue: model.rawValue)!
    }
}

protocol ReceiveOnChainViewDelegate: ReceiveDelegate {
    func didTapOnCompatibilityAddressInfo()
    func didTapOnAddress(address: String)
    func didTapOnAddressTypeControl()
}

final class ReceiveOnChainView: UIView {

    private let stackView = UIStackView()
    private let qrCodeView: QRCodeWithActionsView
    private let advancedOptionsView = OnChainAdvancedOptionsView()

    private let addressSet: AddressSet
    private weak var delegate: ReceiveOnChainViewDelegate?

    var addressType: AddressTypeViewModel {
        didSet {
            updateQRCode()
            advancedOptionsView.setAddressType(addressType)
        }
    }
    let defaultAddressType: AddressTypeViewModel

    private var currentAddress: String {
        switch addressType {
        case .segwit:
            return addressSet.segwit
        case .legacy:
            return addressSet.legacy
        case .taproot:
            return addressSet.taproot
        }
    }

    private var customAmountInBTC: Decimal?

    init(addressSet: AddressSet,
         delegate: ReceiveOnChainViewDelegate?,
         defaultAddressType: AddressTypeViewModel) {
        let qrAccessibilityLabel = L10n.QRCodeWithActionsView.onChainQRAccessibilityLabel
        self.qrCodeView = QRCodeWithActionsView(tapQRAccessibilityLabel: qrAccessibilityLabel)
        self.defaultAddressType = defaultAddressType
        self.addressType = defaultAddressType
        self.addressSet = addressSet
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
            qrCodeView.data = currentAddress.data(using: .utf8)
        }

        qrCodeView.label = currentAddress
    }

    // MARK: - View Controller Actions -

    func setAmount(_ amount: BitcoinAmountWithSelectedCurrency?) {
        customAmountInBTC = amount?.bitcoinAmount.inSatoshis.toBTCDecimal()

        updateQRCode()

        advancedOptionsView.setAmount(amount)
    }

    func resetOptions() {
        customAmountInBTC = nil
        addressType = defaultAddressType

        advancedOptionsView.setAmount(nil)
        advancedOptionsView.setAddressType(addressType)
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
