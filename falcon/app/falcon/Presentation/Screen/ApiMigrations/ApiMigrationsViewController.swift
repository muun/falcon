//
//  ApiMigrationsViewController.swift
//  falcon
//
//  Created by Federico Bond on 27/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ApiMigrationsViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(ApiMigrationsPresenter.init, delegate: self)

    /**
     * This variable determines if the navigation controller is able to push.
     * We set it to true once the view did appear.
    */
    private var migrationDidFinish = false

    override var screenLoggingName: String {
        return "api_migrations"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.setNavigationBarHidden(true, animated: true)
        presenter.setUp()

        showLoading(L10n.ApiMigrationsViewController.loading)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.runApiMigrationAction()
    }

    func pushToHome() {
        self.navigationController!.setViewControllers([MuunTabBarController()], animated: true)
    }

}

extension ApiMigrationsViewController: ApiMigrationsDelegate {

    func migrationFailed() {
        let alert = UIAlertController(
            title: L10n.ApiMigrationsViewController.failedAlertTitle,
            message: L10n.ApiMigrationsViewController.failedAlertMessage,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: L10n.ApiMigrationsViewController.failedAlertRetry,
            style: .default,
            handler: { _ in
                self.presenter.runApiMigrationAction()
            }
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func onMigrationFinished() {
        pushToHome()
    }

}
