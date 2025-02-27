//
//  ShareEmergencyKitViewController.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import AppAuth


class ShareEmergencyKitViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(ShareEmergencyKitPresenter.init, delegate: self)

    private let flow: EmergencyKitFlow

    private var dismissManualExport: DisplayablePopUp.Dismiss?
    private var dismissSuggestCloud: DisplayablePopUp.Dismiss?

    private var shareView: ShareEmergencyKitView!
    private var uploadingEKLoadingView: LoadingView! = LoadingView()
    private var dismissLoading: DisplayablePopUp.Dismiss?
    private var emergencyKit: EmergencyKit?
    private var googleUser: GIDGoogleUser?

    override var screenLoggingName: String {
        return "emergency_kit_save"
    }

    init(flow: EmergencyKitFlow) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        super.loadView()

        shareView = ShareEmergencyKitView(
            delegate: self,
            options: presenter.getOptions(),
            flow: flow
        )
        self.view = shareView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()
        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()

        if let kit = emergencyKit {
            kit.dispose()
        }

        hideUploadingEKView()
    }

    private func setUpNavigation() {
        switch flow {
        case .export:
            title = L10n.ShareEmergencyKitViewController.s1

        case .update:
            ()
        }
    }

    @objc func displayShareActivity() {

        guard let kit = emergencyKit else {
            return
        }

        logScreen("emergency_kit_manual_advice", parameters: [:])

        let activityViewController = UIActivityViewController(
            activityItems: [kit.url],
            applicationActivities: nil
        )

        activityViewController.excludedActivityTypes = [.markupAsPDF]

        activityViewController.completionWithItemsHandler = {(activity, completed, _, _) in
            if !completed {
                // User did not share the pdf
                return
            }
            self.logEvent("ek_save_select", parameters: ["option": "manual"])

            // Remove the temp file
            kit.dispose()

            // User shared the pdf
            self.navigationController!.pushViewController(
                ActivateEmergencyKitViewController(
                    kit: kit,
                    shareOption: activity?.rawValue,
                    flow: self.flow
                ), animated: true
            )
        }

        present(activityViewController, animated: true)
    }

    private func displayUploadingEKView() {
        let text: String
        switch flow {
        case .export:
            text = L10n.ShareEmergencyKitViewController.uploading
        case .update:
            text = L10n.ShareEmergencyKitViewController.updating
        }

        let loadingView = LoadingPopUpView(loadingText: text)
        dismissLoading = show(popUp: loadingView, duration: nil, isDismissableOnTap: false)
    }

    func hideUploadingEKView(completion: (() -> Void)? = nil) {
        guard let dismissLoading = dismissLoading else {
            completion?()
            return
        }

        dismissLoading(completion)
    }
}

extension ShareEmergencyKitViewController: ShareEmergencyKitViewDelegate {

    func didTapOnManualExport() {
        dismissManualExport = show(
            popUp: ManualSaveEmergencyKitView(delegate: self),
            duration: nil,
            isDismissableOnTap: false
        )
    }

    func didTapOnOption(_ option: EKOption) {
        switch option.option {
        case .drive:
            logEvent("ek_save_select", parameters: ["option": "drive"])

            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                // This will call the sign in callback
                GIDSignIn.sharedInstance.restorePreviousSignIn(completion: sign(didSignInFor:withError:))
            } else {
                logEvent("ek_drive", parameters: ["type": "sign_in_start"])
                signInWithGoogle()
            }

        case .icloud:
            if option.isEnabled {
                logEvent("ek_save_select", parameters: ["option": "icloud"])
                uploadEKToICloud()
            }
            // It doesn't do anything if it is disabled

        case .anotherCloud:
            logScreen("emergency_kit_cloud_feedback", parameters: [:])
            dismissSuggestCloud = show(popUp: RequestCloudView(delegate: self),
                                       duration: nil,
                                       isDismissableOnTap: true)
        }
    }

    fileprivate func uploadEKToICloud() {
        guard let kit = emergencyKit else {
            return
        }

        displayUploadingEKView()

        presenter.uploadEmergencyKitToICloud(
            kit: kit,
            fileName: L10n.ShareEmergencyKitViewController.fileName
        )
    }

    fileprivate func uploadEKToDrive(_ user: GIDGoogleUser) {
        guard let kit = emergencyKit else {
            return
        }

        displayUploadingEKView()

        logEvent("ek_drive", parameters: ["type": "upload_start"])
        presenter.uploadEmergencyKitToDrive(
            googleUser: user,
            kit: kit,
            fileName: L10n.ShareEmergencyKitViewController.fileName
        )
    }

    private func presentErrorUploading(option: EmergencyKitSavingOption) {
        let alert = UIAlertController(
            title: L10n.ShareEmergencyKitViewController.ekUploadErrorTitle,
            message: L10n.ShareEmergencyKitViewController.ekUploadErrorDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: L10n.ShareEmergencyKitViewController.alertCancel, style: .destructive, handler: { _ in
                alert.dismiss(animated: true)
            })
        )

        alert.addAction(
            UIAlertAction(title: L10n.ShareEmergencyKitViewController.alertRetry, style: .default, handler: { _ in
                if option == .drive {
                    if let user = self.googleUser {
                        self.uploadEKToDrive(user)
                    } else {
                        self.signInWithGoogle()
                    }
                } else if option == .icloud {
                    self.uploadEKToICloud()
                }
            })
        )

        alert.view.tintColor = Asset.Colors.muunBlue.color
        hideUploadingEKView { [weak self] in
            self?.present(alert, animated: true)
        }
    }

}

