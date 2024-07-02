//
//  UIElement.swift
//  falcon
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol UIElement {
    var accessibilityIdentifier: String { get }
}

extension UIElement where Self: RawRepresentable {
    var accessibilityIdentifier: String {
        return "\(String(describing: type(of: self)))-\(rawValue)"
    }
}

// swiftlint:disable nesting type_body_length
enum UIElements {

    enum Pages {

        enum SignInEmailPage: String, UIElement {
            case root
            case continueView
            case textInputView
            case signInWithRC
        }

        enum SignInPasswordPage: String, UIElement {
            case root
            case continueView
            case textInputView
            case forgotPasswordButton
        }

        enum SignInWithRCPage: String, UIElement {
            case root
            case codeView
            case errorLabel
            case continueButton
        }

        enum VerifyEmailPage: String, UIElement {
            case root
        }

        enum PrimingEmailPage: String, UIElement {
            case root
            case next
            case skipEmail
        }

        enum SetEmailBackUpPage: String, UIElement {
            case root
            case continueView
            case textInputView
        }

        enum SetUpPasswordPage: String, UIElement {
            case root
            case continueView
            case firstTextInputView
            case secondTextInputView
        }

        enum FinishEmailSetupPage: String, UIElement {
            case root
            case firstCheck
            case secondCheck
            case continueButton
        }

        enum GetStartedPage: String, UIElement {
            case root
            case createWalletButton
            case recoverWalletButton
        }

        enum HomePage: String, UIElement {
            case root
            case recoveryCodeSetup
            case receive
            case send
            case balance
            case chevron
            case letsGo
        }

        enum TransactionListPage: String, UIElement {
            case root
            case tableView
        }

        enum LogOutPage: String, UIElement {
            case root
            case continueButton
        }

        enum PinPage: String, UIElement {
            case root
            case keyboardView
            case hintLabel
            case gcmTokenLabel
        }

        enum PrimingRecoveryCodePage: String, UIElement {
            case root
            case next
        }

        enum GenerateRecoveryCodePage: String, UIElement {
            case root
            case codeView
            case continueButton
        }

        enum VerifyRecoveryCodePage: String, UIElement {
            case root
            case codeView
            case errorLabel
            case continueButton
        }

        enum ConfirmRecoveryCodePage: String, UIElement {
            case root
            case firstCheck
            case secondCheck
            case thirdCheck
            case continueButton
        }

        enum RecoveryCodePage: String, UIElement {
            case root
            case codeView
            case continueButton
        }

        enum DetailPage: String, UIElement {
            case root
        }

        enum NewOp: String, UIElement {

            // Base elements
            case root
            case continueButton

            // FilledData
            case amountFilledData
            case feeFilledData
            case feeView
            case descriptionFilledData
            case destinationFilledData

            // Inner views
            enum AmountView: String, UIElement {
                case root
                case input
                case useAllFunds
            }

            enum DescriptionView: String, UIElement {
                case root
                case input
            }
        }

        enum CurrencyPicker: String, UIElement {
            case root
            case tableView
        }

        enum ReceivePage: String, UIElement {
            case root
            case qrCodeWithActions
            case enablePush
            case segmentedControl
        }

        enum SelectFeePage: String, UIElement {
            case root
            case tableView
            case button
        }

        enum ManuallyEnterFeePage: String, UIElement {
            case root
            case textField
            case button
            case warningLabel
        }

        enum ScanQRPage: String, UIElement {
            case root
            case cameraPermissionView
            case enterManually
        }

        enum ManuallyEnterQRPage: String, UIElement {
            case root
            case input
            case submit
        }

        enum SettingsPage: String, UIElement {
            case root
        }

        enum ChangePasswordPriming: String, UIElement {
            case root
            case continueButton
        }

        enum ChangePasswordEnterCurrent: String, UIElement {
            case root
            case confirmButton
            case forgotPasswordButton
            case textInput
        }

        enum ChangePasswordEnterRecoveryCode: String, UIElement {
            case root
            case codeView
            case errorLabel
            case continueButton
        }

        enum ChangePasswordEnterNew: String, UIElement {
            case root
            case firstTextInput
            case secondTextInput
            case confirmButton
            case agreeChangePasswordCheck
        }

        enum SecurityCenterPage: String, UIElement {
            case root
            case emailSetup
            case recoveryCodeSetup
            case emergencyKit
            case recoveryTool
            case exportEmergencyKitAgainButton
        }

        enum FeedbackPage: String, UIElement {
            case root
            case finishButton
        }

        enum ErrorPage: String, UIElement {
            case root
            case titleLabel
            case descriptionLabel
            case primaryButton
            case secondaryButton
        }

        enum EmergencyKit {

            enum SharePDF: String, UIElement {
                case root
                case saveManually
                case confirm
            }

            enum ActivatePDF: String, UIElement {
                case root
                case segment0
                case segment1
                case segment2
                case segment3
                case segment4
                case segment5
                case activationCodeLabel
            }

            enum Slides: String, UIElement {
                case root
                case continueButton
            }

            enum RecoveryTool: String, UIElement {
                case root
            }
        }

        enum LightningNetworkSettingsPage: String, UIElement {
            case root
            case turboChannels
        }

        enum ReceiveFormatActionSheetPage: String, UIElement {
            case root
        }

        enum LNURLFirstTimePage: String, UIElement {
            case root
            case continueButton
        }

        enum LNURLScanQRPage: String, UIElement {
            case root
            case cameraPermissionView
            case enterManually
        }

        enum LNURLManuallyEnterQRPage: String, UIElement {
            case root
            case input
            case submit
        }
    }

    enum CustomViews {

        enum ButtonViewPage: String, UIElement {
            case mainButton
        }

        enum SmallButtonViewPage: String, UIElement {
            case mainButton
        }

        enum TextInputViewPage: String, UIElement {
            case textfield
            case topLabel
            case bottomLabel
        }

        enum LargeTextInputViewPage: String, UIElement {
            case textView
            case topLabel
            case bottomLabel
        }

        enum KeyboardViewPage: String, UIElement {
            case number1
            case number2
            case number3
            case number4
            case number5
            case number6
            case number7
            case number8
            case number9
            case number0
            case erase
        }

        enum RecoveryViewPage: String, UIElement {
            case segment1
            case segment2
            case segment3
            case segment4
            case segment5
            case segment6
            case segment7
            case segment8
        }

        enum CheckViewPage: String, UIElement {
            case check
        }

        enum LinkButtonPage: String, UIElement {
            case mainButton
        }

        enum CameraPermissionPage: String, UIElement {
            case enable
        }

        enum AmountInput: String, UIElement {
            case root
            case input
            case currency
            case subtitle
        }

        enum QRCodeWithActions: String, UIElement {
            case root
            case address
        }
    }

    enum Cells {

        enum OperationCellPage: String, UIElement {
            case root
        }

    }

}
// swiftlint:enable nesting
