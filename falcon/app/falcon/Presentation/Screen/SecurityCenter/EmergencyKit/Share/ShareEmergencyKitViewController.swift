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

    private var shareView: ShareEmergencyKitView!
    private var uploadingEKLoadingView: LoadingView! = LoadingView()

    private var emergencyKit: EmergencyKit?
    private var googleUser: GIDGoogleUser?

    override var screenLoggingName: String {
        return "emergency_kit_save"
    }

    override func loadView() {
        super.loadView()

        shareView = ShareEmergencyKitView(delegate: self, options: presenter.getOptions())
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
        title = L10n.ShareEmergencyKitViewController.s1
    }

    @objc func displayShareActivity() {

        guard let kit = emergencyKit else {
            return
        }

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

            // Remove the temp file
            kit.dispose()

            // User shared the pdf
            self.navigationController!.pushViewController(
                ActivateEmergencyKitViewController(
                    verificationCode: kit.verificationCode,
                    shareOption: activity?.rawValue
                ), animated: true
            )
        }

        present(activityViewController, animated: true)
    }

    private func displayUploadingEKView() {
        let loadingView = LoadingPopUpView(loadingText: L10n.ShareEmergencyKitViewController.uploading)
        show(popUp: loadingView, duration: nil, isDismissableOnTap: false)
    }

    private func hideUploadingEKView() {
        dismissPopUp()
    }

}

extension ShareEmergencyKitViewController: ShareEmergencyKitViewDelegate {

    func didTapOnCloudStorageInfo() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.cloudStorage)
        navigationController!.present(overlayVc, animated: true)
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

        case .manually:
            logEvent("ek_save_select", parameters: ["option": "manual"])

            displayShareActivity()

        }
    }

    fileprivate func uploadEKToICloud() {
        guard let kit = emergencyKit else {
            return
        }

        displayUploadingEKView()

        presenter.uploadEmergencyKitToICloud(
            ekUrl: kit.url,
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
            user: user,
            ekUrl: kit.url,
            fileName: L10n.ShareEmergencyKitViewController.fileName
        )
    }

    private func presentErrorUploading(option: EmergencyKitSavingOption) {
        dismissPopUp()

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

        self.present(alert, animated: true)
    }

}

extension ShareEmergencyKitViewController: ShareEmergencyKitPresenterDelegate {
    func errorUploadingToICloud() {
        presentErrorUploading(option: .icloud)
    }

    func uploadToICloudSuccessful(link: URL?) {
        guard let kit = emergencyKit else {
            return
        }

        presenter.reportExported(verificationCode: kit.verificationCode)
        logEvent("emergency_kit_exported", parameters: ["share_option": "icloud"])
        kit.dispose()

        dismissPopUp()

        navigationController!.pushViewController(
            VerifyEmergencyKitViewController(option: .icloud, link: link), animated: true
        )
    }

    func gotEmergencyKit(_ kit: EmergencyKit) {
        self.emergencyKit = kit
    }

    func errorUploadingToDrive() {
        logEvent("ek_drive", parameters: ["type": "upload_error"])
        presentErrorUploading(option: .drive)
    }

    func uploadToDriveSuccessful(link: URL?) {
        guard let kit = emergencyKit else {
            return
        }

        presenter.reportExported(verificationCode: kit.verificationCode)
        logEvent("ek_drive", parameters: ["type": "upload_finish"])
        kit.dispose()

        dismissPopUp()

        navigationController!.pushViewController(
            VerifyEmergencyKitViewController(option: .drive, link: link), animated: true
        )
    }
}

extension ShareEmergencyKitViewController: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        guard error == nil else {
            logEvent("ek_drive", parameters: ["type": "sign_in_error"])
            presentErrorUploading(option: .drive)

            googleUser = nil
            return
        }

        logEvent("ek_drive", parameters: ["type": "sign_in_finish"])
        googleUser = user
        uploadEKToDrive(user)
    }

}
