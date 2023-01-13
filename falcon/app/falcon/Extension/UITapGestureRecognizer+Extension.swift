//
//  UITapGestureRecognizer+Extension.swift
//  Muun
//
//  Created by Lucas Serruya on 23/12/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit

// Thanks to https://www.codementor.io/@leoiphonedev
// /swift-tutorial-how-to-perform-action-when-user-click-on-particular-text-of-uilabel-xm9tvtviw
extension UITapGestureRecognizer {
    /// hasUserTapped does not works on simulators.
    func hasUserTapped(text: String, in label: UILabel, labelText: String) -> Bool {
        let targetRange = (labelText as NSString).range(of: text)

        let layoutManager = NSLayoutManager()
        let textContainer = createTextContainer(layoutManager: layoutManager,
                                                label: label)
        // layoutManager needs to be added into a textStorage
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        textStorage.addLayoutManager(layoutManager)

        let locationOfTouchInTextContainer = getTouchedPoint(label: label,
                                                             layoutManager: layoutManager,
                                                             textContainer: textContainer)

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

    private func createTextContainer(layoutManager: NSLayoutManager,
                                     label: UILabel) -> NSTextContainer {
        let textContainer = NSTextContainer(size: CGSize.zero)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        return textContainer
    }

    private func getTouchedPoint(label: UILabel,
                                 layoutManager: NSLayoutManager,
                                 textContainer: NSTextContainer) -> CGPoint {
        let locationOfTouchInLabel = self.location(in: label)
        // this is the frame of the written text without the font's frame.
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (label.bounds.size.width - textBoundingBox.size.width)
                                          * 0.5 - textBoundingBox.origin.x,
                                          y: (label.bounds.size.height - textBoundingBox.size.height)
                                          * 0.5 - textBoundingBox.origin.y)
        return CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                       y: locationOfTouchInLabel.y - textContainerOffset.y)
    }
}
