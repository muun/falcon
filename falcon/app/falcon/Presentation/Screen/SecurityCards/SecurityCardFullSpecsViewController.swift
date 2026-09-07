//
//  SecurityCardFullSpecsViewController.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardFullSpecsViewController: MUViewController {

    private enum Constants {
        static let haloHeightPadding = MuunTheme.Legacy.s40
    }

    private var presenter: SecurityCardFullSpecsPresenter<SecurityCardFullSpecsViewController>!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let haloView = SecurityCardGradientHaloView()
    private let measurementsView = SecurityCardMeasurementsView()
    private let sectionsStack = UIStackView()
    private let topFadeMask = ScrollViewTopFadeMask()

    override var screenLoggingName: String { "security_cards_full_specs" }

    init(provider: SecurityCardProvider, card: SecurityCard) {
        super.init(nibName: nil, bundle: nil)
        presenter = SecurityCardFullSpecsPresenter(
            delegate: self,
            provider: provider,
            card: card
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalSafeAreaInsets = .zero
        presenter.setUp()
        setupTransparentNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
        restoreNavBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHaloView()
        setupScrollView()
        setupMeasurementsView()
        setupSections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        measurementsView.animateIn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topFadeMask.updateMask()
    }

    // MARK: - Layout

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        view.addSubview(scrollView)
        topFadeMask.attach(to: scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHaloView() {
        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.isUserInteractionEnabled = false
        view.addSubview(haloView)

        let screenWidth = UIScreen.main.bounds.width
        let haloHeight = screenWidth / 2 + Constants.haloHeightPadding

        NSLayoutConstraint.activate([
            haloView.topAnchor.constraint(equalTo: view.topAnchor),
            haloView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            haloView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            haloView.heightAnchor.constraint(equalToConstant: haloHeight)
        ])
    }

    private func setupMeasurementsView() {
        measurementsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(measurementsView)
        NSLayoutConstraint.activate([
            measurementsView.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            measurementsView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            measurementsView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupSections() {
        sectionsStack.axis = .vertical
        sectionsStack.spacing = MuunTheme.Spacing.xl3
        sectionsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionsStack)

        NSLayoutConstraint.activate([
            sectionsStack.topAnchor.constraint(
                equalTo: measurementsView.bottomAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            sectionsStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            sectionsStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            sectionsStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    private func renderSections(_ sections: [SecurityCardSpecsListView.ViewModel]) {
        sectionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for section in sections {
            let listView = SecurityCardSpecsListView(delegate: self)
            listView.configure(viewModel: section)
            sectionsStack.addArrangedSubview(listView)
        }
    }
}

// MARK: - SecurityCardSpecsListViewDelegate

extension SecurityCardFullSpecsViewController: SecurityCardSpecsListViewDelegate {

    func didTapInfo(forItem item: SecurityCardSpecsListView.SpecItemViewModel) {
        guard let descriptionHTML = item.additionalHTMLData else { return }
        let infoVC = SecurityCardAdditionalInfoViewController(
            viewModel: .init(
                symbolName: item.symbol,
                title: item.label,
                descriptionHTML: descriptionHTML
            )
        )
        if let sheet = infoVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in infoVC.preferredContentSize.height }
                ]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.preferredCornerRadius = MuunTheme.Spacing.md
        }
        present(infoVC, animated: true)
    }
}

// MARK: - SecurityCardFullSpecsPresenterDelegate

extension SecurityCardFullSpecsViewController: SecurityCardFullSpecsPresenterDelegate {

    func update(viewModel: SecurityCardFullSpecsViewModel) {
        haloView.configure(
            haloColor: viewModel.providerColor,
            backgroundColor: MuunTheme.Color.Surface.background
        )
        measurementsView.configure(
            imageName: viewModel.imageName,
            heightMm: viewModel.heightMm,
            widthMm: viewModel.widthMm,
            color: viewModel.providerColor
        )
        renderSections(viewModel.sections)
    }
}

// MARK: - UIScrollViewDelegate

extension SecurityCardFullSpecsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let adjustedOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let translation = -max(0, adjustedOffset)
        haloView.transform = CGAffineTransform(translationX: 0, y: translation)
    }
}
