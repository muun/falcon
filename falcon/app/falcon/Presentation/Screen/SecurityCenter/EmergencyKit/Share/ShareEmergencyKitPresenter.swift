//
//  ShareEmergencyKitPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core
import RxSwift
import GoogleSignIn
import GoogleAPIClientForREST

protocol ShareEmergencyKitPresenterDelegate: BasePresenterDelegate {
    func gotEmergencyKit(_ kit: EmergencyKit)
    func errorUploadingToDrive()
    func uploadToDriveSuccessful(link: URL?)
    func errorUploadingToICloud()
    func uploadToICloudSuccessful(link: URL?)
}

class ShareEmergencyKitPresenter<Delegate: ShareEmergencyKitPresenterDelegate>: BasePresenter<Delegate> {

    fileprivate let emergencyKitDataSelector: EmergencyKitDataSelector

    fileprivate let emergencyKitExportedAction: ReportEmergencyKitExportedAction
    fileprivate let emergencyKitVerificationCodesRepository: EmergencyKitVerificationCodesRepository

    init(delegate: Delegate,
         emergencyKitExportedAction: ReportEmergencyKitExportedAction,
         emergencyKitDataSelector: EmergencyKitDataSelector,
         emergencyKitVerificationCodesRepository: EmergencyKitVerificationCodesRepository) {
        self.emergencyKitExportedAction = emergencyKitExportedAction
        self.emergencyKitDataSelector = emergencyKitDataSelector
        self.emergencyKitVerificationCodesRepository = emergencyKitVerificationCodesRepository

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        let obs = emergencyKitDataSelector.get()

        subscribeTo(obs) { data in
            let kit = EmergencyKit.generate(data: data)
            self.reportGenerated(verificationCode: kit.verificationCode)
            self.emergencyKitVerificationCodesRepository.store(code: kit.verificationCode)
            self.delegate.gotEmergencyKit(kit)
        }
    }

    // When the EK gets generated we let houston know
    private func reportGenerated(verificationCode: String) {
        emergencyKitExportedAction.run(date: Date(), verificationCode: verificationCode, isVerified: false)
    }

    func reportExported(verificationCode: String) {
        emergencyKitExportedAction.run(date: Date(), verificationCode: verificationCode, isVerified: true)
    }

    func getOptions() -> [EKOption] {
        var options: [EKOption] = []

        if isDriveAvailable() {
            // if drive is available it should be the recommeded option
            options.append((option: .drive, isRecommended: true, isEnabled: true))
        }

        if isICloudAvailable() {
            // iCloud is recommended if it is available and drive is not available
            options.append((option: .icloud, isRecommended: !isDriveAvailable(), isEnabled: true))
            options.append((option: .manually, isRecommended: false, isEnabled: true))
        } else {
            // if iCloud is not available, it should be at the bottom of the list
            options.append((option: .manually, isRecommended: false, isEnabled: true))
            options.append((option: .icloud, isRecommended: false, isEnabled: false))
        }

        return options
    }

    func uploadEmergencyKitToDrive(user: GIDGoogleUser, ekUrl: URL, fileName: String) {
        GoogleDriveHelper.uploadEK(
            user: user,
            emergencyKitUrl: ekUrl,
            fileName: fileName) { webViewLinkString, err in

            if err != nil {
                self.delegate.errorUploadingToDrive()
                return
            }

            let url = URL(string: webViewLinkString ?? "") // This will be nil if the link is nil
            self.delegate.uploadToDriveSuccessful(link: url)
        }
    }

    func uploadEmergencyKitToICloud(ekUrl: URL, fileName: String) {
        ICloudHelper.uploadEK(emergencyKitUrl: ekUrl, fileName: fileName) { kitUrl, err in
            if err != nil {
                self.delegate.errorUploadingToICloud()
                return
            }

            var components = kitUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
            components?.scheme = "shareddocuments"
            self.delegate.uploadToICloudSuccessful(link: components?.url)
        }
    }

    private func isDriveAvailable() -> Bool {
        // This is a heuristic to only display the drive option to users that we think are using gmail and won't forget
        // their password.
        let isDriveInstalled = isInstalled(urlScheme: "googledrive://")
        let isGmailInstalled = isInstalled(urlScheme: "googlegmail://")

        return isDriveInstalled || isGmailInstalled
    }

    private func isICloudAvailable() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    private func isInstalled(urlScheme: String) -> Bool {
        guard let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) else {
            return false
        }

        return true
    }
}
