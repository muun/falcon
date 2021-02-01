//
//  ReceiveInLightningView.swift
//  falcon
//
//  Created by Manu Herrera on 05/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ReceiveDelegate: class {
    func didTapOnShare(_ shareText: String)
    func didTapOnCopy(_ copyText: String)
}

protocol ReceiveInLightningViewDelegate: ReceiveDelegate {
    func didTapOnCompatibilityAddressInfo()
    func didTapOnInvoice(_ invoice: String)
    func didTapOnRequestNewInvoice()
}

struct IncomingInvoiceInfo {
    // The raw string representation of the invoice
    let rawInvoice: String

    // This is the expiration date of the invoice represented in unix time
    // Optional for future compatibility with invoices without expiration date
    let expiresAt: Double?
}

final class ReceiveInLightningView: UIView {

    private let cardStackView = UIStackView()
    private let cardView = UIView()
    private let expirationTimeLabel = UILabel()
    private let expirationTimeCreateNewInvoiceLabel = UILabel()
    private let qrImageView = UIImageView()
    private let invoiceLabel = UILabel()
    private let shareButton = LightButtonView()
    private let copyButton = LightButtonView()
    private let overlayView = UIView()
    private let loadingView = LoadingView()

    private var invoiceInfo: IncomingInvoiceInfo?
    private var timer = Timer()

    private let expirationText = L10n.ReceiveInLightningView.s1("")
    // We display a expiration warning message when the invoice has only 3 minutes remaining of expiration time
    private let expirationMessageThresholdInSecs = 180

    private weak var delegate: ReceiveInLightningViewDelegate?

    init(delegate: ReceiveInLightningViewDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpCardView()
        setUpOverlayView()

        makeViewTestable()
    }

    // MARK: - Views Layout and configutation -

    fileprivate func setUpCardView() {
        cardView.backgroundColor = Asset.Colors.cellBackground.color
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.roundCorners(cornerRadius: 16, clipsToBounds: false)
        setUpShadow(in: cardView)
        addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardStackView.spacing = 16
        cardStackView.alignment = .center
        cardStackView.axis = .vertical
        cardView.addSubview(cardStackView)

        NSLayoutConstraint.activate([
            cardStackView.heightAnchor.constraint(equalTo: cardView.heightAnchor),
            cardStackView.widthAnchor.constraint(equalTo: cardView.widthAnchor),
            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])

        cardStackView.isLayoutMarginsRelativeArrangement = true
        cardStackView.layoutMargins = UIEdgeInsets(top: .sideMargin, left: 0, bottom: .sideMargin, right: 0)

        setUpExpiryLabels()
        setUpQR()
        setUpShareAndCopyButtons()
        setUpLoadingView()
    }

    fileprivate func setUpShadow(in cardShadowView: UIView) {
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            return
        }

