//
//  SettingsViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class SettingsViewController: MUViewController {

    @IBOutlet private weak var tableView: UITableView!

    private lazy var presenter = instancePresenter(SettingsPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "settings"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = UIEdgeInsets.zero
        setUpNavigation()

        presenter.setUp()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.SettingsViewController.s1
    }

    fileprivate func setUpView() {
        setUpTableView()
        view.backgroundColor = Asset.Colors.muunHomeBackgroundColor.color
    }

    fileprivate func setUpTableView() {
        tableView.register(type: SettingsTableViewCell.self)
        tableView.register(type: TwoLinesSettingsTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
    }

    private func handleLogOut() {
        if presenter.hasPendingIncomingSwapOperations() {
            // We can't log out a user with pending incoming swap operations
            presentPendingIncomingSwapsAlert()
        } else {
            presentLogOutAlert()
        }
    }

    private func showCurrencyPicker() {
        if let window = presenter.getExchangeRateWindow() {
            let currencyPicker = CurrencyPickerViewController.createForCurrencySettings(
                exchangeRateWindow: window.toLibwallet(),
                delegate: self,
                selectedCurrency: GetCurrencyForCode().runAssumingCrashPosibility(code: presenter.getPrimaryCurrency())
            )

            navigationController!.pushViewController(currencyPicker, animated: true)
        }
    }

    private func showBitcoinUnitPicker() {
        navigationController!.pushViewController(BitcoinUnitPickerViewController(), animated: true)
    }

    private func showChangePassword() {
        navigationController!.pushViewController(ChangePasswordPrimingViewController(), animated: true)
    }

    private func getChangeCurrencyCell() -> TwoLinesSettingsTableViewCell {
        for (sectionIndex, section) in presenter.sections.enumerated() {
            if case .general(let rows) = section {
                if let row = rows.firstIndex(of: .changeCurrency) {
                    let index = IndexPath(row: row, section: sectionIndex)
                    let cell = tableView.cellForRow(at: index)

                    if let cell = cell as? TwoLinesSettingsTableViewCell {
                        return cell
                    }
                }
            }
        }
        Logger.fatal("could not find change currency cell in settings screen")
    }

    private func decideDeleteWalletAction() {
        if !presenter.canDeleteWallet() {
            presentPendingOperationsAlert()
        } else {
            presentDeleteWalletAlert()
        }
    }

    private func showLightningNetworkSettings() {
        navigationController!.pushViewController(LightningNetworkSettingsViewController(), animated: true)
    }

    private func showOnchainSettings() {
        navigationController!.pushViewController(OnchainSettingsViewController(), animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           switch presenter.sections[section] {
           case .general, .logout, .deleteWallet, .security, .advanced:
            return UITableView.automaticDimension
           case .version:
               return 12
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch presenter.sections[indexPath.section] {

        case .logout:
            handleLogOut()

        case .general(let rows):
            switch rows[indexPath.row] {
            case .bitcoinUnit: showBitcoinUnitPicker()
            case .changeCurrency: showCurrencyPicker()
            }

        case .security(let rows):
            switch rows[indexPath.row] {
            case .changePassword: showChangePassword()
            }

        case .advanced(let rows):
            switch rows[indexPath.row] {
            case .lightningNetwork:
                showLightningNetworkSettings()
            case .onchain:
                showOnchainSettings()
            }

        case .version:
#if DEBUG
            debugChangeTaprootActivation()
#endif

        case .deleteWallet:
            decideDeleteWalletAction()
        }
    }

}

extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch presenter.sections[section] {
        case .logout, .version, .deleteWallet: return nil
        case .general: return L10n.SettingsViewController.s2
        case .security: return L10n.SettingsViewController.s3
        case .advanced: return L10n.SettingsViewController.advanced
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch presenter.sections[section] {

        case .general(let rows):
            return rows.count

        case .security(let rows):
            return rows.count

        case .advanced(let rows):
            return rows.count

        case .logout, .version, .deleteWallet:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch presenter.sections[indexPath.section] {

        case .logout:
            return logOutCell(indexPath: indexPath)

        case .general(let rows):
            return settingsGeneralCell(indexPath: indexPath, generalRows: rows)

        case .security(let rows):
            return settingsSecurityCell(indexPath: indexPath, rows: rows)

        case .version:
            return versionCell()

        case .deleteWallet:
            return deleteWalletCell(indexPath: indexPath)

        case .advanced(let rows):
            return settingsAdvancedCell(indexPath: indexPath, rows: rows)
        }
    }

    // Custom cells
    private func logOutCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: SettingsTableViewCell.self, indexPath: indexPath)

        cell.setUp(L10n.SettingsViewController.s4, color: Asset.Colors.muunRed.color)
        return cell
    }

    private func deleteWalletCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: SettingsTableViewCell.self, indexPath: indexPath)

        cell.setUp(L10n.SettingsViewController.s5, color: Asset.Colors.muunRed.color)
        return cell
    }

    private func versionCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.style = .description
        cell.textLabel?.text = L10n.SettingsViewController.s6 + Constant.appVersion

        return cell
    }

    private func settingsGeneralCell(indexPath: IndexPath, generalRows: [GeneralRow]) -> UITableViewCell {
        switch generalRows[indexPath.row] {

        case .bitcoinUnit:
            let cell = tableView.dequeue(type: TwoLinesSettingsTableViewCell.self, indexPath: indexPath)

            cell.setUp(mainLabel: L10n.SettingsViewController.s7,
                       secondLabel: presenter.getBitcoinUnit(),
                       image: Asset.Assets.btcLogo.image)
            cell.hideTopSeparator()
            cell.showChevron()
            return cell

        case .changeCurrency:
            let cell = tableView.dequeue(type: TwoLinesSettingsTableViewCell.self, indexPath: indexPath)
            var image: UIImage?
            if presenter.shouldDisplayBtcLogo() {
                image = Asset.Assets.btcLogo.image
            }

            cell.setUp(mainLabel: L10n.SettingsViewController.s8,
                       secondLabel: presenter.getReadablePrimaryCurrency(),
                       image: image)
            cell.hideTopSeparator()
            cell.showChevron()
            return cell

        }
    }

    private func settingsSecurityCell(indexPath: IndexPath, rows: [SecurityRow]) -> UITableViewCell {
        switch rows[indexPath.row] {

        case .changePassword:
            let cell = tableView.dequeue(type: SettingsTableViewCell.self, indexPath: indexPath)

            cell.setUp(L10n.SettingsViewController.s9, color: Asset.Colors.title.color)
            return cell
        }
    }

    private func settingsAdvancedCell(indexPath: IndexPath, rows: [AdvancedRow]) -> UITableViewCell {

        switch rows[indexPath.row] {
        case .lightningNetwork:
            let cell = tableView.dequeue(type: SettingsTableViewCell.self, indexPath: indexPath)

            cell.setUp(L10n.SettingsViewController.lightningNetwork, color: Asset.Colors.title.color)
            cell.showChevron()
            if rows.count > 1 {
                cell.hideTopSeparator()
            }

            return cell
        case .onchain:
            let cell = tableView.dequeue(type: SettingsTableViewCell.self, indexPath: indexPath)

            cell.setUp(L10n.SettingsViewController.onchain, color: Asset.Colors.title.color)
            cell.showChevron()
            return cell

        }
    }

}

