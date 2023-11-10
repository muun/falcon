//
//  CreateInvoiceView.swift
//  Muun
//
//  Created by Lucas Serruya on 10/05/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit

protocol CreateInvoiceViewDelegate: AnyObject {
    func button(didPress button: SmallButtonView)
}

class CreateInvoiceView: UIView, SmallButtonViewDelegate {

    private var createAnotherInvoiceButton = SmallButtonView()
    private let expiredLabel = UILabel()

    weak var delegate: CreateInvoiceViewDelegate?

    @available(iOS, obsoleted: 1, message: "Use display and hide methods instead")
    override var isHidden: Bool {
        get {
            super.isHidden
        }
        set {
            super.isHidden = newValue
        }
    }

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func button(didPress button: SmallButtonView) {
        if button == createAnotherInvoiceButton {
            delegate?.button(didPress: button)
        }
    }

    func addAsFullSizeSubviewBindingDelegateTo<T: UIView & CreateInvoiceViewDelegate>(superView: T) {
        superView.addSubview(self)
        delegate = superView

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            topAnchor.constraint(equalTo: superView.topAnchor),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }

    func display(text: NSAttributedString, buttonText: String?) {
        expiredLabel.attributedText = text
        if let buttonText = buttonText {
            createAnotherInvoiceButton.buttonText = buttonText
        } else {
            createAnotherInvoiceButton.isHidden = true
        }
        super.isHidden = false
    }

    func hide() {
        super.isHidden = true
    }

    private func setUpView() {
        accessibilityViewIsModal = true
        backgroundColor = Asset.Colors.background.color
        translatesAutoresizingMaskIntoConstraints = false

        let overlayStackView = UIStackView()
        overlayStackView.translatesAutoresizingMaskIntoConstraints = false
        overlayStackView.spacing = 16
        overlayStackView.alignment = .center
        overlayStackView.axis = .vertical
        addSubview(overlayStackView)

        NSLayoutConstraint.activate([
            overlayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            overlayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            overlayStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        expiredLabel.style = .description
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
}
