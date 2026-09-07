//
//  OrderSummaryViewController.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class OrderSummaryViewController: MUViewController {

    private enum Constants {
        static let haloHeightPadding: CGFloat = 40
        static let ctaButtonHeight: CGFloat = 50
        static let ctaButtonCornerRadius: CGFloat = 8
        static let navTitleFadeDistance: CGFloat = 20
    }

    private var presenter: OrderSummaryPresenter<OrderSummaryViewController>!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let haloView = SecurityCardGradientHaloView()
    private let summaryView = OrderSummaryView()
    private let ctaButton = UIButton(type: .system)
    private let topFadeMask = ScrollViewTopFadeMask()
    private let navTitleLabel = UILabel()
    private var haloHeightConstraint: NSLayoutConstraint!
    private var contentMinHeightConstraint: NSLayoutConstraint!
    private var hasSetupPill = false
    private weak var providerPill: SecurityCardProviderPillView?
    private let pillTapFeedback = UIImpactFeedbackGenerator(style: .medium)

    override var screenLoggingName: String { "security_cards_order_summary" }

    init(provider: SecurityCardProvider, shippingValues: ShippingFormValues) {
        super.init(nibName: nil, bundle: nil)
        presenter = OrderSummaryPresenter(
            delegate: self,
            provider: provider,
            shippingValues: shippingValues
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // The title lives in the content header; the nav bar copy fades in
        // once the header scrolls under the bar.
        navigationItem.largeTitleDisplayMode = .never
        summaryView.delegate = self
        setupNavTitle()
        setupHaloView()
        setupScrollView()
        setupCTAButton()
        setupContent()
        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalSafeAreaInsets = .zero
        setupTransparentNavBar()
        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
        restoreNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        haloHeightConstraint.constant = view.bounds.width / 2 + Constants.haloHeightPadding
        topFadeMask.updateMask()
        updateNavTitleAlpha()
        updateContentMinHeight()
    }

    /// Auto Layout can't reference adjustedContentInset (nav bar), so the
    /// visible-height correction is applied by hand on every layout pass.
    private func updateContentMinHeight() {
        let insets = scrollView.adjustedContentInset
        let constant = -(insets.top + insets.bottom)
        if contentMinHeightConstraint.constant != constant {
            contentMinHeightConstraint.constant = constant
        }
    }

    /// Fades the nav bar title in once the header title has scrolled under
    /// the bar, so the two are never visible at the same time.
    private func updateNavTitleAlpha() {
        guard let titleFrame = summaryView.headerTitleFrame(in: view),
              titleFrame.height > 0 else { return }
        let barBottom = view.safeAreaInsets.top
        let progress = (barBottom - titleFrame.maxY) / Constants.navTitleFadeDistance
        navTitleLabel.alpha = min(1, max(0, progress))
    }

    // MARK: - Layout

    private func setupHaloView() {
        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.isUserInteractionEnabled = false
        view.addSubview(haloView)

        haloHeightConstraint = haloView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            haloView.topAnchor.constraint(equalTo: view.topAnchor),
            haloView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            haloView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            haloHeightConstraint
        ])
    }

    private func setupNavTitle() {
        navTitleLabel.text = L10n.OrderSummaryViewController.title
        navTitleLabel.font = Constant.Fonts.system(size: .opTitle, weight: .semibold)
        navTitleLabel.textColor = MuunTheme.Color.Text.heading
        navTitleLabel.alpha = 0

        // Wrapped in a container: the nav bar animates the titleView's own
        // alpha during push transitions.
        let container = UIView()
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            navTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            navTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            navTitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        navigationItem.titleView = container
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        topFadeMask.attach(to: scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Fills the viewport on tall screens so the CTA anchors to the bottom;
        // taller-than-viewport content scrolls as usual. The constant discounts
        // the scroll insets and is kept in sync in updateContentMinHeight().
        contentMinHeightConstraint = contentView.heightAnchor.constraint(
            greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor
        )

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentMinHeightConstraint
        ])
    }

    private func setupContent() {
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryView)
        contentView.addSubview(ctaButton)

        let preferredCTATopSpacing = ctaButton.topAnchor.constraint(
            equalTo: summaryView.bottomAnchor,
            constant: MuunTheme.Spacing.xl3
        )
        preferredCTATopSpacing.priority = .defaultLow

        NSLayoutConstraint.activate([
            summaryView.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            summaryView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            summaryView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),

            // The CTA scrolls with the content and sits below everything. The
            // gap above it absorbs any extra height when the content stretches
            // to fill the viewport, pushing the button down.
            ctaButton.topAnchor.constraint(
                greaterThanOrEqualTo: summaryView.bottomAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            preferredCTATopSpacing,
            ctaButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            ctaButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            ctaButton.heightAnchor.constraint(equalToConstant: Constants.ctaButtonHeight),
            ctaButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    private func setupCTAButton() {
        ctaButton.titleLabel?.font = MuunTheme.Font.Body.mdStrong
        ctaButton.setTitle(L10n.OrderSummaryViewController.goToPayment, for: .normal)
        ctaButton.setTitleColor(MuunTheme.Color.Text.onActionPrimary, for: .normal)
        ctaButton.layer.cornerRadius = Constants.ctaButtonCornerRadius
        ctaButton.addTarget(self, action: #selector(didTapCTA), for: .touchUpInside)
    }

    private func setupRightPill(url: URL) {
        guard !hasSetupPill else { return }
        hasSetupPill = true
        let pill = SecurityCardProviderPillView(url: url)
        pill.delegate = self
        providerPill = pill
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pill)
        pillTapFeedback.prepare()
    }

    // MARK: - Actions

    @objc private func didTapCTA() {
        let sheet = PayWithMuunViewController(
            provider: presenter.provider,
            orderTotal: presenter.orderTotal
        )
        present(sheet, animated: true)
    }
}

// MARK: - OrderSummaryPresenterDelegate

extension OrderSummaryViewController: OrderSummaryPresenterDelegate {

    func onLoad(_ viewModel: OrderSummaryViewModel) {
        haloView.configure(
            haloColor: viewModel.providerColor,
            backgroundColor: MuunTheme.Color.Surface.background
        )
        ctaButton.backgroundColor = viewModel.providerColor
        summaryView.configure(with: viewModel)
        if let url = viewModel.providerUrl {
            setupRightPill(url: url)
        }
    }

    func onChange(
        selectedSpeed: DeliveryOption.Speed,
        breakdown: OrderSummaryViewModel.BreakdownViewModel
    ) {
        summaryView.updateSelection(selectedSpeed)
        summaryView.configureBreakdown(breakdown)
    }
}

// MARK: - OrderSummaryViewDelegate

extension OrderSummaryViewController: OrderSummaryViewDelegate {

    func didChangeDeliverySpeed(_ speed: DeliveryOption.Speed) {
        presenter.didChangeDeliverySpeed(speed)
    }

    func didTapCurrencyToggle() {
        presenter.didTapCurrencyToggle()
    }
}

// MARK: - UIScrollViewDelegate

extension OrderSummaryViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavTitleAlpha()
    }
}

// MARK: - SecurityCardProviderPillViewDelegate

extension OrderSummaryViewController: SecurityCardProviderPillViewDelegate {

    func securityCardProviderPillViewDidTap(_ view: SecurityCardProviderPillView) {
        guard let providerURL = presenter.providerURL, let pill = providerPill else { return }
        pillTapFeedback.impactOccurred()
        pillTapFeedback.prepare()
        let modal = SecurityCardProviderInfoModal(providerURL: providerURL, sourceView: pill)
        present(modal, animated: true)
    }
}
