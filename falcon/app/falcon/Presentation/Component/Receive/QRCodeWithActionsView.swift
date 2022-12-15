//
//  QRCodeWithActionsView.swift
//  falcon
//
//  Created by Federico Bond on 08/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol QRCodeWithActionsViewDelegate: AnyObject {
    func didTapQRCode()
    func didTapLabel()
    func didTapOnCopy()
    func didTapOnShare()
}

class QRCodeWithActionsView: UIView {

    private let stackView = UIStackView()
    private let qrCodeView = QRCodeView()
    private let labelStackView = UIStackView()
    private let addressLabel = UILabel()
    private let checkLabelImage = UIImageView()
    private let loadingView = QRLoadingView()
    private let shareButton = SmallButtonView()
    private let copyButton = SmallButtonView()

    var data: Data? {
        get {
            qrCodeView.data
        }
        set {
            qrCodeView.data = newValue
        }
    }

    var label: String? {
        didSet {
            addressLabel.text = label ?? ""
            // Hide the eye button when the address fits the screen
            checkLabelImage.isHidden = !addressLabel.isTruncated
        }
    }

    var loadingText: String? {
        get {
            return loadingView.text
        }
        set {
            loadingView.text = newValue
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                qrCodeView.isHidden = true
                addressLabel.text = ""
                checkLabelImage.isHidden = true
                loadingView.isHidden = false
            } else {
                qrCodeView.isHidden = false
                addressLabel.text = label
                loadingView.isHidden = true
            }
        }
    }

    weak var delegate: QRCodeWithActionsViewDelegate?

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.axis = .vertical
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        setUpQR()
        setUpLoadingView()
        setUpAddressLabel()
        setUpShareAndCopyButtons()

        makeViewTestable()
    }

    fileprivate func setUpQR() {
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.delegate = self

        stackView.addArrangedSubview(qrCodeView)

        NSLayoutConstraint.activate([
            qrCodeView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -.sideMargin * 2),
            qrCodeView.heightAnchor.constraint(equalTo: qrCodeView.widthAnchor)
        ])

        stackView.setCustomSpacing(16, after: qrCodeView)
    }

    fileprivate func setUpAddressLabel() {
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.spacing = 4
        labelStackView.distribution = .equalSpacing
        labelStackView.isUserInteractionEnabled = true
        labelStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapLabel))

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.textColor = Asset.Colors.muunGrayDark.color
        addressLabel.font = Constant.Fonts.system(size: .desc)
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingMiddle
        stackView.addArrangedSubview(labelStackView)
        stackView.setCustomSpacing(24, after: labelStackView)
        labelStackView.addArrangedSubview(addressLabel)

        checkLabelImage.translatesAutoresizingMaskIntoConstraints = false
        checkLabelImage.image = Asset.Assets.passwordShow.image
        labelStackView.addArrangedSubview(checkLabelImage)

        NSLayoutConstraint.activate([
            checkLabelImage.heightAnchor.constraint(equalToConstant: 18),
            checkLabelImage.widthAnchor.constraint(equalToConstant: 18),
            checkLabelImage.centerYAnchor.constraint(equalTo: addressLabel.centerYAnchor),
            labelStackView.widthAnchor.constraint(
                lessThanOrEqualTo: stackView.widthAnchor,
                constant: -.sideMargin * 2
            )
        ])
    }

    fileprivate func setUpLoadingView() {
        loadingView.isHidden = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -.sideMargin * 2),
            loadingView.heightAnchor.constraint(equalTo: loadingView.widthAnchor)
        ])
    }

    fileprivate func setUpShareAndCopyButtons() {
        let buttonsContainerView = UIStackView()
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.spacing = 8
        buttonsContainerView.distribution = .fillEqually
        stackView.addArrangedSubview(buttonsContainerView)

        NSLayoutConstraint.activate([
            buttonsContainerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: .sideMargin),
            buttonsContainerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -.sideMargin),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.delegate = self
        shareButton.buttonText = L10n.QRCodeWithActionsView.share
        buttonsContainerView.addArrangedSubview(shareButton)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.delegate = self
        copyButton.buttonText = L10n.QRCodeWithActionsView.copy
        buttonsContainerView.addArrangedSubview(copyButton)
    }

    @objc func didTapLabel() {
        delegate?.didTapLabel()
    }

}

extension QRCodeWithActionsView: QRCodeViewDelegate {

    internal func didTapQRCode() {
        delegate?.didTapQRCode()
    }

}

extension QRCodeWithActionsView: SmallButtonViewDelegate {

    internal func button(didPress button: SmallButtonView) {

        if button == copyButton {
            delegate?.didTapOnCopy()
        }

        if button == shareButton {
            delegate?.didTapOnShare()
        }
    }

}

extension QRCodeWithActionsView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.QRCodeWithActions

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(addressLabel, using: .address)
    }
}

fileprivate extension Selector {
    static let didTapLabel = #selector(QRCodeWithActionsView.didTapLabel)
}
