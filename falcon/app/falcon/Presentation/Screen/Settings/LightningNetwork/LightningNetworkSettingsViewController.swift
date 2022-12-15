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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.Colors.muunHomeBackgroundColor.color

        let mainStackView = addMainStackView()

        addReceiveFormatPreferenceSetting(to: mainStackView)
        addTurboChannelsSettings(to: mainStackView)
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

    private func addTurboChannelsSettings(to stackView: UIStackView) {
        let toggleView = TurboChannelSettingsTogglePresenter<SettingsToggleView>.createView()
        stackView.addArrangedSubviewWrappingLeadingAndTrailing(toggleView)
    }

    private func addReceiveFormatPreferenceSetting(to stackView: UIStackView) {
        let view = ReceiveFormatPreferenceDropdownPresenter<ReceiveFormatSettingDropdownView>.createView()
        stackView.addArrangedSubviewWrappingLeadingAndTrailing(view)
    }

    private func addMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        stackView.spacing = 0

        view.addSubviewWrappingParent(child: stackView, skipBottomContraint: true)

        return stackView
    }
}

extension LightningNetworkSettingsViewController: LightningNetworkSettingsPresenterDelegate {
    func setLoading(_ loading: Bool) {
        if loading {
            showLoading("")
        } else {
            dismissLoading()
        }
    }
}
