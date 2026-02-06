//
//  DisableFlagTableViewCell.swift
//  falcon
//
//  Created by Daniel Mankowski on 18/12/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import UIKit

protocol DisableFlagTableViewCellDelegate: AnyObject {
    func disableFlagToggleValueChanged(flag: FeatureFlags, isOn: Bool)
}

final class DisableFlagTableViewCell: UITableViewCell {

    static let reuseIdentifier = "DisableFlagTableViewCell"

    weak var delegate: DisableFlagTableViewCellDelegate?

    private var flag: FeatureFlags?

    private lazy var nameLabel: UILabel = .init()
    private lazy var descriptionLabel: UILabel = .init()
    private lazy var toggleButton: UISwitch = .init()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = nil
        descriptionLabel.text = nil
    }

    private func setUpView() {
        backgroundColor = Asset.Colors.cellBackground.color
        setUpLabels()
        setUpConstraints()
        setUpToggle()
    }

    private func setUpLabels() {
        nameLabel.font = Constant.Fonts.system(size: .desc, weight: .bold)
        descriptionLabel.font = Constant.Fonts.system(size: .opDesc, weight: .thin)
    }

    private func setUpConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        toggleButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(toggleButton)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .closeSpacing),
            nameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .closeSpacing
            ),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .closeSpacing
            ),
            descriptionLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -.closeSpacing
            ),
            toggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -.closeSpacing
            ),
            toggleButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: descriptionLabel.trailingAnchor,
                constant: .closeSpacing
            ),
            toggleButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: nameLabel.trailingAnchor,
                constant: .closeSpacing
            )
        ])
    }

    private func setUpToggle() {
        toggleButton.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
    }

    @objc func toggleValueChanged() {
        guard let flag else { return }
        delegate?.disableFlagToggleValueChanged(flag: flag, isOn: toggleButton.isOn)
    }

    func setUp(flag: FeatureFlags, isOn: Bool) {
        self.flag = flag
        self.nameLabel.text = flag.rawValue
        self.toggleButton.isOn = isOn
        if case let .overridable(humanReadableDescription, _) = flag.overrideMetadata {
            self.descriptionLabel.text = humanReadableDescription
        } else {
            // It should not be executed, all the flags are overridable at this point.
            self.descriptionLabel.text = ""
        }
    }
}
