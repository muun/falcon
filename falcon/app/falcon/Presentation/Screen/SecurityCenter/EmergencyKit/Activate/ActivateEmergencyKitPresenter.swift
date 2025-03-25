//
//  ActivateEmergencyKitPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 03/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//



protocol ActivateEmergencyKitPresenterDelegate: BasePresenterDelegate {
    func reported()
}

class ActivateEmergencyKitPresenter<Delegate: ActivateEmergencyKitPresenterDelegate>: BasePresenter<Delegate> {

    private let emergencyKitExportedAction: ReportEmergencyKitExportedAction
    fileprivate let emergencyKitVerificationCodesRepository: EmergencyKitRepository

    init(delegate: Delegate,
         emergencyKitExportedAction: ReportEmergencyKitExportedAction,
         emergencyKitVerificationCodesRepository: EmergencyKitRepository) {
        self.emergencyKitExportedAction = emergencyKitExportedAction
        self.emergencyKitVerificationCodesRepository = emergencyKitVerificationCodesRepository

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        emergencyKitExportedAction.reset()
        subscribeTo(emergencyKitExportedAction.getState()) { state in
            switch state.type {
            case .VALUE:
                self.delegate?.reported()
            case .ERROR:
                if let error = state.error {
                    self.handleError(error)
                }
            case .EMPTY, .LOADING:
                // Nothing to do
                ()
            }
        }
    }

    func reportExported(kit: EmergencyKit) {
        emergencyKitExportedAction.run(kit: kit.exported(method: .manual))
    }

    func isOld(code: String) -> Bool {
        return emergencyKitVerificationCodesRepository.isOld(code: code)
    }

}
