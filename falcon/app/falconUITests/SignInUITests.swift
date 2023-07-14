//
//  SignInUITests.swift
//  FalconUITests
//
//  Created by Manu Herrera on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

class SignInUITests: FalconUITests {

    private var signInEmailPage: SignInEmailPage!
    private var getStartedPage: GetStartedPage!
    private var signInPasswordPage: SignInPasswordPage!
    private var pinPage: PinPage!
    private var logOutPage: LogOutPage!
    private var homePage: HomePage!


    override func tearDown() {
        getStartedPage = nil
        signInEmailPage = nil
        signInPasswordPage = nil
        pinPage = nil
        logOutPage = nil
        homePage = nil

        super.tearDown()
    }

    func testFullCreateWalletSignIn() {
        let (homePage, email, password, rc) = createRecoverableUser()
        self.homePage = homePage

        _ = logOut(homePage: homePage)

        fullSignIn(email: email, password: password, pin: genericPin)
        _ = logOut(homePage: homePage)

        _ = signIn(email: email, code: rc, pin: genericPin)
        _ = logOut(homePage: homePage)

        tryUserFacingErrors(registeredEmail: email)
    }

    func testEmailLessRecoveryFullFlow() {
        homePage = createUser()

        addSection("1. skip email, set up rc and export keys")
        let rc = securityCenterTests.skipEmailSetUpRCAndExportKeys(in: homePage)
        _ = logOut(homePage: homePage)

        addSection("2. log in with RC flow")
        homePage = signIn(code: rc, checkEmail: false, pin: genericPin)

        addSection("3. set up email + pw")
        let (email, pass) = securityCenterTests.setUpEmailAndPassword(in: homePage)
        _ = logOut(homePage: homePage)

        addSection("4. log in with rc + email")
        homePage = signIn(code: rc, checkEmail: true, pin: genericPin)
        _ = logOut(homePage: homePage)

        addSection("5. log in with email + password")
        fullSignIn(email: email, password: pass, pin: genericPin)
        _ = logOut(homePage: homePage)

        addSection("6. log in with email + rc")
        homePage = signIn(email: email, code: rc, pin: genericPin)
        _ = logOut(homePage: homePage)
    }

    private func startSignInFlow() {
        getStartedPage = GetStartedPage()
        _ = getStartedPage.createWalletButton.element.waitForExistence(timeout: 10)

        signInEmailPage = getStartedPage.touchRecoverWallet()
        _ = signInEmailPage.element.waitForExistence(timeout: 2)
    }

    private func tryUserFacingErrors(registeredEmail: String) {
        startSignInFlow()

        tryInvalidEmail()

        // This is to wait for Houston "too many requests" response
        _ = app.wait(for: .unknown, timeout: 2)
        tryNonRegisteredEmail(registeredEmail: registeredEmail)

        // This is to wait for Houston "too many requests" response
        _ = app.wait(for: .unknown, timeout: 2)
        tryInvalidPassword(email: registeredEmail, password: "12345678910")

        abortSignIn()
    }

    private func tryInvalidEmail() {
        addSection("SignIn.tryInvalidEmail")

        signInEmailPage.type(email: "muun @muun.com")

        // This is to wait for the label to change its text
        _ = app.wait(for: .unknown, timeout: 1)
        XCTAssert(!signInEmailPage.buttonView.isEnabled())
    }

    private func tryNonRegisteredEmail(registeredEmail: String) {
        addSection("SignIn.tryNonRegisteredEmail")

        signInEmailPage.type(email: "\(registeredEmail)test")

        // This is to wait for the label to change its text
        _ = app.wait(for: .unknown, timeout: 1)
        signInEmailPage.textInputView.bottomLabelTextMatches(L10n.SignInEmailViewController.s8, in: self)
    }

    private func tryInvalidPassword(email: String, password: String) {
        addSection("SignIn.tryInvalidPassword")

        enterPassword(email: email, password: password)
        // Wait for the request to finish
        sleep(2)

        signInPasswordPage.textInputView.bottomLabelTextMatches(L10n.SignInPasswordViewController.s12, in: self)
    }

    private func enterValidEmail(email: String) -> SignInPasswordPage {
        signInEmailPage.type(email: email)

        return SignInPasswordPage()
    }

    private func enterPassword(email: String, password: String) {
        signInPasswordPage = enterValidEmail(email: email)
        _ = signInPasswordPage.element.waitForExistence(timeout: 10)

        signInPasswordPage.type(password: password)
    }

    private func enterValidPassword(email: String, password: String) -> PinPage {
        enterPassword(email: email, password: password)

        return PinPage()
    }

    func signIn(email: String, code: [String], pin: String) -> HomePage {
        addSection("sign in with email + recovery code")

        startSignInFlow()

        signInPasswordPage = enterValidEmail(email: email)
        signInPasswordPage.wait(10)

        let recoveryCodePage = signInPasswordPage.forgotPassword()
        recoveryCodePage.wait()

        recoveryCodePage.set(code: code)

        pinPage = recoveryCodePage.verify()
        pinPage.wait()

        homePage = pinPage.createPinAndAdvance(pin)
        return homePage
    }

    private func signIn(code: [String], checkEmail: Bool, pin: String) -> HomePage {
        addSection("sign in with recovery code")

        startSignInFlow()

        let signInWithRCPage = signInEmailPage.goToSignInWithRCFlow()
        signInWithRCPage.tryWrongCodeAndAssertError(realCode: code)
        signInWithRCPage.tryOldRecoveryCodeAndAssertError()

        let pinPage = signInWithRCPage.advanceWithValidCode(code)
        if checkEmail {
            let verifyEmail = VerifyEmailPage()
            verifyEmail.wait()
        }
        pinPage.wait()

        homePage = pinPage.createPinAndAdvance(pin)
        return homePage
    }

    func signIn(email: String, password: String, pin: String) {

        startSignInFlow()

        pinPage = enterValidPassword(email: email, password: password)
        pinPage.wait(10)

        homePage = pinPage.createPinAndAdvance(pin)
    }

    func fullSignIn(email: String, password: String, pin: String) {
        addSection("sign in with password")
        signIn(email: email, password: password, pin: pin)
        homePage.toggleBalanceVisibility()
        homePage.toggleBalanceVisibility()
    }

    func logOut(homePage: HomePage) -> GetStartedPage {
        return homePage.goToSettings().logout()
    }

    private func abortSignIn() {
        back()
        app.alerts[L10n.SignInPasswordViewController.s8]
            .buttons[L10n.SignInPasswordViewController.s11]
            .tap()
    }

}
