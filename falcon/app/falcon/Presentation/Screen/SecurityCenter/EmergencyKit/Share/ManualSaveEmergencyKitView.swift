//
// Created by Juan Pablo Civile on 04/11/2021.
// Copyright (c) 2021 muun. All rights reserved.
//

import Foundation
import UIKit

protocol ManualSaveEmergencyKitViewDelegate: AnyObject {
    func save()
    func dismiss()
}

class ManualSaveEmergencyKitView: UIScrollView {

    private weak var viewDelegate: ManualSaveEmergencyKitViewDelegate?
    private let button: SmallButtonView = SmallButtonView()

    required init(coder: NSCoder) {
        preconditionFailure()
    }

    init(delegate: ManualSaveEmergencyKitViewDelegate) {
        self.viewDelegate = delegate
        super.init(frame: .zero)
        setupView()
        makeViewTestable()
    }

    private func setupView() {
        roundCorners(cornerRadius: 10, clipsToBounds: true)
        backgroundColor = Asset.Colors.white.color

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = .headerSpacing
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standardMargins
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let stackHeight = heightAnchor.constraint(equalTo: stack.heightAnchor)
        stackHeight.priority = .required - 1

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: widthAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackHeight,
        ])

        let cross = UIButton()
        cross.translatesAutoresizingMaskIntoConstraints = false
        cross.setImage(Asset.Assets.navClose.image, for: .normal)

        cross.setContentCompressionResistancePriority(.required, for: .vertical)
        cross.setContentHuggingPriority(.required, for: .vertical)

        cross.addTarget(self, action: #selector(tapClose), for: .touchUpInside)

        let crossContainer = UIView()
        crossContainer.translatesAutoresizingMaskIntoConstraints = false
        crossContainer.addSubview(cross)

        NSLayoutConstraint.activate([
            crossContainer.topAnchor.constraint(equalTo: cross.topAnchor),
            crossContainer.bottomAnchor.constraint(equalTo: cross.bottomAnchor),
            crossContainer.leadingAnchor.constraint(equalTo: cross.leadingAnchor),
            crossContainer.trailingAnchor.constraint(greaterThanOrEqualTo: cross.trailingAnchor),
        ])
        stack.addArrangedSubview(crossContainer)

        let title = TitleAndDescriptionView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.style = .bigTitle
        title.titleText = L10n.ManualSaveEmergencyKitView.title
        title.descriptionText = nil
        title.makeVisible()
        title.fixCompressionResistance()

        stack.addArrangedSubview(title)
        // title and description has margins built in
        stack.setCustomSpacing(0, after: crossContainer)
        stack.setCustomSpacing(.bigSpacing, after: title)

        stack.addArrangedSubview(buildRow(
            number: 1,
            text: L10n.ManualSaveEmergencyKitView.accesible,
            bold: L10n.ManualSaveEmergencyKitView.accesibleBold
        ))
        stack.addArrangedSubview(buildRow(
            number: 2,
            text: L10n.ManualSaveEmergencyKitView.secrecy,
            bold: L10n.ManualSaveEmergencyKitView.secrecyBold
        ))
        stack.addArrangedSubview(buildRow(
            number: 3,
            text: L10n.ManualSaveEmergencyKitView.update,
            bold: L10n.ManualSaveEmergencyKitView.updateBold
        ))

        stack.arrangedSubviews.last.map {
            stack.setCustomSpacing(.bigSpacing, after: $0)
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonText = L10n.ManualSaveEmergencyKitView.save
        button.delegate = self

        stack.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40)
        ])

    }

    private func buildRow(number: Int, text: String, bold: String) -> UIView {

        let iconView = UILabel()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.text = "\(number)."
        iconView.font = Constant.Fonts.system(size: .desc, weight: .bold)
        iconView.textColor = Asset.Colors.muunBlue.color

        iconView.setContentCompressionResistancePriority(.required, for: .vertical)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconView.setContentHuggingPriority(.required, for: .vertical)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = text.attributedForDescription()
            .set(bold: bold, color: Asset.Colors.black.color)
        label.textColor = Asset.Colors.black.color
        label.numberOfLines = 0

        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)

        let container = UIStackView(arrangedSubviews: [
            iconView,
            label
        ])

        container.axis = .horizontal
        container.alignment = .firstBaseline
        container.distribution = .fill
        container.spacing = .closeSpacing

        return container
    }

    @objc func tapClose() {
        viewDelegate?.dismiss()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let parent = superview {

            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: .sideMargin),
                parent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .sideMargin),
                topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor, constant: .sideMargin),
                parent.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: .sideMargin),
            ])
        }
    }
}

extension ManualSaveEmergencyKitView: SmallButtonViewDelegate {

    func button(didPress button: SmallButtonView) {
        viewDelegate?.save()
    }

}

extension ManualSaveEmergencyKitView: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.SharePDF

    func makeViewTestable() {
        makeViewTestable(self.button, using: .confirm)
    }

}
