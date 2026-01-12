//
//  SyncViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class SyncViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(
        SyncPresenter.init,
        delegate: self,
        state: isExistingUser
    )

    private var isExistingUser = false
    private var shouldRunSyncAction = false

    /**
     * This variable determines if the navigation controller is able to push.
     * We set it to true once the view did appear.
    */
    private var canPushToHome = false
    private var syncDidFinish = false

    override var screenLoggingName: String {
        return "sync"
    }

    /**
     Be aware this screen will behave differently depending on how its invoked. If it is invoked
     from pinViewController it will work because SyncAction already has an state with success or
     failure so as soon as the presenter subscribes it gets the last state triggering either a retry or going to the home.
     If it is invoked from the appDelegate shouldRunSyncAction will be true so the action will be run and handle by
     SyncPresenter#onResponse.
     */
    convenience init(existingUser: Bool, shouldRunSyncAction: Bool = false) {
        self.init()
        self.isExistingUser = existingUser
        self.shouldRunSyncAction = shouldRunSyncAction
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.setNavigationBarHidden(true, animated: true)
        presenter.setUp()

        let text: String
        if isExistingUser {
            text = L10n.SyncViewController.s1
        } else {
            text = L10n.SyncViewController.s2
        }

        showLoading(text)

        if shouldRunSyncAction {
            presenter.runSyncAction()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        canPushToHome = true

        if syncDidFinish {
            presenter.onReadyForHome()
        }
    }

    func goToHome() {
        if !isExistingUser {
            logEvent("wallet_created")
        }

        self.navigationController!.setViewControllers([MuunTabBarController()], animated: true)
    }

    func dismissUnverifiedRecoveryCodeWarning() {
        navigationController?.dismiss(animated: false)
    }

    func presentUnverifiedRecoveryCodeWarning() {
        let warningScreen = UnverifiedRcWarningViewController(actionButtonTapped: { [weak self] in
            self?.presenter.onUserAcknowledgeRecoveryCodeUnverified()
        })

        self.navigationController!.present(warningScreen, animated: true)
    }
}

extension SyncViewController: SyncDelegate {

    func syncFailed() {
        navigationController!.setViewControllers([SessionExpiredViewController()], animated: true)
    }

    func onSyncFinished() {
        syncDidFinish = true

        if canPushToHome {
            presenter.onReadyForHome()
        }
    }

}
