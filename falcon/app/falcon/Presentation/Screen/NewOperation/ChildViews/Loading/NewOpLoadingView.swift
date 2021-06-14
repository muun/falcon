//
//  NewOpLoadingView.swift
//  falcon
//
//  Created by Manu Herrera on 27/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol OpLoadingTransitions: AnyObject {
    func didLoad(feeInfo: FeeInfo,
                 user: User,
                 paymentRequestType: PaymentRequestType)
    func expiredInvoice()
    func invalidAddress()
    func swapError(_ error: NewOpError)
    func unexpectedError()
    func invoiceMissingAmount()
}

class NewOpLoadingView: MUView {

    fileprivate lazy var presenter = instancePresenter(NewOpLoadingPresenter.init, delegate: self, state: paymentIntent)

    private let paymentIntent: PaymentIntent
    weak var delegate: OpLoadingTransitions?

    init(paymentIntent: PaymentIntent, delegate: OpLoadingTransitions?) {
        self.paymentIntent = paymentIntent
        self.delegate = delegate

        super.init(frame: CGRect.zero)

        let view = LoadingView()
        view.titleText = L10n.NewOpLoadingView.s1

        view.addTo(self)

        presenter.startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension NewOpLoadingView: NewOpLoadingPresenterDelegate {

    func unexpectedError() {
        delegate?.unexpectedError()
    }

    func invoiceMissingAmount() {
        delegate?.invoiceMissingAmount()
    }

    func swapError(_ error: NewOpError) {
        delegate?.swapError(error)
    }

    func invalidAddress() {
        delegate?.invalidAddress()
    }

    func expiredInvoice() {
        delegate?.expiredInvoice()
    }

    func loadingDidFinish(feeInfo: FeeInfo,
                          user: User,
                          paymentRequestType: PaymentRequestType) {
        delegate?.didLoad(feeInfo: feeInfo, user: user, paymentRequestType: paymentRequestType)
    }
}
