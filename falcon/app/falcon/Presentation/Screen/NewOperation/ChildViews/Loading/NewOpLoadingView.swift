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

class NewOpLoadingView: MUView, PresenterInstantior {

    fileprivate lazy var presenter = instancePresenter(NewOpLoadingPresenter.init, delegate: self, state: paymentIntent)

    private let paymentIntent: PaymentIntent
    private let origin: Constant.NewOpAnalytics.Origin
    weak var delegate: OpLoadingTransitions?

    init(paymentIntent: PaymentIntent,
         delegate: OpLoadingTransitions?,
         origin: Constant.NewOpAnalytics.Origin) {
        self.paymentIntent = paymentIntent
        self.delegate = delegate
        self.origin = origin

        super.init(frame: CGRect.zero)

        let view = LoadingView()
        view.titleText = L10n.NewOpLoadingView.s1

        view.addTo(self)

        presenter.startLoading(origin: origin)
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
