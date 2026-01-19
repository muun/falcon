//
//  BitcoinUnitPickerViewController.swift
//  falcon
//
//  Created by Manu Herrera on 10/12/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class BitcoinUnitPickerViewController: MUViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!

    fileprivate let cellHeight: CGFloat = 48
    fileprivate lazy var presenter = instancePresenter(BitcoinUnitPickerPresenter.init, delegate: self)
    private weak var delegate: CurrencyPickerDelegate?

    override var screenLoggingName: String {
        return "bitcoin_unit_picker"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        presenter.setUp()

        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.BitcoinUnitPickerViewController.s1
    }

    fileprivate func setUpView() {
        view.backgroundColor = Asset.Colors.muunHomeBackgroundColor.color
        setUpTableView()
    }

    fileprivate func setUpTableView() {
        tableView.register(type: CurrencyTableViewCell.self)
    }

}

extension BitcoinUnitPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCurrency = presenter.currency(forRowAt: indexPath)
        logEvent(
            "did_select_bitcoin_unit",
            parameters: ["type": selectedCurrency.code.lowercased()]
        )
        presenter.selectUnit(selectedCurrency)
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension BitcoinUnitPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: CurrencyTableViewCell.self, indexPath: indexPath)
        let currencyToDisplay = presenter.currency(forRowAt: indexPath)

        cell.setUp(currencyToDisplay, isSelected: presenter.isSelected(currencyToDisplay))

        return cell
    }

}

extension BitcoinUnitPickerViewController: BitcoinUnitPickerPresenterDelegate {}
