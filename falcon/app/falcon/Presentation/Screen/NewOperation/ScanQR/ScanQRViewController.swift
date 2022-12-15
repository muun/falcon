//
//  ScanQRViewController.swift
//  falcon
//
//  Created by Manu Herrera on 20/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import AVKit
import core

class ScanQRViewController: MUViewController {

    @IBOutlet fileprivate weak var enterManuallyButtonView: ButtonView!
    @IBOutlet internal weak var cameraView: UIView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var helperLabel: UILabel!

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

    internal lazy var presenter = instancePresenter(AddressInputPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "scan_qr"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        presenter.setUp()

        setUpView()
        makeViewTestable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        pauseCapture()

        presenter.tearDown()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        blurEffectView.alpha = 0
    }

    private func setUpView() {
        decideFirstView()
        setUpButtons()

        setUpHelperLabel()
    }

    private func setUpButtons() {
        enterManuallyButtonView.style = .secondary
        enterManuallyButtonView.delegate = self
        enterManuallyButtonView.buttonText = L10n.ScanQRViewController.s1
        enterManuallyButtonView.isEnabled = true
    }

    private func setUpHelperLabel() {
        helperLabel.font = Constant.Fonts.system(size: .desc, weight: .medium)
        helperLabel.textColor = .white
        helperLabel.text = L10n.ScanQRViewController.s6
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.ScanQRViewController.s3
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

        navigationController!.pushViewController(ManuallyEnterQRViewController(),
                                                 animated: true,
                                                 removeFromStack: removeFromStack)
    }

    internal func pushToNewOp(_ address: String, origin: Constant.NewOpAnalytics.Origin) {
        pauseCapture()

        do {
            let paymentIntent = try presenter.getPaymentIntent(for: address)
            navigationController!.pushViewController(
                NewOperationViewController(
                    paymentIntent: paymentIntent,
                    origin: origin
                ),
                animated: true
            )
        } catch {
            Logger.log(.err, "Could not get payment uri from address: \(address)")
        }
    }

    override func viewDidLayoutSubviews() {
        updateOverlayPath()
        videoLayer?.frame = cameraView.bounds
    }

}

extension ScanQRViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        pushToManuallyEnterQR()
    }

}

extension ScanQRViewController: AddressInputPresenterDelegate {
    func checkForClipboardChange() {}
}

extension ScanQRViewController: ErrorViewDelegate {

    func logErrorView(_ name: String, params: [String: Any]?) {
        logScreen(name, parameters: params)
    }

    func secondaryButtonTouched() {
        navigationController!.popToRootViewController(animated: true)
    }
}

extension ScanQRViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.ScanQRPage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(enterManuallyButtonView, using: .enterManually)
        makeViewTestable(permissionsView, using: .cameraPermissionView)
    }
}
