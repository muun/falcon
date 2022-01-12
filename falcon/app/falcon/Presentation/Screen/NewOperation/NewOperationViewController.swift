//
//  NewOperationViewController.swift
//  falcon
//
//  Created by Manu Herrera on 07/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol NewOpViewDelegate: AnyObject {
    func readyForNextState(_ isReady: Bool, error: String?)

    func update(buttonText: String)
}

protocol NewOperationChildViewDelegate: AnyObject {
    func pushNextState()
}

class NewOperationViewController: MUViewController {

    fileprivate var keyboardWillShow = false
    fileprivate var comesFromBack = false
    fileprivate var newOpView: NewOperationView!
    fileprivate var paymentIntent: PaymentIntent
    fileprivate var origin: Constant.NewOpAnalytics.Origin

    private var expiresTime: Double = 0
    private var newOpParams: [String: Any] = [:]

    fileprivate var viewBuilder: OpViewBuilder?

    fileprivate lazy var presenter = instancePresenter(NewOperationPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "new_op"
    }

    init(paymentIntent: PaymentIntent, origin: Constant.NewOpAnalytics.Origin) {
        self.paymentIntent = paymentIntent
        self.origin = origin
        super.init(nibName: nil, bundle: nil)

        switch paymentIntent {
        case .toAddress(let uri):
            presenter.start(uri: uri.raw)

            // The code below needs the view to be alive already
            self.loadViewIfNeeded()

            self.viewBuilder = OpToAddressViewBuilder(transitionDelegate: presenter,
                                                      newOpViewDelegate: self,
                                                      filledDataDelegate: self,
                                                      amountDelegate: newOpView)

            newOpParams = ["type": Constant.NewOpAnalytics.OpType.toAddress.rawValue,
                           "origin": origin.rawValue]
            title = L10n.NewOperationViewController.s1

        case .submarineSwap(let invoice):
            presenter.start(invoice: invoice)

            // The code below needs the view to be alive already
            self.loadViewIfNeeded()

            self.viewBuilder = OpSubmarineSwapViewBuilder(transitionDelegate: presenter,
                                                          newOpViewDelegate: self,
                                                          filledDataDelegate: self,
                                                          amountDelegate: newOpView)
            newOpParams = ["type": Constant.NewOpAnalytics.OpType.submarineSwap.rawValue,
                           "origin": origin.rawValue]
            title = L10n.NewOperationViewController.s2

        case .fromHardwareWallet, .toContact, .toHardwareWallet:
            Logger.fatal("Intent is not implemented yet: \(paymentIntent)")
        case .lnurlWithdraw:
            Logger.fatal("Intent is not handled by this view controller: \(paymentIntent)")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        newOpView = NewOperationView(stateTransitions: presenter, filledDataDelegate: self)

        let recognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                          action: #selector(swipe(_:)))
        recognizer.edges = .left
        newOpView.addGestureRecognizer(recognizer)

        self.view = newOpView

        presenter.setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We have some views that occupy the whole screen so we need to disable this
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        setUpNavigation()
        addKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()
    }

    deinit {
        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constant.Images.back,
                                                           style: .plain,
                                                           target: self,
                                                           action: .back)
    }

    @objc func swipe(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            back()
        }
    }

    @objc func back() {
        comesFromBack = true
        presenter.back()
    }

    func replaceCurrentView(with view: MUView, filledData: [MUView]) {

        if let view = view as? NewOperationChildView {
            keyboardWillShow = view.willDisplayKeyboard
        } else {
            keyboardWillShow = false
        }

        newOpView.replaceCurrentView(with: view, filledData: filledData, isBack: comesFromBack)

        comesFromBack = false
    }

    private func fullUri() -> String? {
        switch paymentIntent {
        case .toAddress(let uri):
            return uri.uri.absoluteString
        default:
            return nil
        }
    }

    private func displayErrorView(type: NewOpError) {
        navigationController?.setNavigationBarHidden(true, animated: true)

        let view = ErrorView()
        view.delegate = self
        view.model = type
        view.addTo(self.view)

        forceHideKeyboard()
        self.view.gestureRecognizers?.removeAll()
    }

}

extension NewOperationViewController: NewOpViewDelegate {

    private func showInsufficientFundsScreen(amountPlusFee: MonetaryAmount, totalBalance: MonetaryAmount) {
        displayErrorView(type: .insufficientFunds(
            amountPlusFee: amountPlusFee.toString(),
            maxBalance: totalBalance.toString()
        ))
    }

    func readyForNextState(_ isReady: Bool, error: String?) {
        newOpView.readyForNextState(isReady, error: error)
    }

    func update(buttonText: String) {
        newOpView.buttonText = buttonText
    }

    private func forceHideKeyboard() {
        view.endEditing(true)
        newOpView.animateButtonTransition(height: 0)
    }

}

extension NewOperationViewController: NewOpStateMachineDelegate {

    func unexpectedError() {
        displayErrorView(type: .unexpected)
    }

    private func pushToSupportScreen() {
        // We remove ourself from the stack to avoid weird keyboard animations when pushing and popping
        // And since there is nothing else to do in the new op when we reach this error
        navigationController?.pushViewController(SupportViewController(type: .support),
                                                 animated: true,
                                                 removeFromStack: true)
    }

