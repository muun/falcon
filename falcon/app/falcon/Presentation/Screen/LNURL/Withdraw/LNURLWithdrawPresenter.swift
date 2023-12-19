//
//  LNURLWithdrawPresenter.swift
//  falcon
//
//  Created by Federico Bond on 09/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import core

protocol LNURLWithdrawPresenterDelegate: BasePresenterDelegate {
    func updateState(_ state: LNURLWithdrawViewController.State)
    func returnToHome()
}

class LNURLWithdrawPresenter<Delegate: LNURLWithdrawPresenterDelegate>: BasePresenter<Delegate> {

    private let sessionActions: SessionActions
    private let lnurlWithdrawAction: LNURLWithdrawAction
    private let notificationScheduler: NotificationScheduler
    internal let fetchNotificationsAction: FetchNotificationsAction
    private let errorReporter: ErrorReporter

    private let qr: String
    private var invoice: String?
    private var sender: String?
    private var paymentHash: Data?
    private var expires: Date?

    private var error: MuunError?

    init(delegate: Delegate,
         state: String,
         sessionActions: SessionActions,
         lnurlWithdrawAction: LNURLWithdrawAction,
         notificationScheduler: NotificationScheduler,
         fetchNotificationsAction: FetchNotificationsAction,
         errorReporter: ErrorReporter) {
        self.sessionActions = sessionActions
        self.lnurlWithdrawAction = lnurlWithdrawAction
        self.notificationScheduler = notificationScheduler
        self.fetchNotificationsAction = fetchNotificationsAction
        self.errorReporter = errorReporter
        self.qr = state
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Fetch every 3 seconds for new operations
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 3)

        subscribeTo(periodicFetch, onNext: { _ in })

        subscribeTo(lnurlWithdrawAction.run(qr), onNext: self.onWithdrawStateChange)
    }

    override func tearDown() {
        super.tearDown()

        guard let sender = sender,
              let paymentHash = paymentHash,
              let expires = expires else {
            return
        }

        if error == nil {
            notificationScheduler.notifyPending(
                paymentHash: paymentHash,
                title: L10n.LNURLWithdrawPresenter.pendingNotificationTitle,
                body: L10n.LNURLWithdrawPresenter.pendingNotificationBody(sender)
            )

            notificationScheduler.notifyFailed(
                paymentHash: paymentHash,
                title: L10n.LNURLWithdrawPresenter.failedNotificationTitle,
                body: L10n.LNURLWithdrawPresenter.failedNotificationBody(sender),
                at: expires
            )
        }
    }

    private func onWithdrawStateChange(state: LNURLWithdrawAction.State) {
        switch state {
        case .contacting(let domain):
            sender = domain
            delegate.updateState(.contacting(domain: domain))
        case .receiving(let domain):
            delegate.updateState(.receiving(domain: domain))
        case .invoice(let invoice, let paymentHash, let expires, _):
            self.invoice = invoice
            self.paymentHash = paymentHash
            self.expires = expires
            delegate.updateState(.invoiceCreated)
        case .tooLong(let domain):
            delegate.updateState(.tooLong(domain: domain))
        case .failed(let error):
            self.error = error
            let viewModel = LNURLWithdrawErrorViewModel(wrappedError: error, invoice: invoice)
            delegate.updateState(.failed(error: viewModel))
        case .success:
            // clean up these fields so notifications are not scheduled
            self.sender = nil
            self.paymentHash = nil
            self.expires = nil
            delegate.updateState(.success)
        }
    }

    func retry() {
        subscribeTo(lnurlWithdrawAction.run(qr), onNext: self.onWithdrawStateChange)
    }

    func getReportURLQueryParams() -> String {
        guard let error = error else {
            fatalError("expected presenter to contain an error")
        }

        let user = sessionActions.getUser()
        var (subject, body) = errorReporter.getSubjectAndBody(
            error: error,
            user: user,
            extraKeys: getReportExtraKeys()
        )

        subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        body = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return "subject=\(subject)&body=\(body)"
    }

    func getReportForClipboard() -> String {
        guard let error = error else {
            fatalError("expected presenter to contain an error")
        }

        let user = sessionActions.getUser()

        let (_, body) = errorReporter.getSubjectAndBody(
            error: error,
            user: user,
            extraKeys: getReportExtraKeys()
        )
        return body
    }

    private func getReportExtraKeys() -> [String: String] {
        var keys: [String: String] = [:]
        if let sender = sender {
            keys["sender"] = sender
        }
        if let paymentHash = paymentHash {
            keys["payment_hash"] = paymentHash.toHexString()
        }
        if let expires = expires {
            keys["expires"] = ISO8601DateFormatter().string(from: expires)
        }
        return keys
    }

}

struct LNURLWithdrawErrorViewModel: ErrorViewModel {

    let wrappedError: MuunError
    let invoice: String?

