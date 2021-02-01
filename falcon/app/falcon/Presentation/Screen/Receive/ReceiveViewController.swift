//
//  ReceiveViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import CoreImage

class ReceiveViewController: MUViewController {

    private var segmentControlView: UISegmentedControl!
    private var receiveOnChainView: ReceiveOnChainView!
    private var receiveInLightningView: ReceiveInLightningView!
    private var notificationsPrimingView: NotificationsPrimingView!

    fileprivate lazy var presenter = instancePresenter(ReceivePresenter.init, delegate: self)
    fileprivate lazy var typeLogParams = segwitLogParams
    fileprivate let segwitLogParams = ["type": "segwit_address"]
    fileprivate let legacyLogParams = ["type": "legacy_address"]
    fileprivate let onChainAddressLogParams = ["type": "on_chain_address"]
    fileprivate let lightningInvoiceLogParams = ["type": "lightning_invoice"]
    fileprivate let notificationLogParams = ["type": "notifications_priming"]

    fileprivate let receiveLogName = "receive"
    fileprivate var origin: String

    override func customLoggingParameters() -> [String: Any]? {
        return getLogParams()
    }

    override var screenLoggingName: String {
        return receiveLogName
    }

    init(origin: Constant.ReceiveOrigin) {
        self.origin = origin.rawValue

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        setUpView()

        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigation()

        presenter.setUp()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        presenter.tearDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // For some reason, the QR does not load correctly unless it's called here
        receiveOnChainView.displaySegwit()
        // First screen is on-chain
        showOnChain()
    }

    private func setUpView() {
        self.view = UIView()
        setUpSegmentedControl()
        setUpOnChainView()
        setUpLightningView()
        setUpNotificationsPrimingView()
    }

    private func setUpSegmentedControl() {
        segmentControlView = UISegmentedControl()
        segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s1, at: 0, animated: true)
        segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s2, at: 1, animated: true)
        segmentControlView.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        segmentControlView.selectedSegmentIndex = 0
        segmentControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentControlView.tintColor = Asset.Colors.muunBlue.color
        view.addSubview(segmentControlView)

        NSLayoutConstraint.activate([
            segmentControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .sideMargin),
            segmentControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.sideMargin),
            segmentControlView.topAnchor.constraint(equalTo: view.topAnchor, constant: .sideMargin)
        ])
    }

    private func setUpOnChainView() {
        let addresses = presenter.getOnChainAddresses()
        receiveOnChainView = ReceiveOnChainView(segwit: addresses.segwit, legacy: addresses.legacy, delegate: self)
        receiveOnChainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(receiveOnChainView)

        NSLayoutConstraint.activate([
            receiveOnChainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            receiveOnChainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            receiveOnChainView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor),
            receiveOnChainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        receiveOnChainView.displaySegwit()
        receiveOnChainView.alpha = 0
    }

    private func setUpLightningView() {
        receiveInLightningView = ReceiveInLightningView(delegate: self)
        receiveInLightningView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(receiveInLightningView)

        NSLayoutConstraint.activate([
            receiveInLightningView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            receiveInLightningView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            receiveInLightningView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor),
            receiveInLightningView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        receiveInLightningView.isHidden = true
    }

    private func setUpNotificationsPrimingView() {
        notificationsPrimingView = NotificationsPrimingView(delegate: self)
        notificationsPrimingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationsPrimingView)

        NSLayoutConstraint.activate([
            notificationsPrimingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationsPrimingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Add some space below the segmented control
            notificationsPrimingView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor, constant: 4),
            notificationsPrimingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        notificationsPrimingView.isHidden = true
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.ReceiveViewController.s3
    }

    private func animateView() {
        receiveOnChainView.animate(direction: .topToBottom, duration: .short, delay: .medium)
    }

    private func getLogParams() -> [String: Any] {
        var params = ["origin": origin]
        params.merge(typeLogParams) { (_, new) in new }
        return params
    }

    @objc func segmentSelected(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex

        if index == 0 {
            showOnChain()
        } else {
            showLightning()
        }
    }

    private func showNotificationsPriming(isLightning: Bool) {
        notificationsPrimingView.isHidden = false
        if isLightning {
            notificationsPrimingView.setUpForLightning()
        } else {
            notificationsPrimingView.setUpForOnChain()
        }

        typeLogParams = notificationLogParams
        logScreen(receiveLogName, parameters: getLogParams())
    }

    // We only display the push notifications priming view for on-chain addresses if we have never asked before
    private func showOnChain() {

        receiveInLightningView.isHidden = true

        func displayPermissionsView() {
            notificationsPrimingView.isHidden = false
            receiveOnChainView.isHidden = true
        }

        func displayOnChainAddressesView() {
            typeLogParams = onChainAddressLogParams
            logScreen(receiveLogName, parameters: getLogParams())

            notificationsPrimingView.isHidden = true
            receiveOnChainView.isHidden = false
            receiveOnChainView.alpha = 0
            receiveOnChainView.animate(direction: .topToBottom, duration: .short)
        }

        if !presenter.hasSkippedPushNotificationsPermission() {
            PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
                DispatchQueue.main.async {
                    if status == .notDetermined {
                        self.showNotificationsPriming(isLightning: false)
                    } else {
                        displayOnChainAddressesView()
                    }
                }
            }
        } else {
            displayOnChainAddressesView()
        }
    }

    // We display the push notifications priming view for o lightning if we know that the permissions are not granted
    private func showLightning() {

        receiveOnChainView.isHidden = true

        func displayPermissionsView() {
            notificationsPrimingView.isHidden = false
            receiveInLightningView.isHidden = true
        }

        func displayInvoiceView() {
            typeLogParams = lightningInvoiceLogParams
            logScreen(receiveLogName, parameters: getLogParams())

            // Always update the invoice before displaying the view
            presenter.refreshLightningInvoice()

            notificationsPrimingView.isHidden = true
            receiveInLightningView.isHidden = false
            receiveInLightningView.alpha = 0
            receiveInLightningView.animate(direction: .topToBottom, duration: .short)
        }

        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            DispatchQueue.main.async {
                if status == .notDetermined || status == .denied {
                    self.showNotificationsPriming(isLightning: true)
                } else {
                    displayInvoiceView()
                }
            }
        }

    }

}

