//
// Created by Juan Pablo Civile on 06/11/2021.
// Copyright (c) 2021 muun. All rights reserved.
//

import Foundation
import UIKit
import core

protocol RequestCloudViewDelegate: AnyObject {
    func dismiss(requestCloud: UIView)
    func request(cloud: String)
}

class RequestCloudView: UIView {

    private weak var delegate: RequestCloudViewDelegate?
    private let button = SmallButtonView()
    private let input = TextInputView()
    private let stack = UIStackView()

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    init(delegate: RequestCloudViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {

        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = .spacing
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standardMargins
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])
        stack.roundCorners(cornerRadius: 10, clipsToBounds: true)
        stack.backgroundColor = Asset.Colors.white.color

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

        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = Constant.Fonts.description
        description.textColor = Asset.Colors.muunGrayDark.color
        description.numberOfLines = 0
        description.text = L10n.RequestCloudView.description
        stack.addArrangedSubview(description)

        input.topLabel = ""
        input.bottomLabel = ""
        input.style = .small
        input.delegate = self
        input.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(input)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonText = L10n.RequestCloudView.send
        button.delegate = self
        button.isEnabled = false

        stack.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40)
        ])

    }

    @objc func tapClose() {
        delegate?.dismiss(requestCloud: self)
    }

    override func didMoveToSuperview() {
        guard let parent = superview else {
            return
        }

        NSLayoutConstraint.activate([
            parent.widthAnchor.constraint(equalTo: widthAnchor, constant: 2 * .sideMargin),
            stack.bottomAnchor.constraint(equalTo: parent.centerYAnchor)
        ])

        _ = input.becomeFirstResponder()
    }
}

extension RequestCloudView: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        button.isEnabled = text.count > 0
    }

}

extension RequestCloudView: SmallButtonViewDelegate {

    func button(didPress button: SmallButtonView) {
        delegate?.request(cloud: input.text)
    }

}
