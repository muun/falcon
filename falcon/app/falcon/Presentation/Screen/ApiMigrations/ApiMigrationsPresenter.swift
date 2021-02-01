//
//  ApiMigrationsPresenter.swift
//  falcon
//
//  Created by Federico Bond on 27/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import RxSwift
import core

protocol ApiMigrationsDelegate: BasePresenterDelegate {
    func onMigrationFinished()
    func migrationFailed()
}

class ApiMigrationsPresenter<Delegate: ApiMigrationsDelegate>: BasePresenter<Delegate> {

    private var apiMigrationAction: ApiMigrationAction

    init(delegate: Delegate, apiMigrationAction: ApiMigrationAction) {
        self.apiMigrationAction = apiMigrationAction
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(apiMigrationAction.getState(), onNext: self.onResponse)
    }

    private func onResponse(_ result: ActionState<Void>) {
        switch result.type {

        case .EMPTY:
            print()

        case .ERROR:
            delegate.migrationFailed()

        case .LOADING:
            print()

        case .VALUE:
            delegate.onMigrationFinished()
        }
    }

    func runApiMigrationAction() {
        apiMigrationAction.run()
    }

}