// Alerts
extension SettingsViewController {

    private func presentPendingOperationsAlert() {
        let alert = UIAlertController(
            title: L10n.SettingsViewController.s10,
            message: L10n.SettingsViewController.s23,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.ok, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.view.tintColor = Asset.Colors.muunBlue.color
        self.present(alert, animated: true)
    }

    private func presentPendingIncomingSwapsAlert() {
        let alert = UIAlertController(
            title: L10n.SettingsViewController.s12,
            message: L10n.SettingsViewController.s13,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.ok, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.view.tintColor = Asset.Colors.muunBlue.color
        self.present(alert, animated: true)
    }

    private func presentLogOutAlert() {
        let alert = UIAlertController(
            title: L10n.SettingsViewController.s15,
            message: L10n.SettingsViewController.s16,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.cancel, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.s4, style: .destructive, handler: { _ in
            self.logEvent("log_out")
            self.presenter.logout()
            self.resetWindowToGetStarted()
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

    private func presentDeleteWalletAlert() {
        let alert = UIAlertController(
            title: L10n.SettingsViewController.s19,
            message: L10n.SettingsViewController.s20,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.cancel, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.SettingsViewController.s22, style: .destructive, handler: { _ in
            self.logEvent("wallet_deleted")
            self.presenter.deleteWallet()
            self.navigationController!.setViewControllers(
                [FeedbackViewController(feedback: FeedbackInfo.deleteWallet)],
                animated: true
            )
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

#if DEBUG
    private func debugChangeTaprootActivation() {
        presenter.debugChangeTaprootActivation()
    }
#endif
}

extension SettingsViewController: SettingsPresenterDelegate {

    func setCurrencyLoading(_ isLoading: Bool) {
        let cell = getChangeCurrencyCell()
        cell.setLoading(isLoading)
    }

    func successfullyUpdateUser() {
        tableView.reloadData()
    }

}

extension SettingsViewController: CurrencyPickerDelegate {

    func didSelectCurrency(_ currency: Currency) {
        AnalyticsHelper.setUserProperty(currency.code, forName: "currency")
        presenter.didChangeCurrency(currency)
        tableView.reloadData()
    }

}

extension SettingsViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SettingsPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
    }

}
