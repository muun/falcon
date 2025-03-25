//
//  DetailedUnifiedURIView.swift
//  Muun
//
//  Created by Lucas Serruya on 21/12/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit

class DetailedUnifiedURIView: MUBottomSheetViewContainer {
    private let bitcoinURIViewModel: BitcoinURIViewModel
    var toast: ToastView?
    var detailedURILabel = UILabel()

    init(bitcoinURIViewModel: BitcoinURIViewModel,
         screenNameForLogs: String) {
        self.bitcoinURIViewModel = bitcoinURIViewModel
        super.init(screenNameForLogs: screenNameForLogs)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setUpView() {
        super.setUpView()
        addDetailedURIDisclaimer()
        addSpacer()
        let btcTitle = formattedAsTitle(title: L10n.ReceiveViewController.detailedURIBTCTitle)
        dialogView.addArrangedSubview(multilineLabel(string: btcTitle))

        let btcAddressLabel = copyableItem(string: bitcoinURIViewModel.address.attributedForDescription(),
                                           valueToBeCopied: bitcoinURIViewModel.addressWithAmount)
        dialogView.addArrangedSubview(btcAddressLabel)
        addSpacer()
        let lnTitle = formattedAsTitle(title: L10n.ReceiveViewController.detailedURIBTCTitle)
        dialogView.addArrangedSubview(multilineLabel(string: lnTitle))

        let lnLabel = copyableItem(string: bitcoinURIViewModel.invoice.rawInvoice.attributedForDescription())

        dialogView.addArrangedSubview(lnLabel)
    }
}

extension DetailedUnifiedURIView: DisplayableToast {
    @objc func dismissToast() {
        toast?.animateOut()
    }
}

private extension DetailedUnifiedURIView {
    func addDetailedURIDisclaimer() {
        let detailedURI = L10n.ReceiveViewController.detailedURIDisclaimer
            .attributedForDescription(paragraphLineBreakMode: .byClipping)
            .set(tint: L10n.ReceiveViewController.detailedURIDisclaimer,
                 color: Asset.Colors.muunGrayDark.color)
            .set(tint: L10n.ReceiveFormatSettingDropdownView.learnMoreUnderline,
                 color: Asset.Colors.muunBlue.color)
        detailedURILabel = multilineLabel(string: detailedURI)
        detailedURILabel.isUserInteractionEnabled = true
        detailedURILabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLearnMore))
        )
        dialogView.addArrangedSubview(detailedURILabel)
    }

    func addSpacer() {
        let spacer = UIView()
        let heightConstraint = NSLayoutConstraint(item: spacer,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: spacer,
                                                  attribute: .height,
                                                  multiplier: 1,
                                                  constant: 0)
        spacer.addConstraint(heightConstraint)
        dialogView.addArrangedSubview(spacer)
    }

    @objc
    func didTapLearnMore(_ gesture: UITapGestureRecognizer) {
        guard let labelText = detailedURILabel.text else {
            return
        }

        if gesture.hasUserTapped(text: L10n.ReceiveFormatSettingDropdownView.learnMoreUnderline,
                                 in: detailedURILabel,
                                 labelText: labelText) {
            UIApplication.shared.open(
                URL(string: L10n.ReceiveFormatSettingDropdownView.learnMoreLink)!, options: [:]
            )
        }
    }

    func formattedAsTitle(title: String) -> NSAttributedString {
        let attributedTitle = title.set(font: Constant.Fonts.system(size: .desc,
                                                                    weight: .semibold),
                                        lineSpacing: Constant.FontAttributes.lineSpacing,
                                        kerning: Constant.FontAttributes.kerning)

        return attributedTitle.set(tint: title, color: Asset.Colors.title.color)
    }

    func multilineLabel(string: NSAttributedString) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = string
        return label
    }

    func copyableItem(string: NSAttributedString, valueToBeCopied: String? = nil) -> UIView {
        return MUDetailRowView.clipboard(title: string,
                                         valueToBeCopied: valueToBeCopied,
                                         controller: self,
                                         takeTapOnlyOnButton: true)
    }
}
