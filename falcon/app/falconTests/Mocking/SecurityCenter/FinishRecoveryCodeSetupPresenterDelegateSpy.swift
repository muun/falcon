//
//  FinishRecoveryCodeSetupPresenterDelegateSpy.swift
//  falconTests
//
//  Created by Lucas Serruya on 01/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun
import UIKit

class FinishRecoveryCodeSetupPresenterDelegateSpy: FinishRecoveryCodeSetupPresenterDelegate {
    var challengeSuccessCalledCount = 0
    func challengeSuccess() {
        challengeSuccessCalledCount += 1
    }
    
    var showFinishErrorSetupErrorCalledCount = 0
    func showFinishErrorSetupError() {
        showFinishErrorSetupErrorCalledCount += 1
    }
    
    var finishButtonLoadingStates = [Bool]()
    func finishButtonIs(loading: Bool) {
        finishButtonLoadingStates.append(loading)
    }
    
    func showMessage(_ message: String) {
    }
    
    func pushTo(_ vc: Muun.MUViewController) {
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {}
}
