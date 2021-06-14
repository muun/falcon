//
//  RecoveryView.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

protocol RecoveryViewDelegate: AnyObject {
    func recoveryViewDidChange(_ recoveryView: RecoveryView, code: RecoveryCode?)
}

extension RecoveryViewDelegate {
    func recoveryViewDidChange(_ recoveryView: RecoveryView, code: RecoveryCode?) {
        // In most cases we don't want do anything with this method
    }
}

@IBDesignable
class RecoveryView: MUView {

    enum Style {
        case display
        case editable
    }

    @IBOutlet private var textfields: [DeletableTextField]!
    @IBOutlet private weak var recoveryCardView: UIView!
    @IBOutlet private var bottomLines: [UIView]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    weak var delegate: RecoveryViewDelegate?
    private let separator = "-"

    public var isLoading: Bool {
        get { return !activityIndicator.isHidden }
        set { setLoading(loading: newValue) }
    }

    public var style: Style = .editable {
        didSet {
            setUp()
        }
    }

    public var presetValues: [String] = [] {
        didSet {
            setUp()
        }
    }

    override func setUp() {
        setUpCard()
        setUpLines()
        setUpTextfields()
        setUpActivityIndicator()

        makeViewTestable()
    }

    private func setUpCard() {
        recoveryCardView.layer.borderColor = Asset.Colors.muunGrayLight.color.cgColor
        recoveryCardView.layer.borderWidth = 1
        recoveryCardView.layer.cornerRadius = 8
    }

    private func setUpTextfields() {

        let firstEmptyIndex = presetValues.firstIndex(of: "") ?? presetValues.count

        for textfield in textfields {

            let index = textfield.tag

            textfield.attributedPlaceholder = NSAttributedString(
                string: "XXXX",
                attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.muunGrayLight.color]
            )
            textfield.adjustsFontSizeToFitWidth = false
            textfield.textAlignment = .center
            textfield.delegate = self
            textfield.deleteDelegate = self
            textfield.autocorrectionType = .no

            let hasPreset = presetValues.count > index && !presetValues[index].isEmpty
            if hasPreset {
                textfield.text = presetValues[index]
                textfield.isUserInteractionEnabled = false
            } else {
                textfield.text = ""
                textfield.isUserInteractionEnabled = true
            }

            switch style {
            case .display:
                textfield.textColor = Asset.Colors.title.color
            case .editable:
                textfield.textColor = hasPreset ? Asset.Colors.muunDisabled.color : Asset.Colors.title.color
            }

            if index == firstEmptyIndex {
                textfield.becomeFirstResponder()
            } else {
                textfield.resignFirstResponder()
            }
        }
    }

    private func setUpLines() {

        for (index, line) in bottomLines.enumerated() {

            let hasPreset = presetValues.count > index && !presetValues[index].isEmpty

            switch style {
            case .editable:
                line.isHidden = hasPreset
                line.backgroundColor = Asset.Colors.muunGrayLight.color
            case .display:
                line.isHidden = true
            }

        }
    }

    fileprivate func setUpActivityIndicator() {
        activityIndicator.color = Asset.Colors.muunBlue.color
    }

    fileprivate func setLoading(loading: Bool) {
        activityIndicator.isHidden = !loading

        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension RecoveryView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let currentTag = textField.tag
        bottomLines[currentTag].backgroundColor = Asset.Colors.muunBlue.color
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let currentTag = textField.tag
        bottomLines[currentTag].backgroundColor = Asset.Colors.muunGrayLight.color
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        for char in string.uppercased() {

            guard RecoveryCode.alphabet.contains(String(char)) else {
                return false
            }
        }

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string.uppercased())
            let currentTag = textField.tag

            if range.lowerBound == 0 && range.upperBound == 0 && updatedText.isEmpty {

                // This is a delete on an empty string, so jump back
                selectPreviousField(from: currentTag)

            } else if updatedText.count >= RecoveryCode.segmentLength {

                // We might overflow if we accept this change
                // This should only happen if the user pastes his full code, and we won't support that

                // If there's space left in this field, fill it
                if text.count < RecoveryCode.segmentLength {
                    textField.text = String(updatedText.prefix(RecoveryCode.segmentLength))
                }

                // We filled this segment
                selectNextField(from: currentTag)

            } else {

                // We handle this manually to make sure letters are uppercased
                textField.text = updatedText
            }

            delegate?.recoveryViewDidChange(self, code: getFinalRecoveryCode())
        }

        return false
    }

    private func selectNextField(from field: Int) {
        var next = field + 1
        // Skip pre set values
        while presetValues.count > next && !presetValues[next].isEmpty {
            next += 1
        }

        if next < RecoveryCode.segmentCount {
            textfields[next].becomeFirstResponder()
        }
    }

    private func selectPreviousField(from field: Int) {
        var previous = field - 1
        // Skip pre set values
        while previous >= 0 && presetValues.count > previous && !presetValues[previous].isEmpty {
            previous -= 1
        }

        if previous < RecoveryCode.segmentCount && previous >= 0 {

            textfields[previous].becomeFirstResponder()
        }
    }

    private func getFinalRecoveryCode() -> RecoveryCode? {
        var segments = [String]()

        for t in textfields {
            if let segment = t.text {
                segments.append(segment)
            }
        }

        return try? RecoveryCode(segments: segments)
    }

}

extension RecoveryView: DeletableTextFieldDelegate {
    func textFieldDidDelete(_ textField: DeletableTextField) {
        if let text = textField.text, text == "" {
            selectPreviousField(from: textField.tag)
        }
    }
}

extension RecoveryView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.RecoveryViewPage

    func makeViewTestable() {
        makeViewTestable(textfields[0], using: .segment1)
        makeViewTestable(textfields[1], using: .segment2)
        makeViewTestable(textfields[2], using: .segment3)
        makeViewTestable(textfields[3], using: .segment4)
        makeViewTestable(textfields[4], using: .segment5)
        makeViewTestable(textfields[5], using: .segment6)
        makeViewTestable(textfields[6], using: .segment7)
        makeViewTestable(textfields[7], using: .segment8)
    }
}
