//
//  NewOpDescriptionView.swift
//  falcon
//
//  Created by Manu Herrera on 17/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol OpDescriptionTransitions: NewOperationTransitions {
    func didEnter(description: String, data: NewOperationStateAmount)
}

class NewOpDescriptionView: MUView, PresenterInstantior {

    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var placeholder: UILabel!
    @IBOutlet fileprivate weak var textViewBottomConstraint: NSLayoutConstraint!

    private let data: NewOperationStateAmount

    weak var delegate: NewOpViewDelegate?
    weak var transitionsDelegate: OpDescriptionTransitions?
    fileprivate lazy var presenter = instancePresenter(NewOpDescriptionPresenter.init, delegate: self, state: data)

    init(data: NewOpData.Description,
         delegate: NewOpViewDelegate?,
         transitionsDelegate: OpDescriptionTransitions?) {
        self.data = data
        self.delegate = delegate
        self.transitionsDelegate = transitionsDelegate

        super.init(frame: .zero)

        if !data.description.isEmpty {
            textView.text = data.description
        }

        presenter.validityCheck(textView.text ?? "")

        placeholder.isHidden = !textView.text.isEmpty
        delegate?.update(buttonText: L10n.NewOpDescriptionView.s1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                _ = self.textView.becomeFirstResponder()
            }
        }
    }

    override func setUp() {
        super.setUp()

        setUpPlaceholder()
        setUpTextView()

        makeViewTestable()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            presenter.tearDown()
        } else {
            presenter.setUp()
        }
    }

    func setUpTextView() {
        textView.tintColor = Asset.Colors.muunBlue.color
        textView.textColor = Asset.Colors.title.color
        textView.font = Constant.Fonts.system(size: .h1)
        textView.text = ""
        textView.textContainerInset = .zero
    }

    func setUpPlaceholder() {
        placeholder.textColor = Asset.Colors.muunGrayLight.color
        placeholder.font = Constant.Fonts.system(size: .h1)
        placeholder.text = L10n.NewOpDescriptionView.s2
        placeholder.backgroundColor = .clear
    }

    func setBottomSpacing(isDisplayingTimer: Bool) {
        if isDisplayingTimer {
            textViewBottomConstraint.constant = 24
        } else {
            textViewBottomConstraint.constant = 0
        }
    }
}

extension NewOpDescriptionView: NewOperationChildView {

    var willDisplayKeyboard: Bool {
        return true
    }

}

extension NewOpDescriptionView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {

        if let text = textView.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)
            placeholder.isHidden = !updatedText.isEmpty
            presenter.validityCheck(updatedText)
        }

        return true
    }

}

extension NewOpDescriptionView: NewOperationChildViewDelegate {

    func pushNextState() {
        transitionsDelegate?.didEnter(description: textView.text, data: data)
    }

}

extension NewOpDescriptionView: NewOpDescriptionPresenterDelegate {

    func userDidChangeDescription(_ isValid: Bool) {
        delegate?.readyForNextState(isValid, error: nil)
    }

}

extension NewOpDescriptionView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp.DescriptionView

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(textView, using: .input)
    }
}
