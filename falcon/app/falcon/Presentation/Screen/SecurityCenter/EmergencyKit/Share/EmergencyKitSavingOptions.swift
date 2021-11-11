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
    case drive, icloud, anotherCloud

    func image() -> UIImage {
        switch self {
        case .drive: return Asset.Assets.ekOptionDrive.image
        case .icloud: return Asset.Assets.ekOptionIcloud.image
        case .anotherCloud: return Asset.Assets.ekOptionAnotherCloud.image
        }
    }

    func title() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveTitle
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudTitle
        case .anotherCloud: return L10n.SaveEmergencyKitOptionView.anotherCloudTitle
        }
    }

    func description() -> NSAttributedString {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveDescription.attributedForDescription()
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudDescription.attributedForDescription()
        case .anotherCloud: return L10n.SaveEmergencyKitOptionView.anotherCloudDescription.attributedForDescription()
        }
    }

    func disabledDescription() -> NSAttributedString {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.driveDescription.attributedForDescription()
        case .icloud: return L10n.SaveEmergencyKitOptionView.icloudDisabledDescription.attributedForDescription()
        case .anotherCloud: return L10n.SaveEmergencyKitOptionView.anotherCloudDescription.attributedForDescription()
        }
    }

    func openInCloudButtonText() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.openInDrive
        case .icloud: return L10n.SaveEmergencyKitOptionView.openInICloud
        case .anotherCloud: return "" // won't be used
        }
    }

    func verifyImage() -> UIImage {
        switch self {
        case .drive: return Asset.Assets.ekVerifyDrive.image
        case .icloud: return Asset.Assets.ekVerifyIcloud.image
        case .anotherCloud: return UIImage() // won't be used
        }
    }

    func verifyTitle() -> String {
        switch self {
        case .drive, .icloud: return L10n.SaveEmergencyKitOptionView.verifyTitle
        case .anotherCloud: return "" // won't be used
        }
    }

    func verifyDescription() -> String {
        switch self {
        case .drive: return L10n.SaveEmergencyKitOptionView.verifyDescriptionDrive
        case .icloud: return L10n.SaveEmergencyKitOptionView.verifyDescriptionICloud
        case .anotherCloud: return "" // won't be used
        }
    }
}