        // We only want the shadow if we are not on dark mode
        cardShadowView.setUpShadow(
            color: Asset.Colors.muunGrayDark.color,
            opacity: 0.25,
            offset: CGSize(width: 0, height: 4),
            radius: 8
        )
    }

    fileprivate func setUpExpiryLabels() {
        expirationTimeLabel.style = .description
        expirationTimeLabel.text = expirationText
        expirationTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationTimeLabel.numberOfLines = 0
        expirationTimeLabel.isHidden = true
        cardStackView.addArrangedSubview(expirationTimeLabel)
        cardStackView.setCustomSpacing(0, after: expirationTimeLabel)

        expirationTimeCreateNewInvoiceLabel.style = .description
        let createAnotherText = L10n.ReceiveInLightningView.s2
        expirationTimeCreateNewInvoiceLabel.attributedText = createAnotherText
            .attributedForDescription(alignment: .center)
            .set(underline: createAnotherText, color: Asset.Colors.muunBlue.color)
        expirationTimeCreateNewInvoiceLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationTimeCreateNewInvoiceLabel.numberOfLines = 0
        expirationTimeCreateNewInvoiceLabel.isHidden = true
        cardStackView.addArrangedSubview(expirationTimeCreateNewInvoiceLabel)

        expirationTimeCreateNewInvoiceLabel.isUserInteractionEnabled = true
        expirationTimeCreateNewInvoiceLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: .createAnotherInvoice)
        )
    }

    private func setExpirationLabelsHidden(_ isHidden: Bool) {
        expirationTimeLabel.isHidden = isHidden
        expirationTimeCreateNewInvoiceLabel.isHidden = isHidden
    }

    fileprivate func setUpQR() {
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.isUserInteractionEnabled = true
        qrImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .qrTouch))

        cardStackView.addArrangedSubview(qrImageView)

        NSLayoutConstraint.activate([
            qrImageView.widthAnchor.constraint(equalTo: cardStackView.widthAnchor, constant: -.sideMargin * 2),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])

        cardStackView.setCustomSpacing(8, after: qrImageView)

        let invoiceStackView = UIStackView()
        invoiceStackView.translatesAutoresizingMaskIntoConstraints = false
        invoiceStackView.spacing = 8
        invoiceStackView.distribution = .equalSpacing
        invoiceStackView.isUserInteractionEnabled = true
        invoiceStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .invoiceTouch))

        invoiceLabel.translatesAutoresizingMaskIntoConstraints = false
        invoiceLabel.textColor = Asset.Colors.muunGrayDark.color
        invoiceLabel.font = Constant.Fonts.system(size: .notice)
        invoiceLabel.numberOfLines = 1
        invoiceLabel.lineBreakMode = .byTruncatingMiddle
        cardStackView.addArrangedSubview(invoiceStackView)
        invoiceStackView.addArrangedSubview(invoiceLabel)

        let checkInvoiceImage = UIImageView()
        checkInvoiceImage.translatesAutoresizingMaskIntoConstraints = false
        checkInvoiceImage.image = Asset.Assets.passwordShow.image
        invoiceStackView.addArrangedSubview(checkInvoiceImage)

        NSLayoutConstraint.activate([
            checkInvoiceImage.heightAnchor.constraint(equalToConstant: 16),
            checkInvoiceImage.widthAnchor.constraint(equalToConstant: 16),
            checkInvoiceImage.centerYAnchor.constraint(equalTo: invoiceLabel.centerYAnchor),
            invoiceStackView.widthAnchor.constraint(
                lessThanOrEqualTo: cardStackView.widthAnchor,
                constant: -.sideMargin * 2
            )
        ])
    }

    fileprivate func setUpShareAndCopyButtons() {
        let buttonsContainerView = UIStackView()
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.spacing = 32
        cardStackView.addArrangedSubview(buttonsContainerView)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.delegate = self
        shareButton.buttonText = L10n.ReceiveInLightningView.s3
        buttonsContainerView.addArrangedSubview(shareButton)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.delegate = self
        copyButton.buttonText = L10n.ReceiveInLightningView.s4
        buttonsContainerView.addArrangedSubview(copyButton)

        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 60),
            copyButton.widthAnchor.constraint(equalToConstant: 60),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    fileprivate func setUpLoadingView() {
        loadingView.isHidden = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.titleText = L10n.ReceiveInLightningView.s7
        loadingView.backgroundColor = Asset.Colors.cellBackground.color
        loadingView.roundCorners(cornerRadius: 16)
        cardView.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: cardView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            loadingView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor)
        ])
    }

    private func setUpOverlayView() {
        overlayView.backgroundColor = Asset.Colors.muunBluePale.color.withAlphaComponent(0.98)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true
        overlayView.roundCorners(cornerRadius: 16)

        cardView.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: cardView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        let overlayStackView = UIStackView()
        overlayStackView.translatesAutoresizingMaskIntoConstraints = false
        overlayStackView.spacing = 16
        overlayStackView.alignment = .center
        overlayStackView.axis = .vertical
        overlayView.addSubview(overlayStackView)

        NSLayoutConstraint.activate([
            overlayStackView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: .sideMargin),
            overlayStackView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -.sideMargin),
            overlayStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let expiredLabel = UILabel()
        expiredLabel.style = .description
        expiredLabel.attributedText = L10n.ReceiveInLightningView.s5
            .attributedForDescription(alignment: .center)
        expiredLabel.translatesAutoresizingMaskIntoConstraints = false
        expiredLabel.numberOfLines = 0
        overlayStackView.addArrangedSubview(expiredLabel)
        NSLayoutConstraint.activate([
            expiredLabel.leadingAnchor.constraint(equalTo: overlayStackView.leadingAnchor),
            expiredLabel.trailingAnchor.constraint(equalTo: overlayStackView.trailingAnchor)
        ])

        let createAnotherInvoiceButton = SmallButtonView()
        createAnotherInvoiceButton.isEnabled = true
        createAnotherInvoiceButton.buttonText = L10n.ReceiveInLightningView.s6
        createAnotherInvoiceButton.delegate = self
        createAnotherInvoiceButton.backgroundColor = .clear
        overlayStackView.addArrangedSubview(createAnotherInvoiceButton)

        NSLayoutConstraint.activate([
            createAnotherInvoiceButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func displayInvoiceExpiredView() {
        overlayView.isHidden = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: .updateTimer,
            userInfo: nil,
            repeats: true
        )
    }

    // MARK: - View actions -

    @objc fileprivate func createAnotherTouch() {
        delegate?.didTapOnRequestNewInvoice()
    }

    @objc fileprivate func qrTouch() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnCopy(invoiceInfo.rawInvoice)
    }

    @objc fileprivate func invoiceTouch() {
        guard let invoiceInfo = invoiceInfo else { return }
        delegate?.didTapOnInvoice(invoiceInfo.rawInvoice)
    }

    @objc fileprivate func updateTimer() {
        guard let expiresAt = invoiceInfo?.expiresAt else { return }
        let expirationTimeRemainingInSecs = getInvoiceExpirationTimeInSecs(unixExpiration: expiresAt)

        if expirationTimeRemainingInSecs <= 0 {
            displayInvoiceExpiredView()
            timer.invalidate()
            return
        }

        if expirationTimeRemainingInSecs < expirationMessageThresholdInSecs {
            setExpirationLabelsHidden(false)
            updateExpireLabel(secsRemaining: expirationTimeRemainingInSecs)
        } else {
            setExpirationLabelsHidden(true)
        }
    }

    private func updateExpireLabel(secsRemaining: Int) {
        let timeString = formatTimeRemaining(secsRemaining)
        expirationTimeLabel.text = L10n.ReceiveInLightningView.s1(timeString)
    }

    private func formatTimeRemaining(_ seconds: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"

        let timeInterval = Double(seconds)
        let timeRemaining = Date(timeIntervalSince1970: timeInterval)

        return formatter.string(from: timeRemaining)
    }

    private func getInvoiceExpirationTimeInSecs(unixExpiration: Double) -> Int {
        let secsRemaining = unixExpiration - Date().timeIntervalSince1970
        return Int(secsRemaining)
    }

    // MARK: - View Controller actions -

    func displayInvoice(_ invoiceInfo: IncomingInvoiceInfo?) {
        guard let invoiceInfo = invoiceInfo else {
            loadingView.isHidden = false
            return
        }

        // Reset the view to initial state when displaying a new invoice
        overlayView.isHidden = true
        setExpirationLabelsHidden(true)
        loadingView.isHidden = true
        timer.invalidate()

        self.invoiceInfo = invoiceInfo
        // Restart the timer, it will take care of handling the expiration time of the invoice
        startTimer()

        qrImageView.image = generateQR(invoice: invoiceInfo.rawInvoice)
        invoiceLabel.text = invoiceInfo.rawInvoice
    }

    private func generateQR(invoice: String) -> UIImage {
        // Why uppercased? Because uppercased enables alphanumeric mode for the QR, making it less dense
        let stringData = invoice.uppercased().data(using: .utf8)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            fatalError("The QR code filter is not available")
        }

        filter.setValue(stringData, forKey: "inputMessage")
        // We need a low InputCorrectionLevel because the raw invoice is too long and the QR becomes too dense otherwise
        // "L" is the lowest one
        filter.setValue("L", forKey: "inputCorrectionLevel")

        guard let coreImage = filter.outputImage else {
            fatalError("Failed to generate an image for the QR code")
        }

        // This transforms keeps the QR from blurring
        let scaleX = qrImageView.frame.size.width / coreImage.extent.size.width
        let scaleY = qrImageView.frame.size.height / coreImage.extent.size.height

        let scaledImage = coreImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        return UIImage(ciImage: scaledImage)
    }
}

extension ReceiveInLightningView: LightButtonViewDelegate {
    internal func lightButton(didPress lightButton: LightButtonView) {
        guard let invoiceInfo = invoiceInfo else { return }

        if lightButton == copyButton {
            delegate?.didTapOnCopy(invoiceInfo.rawInvoice)
        } else {
            delegate?.didTapOnShare(invoiceInfo.rawInvoice)
        }
    }
}

extension ReceiveInLightningView: SmallButtonViewDelegate {

    internal func button(didPress button: SmallButtonView) {
        delegate?.didTapOnRequestNewInvoice()
    }

}

extension ReceiveInLightningView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    private func makeViewTestable() {
        makeViewTestable(invoiceLabel, using: .invoice)
    }
}

fileprivate extension Selector {
    static let createAnotherInvoice = #selector(ReceiveInLightningView.createAnotherTouch)
    static let qrTouch = #selector(ReceiveInLightningView.qrTouch)
    static let invoiceTouch = #selector(ReceiveInLightningView.invoiceTouch)
    static let updateTimer = #selector(ReceiveInLightningView.updateTimer)
}
