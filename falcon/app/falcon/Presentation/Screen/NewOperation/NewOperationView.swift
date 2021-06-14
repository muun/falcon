//
//  NewOperationView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 26/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import UIKit
import core

protocol NewOperationViewDelegate: AnyObject {
    func invoiceJustExpired()
    func didPressInfoButton(info: MoreInfo)
    func oneConfNoticeTapped()
}

protocol NewOperationChildView {
    var willDisplayKeyboard: Bool { get }
}

class NewOperationView: MUView {

    typealias FilledDataDelegate = NewOpDestinationViewDelegate & NewOperationViewDelegate

    @IBOutlet fileprivate weak var filledDataView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var moreInfoLabel: UILabel!
    @IBOutlet private weak var oneConfNoticeView: NoticeView!
    @IBOutlet private var filledDataHeightConstraint: NSLayoutConstraint!

    typealias StateView = NewOperationChildViewDelegate & MUView

    private var currentView: StateView?
    private weak var stateTransitions: NewOperationTransitions?
    private weak var filledDataDelegate: FilledDataDelegate?
    private var timer = Timer()
    private var expiresTime: Double = 0

    private let startupTime = Date()

    var isLoading: Bool {
        didSet {
            buttonView.isLoading = isLoading
        }
    }

    var buttonText: String {
        didSet {
            buttonView.buttonText = buttonText
        }
    }

