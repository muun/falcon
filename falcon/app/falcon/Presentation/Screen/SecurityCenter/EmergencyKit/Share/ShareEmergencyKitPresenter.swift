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
import Foundation

protocol ShareEmergencyKitPresenterDelegate: BasePresenterDelegate {
    func gotEmergencyKit(_ kit: EmergencyKit)
    func errorUploadingToCloud(option: EmergencyKitSavingOption, error: Error)
    func uploadToCloudSuccessful(kit: EmergencyKit,
                                 option: EmergencyKitSavingOption,
                                 link: URL?)
    func hideUploadingEKView(completion: (() -> Void)?)
}

class ShareEmergencyKitPresenter<Delegate: ShareEmergencyKitPresenterDelegate>: BasePresenter<Delegate> {

    fileprivate let emergencyKitDataSelector: EmergencyKitDataSelector

    fileprivate let emergencyKitExportedAction: ReportEmergencyKitExportedAction
    fileprivate let emergencyKitVerificationCodesRepository: EmergencyKitRepository
    fileprivate let supportAction: SupportAction
    fileprivate let sessionActions: SessionActions

    init(delegate: Delegate,
         emergencyKitExportedAction: ReportEmergencyKitExportedAction,
         emergencyKitDataSelector: EmergencyKitDataSelector,
         emergencyKitVerificationCodesRepository: EmergencyKitRepository,
         feedbackAction: SupportAction,
         sessionActions: SessionActions
    ) {
        self.emergencyKitExportedAction = emergencyKitExportedAction
        self.emergencyKitDataSelector = emergencyKitDataSelector
        self.emergencyKitVerificationCodesRepository = emergencyKitVerificationCodesRepository
        self.supportAction = feedbackAction
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        let obs = emergencyKitDataSelector.get()

        subscribeTo(obs) { data in
            let kit = EmergencyKit.generate(data: data)
            self.reportGenerated(kit: kit)
            self.emergencyKitVerificationCodesRepository.store(code: kit.verificationCode)
            self.delegate.gotEmergencyKit(kit)
        }
    }

    // When the EK gets generated we let houston know
    private func reportGenerated(kit: EmergencyKit) {
        emergencyKitExportedAction.run(kit: kit.generated())
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
            options.append((option: .anotherCloud, isRecommended: false, isEnabled: true))
        } else {
            // if iCloud is not available, it should be at the bottom of the list
            options.append((option: .anotherCloud, isRecommended: false, isEnabled: true))
            options.append((option: .icloud, isRecommended: false, isEnabled: false))
        }

        return options
    }

    private func reportExportedViaCloud(kit: EmergencyKit, option: EmergencyKitSavingOption, link: URL?) {
        emergencyKitExportedAction.reset()
        subscribeTo(emergencyKitExportedAction.getState()) { state in
            switch state.type {
            case .VALUE:
                self.delegate.uploadToCloudSuccessful(kit: kit, option: option, link: link)
            case .ERROR:
                if let error = state.error {
                    self.delegate.hideUploadingEKView {
                        self.handleError(error)
                    }
                }
            case .EMPTY, .LOADING:
                // Nothing to do
                ()
            }
        }

        let method: ExportEmergencyKit.Method
        switch option {
        case .drive:
            method = .drive
        case .icloud:
            method = .icloud
        case .anotherCloud:
            Logger.fatal("Got another cloud after successful export")
        }
        emergencyKitExportedAction.run(kit: kit.exported(method: method))
    }

    func uploadEmergencyKitToDrive(googleUser: GIDGoogleUser, kit: EmergencyKit, fileName: String) {
        guard let user = sessionActions.getUser() else {
            Logger.fatal("Unlogged user managed to upload a kit to drive")
        }

        GoogleDriveHelper.uploadEK(
            googleUser: googleUser,
            emergencyKitUrl: kit.url,
            fileName: fileName,
            user: user,
            kitVersion: kit.version
        ) { webViewLinkString, err in

            if let err = err {
                self.delegate.errorUploadingToCloud(option: .drive, error: err)
                return
            }

            let url = URL(string: webViewLinkString ?? "") // This will be nil if the link is nil
            self.reportExportedViaCloud(kit: kit, option: .drive, link: url)
        }
    }

    func uploadEmergencyKitToICloud(kit: EmergencyKit, fileName: String) {
        guard let user = sessionActions.getUser() else {
            Logger.fatal("Unlogged user managed to upload a kit to iCloud")
        }

        ICloudHelper.uploadEK(
            emergencyKitUrl: kit.url,
            fileName: fileName,
            user: user,
            kitVersion: kit.version
        ) { kitUrl, err in
            if let err = err {
                self.delegate.errorUploadingToCloud(option: .icloud, error: err)
                return
            }

            var components = kitUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
            components?.scheme = "shareddocuments"
            self.reportExportedViaCloud(kit: kit, option: .icloud, link: components?.url)
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

    func request(cloud: String) {
        supportAction.run(type: .cloudRequest, text: cloud)
    }
}
