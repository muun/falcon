//
//  ScrollViewTopFadeMask.swift
//  falcon
//
//  Created by Federico Jordán on 20/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// Masks a scroll view with a vertical gradient so scrolled content fades
/// out under the transparent nav bar instead of overlapping the title.
final class ScrollViewTopFadeMask {

    private enum Constants {
        static let fadeDistance: CGFloat = 40
    }

    private let gradientLayer = CAGradientLayer()
    private weak var scrollView: UIScrollView?
    private var offsetObservation: NSKeyValueObservation?

    func attach(to scrollView: UIScrollView) {
        self.scrollView = scrollView
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        scrollView.layer.mask = gradientLayer

        // bounds.origin is the contentOffset: re-pin the mask on every scroll
        // or it would scroll away with the content.
        offsetObservation = scrollView.observe(\.contentOffset) { [weak self] _, _ in
            self?.updateMask()
        }
        updateMask()
    }

    /// Call from viewDidLayoutSubviews too: safe-area changes don't fire the
    /// contentOffset observation.
    func updateMask() {
        guard let scrollView = scrollView else { return }
        let bounds = scrollView.bounds
        guard bounds.height > 0 else { return }

        // The band rests above the bar's bottom edge (nothing faded at rest)
        // and slides below it as content scrolls under, so anything behind
        // the bar ends up fully transparent.
        let barBottom = scrollView.safeAreaInsets.top
        let scrolledUnderBar = bounds.origin.y + scrollView.adjustedContentInset.top
        let progress = min(1, max(0, scrolledUnderBar / Constants.fadeDistance))
        let fadeStart = max(0, barBottom - Constants.fadeDistance * (1 - progress))
        let fadeEnd = fadeStart + Constants.fadeDistance

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        gradientLayer.locations = [
            NSNumber(value: Double(fadeStart / bounds.height)),
            NSNumber(value: Double(fadeEnd / bounds.height))
        ]
        CATransaction.commit()
    }

    deinit {
        offsetObservation?.invalidate()
    }
}
