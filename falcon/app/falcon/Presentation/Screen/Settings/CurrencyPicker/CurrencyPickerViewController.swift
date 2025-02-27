//
//  CurrencyPickerViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import Libwallet


protocol CurrencyPickerDelegate: AnyObject {
    func didSelectCurrency(_ currency: Currency)
}

class CurrencyPickerViewController: MUViewController, Resolver {

    @IBOutlet private weak var tableView: UITableView!

    fileprivate let cellHeight: CGFloat = 48
    fileprivate lazy var presenter = instancePresenter(CurrencyPickerPresenter.init,
                                                       delegate: self,
                                                       state: currenciesForPickerRetrieverService)

    private let currenciesForPickerRetrieverService: CurrenciesForPickerRetriever
    private var selectedCurrency: Currency?
    private weak var delegate: CurrencyPickerDelegate?

    override var screenLoggingName: String {
        return "currency_picker"
    }

    init(delegate: CurrencyPickerDelegate?,
         selectedCurrency: Currency?,
         currenciesForPickerRetrieverService: CurrenciesForPickerRetriever) {
        self.delegate = delegate
        self.selectedCurrency = selectedCurrency
        self.currenciesForPickerRetrieverService = currenciesForPickerRetrieverService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
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

        title = L10n.CurrencyPickerViewController.s1
    }

    fileprivate func setUpView() {
        setUpTableView()
        setUpSearchBar()

        makeViewTestable()
    }

    fileprivate func setUpTableView() {
        tableView.register(type: CurrencyTableViewCell.self)
    }

    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.tintColor = Asset.Colors.muunBlue.color
        searchBar.placeholder = L10n.CurrencyPickerViewController.s2
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }

    static func createForCurrencySelection(exchangeRateWindow: NewopExchangeRateWindow,
                                           delegate: CurrencyPickerDelegate?,
                                           selectedCurrency: Currency?) -> CurrencyPickerViewController {
        let userSelector: UserSelector = resolve()
        let currenciesRepository = InMemoryCurrenciesForPickerRetriever.createForContextualCurrencySelection(userSelector: userSelector,
                                                                                                      exchangeRateWindow: exchangeRateWindow)
        return CurrencyPickerViewController(delegate: delegate,
                                            selectedCurrency: selectedCurrency,
                                            currenciesForPickerRetrieverService: currenciesRepository)
    }

    static func createForCurrencySettings(exchangeRateWindow: NewopExchangeRateWindow,
                                          delegate: CurrencyPickerDelegate?,
                                          selectedCurrency: Currency?) -> CurrencyPickerViewController {
        let userSelector: UserSelector = resolve()
        let repository = InMemoryCurrenciesForPickerRetriever.createForSettings(userSelector: userSelector,
                                                                                       exchangeRateWindow: exchangeRateWindow)
        return CurrencyPickerViewController(delegate: delegate,
                                            selectedCurrency: selectedCurrency,
                                            currenciesForPickerRetrieverService: repository)
    }
}

extension CurrencyPickerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filter(searchText)
        tableView.reloadData()
    }

}

extension CurrencyPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentCurrency = presenter.currency(forRowAt: indexPath)

        delegate?.didSelectCurrency(currentCurrency)

        if navigationIsBeingPresented() {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Asset.Colors.muunHomeBackgroundColor.color

        let headerLabel = UILabel(frame: CGRect(x: 24, y: 16, width: tableView.bounds.size.width, height: 20))
        headerLabel.font = Constant.Fonts.system(size: .opHelper)
        headerLabel.textColor = Asset.Colors.muunGrayDark.color
        let text = (section == 0)
            ? L10n.CurrencyPickerViewController.s3
            : L10n.CurrencyPickerViewController.s4
        headerLabel.text = text
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension CurrencyPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currenciesCount(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: CurrencyTableViewCell.self, indexPath: indexPath)
        let currencyToDisplay = presenter.currency(forRowAt: indexPath)

        cell.setUp(currencyToDisplay, isSelected: currencyToDisplay.displayCode == selectedCurrency?.displayCode)

        return cell
    }

}

extension CurrencyPickerViewController: CurrencyPickerPresenterDelegate {

    func gotCurrencyList() {
        tableView.reloadData()
    }
}

extension CurrencyPickerViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.CurrencyPicker

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(tableView, using: .tableView)
    }
}
