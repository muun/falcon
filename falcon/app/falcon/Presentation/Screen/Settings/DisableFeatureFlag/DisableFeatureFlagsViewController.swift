//
//  DisableFeatureFlagsViewController.swift
//  falcon
//
//  Created by Daniel Mankowski on 05/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import UIKit

final class DisableFeatureFlagsViewController: MUViewController {

    // MARK: - Properties
    private let contentView = UIView()
    private let disableNfcCardStackView = UIStackView()
    private let informationLabelView = UILabel()
    private let disableNfcLabelView = UILabel()
    private let toggleButton = UISwitch()

    private lazy var presenter = instancePresenter(
        DisableFeatureFlagsPresenter.init,
        delegate: self
    )

    override var screenLoggingName: String {
        return "disable_feature_flag"
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setUp()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.setUp()
        toggleButton.setOn(presenter.isNfcCardEnabled, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    // MARK: - Private Methods
    private func configureViews() {
        view.backgroundColor = .white
        title = L10n.DisableFeatureFlagsViewController.title

        configureContentView()
        configureStackViews()
        configureLabels()
        configureToggles()
    }

    private func configureContentView() {
        view.addSubview(contentView)
        contentView.addSubview(informationLabelView)
        contentView.addSubview(disableNfcCardStackView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: .spacing
            ),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureStackViews() {
        disableNfcCardStackView.axis = .horizontal
        disableNfcCardStackView.alignment = .center
        disableNfcCardStackView.spacing = .closeSpacing
        disableNfcCardStackView.distribution = .fill
        disableNfcCardStackView.translatesAutoresizingMaskIntoConstraints = false
        disableNfcCardStackView.addArrangedSubview(disableNfcLabelView)
        disableNfcCardStackView.addArrangedSubview(toggleButton)

        NSLayoutConstraint.activate([
            disableNfcCardStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .closeSpacing
            ),
            disableNfcCardStackView.topAnchor.constraint(
                equalTo: informationLabelView.bottomAnchor,
                constant: .bigSpacing
            ),
            disableNfcCardStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -.closeSpacing
            )
        ])
    }

    private func configureLabels() {
        disableNfcLabelView.numberOfLines = 0
        disableNfcLabelView.textAlignment = .left
        disableNfcLabelView.text = L10n.DisableFeatureFlagsViewController.nfcLabel
        disableNfcLabelView.font = Constant.Fonts.system(size: .desc, weight: .bold)
        disableNfcLabelView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        disableNfcLabelView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        informationLabelView.translatesAutoresizingMaskIntoConstraints = false
        informationLabelView.numberOfLines = 0
        informationLabelView.textColor = .gray
        informationLabelView.text = L10n.DisableFeatureFlagsViewController.informationLabel
        NSLayoutConstraint.activate([
            informationLabelView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .closeSpacing
            ),
            informationLabelView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: .closeSpacing
            ),
            informationLabelView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -.closeSpacing
            )
        ])
    }

    private func configureToggles() {
        toggleButton.setContentHuggingPriority(.required, for: .horizontal)
        toggleButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        toggleButton.addTarget(
            self,
            action: #selector(didTapToggle),
            for: UIControl.Event.valueChanged
        )
    }

    @objc func didTapToggle() {
        presenter.setNfcFlagEnabled(toggleButton.isOn)
    }
}

extension DisableFeatureFlagsViewController: DisableFeatureFlagsPresenterDelegate {}
