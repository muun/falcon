//
//  EmergencyKitSavingOptions.swift
//  falcon
//
//  Created by Manu Herrera on 12/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

typealias EKOption = (option: EmergencyKitSavingOption, isRecommended: Bool, isEnabled: Bool)

enum EmergencyKitSavingOption {
    case drive, icloud, manually

    func image() -> UIImage {
        switch self {
        case .drive: return Asset.Assets.ekOptionDrive.image
        case .icloud: return Asset.Assets.ekOptionIcloud.image
        case .manually: return Asset.Assets.ekOptionManually.image
        }
    }

    func title() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveTitle
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudTitle
        case .manually: return L10n.SaveEmergencyKitOptionView.manuallyTitle
        }
    }

    func description() -> NSAttributedString {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveDescription.attributedForDescription()
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudDescription.attributedForDescription()
        case .manually: return L10n.SaveEmergencyKitOptionView.manuallyDescription.attributedForDescription()
        }
    }

    func disabledDescription() -> NSAttributedString {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveDescription.attributedForDescription()
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudDisabledDescription.attributedForDescription()
        case .manually: return L10n.SaveEmergencyKitOptionView.manuallyDescription.attributedForDescription()
        }
    }

    func openInCloudButtonText() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.openInDrive
        case .icloud: return L10n.SaveEmergencyKitOptionView.openInICloud
        case .manually: return "" // won't be used
        }
    }

    func verifyImage() -> UIImage {
        switch self {
        case .drive: return Asset.Assets.ekVerifyDrive.image
        case .icloud: return Asset.Assets.ekVerifyIcloud.image
        case .manually: return UIImage() // won't be used
        }
    }

    func verifyTitle() -> String {
        switch self {
        case .drive, .icloud: return L10n.SaveEmergencyKitOptionView.verifyTitle
        case .manually: return "" // won't be used
        }
    }

    func verifyDescription() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.verifyDescriptionDrive
        case .icloud: return L10n.SaveEmergencyKitOptionView.verifyDescriptionICloud
        case .manually: return "" // won't be used
        }
    }
}