    func requestNextStep(_ data: NewOpState) {
        guard let nextStep = viewBuilder?.getNextStep(state: data) else {
            Logger.fatal("View builder didn't return new step")
        }

        switch nextStep {
        case .view(let view, let filledData):
            replaceCurrentView(with: view, filledData: filledData)
            newOpView.displayOneConfNotice(viewBuilder?.shouldDisplayOneConfNotice(state: data) ?? false)
        case .modal(let vc):
            let navController = UINavigationController(rootViewController: vc)
            if vc.isKind(of: CurrencyPickerViewController.self) {
                // We want fullscreen modal for currency picker
                navController.modalPresentationStyle = .fullScreen
            }
            navigationController?.present(navController, animated: true)
        }

        if let customLogging = viewBuilder?.getLoggingData(state: data) {
            if let newParams = customLogging.logParams {
                newOpParams.merge(newParams) { (_, new) in new }
            }

            let logName = "\(screenLoggingName)_\(customLogging.logName)"
            logScreen(logName, parameters: newOpParams)
        }
    }

    func updateStep(_ data: NewOpState) {

        switch data {
        case .amount(let data):
            newOpView.withCurrentView { (v: NewOpAmountView) in v.updateUI(data: data) }

        default:
            Logger.fatal("Can't update for state \(type(of: data))")
        }
    }

    func invoiceMissingAmount() {
        displayErrorView(type: .invoiceMissingAmount)
    }

    private func toggleUserInteraction(isEnabled: Bool) {
        newOpView.subviews.forEach { (v) in
            v.isUserInteractionEnabled = isEnabled
        }
        newOpView.gestureRecognizers?.forEach({ (g) in
            g.isEnabled = isEnabled
        })

        navigationController?.navigationBar.isUserInteractionEnabled = isEnabled
        let color: UIColor = isEnabled ? Asset.Colors.muunGrayDark.color : Asset.Colors.muunDisabled.color
        navigationController?.navigationBar.tintColor = color
    }

    func showExchangeRateWindowTooOldError() {
        displayErrorView(type: .exchangeRateWindowTooOld)
    }

    func swapError(_ error: NewOpError) {
        displayErrorView(type: error)
    }

    func invalidAddress() {
        displayErrorView(type: .invalidAddress(fullUri() ?? ""))
    }

    func setExpires(_ expiresTime: Double) {
        self.expiresTime = expiresTime

        newOpView.setExpires(expiresTime)
    }

    func expiredInvoice() {
        displayErrorView(type: .expiredInvoice)
    }

    func notEnoughBalance(amountPlusFee: MonetaryAmount, totalBalance: MonetaryAmount) {
        showInsufficientFundsScreen(amountPlusFee: amountPlusFee, totalBalance: totalBalance)
    }

    func cancel(confirm: Bool) {
        if confirm {
            presentAbortAlertView()
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func presentAbortAlertView() {
        let alert = UIAlertController(
            title: L10n.NewOperationViewController.s3,
            message: L10n.NewOperationViewController.s4,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.NewOperationViewController.s5, style: .default, handler: { _ in
            alert.dismiss(animated: true)
            self.presenter.cancelAbort()
        }))

        alert.addAction(UIAlertAction(title: L10n.NewOperationViewController.s6, style: .destructive, handler: { _ in
            self.forceHideKeyboard()
            self.navigationController!.popToRootViewController(animated: true)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.navigationController!.present(alert, animated: true)
    }

    func requestFinish(_ operation: core.Operation) {
        toggleUserInteraction(isEnabled: false)
        newOpView.isLoading = true

        logEvent("\(screenLoggingName)_submitted", parameters: newOpParams)
    }

    func operationCompleted(_ operation: core.Operation) {
        newOpParams["operation_id"] =  "\(operation.id ?? 0)"
        logEvent("\(screenLoggingName)_completed", parameters: newOpParams)

        toggleUserInteraction(isEnabled: true)
        newOpView.isLoading = false

        self.navigationController!.popToRootViewController(animated: true)
    }

    func operationError() {
        logEvent("\(screenLoggingName)_error")

        toggleUserInteraction(isEnabled: true)
        newOpView.isLoading = false
        displayErrorView(type: .unexpected)
    }

    private func showDustError() {
        displayErrorView(type: .amountBelowDust)
    }

}

// Keyboard stuff
extension NewOperationViewController {

    override func keyboardWillHide(notification: NSNotification) {
        // If we know the keyboard will be shown, we ignore this call to avoid jumps
        // BUT animate if we're presenting someone
        if !keyboardWillShow || presentedViewController != nil {
            newOpView.animateButtonTransition(height: 0)
        }
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            newOpView.animateButtonTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

}

extension NewOperationViewController: ErrorViewDelegate {

    func logErrorView(_ name: String, params: [String: Any]?) {
        logScreen(name, parameters: params)
    }

    func backToHomeTouched() {
        navigationController!.popToRootViewController(animated: true)
    }

    func descriptionTouched(type: ErrorViewModel) {
        guard let type = type as? NewOpError else {
            return
        }

        switch type {
        case .unexpected, .noPaymentRoute:
            pushToSupportScreen()
        default:
            break
        }
    }

}

extension NewOperationViewController: NewOpDestinationViewDelegate {

    func showMoreInfo(info: MoreInfo) {
        let overlayVc = BottomDrawerOverlayViewController(info: info)
        navigationController!.present(overlayVc, animated: true)
    }

}

extension NewOperationViewController: NewOperationViewDelegate {

    func oneConfNoticeTapped() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.oneConfNotice)
        self.present(overlayVc, animated: true)
    }

    func amountBelowDust() {
        showDustError()
    }

    func didPressInfoButton(info: MoreInfo) {
        showMoreInfo(info: info)
    }

    func invoiceJustExpired() {
        expiredInvoice()
    }

    func changeCurrency(_ currency: Currency) {
        presenter.changeCurrency(currency)
    }

}

extension NewOperationViewController: NewOperationPresenterDelegate {

}

fileprivate extension Selector {
    static let back = #selector(NewOperationViewController.back)
}
