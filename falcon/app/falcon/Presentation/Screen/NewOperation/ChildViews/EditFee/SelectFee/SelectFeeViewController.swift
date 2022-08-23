//
//  SelectFeeViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol SelectFeeDelegate: AnyObject {
    func selected(fee: BitcoinAmount, rate: FeeRate)
    func cancel()
}

class SelectFeeViewController: MUViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: ButtonView!
    @IBOutlet fileprivate weak var noticeView: UIView!
    @IBOutlet fileprivate weak var noticeLabel: UILabel!
    @IBOutlet fileprivate weak var noticeSeparatorView: UIView!

    fileprivate lazy var presenter = instancePresenter(SelectFeePresenter.init,
                                                       delegate: self, state: state)
    private weak var delegate: SelectFeeDelegate?

    private var selectedFee: FeeState {
        didSet {
            updateConfirmButton()
        }
    }

    private let originalFeeState: FeeState
    private let state: FeeEditorState

    override var screenLoggingName: String {
        return "select_fee"
    }

    init(delegate: SelectFeeDelegate?, state: FeeEditorState) {

        self.delegate = delegate
        self.originalFeeState = state.feeState
        self.selectedFee = state.feeState
        self.state = state

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigation()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.SelectFeeViewController.s1
    }

    private func setUpView() {
        setUpTableView()
        setUpButton()
        setUpDisclaimer()
    }

    private func setUpButton() {
        confirmButton.style = .primary
        confirmButton.delegate = self
        confirmButton.buttonText = L10n.SelectFeeViewController.s2

        updateConfirmButton()
    }

    private func setUpTableView() {
        tableView.register(type: TitleTableViewCell.self)
        tableView.register(type: TargetedFeeTableViewCell.self)
        tableView.register(type: EnterFeeManuallyTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        tableView.alwaysBounceVertical = false
    }

    private func setUpDisclaimer() {
        noticeView.backgroundColor = Asset.Colors.background.color
        noticeView.isHidden = !presenter.takeFeeFromAmount
        noticeLabel.textColor = Asset.Colors.muunGrayDark.color
        noticeLabel.font = Constant.Fonts.system(size: .helper)
        let boldText = L10n.SelectFeeViewController.s3
        let allText = L10n.SelectFeeViewController.s5
        noticeLabel.attributedText = allText
            .set(font: noticeLabel.font)
            .set(bold: boldText, color: Asset.Colors.muunWarning.color)
        noticeSeparatorView.backgroundColor = Asset.Colors.separator.color
    }

    private func updateConfirmButton() {
        switch selectedFee {
        case .finalFee:
            confirmButton.isEnabled = true
        case .feeNeedsChange, .noPossibleFee:
            confirmButton.isEnabled = false
        }
    }

    override func onCloseTap() {
        self.delegate?.cancel()
        super.onCloseTap()
    }

    override func willMove(toParent parent: UIViewController?) {
        parent?.presentationController?.delegate = self
        super.willMove(toParent: parent)
    }
}

extension SelectFeeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch presenter.sections[indexPath.section] {

        case .targetedFees:
            let feeInfo = presenter.fee(for: indexPath)

            if case .finalFee = feeInfo {
                selectedFee = feeInfo
            }

            tableView.reloadData()

        case .enterManually:
            let vc = ManuallyEnterFeeViewController(delegate: delegate,
                                                    state: state,
                                                    showUseMaxButton: shouldShowUseMaxButton(),
                                                    selectedCurrency: state.amount.selectedCurrency)
            navigationController!.pushViewController(vc, animated: true)
            tableView.reloadData()

        default:
            return
        }
    }

    private func shouldShowUseMaxButton() -> Bool {
        // The use max fee button is only displayed in case the user is not taking fee from amount
        // And if the user doesnt have a selected fee
        if presenter.takeFeeFromAmount {
            return false
        } else {
            switch originalFeeState {
            case .finalFee:
                return false
            default:
                return true
            }

        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch presenter.sections[indexPath.section] {

        case .targetedFees:
            let feeInfo = presenter.fee(for: indexPath)
            cell.setSelected(selectedFee == feeInfo, animated: true)

        case .enterManually:
            cell.setSelected(isFeeSelectedManually(), animated: true)

        default:
            return
        }
    }

    private func presentOverlay() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.selectFee)
        navigationController!.present(overlayVc, animated: true)
    }

    private func isFeeSelectedManually() -> Bool {
        return !presenter.fees.contains(selectedFee)
    }
}

extension SelectFeeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsForSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch presenter.sections[indexPath.section] {

        case .title:
            return titleCell(indexPath: indexPath)

        case .targetedFees:
            return targetedFeeCell(indexPath: indexPath)

        case .enterManually:
            return enterManuallyCell(indexPath: indexPath)
        }
    }

    // Custom cells
    private func titleCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: TitleTableViewCell.self, indexPath: indexPath)

        let text = L10n.SelectFeeViewController.s4

        cell.setUp(text: text, delegate: self)
        cell.selectionStyle = .none

        return cell
    }

    private func targetedFeeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: TargetedFeeTableViewCell.self, indexPath: indexPath)

        let fee = presenter.fee(for: indexPath)
        let timeText = presenter.timeText(for: indexPath)

        cell.setUp(fee: fee,
                   confirmationTime: timeText,
                   currencyToShow: state.amount.selectedCurrency)
        cell.selectionStyle = .none

        return cell
    }

    private func enterManuallyCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: EnterFeeManuallyTableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none

        var finalFee: BitcoinAmount?

        switch originalFeeState {
        case .finalFee(let fee, _):
            finalFee = fee
            for fee in presenter.fees where fee == originalFeeState {
                finalFee = nil
            }
        default:
            finalFee = nil
        }

        var fee: BitcoinAmountWithSelectedCurrency?

        if let finalFee = finalFee {
            fee = BitcoinAmountWithSelectedCurrency(bitcoinAmount: finalFee,
                                                    selectedCurrency: state.amount.selectedCurrency)
        }
        cell.setUp(fee: fee)
        return cell
    }

}

extension SelectFeeViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        if case .finalFee(let fee, let rate) = selectedFee {
            delegate?.selected(fee: fee, rate: rate)
            navigationController?.dismiss(animated: true)
        }
    }

}

extension SelectFeeViewController: TitleTableViewCellDelegate {

    func didTouchTitle() {
        presentOverlay()
    }

}

extension SelectFeeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SelectFeePage

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
        self.makeViewTestable(tableView, using: .tableView)
        self.makeViewTestable(confirmButton, using: .button)
    }

}

extension SelectFeeViewController: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.cancel()
    }
}