    var error: LNURLWithdrawAction.WithdrawError {
        if let error = wrappedError.kind as? LNURLWithdrawAction.WithdrawError {
            return error
        }
        return LNURLWithdrawAction.WithdrawError.unknown(
            message: wrappedError.localizedDescription
        )
    }

    func title() -> String {
        switch error {
        case .invalidCode:
            return L10n.LNURLWithdrawPresenter.invalidCodeTitle
        case .unresponsive(_, let domain):
            return L10n.LNURLWithdrawPresenter.unresponsiveTitle(domain)
        case .wrongTag:
            return L10n.LNURLWithdrawPresenter.wrongTagTitle
        case .requestExpired:
            return L10n.LNURLWithdrawPresenter.requestExpiredTitle
        case .noAvailableBalance:
            return L10n.LNURLWithdrawPresenter.noAvailableBalanceTitle
        case .noRoute:
            return L10n.LNURLWithdrawPresenter.noRouteTitle
        case .unknown:
            return L10n.LNURLWithdrawPresenter.unknownErrorTitle
        case .expiredInvoice:
            return L10n.LNURLWithdrawPresenter.expiredInvoiceTitle
        case .countryNotSupported:
            return L10n.LNURLWithdrawPresenter.countryNotSupportedTitle
        case .alreadyUsed:
            return L10n.LNURLWithdrawPresenter.alreadyUsedTitle
        }
    }

    func description() -> NSAttributedString {
        switch error {
        case .invalidCode:
            return L10n.LNURLWithdrawPresenter.invalidCodeDescription
                .attributedForDescription(alignment: .center)
        case .unresponsive:
            return L10n.LNURLWithdrawPresenter.unresponsiveDescription
                .attributedForDescription(alignment: .center)
        case .wrongTag:
            return L10n.LNURLWithdrawPresenter.wrongTagDescription
                .attributedForDescription(alignment: .center)
        case .requestExpired:
            return L10n.LNURLWithdrawPresenter.requestExpiredDescription
                .attributedForDescription(alignment: .center)
        case .noAvailableBalance(_, let domain):
            return L10n.LNURLWithdrawPresenter.noAvailableBalanceDescription(domain)
                .attributedForDescription(alignment: .center)
                .set(bold: domain, color: Asset.Colors.muunGrayDark.color)
        case .noRoute(_, let domain):
            return L10n.LNURLWithdrawPresenter.noRouteDescription(domain, domain)
                .attributedForDescription(alignment: .center)
                .set(bold: domain, color: Asset.Colors.muunGrayDark.color)
        case .unknown:
            return L10n.LNURLWithdrawPresenter.unknownErrorDescription
                .attributedForDescription(alignment: .center)
        case .expiredInvoice(let domain):
            return L10n.LNURLWithdrawPresenter.expiredInvoiceDescription(domain)
                .attributedForDescription(alignment: .center)
                .set(bold: domain, color: Asset.Colors.muunGrayDark.color)
        case .countryNotSupported:
            return L10n.LNURLWithdrawPresenter.countryNotSupportedDescription
                .attributedForDescription(alignment: .center)
        case .alreadyUsed:
            return L10n.LNURLWithdrawPresenter.alreadyUsedDescription
                .attributedForDescription(alignment: .center)
        }
    }

    func loggingName() -> String {
        switch error {
        case .invalidCode:
            return "lnurl_invalid_code"
        case .unresponsive:
            return "lnurl_unresponsive"
        case .wrongTag:
            return "lnurl_wrong_tag"
        case .requestExpired:
            return "lnurl_request_expired"
        case .noAvailableBalance:
            return "lnurl_no_balance"
        case .noRoute:
            return "lnurl_no_route"
        case .unknown:
            return "lnurl_unknown_error"
        case .expiredInvoice:
            return "lnurl_expired_invoice"
        case .alreadyUsed:
            return "lnurl_already_used"
        case .countryNotSupported:
            return "lnurl_countryNotSupported"
        }
    }

    func kind() -> ErrorViewKind {
        switch error {
        case .unresponsive:
            return .retryable
        case .unknown:
            return .reportable
        default:
            return .final
        }
    }

    func firstBoxTexts() -> (title: String, content: NSAttributedString)? {
        if case .unknown(var message) = error {
            if message.count > 280 {
                message = message.truncate(maxLength: 280) + "..."
            }
            return (
                L10n.LNURLWithdrawPresenter.receivedMessage,
                message.attributedForDescription(alignment: .center)
            )
        }

        if let invoice = invoice {
            return (
                L10n.LNURLWithdrawPresenter.invoice,
                invoice.attributedForDescription(alignment: .center)
            )
        }
        return nil
    }

    func secondaryButtonText() -> String {
        return L10n.ErrorView.goToHome
    }
}

extension LNURLWithdrawPresenter: NotificationsFetcher {}
