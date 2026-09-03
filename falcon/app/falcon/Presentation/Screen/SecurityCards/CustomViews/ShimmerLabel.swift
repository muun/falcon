//
//  ShimmerLabel.swift
//  falcon
//
//  Created by Federico Jordán on 07/08/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// A label filled with a base color whose text is swept once by a gradient
/// highlight. Tapping it replays the sweep.
final class ShimmerLabel: UIView {

    private enum Constants {
        static let sweepDuration: CFTimeInterval = 1.4
        /// The gradient spans 3x the label width; the sweep travels ±25% of
        /// it, so the highlight band starts and ends just off the text.
        static let sweepTravelFactor: CGFloat = 0.75
        static let gradientWidthMultiplier: CGFloat = 3
        /// Highlight band edges within the gradient, centered at 0.5.
        static let bandLocations: [NSNumber] = [0.46, 0.5, 0.54]
        /// The prototype's CSS `linear-gradient(100deg, ...)`: 10° below horizontal.
        static let tiltDegrees: CGFloat = 10
        static let sweepAnimationKey = "shimmerSweep"
    }

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            accessibilityLabel = newValue
            invalidateIntrinsicContentSize()
        }
    }

    var font: UIFont {
        get { label.font }
        set {
            label.font = newValue
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }

    private let baseColor: UIColor
    private let highlightColor: UIColor
    private let label = UILabel()
    private let gradientLayer = CAGradientLayer()
    private let tapFeedback = UINotificationFeedbackGenerator()
    private var hasPlayedInitialSweep = false

    init(baseColor: UIColor, highlightColor: UIColor) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        super.init(frame: .zero)
        setupGradient()
        setupMask()
        setupTapToReplay()
        setupAccessibility()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        // The layer carries a rotation + translation transform, so its
        // geometry must be set via bounds/position — the frame setter
        // compensates for the current transform and would re-center the
        // highlight over the text.
        withoutImplicitAnimations {
            let gradientWidth = bounds.width * Constants.gradientWidthMultiplier
            // Tall enough that the rotated layer still covers the text at
            // every sweep offset.
            let gradientHeight = bounds
                .height + gradientWidth * tan(Constants.tiltDegrees * .pi / 180)
            gradientLayer.bounds = CGRect(x: 0, y: 0, width: gradientWidth, height: gradientHeight)
            gradientLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            // Rest with the highlight band off the text, so only baseColor
            // shows outside the sweep animation: off-left before the first
            // sweep, off-right after it (the prototype's fillMode: forwards).
            let restingOffset = hasPlayedInitialSweep ? sweepTravelDistance : -sweepTravelDistance
            gradientLayer.transform = sweepTransform(offsetX: restingOffset)
        }
        playInitialSweepIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyGradientColors()
    }

    private var sweepTravelDistance: CGFloat {
        bounds.width * Constants.sweepTravelFactor
    }

    /// The gradient runs purely horizontal in the layer's unit space.
    /// CAGradientLayer computes the band's orientation in unit space *before*
    /// stretching to the layer's (very wide) bounds, so any non-axis-aligned
    /// axis gets badly skewed. The prototype's 10° tilt is applied by rotating
    /// the whole layer instead — see `sweepTransform(offsetX:)`.
    private func setupGradient() {
        gradientLayer.locations = Constants.bandLocations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        applyGradientColors()
        layer.addSublayer(gradientLayer)
    }

    /// Rotates the layer 10° (the prototype's `linear-gradient(100deg)`) and
    /// then translates it in screen space: the translation lives in m41/m42,
    /// which CA applies after the linear part and exposes as the
    /// `transform.translation.x` key path animated by the sweep.
    private func sweepTransform(offsetX: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(Constants.tiltDegrees * .pi / 180, 0, 0, 1)
        transform.m41 = offsetX
        return transform
    }

    private func applyGradientColors() {
        let base = baseColor.resolvedColor(with: traitCollection).cgColor
        let highlight = highlightColor.resolvedColor(with: traitCollection).cgColor
        gradientLayer.colors = [base, highlight, base]
    }

    private func setupMask() {
        mask = label
    }

    private func setupTapToReplay() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    private func playInitialSweepIfNeeded() {
        guard !hasPlayedInitialSweep, bounds.width > 0 else { return }
        hasPlayedInitialSweep = true
        playSweep()
    }

    private func playSweep() {
        let sweep = CABasicAnimation(keyPath: "transform.translation.x")
        sweep.fromValue = -sweepTravelDistance
        sweep.toValue = sweepTravelDistance
        sweep.duration = Constants.sweepDuration
        sweep.timingFunction = CAMediaTimingFunction(name: .linear)
        // Land on the sweep's end position when the animation is removed.
        withoutImplicitAnimations {
            gradientLayer.transform = sweepTransform(offsetX: sweepTravelDistance)
        }
        gradientLayer.removeAnimation(forKey: Constants.sweepAnimationKey)
        gradientLayer.add(sweep, forKey: Constants.sweepAnimationKey)
    }

    /// Standalone sublayers implicitly animate every property change (0.25s),
    /// which would drag the highlight band around visibly between states.
    private func withoutImplicitAnimations(_ changes: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        changes()
        CATransaction.commit()
    }

    @objc
    private func didTap() {
        tapFeedback.notificationOccurred(.success)
        playSweep()
    }
}
