//
//  HelpViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class SupportViewController: MUViewController {

    @IBOutlet fileprivate weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet fileprivate weak var textInputView: LargeTextInputView!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var emailBoxView: UIView!
    @IBOutlet fileprivate weak var linkButtonView: LinkButtonView!

    fileprivate lazy var presenter = instancePresenter(SupportPresenter.init, delegate: self, state: type)
    private let type: SupportAction.RequestType
    private var emailActionSheet: UIAlertController = UIAlertController()

    override var screenLoggingName: String {
        return "support"
    }

    override func customLoggingParameters() -> [String: Any]? {
        return ["type": type.loggingName()]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init(type: SupportAction.RequestType) {
        self.type = type

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        addKeyboardObservers()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()

        presenter.tearDown()
    }

    private func setUpNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = ""
    }

    fileprivate func setUpView() {
        setUpTitleAndDescription()

        if type == .anonSupport {
            setUpAnonUserSupportView()
        } else {
            setUpUserSupportView()
        }
    }

    private func setUpAnonUserSupportView() {
        emailBoxView.isHidden = false
        linkButtonView.isHidden = false

        textInputView.removeFromSuperview()
        buttonView.removeFromSuperview()

        setUpEmailBoxView()
        setUpOpenEmailClientButton()
        setUpEmailActionSheet()

        animateAnonUserView()
    }

    private func setUpUserSupportView() {
        emailBoxView.removeFromSuperview()
        linkButtonView.removeFromSuperview()

        textInputView.isHidden = false
        buttonView.isHidden = false

        setUpTextInputView()
        setUpSendButton()

        animateUserView()
    }

    private func setUpTitleAndDescription() {
        titleAndDescriptionView.titleText = type.titleText
        titleAndDescriptionView.descriptionText = type.descriptionText

        if type == .anonSupport, let supportId = presenter.getSupportId() {
            addSupportCode(supportId)
        }
    }

    fileprivate func addSupportCode(_ code: String) {
        let desc = NSMutableAttributedString(attributedString: type.descriptionText)
        let supportText = L10n.SupportViewController.s1
        desc.append(" \(supportText) (\(code)).".attributedForDescription())
        titleAndDescriptionView.descriptionText = desc

        titleAndDescriptionView.delegate = self
    }

    fileprivate func animateAnonUserView() {
        titleAndDescriptionView.animate()
        emailBoxView.animate(direction: .topToBottom, duration: .short)
        linkButtonView.animate(direction: .bottomToTop, duration: .medium)
    }

    fileprivate func animateUserView() {
        titleAndDescriptionView.animate()
        textInputView.animate(direction: .topToBottom, duration: .short)
        buttonView.animate(direction: .bottomToTop, duration: .medium)
    }

    fileprivate func setUpTextInputView() {
        textInputView.delegate = self
        textInputView.bottomText = ""
        textInputView.topText = type.textInputTitle
        textInputView.alpha = 0
        _ = textInputView.becomeFirstResponder()
    }

    fileprivate func setUpEmailBoxView() {
        emailBoxView.alpha = 0
    }

    fileprivate func setUpSendButton() {
        buttonView.delegate = self
        buttonView.buttonText = type.buttonText
        buttonView.isEnabled = false
        buttonView.alpha = 0
    }

    fileprivate func setUpOpenEmailClientButton() {
        linkButtonView.delegate = self
        linkButtonView.buttonText = type.buttonText
        linkButtonView.isEnabled = false
        linkButtonView.alpha = 0
    }

    fileprivate func setUpEmailActionSheet() {
        emailActionSheet = UIAlertController(title: L10n.SupportViewController.s2,
                                             message: nil,
                                             preferredStyle: .actionSheet)
        emailActionSheet.addAction(UIAlertAction(title: L10n.SupportViewController.s3, style: .cancel, handler: nil))

        addEmailActions()
    }

    fileprivate func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }

        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (_) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        return action
    }

    fileprivate func addEmailActions() {
        let muunEmail = "support@muun.com"

        if let action = openAction(withURL: "mailto:\(muunEmail)", andTitleActionTitle: "Mail") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "googlegmail://co?to=\(muunEmail)", andTitleActionTitle: "Gmail") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "ms-outlook://compose?to=\(muunEmail)", andTitleActionTitle: "Outlook") {
            emailActionSheet.addAction(action)
        }

        // If this is == 1, that means the user doesnt have any email client app installed
        linkButtonView.isEnabled = (emailActionSheet.actions.count > 1)
    }

}

extension SupportViewController: SupportPresenterDelegeate {

    @objc func didSendRequest() {
        if navigationIsBeingPresented() {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    func didFailRequest() {
        textInputView.isUserInteractionEnabled = true
        buttonView.isLoading = false
    }

}

//Keyboard actions
extension SupportViewController {

    override func keyboardWillHide(notification: NSNotification) {
        guard type != .anonSupport else { return }

        animateButtonTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        guard type != .anonSupport else { return }

        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateButtonTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateButtonTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.bottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension SupportViewController: LargeTextInputViewDelegate {

    func onTextChange(textInputView: LargeTextInputView, text: String) {
        buttonView.isEnabled = !text.isEmpty
    }

}

extension SupportViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        view.endEditing(true)

        presenter.sendRequest(text: textInputView.text)
        textInputView.isUserInteractionEnabled = false
        button.isLoading = true
    }

}

extension SupportViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        navigationController!.present(emailActionSheet, animated: true)
    }

}

extension SupportViewController: TitleAndDescriptionViewDelegate {

    func descriptionTouched() {
        if type == .anonSupport, let supportId = presenter.getSupportId() {
            UIPasteboard.general.string = supportId
            showToast(message: L10n.SupportViewController.s4)
        }
    }

}

extension SupportAction.RequestType {

    var titleText: String {
        switch self {
        case .feedback:
            return L10n.SupportViewController.s5
        case .help, .support:
            return L10n.SupportViewController.s6
        case .anonSupport:
            return L10n.SupportViewController.s7
        case .cloudRequest:
            Logger.fatal("Cant invoke support view with cloud request")
        }
    }

    var descriptionText: NSAttributedString {
        switch self {
        case .feedback:
            return L10n.SupportViewController.s8
                .attributedForDescription()
        case .help, .support:
            return L10n.SupportViewController.s9
                .attributedForDescription()
        case .anonSupport:
            return L10n.SupportViewController.s10
                .attributedForDescription()
                .set(bold: "support@muun.com", color: Asset.Colors.title.color)
        case .cloudRequest:
            Logger.fatal("Cant invoke support view with cloud request")
        }
    }

    var textInputTitle: String {
        switch self {
        case .feedback:
            return L10n.SupportViewController.s11
        case .help, .support:
            return L10n.SupportViewController.s12
        case .anonSupport:
            return ""
        case .cloudRequest:
            Logger.fatal("Cant invoke support view with cloud request")
        }
    }

    var buttonText: String {
        switch self {
        case .feedback:
            return L10n.SupportViewController.s13
        case .help, .support:
            return L10n.SupportViewController.s14
        case .anonSupport:
            return L10n.SupportViewController.s15
        case .cloudRequest:
            Logger.fatal("Cant invoke support view with cloud request")
        }
    }

}

extension SupportAction.RequestType {
    func loggingName() -> String {
        switch self {
        case .feedback: return "feedback"
        case .help: return "help"
        case .support: return "support"
        case .anonSupport: return "anon_support"
        case .cloudRequest:
            Logger.fatal("Cant invoke support view with cloud request")
        }
    }
}
