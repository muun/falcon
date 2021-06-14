//
//  ErrorView.swift
//  falcon
//
//  Created by Manu Herrera on 26/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol ErrorViewDelegate: AnyObject {
    func retryTouched()
    func sendReportTouched()
    func backToHomeTouched()
    func logErrorView(_ name: String, params: [String: Any]?)
    func descriptionTouched(type: ErrorViewModel)
}

extension ErrorViewDelegate {
    func retryTouched() {} // default implementation
    func sendReportTouched() {} // default implementation
}

extension ErrorViewDelegate {
    // In most cases we dont want to do anything so this is the default implementation
    func descriptionTouched(type: ErrorViewModel) {}
}

enum ErrorViewKind {
    case retryable
    case reportable
    case final
}

protocol ErrorViewModel {
    func title() -> String
    func description() -> NSAttributedString
    func firstBoxTexts() -> (title: String, content: NSAttributedString)?
    func secondBoxTexts() -> (title: String, content: NSAttributedString)?
    func loggingName() -> String
    func kind() -> ErrorViewKind
}

extension ErrorViewModel {

    func kind() -> ErrorViewKind {
        return .final
    }

    func firstBoxTexts() -> (title: String, content: NSAttributedString)? {
        return nil
    }

    func secondBoxTexts() -> (title: String, content: NSAttributedString)? {
        return nil
    }
}

class ErrorView: UIView {

    private let scrollView = UIScrollView()
    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var firstBox = UIView()
    private var firstTitleLabel = UILabel()
    private var firstLabel = UILabel()
    private var secondBox = UIView()
    private var secondTitleLabel = UILabel()
    private var secondLabel = UILabel()

    private let buttonsStackView = UIStackView()
    private var primaryButton = ButtonView()
    private var secondaryButton = LinkButtonView()

    weak var delegate: ErrorViewDelegate?

    public var model: ErrorViewModel? {
        didSet {
            updateView()
        }
    }

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
        backgroundColor = Asset.Colors.background.color
        
        setUpLabels()
        setUpButtons()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),

            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        labelsStackView.axis = .vertical
        labelsStackView.alignment = .center
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: .sideMargin),
            labelsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -.sideMargin),
            labelsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * .sideMargin),
            labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor)
        ])

        let imageView = UIImageView()
        imageView.image = Asset.Assets.stateError.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(imageView)
        labelsStackView.setCustomSpacing(24, after: imageView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 96),
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.topAnchor.constraint(equalTo: labelsStackView.topAnchor, constant: 120)
        ])

        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.setCustomSpacing(8, after: titleLabel)

        descriptionLabel.style = .description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(descriptionLabel)
        labelsStackView.setCustomSpacing(24, after: descriptionLabel)

        firstTitleLabel.textColor = Asset.Colors.title.color
        firstTitleLabel.font = Constant.Fonts.system(size: .helper, weight: .semibold)
        firstTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(firstTitleLabel)
        labelsStackView.setCustomSpacing(8, after: firstTitleLabel)

        firstLabel.textColor = Asset.Colors.muunGrayDark.color
        firstLabel.font = Constant.Fonts.description
        firstLabel.numberOfLines = 0
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(firstLabel)
        labelsStackView.setCustomSpacing(16, after: firstLabel)

        secondTitleLabel.textColor = Asset.Colors.title.color
        secondTitleLabel.font = Constant.Fonts.system(size: .helper, weight: .semibold)
        secondTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(secondTitleLabel)
        labelsStackView.setCustomSpacing(8, after: secondTitleLabel)

        secondLabel.textColor = Asset.Colors.muunGrayDark.color
        secondLabel.font = Constant.Fonts.description
        secondLabel.numberOfLines = 0
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(secondLabel)
    }

    fileprivate func setUpButtons() {
        buttonsStackView.axis = .vertical
        buttonsStackView.alignment = .fill
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsStackView)

        secondaryButton.delegate = self
        secondaryButton.buttonText = L10n.ErrorView.goToHome
        secondaryButton.isEnabled = true
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(secondaryButton)

        primaryButton.delegate = self
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(primaryButton)
    }

    private func updateView() {
        titleLabel.text = model?.title()
        descriptionLabel.attributedText = model?.description()
        setFirstBox()
        setSecondBox()
        setButtons()

        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .descriptionTouched))
    }

    private func setButtons() {
        switch model?.kind() ?? .final {
        case .retryable:
            primaryButton.isHidden = false
            primaryButton.buttonText = L10n.ErrorView.retry
        case .reportable:
            primaryButton.isHidden = false
            primaryButton.buttonText = L10n.ErrorView.sendReport
        case .final:
            primaryButton.isHidden = true
        }
    }

    @objc fileprivate func descriptionTouched() {
        if let model = model {
            delegate?.descriptionTouched(type: model)
        }
    }

    private func setFirstBox() {
        if let firstBoxInfo = model?.firstBoxTexts() {
            firstTitleLabel.text = firstBoxInfo.title.uppercased()
            firstLabel.attributedText = firstBoxInfo.content
        } else {
            firstBox.isHidden = true
        }
    }

    private func setSecondBox() {
        if let secondBoxInfo = model?.secondBoxTexts() {
            secondTitleLabel.text = secondBoxInfo.title.uppercased()
            secondLabel.attributedText = secondBoxInfo.content
        } else {
            secondBox.isHidden = true
        }
    }

    func addTo(_ view: UIView) {
        self.alpha = 0
        self.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self)
        self.frame = view.bounds

        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        if let model = model {
            // Special-casing for NewOpError to avoid changing behavior
            if model is NewOpError {
                delegate?.logErrorView("new_op_error", params: ["type": model.loggingName()])
            } else {
                delegate?.logErrorView("error", params: ["type": model.loggingName()])
            }
        }

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

}

extension ErrorView: ButtonViewDelegate {
    func button(didPress button: ButtonView) {
        switch model?.kind() {
        case .retryable:
            delegate?.retryTouched()
        case .reportable:
            delegate?.sendReportTouched()
        default:
            break
        }
    }
}

extension ErrorView: LinkButtonViewDelegate {
    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.backToHomeTouched()
    }
}

extension ErrorView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ErrorPage

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(titleLabel, using: .titleLabel)
        makeViewTestable(descriptionLabel, using: .descriptionLabel)
        makeViewTestable(primaryButton, using: .primaryButton)
        makeViewTestable(secondaryButton, using: .secondaryButton)
    }
}

fileprivate extension Selector {
    static let descriptionTouched = #selector(ErrorView.descriptionTouched)
}
