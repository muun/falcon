//
//  QRCodeView.swift
//  falcon
//
//  Created by Federico Bond on 08/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol QRCodeViewDelegate: AnyObject {
    func didTapQRCode()
}

class QRCodeView: UIImageView {

    weak var delegate: QRCodeViewDelegate?

    var data: Data? {
        didSet {
            // Needs to happen async because the view must layout itself first
            // (so that frame.size has a valid value)
            DispatchQueue.main.async {
                self.generate()
            }
        }
    }

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTap))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        generate()
    }

    private func generate() {
        guard let data = data else {
            return
        }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            fatalError("The QR code filter is not available")
        }

        filter.setValue(data, forKey: "inputMessage")
        // We need a low InputCorrectionLevel because the raw invoice is too long and the QR becomes too dense otherwise
        // "L" is the lowest one
        filter.setValue("L", forKey: "inputCorrectionLevel")

        guard var coreImage = filter.outputImage else {
            fatalError("Failed to generate an image for the QR code")
        }

        if !isDarkMode() {
            let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            let bounds = coreImage.extent
            let newBounds = bounds.inset(by: insets)
            coreImage = coreImage.cropped(to: newBounds)
        }

        // This transforms keeps the QR from blurring
        let scaleX = frame.size.width / coreImage.extent.size.width
        let scaleY = frame.size.height / coreImage.extent.size.height

        let scaledImage = coreImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // To avoid blurring in the borders after cropping and scaling the image,
        // we generate a new CGImage from the CIImage.
        let cgImage = CIContext().createCGImage(
            scaledImage.clampedToExtent(),
            from: scaledImage.extent
        )

        image = UIImage(cgImage: cgImage!)
    }

    fileprivate func isDarkMode() -> Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }

        return false
    }

    @objc fileprivate func didTap() {
        delegate?.didTapQRCode()
    }
}

fileprivate extension Selector {
    static let didTap = #selector(QRCodeView.didTap)
}