extension ShareEmergencyKitViewController: ShareEmergencyKitPresenterDelegate {

    func uploadToCloudSuccessful(kit: EmergencyKit, option: EmergencyKitSavingOption, link: URL?) {
        logEvent("emergency_kit_exported", parameters: ["share_option": "\(option)"])
        kit.dispose()

        dismissLoading?(nil)

        navigationController!.pushViewController(
            VerifyEmergencyKitViewController(option: option, link: link, flow: self.flow),
            animated: true
        )
    }

    func gotEmergencyKit(_ kit: EmergencyKit) {
        self.emergencyKit = kit
    }

    func errorUploadingToCloud(option: EmergencyKitSavingOption, error: Error) {

        if option == .drive,
            let error = error as? NSError {

            switch (error.domain, error.code) {
            case (OIDOAuthTokenErrorDomain, OIDErrorCodeOAuth.unauthorizedClient.rawValue),
                (OIDOAuthTokenErrorDomain, OIDErrorCodeOAuth.accessDenied.rawValue),
                (OIDOAuthTokenErrorDomain, OIDErrorCodeOAuth.invalidGrant.rawValue),
                (kGTLRErrorObjectDomain, 403),
                (kGTLRErrorObjectDomain, 401):

                // Retrigger a login
                signInWithGoogle()
                return

            default:
                // 🤷‍♂️
                ()
            }
        }

        logEvent("emergency_kit_fail", parameters: ["type": "upload_error", "shared_option": "\(option)"])
        presentErrorUploading(option: option)
    }

    func abortExportBecauseOfError() {
        let alert = UIAlertController(
            title: L10n.ShareEmergencyKitViewController.generateEmergencyKitError,
            message: nil,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: L10n.ShareEmergencyKitViewController.alertRetry,
            style: .default,
            handler: { _ in
                self.navigationController?.popTo(type: SecurityCenterViewController.self)
            }
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ShareEmergencyKitViewController {

    func sign(didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            handleSignIn(error: error)
            return
        }

        googleUser = user

        // Check if the file scope has been given cause it's actually optional in spite of us requesting it
        if let userGrantedScopes = user.grantedScopes,
           userGrantedScopes.contains(kGTLRAuthScopeDriveFile) {
            uploadEKToDrive(user)
        } else {
            // Re-request sign in so we get the missing scope
            let scopes = [kGTLRAuthScopeDriveFile]

            user.addScopes(scopes, presenting: self) { [weak self] result, error in
                self?.sign(didSignInFor: result?.user, withError: error)
            }
        }
    }

    func signInWithGoogle() {
        let scopes = [kGTLRAuthScopeDriveFile]
        GIDSignIn.sharedInstance.signIn(withPresenting: self,
                                        hint: nil,
                                        additionalScopes: scopes) { [weak self] result, error in
            self?.sign(didSignInFor: result?.user, withError: error)
        }
    }

    private func handleSignIn(error: Error) {
        let errorCode = (error as NSError).code
        // Show the error only if it's not an user cancel
        guard errorCode != GIDSignInError.canceled.rawValue else {
            hideUploadingEKView()
            return
        }

        let nextVisualActionAfterDismiss: (() -> Void)
        // This error is not handled by GIDSignIn
        // ref: https://github.com/google/GoogleSignIn-iOS/issues/93
        let isTokenExpiredOrRevoked = errorCode == OIDErrorCodeOAuth.invalidGrant.rawValue
        if isTokenExpiredOrRevoked {
            GIDSignIn.sharedInstance.signOut()
            googleUser = nil
            nextVisualActionAfterDismiss = { [weak self] in self?.signInWithGoogle() }
            return
        } else { // unhandled error
            Logger.log(error: error)
            logEvent("ek_drive", parameters: ["type": "sign_in_error"])
            nextVisualActionAfterDismiss = { [weak self] in self?.presentErrorUploading(option: .drive) }
            googleUser = nil
        }

        // ensure loading is dismissed before trying anything. Otherwise next visual action will be not executed
        hideUploadingEKView {
            nextVisualActionAfterDismiss()
        }
    }
}

extension ShareEmergencyKitViewController: ManualSaveEmergencyKitViewDelegate {

    func save() {
        dismissManualExport?(nil)
        displayShareActivity()
    }

    func dismiss() {
        dismissManualExport?(nil)
    }

}

extension ShareEmergencyKitViewController: RequestCloudViewDelegate {

    func dismiss(requestCloud: UIView) {
        dismissSuggestCloud?(nil)
    }

    func request(cloud: String) {
        logScreen("emergency_kit_cloud_feedback_submit", parameters: ["cloud_name": cloud])
        presenter.request(cloud: cloud)
    }

}
