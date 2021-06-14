//
//  TransactionListEmptyView.swift
//  falcon
//
//  Created by Federico Bond on 04/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol TransactionListEmptyViewDelegate: AnyObject {
    func didTapOnLoadWallet()
}

final class TransactionListEmptyView: UIView {

    private var contentsStackView: UIStackView! = UIStackView()

    private weak var delegate: TransactionListEmptyViewDelegate?

    init(delegate: TransactionListEmptyViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpStackView()
        setUpImageView()
        setUpLabels()
    }

    fileprivate func setUpStackView() {
        contentsStackView.axis = .vertical
        contentsStackView.alignment = .center
        contentsStackView.distribution = .fill
        contentsStackView.spacing = 24

        contentsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentsStackView)
        NSLayoutConstraint.activate([
            contentsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            contentsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }

    fileprivate func setUpImageView() {
        let imageView = UIImageView(image: Asset.Assets.emptyTransactions.image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentsStackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 136),
            imageView.widthAnchor.constraint(equalToConstant: 240)
        ])
    }

    fileprivate func setUpLabels() {
        setUpTitleLabel()
        setUpDescriptionLabel()
    }

    fileprivate func setUpTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.style = .title
        titleLabel.textAlignment = .center
        titleLabel.text = L10n.TransactionListEmptyView.title

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsStackView.addArrangedSubview(titleLabel)
        contentsStackView.setCustomSpacing(8, after: titleLabel)
    }

    fileprivate func setUpDescriptionLabel() {
        let descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.style = .description
        descLabel.textAlignment = .center
        descLabel.attributedText = L10n.TransactionListEmptyView.description
            .attributedForDescription(alignment: .center)
            .set(underline: L10n.TransactionListEmptyView.descriptionCta, color: Asset.Colors.muunBlue.color)
        descLabel.isUserInteractionEnabled = true
        descLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .loadWalletTap))

        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsStackView.addArrangedSubview(descLabel)
    }

    @objc internal func loadWalletTap() {
        delegate?.didTapOnLoadWallet()
    }
}

fileprivate extension Selector {
    static let loadWalletTap = #selector(TransactionListEmptyView.loadWalletTap)
}
