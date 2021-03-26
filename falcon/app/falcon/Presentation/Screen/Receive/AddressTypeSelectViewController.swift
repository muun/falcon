//
//  AddressTypeSelectViewController.swift
//  falcon
//
//  Created by Federico Bond on 12/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol ReceiveAddressTypeSelectViewControllerDelegate: class {
    func didSelect(addressType: AddressType)
}

class ReceiveAddressTypeSelectViewController: UIViewController {

    private weak var delegate: ReceiveAddressTypeSelectViewControllerDelegate?

    private var addressType: AddressType

    init(delegate: ReceiveAddressTypeSelectViewControllerDelegate,
         addressType: AddressType) {

        self.delegate = delegate
        self.addressType = addressType
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

        let dialogView = UIStackView()
        dialogView.axis = .vertical
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.isLayoutMarginsRelativeArrangement = true
        dialogView.layoutMargins = UIEdgeInsets(top: .bottomDrawerTopMargin, left: .sideMargin, bottom: .sideMargin, right: .sideMargin)

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
        titleLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        let options = AddressType.allValues.map { $0.description }
        let radioGroupView = RadioGroupView(delegate: self, options: options)
        radioGroupView.setSelected(option: addressType.description)
        radioGroupView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.addArrangedSubview(radioGroupView)
    }

    @objc func didTapDismiss() {
        dismiss(animated: true)
    }

}

extension ReceiveAddressTypeSelectViewController: RadioGroupViewDelegate {

    func didSelect(choice: String) {
        switch choice {
        case AddressType.segwit.description:
            delegate?.didSelect(addressType: .segwit)
        case AddressType.legacy.description:
            delegate?.didSelect(addressType: .legacy)
        default:
            fatalError()
        }

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

fileprivate extension Selector {

    static let didTapDismiss = #selector(ReceiveAddressTypeSelectViewController.didTapDismiss)

}
