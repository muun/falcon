//
//  RadioGroupView.swift
//  falcon
//
//  Created by Federico Bond on 12/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol RadioGroupViewDelegate: class {
    func didSelect(choice: String)
}

class RadioGroupView: UIStackView {

    private let options: [String]

    private var optionViews: [OptionView] = []

    private weak var delegate: RadioGroupViewDelegate?

    init(delegate: RadioGroupViewDelegate?, options: [String]) {
        self.options = options
        self.delegate = delegate

        super.init(frame: .zero)

        setUpView()
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Views Layout and configuration -

    private func setUpView() {
        axis = .vertical

        for option in options {
            let optionView = OptionView(label: option)
            optionView.translatesAutoresizingMaskIntoConstraints = false
            addArrangedSubview(optionView)

            optionView.isUserInteractionEnabled = true
            optionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapOption))

            optionViews.append(optionView)
        }

    }

    // MARK: - View Controller Actions -

    func setSelected(option label: String) {

        // Mark the option view with the specified label as selected and unselect the rest
        for option in optionViews {
            option.selected = (option.label == label)
        }
    }

    // MARK: - UI Handlers -

    @objc fileprivate func didTapOption(sender: UITapGestureRecognizer) {

        // Mark the tap sender option view as selected and unselect the rest
        for option in optionViews {
            option.selected = (option == sender.view)
        }

        if let option = sender.view as? OptionView {
            delegate?.didSelect(choice: option.label)
        }
    }

}

private class OptionView: UIView {

    private let radio = UIImageView()
    private let labelView = UILabel()

    var label: String {
        didSet {
            labelView.text = label
        }
    }

    var selected: Bool {
        didSet {
            didSelect()
        }
    }

    init(label: String, selected: Bool = false) {
        self.label = label
        self.selected = selected
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        radio.translatesAutoresizingMaskIntoConstraints = false
        addSubview(radio)

        labelView.text = label
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)

        NSLayoutConstraint.activate([
            radio.centerYAnchor.constraint(equalTo: centerYAnchor),
            radio.leadingAnchor.constraint(equalTo: leadingAnchor),
            radio.widthAnchor.constraint(equalToConstant: 20),
            radio.heightAnchor.constraint(equalTo: radio.widthAnchor),

            labelView.leadingAnchor.constraint(equalTo: radio.trailingAnchor, constant: 18),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 50)
        ])

        didSelect()
    }

    private func didSelect() {
        if selected {
            labelView.font = Constant.Fonts.system(size: .desc, weight: .semibold)
            radio.image = Asset.Assets.radioOptionSelected.image
        } else {
            labelView.font = Constant.Fonts.system(size: .desc, weight: .regular)
            radio.image = Asset.Assets.radioOption.image
        }
    }

}

fileprivate extension Selector {

    static let didTapOption = #selector(RadioGroupView.didTapOption(sender:))

}
