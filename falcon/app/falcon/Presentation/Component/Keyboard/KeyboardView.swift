//
//  KeyboardView.swift
//  falcon
//
//  Created by Manu Herrera on 22/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func onNumberPressed(number: String)
    func onErasePressed()
}

@IBDesignable
class KeyboardView: MUView {

    @IBOutlet private weak var eraseView: UIView!
    @IBOutlet private weak var eraseImageView: UIImageView!

    @IBOutlet private var numberViews: [UIView]!
    @IBOutlet private var numberLabels: [UILabel]!
    @IBOutlet private var lettersLabels: [UILabel]!

    weak var delegate: KeyboardViewDelegate?
    private let notification = UINotificationFeedbackGenerator() // This is used to notify success or error to the user

    public var isEraseEnabled: Bool {
        get { return eraseImageView.isUserInteractionEnabled }
        set { setEraseEnabled(newValue) }
    }

    public var isEnabled: Bool {
        get { return self.isUserInteractionEnabled }
        set { setKeyboardEnabled(newValue) }
    }

    override func setUp() {
        setUpLabels()

        addNumberViewActions()
        addDeleteAction()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        for label in numberLabels {
            label.textColor = Asset.Colors.title.color
            label.font = Constant.Fonts.system(size: .h2)
        }

        for label in lettersLabels {
            label.textColor = Asset.Colors.title.color
            label.font = Constant.Fonts.system(size: .helper)
        }
    }

    fileprivate func addNumberViewActions() {
        for view in numberViews {
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: .keyboardViewTouched)
            )
        }
    }

    fileprivate func addDeleteAction() {
        eraseView.isUserInteractionEnabled = true
        eraseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .eraseViewTouched))
    }

    @objc fileprivate func viewTouched(withSender sender: AnyObject) {
        if let number = sender.view?.accessibilityLabel {
            notification.notificationOccurred(.warning)
            delegate?.onNumberPressed(number: number)
        }
    }

    @objc fileprivate func eraseViewTouched() {
        notification.notificationOccurred(.warning)
        delegate?.onErasePressed()
    }

    fileprivate func setEraseEnabled(_ isEnabled: Bool) {

        eraseImageView.isUserInteractionEnabled = isEnabled
        eraseView.isUserInteractionEnabled = isEnabled

        let nextAlphaValue: CGFloat = isEnabled
            ? 1.0
            : 0.25

        UIView.animate(withDuration: 0.2) {
            self.eraseImageView.alpha = nextAlphaValue
        }

    }

    fileprivate func setKeyboardEnabled(_ isEnabled: Bool) {

        self.isUserInteractionEnabled = isEnabled

        let nextAlphaValue: CGFloat = isEnabled
            ? 1.0
            : 0.25

        for view in numberViews {
            view.alpha = nextAlphaValue
        }

    }

}

extension KeyboardView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.KeyboardViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.numberViews[0], using: .number1)
        self.makeViewTestable(self.numberViews[1], using: .number2)
        self.makeViewTestable(self.numberViews[2], using: .number3)
        self.makeViewTestable(self.numberViews[3], using: .number4)
        self.makeViewTestable(self.numberViews[4], using: .number5)
        self.makeViewTestable(self.numberViews[5], using: .number6)
        self.makeViewTestable(self.numberViews[6], using: .number7)
        self.makeViewTestable(self.numberViews[7], using: .number8)
        self.makeViewTestable(self.numberViews[8], using: .number9)
        self.makeViewTestable(self.numberViews[9], using: .number0)
        self.makeViewTestable(self.eraseView, using: .erase)
    }

}

fileprivate extension Selector {

    static let keyboardViewTouched =
        #selector(KeyboardView.viewTouched(withSender:))

    static let eraseViewTouched =
        #selector(KeyboardView.eraseViewTouched)

}
