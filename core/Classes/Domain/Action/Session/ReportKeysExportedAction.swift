//
//  ReportKeysExportedAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 14/05/2020.
//

import Foundation
import RxSwift

public class ReportKeysExportedAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let sessionActions: SessionActions

    public init(houstonService: HoustonService, sessionActions: SessionActions) {
        self.houstonService = houstonService
        self.sessionActions = sessionActions

        super.init(name: "ReportKeysExportedAction")
    }

    public func run() {
        runSingle(houstonService.setHasExportedKeys())
        sessionActions.setHasExportedKeys()
    }

}
