//
//  TurboChannelsViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

class OnchainSettingsViewController: MUViewController {

    private lazy var presenter = instancePresenter(OnchainSettingsPresenter.init, delegate: self)

    internal var settingsView: OnchainSettingsView!

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = L10n.OnchainSettings.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var screenLoggingName: String {
        return "settings_bitcoin_network"
    }

    override func loadView() {
        settingsView = OnchainSettingsView(delegate: self)
        view = settingsView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = UIEdgeInsets.zero

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

}

extension OnchainSettingsViewController: OnchainSettingsViewDelegate {

    func toggle() {
        if settingsView.enabled {
            presenter.toggle()
        } else {
            let alert = UIAlertController(
                title: L10n.OnchainSettings.confirmTitle,
                message: L10n.OnchainSettings.confirmDescription,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: L10n.SettingsViewController.cancel,
                                          style: .destructive,
                                          handler: { _ in
                self.settingsView.enabled = false
            }))

            alert.addAction(UIAlertAction(title: L10n.OnchainSettings.confirm, style: .default, handler: { _ in
                self.presenter.toggle()
            }))

            present(alert, animated: true)
        }

    }

}

extension OnchainSettingsViewController: OnchainSettingsPresenterDelegate {

    func update(hoursToActivation: Int) {
        settingsView!.showActivationTimer(hours: hoursToActivation)
    }

    func update(enabled: Bool) {
        settingsView.enabled = enabled
    }

    func setLoading(_ loading: Bool) {
        settingsView.loading = loading

        if loading {
            showLoading("")
        } else {
            dismissLoading()
        }
    }

}
