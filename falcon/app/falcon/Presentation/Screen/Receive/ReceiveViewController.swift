//
//  ReceiveViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import CoreImage


enum ReceiveType {
    case onChain
    case lightning
    case unified
}

class ReceiveViewController: MUViewController, Resolver {
    private var scrollView = UIScrollView()
    private var segmentControlView: UISegmentedControl!
    private var receiveOnChainView: ReceiveOnChainView!
    private var receiveInLightningView: ReceiveInLightningView!
    private var receiveUnifiedView: ReceiveUnifiedView!
    private var notificationsPrimingView: NotificationsPrimingView!

    private var receiveInLightningViewConstraints: [NSLayoutConstraint] = []
    private var receiveOnChainViewConstraints: [NSLayoutConstraint] = []
    private var receiveUnifiedViewConstraints: [NSLayoutConstraint] = []

    fileprivate lazy var presenter = instancePresenter(ReceivePresenter.init, delegate: self)
    fileprivate lazy var typeLogParams = segwitLogParams
    fileprivate let segwitLogParams = ["type": "segwit_address"]
    fileprivate let legacyLogParams = ["type": "legacy_address"]
    fileprivate let taprootLogParams = ["type": "taproot_address"]
    fileprivate let onChainAddressLogParams = ["type": "on_chain_address"]
    fileprivate let lightningInvoiceLogParams = ["type": "lightning_invoice"]
    fileprivate let unifiedFormatLogParams = ["type": "unified_format"]
    fileprivate let notificationLogParams = ["type": "notifications_priming"]

    fileprivate let receiveLogName = "receive"
    fileprivate var origin: String

    // Allow invoice creation on lightning tab tap.
    private var isHighFeesFlowAccepted = false

    private var isHighFeesFlowVisible: Bool?

    private var receiveType: ReceiveType = .onChain {
        didSet {
            presenter.setCustomAmount(nil)
            if oldValue != receiveType {
                showViewForCurrentReceiveType()
            }
        }
    }

    private var invoice: IncomingInvoiceInfo?

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

    override func viewDidLoad() {
        switch presenter.retrieveReceivePreference() {
        case .ONCHAIN:
            receiveType = .onChain
            segmentControlView.selectedSegmentIndex = 0
        case .LIGHTNING:
            receiveType = .lightning
            segmentControlView.selectedSegmentIndex = 0
        case .UNIFIED:
            receiveType = .unified
        }

        presenter.onViewLoaded()

        additionalSafeAreaInsets = .zero
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigation()

        presenter.setUp()

        // Wait for this value to be loaded, if it is not loaded for the first time yet, this will be executed as soon
        // as flags repositories respondes
        if isHighFeesFlowVisible != nil {
            if receiveType == .unified {
                presenter.refreshUnifiedQR()
            } else if receiveType == .lightning {
                presenter.refreshLightningInvoice()
            }
        }

        let buttonItem = UIBarButtonItem(image: Asset.Assets.scan.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(ReceiveViewController.didTapLNURL))
        buttonItem.tintColor = Asset.Colors.muunBlue.color
        buttonItem.accessibilityIdentifier = "Receive with LNURL"
        navigationItem.rightBarButtonItem = buttonItem
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        presenter.tearDown()
    }

    private func setUpView() {
        self.view = UIView()

        view.backgroundColor = Asset.Colors.background.color
        setUpScrollView()
        setUpSegmentedControl()
        setUpOnChainView()
        setUpLightningView()
        setUpUnifiedView()
        setUpNotificationsPrimingView()
    }

