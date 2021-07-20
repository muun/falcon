//
//  ScanQRViewController+Camera.swift
//  falcon
//
//  Created by Manu Herrera on 14/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import AVKit
import core

extension ScanQRViewController {

    internal func cameraAuthorizationStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: cameraMediaType)
    }

    internal func continueCapture() {
        switch status {
        case .blank, .scanning:
            break
        case .paused:
            captureSession.startRunning()
            status = .scanning
        case .disabled:
            pushToManuallyEnterQR(removeFromStack: true)
        }
    }

    internal func pauseCapture() {
        switch status {
        case .blank, .paused, .disabled:
            break
        case .scanning:
            captureSession.stopRunning()
            status = .paused
        }
    }

    internal func decideFirstView() {
        switch cameraAuthorizationStatus() {
        case .notDetermined, .denied:
            showPermissionsView()
        case .authorized, .restricted:
            hidePermissionView()
        @unknown default:
            Logger.log(.err, "Got unknown camera autorization status \(cameraAuthorizationStatus())")
            showPermissionsView()
        }
    }

    internal func setUpCameraView() {
        if status != .blank {
            return
        }

        // We don't start scanning in this function yet
        status = .paused
        setUpOverlayView()

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            Logger.log(.err, "Failed to get the camera device")

            // This method gets called to early in the lifecycle of this VC
            // So we mark ourselves as disabled and this will cause the VC to be replaced later on.
            status = .disabled
            return
        }

        do {

            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoLayer.frame = cameraView.bounds
            cameraView.layer.addSublayer(videoLayer)

            self.videoLayer = videoLayer

        } catch {
            Logger.log(.err, "Some error with the camera")

            pushToManuallyEnterQR(removeFromStack: true)
            return
        }

    }
}

extension ScanQRViewController: CameraPermissionViewDelegate {

    func userDidRequestPermission() {
        switch cameraAuthorizationStatus() {

        case .notDetermined:
            // Prompting user for the permission to use the camera.
            logEvent("\(screenLoggingName)_ask_camera_permission")
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    self.logEvent("\(self.screenLoggingName)_camera_permission_granted")
                    DispatchQueue.main.async {
                        self.hidePermissionView()
                    }
                }
            }

        case .denied:
            // In case that the user has previusly denied permissions, it's impossible to request access again.
            // So we take her to the iOS Settings of muun
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)

        // The user will never see the button in these states
        case .authorized, .restricted:
            break
        }
    }

}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {

    fileprivate func showInvalidAddressView(_ address: String) {
        let view = ErrorView()

        view.delegate = self
        view.model = NewOpError.invalidAddress(address)

        view.addTo(self.view)
        self.view.gestureRecognizers?.removeAll()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if status != .scanning {
            return
        }

        if metadataObjects.count == 0 {
            return
        }

        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
            metadataObj.type == AVMetadataObject.ObjectType.qr,
            let address = metadataObj.stringValue {

            pauseCapture()
            blurScreen()

            if presenter.isValid(lnurl: address) {
                navigationController!.pushViewController(
                    LNURLFromSendViewController(qr: address),
                    animated: true
                )
            } else if presenter.isValid(rawAddress: address) {
                pushToNewOp(address, origin: .qr)
            } else {
                showInvalidAddressView(address)
            }

        }
    }

    private func blurScreen() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds

        view.addSubview(blurEffectView)

        blurEffectView.alpha = 0
        UIView.animate(withDuration: 0.125) {
            self.blurEffectView.alpha = 1
        }
    }
}
