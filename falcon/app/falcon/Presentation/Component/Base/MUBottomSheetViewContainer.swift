//
//  MUBottomSheetViewContainer.swift
//  Muun
//
//  Created by Lucas Serruya on 21/12/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit

/// This view is a bottom sheet container with a vertical stackview in it. Just add whatever you want into dialogView
/// overriding setUpView method and call super before anything and it wil lbe displayed as a bottomSheet.
class MUBottomSheetViewContainer: UIViewController {
    var dialogView = UIStackView()
    private let screenNameForLogs: String

    init(screenNameForLogs: String) {
        self.screenNameForLogs = screenNameForLogs

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    override var screenLoggingName: String {
        return screenNameForLogs
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This log is usually logged by a MUBottomSheetViewContainer parent. Since MUViewController only support pushing
        // VC instead of presententing them, I added this log in order to get the screen logged. As a future work we
        // must refactor MUViewController in order to support presetingVCs
        logScreen()
    }

    func setUpView() {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapDismiss))
        view.autoresizingMask = .flexibleHeight
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        if #available(iOS 13.4.0, *) {
            panGesture.allowedScrollTypesMask = .all
        }

        view.addGestureRecognizer(panGesture)

        createDialogStackView()
        addBackgroundView(to: dialogView)
    }

    @objc func didTapDismiss() {
        dismiss(animated: true)
    }

    // Ref: https://betterprogramming.pub/simple-drag-dismiss-on-presented-view-controller-tutorial-5f2f44f86f7b
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            if self.viewTranslation.y > 0 {
                UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
        case .ended:
            if viewTranslation.y < 5 {
                UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

fileprivate extension Selector {
    static let didTapDismiss = #selector(MUBottomSheetViewContainer.didTapDismiss)
}

extension MUBottomSheetViewContainer: UIViewControllerTransitioningDelegate {
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

private extension MUBottomSheetViewContainer {
    func createDialogStackView() {
        var margins: UIEdgeInsets = .standardMargins
        margins.top = .bigSpacing

        dialogView = UIStackView()
        dialogView.axis = .vertical
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.isLayoutMarginsRelativeArrangement = true
        dialogView.layoutMargins = margins
        dialogView.spacing = .spacing
        dialogView.alignment = .fill
        dialogView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(killTap)))
        view.addSubview(dialogView)

        NSLayoutConstraint.activate([
            dialogView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func addBackgroundView(to container: UIView) {
        // Add background, see https://stackoverflow.com/a/34868367/368861
        let background = UIView(frame: container.bounds)
        background.backgroundColor = Asset.Colors.cellBackground.color
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(background)
    }

    @objc
    func killTap() {
        print("tap killed")
    }
}