extension ReceiveViewController: ReceivePresenterDelegate {

    func didReceiveNewOperation(message: String) {
        showToast(message: message)
    }

    func show(invoice: IncomingInvoiceInfo?) {
        receiveInLightningView.displayInvoice(invoice)
    }

}

extension ReceiveViewController: ReceiveOnChainViewDelegate {

    func didSwitchToLegacy() {
        typeLogParams = legacyLogParams
        logScreen(receiveLogName, parameters: getLogParams())
    }

    func didSwitchToSegwit() {
        typeLogParams = segwitLogParams
        logScreen(receiveLogName, parameters: getLogParams())
    }

    func didTapOnCompatibilityAddressInfo() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.segwitLegacyInfo)
        self.present(overlayVc, animated: true)
    }

    func didTapOnShare(_ shareText: String) {
        shareButtonTouched(shareText)
    }

    func shareButtonTouched(_ shareText: String) {
        let activityViewController = UIActivityViewController(activityItems: [shareText as NSString],
                                                              applicationActivities: nil)

        present(activityViewController, animated: true, completion: {})
    }

    func didTapOnCopy(_ copyText: String) {
        copyButtonTouched(copyText, origin: "copy_button")
    }

    func copyButtonTouched(_ copyText: String, origin: String) {
        UIPasteboard.general.string = copyText
        presenter.saveOwnAddress(copyText)

        showToast(message: L10n.ReceiveViewController.s4)
    }

    func didTapOnAddress(address: String) {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.onChainAddress(address))
        self.present(overlayVc, animated: true)
    }

}

extension ReceiveViewController: ReceiveInLightningViewDelegate {

    func didTapOnInvoice(_ invoice: String) {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.lightningInvoice(invoice))
        self.present(overlayVc, animated: true)
    }

    func didTapOnRequestNewInvoice() {
        presenter.refreshLightningInvoice()
    }

}

extension ReceiveViewController: NotificationsPrimingViewDelegate {

    func askForPushNotificationPermission() {
        logEvent("ask_push_notifications_permission")

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { permissionGranted, _ in
                DispatchQueue.main.async {
                    guard permissionGranted else {
                        self.logEvent("push_notifications_permission_declined")
                        return
                    }

                    self.logEvent("push_notifications_permission_granted")
                    self.permissionGranted()

                    // Attempt registration for remote notifications on the main thread
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        )
    }

    func didTapOnSkipButton() {
        presenter.skipPushNotificationsPermission()
        showOnChain()
    }

    func permissionGranted() {
        if segmentControlView.selectedSegmentIndex == 0 {
            showOnChain()
        } else {
            showLightning()
        }
    }

}

extension ReceiveViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(self.segmentControlView, using: .segmentedControl)
    }
}
