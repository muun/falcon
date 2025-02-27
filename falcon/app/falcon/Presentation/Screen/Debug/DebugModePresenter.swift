//
//  DebugModePresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation


protocol DebugMenuPresenterDelegate: BasePresenterDelegate,
                                     MUViewController {
    func askUserForText(message: String, completion: @escaping (String) -> Void)
    func showRequests()
    func showAnalytics()
}

class DebugMenuPresenter<Delegate: DebugMenuPresenterDelegate>: BasePresenter<Delegate> {
    private let executableGroups: [DebugExecutablesGroup]

    init(delegate: Delegate,
         executableGroups: [DebugExecutablesGroup]) {
        self.executableGroups = executableGroups

        super.init(delegate: delegate)
    }

    func onExecutableSelected(groupIndex: Int, executableIndex: Int) {
        delegate.showLoading("Wait for it :)")
        DispatchQueue.global().async {
            let executables = self.executableGroups[groupIndex].executables

            executables[executableIndex].execute(context: self) {
                DispatchQueue.main.async {
                    self.delegate.dismissLoading()
                }
            }
        }
    }

    func numberOfExecutablesIn(groupIndex: Int) -> Int {
        executableGroups[groupIndex].executables.count
    }

    func titleFor(groupIndex: Int, executableIndex: Int) -> String {
        executableGroups[groupIndex].executables[executableIndex].getTitleForCell()
    }

    func titleFor(groupIndex: Int) -> String {
        executableGroups[groupIndex].category
    }

    func numberOfGroups() -> Int {
        executableGroups.count
    }
}

extension DebugMenuPresenter: DebugMenuExecutableContext {
    func askUserForText(message: String, completion: @escaping (String) -> Void) {
        delegate.askUserForText(message: message, completion: completion)
    }

    func showRequests() {
        delegate.showRequests()
    }

    func showAnalytics() {
        delegate.showAnalytics()
    }
}
