//
//  SecureKeyValueStorageDebugPresenter.swift
//  Muun
//

import Foundation

protocol SecureKeyValueStorageDebugPresenterDelegate: BasePresenterDelegate,
                                                      MUViewController {
    func showAlert(title: String?, message: String?)
}

class SecureKeyValueStorageDebugPresenter<Delegate: SecureKeyValueStorageDebugPresenterDelegate>:
    BasePresenter<Delegate> {

    private let smokeKey = "libwallet-bridge-smoketest"
    private let walletService: WalletService

    init(delegate: Delegate, walletService: WalletService) {
        self.walletService = walletService
        super.init(delegate: delegate)
    }

    func onPutTapped() {
        let timestampMs = Int64(Date().timeIntervalSince1970 * 1000)
        let payload = Data("hello-from-libwallet-\(timestampMs)".utf8)
        do {
            try walletService.secureKeyValueStoragePut(
                key: smokeKey,
                value: payload
            )
            delegate.showAlert(title: "PUT OK", message: "key=\(smokeKey)")
        } catch {
            delegate.showAlert(title: "PUT failed", message: error.localizedDescription)
        }
    }

    func onGetTapped() {
        do {
            let secret = try walletService.secureKeyValueStorageGet(key: smokeKey)
            try secret.withSecret { bytes in
                delegate.showAlert(title: "GET OK", message: "\(bytes.count) bytes")
            }
        } catch {
            delegate.showAlert(title: "GET failed", message: error.localizedDescription)
        }
    }

    func onDeleteTapped() {
        do {
            try walletService.secureKeyValueStorageDelete(key: smokeKey)
            delegate.showAlert(title: "DELETE OK", message: "key=\(smokeKey)")
        } catch {
            delegate.showAlert(title: "DELETE failed", message: error.localizedDescription)
        }
    }

    func onWipeConfirmed() {
        do {
            try walletService.secureKeyValueStorageWipe()
            delegate.showAlert(title: "WIPE OK", message: nil)
        } catch {
            delegate.showAlert(title: "WIPE failed", message: error.localizedDescription)
        }
    }
}
