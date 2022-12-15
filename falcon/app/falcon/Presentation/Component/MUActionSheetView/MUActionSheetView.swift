//
//  MUActionSheetView.swift
//  falcon
//
//  Created by Federico Bond on 12/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol MUActionSheetViewDelegate: AnyObject {
    func didSelect(option: any MUActionSheetOption)
}

protocol MUActionSheetOption: RawRepresentable<String> {
    var name: String { get }
    var description: NSAttributedString { get }
}

/**
 In order to use this view you will have to init it with the delegate in which you will receive the selected item,
 the header title for customization and the options that will be displayed to the user.
 The option will ask you for a hightlight and a blockHeight. Do not worry about this two things unless you need it.
 If you need it feel free to get how this two parameters work and then complete this doc :)
 MUActionSheetOptionViewModel is a model to retrieve your MUActionSheetOption in a way the action sheet is able
 to understand. Do not use it for anything  else.
 */
class MUActionSheetView: UIViewController {
    private weak var delegate: MUActionSheetViewDelegate?
    private let headerTitle: String
    private let viewOptions: [MUActionSheetOptionViewModel]
    private let screenNameForLogs: String

    init(delegate: MUActionSheetViewDelegate,
         headerTitle: String,
         screenNameForLogs: String,
         viewOptions: [MUActionSheetOptionViewModel]) {
        self.delegate = delegate
        self.headerTitle = headerTitle
        self.viewOptions = viewOptions
        self.screenNameForLogs = screenNameForLogs

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override var screenLoggingName: String {
        return screenNameForLogs
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This log is usually logged by a MUViewController parent. Since MUViewController only support pushing
        // VC instead of presententing them, I added this log in order to get the screen logged. As a future work we
        // must refactor MUViewController in order to support presetingVCs
        logScreen()
    }

    private func setUpView() {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapDismiss))
        view.autoresizingMask = .flexibleHeight

        let dialogView = createDialogStackView()
        addBackgroundView(to: dialogView)
        addTitleLabel(to: dialogView)
        addSelectableOptions(to: dialogView)
    }

    @objc func didTapDismiss() {
        dismiss(animated: true)
    }
}

extension MUActionSheetView: MUActionSheetCardDelegate {

    func tapped(actionSheetCard: MUActionSheetCard) {
        delegate?.didSelect(option: actionSheetCard.selectedOptionType)
        dismiss(animated: true)
    }
}

extension MUActionSheetView: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return ModalAnimationController(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalAnimationController(presenting: false)
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }

}

fileprivate extension Selector {
    static let didTapDismiss = #selector(MUActionSheetView.didTapDismiss)
}

private extension MUActionSheetView {
    func createDialogStackView() -> UIStackView {
        var margins: UIEdgeInsets = .standardMargins
        margins.top = .bigSpacing

        let dialogView = UIStackView()
        dialogView.axis = .vertical
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.isLayoutMarginsRelativeArrangement = true
        dialogView.layoutMargins = margins
        dialogView.spacing = .spacing
        dialogView.alignment = .fill
        view.addSubview(dialogView)

        NSLayoutConstraint.activate([
            dialogView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return dialogView
    }

    func addBackgroundView(to container: UIView) {
        // Add background, see https://stackoverflow.com/a/34868367/368861
        let background = UIView(frame: container.bounds)
        background.backgroundColor = Asset.Colors.cellBackground.color
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(background)
    }

    func addTitleLabel(to dialogView: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = headerTitle
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.textAlignment = .natural
        titleLabel.textColor = Asset.Colors.black.color
        dialogView.addArrangedSubview(titleLabel)
        dialogView.setCustomSpacing(.headerSpacing, after: titleLabel)
    }

    func addSelectableOptions(to dialogView: UIStackView) {
        for viewOption in viewOptions {
            dialogView.addArrangedSubview(MUActionSheetCard(
                selectedOptionType: viewOption.type,
                status: viewOption.status,
                delegate: self,
                highlight: viewOption.highlight
            ))
        }
    }
}
