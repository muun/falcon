//
//  RecoveryCodeTest.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

class RecoveryCodeUITest: FalconUITests {

    func setUpRecoveryCode(in securityCenter: SecurityCenterPage) -> [String] {

        addSection("security center - set up recovery code")

        let primingRc = securityCenter.goToRecoveryCodeSetup()
        let generateCode = primingRc.confirm()
        let code = generateCode.recoveryCode()
        let verifyCode = generateCode.touchContinueButton()
        verifyCode.wait()

        verifyCode.inputInvalidCode(realCode: code)
        waitUntil(condition: { verifyCode.isInvalid() }, timeout: 1, description: "inputing an invalid code fails")

        verifyCode.set(code: code)

        let confirmPage = verifyCode.touchContinueButton()
        confirmPage.wait()

        let feedbackPage = confirmPage.confirm()
        feedbackPage.finish()
        print("Recovery code setup successful")
        return code
    }
}
