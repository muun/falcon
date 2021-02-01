//
//  HelpEmergencyKitViewController.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class HelpEmergencyKitViewController: MUViewController {

    private var helpView: HelpEmergencyKitView!

    override var screenLoggingName: String {
        return "emergency_kit_help"
    }

    override func loadView() {
        super.loadView()

        helpView = HelpEmergencyKitView()
        self.view = helpView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
    }

}
