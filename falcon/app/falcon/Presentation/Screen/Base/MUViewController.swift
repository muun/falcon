//
//  MUViewController.swift
//  falcon
//
//  Created by Manu Herrera on 16/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class MUViewController: UIViewController {

    var loadingView: LoadingView?
    var toast: ToastView?
    var alreadyDismissedPopUp: Bool = false
    var containerView: UIView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        handleTabBarVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNavigationStyle()
        additionalSafeAreaInsets = UIEdgeInsets(
            top: 0,
            left: Constant.Dimens.viewControllerPadding,
            bottom: 0,
            right: Constant.Dimens.viewControllerPadding
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logScreen()

        #if DEBUG
        setUpEnvLabel()
        #else
        if Environment.current != .prod {
            setUpEnvLabel()
        }
        #endif
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        dismissLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.Colors.background.color
    }

    func navigationIsBeingPresented() -> Bool {
        return presentingViewController != nil ||
            navigationController?.presentingViewController?.presentedViewController === navigationController
    }

    private func setNavigationStyle() {
        navigationController!.navigationBar.tintColor = Asset.Colors.muunGrayDark.color
        navigationController!.navigationBar.backIndicatorImage = UIImage()
        navigationController!.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.showSeparator()
        navigationController!.navigationBar.barTintColor = Asset.Colors.cellBackground.color
        navigationController!.view.backgroundColor = Asset.Colors.cellBackground.color
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.prefersLargeTitles = false

        let textAttributes = [NSAttributedString.Key.foregroundColor: Asset.Colors.title.color]
        navigationController!.navigationBar.titleTextAttributes = textAttributes
        navigationController!.navigationBar.largeTitleTextAttributes = textAttributes

        let isModal = navigationIsBeingPresented()
        if isModal {
            navigationController!.hideSeparatorForModal()
        }
        let showCloseButton = isModal && navigationController?.viewControllers.count == 1
        if showCloseButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constant.Images.close,
                                                               style: .plain,
                                                               target: self,
                                                               action: .onCloseTap)
        }

        navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(image: Constant.Images.back,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }

    @objc func onCloseTap() {
        dismiss(animated: true, completion: nil)
    }

    func showLoading(_ text: String) {
        if loadingView == nil {
            loadingView = LoadingView()
            loadingView?.addTo(self.view)
        }

        if let view = loadingView {
            view.titleText = text
            view.isHidden = false
        }
    }

    func dismissLoading() {
        if let view = loadingView {
            UIView.animate(withDuration: 0.25, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.isHidden = true
            })
        }
    }

    private func setUpEnvLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.sideMargin),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.sideMargin)
        ])
        label.backgroundColor = Asset.Colors.muunRed.color
        label.textColor = .white
        label.text = " \(Environment.current.rawValue) "

        label.roundCorners(cornerRadius: 10, clipsToBounds: true)
    }

    // We only want to display the tab bar in the top level view controllers of the tab bar controller.
    // If for some reason you need another view controller to display the tab bar, you can either:
    // 1. add it to the isTopLevelVc check; or
    // 2. override the `init(nibName, bundle)` method of the VC and add the `hidesBottomBarWhenPushed = false` line
    // just below the `super.init(nibName, bundle)` call.
    fileprivate func handleTabBarVisibility() {
        let isTopLevelVc = isKind(of: HomeViewController.self)
            || isKind(of: SecurityCenterViewController.self)
            || isKind(of: SettingsViewController.self)

        hidesBottomBarWhenPushed = !isTopLevelVc
    }

    // Use this method whenever the user needs a clean restart of the view herarchy (ie: log out, delete wallet, etc)
    func resetWindowToGetStarted() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Couldn't get access to the App Delegate")
        }

        appDelegate.resetWindowToGetStarted()
    }

}

extension MUViewController: DisplayableToast {
    @objc func dismissToast() {
        toast?.animateOut()
    }
}

extension MUViewController: DisplayablePopUp {
    @objc func dismissPopUp() {
        alreadyDismissedPopUp = true
        navigationController!.dismiss(animated: true)
    }
}

// Keyboard extension
extension MUViewController {

    internal func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: .keyboardWillShow,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: .keyboardWillHide,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    internal func removeKeyboardObservers() {
        view.endEditing(true)

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        // override this method
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // override this method
    }

}

// Clipboard extension
extension MUViewController {

    internal func addClipboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: .clipboardChanged,
                                               name: UIPasteboard.changedNotification,
                                               object: nil)
    }

    internal func removeClipboardObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIPasteboard.changedNotification,
                                                  object: nil)
    }

    @objc func clipboardChanged() {
        // override this method
    }

}

extension MUViewController: BasePresenterDelegate {

    func pushTo(_ vc: MUViewController) {
        self.navigationController!.pushViewController(vc, animated: true)
    }

    func showMessage(_ message: String) {
        showToast(message: message)
    }

}

fileprivate extension Selector {

    static let keyboardWillShow = #selector(MUViewController.keyboardWillShow(notification:))
    static let keyboardWillHide = #selector(MUViewController.keyboardWillHide(notification:))

    static let onCloseTap = #selector(MUViewController.onCloseTap)

    static let clipboardChanged = #selector(MUViewController.clipboardChanged)

}