    private func setUpScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setUpSegmentedControl() {
        segmentControlView = UISegmentedControl()

        if isOnchainDefaultPreference() {
            segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s1, at: 0, animated: true)
            segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s2, at: 1, animated: true)

        } else {
            segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s2, at: 0, animated: true)
            segmentControlView.insertSegment(withTitle: L10n.ReceiveViewController.s1, at: 1, animated: true)
        }

        segmentControlView.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        segmentControlView.selectedSegmentIndex = 0
        segmentControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentControlView.tintColor = Asset.Colors.muunBlue.color
        scrollView.addSubview(segmentControlView)

        NSLayoutConstraint.activate([
            segmentControlView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: .sideMargin),
            segmentControlView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -.sideMargin),
            segmentControlView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: .sideMargin),
            segmentControlView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * .sideMargin)
        ])
    }

    private func setUpOnChainView() {
        receiveOnChainView = ReceiveOnChainView(
            addressSet: presenter.getOnChainAddresses(),
            delegate: self,
            defaultAddressType: presenter.defaultAddressType()
        )
        receiveOnChainView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(receiveOnChainView)

        receiveOnChainViewConstraints = [
            receiveOnChainView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            receiveOnChainView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            receiveOnChainView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor),
            receiveOnChainView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        receiveOnChainView.alpha = 0
    }

    private func setUpLightningView() {
        receiveInLightningView = ReceiveInLightningView(delegate: self)
        receiveInLightningView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(receiveInLightningView)

        receiveInLightningViewConstraints = [
            receiveInLightningView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            receiveInLightningView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            receiveInLightningView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor),
            receiveInLightningView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        receiveInLightningView.isHidden = true
    }

    private func setUpUnifiedView() {
        receiveUnifiedView = ReceiveUnifiedView(delegate: self,
                                                addressType: presenter.defaultAddressType())
        receiveUnifiedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(receiveUnifiedView)

        receiveUnifiedViewConstraints = [
            receiveUnifiedView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            receiveUnifiedView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            receiveUnifiedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            receiveUnifiedView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            receiveUnifiedView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        receiveUnifiedView.isHidden = true
    }

    private func setUpNotificationsPrimingView() {
        notificationsPrimingView = NotificationsPrimingView(delegate: self)
        notificationsPrimingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationsPrimingView)

        NSLayoutConstraint.activate([
            notificationsPrimingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationsPrimingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationsPrimingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if presenter.retrieveReceivePreference() == .UNIFIED {
            NSLayoutConstraint.activate([
                // Add some space below the top of the screen
                notificationsPrimingView.topAnchor.constraint(equalTo: view.topAnchor,
                                                              constant: 4)])
        } else {
            NSLayoutConstraint.activate([
                // Add some space below the segmented control
                notificationsPrimingView.topAnchor.constraint(equalTo: segmentControlView.bottomAnchor,
                                                              constant: 4)])
        }

        notificationsPrimingView.isHidden = true
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        if presenter.retrieveReceivePreference() == .UNIFIED {
            title = L10n.ReceiveViewController.receiveBitcoin
        } else {
            title = L10n.ReceiveViewController.s3
        }
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

        if isOnchainDefaultPreference() {
            receiveType = index == 0 ? .onChain : .lightning
        } else {
            receiveType = index == 0 ? .lightning : .onChain
        }
    }

    private func isOnchainDefaultPreference() -> Bool {
        return presenter.retrieveReceivePreference() == .ONCHAIN
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

    private func showViewForCurrentReceiveType() {
        switch receiveType {
        case .onChain:
            showOnChain()
        case .lightning:
            showLightning()
        case .unified:
            showUnifiedQR()
        }
    }

    func updateHighFeesFlowState(isVisible: Bool) {
        // If we are not seeing high fees flow refresh invoices.
        showViewForCurrentReceiveType()

        isHighFeesFlowVisible = isVisible
        self.receiveInLightningView.isHighFeesFlow = isVisible
        self.receiveUnifiedView.isHighFeesFlow = isVisible
    }

    // We only display the push notifications priming view for on-chain addresses if we have never asked before
    private func showOnChain() {
        receiveInLightningView.isHidden = true
        NSLayoutConstraint.deactivate(receiveInLightningViewConstraints)

        func displayPermissionsView() {
            notificationsPrimingView.isHidden = false
            receiveOnChainView.isHidden = true
        }

        func displayOnChainAddressesView() {
            typeLogParams = onChainAddressLogParams
            logScreen(receiveLogName, parameters: getLogParams())

            notificationsPrimingView.isHidden = true
            receiveOnChainView.resetOptions()
            receiveOnChainView.isHidden = false
            NSLayoutConstraint.activate(receiveOnChainViewConstraints)
            receiveOnChainView.alpha = 0
            receiveOnChainView.animate(direction: .topToBottom, duration: .short)
        }

        if !presenter.hasSkippedPushNotificationsPermission() {
            PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
                if status == .notDetermined {
                    self.showNotificationsPriming(isLightning: false)
                } else {
                    displayOnChainAddressesView()
                }
            }
        } else {
            displayOnChainAddressesView()
        }
    }

    // We display the push notifications priming view for o lightning if we know that the permissions are not granted
    private func showLightning() {
        receiveOnChainView.isHidden = true
        NSLayoutConstraint.deactivate(receiveOnChainViewConstraints)

        func displayPermissionsView() {
            notificationsPrimingView.isHidden = false
            receiveInLightningView.isHidden = true
        }

        func displayInvoiceView() {
            typeLogParams = lightningInvoiceLogParams
            logScreen(receiveLogName, parameters: getLogParams())

            // Always update the invoice before displaying the view unless we don't know if the view is high fees yet.
            // In that case Invoices will be refreshed as soon as we know the flags status.
            // The other flag, is HighFeesFlowAccepted is for lightning tab pressed. Once a new invoice is requested
            // manually we start recreating invoices even if high flow fees is turned on.
            if isHighFeesFlowVisible == false || isHighFeesFlowAccepted {
                presenter.refreshLightningInvoice()
            }

            notificationsPrimingView.isHidden = true
            receiveInLightningView.setAmount(nil)
            receiveInLightningView.isHidden = false
            NSLayoutConstraint.activate(receiveInLightningViewConstraints)
            receiveInLightningView.alpha = 0
            receiveInLightningView.animate(direction: .topToBottom, duration: .short)
        }

        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            if status == .notDetermined || status == .denied {
                self.showNotificationsPriming(isLightning: true)
            } else {
                displayInvoiceView()
            }
        }
    }

    // We display the push notifications priming view for o lightning if we know that the permissions are not granted
    private func showUnifiedQR() {
        NSLayoutConstraint.deactivate(receiveOnChainViewConstraints)
        segmentControlView.removeFromSuperview()
        receiveOnChainView.isHidden = true
        receiveInLightningView.isHidden = true
        func displayPermissionsView() {
            notificationsPrimingView.isHidden = false
        }

        func displayUnifiedView() {
            typeLogParams = unifiedFormatLogParams
            logScreen(receiveLogName, parameters: getLogParams())

            // Always update the invoice before displaying the view unless we don't know if the view is high fees flow
            // yet. In that case Invoices will be refreshed as soon as we know the flags status
            if isHighFeesFlowVisible == false {
                presenter.refreshUnifiedQR()
            }

            notificationsPrimingView.isHidden = true
            receiveUnifiedView.setAmount(nil)
            receiveUnifiedView.isHidden = false
            NSLayoutConstraint.activate(receiveUnifiedViewConstraints)
            receiveUnifiedView.alpha = 0
            receiveUnifiedView.animate(direction: .topToBottom, duration: .short)
        }

        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            if status == .notDetermined || status == .denied {
                self.showNotificationsPriming(isLightning: true)
            } else {
                displayUnifiedView()
            }
        }
    }

    @objc func didTapLNURL() {
        let vc: UIViewController
        if presenter.isLNURLFirstTimeUser() {
            vc = LNURLFirstTimeViewController()
        } else {
            vc = LNURLScanQRViewController()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ReceiveViewController: ReceivePresenterDelegate {
    func didReceiveNewOperation(message: String) {
        showToast(message: message)
    }

    func show(invoice: IncomingInvoiceInfo?) {
        self.invoice = invoice
        receiveInLightningView.displayInvoice(invoice)
    }

    func show(bitcoinURIViewModel: BitcoinURIViewModel?) {
        receiveUnifiedView.display(bitcoinURIViewModel: bitcoinURIViewModel)
    }
}

extension ReceiveViewController: ReceiveOnChainViewDelegate {

    func didTapOnAddressTypeControl() {
        let userActivatedFeature: UserActivatedFeaturesSelector = ReceiveViewController.resolve()
        let blockchainHeightRepository: BlockchainHeightRepository = ReceiveViewController.resolve()
        let optionsRetriever = AddressTypeOptionsRetriever(userActivatedFeatureSelector: userActivatedFeature,
                                                           blockheightRepository: blockchainHeightRepository)
        let options = optionsRetriever.run(selectedOption: receiveOnChainView.addressType)
        let vc = MUActionSheetView(
            delegate: self,
            headerTitle: L10n.AddressTypeSelectViewController.title,
            screenNameForLogs: "receive_address_type_select",
            viewOptions: options)

        present(vc, animated: true)
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

        if receiveType == .lightning {

            if let expirationTime = invoice?.formattedExpirationTime {

                let message = NSMutableAttributedString(string: L10n.ReceiveViewController.s5(expirationTime))
                    .set(bold: L10n.ReceiveViewController.s4, color: Asset.Colors.background.color)

                showToast(message: message)

                return
            }

        }

        showToast(message: L10n.ReceiveViewController.s4)
    }

    func didTapOnAddress(address: String) {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.onChainAddress(address))
        self.present(overlayVc, animated: true)
    }

    func didTapOnAddAmount() {
        let customAmount = presenter.getCustomAmount()
        var inputCurrency: MonetaryAmountWithCompleteDataOfCurrency?
        if let customAmount = customAmount {
            let realCurrencyForAmount = customAmount.selectedCurrency
            let inputCurrencyCode = customAmount.bitcoinAmount.inInputCurrency
            inputCurrency = MonetaryAmountWithCompleteDataOfCurrency(monetaryAmount: inputCurrencyCode,
                                                                     currency: realCurrencyForAmount)
        }
        let vc = ReceiveAmountInputViewController(
            delegate: self,
            amount: inputCurrency,
            receiveType: receiveType
        )
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true)
    }

    func didToggleOptions(visible: Bool) {
        view.setNeedsLayout()
        view.layoutIfNeeded()

        if visible {
            // Scroll to bottom
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height
                    - self.scrollView.bounds.height
                    + self.scrollView.contentInset.bottom)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

}

extension ReceiveViewController: ReceiveInLightningViewDelegate {

    func didTapOnInvoice(_ invoice: String) {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.lightningInvoice(invoice))
        self.present(overlayVc, animated: true)
    }

    func didTapOnRequestNewInvoice() {
        isHighFeesFlowAccepted = true
        presenter.refreshLightningInvoice()
    }
}

