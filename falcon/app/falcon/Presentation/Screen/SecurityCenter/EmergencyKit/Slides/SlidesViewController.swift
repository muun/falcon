//
//  SlidesViewController.swift
//  falcon
//
//  Created by Manu Herrera on 16/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class SlidesViewController: MUViewController {

    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var pageControl: UIPageControl!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var hintLabel: UILabel!

    fileprivate var stepNumber: Int = 0
    fileprivate let configuration: SlidesViewConfiguration
    fileprivate var needsAnimation = true

    override var screenLoggingName: String {
        return configuration.screenEvent
    }

    override func customLoggingParameters() -> [String: Any]? {
        return ["step": stepNumber]
    }

    init(configuration: SlidesViewConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        preconditionFailure()
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
        if needsAnimation {
            needsAnimation = false

            scrollView.animate(direction: .topToBottom, duration: .short)
            pageControl.animate(direction: .topToBottom, duration: .short)
            hintLabel.animate(direction: .topToBottom, duration: .short)
        }
    }

    fileprivate func setUpView() {
        setUpButton()
        setUpHintLabel()
        setUpScrollView()
    }

    fileprivate func setUpNavigation() {
        if navigationIsBeingPresented() {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: Constant.Images.close,
                style: .plain,
                target: self,
                action: .abort
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: Constant.Images.back,
                style: .plain,
                target: self,
                action: .abort
            )
        }

        if let title = configuration.title {
            self.title = title
        } else {
            navigationController?.hideSeparator()
        }
    }

    private func setUpScrollView() {
        scrollView.delegate = self

        let slides = createSlides()
        let slidesStack = UIStackView()
        slidesStack.translatesAutoresizingMaskIntoConstraints = false
        slidesStack.axis = .horizontal
        slidesStack.spacing = 0
        slidesStack.distribution = .fillEqually
        slidesStack.alignment = .fill

        scrollView.addSubview(slidesStack)
        NSLayoutConstraint.activate([
            slidesStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            slidesStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            slidesStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            slidesStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            slidesStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            slidesStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: CGFloat(slides.count))
        ])

        for slide in slides {
            slidesStack.addArrangedSubview(slide)
        }

        setUpPageControl(slideCount: slides.count)
    }

    private func setUpPageControl(slideCount: Int) {
        pageControl.numberOfPages = slideCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = Asset.Colors.blueDisabled.color
        pageControl.currentPageIndicatorTintColor = Asset.Colors.muunBlue.color
        view.bringSubviewToFront(pageControl)
    }

    private func setUpButton() {
        buttonView.isEnabled = true
        buttonView.buttonText = configuration.finish
        buttonView.delegate = self
        buttonView.alpha = 0
    }

    private func setUpHintLabel() {
        hintLabel.textColor = Asset.Colors.muunGrayDark.color
        hintLabel.font = Constant.Fonts.italic(size: .desc)
        hintLabel.text = L10n.SlidesViewController.swipe
        hintLabel.alpha = 0
    }

    private func createSlides() -> [SlideView] {

        return configuration.slides.map { slide in
            let view = SlideView()
            view.setUp(
                image: slide.image.image,
                title: slide.title,
                description: slide.description.attributedForDescription(alignment: .center)
            )
            return view
        }
    }

    @objc func abort() {
        configuration.abortTapped(self)
    }

}

extension SlidesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x/view.frame.width))
        pageControl.currentPage = pageIndex

        if pageIndex == configuration.slides.count - 1 && buttonView.alpha == 0 {
            hintLabel.isHidden = true
            buttonView.animate(direction: .bottomToTop, duration: .short)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stepNumber = pageControl.currentPage
        logScreen() // This will update the step number param
    }

}

extension SlidesViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        configuration.finishTapped(self)
    }

}

extension SlidesViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.Slides

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
        self.makeViewTestable(buttonView, using: .continueButton)
    }

}

fileprivate extension Selector {

    static let abort =  #selector(SlidesViewController.abort)

}
