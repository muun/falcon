//
//  VerifyEmergencyKitViewController.swift
//  falcon
//
//  Created by Manu Herrera on 11/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class VerifyEmergencyKitViewController: MUViewController {

    private var verifyView: VerifyEmergencyKitView!
    private let option: EmergencyKitSavingOption
    private let link: URL?
    private let flow: EmergencyKitFlow

    override var screenLoggingName: String {
        return "emergency_kit_cloud_verify"
    }

    init(option: EmergencyKitSavingOption, link: URL?, flow: EmergencyKitFlow) {
        self.option = option
        self.link = link
        self.flow = flow

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        super.loadView()

        verifyView = VerifyEmergencyKitView(delegate: self, option: option, hasLink: link != nil)
        self.view = verifyView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()
    }

    private func setUpNavigation() {
        switch flow {
        case .export:
            title = L10n.ShareEmergencyKitViewController.s1
        case .update:
            navigationController?.hideSeparator()
        }
    }

}

extension VerifyEmergencyKitViewController: VerifyEmergencyKitViewDelegate {

    func didTapOnOpenLink() {
        if let url = link {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func didTapOnContinue() {
        navigationController!.pushViewController(
            FeedbackViewController(feedback: flow.successFeedback), animated: true
        )
    }

}
