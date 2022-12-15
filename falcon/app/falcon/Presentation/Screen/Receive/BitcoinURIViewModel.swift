//
//  BitcoinURIViewModel.swift
//  Muun
//
//  Created by Lucas Serruya on 28/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

struct BitcoinURIViewModel {
    let uri: String
    let invoice: IncomingInvoiceInfo
    let address: String

    static func from(raw: RawBitcoinURI) -> BitcoinURIViewModel {
        let info = IncomingInvoiceInfo.from(raw: raw.rawInvoice)

        return BitcoinURIViewModel(uri: raw.uri,
                                   invoice: info,
                                   address: raw.address)
    }

    func detailedURIForDescription() -> NSAttributedString {
        let detailedURI = L10n.ReceiveViewController.detailedURIDisclaimer
            .attributedForDescription(paragraphLineBreakMode: .byClipping)
        addEmptyLine(to: detailedURI)
        addTitle(title: L10n.ReceiveViewController.detailedURIBTCTitle, to: detailedURI)
        detailedURI.append(address.attributedForDescription())
        addEmptyLine(to: detailedURI)
        addTitle(title: L10n.ReceiveViewController.detailedURILNTitle, to: detailedURI)
        detailedURI.append(invoice.rawInvoice.attributedForDescription())
        return detailedURI
    }

    private func addEmptyLine(to string: NSMutableAttributedString) {
        addEndOfLine(to: string)
        addEndOfLine(to: string)
    }

    private func addEndOfLine(to string: NSMutableAttributedString) {
        string.append("\n".toAttributedString())
    }

    private func addTitle(title: String, to string: NSMutableAttributedString) {
        let attributedTitle = title.set(font: Constant.Fonts.system(size: .desc,
                                                                    weight: .semibold),
                                        lineSpacing: Constant.FontAttributes.lineSpacing,
                                        kerning: Constant.FontAttributes.kerning)

        _ = attributedTitle.set(tint: title, color: Asset.Colors.title.color)
        string.append(attributedTitle)

        addEndOfLine(to: string)
    }
}
