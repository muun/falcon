//
//  ReceivingNodeDetailsPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 22/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

protocol ReceivingNodeDetailsPresenterDelegate: BasePresenterDelegate {
    func onLoad(_ viewModel: ReceivingNodeDetailsViewModel)
}

private enum Constants {
    // TODO: source the receiving node's public key from the real payment flow.
    static let publicKey = "0262cd729086d2e1708b92fa7eb0092d051ad29de81bd8b91e8ebed1aa970ac9da"
    static let explorerBaseURL = "https://mempool.space/lightning/node/"
}

final class ReceivingNodeDetailsPresenter<Delegate: ReceivingNodeDetailsPresenterDelegate>:
    BasePresenter<Delegate> {

    func load() {
        delegate.onLoad(
            ReceivingNodeDetailsViewModel(
                publicKey: Constants.publicKey,
                explorerURL: URL(string: Constants.explorerBaseURL + Constants.publicKey)!
            )
        )
    }
}
