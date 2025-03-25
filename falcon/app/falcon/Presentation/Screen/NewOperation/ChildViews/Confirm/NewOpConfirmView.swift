//
//  NewOpConfirmView.swift
//  falcon
//
//  Created by Manu Herrera on 17/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit


protocol OpConfirmTransitions: NewOperationTransitions {
    func didConfirm()
}

class NewOpConfirmView: MUView, PresenterInstantior {

    private let feeState: FeeState
    fileprivate lazy var presenter = instancePresenter(NewOpConfirmPresenter.init, delegate: self, state: feeState)

    weak var delegate: NewOpViewDelegate?
    weak var transitionDelegate: OpConfirmTransitions?

    init(feeState: FeeState, delegate: NewOpViewDelegate?, transitionDelegate: OpConfirmTransitions?) {
        self.feeState = feeState
        self.delegate = delegate
        self.transitionDelegate = transitionDelegate

        super.init(frame: CGRect.zero)

        delegate?.update(buttonText: L10n.NewOpConfirmView.s1)
    }

    func validityCheck() {
        presenter.validityCheck()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            presenter.tearDown()
        } else {
            presenter.setUp()
        }
    }
}

extension NewOpConfirmView: NewOperationChildViewDelegate {

    func pushNextState() {
        transitionDelegate?.didConfirm()
    }

}

extension NewOpConfirmView: NewOpConfirmPresenterDelegate {

    func dataValidated(_ isValid: Bool) {
        delegate?.readyForNextState(isValid, error: nil)
    }

}
