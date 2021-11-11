//
//  ReportEmergencyKitExportedAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 14/05/2020.
//

import Foundation
import RxSwift

public class ReportEmergencyKitExportedAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let sessionActions: SessionActions

    public init(houstonService: HoustonService, sessionActions: SessionActions) {
        self.houstonService = houstonService
        self.sessionActions = sessionActions

        super.init(name: "ReportEmergencyKitExportedAction")
    }

    public func run(kit: ExportEmergencyKit) {
        runSingle(houstonService.setEmergencyKitExported(exportEmergencyKit: kit).map({
            if kit.verified {
                self.sessionActions.exported(kit: kit)
            }
        }))
    }

}
