//
//  AppInfoProvider.swift
//  falcon
//
//  Created by Ramiro Repetto on 26/08/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import CryptoKit
import UIKit
import StoreKit

public class AppInfoProvider {

    private var installSource: InstallSource = InstallSource.unknown

    public func start() {
        Task {
            if #available(iOS 16.0, *) {
                installSource = await getInstallSource16Plus()
            } else {
                installSource = getInstallSourceIos15()
            }
        }
    }

    func getAppDisplayName() -> String {
        return (
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ) ?? SignalConstants.empty
    }

    func getAppName() -> String {
        return  (
            Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ) ?? SignalConstants.empty
    }

    func getAppId() -> String {
        return  Bundle.main.bundleIdentifier ?? SignalConstants.empty
    }

    func getAppPrimaryIconHash() -> String {
        guard let info = Bundle.main.infoDictionary,
              let iconDict = info["CFBundleIcons"] as? [String: Any],
              let primaryIcon = iconDict["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let firstIconName = iconFiles.first else {
            return SignalConstants.unknown
        }

        guard let image = UIImage(named: firstIconName),
              let data = image.pngData() else {
            return SignalConstants.unknown
        }

        let digest = SHA256.hash(data: data)
        let hashString = digest.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }

    enum InstallSource: Int {
        case store = 1
        case test = 2
        case verifiedUnknown = 3
        case unverified = 0
        case unknown = -1
        case error = -2
    }

    private func getInstallSourceIos15() -> InstallSource {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return .error
        }

        let lastComponent = receiptURL.lastPathComponent
        let fileExists = FileManager.default.fileExists(atPath: receiptURL.path)
        let fileSize: Int
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: receiptURL.path)
            fileSize = attrs[.size] as? Int ?? 0
        } catch {
            fileSize = 0
        }

        switch lastComponent {
        case "sandboxReceipt":
            return .test
        case "receipt":
            if fileExists && fileSize > 0 {
                return .store
            } else {
                return .test
            }
        default:
            return .unverified
        }
    }

    @available(iOS 16.0, *)
    private func getInstallSource16Plus() async -> InstallSource {
        do {
            let appTransaction = try await AppTransaction.shared
            switch appTransaction {
            case .verified(let transaction):
                switch transaction.environment {
                case .production:
                    return .store
                case .sandbox:
                    return .test
                default:
                    return .verifiedUnknown
                }
            case .unverified:
                return .unverified
            }
        } catch {
            return .error
        }
    }

    func getInstallSource() -> InstallSource {
        return installSource
    }
}
