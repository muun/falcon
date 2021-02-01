//
//  KeyboardViewPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class KeyboardViewPage: UIElementPage<UIElements.CustomViews.KeyboardViewPage> {

    private lazy var number1 = self.otherElement(.number1)
    private lazy var number2 = self.otherElement(.number2)
    private lazy var number3 = self.otherElement(.number3)
    private lazy var number4 = self.otherElement(.number4)
    private lazy var number5 = self.otherElement(.number5)
    private lazy var number6 = self.otherElement(.number6)
    private lazy var number7 = self.otherElement(.number7)
    private lazy var number8 = self.otherElement(.number8)
    private lazy var number9 = self.otherElement(.number9)
    private lazy var number0 = self.otherElement(.number0)
    private lazy var erase = self.otherElement(.erase)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    // Just too many cases
    // swiftlint:disable cyclomatic_complexity
    func tap(number: Int) {
        switch number {
        case 1:
            number1.tap()
        case 2:
            number2.tap()
        case 3:
            number3.tap()
        case 4:
            number4.tap()
        case 5:
            number5.tap()
        case 6:
            number6.tap()
        case 7:
            number7.tap()
        case 8:
            number8.tap()
        case 9:
            number9.tap()
        case 0:
            number0.tap()
        default:
            number1.tap()
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func tapErase() {
        erase.tap()
    }

}
