//
//  ActivateEmergencyKitPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 03/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core

protocol ActivateEmergencyKitPresenterDelegate: BasePresenterDelegate {}

class ActivateEmergencyKitPresenter<Delegate: ActivateEmergencyKitPresenterDelegate>: BasePresenter<Delegate> {

    private let emergencyKitExportedAction: ReportEmergencyKitExportedAction
    fileprivate let emergencyKitVerificationCodesRepository: EmergencyKitVerificationCodesRepository

    init(delegate: Delegate,
         emergencyKitExportedAction: ReportEmergencyKitExportedAction,
         emergencyKitVerificationCodesRepository: EmergencyKitVerificationCodesRepository) {
        self.emergencyKitExportedAction = emergencyKitExportedAction
        self.emergencyKitVerificationCodesRepository = emergencyKitVerificationCodesRepository

        super.init(delegate: delegate)
    }

    func reportExported(verificationCode: String) {
        emergencyKitExportedAction.run(date: Date(), verificationCode: verificationCode, isVerified: true)
    }

    func isOld(code: String) -> Bool {
        return emergencyKitVerificationCodesRepository.isOld(code: code)
    }

}
