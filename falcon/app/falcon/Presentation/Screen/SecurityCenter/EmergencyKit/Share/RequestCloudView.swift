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
    private let feedbackView = RequestCloudFeedbackView()

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    init(delegate: RequestCloudViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        addKeyboardWillHideNotification()

        setupStackView()

        addCrossToStackView()
        addDescriptionToStackView()
        addInputLabelToStackview()
        addButtonToStackView()
        addFeedbackView()
    }

    @objc func tapClose() {
        delegate?.dismiss(requestCloud: self)
    }

    override func didMoveToSuperview() {
        guard let parent = superview else {
            return
        }

        setStackCentering(parent)

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
        feedbackView.isHidden = false
        self.delegate?.request(cloud: self.input.text)

        let dismissTimeInSeconds: CGFloat = 3
        endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissTimeInSeconds) {
            self.delegate?.dismiss(requestCloud: self)
        }
    }
}

private extension RequestCloudView {
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        self.layoutIfNeeded()
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo?[durationKey] as? Double ?? 0

        let stackCenterYConstraint = stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        stackCenterYConstraint.isActive = true

        self.setNeedsLayout()

        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
        })
    }

    func setupStackView() {
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
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
        roundCornersAndSetBgColortTo(container: stack)
    }

    func addCrossToStackView() {
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
            crossContainer.trailingAnchor.constraint(greaterThanOrEqualTo: cross.trailingAnchor)
        ])
        stack.addArrangedSubview(crossContainer)
    }

    func addDescriptionToStackView() {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = Constant.Fonts.description
        description.textColor = Asset.Colors.muunGrayDark.color
        description.numberOfLines = 0
        description.text = L10n.RequestCloudView.description
        stack.addArrangedSubview(description)
    }

    func addInputLabelToStackview() {
        input.topLabel = ""
        input.bottomLabel = ""
        input.style = .small
        input.delegate = self
        input.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(input)
    }

    func addButtonToStackView() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonText = L10n.RequestCloudView.send
        button.delegate = self
        button.isEnabled = false

        stack.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func addFeedbackView() {
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        roundCornersAndSetBgColortTo(container: feedbackView)
        addSubview(feedbackView)

        NSLayoutConstraint.activate([
            feedbackView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            feedbackView.heightAnchor.constraint(equalTo: stack.heightAnchor),
            feedbackView.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            feedbackView.centerYAnchor.constraint(equalTo: stack.centerYAnchor)
        ])

        feedbackView.isHidden = true
    }

    func addKeyboardWillHideNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func roundCornersAndSetBgColortTo(container: UIView) {
        container.roundCorners(cornerRadius: 10, clipsToBounds: true)
        container.backgroundColor = Asset.Colors.white.color
    }

    func setStackCentering(_ parent: UIView) {
        let stackCenterYConstraint = stack.bottomAnchor.constraint(equalTo: parent.centerYAnchor)
        stackCenterYConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            parent.widthAnchor.constraint(equalTo: widthAnchor, constant: 2 * .sideMargin),
            stackCenterYConstraint
        ])
    }
}
