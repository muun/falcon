//
//  ReceiveOnChainView.swift
//  falcon
//
//  Created by Manu Herrera on 30/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

enum AddressType {
    case segwit
    case legacy
}

protocol ReceiveOnChainViewDelegate: ReceiveDelegate {
    func didTapOnCompatibilityAddressInfo()
    func didTapOnAddress(address: String)
    func didSwitchToSegwit()
    func didSwitchToLegacy()
}

final class ReceiveOnChainView: UIView {

    private let contentStackView = UIStackView()
    private let cardStackView = UIStackView()
    private let compatStackView = UIStackView()
    private let compatibilityLabel = UILabel()
    private let qrImageView = UIImageView()
    private let addressLabel = UILabel()
    private let checkAddressImage = UIImageView()
    private let shareButton = LightButtonView()
    private let copyButton = LightButtonView()
    private let switchAdressLabel = UILabel()

    private let segwitAddress: String
    private let legacyAddress: String
    private weak var delegate: ReceiveOnChainViewDelegate?

    private var currentAddressType: AddressType = .segwit

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
        setUpContentStackView()
        setUpCardView()
        setUpSwitchAddressLabel()

        makeViewTestable()
    }

    fileprivate func setUpContentStackView() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.spacing = 16
        contentStackView.alignment = .center
        contentStackView.axis = .vertical
        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    fileprivate func setUpCardView() {
        let cardView = UIView()

        cardView.backgroundColor = Asset.Colors.cellBackground.color
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.roundCorners(cornerRadius: 16, clipsToBounds: false)
        setUpShadow(in: cardView)
        contentStackView.addArrangedSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor)
        ])

        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardStackView.spacing = 16
        cardStackView.alignment = .center
        cardStackView.axis = .vertical
        cardView.addSubview(cardStackView)

        NSLayoutConstraint.activate([
            cardStackView.heightAnchor.constraint(equalTo: cardView.heightAnchor),
            cardStackView.widthAnchor.constraint(equalTo: cardView.widthAnchor),
            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])

        cardStackView.isLayoutMarginsRelativeArrangement = true
        cardStackView.layoutMargins = UIEdgeInsets(top: .sideMargin, left: 0, bottom: .sideMargin, right: 0)

        setUpCompatibilityButton()
        setUpQR()
        setUpShareAndCopyButtons()
    }

    fileprivate func setUpShadow(in cardView: UIView) {
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            return
        }

        // We only want the shadow if we are not on dark mode
        cardView.setUpShadow(
            color: Asset.Colors.muunGrayDark.color,
            opacity: 0.25,
            offset: CGSize(width: 0, height: 4),
            radius: 8
        )
    }

    fileprivate func setUpCompatibilityButton() {
        compatStackView.translatesAutoresizingMaskIntoConstraints = false
        compatStackView.spacing = 8
        compatStackView.distribution = .equalSpacing
        compatStackView.axis = .horizontal
        cardStackView.addArrangedSubview(compatStackView)

        compatibilityLabel.text = L10n.ReceiveOnChainView.s1
        compatibilityLabel.textColor = Asset.Colors.title.color
        compatibilityLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        compatibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        compatStackView.addArrangedSubview(compatibilityLabel)

        let imageView = UIImageView()
        imageView.image = Asset.Assets.info.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        compatStackView.addArrangedSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.centerYAnchor.constraint(equalTo: compatStackView.centerYAnchor)
        ])

        compatStackView.isHidden = true

        compatStackView.isUserInteractionEnabled = true
        compatStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .compatTouch))
    }

    fileprivate func setUpQR() {
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.isUserInteractionEnabled = true
        qrImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .qrTouch))

        cardStackView.addArrangedSubview(qrImageView)

        NSLayoutConstraint.activate([
            qrImageView.widthAnchor.constraint(equalTo: cardStackView.widthAnchor, constant: -.sideMargin * 2),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])

        cardStackView.setCustomSpacing(8, after: qrImageView)

        let addressStackView = UIStackView()
        addressStackView.translatesAutoresizingMaskIntoConstraints = false
        addressStackView.spacing = 8
        addressStackView.distribution = .equalSpacing
        addressStackView.isUserInteractionEnabled = true
        addressStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .addressTouch))

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.textColor = Asset.Colors.muunGrayDark.color
        addressLabel.font = Constant.Fonts.system(size: .notice)
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingMiddle
        cardStackView.addArrangedSubview(addressStackView)
        addressStackView.addArrangedSubview(addressLabel)

        checkAddressImage.translatesAutoresizingMaskIntoConstraints = false
        checkAddressImage.image = Asset.Assets.passwordShow.image
        addressStackView.addArrangedSubview(checkAddressImage)

        NSLayoutConstraint.activate([
            checkAddressImage.heightAnchor.constraint(equalToConstant: 16),
            checkAddressImage.widthAnchor.constraint(equalToConstant: 16),
            checkAddressImage.centerYAnchor.constraint(equalTo: addressLabel.centerYAnchor),
            addressStackView.widthAnchor.constraint(
                lessThanOrEqualTo: cardStackView.widthAnchor,
                constant: -.sideMargin * 2
            )
        ])
    }

    fileprivate func setUpShareAndCopyButtons() {
        let buttonsContainerView = UIStackView()
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.spacing = 32
        cardStackView.addArrangedSubview(buttonsContainerView)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.delegate = self
        shareButton.buttonText = L10n.ReceiveOnChainView.s2
        buttonsContainerView.addArrangedSubview(shareButton)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.delegate = self
        copyButton.buttonText = L10n.ReceiveOnChainView.s3
        buttonsContainerView.addArrangedSubview(copyButton)

        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 60),
            copyButton.widthAnchor.constraint(equalToConstant: 60),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    fileprivate func setUpSwitchAddressLabel() {
        switchAdressLabel.translatesAutoresizingMaskIntoConstraints = false
        switchAdressLabel.textColor = Asset.Colors.muunGrayDark.color
        switchAdressLabel.font = Constant.Fonts.system(size: .notice)
        switchAdressLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(switchAdressLabel)

        NSLayoutConstraint.activate([
            switchAdressLabel.leadingAnchor.constraint(
                equalTo: contentStackView.leadingAnchor,
                constant: .sideMargin
            ),
            switchAdressLabel.trailingAnchor.constraint(
                equalTo: contentStackView.trailingAnchor,
                constant: -.sideMargin
            )
        ])
    }

    private func setAddress(_ address: String) {
        // Uppercase segwit addresses to trigger alphanumeric mode in
        // the QR code, which reduces QR density
        let stringData: Data?
        if currentAddressType == .segwit {
            stringData = address.uppercased().data(using: .utf8)
        } else {
            stringData = address.data(using: .utf8)
        }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            fatalError("The QR code filter is not available")
        }

        filter.setValue(stringData, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let coreImage = filter.outputImage else {
            fatalError("Failed to generate an image for the QR code")
        }

        // This transforms keeps the QR from blurring
        let scaleX = qrImageView.frame.size.width / coreImage.extent.size.width
        let scaleY = qrImageView.frame.size.height / coreImage.extent.size.height

        let scaledImage = coreImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        qrImageView.image = UIImage(ciImage: scaledImage)
        addressLabel.text = address
        // Hide the eye button when the address fits the screen
        checkAddressImage.isHidden = !addressLabel.isTruncated
    }

    private func setSwitchButton() {

        switchAdressLabel.isUserInteractionEnabled = true
        switchAdressLabel.gestureRecognizers?.forEach(switchAdressLabel.removeGestureRecognizer)

        let text: String
        let underline: String

        if currentAddressType == .segwit {
            text = L10n.ReceiveOnChainView.s6
            underline = L10n.ReceiveOnChainView.s4

            switchAdressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .switchToLegacy))
        } else {
            text = L10n.ReceiveOnChainView.s5
            underline = text

            switchAdressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .switchToSegwit))
        }

        switchAdressLabel.attributedText = text
            .set(font: Constant.Fonts.system(size: .notice),
                 lineSpacing: Constant.FontAttributes.lineSpacing,
                 kerning: Constant.FontAttributes.kerning,
                 alignment: .center)
            .set(underline: underline, color: Asset.Colors.muunBlue.color)

    }

    @objc func displaySegwit() {
        currentAddressType = .segwit
        compatStackView.isHidden = true
        setAddress(segwitAddress)
        setSwitchButton()
        delegate?.didSwitchToSegwit()
    }

    @objc func displayLegacy() {
        currentAddressType = .legacy
        compatStackView.isHidden = false
        setAddress(legacyAddress)
        setSwitchButton()
        delegate?.didSwitchToLegacy()
    }

    @objc func compatTouch() {
        delegate?.didTapOnCompatibilityAddressInfo()
    }

    @objc func qrTouch() {
        let add = (currentAddressType == .segwit) ? segwitAddress : legacyAddress
        delegate?.didTapOnCopy(add)
    }

    @objc func addressTouch() {
        let add = (currentAddressType == .segwit) ? segwitAddress : legacyAddress
        delegate?.didTapOnAddress(address: add)
    }

}

extension ReceiveOnChainView: LightButtonViewDelegate {
    func lightButton(didPress lightButton: LightButtonView) {
        let add = (currentAddressType == .segwit) ? segwitAddress : legacyAddress

        if lightButton == copyButton {
            delegate?.didTapOnCopy(add)
        } else {
            delegate?.didTapOnShare(add)
        }
    }
}

extension ReceiveOnChainView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    func makeViewTestable() {
        makeViewTestable(addressLabel, using: .address)
    }
}

fileprivate extension Selector {
    static let switchToLegacy = #selector(ReceiveOnChainView.displayLegacy)
    static let switchToSegwit = #selector(ReceiveOnChainView.displaySegwit)
    static let compatTouch = #selector(ReceiveOnChainView.compatTouch)
    static let qrTouch = #selector(ReceiveOnChainView.qrTouch)
    static let addressTouch = #selector(ReceiveOnChainView.addressTouch)
}
