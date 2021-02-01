//
//  EmergencyKitSlidesViewController.swift
//  falcon
//
//  Created by Manu Herrera on 16/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class EmergencyKitSlidesViewController: MUViewController {

    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var pageControl: UIPageControl!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var hintLabel: UILabel!

    fileprivate var stepNumber: Int = 0

    override var screenLoggingName: String {
        return "emergency_kit_slides"
    }

    override func customLoggingParameters() -> [String: Any]? {
        return ["step": stepNumber]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setUpNavigation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // This call need to be here because in the view did load method the scroll view doesnt calculate correctly
        // the width of the view.
        setUpScrollView()
        showHintLabel()
    }

    fileprivate func setUpView() {
        setUpButton()
        setUpHintLabel()
    }

    fileprivate func setUpNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Constant.Images.back,
            style: .plain,
            target: self,
            action: .abortEmergencyKitSetup
        )

        title = L10n.EmergencyKitSlidesViewController.s1
    }

    private func setUpScrollView() {
        scrollView.delegate = self

        let slides = createSlides()
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count),
                                        height: scrollView.frame.height)

        for (i, slide) in slides.enumerated() {
            slide.frame = CGRect(
                x: view.frame.width * CGFloat(i),
                y: 0,
                width: view.frame.width,
                height: scrollView.frame.height
            )
            scrollView.addSubview(slide)
        }

        setUpPageControl(slideCount: slides.count)
        scrollView.animate(direction: .topToBottom, duration: .short)
    }

    private func setUpPageControl(slideCount: Int) {
        pageControl.numberOfPages = slideCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = Asset.Colors.muunGrayLight.color
        pageControl.currentPageIndicatorTintColor = Asset.Colors.muunBlue.color
        pageControl.animate(direction: .topToBottom, duration: .short)
        view.bringSubviewToFront(pageControl)
    }

    private func setUpButton() {
        buttonView.isEnabled = true
        buttonView.buttonText = L10n.EmergencyKitSlidesViewController.s2
        buttonView.delegate = self
        buttonView.alpha = 0
    }

    private func setUpHintLabel() {
        hintLabel.textColor = Asset.Colors.muunGrayDark.color
        hintLabel.font = Constant.Fonts.italic(size: .desc)
        hintLabel.text = L10n.EmergencyKitSlidesViewController.s3
        hintLabel.alpha = 0
    }

    private func showHintLabel() {
        hintLabel.animate(direction: .rightToLeft, duration: .medium, delay: .medium)
    }

    private func createSlides() -> [EmergencyKitSlide] {

        let desc1 = L10n.EmergencyKitSlidesViewController.s12.attributedForDescription(alignment: .center)

        let slide1 = EmergencyKitSlide()
        slide1.setUp(image: Asset.Assets.emergencyKit1.image,
                     title: L10n.EmergencyKitSlidesViewController.s4,
                     description: desc1)

        let desc2 = L10n.EmergencyKitSlidesViewController.s5.attributedForDescription(alignment: .center)

        let slide2 = EmergencyKitSlide()
        slide2.setUp(image: Asset.Assets.emergencyKit2.image,
                     title: L10n.EmergencyKitSlidesViewController.s6,
                     description: desc2)

        let desc3 = L10n.EmergencyKitSlidesViewController.s13.attributedForDescription(alignment: .center)

        let slide3 = EmergencyKitSlide()
        slide3.setUp(image: Asset.Assets.emergencyKit3.image,
                     title: L10n.EmergencyKitSlidesViewController.s7,
                     description: desc3)

        return [slide1, slide2, slide3]
    }

    @objc func abortSetup() {
        let desc = L10n.EmergencyKitSlidesViewController.s8
        let alert = UIAlertController(
            title: L10n.EmergencyKitSlidesViewController.s9,
            message: desc,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.EmergencyKitSlidesViewController.s10, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.EmergencyKitSlidesViewController.s11, style: .destructive, handler: { _ in
            self.logEvent("emergency_kit_aborted")
            self.navigationController!.popTo(type: SecurityCenterViewController.self)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.navigationController!.present(alert, animated: true)
    }

}

extension EmergencyKitSlidesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)

        if pageIndex == 2 && buttonView.alpha == 0 {
            hintLabel.isHidden = true
            buttonView.animate(direction: .bottomToTop, duration: .short)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stepNumber = pageControl.currentPage
        logScreen() // This will update the step number param
    }

}

extension EmergencyKitSlidesViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        navigationController!.pushViewController(ShareEmergencyKitViewController(), animated: true)
    }

}

extension EmergencyKitSlidesViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.Slides

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
        self.makeViewTestable(buttonView, using: .continueButton)
    }

}

fileprivate extension Selector {

    static let abortEmergencyKitSetup =  #selector(EmergencyKitSlidesViewController.abortSetup)

}