extension ReceiveViewController: ReceiveUnifiedViewDelegate {
    func didTapOn(URI: BitcoinURIViewModel) {
        let dialog = DetailedUnifiedURIView(bitcoinURIViewModel: URI,
                                            screenNameForLogs: "more_info")
        self.present(dialog, animated: true)
    }

    func didTapOnRequestNewUnfiedQR() {
        presenter.refreshUnifiedQR()
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
        showViewForCurrentReceiveType()
    }

    func permissionGranted() {
        showViewForCurrentReceiveType()
    }

}

extension ReceiveViewController: ReceiveAmountInputViewControllerDelegate {

    func didConfirm(bitcoinAmount: BitcoinAmountWithSelectedCurrency?) {
        presenter.setCustomAmount(bitcoinAmount)

        if receiveType == .onChain {
            receiveOnChainView.setAmount(bitcoinAmount)
        } else {
            if #available(iOS 13, *) {
                // in iOS 13+ the modal presentation style changes and doesn't actually *cover* everything
                // that means that viewWillDisappear/viewWillAppear won't trigger for this VC when showing
                // the amount modal. So we need to trigger a refresh of the invoice manually.
                // For older versions, the viewWillAppear will take care of it. And we actually want that, since
                // this method requires the view to be fully shown and will crash otherwise.
                if receiveType == .unified {
                    presenter.refreshUnifiedQR()
                } else {
                    presenter.refreshLightningInvoice()
                }
            }
            if receiveType == .unified {
                receiveUnifiedView.setAmount(bitcoinAmount)
            } else {
                receiveInLightningView.setAmount(bitcoinAmount)
            }
        }
    }

}

extension ReceiveViewController: MUActionSheetViewDelegate {

    func didSelect(option: any MUActionSheetOption) {

        guard let addressType = option as? AddressTypeViewModel else {
            let optionName = option.name
            Logger.fatal("receive actionSheet is working with something that is not an AddressViewModel \(optionName)")
        }

        receiveOnChainView.addressType = addressType

        if presenter.retrieveReceivePreference() == .UNIFIED {
            receiveUnifiedView.addressType = addressType
            presenter.refreshUnifiedQR(replacingSelectedAddressTypeBy: addressType)
        }

        switch addressType {
        case .segwit:
            typeLogParams = segwitLogParams
            logScreen(receiveLogName, parameters: getLogParams())
        case .legacy:
            typeLogParams = legacyLogParams
            logScreen(receiveLogName, parameters: getLogParams())
        case .taproot:
            typeLogParams = taprootLogParams
            logScreen(receiveLogName, parameters: getLogParams())
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
