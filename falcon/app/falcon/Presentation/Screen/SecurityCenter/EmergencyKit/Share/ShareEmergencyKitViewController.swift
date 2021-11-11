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

        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
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

    private func hideUploadingEKView() {
        dismissLoading?()
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

            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                // This will call the sign in callback
                GIDSignIn.sharedInstance().restorePreviousSignIn()
            } else {
                logEvent("ek_drive", parameters: ["type": "sign_in_start"])
                GIDSignIn.sharedInstance().signIn()
            }

        case .icloud:
            if option.isEnabled {
                logEvent("ek_save_select", parameters: ["option": "icloud"])
                uploadEKToICloud()
            }
            // It doesn't do anything if it is disabled

        case .anotherCloud:
            logScreen("emergency_kit_cloud_feedback", parameters: [:])
            dismissSuggestCloud = show(popUp: RequestCloudView(delegate: self), duration: nil, isDismissableOnTap: false)
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
        dismissLoading?()

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
                        GIDSignIn.sharedInstance().signIn()
                    }
                } else if option == .icloud {
                    self.uploadEKToICloud()
                }
            })
        )

        alert.view.tintColor = Asset.Colors.muunBlue.color

        present(alert, animated: true)
    }

}

extension ShareEmergencyKitViewController: ShareEmergencyKitPresenterDelegate {

    func uploadToCloudSuccessful(kit: EmergencyKit, option: EmergencyKitSavingOption, link: URL?) {
        logEvent("emergency_kit_exported", parameters: ["share_option": "\(option)"])
        kit.dispose()

        dismissLoading?()

        navigationController!.pushViewController(
            VerifyEmergencyKitViewController(option: option, link: link, flow: self.flow),
            animated: true
        )
    }

    func gotEmergencyKit(_ kit: EmergencyKit) {
        self.emergencyKit = kit
    }

    func errorUploadingToCloud(option: EmergencyKitSavingOption) {
        logEvent("emergency_kit_fail", parameters: ["type": "upload_error", "shared_option": "\(option)"])
        presentErrorUploading(option: option)
    }
}

extension ShareEmergencyKitViewController: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        guard error == nil else {
            // Show the error only if it's not an user cancel
            if (error as NSError).code != GIDSignInErrorCode.canceled.rawValue {
                logEvent("ek_drive", parameters: ["type": "sign_in_error"])
                presentErrorUploading(option: .drive)
            }

            googleUser = nil
            return
        }

        logEvent("ek_drive", parameters: ["type": "sign_in_finish"])
        googleUser = user
        uploadEKToDrive(user)
    }

}

extension ShareEmergencyKitViewController: ManualSaveEmergencyKitViewDelegate {

    func save() {
        dismissManualExport?()
        displayShareActivity()
    }

    func dismiss() {
        dismissManualExport?()
    }

}

extension ShareEmergencyKitViewController: RequestCloudViewDelegate {

    func dismiss(requestCloud: UIView) {
        dismissSuggestCloud?()
    }

    func request(cloud: String) {
        logScreen("emergency_kit_cloud_feedback_submit", parameters: ["cloud_name": cloud])
        presenter.request(cloud: cloud)
        dismissSuggestCloud?()
    }

}
