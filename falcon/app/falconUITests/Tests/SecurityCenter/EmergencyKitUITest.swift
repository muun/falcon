//
//  EmergencyKitUITest.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 10/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

class EmergencyKitUITest: FalconUITests {

    func exportEmergencyKit(in securityCenter: SecurityCenterPage) {
        addSection("Export Emergency Kit")
        let slides = securityCenter.goToEmergecyKit()
        let sharePDF = slides.tapContinue()
        let activateKit = sharePDF.savePDF()

        let feedbackPage = activateKit.tryIncorrectAndThenCorrectCode()
        feedbackPage.finish()
        print("Emergency Kit exported")
    }

}
