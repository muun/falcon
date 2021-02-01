//
//  HelpPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

protocol SupportPresenterDelegeate: BasePresenterDelegate {
    func didSendRequest()
    func didFailRequest()
}

class SupportPresenter<Delegate: SupportPresenterDelegeate>: BasePresenter<Delegate> {

    private let type: SupportAction.RequestType
    private let supportAction: SupportAction
    private let sessionActions: SessionActions

    init(delegate: Delegate,
         state: SupportAction.RequestType,
         supportAction: SupportAction,
         sessionActions: SessionActions) {
        self.type = state
        self.supportAction = supportAction
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    func sendRequest(text: String) {
        supportAction.run(type: type, text: text)
        subscribeTo(supportAction.getState(), onNext: supportRequest)
    }

    func supportRequest(value: ActionState<()>) {
        switch value.type {
        case .EMPTY, .LOADING:
            break
        case .VALUE:
            delegate.didSendRequest()
        case .ERROR:
            guard let error = value.getError() else {
                Logger.log(.err, "didnt have an error value")
                return
            }

            handleError(error)
        }
    }

    override func handleError(_ error: Error) {
        delegate.didFailRequest()
        super.handleError(error)
    }

    func getSupportId() -> String? {
        guard let u = sessionActions.getUser(), let date = u.createdAt else {
            return nil
        }

        return date.getSupportId()
    }

}
