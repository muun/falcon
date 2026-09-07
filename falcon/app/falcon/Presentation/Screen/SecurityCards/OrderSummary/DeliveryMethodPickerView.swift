//
//  DeliveryMethodPickerView.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol DeliveryMethodPickerViewDelegate: AnyObject {
    func didSelectDeliverySpeed(_ speed: DeliveryOption.Speed)
}

/// Stateless: it renders the given options and reports taps. The selected speed is
/// owned by the presenter and pushed back via `updateSelection(_:)`.
final class DeliveryMethodPickerView: UIView {

    private weak var delegate: DeliveryMethodPickerViewDelegate?
    private let stackView = UIStackView()
    private var optionViews: [DeliveryOption.Speed: DeliveryMethodOptionView] = [:]

    init(options: [DeliveryMethodOptionViewModel], delegate: DeliveryMethodPickerViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setUpStackView()
        addOptions(options)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateSelection(_ speed: DeliveryOption.Speed) {
        for (optionSpeed, view) in optionViews {
            view.configure(with: view.viewModel.withSelected(optionSpeed == speed))
        }
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = MuunTheme.Spacing.md
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func addOptions(_ viewModels: [DeliveryMethodOptionViewModel]) {
        for viewModel in viewModels {
            let view = DeliveryMethodOptionView(viewModel: viewModel)
            view.addAction(
                UIAction { [weak self] _ in
                    self?.delegate?.didSelectDeliverySpeed(viewModel.speed) },
                for: .touchUpInside
            )
            optionViews[viewModel.speed] = view
            stackView.addArrangedSubview(view)
        }
    }
}
