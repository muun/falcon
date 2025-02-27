//
//  TurboChannelsView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//


import UIKit

final class ReceiveFormatSettingDropdownView: MUView, PresenterInstantior {
    private let subtitle: UILabel
    private let title: String
    private let controlView = UIStackView()
    private let controlButton = UIButton()

    weak var presenter: SettingsDropdownPresenter? {
        didSet {
            presenter?.setUp()
        }
    }

    var state: ReceiveFormatPreferenceViewModel = .ONCHAIN {
        didSet {
            controlButton.setTitle(state.shortName, for: .normal)
        }
    }

    var loading = false {
        didSet {
            isUserInteractionEnabled = !loading
        }
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(title: String,
         subtitle: UILabel) {
        self.title = title
        self.subtitle = subtitle
        super.init(frame: CGRect.zero)
    }

    override func didMoveToWindow() {
        // If we set this in setUp something seems to reset it
        backgroundColor = Asset.Colors.muunHomeBackgroundColor.color
    }

    override func setUp() {
        let mainStackView = createMainStack()
        addHairline(to: mainStackView)

        let toggleStackView = addToggleStackView(to: mainStackView)
        addTitleLabel(to: toggleStackView)
        addControlView(to: toggleStackView)
        addHairline(to: mainStackView)
        addSpacer(to: mainStackView)
        addSubtitle(to: mainStackView)
    }

    @objc func didTapControl() {
        presenter?.didTapDropdown()
    }

    deinit {
        presenter?.tearDown()
    }

    func presentActionSheet(actionSheetDelegate: MUActionSheetViewDelegate,
                            selectedOption: any MUActionSheetOption) {
        let vc = MUActionSheetView(
            delegate: actionSheetDelegate,
            headerTitle: L10n.ReceiveFormatSettingDropdownView.receiveFormatActionSheetTitle,
            screenNameForLogs: "receive_format_select",
            viewOptions: ReceiveFormatOptionsRetriever.run(selectedOption: selectedOption))

        present(vc, animated: true, completion: nil)
    }
}

private extension ReceiveFormatSettingDropdownView {
    private func addControlView(to stackView: UIStackView) {
        controlButton.addTarget(self, action: .didTapControl, for: .touchUpInside)
        controlButton.semanticContentAttribute = .forceRightToLeft
        controlButton.setImage(Asset.Assets.chevronAlt.image, for: .normal)
        controlButton.titleLabel?.font = Constant.Fonts.system(size: .desc)
        controlButton.setTitleColor(Asset.Colors.muunGrayDark.color, for: .normal)
        controlView.axis = .horizontal
        controlView.distribution = .equalCentering
        controlView.alignment = .center
        controlView.isUserInteractionEnabled = true

        controlView.addArrangedSubview(controlButton)

        controlView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(controlView)
    }

    func createMainStack() -> UIStackView {
        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.alignment = .center
        verticalStack.distribution = .fillProportionally
        verticalStack.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.spacing = 12

        addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            verticalStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            verticalStack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        return verticalStack
    }

    func addToggleStackView(to mainStackView: UIStackView) -> UIStackView {
        let toggleStackView = UIStackView()
        toggleStackView.translatesAutoresizingMaskIntoConstraints = false
        toggleStackView.axis = .horizontal
        toggleStackView.alignment = .center
        toggleStackView.distribution = .equalSpacing
        toggleStackView.backgroundColor = Asset.Colors.cellBackground.color
        toggleStackView.spacing = Constant.Dimens.viewControllerPadding
        toggleStackView.layoutMargins = UIEdgeInsets(top: 0,
                                                     left: Constant.Dimens.viewControllerPadding,
                                                     bottom: 0,
                                                     right: Constant.Dimens.viewControllerPadding)
        toggleStackView.isLayoutMarginsRelativeArrangement = true

        mainStackView.addArrangedSubview(toggleStackView)
        mainStackView.setCustomSpacing(0, after: toggleStackView)

        NSLayoutConstraint.activate([
            toggleStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            toggleStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            toggleStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        return toggleStackView
    }

    func addTitleLabel(to toggleStackView: UIStackView) {
        let titleLabel = UILabel()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        // Don't shrink unless needed to
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        // Strech as much as needed
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        toggleStackView.addArrangedSubview(titleLabel)
    }

    func addSubtitle(to mainStackView: UIStackView) {
        mainStackView.addArrangedSubview(subtitle)
        NSLayoutConstraint.activate([
            subtitle.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor,
                                               constant: -Constant.Dimens.viewControllerPadding),
            subtitle.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor,
                                                    constant: Constant.Dimens.viewControllerPadding)
        ])
    }

    private func addHairline(to stackView: UIStackView) {
        let hairline = HairlineView()
        hairline.color = Asset.Colors.title.color.withAlphaComponent(0.12)
        stackView.addArrangedSubview(hairline)
        NSLayoutConstraint.activate([
            hairline.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])

        stackView.setCustomSpacing(0, after: hairline)
    }

    func addSpacer(to mainStackView: UIStackView) {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        mainStackView.addArrangedSubview(spacer)
    }
}

extension ReceiveFormatSettingDropdownView: SettingsDropdownPresenterDelegate {
}

fileprivate extension Selector {
    static let didTapControl = #selector(ReceiveFormatSettingDropdownView.didTapControl)
}

enum ReceiveFormatPreferenceViewModel: String, MUActionSheetOption {
    case ONCHAIN
    case LIGHTNING
    case UNIFIED

    var name: String {
        return getValue(onChain: L10n.ReceiveFormatSettingDropdownView.receiveFormatBTCOption,
                        lightning: L10n.ReceiveFormatSettingDropdownView.receiveFormatLNOption,
                        unified: L10n.ReceiveFormatSettingDropdownView.receiveFormatUnifiedOption)
    }

    var shortName: String {
        return getValue(onChain: L10n.ReceiveFormatSettingDropdownView.bitcoinCurrentValue,
                        lightning: L10n.ReceiveFormatSettingDropdownView.lightningCurrentValue,
                        unified: L10n.ReceiveFormatSettingDropdownView.receiveFormatUnifiedOption)
    }

    var description: NSAttributedString {
        let btcDesc = L10n.ReceiveFormatSettingDropdownView.receiveFormatBTCDescription.toAttributedString()
        let lndDesc = L10n.ReceiveFormatSettingDropdownView.receiveFormatLNDescription.toAttributedString()
        return getValue(onChain: btcDesc,
                        lightning: lndDesc,
                        unified: getUnifiedDescription())
    }

    private func getUnifiedDescription() -> NSAttributedString {
        let text = L10n.ReceiveFormatSettingDropdownView.receiveFormatUnifiedDescription
            .set(font: Constant.Fonts.system(size: .helper))
            .set(tint: L10n.ReceiveFormatSettingDropdownView.receiveFormatUnifiedDescriptionUnderline,
                 color: Asset.Colors.black.color)
        return text
    }

    private func getValue<T: Any>(onChain: T, lightning: T, unified: T) -> T {
        switch self {
        case .ONCHAIN: return onChain
        case .LIGHTNING: return lightning
        case .UNIFIED: return unified
        }
    }

    static func from(model: ReceiveFormatPreference) -> ReceiveFormatPreferenceViewModel {
        return ReceiveFormatPreferenceViewModel(rawValue: model.rawValue)!
    }
}
