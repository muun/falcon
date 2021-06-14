//
//  LNURLScanQRViewController.swift
//  falcon
//
//  Created by Federico Bond on 10/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import AVKit
import core

class LNURLScanQRViewController: MUViewController {

    @IBOutlet fileprivate weak var enterManuallyButtonView: ButtonView!
    @IBOutlet internal weak var cameraView: UIView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var sendToAddressView: UIView!
    @IBOutlet private weak var sendToAddressLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var helperLabel: UILabel!
    @IBOutlet private weak var sendToAddressViewSeparator: UIView!

    private var overlayFillLayer: CAShapeLayer = CAShapeLayer()
    internal var videoLayer: AVCaptureVideoPreviewLayer?

    internal var status: Status = .blank
    internal enum Status {
        case blank
        case scanning
        case paused
        case disabled
    }

    internal let cameraMediaType = AVMediaType.video
    internal var captureSession = AVCaptureSession()
    internal let permissionsView = CameraPermissionView()
    internal var blurEffectView = UIVisualEffectView()

    internal lazy var presenter = instancePresenter(LNURLScanQRPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "lnurl_scan_qr"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addClipboardObserver()

        presenter.setUp()

        setUpView()
        makeViewTestable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        pauseCapture()
        removeClipboardObserver()

        presenter.tearDown()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        blurEffectView.alpha = 0
    }

    private func setUpView() {
        decideFirstView()
        setUpButtons()
        setUpSendToAddressView()
        setUpHelperLabel()
    }

    override func clipboardChanged() {
        checkClipboard()
    }

    fileprivate func checkClipboard() {
        if let theString = UIPasteboard.general.string, presenter.validate(qr: theString) {
            sendToAddressView.isHidden = false
            addressLabel.text = theString
        }
    }

    private func setUpButtons() {
        enterManuallyButtonView.style = .secondary
        enterManuallyButtonView.delegate = self
        enterManuallyButtonView.buttonText = L10n.LNURLScanQRViewController.enterManually
        enterManuallyButtonView.isEnabled = true
    }

    private func setUpHelperLabel() {
        helperLabel.font = Constant.Fonts.system(size: .desc, weight: .medium)
        helperLabel.textColor = .white
        helperLabel.text = L10n.LNURLScanQRViewController.helper
    }

    private func setUpSendToAddressView() {
        sendToAddressView.backgroundColor = Asset.Colors.cellBackground.color
        sendToAddressLabel.textColor = Asset.Colors.muunBlue.color
        sendToAddressLabel.font = Constant.Fonts.system(size: .opTitle, weight: .semibold)
        sendToAddressLabel.text = L10n.LNURLScanQRViewController.useClipboard

        addressLabel.style = .description

        sendToAddressView.isHidden = true
        sendToAddressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .useLinkInClipboardTouched))

        sendToAddressViewSeparator.backgroundColor = Asset.Colors.separator.color
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.LNURLScanQRViewController.title
    }

    fileprivate func makeNavigationInvisible() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = textAttributes
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.hideSeparator()
        navigationController!.navigationBar.isTranslucent = true
        navigationController!.navigationBar.tintColor = .white
    }

    fileprivate func makeNavigationVisible() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: Asset.Colors.title.color]
        navigationController!.navigationBar.titleTextAttributes = textAttributes
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.tintColor = Asset.Colors.muunGrayDark.color
        navigationController!.showSeparator()
    }

    internal func showPermissionsView() {
        helperLabel.isHidden = true
        permissionsView.backgroundColor = Asset.Colors.background.color
        permissionsView.isHidden = false
        permissionsView.delegate = self
        permissionsView.titleText = L10n.ScanQRViewController.s4
        permissionsView.contentText = L10n.ScanQRViewController.s5
        permissionsView.addTo(self.view)

        makeNavigationVisible()

        // At this point permissionView is at the top of the view herarchy, therefore the buttons arent reachables.
        // Thats why we need to bring them to the front of the view.
        view.bringSubviewToFront(enterManuallyButtonView)
        view.bringSubviewToFront(sendToAddressView)
    }

    internal func hidePermissionView() {
        helperLabel.isHidden = false
        makeNavigationInvisible()

        permissionsView.isHidden = true

        setUpCameraView()
        continueCapture()
    }

    fileprivate func updateOverlayPath() {
        let squareMargin: CGFloat = 56.0
        let squareSide = overlayView.bounds.width - (squareMargin * 2)

        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        let transparentPath = UIBezierPath(rect: CGRect(x: overlayView.bounds.midX - (squareSide / 2),
                                                        y: overlayView.bounds.midY - (squareSide / 2),
                                                        width: squareSide,
                                                        height: squareSide))
        overlayPath.append(transparentPath)
        overlayPath.usesEvenOddFillRule = true

        overlayFillLayer.path = overlayPath.cgPath
    }

    internal func setUpOverlayView() {
        overlayView.backgroundColor = .clear

        updateOverlayPath()
        overlayFillLayer.fillRule = .evenOdd
        overlayFillLayer.fillColor = UIColor.black.withAlphaComponent(0.64).cgColor

        overlayView.layer.addSublayer(overlayFillLayer)
    }

    internal func pushToManuallyEnterQR(removeFromStack: Bool = false) {
        pauseCapture()

        navigationController!.pushViewController(LNURLManuallyEnterQRViewController(),
                                                 animated: true,
                                                 removeFromStack: removeFromStack)
    }

    internal func pushToWithdraw(_ link: String, origin: Constant.NewOpAnalytics.Origin) {
        pauseCapture()

        navigationController!.pushViewController(
            LNURLWithdrawViewController(qr: link),
            animated: true
        )
    }

    @objc func useLinkInClipboardTouched() {
        pushToWithdraw(addressLabel.text!, origin: .clipboard)
    }

    override func viewDidLayoutSubviews() {
        updateOverlayPath()
        videoLayer?.frame = cameraView.bounds
    }

}

extension LNURLScanQRViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        pushToManuallyEnterQR()
    }

}

extension LNURLScanQRViewController: LNURLScanQRPresenterDelegate {
    func checkForClipboardChange() {
        checkClipboard()
    }
}

extension LNURLScanQRViewController: ErrorViewDelegate {

    func logErrorView(_ name: String, params: [String: Any]?) {
        logScreen(name, parameters: params)
    }

    func backToHomeTouched() {
        navigationController!.popToRootViewController(animated: true)
    }
}

fileprivate extension Selector {
    static let useLinkInClipboardTouched = #selector(LNURLScanQRViewController.useLinkInClipboardTouched)
}

extension LNURLScanQRViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.LNURLScanQRPage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(enterManuallyButtonView, using: .enterManually)
        makeViewTestable(permissionsView, using: .cameraPermissionView)
    }
}
