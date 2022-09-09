//
//  TurboChannelsViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

class LightningNetworkSettingsViewController: MUViewController {

    private lazy var presenter = instancePresenter(LightningNetworkSettingsPresenter.init, delegate: self)

    internal var lightningNetworkSettingsView: LightningNetworkSettingsView!

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = L10n.LightningNetworkSettings.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var screenLoggingName: String {
        return "settings_lightning_network"
    }

    override func loadView() {
        lightningNetworkSettingsView = LightningNetworkSettingsView(delegate: self)
        view = lightningNetworkSettingsView
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

extension LightningNetworkSettingsViewController: LightningNetworkSettingsViewDelegate {

    func didTapLearnMore() {
        UIApplication.shared.open(
            URL(string: L10n.LightningNetworkSettings.blogPost)!, options: [:]
        )
    }

    func toggle() {
        if !lightningNetworkSettingsView.enabled {
            presenter.toggle()
        } else {
            let alert = UIAlertController(
                title: L10n.LightningNetworkSettings.confirmTitle,
                message: L10n.LightningNetworkSettings.confirmDescription,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: L10n.SettingsViewController.cancel, style: .cancel, handler: { _ in
                self.lightningNetworkSettingsView.enabled = true
            }))

            alert.addAction(UIAlertAction(title: L10n.LightningNetworkSettings.disable,
                                          style: .destructive,
                                          handler: { _ in
                self.presenter.toggle()
            }))

            present(alert, animated: true)
        }

    }

}

extension LightningNetworkSettingsViewController: LightningNetworkSettingsPresenterDelegate {

    func update(enabled: Bool) {
        lightningNetworkSettingsView.enabled = enabled
    }

    func setLoading(_ loading: Bool) {
        lightningNetworkSettingsView.loading = loading

        if loading {
            showLoading("")
        } else {
            dismissLoading()
        }
    }

}
