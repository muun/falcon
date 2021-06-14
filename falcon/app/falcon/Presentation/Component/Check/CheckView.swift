//
//  CheckView.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol CheckViewDelegate: AnyObject {
    func onCheckChanged(checked: Bool)
}

@IBDesignable
class CheckView: MUView {

    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var checkImageView: UIImageView!

    weak var delegate: CheckViewDelegate?
    fileprivate var checkStatus: Bool = false

    public var labelText: String {
        get { return mainLabel.text ?? "" }
        set { mainLabel.text = newValue }
    }

    public var isChecked: Bool {
        get { return checkStatus }
        set { setChecked(checked: newValue) }
    }

    override func setUp() {
        setUpCheckBox()
        setUpLabel()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: .touched))

        makeViewTestable()
    }

    fileprivate func setUpCheckBox() {
        checkButton.backgroundColor = UIColor.clear
        checkButton.layer.borderWidth = 1
        checkButton.layer.borderColor = Asset.Colors.muunGrayLight.color.cgColor
        checkButton.layer.cornerRadius = 4

        checkImageView.layer.cornerRadius = 4
        checkImageView.image = nil
    }

    fileprivate func setUpLabel() {
        mainLabel.textColor = Asset.Colors.muunGrayDark.color
        mainLabel.font = Constant.Fonts.description
    }

    fileprivate func setChecked(checked: Bool) {
        checkStatus = checked

        let color = checked
            ? Asset.Colors.muunBlue.color
            : UIColor.clear
        checkButton.backgroundColor = color

        let image = checked
            ? Asset.Assets.tick.image
            : nil
        checkImageView.image = image
        checkImageView.tintColor = .white

        checkButton.layer.borderWidth = checked ? 0 : 1

        delegate?.onCheckChanged(checked: checkStatus)
    }

    @IBAction fileprivate func touched(_ sender: Any) {
        checkStatus.toggle()

        setChecked(checked: checkStatus)
    }

}

fileprivate extension Selector {

    static let touched = #selector(CheckView.touched)

}

extension CheckView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.CheckViewPage

    func makeViewTestable() {
        // We expose no elements
    }
}
