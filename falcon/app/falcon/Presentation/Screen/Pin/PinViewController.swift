//
//  PinViewController.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol LockDelegate: AnyObject {
    func unlockApp()
    func logOut()
}

class PinViewController: MUViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var hintLabel: UILabel!

    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var keyboardView: KeyboardView!
    @IBOutlet private weak var backButton: UIButton!

    private var uiTestLabel: UILabel! // This label is only used for ui tests purposes

    private let notification = UINotificationFeedbackGenerator() // This is used to notify success or error to the user
    private var currentPin = ""
    private var state: PinPresenterState!
    private var isExistingUser = true
    private weak var appLockDelegate: LockDelegate?

    fileprivate lazy var presenter = instancePresenter(PinPresenter.init, delegate: self, state: state)

    override var screenLoggingName: String {
        return "pin_\(state.loggingName())"
    }

    convenience init(state: PinPresenterState,
                     isExistingUser: Bool = true,
                     lockDelegate: LockDelegate? = nil) {

        self.init()

        self.state = state
        self.isExistingUser = isExistingUser
        self.appLockDelegate = lockDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.setNavigationBarHidden(true, animated: true)

        presenter.setUp(isExistingUser: isExistingUser)

        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpKeyboard()
        setUpPinView()
        setLabelsText(title: state.pinTitle(), description: state.pinDescription())
        setUpUiTestLabel()

        animateView()

        let isLocked = (state == .locked)
        if isLocked, presenter.getBiometricIdStatus() {
            requestAuthentication(completion: {
                self.unlockSuccessful()
            }, failure: {

            })
        }
    }

    fileprivate func setUpUiTestLabel() {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            uiTestLabel = UILabel()
            uiTestLabel.style = .description
            uiTestLabel.text = presenter.getGcmToken()

            uiTestLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(uiTestLabel)
            NSLayoutConstraint.activate([
                uiTestLabel.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 12),
                uiTestLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        #endif
    }

    fileprivate func setUpKeyboard() {
        keyboardView.delegate = self
        keyboardView.isEraseEnabled = false
    }

    fileprivate func setUpPinView() {
        pinView.delegate = self
        pinView.alpha = 0
    }

    fileprivate func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h1)
        titleLabel.alpha = 0

        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.font = Constant.Fonts.description
        descriptionLabel.alpha = 0

        hintLabel.textColor = Asset.Colors.muunGrayDark.color
        hintLabel.font = Constant.Fonts.system(size: .helper)
    }

    fileprivate func setLabelsText(title: String, description: String, hint: String = "") {
        titleLabel.text = title
        descriptionLabel.text = description
        hintLabel.text = hint
    }

    fileprivate func animateView() {
        titleLabel.animate(direction: .topToBottom, duration: .short) {
            self.descriptionLabel.animate(direction: .topToBottom, duration: .short)
            self.pinView.animate(direction: .topToBottom, duration: .short, delay: .short)
        }
    }

    fileprivate func requestAuthentication(completion: @escaping () -> Void, failure: @escaping () -> Void) {

        let myContext = LAContext()
        var text = ""
        var authError: NSError?

        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {

            switch myContext.biometryType {
            case .faceID:
                text = L10n.PinViewController.s1
            case .touchID:
                text = L10n.PinViewController.s2
            case .none:
                text = L10n.PinViewController.s3
            @unknown default:
                fatalError("Implement the new biometric type")
            }

            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: text) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        completion()
                    } else {
                        failure()
                    }
                }
            }
        } else {
            // TODO: Show a "Face id not set up" pop up
            failure()
        }
    }

    fileprivate func pushToSync() {
        let vc = SyncViewController(existingUser: self.isExistingUser)
        navigationController!.pushViewController(vc, animated: true)
    }

    @IBAction fileprivate func backButtonPressed(_ sender: Any) {
        backButton.isHidden = true

        pinView.clearInput()
        pinView.filledPins = 0

        currentPin = ""

        presenter.resetChoose()
        state = .choosePin

        setLabelsText(title: state.pinTitle(), description: state.pinDescription())
    }

}

extension PinViewController: KeyboardViewDelegate {

    func onNumberPressed(number: String) {

        if pinView.filledPins < 4 {
            pinView.colorNextPin()
            currentPin.append(number)
        }

        if pinView.filledPins == 4 {
            presenter.pinFinished(pin: currentPin)
        }

    }

    func onErasePressed() {
        currentPin = String(currentPin.dropLast())

        pinView.erasePin()
    }

}

extension PinViewController: PinViewDelegate {

    func animationStarted() {
        keyboardView.isEnabled = false
        keyboardView.isEraseEnabled = false
    }

    func animationEnded() {
        pinView.filledPins = 0
        currentPin = ""

        keyboardView.isEnabled = true
    }

    func setDelete(enabled: Bool) {
        keyboardView.isEraseEnabled = enabled
    }

}

extension PinViewController: PinPresenterDelegate {

    enum PinTypeParam: String {
        case correct
        case incorrect
        case created
        case did_not_match
    }

    func unlockSuccessful() {

        if let lockDelegate = self.appLockDelegate {
            logEvent("pin", parameters: ["type": PinTypeParam.correct.rawValue])
            pinView.pinValidationFeedback(isValid: true)
            notification.notificationOccurred(.success)

            lockDelegate.unlockApp()
        }
    }

    func unlockUnsuccessful(attemptsLeft: Int, isAnonUser: Bool) {
        logEvent("pin", parameters: ["type": PinTypeParam.incorrect.rawValue])
        pinView.pinValidationFeedback(isValid: false)
        notification.notificationOccurred(.error)

        let bold = L10n.PinViewController.s4

        if isAnonUser {
            hintLabel.attributedText = bold
                .attributedForDescription(alignment: .center)
                .set(bold: bold, color: Asset.Colors.muunRed.color)
        } else {
            let errorString = L10n.PinViewController.s5("\(attemptsLeft)")
            hintLabel.attributedText = errorString
                .attributedForDescription(alignment: .center)
                .set(bold: bold, color: Asset.Colors.muunRed.color)
                .set(bold: "\(attemptsLeft)", color: Asset.Colors.muunGrayDark.color)
        }
    }

    func noMoreAttempts() {
        if let lockDelegate = self.appLockDelegate {
            lockDelegate.logOut()
        }
    }

    func pinRepeated(isValid: Bool) {
        pinView.pinValidationFeedback(isValid: isValid)

        let feedback: UINotificationFeedbackGenerator.FeedbackType = isValid
            ? .success
            : .error

        notification.notificationOccurred(feedback)

        let hintText = isValid
            ? ""
            : L10n.PinViewController.s6

        hintLabel.text = hintText

        if isValid {
            logEvent("pin", parameters: ["type": PinTypeParam.created.rawValue])

            requestAuthentication(completion: {
                self.presenter.setBiometricIdStatus(true)
                self.pushToSync()
            }, failure: {
                self.presenter.setBiometricIdStatus(false)
                self.pushToSync()
            })
        } else {
            logEvent("pin", parameters: ["type": PinTypeParam.did_not_match.rawValue])
        }
    }

    func pinChoosed() {
        logScreen("pin_repeat")
        pinView.clearInput()

        state = .repeatPin
        setLabelsText(title: state.pinTitle(), description: state.pinDescription())
        backButton.isHidden = false
    }

}

extension PinViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.PinPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(keyboardView, using: .keyboardView)
        makeViewTestable(hintLabel, using: .hintLabel)
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            makeViewTestable(uiTestLabel, using: .gcmTokenLabel)
        }
        #endif
    }
}