    init(stateTransitions: NewOperationTransitions, filledDataDelegate: FilledDataDelegate) {
        self.stateTransitions = stateTransitions
        self.filledDataDelegate = filledDataDelegate
        self.isLoading = true
        self.buttonText = ""

        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func setUp() {
        backgroundColor = Asset.Colors.background.color

        buttonView.delegate = self
        setUpMoreInfoLabel()

        makeViewTestable()
    }

    private func setUpMoreInfoLabel() {
        moreInfoLabel.textColor = Asset.Colors.muunGrayDark.color
        moreInfoLabel.font = Constant.Fonts.system(size: .notice)
        moreInfoLabel.isHidden = true
        moreInfoLabel.text = ""
    }

    fileprivate func animate(in view: MUView, out previousView: UIView, isBack: Bool) {
        let deltaX = (isBack ? 1 : -1) * containerView.bounds.size.width

        if view as? NewOpConfirmView != nil {
            // No animations when is time to confirm
            previousView.removeFromSuperview()
            containerView.isHidden = true
            return
        }

        // Make the new view be outside view
        view.transform = CGAffineTransform(translationX: -deltaX, y: 0)
        containerView.layoutIfNeeded()

        func animate() {
            // And shift the new view in and the old one out
            view.transform = .identity
            previousView.transform = CGAffineTransform(translationX: deltaX, y: 0)

            layoutIfNeeded()
        }

        func completion(_: Bool) {
            previousView.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.3,
                       animations: animate,
                       completion: completion)
    }

    fileprivate func replace(loadingView: NewOpLoadingView, with view: MUView) {
        showContinueButton()

        if Date().timeIntervalSince(startupTime) < 0.3 {

            let deltaX = -containerView.bounds.size.width

            // Make the new view be outside view
            view.transform = CGAffineTransform(translationX: -deltaX, y: 0)
            containerView.layoutIfNeeded()

            func animate() {
                // And shift the new view in and the old one out
                view.transform = .identity
                loadingView.alpha = 0

                layoutIfNeeded()
            }

            func completion(_: Bool) {
                loadingView.removeFromSuperview()
            }

            UIView.animate(withDuration: 0.3,
                           animations: animate,
                           completion: completion)
        } else {
            animate(in: view, out: loadingView, isBack: false)
        }
    }

    func replaceCurrentView(with view: MUView, filledData: [MUView], isBack: Bool) {

        // We need this variable otherwise addTo mutates the subview array and it becomes useless
        let subViews = containerView.subviews

        containerView.isHidden = false
        view.addTo(containerView)

        if let previousView = subViews.first {

            if let loadingView = previousView as? NewOpLoadingView {
                replace(loadingView: loadingView, with: view)
            } else {
                animate(in: view, out: previousView, isBack: isBack)
            }
        }

        if let view = view as? StateView {
            currentView = view
        } else {
            currentView = nil
        }

        if !filledData.isEmpty {
            display(filledData: filledData)
        } else {
            hideFilledData()
        }
    }

    func animateButtonTransition(height: CGFloat) {

        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
            self.buttonBottomConstraint.constant = height

            self.layoutIfNeeded()

        }, completion: nil)
    }

    fileprivate func display(filledData: [MUView]) {
        filledDataHeightConstraint.isActive = false
        filledDataView.subviews.forEach { $0.removeFromSuperview() }

        filledData.forEach { (view) in
            filledDataView.addArrangedSubview(view)
        }
    }

    fileprivate func hideFilledData() {
        for view in filledDataView.subviews {
            view.removeFromSuperview()
        }

        filledDataHeightConstraint.isActive = true
    }

    func readyForNextState(_ isReady: Bool, error: String?) {
        buttonView.isEnabled = isReady

        if let error = error {
            buttonView.buttonText = error
        } else {
            buttonView.buttonText = buttonText
        }
    }

    func setExpires(_ expiresTime: Double) {
        self.expiresTime = expiresTime

        startTimer(calculateSecondsLeft())
    }

    func displayOneConfNotice() {
        oneConfNoticeView.style = .notice
        oneConfNoticeView.text = L10n.NewOperationView.s2
            .set(font: Constant.Fonts.system(size: .opHelper),
                 lineSpacing: Constant.FontAttributes.lineSpacing,
                 kerning: Constant.FontAttributes.kerning,
                 alignment: .left)
            .set(underline: L10n.NewOperationView.s3, color: Asset.Colors.muunBlue.color)

        oneConfNoticeView.delegate = self
        oneConfNoticeView.isHidden = false
    }

    private func calculateSecondsLeft() -> Int {
        return Int(expiresTime - Date().timeIntervalSince1970)
    }

    private func updateExpireLabel() {
        let timeString = formatTimeRemaining(calculateSecondsLeft())
        moreInfoLabel.text = L10n.NewOperationView.s1(timeString)

        if calculateSecondsLeft() <= 60 {
            moreInfoLabel.textColor = Asset.Colors.muunRed.color
        }
    }

    private func formatTimeRemaining(_ seconds: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"

        let timeInterval = Double(seconds)
        let timeRemaining = Date(timeIntervalSince1970: timeInterval)

        return formatter.string(from: timeRemaining)
    }

    private func startTimer(_ seconds: Int) {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: .updateTimer,
            userInfo: nil,
            repeats: true
        )
        moreInfoLabel.isHidden = false
    }

    @objc func updateTimer() {
        if calculateSecondsLeft() <= 0 {
            filledDataDelegate?.invoiceJustExpired()
            timer.invalidate()
            return
        }
        updateExpireLabel()
    }

    fileprivate func showContinueButton() {
        buttonView.isHidden = false
        buttonView.animate(direction: .bottomToTop, duration: .short)
    }

}

extension NewOperationView: NoticeViewDelegate {

    func didTapOnMessage() {
        filledDataDelegate?.oneConfNoticeTapped()
    }

}

extension NewOperationView: CurrencyPickerDelegate {

    func didSelectCurrency(_ currency: Currency) {
        if let view = currentView as? NewOpAmountView {
            view.updateInfo(newCurrency: currency)
        }
    }

}

extension NewOperationView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        pushToNextState()
    }

    func pushToNextState() {
        currentView?.pushNextState()
    }

}

extension NewOperationView: NewOpFilledAmountDelegate {

    func didPressMoreInfo(info: MoreInfo) {
        filledDataDelegate?.didPressInfoButton(info: info)
    }

    func didPressAmount() {
        for view in filledDataView.subviews {
            if let v = view as? NewOpAmountFilledDataView {
                v.cycleCurrency()
            }
        }
    }

}

extension NewOperationView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp

    fileprivate func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(buttonView, using: .continueButton)
    }
}

fileprivate extension Selector {

    static let updateTimer = #selector(NewOperationView.updateTimer)

}
