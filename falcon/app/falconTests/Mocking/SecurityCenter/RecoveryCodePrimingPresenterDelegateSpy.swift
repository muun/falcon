//
//  RecoveryCodePrimingPresenterDelegateSpy.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun

import UIKit

class RecoveryCodePrimingPresenterDelegateSpy: RecoveryCodePrimingPresenterDelegate {
    var goToNextCalledCount = 0
    var lastRecoveryCodePassedOnGoToNextScreen: RecoveryCode!
    func goToNextScreen(recoveryCode: RecoveryCode) {
        goToNextCalledCount += 1
        lastRecoveryCodePassedOnGoToNextScreen = recoveryCode
    }
    
    var continueButtonLoadingCalledCount = 0
    var continueButtonLoadingLastStates = [Bool]()
    func continueButtonIs(loading: Bool) {
        continueButtonLoadingLastStates.append(loading)
        continueButtonLoadingCalledCount += 1
    }
    
    var showStartRecoveryCodeSetupErrorCalledCount = 0
    func showStartRecoveryCodeSetupError() {
        showStartRecoveryCodeSetupErrorCalledCount += 1
    }
    
    func showMessage(_ message: String) {
    }
    
    func pushTo(_ vc: Muun.MUViewController) {
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {}
}
