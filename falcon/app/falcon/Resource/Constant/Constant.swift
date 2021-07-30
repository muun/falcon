//
//  Constant.swift
//  falcon
//
//  Created by Manu Herrera on 10/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

enum Constant {

    enum Dimens {
        static let homeHeaderHeight: CGFloat = 16.0
        static let viewControllerPadding: CGFloat = 24.0
    }

    enum FontSize: CGFloat {
        case bitcoinAmountHome = 36
        case welcomeMessage = 34
        case homeAmount = 30
        case h2 = 24
        case h1 = 20
        case homeCurrency = 18
        case opTitle = 17
        case desc = 16
        case opDesc = 15
        case helper = 14
        case opHelper = 13
        case notice = 12
        case tabBar = 10
        case amountInput = 48
    }

    enum Fonts {
        static let description = system(size: .desc, weight: .regular)

        static func system(size: Constant.FontSize, weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: size.rawValue, weight: weight)
        }

        static func italic(size: Constant.FontSize) -> UIFont {
            return UIFont.italicSystemFont(ofSize: size.rawValue)
        }

        static func monospacedDigitSystemFont(size: Constant.FontSize, weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.monospacedDigitSystemFont(ofSize: size.rawValue, weight: weight)
        }
    }

    enum FontAttributes {
        static let kerning: CGFloat = 0.5
        static let lineSpacing: CGFloat = 5.0
    }

    enum MuunURL {
        static let appStoreLink = "https://apps.apple.com/app/muun-wallet/id1482037683"
    }

    static let supportEmail = "support@muun.com"

    static let leftBarButtonItemInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)

    enum Images {
        static let back = Asset.Assets.navBack.image.withInsets(leftBarButtonItemInsets)
        static let close = Asset.Assets.navClose.image.withInsets(leftBarButtonItemInsets)
    }

    enum NewOpAnalytics {

        enum OpType: String {
            case toAddress = "to_address"
            case submarineSwap = "submarine_swap"
        }

        enum Origin: String {
            case clipboard = "send_clipboard_paste"
            case manualInput = "send_manual_input"
            case qr = "scan_qr"
            case externalLink = "external_link"
        }
    }

    enum ReceiveOrigin: String {
        case forcePush = "force_push_receive"
        case receiveButton = "receive_button"
    }

    enum SecurityCenterOrigin: String {
        case emptyAnonUser = "empty_home_anon_user"
        case shieldButton = "shield_button"
        case bannerSetupEmail = "banner_setup_email"
    }

    // 18.0.3 (1995)
    static let appVersion = """
    \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? 0) \
    (\(Bundle.main.infoDictionary!["CFBundleVersion"] ?? 0))
    """

}

enum ShortcutIdentifier: String {
    case sendMoney
    case receiveMoney

    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}
