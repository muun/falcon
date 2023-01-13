//
//  DetailViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 29/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class DetailViewController: MUViewController {

    @IBOutlet fileprivate weak var summaryLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet fileprivate weak var clockImageView: UIImageView!

    fileprivate lazy var presenter = instancePresenter(DetailPresenter.init, delegate: self)

    let operation: core.Operation
    let formatter: OperationFormatter

    private let refundMessage = L10n.DetailViewController.s1

    init(operation: core.Operation) {
        self.operation = operation
        self.formatter = OperationFormatter(operation: operation)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func customLoggingParameters() -> [String: Any]? {
        return [
            "operation_id": operation.id ?? 0,
            "direction": operation.direction.rawValue.lowercased()
        ]
    }

    override var screenLoggingName: String {
        return "operation_detail"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let outgoingSwap = operation.submarineSwap {
            setUp(swap: outgoingSwap)
        } else if let incomingSwap = operation.incomingSwap {
            setUp(incomingSwap: incomingSwap)
        } else {
            setUpOnchain()
        }

        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = L10n.DetailViewController.s2
        presenter.setUp()
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    private func setUp(swap: SubmarineSwap) {
        addSummary()
        addStatus()

        if formatter.simpleStatus != .COMPLETED {
            stackView.setCustomSpacing(8, after: statusLabel)
            addSwapStatus(swap: swap)
        }

        addDescription()
        addWhen()
        addAmount()

        addLightningFee(swap: swap)

        addSeparator()

        add(invoice: swap._invoice)

        if let preimage = swap._preimageInHex {
            add(preimage: preimage)
        }

        add(receiver: swap._receiver)
    }

    private func setUp(incomingSwap: IncomingSwap) {
        addSummary()
        addStatus()
        addDescription()
        addWhen()
        addAmount()

        addSeparator()

        add(paymentHash: incomingSwap.paymentHash.toHexString())

        if let preimage = incomingSwap.preimage {
            add(preimage: preimage.toHexString())
        }
    }

    private func setUpOnchain() {
        addSummary()
        addStatus()
        addDescription()
        addWhen()
        addAmount()
        addNetworkFee()
        addSeparator()
        addConfirmations()
        addRelevantAddress()
        addTxHash(title: L10n.DetailViewController.s3)
    }

    fileprivate func addSummary() {
        let amount = operation.amount.inInputCurrency.toAmountPlusCode()

        let summary = """
        \(formatter.title)
        \(amount)
        """
        summaryLabel.textColor = Asset.Colors.title.color
        summaryLabel.attributedText = summary
            .set(font: summaryLabel.font, lineSpacing: 4, alignment: .center)
            .set(tint: formatter.title, color: Asset.Colors.muunGrayDark.color)
            .set(bold: amount, color: summaryLabel.textColor)
    }

    fileprivate func addStatus() {
        statusLabel.textColor = formatter.color
        statusLabel.font = Constant.Fonts.system(size: .desc, weight: .bold)
        statusLabel.text = formatter.status

        clockImageView.isHidden = !operation.isPending()
        clockImageView.tintColor = formatter.color

        // Only display the cancelable notice for incoming rbf transactions
        if operation.isCancelable() && operation.direction == .INCOMING {
            let noticeView = NoticeView(frame: .zero)
            noticeView.style = .warning
            noticeView.text = L10n.DetailViewController.rbfNotice
                .set(font: Constant.Fonts.system(size: .opHelper),
                     lineSpacing: Constant.FontAttributes.lineSpacing,
                     kerning: Constant.FontAttributes.kerning,
                     alignment: .left)
                .set(underline: L10n.DetailViewController.rbfCta, color: Asset.Colors.muunBlue.color)
            noticeView.delegate = self
            stackView.addArrangedSubview(noticeView)
        }
    }

    fileprivate func addDescription() {
        if let description = formatter.description {
            stackView.addArrangedSubview(MUDetailRowView(title: L10n.DetailViewController.s4, content: description))
        }
    }

    fileprivate func addWhen() {
        stackView.addArrangedSubview(
            MUDetailRowView(title: L10n.DetailViewController.s5, content: formatter.extendedCreationDate)
        )
    }

    fileprivate func addAmount() {
        stackView.addArrangedSubview(
            MUDetailRowView.copyableAmount(operation.amount, title: L10n.DetailViewController.s6, controller: self)
        )
    }

    fileprivate func addConfirmations() {
        if formatter.simpleStatus != .FAILED {
            stackView.addArrangedSubview(MUDetailRowView(title: L10n.DetailViewController.s7,
                                                       content: formatter.confirmations))
        }
    }

    fileprivate func addNetworkFee() {
        if operation.direction != .INCOMING {
            stackView.addArrangedSubview(MUDetailRowView.copyableAmount(
                operation.fee,
                title: L10n.DetailViewController.outgoingTxFee,
                controller: self
            ))
        }
    }

    fileprivate func addRelevantAddress() {
        if let receiverAddress = operation.receiverAddress {
            let url = "\(Environment.current.addressExplorer)\(receiverAddress)"

            let openExplorer = {
                let params = ["name": "block_explorer", "url": url]
                self.logEvent("open_web", parameters: params)
                UIApplication.shared.open(URL(string: url)!,
                                          options: [:],
                                          completionHandler: nil)
            }

            let onIconTap = {
                UIPasteboard.general.string = receiverAddress
                self.showToast(message: L10n.MUDetailRowView.s1)
            }

            var message = ""
            switch operation.direction {
            case .OUTGOING:
                message = L10n.DetailViewController.s9
            case .INCOMING, .CYCLICAL:
                message = L10n.DetailViewController.s10
            }

            stackView.addArrangedSubview(MUDetailRowView(
                title: NSAttributedString(string: message),
                content: receiverAddress.attributedForDescription(),
                tapIcon: Asset.Assets.copy.image,
                onTap: openExplorer,
                onIconTap: onIconTap,
                contentColor: Asset.Colors.muunBlue.color
            ))
        }
    }

    fileprivate func addTxHash(title: String) {
        if let hash = operation.transaction?.hash {
            let url = "\(Environment.current.txExplorer)\(hash)"

            let shareUrl = {
                let activityViewController = UIActivityViewController(activityItems: [url as NSString],
                                                                      applicationActivities: nil)

                self.present(activityViewController, animated: true, completion: {})
            }

            let openExplorer = {
                let params = ["name": "block_explorer", "url": url]
                self.logEvent("open_web", parameters: params)
                UIApplication.shared.open(URL(string: url)!,
                                          options: [:],
                                          completionHandler: nil)
            }

            let longPress = {
                UIPasteboard.general.string = url

                self.showToast(message: L10n.DetailViewController.s11)
            }

            stackView.addArrangedSubview(MUDetailRowView(
                title: NSAttributedString(string: title),
                content: hash.attributedForDescription(),
                tapIcon: Asset.Assets.share.image,
                onTap: openExplorer,
                onLongPress: longPress,
                onIconTap: shareUrl,
                contentColor: Asset.Colors.muunBlue.color)
            )

        }
    }

    fileprivate func addLightningFee(swap: SubmarineSwap) {

        // If the swap was rejected by swapper after submiting, it won't have a fee
        if let fee = swap.getLightningFeeInSats(onChainFee: operation.fee)?
            .toBitcoinAmount(reference: operation.amount) {
            stackView.addArrangedSubview(
                MUDetailRowView.copyableAmount(fee, title: L10n.DetailViewController.s8, controller: self)
            )
        }

    }

    fileprivate func add(invoice: String) {
        stackView.addArrangedSubview(
            MUDetailRowView.clipboard(invoice, title: L10n.DetailViewController.s13, controller: self)
        )
    }

    fileprivate func add(receiver: SubmarineSwapReceiver) {
        guard let pubKey = receiver._publicKey else {
            return
        }

        let name: String
        if let alias = receiver._alias {
            name = alias
        } else {
            name = pubKey
        }

        let rowView = MUDetailRowView.clipboard(name,
                                              title: L10n.DetailViewController.s14,
                                              valueToBeCopied: pubKey,
                                              controller: self)

        stackView.addArrangedSubview(rowView)
    }

    fileprivate func add(paymentHash: String) {
        stackView.addArrangedSubview(MUDetailRowView.clipboard(paymentHash,
                                                             title: L10n.DetailViewController.paymentHash,
                                                             controller: self))
    }

    fileprivate func add(preimage: String) {
        stackView.addArrangedSubview(MUDetailRowView.clipboard(preimage,
                                                             title: L10n.DetailViewController.preimage,
                                                             controller: self))
    }

    fileprivate func addSwapStatus(swap: SubmarineSwap) {
        var content: String

        switch operation.status {
        case .SWAP_FAILED:
            content = messageForSwapFailed(swap: swap)

        case .SWAP_EXPIRED:
            content = refundMessage

        case .SWAP_ROUTING:
            content = L10n.DetailViewController.s16

        case .SWAP_PENDING, .CREATED, .BROADCASTED, .SIGNED:
            if swap._fundingOutput.confirmationsNeeded() > 0 {
                let onTap = {
                    let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.confsNeeded)
                    self.present(overlayVc, animated: true)
                }

                let text = L10n.DetailViewController.s19
                stackView.addArrangedSubview(MUDetailRowView.text(text,
                                                                link: L10n.DetailViewController.s20,
                                                                onTap: onTap))
                return
            }
            content = L10n.DetailViewController.s16

        case .SWAP_PAYED, .CONFIRMED, .FAILED, .SETTLED, .SIGNING, .DROPPED, .SWAP_OPENING_CHANNEL,
             .SWAP_WAITING_CHANNEL:
            return
        }

        stackView.addArrangedSubview(MUDetailRowView.text(content))
    }

    fileprivate func messageForSwapFailed(swap: SubmarineSwap) -> String {
        var content: String
        if swap._fundingOutput.scriptVersion() == presenter.getSubmarineSwapV1Version() {
            if let blocksUntilRefund = presenter.blocksUntilRefund(ss: swap) {
                let refundText = presenter.calculateTimeForRefund(blocksLeft: blocksUntilRefund)
                content = L10n.DetailViewController.s22(refundText.time, refundText.blocks)
            } else {
                // This means the user already got her refund
                content = refundMessage
            }
        } else {
            // For swaps v2 display refund message
            content = refundMessage
        }

        return content
    }

    fileprivate func addSeparator() {
        let hairline = UIView()
        stackView.addArrangedSubview(hairline)
        stackView.setCustomSpacing(20, after: hairline)

        hairline.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        hairline.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        hairline.backgroundColor = Asset.Colors.muunGrayLight.color
    }

}

extension DetailViewController: NoticeViewDelegate {
    func didTapOnMessage() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.rbf)
        self.present(overlayVc, animated: true)
    }
}

extension DetailViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.DetailPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
    }
}

extension DetailViewController: DetailPresenterDelegate {}
