//
//  AddressTypeSelectViewController.swift
//  falcon
//
//  Created by Federico Bond on 12/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol ReceiveAddressTypeSelectViewControllerDelegate: AnyObject {
    func didSelect(addressType: AddressType)
}

class ReceiveAddressTypeSelectViewController: UIViewController, PresenterInstantior {

    private weak var delegate: ReceiveAddressTypeSelectViewControllerDelegate?
    private lazy var presenter = instancePresenter(ReceiveAddressTypeSelectPresenter.init, delegate: self)

    private var selectedAddressType: AddressType

    init(delegate: ReceiveAddressTypeSelectViewControllerDelegate,
         addressType: AddressType) {

        self.delegate = delegate
        self.selectedAddressType = addressType
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override var screenLoggingName: String {
        return "receive_address_type_select"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    private func setUpView() {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapDismiss))
        view.autoresizingMask = .flexibleHeight

        var margins: UIEdgeInsets = .standardMargins
        margins.top = .bigSpacing

        let dialogView = UIStackView()
        dialogView.axis = .vertical
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.isLayoutMarginsRelativeArrangement = true
        dialogView.layoutMargins = margins
        dialogView.spacing = .spacing
        dialogView.alignment = .fill

        // Add background, see https://stackoverflow.com/a/34868367/368861
        let background = UIView(frame: dialogView.bounds)
        background.backgroundColor = Asset.Colors.cellBackground.color
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dialogView.addSubview(background)

        view.addSubview(dialogView)

        NSLayoutConstraint.activate([
            dialogView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = L10n.AddressTypeSelectViewController.title
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.textAlignment = .natural
        titleLabel.textColor = Asset.Colors.black.color
        dialogView.addArrangedSubview(titleLabel)

        for addressType in presenter.addressTypes() {
            let status: AddressTypeCard.Status
            var highlight: String? = nil

            if addressType.type == selectedAddressType {
                status = .selected
            } else if addressType.enabled {
                status = .enabled
            } else {
                status = .disabled
                if addressType.type == .taproot {
                    highlight = L10n.AddressTypeOptionView.taprootActivation(
                        String(describing: BlockHelper.hoursFor(addressType.blocksLeft))
                    )
                }
            }

            dialogView.addArrangedSubview(AddressTypeCard(
                addressType: addressType.type,
                status: status,
                delegate: self,
                highlight: highlight
            ))
        }

        dialogView.setCustomSpacing(.headerSpacing, after: titleLabel)

    }

    @objc func didTapDismiss() {
        dismiss(animated: true)
    }

}

extension ReceiveAddressTypeSelectViewController: AddressTypeCardDelegate {

    func tapped(addressTypeCard: AddressTypeCard) {
        delegate?.didSelect(addressType: addressTypeCard.addressType)
        dismiss(animated: true)
    }
}

extension ReceiveAddressTypeSelectViewController: UIViewControllerTransitioningDelegate {

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

extension ReceiveAddressTypeSelectViewController: BasePresenterDelegate {

    func showMessage(_ message: String) {
        Logger.fatal("Unsupported call to showMessage")
    }

    func pushTo(_ vc: MUViewController) {
        Logger.fatal("Unsupported call to pushTo")
    }

}

fileprivate extension Selector {

    static let didTapDismiss = #selector(ReceiveAddressTypeSelectViewController.didTapDismiss)

}
