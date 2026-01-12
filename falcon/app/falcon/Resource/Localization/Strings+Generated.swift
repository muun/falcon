// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum ActionCardView {
    /// Skipped
    internal static let s1 = L10n.tr("Localizable", "ActionCardView.s1")
  }

  internal enum ActivateEmergencyKitView {
    /// Enter the 6-digit verification code located in the top-right corner of the document, just to ensure everything went right.
    internal static let activationDescription = L10n.tr("Localizable", "ActivateEmergencyKitView.activationDescription")
    /// 6-digit verification code
    internal static let boldDescription = L10n.tr("Localizable", "ActivateEmergencyKitView.boldDescription")
    /// This is an old code. Check your latest Emergency Kit (your code starts with %@)
    internal static func oldCodeError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ActivateEmergencyKitView.oldCodeError", String(describing: p1))
    }
    /// This is an old code.
    internal static let oldCodeErrorRed = L10n.tr("Localizable", "ActivateEmergencyKitView.oldCodeErrorRed")
    /// Verify your Emergency Kit
    internal static let s1 = L10n.tr("Localizable", "ActivateEmergencyKitView.s1")
    /// Verification code
    internal static let s4 = L10n.tr("Localizable", "ActivateEmergencyKitView.s4")
    /// Can't find it?
    internal static let s6 = L10n.tr("Localizable", "ActivateEmergencyKitView.s6")
    /// Wrong code
    internal static let s8 = L10n.tr("Localizable", "ActivateEmergencyKitView.s8")
  }

  internal enum ActivateEmergencyKitViewController {
    /// Emergency Kit
    internal static let s1 = L10n.tr("Localizable", "ActivateEmergencyKitViewController.s1")
  }

  internal enum AddressTypeOptionView {
    /// Address type
    internal static let label = L10n.tr("Localizable", "AddressTypeOptionView.label")
    /// Legacy
    internal static let legacy = L10n.tr("Localizable", "AddressTypeOptionView.legacy")
    /// The most widely accepted address type. Use it only when a service labels your Segwit addresses as invalid.
    internal static let legacyDescription = L10n.tr("Localizable", "AddressTypeOptionView.legacyDescription")
    /// Segwit
    internal static let segwit = L10n.tr("Localizable", "AddressTypeOptionView.segwit")
    /// A relatively new address type, already widely accepted. It creates lighter transactions and saves you money on future network fees.
    internal static let segwitDescription = L10n.tr("Localizable", "AddressTypeOptionView.segwitDescription")
    /// Taproot
    internal static let taproot = L10n.tr("Localizable", "AddressTypeOptionView.taproot")
    /// Activates in ~%@ hours.
    internal static func taprootActivation(_ p1: Any) -> String {
      return L10n.tr("Localizable", "AddressTypeOptionView.taprootActivation", String(describing: p1))
    }
    /// The newest and most powerful address type. Many services are not yet compatible and may label it as invalid.
    internal static let taprootDescription = L10n.tr("Localizable", "AddressTypeOptionView.taprootDescription")
  }

  internal enum AddressTypeSelectViewController {
    /// Choose your address type
    internal static let title = L10n.tr("Localizable", "AddressTypeSelectViewController.title")
  }

  internal enum AmountOptionView {
    /// Add +
    internal static let addButton = L10n.tr("Localizable", "AmountOptionView.addButton")
    /// Amount
    internal static let label = L10n.tr("Localizable", "AmountOptionView.label")
  }

  internal enum ApiMigrationsViewController {
    /// Please retry.
    internal static let failedAlertMessage = L10n.tr("Localizable", "ApiMigrationsViewController.failedAlertMessage")
    /// Retry
    internal static let failedAlertRetry = L10n.tr("Localizable", "ApiMigrationsViewController.failedAlertRetry")
    /// Error loading wallet
    internal static let failedAlertTitle = L10n.tr("Localizable", "ApiMigrationsViewController.failedAlertTitle")
    /// Loading your wallet
    internal static let loading = L10n.tr("Localizable", "ApiMigrationsViewController.loading")
  }

  internal enum AppDelegate {
    /// Security
    internal static let securityTab = L10n.tr("Localizable", "AppDelegate.securityTab")
    /// Settings
    internal static let settingsTab = L10n.tr("Localizable", "AppDelegate.settingsTab")
    /// Wallet
    internal static let walletTab = L10n.tr("Localizable", "AppDelegate.walletTab")
  }

  internal enum BalanceView {
    /// ﹡﹡﹡
    internal static let hiddenBalance = L10n.tr("Localizable", "BalanceView.hiddenBalance")
    /// Tap to reveal balance
    internal static let tapToRevealBalance = L10n.tr("Localizable", "BalanceView.tapToRevealBalance")
  }

  internal enum BasePresenter {
    /// Please try again
    internal static let s1 = L10n.tr("Localizable", "BasePresenter.s1")
    /// An error ocurred
    internal static let s2 = L10n.tr("Localizable", "BasePresenter.s2")
    /// Can't connect to Muun's server
    internal static let s3 = L10n.tr("Localizable", "BasePresenter.s3")
    /// Your phone's secure storage has been corrupted or compromised. For security reasons, Muun has logged out. Please contact support@muun.com for help.
    internal static let s6 = L10n.tr("Localizable", "BasePresenter.s6")
  }

  internal enum BitcoinUnitPickerViewController {
    /// Bitcoin Unit
    internal static let s1 = L10n.tr("Localizable", "BitcoinUnitPickerViewController.s1")
  }

  internal enum CameraPermissionView {
    /// ENABLE CAMERA
    internal static let s1 = L10n.tr("Localizable", "CameraPermissionView.s1")
  }

  internal enum ChangePasswordEnterCurrentView {
    /// Enter your password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s1")
    /// Current password
    internal static let s2 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s2")
    /// At least 8 characters long
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s3")
    /// CONFIRM CURRENT PASSWORD
    internal static let s4 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s4")
    /// I FORGOT MY PASSWORD
    internal static let s5 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s5")
    /// Invalid password
    internal static let s6 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s6")
    /// Verify you own this wallet.
    internal static let s7 = L10n.tr("Localizable", "ChangePasswordEnterCurrentView.s7")
  }

  internal enum ChangePasswordEnterCurrentViewController {
    /// Change password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterCurrentViewController.s1")
  }

  internal enum ChangePasswordEnterNewView {
    /// Create your new password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s1")
    /// Your new password must be different from your previous password.
    internal static let s2 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s2")
    /// New password
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s3")
    /// At least 8 characters long
    internal static let s4 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s4")
    /// Passwords must match
    internal static let s6 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s6")
    /// CONFIRM NEW PASSWORD
    internal static let s7 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s7")
    /// I understand that my previous password is no longer valid.
    internal static let s8 = L10n.tr("Localizable", "ChangePasswordEnterNewView.s8")
  }

  internal enum ChangePasswordEnterNewViewController {
    /// Change password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterNewViewController.s1")
    /// Abort change password?
    internal static let s2 = L10n.tr("Localizable", "ChangePasswordEnterNewViewController.s2")
    /// Your new password won't work unless you finish.
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordEnterNewViewController.s3")
    /// Cancel
    internal static let s4 = L10n.tr("Localizable", "ChangePasswordEnterNewViewController.s4")
    /// Abort
    internal static let s5 = L10n.tr("Localizable", "ChangePasswordEnterNewViewController.s5")
  }

  internal enum ChangePasswordEnterRecoveryCodeView {
    /// CONFIRM RECOVERY CODE
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterRecoveryCodeView.s1")
    /// Enter your recovery code
    internal static let s2 = L10n.tr("Localizable", "ChangePasswordEnterRecoveryCodeView.s2")
    /// Wrong Recovery Code. Please try again.
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordEnterRecoveryCodeView.s3")
  }

  internal enum ChangePasswordEnterRecoveryCodeViewController {
    /// Change password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordEnterRecoveryCodeViewController.s1")
  }

  internal enum ChangePasswordPrimingView {
    /// START PASSWORD CHANGE
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordPrimingView.s1")
    /// Change your password
    internal static let s2 = L10n.tr("Localizable", "ChangePasswordPrimingView.s2")
    /// Your password is used for security. To change it, you need access to your email and your current password or Recovery Code.
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordPrimingView.s3")
  }

  internal enum ChangePasswordPrimingViewController {
    /// Change password
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordPrimingViewController.s1")
  }

  internal enum ChangePasswordVerifyViewController {
    /// Confirm Password change
    internal static let s1 = L10n.tr("Localizable", "ChangePasswordVerifyViewController.s1")
    /// You will receive a verification email at %@
    internal static func s2(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ChangePasswordVerifyViewController.s2", String(describing: p1))
    }
    /// Change password
    internal static let s3 = L10n.tr("Localizable", "ChangePasswordVerifyViewController.s3")
    /// Choose Email
    internal static let s4 = L10n.tr("Localizable", "ChangePasswordVerifyViewController.s4")
  }

  internal enum CurrencyPickerViewController {
    /// Currencies
    internal static let s1 = L10n.tr("Localizable", "CurrencyPickerViewController.s1")
    /// Search
    internal static let s2 = L10n.tr("Localizable", "CurrencyPickerViewController.s2")
    /// MOST USED
    internal static let s3 = L10n.tr("Localizable", "CurrencyPickerViewController.s3")
    /// ALPHABETICALLY ORDERED BY COUNTRY
    internal static let s4 = L10n.tr("Localizable", "CurrencyPickerViewController.s4")
  }

  internal enum DetailPresenter {
    /// %@ hours
    internal static func s1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DetailPresenter.s1", String(describing: p1))
    }
    /// (%@ blocks)
    internal static func s2(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DetailPresenter.s2", String(describing: p1))
    }
  }

  internal enum DetailViewController {
    /// Fee paid to miners
    internal static let outgoingTxFee = L10n.tr("Localizable", "DetailViewController.outgoingTxFee")
    /// Payment hash
    internal static let paymentHash = L10n.tr("Localizable", "DetailViewController.paymentHash")
    /// Payment preimage
    internal static let preimage = L10n.tr("Localizable", "DetailViewController.preimage")
    /// How?
    internal static let rbfCta = L10n.tr("Localizable", "DetailViewController.rbfCta")
    /// This transaction has RBF (replace-by-fee) enabled. RBF allows the sender to raise the original fee for faster confirmation, but they can also use it to cancel the transaction.\n\nUnless you know and trust the sender, consider it a risk until the transaction is confirmed.
    internal static let rbfInfoDesc = L10n.tr("Localizable", "DetailViewController.rbfInfoDesc")
    /// How can this transaction be canceled?
    internal static let rbfInfoTitle = L10n.tr("Localizable", "DetailViewController.rbfInfoTitle")
    /// Until confirmed, this transaction can be canceled by the sender. How?
    internal static let rbfNotice = L10n.tr("Localizable", "DetailViewController.rbfNotice")
    /// This payment failed. You received a refund.
    internal static let s1 = L10n.tr("Localizable", "DetailViewController.s1")
    /// Received in address
    internal static let s10 = L10n.tr("Localizable", "DetailViewController.s10")
    /// URL copied.
    internal static let s11 = L10n.tr("Localizable", "DetailViewController.s11")
    /// Lightning invoice
    internal static let s13 = L10n.tr("Localizable", "DetailViewController.s13")
    /// Receiving node
    internal static let s14 = L10n.tr("Localizable", "DetailViewController.s14")
    /// Waiting for the recipient to accept the payment.
    internal static let s16 = L10n.tr("Localizable", "DetailViewController.s16")
    /// This payment is waiting for an on-chain confirmation.
    internal static let s19 = L10n.tr("Localizable", "DetailViewController.s19")
    /// Payment detail
    internal static let s2 = L10n.tr("Localizable", "DetailViewController.s2")
    /// Why?
    internal static let s20 = L10n.tr("Localizable", "DetailViewController.s20")
    /// There was no available route for this payment. You will get the refund in approximately %@ %@.
    internal static func s22(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "DetailViewController.s22", String(describing: p1), String(describing: p2))
    }
    /// Transaction ID
    internal static let s3 = L10n.tr("Localizable", "DetailViewController.s3")
    /// Description
    internal static let s4 = L10n.tr("Localizable", "DetailViewController.s4")
    /// When
    internal static let s5 = L10n.tr("Localizable", "DetailViewController.s5")
    /// Amount
    internal static let s6 = L10n.tr("Localizable", "DetailViewController.s6")
    /// Confirmations
    internal static let s7 = L10n.tr("Localizable", "DetailViewController.s7")
    /// Network fee
    internal static let s8 = L10n.tr("Localizable", "DetailViewController.s8")
    /// Sent to address
    internal static let s9 = L10n.tr("Localizable", "DetailViewController.s9")
  }

  internal enum DisableFeatureFlagsViewController {
    /// Some of our feature flags can be turned off and on again at your request. These are the ones you can currently modify. Turn the toggles off to disable the selected feature.
    internal static let informationLabel = L10n.tr("Localizable", "DisableFeatureFlagsViewController.informationLabel")
    /// Security Card
    internal static let nfcLabel = L10n.tr("Localizable", "DisableFeatureFlagsViewController.nfcLabel")
    /// Disable feature flags
    internal static let title = L10n.tr("Localizable", "DisableFeatureFlagsViewController.title")
  }

  internal enum EmailAlreadyUsedView {
    /// Another wallet is already using this email
    internal static let s1 = L10n.tr("Localizable", "EmailAlreadyUsedView.s1")
    /// support team
    internal static let s2 = L10n.tr("Localizable", "EmailAlreadyUsedView.s2")
    /// If you need help with your wallet please reach out to our support team and let us know what happened. We'll be happy to help.
    internal static let s3 = L10n.tr("Localizable", "EmailAlreadyUsedView.s3")
  }

  internal enum EmailClientsPicker {
    /// Cancel
    internal static let s1 = L10n.tr("Localizable", "EmailClientsPicker.s1")
  }

  internal enum EmailPrimingViewController {
    /// START
    internal static let s1 = L10n.tr("Localizable", "EmailPrimingViewController.s1")
    /// I DON'T WANT TO USE MY EMAIL
    internal static let s2 = L10n.tr("Localizable", "EmailPrimingViewController.s2")
    /// Are you sure you don't want email recovery?
    internal static let s3 = L10n.tr("Localizable", "EmailPrimingViewController.s3")
    /// You can come back if you change your mind later.
    internal static let s4 = L10n.tr("Localizable", "EmailPrimingViewController.s4")
    /// Cancel
    internal static let s5 = L10n.tr("Localizable", "EmailPrimingViewController.s5")
    /// I'm sure
    internal static let s6 = L10n.tr("Localizable", "EmailPrimingViewController.s6")
  }

  internal enum EmergencyKitSlides {
    /// Emergency Kit
    internal static let s1 = L10n.tr("Localizable", "EmergencyKitSlides.s1")
    /// Continue
    internal static let s10 = L10n.tr("Localizable", "EmergencyKitSlides.s10")
    /// Abort
    internal static let s11 = L10n.tr("Localizable", "EmergencyKitSlides.s11")
    /// Your Emergency Kit is a PDF document with information and instructions to independently transfer your funds.
    internal static let s12 = L10n.tr("Localizable", "EmergencyKitSlides.s12")
    /// By combining the Emergency Kit and your Recovery Code, you will have total, undisputed control over your funds.
    internal static let s13 = L10n.tr("Localizable", "EmergencyKitSlides.s13")
    /// CREATE YOUR EMERGENCY KIT
    internal static let s2 = L10n.tr("Localizable", "EmergencyKitSlides.s2")
    /// One document
    internal static let s4 = L10n.tr("Localizable", "EmergencyKitSlides.s4")
    /// Your private keys are securely encrypted with your Recovery Code, so you can save it online.
    internal static let s5 = L10n.tr("Localizable", "EmergencyKitSlides.s5")
    /// Stored online
    internal static let s6 = L10n.tr("Localizable", "EmergencyKitSlides.s6")
    /// Complete Ownership
    internal static let s7 = L10n.tr("Localizable", "EmergencyKitSlides.s7")
    /// You haven’t finished exporting up your Emergency Kit. You can restart this setup later.
    internal static let s8 = L10n.tr("Localizable", "EmergencyKitSlides.s8")
    /// Abort Emergency Kit export?
    internal static let s9 = L10n.tr("Localizable", "EmergencyKitSlides.s9")
  }

  internal enum EnterFeeManuallyTableViewCell {
    /// MANUALLY SELECTED FEE
    internal static let s1 = L10n.tr("Localizable", "EnterFeeManuallyTableViewCell.s1")
    /// ENTER FEE MANUALLY
    internal static let s2 = L10n.tr("Localizable", "EnterFeeManuallyTableViewCell.s2")
  }

  internal enum ErrorView {
    /// GO BACK
    internal static let goBack = L10n.tr("Localizable", "ErrorView.goBack")
    /// GO TO HOME
    internal static let goToHome = L10n.tr("Localizable", "ErrorView.goToHome")
    /// GO TO SECURITY CENTER
    internal static let goToSecurityCenter = L10n.tr("Localizable", "ErrorView.goToSecurityCenter")
    /// RETRY
    internal static let retry = L10n.tr("Localizable", "ErrorView.retry")
    /// SEND REPORT
    internal static let sendReport = L10n.tr("Localizable", "ErrorView.sendReport")
  }

  internal enum ExpirationTimeOptionView {
    /// Expiration time
    internal static let label = L10n.tr("Localizable", "ExpirationTimeOptionView.label")
  }

  internal enum FeeEditorPresenter {
    /// 15 days
    internal static let s1 = L10n.tr("Localizable", "FeeEditorPresenter.s1")
  }

  internal enum FinishEmailSetupViewController {
    /// Two things you must understand
    internal static let s1 = L10n.tr("Localizable", "FinishEmailSetupViewController.s1")
    /// FINISH
    internal static let s2 = L10n.tr("Localizable", "FinishEmailSetupViewController.s2")
    /// Why can't the password be reset?
    internal static let s3 = L10n.tr("Localizable", "FinishEmailSetupViewController.s3")
    /// You haven’t finished setting up your recovery method. You can restart this setup later.
    internal static let s4 = L10n.tr("Localizable", "FinishEmailSetupViewController.s4")
    /// Abort recovery setup?
    internal static let s5 = L10n.tr("Localizable", "FinishEmailSetupViewController.s5")
    /// Cancel
    internal static let s6 = L10n.tr("Localizable", "FinishEmailSetupViewController.s6")
    /// Abort
    internal static let s7 = L10n.tr("Localizable", "FinishEmailSetupViewController.s7")
  }

  internal enum FinishRecoveryCodeSetupViewController {
    /// Two things you must understand
    internal static let s1 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s1")
    /// FINISH
    internal static let s2 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s2")
    /// Failed to create the backup
    internal static let s3 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s3")
    /// Your Recovery Code is used to create an encrypted backup of your private key. To save the backup, you need internet connection.\n\nPlease check your connection and try again.
    internal static let s4 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s4")
    /// Retry
    internal static let s5 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s5")
    /// Cancel
    internal static let s6 = L10n.tr("Localizable", "FinishRecoveryCodeSetupViewController.s6")
  }

  internal enum GenerateRecoveryCodeViewController {
    /// Write down your Recovery Code
    internal static let s1 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s1")
    /// Use pen and paper. For security, don't save this on your phone or in the cloud.
    internal static let s2 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s2")
    /// CONTINUE
    internal static let s3 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s3")
    /// Abort Recovery Code setup?
    internal static let s4 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s4")
    /// Cancel
    internal static let s5 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s5")
    /// Abort
    internal static let s6 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s6")
    /// Your Recovery Code won't work unless you finish.
    internal static let s7 = L10n.tr("Localizable", "GenerateRecoveryCodeViewController.s7")
  }

  internal enum GetStartedViewController {
    /// Self-custodial wallet\nfor bitcoin and lightning.
    internal static let s1 = L10n.tr("Localizable", "GetStartedViewController.s1")
    /// CREATE A NEW WALLET
    internal static let s5 = L10n.tr("Localizable", "GetStartedViewController.s5")
    /// RECOVER EXISTING WALLET
    internal static let s6 = L10n.tr("Localizable", "GetStartedViewController.s6")
  }

  internal enum HelpEmergencyKitView {
    /// Can’t find the verification code?
    internal static let s1 = L10n.tr("Localizable", "HelpEmergencyKitView.s1")
    /// 6-digit number
    internal static let s2 = L10n.tr("Localizable", "HelpEmergencyKitView.s2")
    /// The verification code is a 6-digit number, located at the top-right corner of your Emergency Kit.
    internal static let s5 = L10n.tr("Localizable", "HelpEmergencyKitView.s5")
  }

  internal enum Home {
    /// Level-up your payments. Save with each payment by activating Taproot.
    internal static let activateTaproot = L10n.tr("Localizable", "Home.activateTaproot")
    /// Level-up your payments.
    internal static let activateTaprootHighlight = L10n.tr("Localizable", "Home.activateTaprootHighlight")
    /// Back up your wallet. Create a backup to never lose access to your wallet.
    internal static let backUp = L10n.tr("Localizable", "Home.backUp")
    /// Back up your wallet
    internal static let boldBackUp = L10n.tr("Localizable", "Home.boldBackUp")
    /// The Bitcoin Network is congested. Fees are high, and confirmation times are slow.
    internal static let highFeesBannerTitle = L10n.tr("Localizable", "Home.highFeesBannerTitle")
    /// Upgrade to iOS 15 or greater to keep getting the latest features and security updates.
    internal static let iosUnder15Banner = L10n.tr("Localizable", "Home.iOSUnder15Banner")
    /// RECEIVE
    internal static let receiveCTA = L10n.tr("Localizable", "Home.receiveCTA")
    /// SEND
    internal static let sendCTA = L10n.tr("Localizable", "Home.sendCTA")
    /// Welcome to your new homescreen!\nTap or swipe up to see your transactions.
    internal static let transactionListTooltip = L10n.tr("Localizable", "Home.transactionListTooltip")
  }

  internal enum HomeViewController {
    /// Report a problem
    internal static let s1 = L10n.tr("Localizable", "HomeViewController.s1")
    /// Send feedback
    internal static let s2 = L10n.tr("Localizable", "HomeViewController.s2")
    /// Cancel
    internal static let s3 = L10n.tr("Localizable", "HomeViewController.s3")
  }

  internal enum LNURLFirstTimeViewController {
    /// Use LNURL to receive payments without having to share invoices. You can only use it with other services that support it.
    internal static let description = L10n.tr("Localizable", "LNURLFirstTimeViewController.description")
    /// Scan and receive\nlightning payments
    internal static let title = L10n.tr("Localizable", "LNURLFirstTimeViewController.title")
  }

  internal enum LNURLFromSendViewController {
    /// This seems like a LNURL code. It allows you to receive bitcoin via lightning, instead of sending it. Do you want to use it?
    internal static let description = L10n.tr("Localizable", "LNURLFromSendViewController.description")
    /// GO BACK TO SEND
    internal static let goBack = L10n.tr("Localizable", "LNURLFromSendViewController.goBack")
    /// RECEIVE BITCOIN
    internal static let receiveBitcoin = L10n.tr("Localizable", "LNURLFromSendViewController.receiveBitcoin")
    /// Looking to receive via lightning?
    internal static let title = L10n.tr("Localizable", "LNURLFromSendViewController.title")
  }

  internal enum LNURLManuallyEnterQRViewController {
    /// CONFIRM LINK
    internal static let confirm = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.confirm")
    /// Your clipboard is empty
    internal static let emptyClipboard = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.emptyClipboard")
    /// LNURL link
    internal static let inputLabel = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.inputLabel")
    /// Not an LNURLw link
    internal static let invalid = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.invalid")
    /// PASTE FROM CLIPBOARD
    internal static let pasteFromClipboard = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.pasteFromClipboard")
    /// Receive
    internal static let title = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.title")
    /// An error occurred. Copy and paste it again
    internal static let unexpectedError = L10n.tr("Localizable", "LNURLManuallyEnterQRViewController.unexpectedError")
  }

  internal enum LNURLScanQRViewController {
    /// ENTER LNURL LINK
    internal static let enterManually = L10n.tr("Localizable", "LNURLScanQRViewController.enterManually")
    /// Scan an LNURL QR to\nreceive bitcoin
    internal static let helper = L10n.tr("Localizable", "LNURLScanQRViewController.helper")
    /// Receive
    internal static let title = L10n.tr("Localizable", "LNURLScanQRViewController.title")
    /// USE LNURL LINK IN CLIPBOARD
    internal static let useClipboard = L10n.tr("Localizable", "LNURLScanQRViewController.useClipboard")
  }

  internal enum LNURLWithdrawPresenter {
    /// This code was used by another wallet, and can't be used again.
    internal static let alreadyUsedDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.alreadyUsedDescription")
    /// Code already used
    internal static let alreadyUsedTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.alreadyUsedTitle")
    /// The service that created this code is not available in your country.
    internal static let countryNotSupportedDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.countryNotSupportedDescription")
    /// Country not supported
    internal static let countryNotSupportedTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.countryNotSupportedTitle")
    /// Your lightning invoice expired, and %@ didn't complete the payment. Please, contact them for more information.
    internal static func expiredInvoiceDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.expiredInvoiceDescription", String(describing: p1))
    }
    /// Your payment failed
    internal static let expiredInvoiceTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.expiredInvoiceTitle")
    /// Your lightning invoice expired, and %@ didn't complete the payment.
    internal static func failedNotificationBody(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.failedNotificationBody", String(describing: p1))
    }
    /// Your payment failed
    internal static let failedNotificationTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.failedNotificationTitle")
    /// It doesn't seem to be one. Please, double-check its source. Keep in mind you can only use LNURL with services that support it.
    internal static let invalidCodeDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.invalidCodeDescription")
    /// Is it a LNURL code?
    internal static let invalidCodeTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.invalidCodeTitle")
    /// Invoice
    internal static let invoice = L10n.tr("Localizable", "LNURLWithdrawPresenter.invoice")
    /// It seems you don't have any funds to withdraw from %@. Please, check that your balance isn't empty.
    internal static func noAvailableBalanceDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.noAvailableBalanceDescription", String(describing: p1))
    }
    /// There are no funds to withdraw
    internal static let noAvailableBalanceTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.noAvailableBalanceTitle")
    /// It seems %@ couldn't find a route to send you the payment. We suggest you contact %@ to let them know.
    internal static func noRouteDescription(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.noRouteDescription", String(describing: p1), String(describing: p2))
    }
    /// There's no available route
    internal static let noRouteTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.noRouteTitle")
    /// You'll receive your payment as soon as %@ completes it.
    internal static func pendingNotificationBody(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.pendingNotificationBody", String(describing: p1))
    }
    /// Your payment is on the way
    internal static let pendingNotificationTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.pendingNotificationTitle")
    /// Received message
    internal static let receivedMessage = L10n.tr("Localizable", "LNURLWithdrawPresenter.receivedMessage")
    /// The LNURL expired before the payment was made. Please, request a new one.
    internal static let requestExpiredDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.requestExpiredDescription")
    /// This withdrawal request has expired
    internal static let requestExpiredTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.requestExpiredTitle")
    /// Something failed and we aren't sure what it was. Please send us a report to help us find out what happened.
    internal static let unknownErrorDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.unknownErrorDescription")
    /// Something went wrong
    internal static let unknownErrorTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.unknownErrorTitle")
    /// The service that created the LNURL code is unavailable. Please, try again later.
    internal static let unresponsiveDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.unresponsiveDescription")
    /// %@ is not responding
    internal static func unresponsiveTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawPresenter.unresponsiveTitle", String(describing: p1))
    }
    /// This is a valid LNURL, but not for this operation. Please, double-check its source. Keep in mind you can only use LNURL to withdraw funds.
    internal static let wrongTagDescription = L10n.tr("Localizable", "LNURLWithdrawPresenter.wrongTagDescription")
    /// Is it a LNURL withdraw?
    internal static let wrongTagTitle = L10n.tr("Localizable", "LNURLWithdrawPresenter.wrongTagTitle")
  }

  internal enum LNURLWithdrawViewController {
    /// Contacting %@...
    internal static func contacting(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawViewController.contacting", String(describing: p1))
    }
    /// Copy to clipboard
    internal static let copyToClipboard = L10n.tr("Localizable", "LNURLWithdrawViewController.copyToClipboard")
    /// Loading...
    internal static let loading = L10n.tr("Localizable", "LNURLWithdrawViewController.loading")
    /// Receiving from %@...
    internal static func receiving(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawViewController.receiving", String(describing: p1))
    }
    /// Receive
    internal static let title = L10n.tr("Localizable", "LNURLWithdrawViewController.title")
    /// %@ is taking too long to pay
    internal static func tooLong(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawViewController.tooLong", String(describing: p1))
    }
    /// You can choose to wait here or leave, and receive a notification when the payment completes. If the payment doesn't complete, please contact %@
    internal static func tooLongDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LNURLWithdrawViewController.tooLongDescription", String(describing: p1))
    }
  }

  internal enum LightningAdvancedOptionsView {
    /// Invoice settings
    internal static let header = L10n.tr("Localizable", "LightningAdvancedOptionsView.header")
    /// Hide settings
    internal static let hide = L10n.tr("Localizable", "LightningAdvancedOptionsView.hide")
  }

  internal enum LightningNetworkSettings {
    /// https://blog.muun.com/turbo-channels/
    internal static let blogPost = L10n.tr("Localizable", "LightningNetworkSettings.blogPost")
    /// Receiving some lightning payments will take much longer.
    internal static let confirmDescription = L10n.tr("Localizable", "LightningNetworkSettings.confirmDescription")
    /// Disable turbo channels?
    internal static let confirmTitle = L10n.tr("Localizable", "LightningNetworkSettings.confirmTitle")
    /// Disable
    internal static let disable = L10n.tr("Localizable", "LightningNetworkSettings.disable")
    /// Learn more about the trade-offs of turbo channels.
    internal static let learnMore = L10n.tr("Localizable", "LightningNetworkSettings.learnMore")
    /// Learn more
    internal static let learnMoreUnderline = L10n.tr("Localizable", "LightningNetworkSettings.learnMoreUnderline")
    /// In Muun, you can receive funds via the Bitcoin Network or the Lightning Network.\n\nMany services don't support Lightning yet, so when you tap on the Receive button, your wallet defaults to the Bitcoin Network and shows a bitcoin address. By defaulting to Lightning, your wallet will show a lightning invoice, and you'll need to manually switch to Bitcoin each time you need a bitcoin address.
    internal static let lightningDefaultDescription = L10n.tr("Localizable", "LightningNetworkSettings.lightningDefaultDescription")
    /// Default to Lightning on Receive
    internal static let lightningDefaultTitle = L10n.tr("Localizable", "LightningNetworkSettings.lightningDefaultTitle")
    /// Lightning Network
    internal static let title = L10n.tr("Localizable", "LightningNetworkSettings.title")
    /// Turbo channels
    internal static let turboChannels = L10n.tr("Localizable", "LightningNetworkSettings.turboChannels")
  }

  internal enum LogOutViewController {
    /// You were logged out
    internal static let s1 = L10n.tr("Localizable", "LogOutViewController.s1")
    /// RESTART
    internal static let s2 = L10n.tr("Localizable", "LogOutViewController.s2")
    /// You entered a wrong pin 3 times in a row. As a security measure, you were logged out. Please restart Muun to recover your wallet.
    internal static let s3 = L10n.tr("Localizable", "LogOutViewController.s3")
  }

  internal enum MUDetailRowView {
    /// Copied to clipboard
    internal static let s1 = L10n.tr("Localizable", "MUDetailRowView.s1")
  }

  internal enum ManualSaveEmergencyKitView {
    /// Make it accesible. You should be able to access your Kit at all times, even if your phone is lost, stolen or stops working.
    internal static let accesible = L10n.tr("Localizable", "ManualSaveEmergencyKitView.accesible")
    /// Make it accesible.
    internal static let accesibleBold = L10n.tr("Localizable", "ManualSaveEmergencyKitView.accesibleBold")
    /// SAVE MANUALLY
    internal static let save = L10n.tr("Localizable", "ManualSaveEmergencyKitView.save")
    /// Don’t prioritize secrecy. Remember, your Kit is encrypted. Without your Recovery Code, the Kit is harmless. 
    internal static let secrecy = L10n.tr("Localizable", "ManualSaveEmergencyKitView.secrecy")
    /// Don’t prioritize secrecy.
    internal static let secrecyBold = L10n.tr("Localizable", "ManualSaveEmergencyKitView.secrecyBold")
    /// Saving the Kit manually? Here’s some advice.
    internal static let title = L10n.tr("Localizable", "ManualSaveEmergencyKitView.title")
    /// Make it easy to update. You should always have the latest Kit at hand, an old Kit won’t work.
    internal static let update = L10n.tr("Localizable", "ManualSaveEmergencyKitView.update")
    /// Make it easy to update.
    internal static let updateBold = L10n.tr("Localizable", "ManualSaveEmergencyKitView.updateBold")
  }

  internal enum ManuallyEnterFeeViewController {
    /// Edit network fee
    internal static let s1 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s1")
    /// Not enough funds.
    internal static let s11 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s11")
    /// Fee is very low. This transaction may take days to confirm.
    internal static let s12 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s12")
    /// Fee is too low. The bitcoin network is experiencing unusually high traffic and rejecting transactions with fee rates below %@ sat/vbyte.
    internal static func s13(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ManuallyEnterFeeViewController.s13", String(describing: p1))
    }
    /// Enter a fee manually. What's this?
    internal static let s2 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s2")
    /// What's this?
    internal static let s3 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s3")
    /// sat/vbyte
    internal static let s4 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s4")
    /// CONFIRM FEE
    internal static let s5 = L10n.tr("Localizable", "ManuallyEnterFeeViewController.s5")
    /// Less than %@
    internal static func s7(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ManuallyEnterFeeViewController.s7", String(describing: p1))
    }
    /// Fee is too low. Enter a fee of at least %@ sat/vbyte
    internal static func s8(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ManuallyEnterFeeViewController.s8", String(describing: p1))
    }
    /// Fee is too high. Enter a fee lower than %@ sat/vbyte
    internal static func s9(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ManuallyEnterFeeViewController.s9", String(describing: p1))
    }
  }

  internal enum ManuallyEnterQRViewController {
    /// Text address or invoice
    internal static let s1 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s1")
    /// CONTINUE
    internal static let s2 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s2")
    /// PASTE FROM CLIPBOARD
    internal static let s3 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s3")
    /// Send bitcoin
    internal static let s4 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s4")
    /// Not an address or invoice
    internal static let s5 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s5")
    /// You'll send funds to your Muun wallet
    internal static let s6 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s6")
    /// Your clipboard is empty
    internal static let s7 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s7")
    /// An error occurred. Copy and paste it again
    internal static let s8 = L10n.tr("Localizable", "ManuallyEnterQRViewController.s8")
  }

  internal enum NewOp {
    /// Full Address
    internal static let s1 = L10n.tr("Localizable", "NewOp.s1")
    /// Why will this payment take longer?
    internal static let s10 = L10n.tr("Localizable", "NewOp.s10")
    /// This lightning payment requires a confirmed on-chain transaction. It takes an average of 10 minutes to confirm
    internal static let s11 = L10n.tr("Localizable", "NewOp.s11")
    /// Receiving node details
    internal static let s2 = L10n.tr("Localizable", "NewOp.s2")
    /// OPEN IN NODE EXPLORER
    internal static let s3 = L10n.tr("Localizable", "NewOp.s3")
    /// Confirmation needed
    internal static let s4 = L10n.tr("Localizable", "NewOp.s4")
    /// Network fee and confirmation times
    internal static let s5 = L10n.tr("Localizable", "NewOp.s5")
    /// Manual fee and confirmation times
    internal static let s6 = L10n.tr("Localizable", "NewOp.s6")
    /// This lightning payment involves an on-chain transaction.\nTo complete the payment, the transaction must be confirmed.
    internal static let s7 = L10n.tr("Localizable", "NewOp.s7")
    /// Muun calculates and suggests the optimal fee needed to confirm your transaction in less than 30 minutes.\n\nA higher fee gives more priority to your transaction, while a transaction with a lower fee may take hours to confirm.\n\nOptimal fees rise when there is more activity on the network. If fees increase while your transaction is still unconfirmed, it may take longer to get confirmed.
    internal static let s8 = L10n.tr("Localizable", "NewOp.s8")
    /// Satoshis per virtual byte (sat/vbyte) is the unit to measure the priority of a transaction.\n\nA higher fee gives more priority to your transaction, while a payment with a lower fee may take hours to confirm.\n\nFees rise when there is more activity on the network. If fees increase while your payment is still unconfirmed, it may take longer to get confirmed.
    internal static let s9 = L10n.tr("Localizable", "NewOp.s9")
  }

  internal enum NewOpAmountFilledDataView {
    /// Amount
    internal static let s1 = L10n.tr("Localizable", "NewOpAmountFilledDataView.s1")
    /// Network fee
    internal static let s2 = L10n.tr("Localizable", "NewOpAmountFilledDataView.s2")
    /// Total
    internal static let s3 = L10n.tr("Localizable", "NewOpAmountFilledDataView.s3")
  }

  internal enum NewOpAmountView {
    /// CONFIRM AMOUNT
    internal static let s1 = L10n.tr("Localizable", "NewOpAmountView.s1")
    /// Balance: %@ %@
    internal static func s2(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "NewOpAmountView.s2", String(describing: p1), String(describing: p2))
    }
    /// Use all funds
    internal static let s3 = L10n.tr("Localizable", "NewOpAmountView.s3")
    /// NOT ENOUGH FUNDS
    internal static let s4 = L10n.tr("Localizable", "NewOpAmountView.s4")
    /// AMOUNT IS TOO SMALL
    internal static let s5 = L10n.tr("Localizable", "NewOpAmountView.s5")
  }

  internal enum NewOpConfirmView {
    /// SEND
    internal static let s1 = L10n.tr("Localizable", "NewOpConfirmView.s1")
  }

  internal enum NewOpDescriptionFilledDataView {
    /// Note
    internal static let s1 = L10n.tr("Localizable", "NewOpDescriptionFilledDataView.s1")
  }

  internal enum NewOpDescriptionView {
    /// CONFIRM NOTE
    internal static let s1 = L10n.tr("Localizable", "NewOpDescriptionView.s1")
    /// Write a note
    internal static let s2 = L10n.tr("Localizable", "NewOpDescriptionView.s2")
  }

  internal enum NewOpDestinationFilledDataView {
    /// To
    internal static let s1 = L10n.tr("Localizable", "NewOpDestinationFilledDataView.s1")
  }

  internal enum NewOpError {
    /// This payment is too small
    internal static let s10 = L10n.tr("Localizable", "NewOpError.s10")
    /// This invoice doesn't include an amount
    internal static let s11 = L10n.tr("Localizable", "NewOpError.s11")
    /// An unexpected error occurred
    internal static let s12 = L10n.tr("Localizable", "NewOpError.s12")
    /// This invoice can't be paid
    internal static let s13 = L10n.tr("Localizable", "NewOpError.s13")
    /// Payment failed
    internal static let s14 = L10n.tr("Localizable", "NewOpError.s14")
    /// This invoice expired before the payment was made. Please, create or request a new one.
    internal static let s15 = L10n.tr("Localizable", "NewOpError.s15")
    /// Please try with another invoice
    internal static let s16 = L10n.tr("Localizable", "NewOpError.s16")
    /// support team
    internal static let s17 = L10n.tr("Localizable", "NewOpError.s17")
    /// You don’t have enough funds to cover this payment and the network fee.
    internal static let s18 = L10n.tr("Localizable", "NewOpError.s18")
    /// At the moment, you can only pay to invoices that include an amount. Please, create or request a new one.
    internal static let s19 = L10n.tr("Localizable", "NewOpError.s19")
    /// This is not a BTC address
    internal static let s2 = L10n.tr("Localizable", "NewOpError.s2")
    /// You can't pay an invoice to yourself.
    internal static let s21 = L10n.tr("Localizable", "NewOpError.s21")
    /// Scanned text
    internal static let s22 = L10n.tr("Localizable", "NewOpError.s22")
    /// Total (Amount + Minimum Fee)
    internal static let s23 = L10n.tr("Localizable", "NewOpError.s23")
    /// Your balance
    internal static let s24 = L10n.tr("Localizable", "NewOpError.s24")
    /// This is not a BTC address or a lightning invoice. Double-check its source and make sure the address is properly formatted.
    internal static let s25 = L10n.tr("Localizable", "NewOpError.s25")
    /// Your payment was not completed because bitcoin exchange rates changed since you started. Please start a new payment.
    internal static let s26 = L10n.tr("Localizable", "NewOpError.s26")
    /// Please request a new invoice with an expiration time of at least one hour, or try scanning an invoice with a smaller amount.
    internal static let s27 = L10n.tr("Localizable", "NewOpError.s27")
    /// This invoice has already been scanned or paid by another wallet. Please, create or request a new one.
    internal static let s28 = L10n.tr("Localizable", "NewOpError.s28")
    /// There's no route with enough capacity to make this payment. Please, reach out to our support team and let us know what happened. We'll be happy to help.
    internal static let s29 = L10n.tr("Localizable", "NewOpError.s29")
    /// This invoice has expired
    internal static let s3 = L10n.tr("Localizable", "NewOpError.s3")
    /// The amount you are trying too send is too small. It must be greater than %@ satoshis.
    internal static func s30(_ p1: Any) -> String {
      return L10n.tr("Localizable", "NewOpError.s30", String(describing: p1))
    }
    /// Something went wrong, but we don’t know what. Please, reach out to our support team and let us know what happened. We'll be happy to help.
    internal static let s31 = L10n.tr("Localizable", "NewOpError.s31")
    /// This invoice was created by a private node that can't be reached. To reach it, the invoice must include extra data (RouteHints). This issue can only be fixed by the invoice creator.
    internal static let s32 = L10n.tr("Localizable", "NewOpError.s32")
    /// The receiving wallet can't process Lightning payments right now.\n\nYour payment failed immediately, and the funds are in your wallet.
    internal static let s33 = L10n.tr("Localizable", "NewOpError.s33")
    /// The bitcoin rates changed
    internal static let s4 = L10n.tr("Localizable", "NewOpError.s4")
    /// Unable to pay this invoice
    internal static let s5 = L10n.tr("Localizable", "NewOpError.s5")
    /// This payment needs a longer expiration time
    internal static let s6 = L10n.tr("Localizable", "NewOpError.s6")
    /// This invoice has already been used
    internal static let s7 = L10n.tr("Localizable", "NewOpError.s7")
    /// There is no available route
    internal static let s8 = L10n.tr("Localizable", "NewOpError.s8")
    /// You don't have enough funds
    internal static let s9 = L10n.tr("Localizable", "NewOpError.s9")
  }

  internal enum NewOpLoadingView {
    /// Loading payment details
    internal static let s1 = L10n.tr("Localizable", "NewOpLoadingView.s1")
  }

  internal enum NewOperationView {
    /// This invoice expires in %@
    internal static func s1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "NewOperationView.s1", String(describing: p1))
    }
    /// This payment will take longer than most lightning payments. Why?
    internal static let s2 = L10n.tr("Localizable", "NewOperationView.s2")
    /// Why?
    internal static let s3 = L10n.tr("Localizable", "NewOperationView.s3")
  }

  internal enum NewOperationViewController {
    /// Send bitcoin
    internal static let s1 = L10n.tr("Localizable", "NewOperationViewController.s1")
    /// Pay via lightning
    internal static let s2 = L10n.tr("Localizable", "NewOperationViewController.s2")
    /// Cancel payment?
    internal static let s3 = L10n.tr("Localizable", "NewOperationViewController.s3")
    /// Do you want to cancel this payment and go back to the home screen?
    internal static let s4 = L10n.tr("Localizable", "NewOperationViewController.s4")
    /// NO
    internal static let s5 = L10n.tr("Localizable", "NewOperationViewController.s5")
    /// YES, CANCEL
    internal static let s6 = L10n.tr("Localizable", "NewOperationViewController.s6")
    /// Disable security card flag?
    internal static let s7 = L10n.tr("Localizable", "NewOperationViewController.s7")
    /// Do you want to deactivate security card flag to complete payment?
    internal static let s8 = L10n.tr("Localizable", "NewOperationViewController.s8")
    /// YES, DISABLE
    internal static let s9 = L10n.tr("Localizable", "NewOperationViewController.s9")
  }

  internal enum NotificationService {
    /// Open the app to claim it
    internal static let fulfillIncomingSwapBody = L10n.tr("Localizable", "NotificationService.fulfillIncomingSwapBody")
    /// A lightning payment is pending!
    internal static let fulfillIncomingSwapTitle = L10n.tr("Localizable", "NotificationService.fulfillIncomingSwapTitle")
    /// %@ sent you %@
    internal static func opFromContactTitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "NotificationService.opFromContactTitle", String(describing: p1), String(describing: p2))
    }
    /// %@ received
    internal static func opReceivedTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "NotificationService.opReceivedTitle", String(describing: p1))
    }
    /// %@ sent
    internal static func opSentTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "NotificationService.opSentTitle", String(describing: p1))
    }
    /// The Bitcoin Network activated Taproot. You can now enjoy cheaper payments.
    internal static let taprootActivatedBody = L10n.tr("Localizable", "NotificationService.taprootActivatedBody")
    /// Taproot is live 🎉
    internal static let taprootActivatedTitle = L10n.tr("Localizable", "NotificationService.taprootActivatedTitle")
    /// Save with each payment by activating Taproot.
    internal static let taprootPreactivationBody = L10n.tr("Localizable", "NotificationService.taprootPreactivationBody")
    /// Level-up your payments
    internal static let taprootPreactivationTitle = L10n.tr("Localizable", "NotificationService.taprootPreactivationTitle")
    /// You have a new notification
    internal static let unknown = L10n.tr("Localizable", "NotificationService.unknown")
  }

  internal enum NotificationsPrimingView {
    /// Never miss a payment
    internal static let s1 = L10n.tr("Localizable", "NotificationsPrimingView.s1")
    /// Please enable notifications to know when you receive bitcoin.
    internal static let s2 = L10n.tr("Localizable", "NotificationsPrimingView.s2")
    /// ENABLE NOTIFICATIONS
    internal static let s3 = L10n.tr("Localizable", "NotificationsPrimingView.s3")
    /// SKIP
    internal static let s4 = L10n.tr("Localizable", "NotificationsPrimingView.s4")
    /// Please enable notifications
    internal static let s5 = L10n.tr("Localizable", "NotificationsPrimingView.s5")
    /// Lightning payments require you to get notifications.
    internal static let s6 = L10n.tr("Localizable", "NotificationsPrimingView.s6")
  }

  internal enum OnChainAdvancedOptionsView {
    /// Address settings
    internal static let header = L10n.tr("Localizable", "OnChainAdvancedOptionsView.header")
    /// Hide settings
    internal static let hide = L10n.tr("Localizable", "OnChainAdvancedOptionsView.hide")
  }

  internal enum OnchainSettings {
    /// Confirm
    internal static let confirm = L10n.tr("Localizable", "OnchainSettings.confirm")
    /// Some services may label your addresses as invalid.
    internal static let confirmDescription = L10n.tr("Localizable", "OnchainSettings.confirmDescription")
    /// Set Taproot as default?
    internal static let confirmTitle = L10n.tr("Localizable", "OnchainSettings.confirmTitle")
    /// Default to Taproot
    internal static let defaultTaproot = L10n.tr("Localizable", "OnchainSettings.defaultTaproot")
    /// Taproot is a new address type that makes your payments cheaper and less traceable.\n\nMany services are not yet compatible with Taproot and may label your addresses as invalid. If you make Taproot the default, you'll need to manually change the address type to Segwit or Legacy every time this happens.
    internal static let learnMore = L10n.tr("Localizable", "OnchainSettings.learnMore")
    /// Activates in ~%@ hours
    internal static func timeToActivation(_ p1: Any) -> String {
      return L10n.tr("Localizable", "OnchainSettings.timeToActivation", String(describing: p1))
    }
    /// Bitcoin Network
    internal static let title = L10n.tr("Localizable", "OnchainSettings.title")
  }

  internal enum OpSubmarineSwapViewBuilder {
    /// Public key
    internal static let s1 = L10n.tr("Localizable", "OpSubmarineSwapViewBuilder.s1")
    /// IP Addresses
    internal static let s2 = L10n.tr("Localizable", "OpSubmarineSwapViewBuilder.s2")
  }

  internal enum OpToAddressViewBuilder {
    /// Notice:
    internal static let s1 = L10n.tr("Localizable", "OpToAddressViewBuilder.s1")
    /// Notice: Not enough funds to pay for the optimal network fee. Select a network fee to continue.
    internal static let s2 = L10n.tr("Localizable", "OpToAddressViewBuilder.s2")
    /// Notice: Because you are using all your funds, the fee is deducted from the total amount you are sending.
    internal static let s4 = L10n.tr("Localizable", "OpToAddressViewBuilder.s4")
  }

  internal enum OperationFormatter {
    /// Cancelable
    internal static let cancelable = L10n.tr("Localizable", "OperationFormatter.cancelable")
    /// You paid yourself
    internal static let s1 = L10n.tr("Localizable", "OperationFormatter.s1")
    /// %@ paid you
    internal static func s10(_ p1: Any) -> String {
      return L10n.tr("Localizable", "OperationFormatter.s10", String(describing: p1))
    }
    /// You received
    internal static let s2 = L10n.tr("Localizable", "OperationFormatter.s2")
    /// You paid
    internal static let s3 = L10n.tr("Localizable", "OperationFormatter.s3")
    /// Confirming
    internal static let s4 = L10n.tr("Localizable", "OperationFormatter.s4")
    /// Failed
    internal static let s5 = L10n.tr("Localizable", "OperationFormatter.s5")
    /// You paid
    internal static let s6 = L10n.tr("Localizable", "OperationFormatter.s6")
    /// Confirmed
    internal static let s9 = L10n.tr("Localizable", "OperationFormatter.s9")
  }

  internal enum OperationTableViewCell {
    /// From the bitcoin network
    internal static let s1 = L10n.tr("Localizable", "OperationTableViewCell.s1")
    /// From the lightning network
    internal static let s2 = L10n.tr("Localizable", "OperationTableViewCell.s2")
  }

  internal enum PinPresenter {
    /// Create your PIN
    internal static let s1 = L10n.tr("Localizable", "PinPresenter.s1")
    /// Confirm your PIN
    internal static let s2 = L10n.tr("Localizable", "PinPresenter.s2")
    /// Enter your PIN
    internal static let s3 = L10n.tr("Localizable", "PinPresenter.s3")
    /// Keep your wallet safe
    internal static let s4 = L10n.tr("Localizable", "PinPresenter.s4")
    /// Enter it again to confirm
    internal static let s5 = L10n.tr("Localizable", "PinPresenter.s5")
  }

  internal enum PinViewController {
    /// Use your face to unlock Muun
    internal static let s1 = L10n.tr("Localizable", "PinViewController.s1")
    /// Use your fingerprint to unlock Muun
    internal static let s2 = L10n.tr("Localizable", "PinViewController.s2")
    /// Unlock muun
    internal static let s3 = L10n.tr("Localizable", "PinViewController.s3")
    /// Invalid PIN.
    internal static let s4 = L10n.tr("Localizable", "PinViewController.s4")
    /// Invalid PIN. After %@ more failed attempts, you'll be logged out of your wallet.
    internal static func s5(_ p1: Any) -> String {
      return L10n.tr("Localizable", "PinViewController.s5", String(describing: p1))
    }
    /// Pin did not match
    internal static let s6 = L10n.tr("Localizable", "PinViewController.s6")
  }

  internal enum QRCodeWithActionsView {
    /// COPY
    internal static let copy = L10n.tr("Localizable", "QRCodeWithActionsView.copy")
    /// Tap to copy your lightning invoice
    internal static let lightningQRAccessibilityLabel = L10n.tr("Localizable", "QRCodeWithActionsView.lightningQRAccessibilityLabel")
    /// Tap to copy your bitcoin address
    internal static let onChainQRAccessibilityLabel = L10n.tr("Localizable", "QRCodeWithActionsView.onChainQRAccessibilityLabel")
    /// SHARE
    internal static let share = L10n.tr("Localizable", "QRCodeWithActionsView.share")
    /// Tap to copy your unified URI
    internal static let unifiedQRAccessibilityLabel = L10n.tr("Localizable", "QRCodeWithActionsView.unifiedQRAccessibilityLabel")
  }

  internal enum Receive {
    /// Your bitcoin address
    internal static let s1 = L10n.tr("Localizable", "Receive.s1")
    /// Your lightning network invoice
    internal static let s2 = L10n.tr("Localizable", "Receive.s2")
    /// Segwit and legacy addresses
    internal static let s3 = L10n.tr("Localizable", "Receive.s3")
    /// Segwit and legacy are two different types of bitcoin addresses.\n\nLegacy addresses are more widely adopted but create larger transactions. Using them will result in higher fees on your future transactions.\n\nTo make your transactions more cost-effective, Muun displays Segwit addresses by default. Some services haven't upgraded to Segwit yet. If you are having trouble using a Segwit address, try a legacy address instead.
    internal static let s4 = L10n.tr("Localizable", "Receive.s4")
  }

  internal enum ReceiveAmountInputViewController {
    /// CONFIRM AMOUNT
    internal static let confirm = L10n.tr("Localizable", "ReceiveAmountInputViewController.confirm")
    /// Edit amount
    internal static let editAmount = L10n.tr("Localizable", "ReceiveAmountInputViewController.editAmount")
    /// REMOVE AMOUNT
    internal static let remove = L10n.tr("Localizable", "ReceiveAmountInputViewController.remove")
    /// Edit Invoice Amount
    internal static let titleLightning = L10n.tr("Localizable", "ReceiveAmountInputViewController.titleLightning")
    /// Edit Address Amount
    internal static let titleOnChain = L10n.tr("Localizable", "ReceiveAmountInputViewController.titleOnChain")
    /// AMOUNT IS TOO BIG
    internal static let tooBig = L10n.tr("Localizable", "ReceiveAmountInputViewController.tooBig")
    /// AMOUNT IS TOO SMALL
    internal static let tooSmall = L10n.tr("Localizable", "ReceiveAmountInputViewController.tooSmall")
  }

  internal enum ReceiveFormatSettingDropdownView {
    /// Bitcoin
    internal static let bitcoinCurrentValue = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.BitcoinCurrentValue")
    /// When receiving funds, you have to choose between using the Bitcoin Network or the Lightning Network. In the future, you won’t need to do it anymore (learn more).
    internal static let description = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.description")
    /// https://bitcoinqr.dev/
    internal static let learnMoreLink = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.learnMoreLink")
    /// learn more
    internal static let learnMoreUnderline = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.learnMoreUnderline")
    /// Lightning
    internal static let lightningCurrentValue = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.LightningCurrentValue")
    /// Choose your receiving protocol
    internal static let receiveFormatActionSheetTitle = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatActionSheetTitle")
    /// Default to show a bitcoin address. The most widely accepted and reliable way of transacting in bitcoin.
    internal static let receiveFormatBTCDescription = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatBTCDescription")
    /// Bitcoin first
    internal static let receiveFormatBTCOption = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatBTCOption")
    /// Default to show a lightning invoice. Lightning payments can be faster and cheaper, but some services don't support them yet.
    internal static let receiveFormatLNDescription = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatLNDescription")
    /// Lightning first
    internal static let receiveFormatLNOption = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatLNOption")
    /// 🧪 Experimental. Default to a unified QR code that encodes both a bitcoin address and a lightning invoice. Many services don’t support this unified format yet.
    internal static let receiveFormatUnifiedDescription = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatUnifiedDescription")
    /// Experimental.
    internal static let receiveFormatUnifiedDescriptionUnderline = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatUnifiedDescriptionUnderline")
    /// Unified
    internal static let receiveFormatUnifiedOption = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.ReceiveFormatUnifiedOption")
    /// Receiving protocol
    internal static let title = L10n.tr("Localizable", "ReceiveFormatSettingDropdownView.title")
  }

  internal enum ReceiveInLightningView {
    /// Generating invoice
    internal static let loading = L10n.tr("Localizable", "ReceiveInLightningView.loading")
    /// This invoice will expire in %@. Create another
    internal static func s1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ReceiveInLightningView.s1", String(describing: p1))
    }
    /// Create another
    internal static let s2 = L10n.tr("Localizable", "ReceiveInLightningView.s2")
    /// This invoice expired before the payment was made. Please, create or request a new one.
    internal static let s5 = L10n.tr("Localizable", "ReceiveInLightningView.s5")
    /// CREATE INVOICE
    internal static let s6 = L10n.tr("Localizable", "ReceiveInLightningView.s6")
    /// Your wallet is temporarily unable to receive Lightning payments due to the high congestion of the Bitcoin Network.\n\nTo receive a payment, please switch to the Bitcoin tab.
    internal static let s7 = L10n.tr("Localizable", "ReceiveInLightningView.s7")
  }

  internal enum ReceiveOnChainView {
    /// Bitcoin legacy address
    internal static let s1 = L10n.tr("Localizable", "ReceiveOnChainView.s1")
    /// Switch to legacy addresses
    internal static let s4 = L10n.tr("Localizable", "ReceiveOnChainView.s4")
    /// Switch to Segwit addresses
    internal static let s5 = L10n.tr("Localizable", "ReceiveOnChainView.s5")
    /// Having trouble using this address?\nSwitch to legacy addresses
    internal static let s6 = L10n.tr("Localizable", "ReceiveOnChainView.s6")
  }

  internal enum ReceivePresenter {
    /// %@ received
    internal static func s1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ReceivePresenter.s1", String(describing: p1))
    }
  }

  internal enum ReceiveUnifiedView {
    /// Your wallet is temporarily unable to receive Lightning payments due to the high congestion of the Bitcoin Network.\n\nTo receive a payment, please visit Settings > Lightning Network and set Bitcoin as your receiving protocol.
    internal static let highFeesMessage = L10n.tr("Localizable", "ReceiveUnifiedView.highFeesMessage")
    /// Generating QR code
    internal static let loading = L10n.tr("Localizable", "ReceiveUnifiedView.loading")
  }

  internal enum ReceiveViewController {
    /// Your bitcoin address
    internal static let detailedURIBTCTitle = L10n.tr("Localizable", "ReceiveViewController.detailedURIBTCTitle")
    /// 🧪 Unified QR codes are experimental (learn more)
    internal static let detailedURIDisclaimer = L10n.tr("Localizable", "ReceiveViewController.detailedURIDisclaimer")
    /// Your lightning invoice
    internal static let detailedURILNTitle = L10n.tr("Localizable", "ReceiveViewController.detailedURILNTitle")
    /// Receive Bitcoin
    internal static let receiveBitcoin = L10n.tr("Localizable", "ReceiveViewController.receiveBitcoin")
    /// Bitcoin
    internal static let s1 = L10n.tr("Localizable", "ReceiveViewController.s1")
    /// Lightning
    internal static let s2 = L10n.tr("Localizable", "ReceiveViewController.s2")
    /// Receive
    internal static let s3 = L10n.tr("Localizable", "ReceiveViewController.s3")
    /// Copied to clipboard
    internal static let s4 = L10n.tr("Localizable", "ReceiveViewController.s4")
    /// Copied to clipboard. This invoice expires in %@.
    internal static func s5(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ReceiveViewController.s5", String(describing: p1))
    }
  }

  internal enum Recover {
    /// What is the Recovery Code?
    internal static let s1 = L10n.tr("Localizable", "Recover.s1")
    /// Forgotten passwords
    internal static let s2 = L10n.tr("Localizable", "Recover.s2")
    /// It is a set of randomly-generated characters and the only way to log in if you forgot your password.\nYou set it up on %@ and most likely wrote it on a paper.
    internal static func s3(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Recover.s3", String(describing: p1))
    }
    /// It is a set of randomly-generated characters and the only way to log in if you forgot your password.
    internal static let s4 = L10n.tr("Localizable", "Recover.s4")
    /// Muun doesn't keep a copy of your password, so it can't be reset.\nTry to remember it. You chose it on %@
    internal static func s5(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Recover.s5", String(describing: p1))
    }
    /// Muun doesn't keep a copy of your password, so it can't be reset.\nTry to remember it.
    internal static let s6 = L10n.tr("Localizable", "Recover.s6")
  }

  internal enum RecoveryCodeMissingView {
    /// SET UP RECOVERY CODE
    internal static let s1 = L10n.tr("Localizable", "RecoveryCodeMissingView.s1")
    /// Recovery code missing
    internal static let s2 = L10n.tr("Localizable", "RecoveryCodeMissingView.s2")
    /// To change your password you first need to set up your Recovery Code.
    internal static let s3 = L10n.tr("Localizable", "RecoveryCodeMissingView.s3")
  }

  internal enum RecoveryCodePrimingViewController {
    /// START
    internal static let s1 = L10n.tr("Localizable", "RecoveryCodePrimingViewController.s1")
    /// Failed to create the backup
    internal static let s2 = L10n.tr("Localizable", "RecoveryCodePrimingViewController.s2")
    /// You are about to create an encrypted backup of your private key. To save it, you need an internet connection.\n\nPlease check your connection and try again.
    internal static let s3 = L10n.tr("Localizable", "RecoveryCodePrimingViewController.s3")
    /// Retry
    internal static let s4 = L10n.tr("Localizable", "RecoveryCodePrimingViewController.s4")
    /// Cancel
    internal static let s5 = L10n.tr("Localizable", "RecoveryCodePrimingViewController.s5")
  }

  internal enum RecoveryToolViewController {
    /// Recover your funds
    internal static let s1 = L10n.tr("Localizable", "RecoveryToolViewController.s1")
    /// Use the Recovery Tool to retrieve your money
    internal static let s2 = L10n.tr("Localizable", "RecoveryToolViewController.s2")
    /// In a scenario where Muun is unavailable, this is the way to reclaim all your money without the collaboration of our servers.
    internal static let s3 = L10n.tr("Localizable", "RecoveryToolViewController.s3")
    /// Use your encrypted Private Keys, your Recovery Code and the Recovery Tool to retrieve your funds.
    internal static let s4 = L10n.tr("Localizable", "RecoveryToolViewController.s4")
    /// You can find our Recovery Tool and the instructions for this process at https://github.com/muun/recovery
    internal static let s5 = L10n.tr("Localizable", "RecoveryToolViewController.s5")
  }

  internal enum RequestCloudFeedbackView {
    /// Thank you for your feedback!
    internal static let title = L10n.tr("Localizable", "RequestCloudFeedbackView.title")
  }

  internal enum RequestCloudView {
    /// We plan to support more cloud services. Which one would you like to see added?
    internal static let description = L10n.tr("Localizable", "RequestCloudView.description")
    /// SEND FEEDBACK
    internal static let send = L10n.tr("Localizable", "RequestCloudView.send")
  }

  internal enum SaveEmergencyKitOptionView {
    /// Tell us which cloud service you would like us to support.
    internal static let anotherCloudDescription = L10n.tr("Localizable", "SaveEmergencyKitOptionView.anotherCloudDescription")
    /// Suggest another cloud
    internal static let anotherCloudTitle = L10n.tr("Localizable", "SaveEmergencyKitOptionView.anotherCloudTitle")
    /// Use your Google account to save and access your Kit.
    internal static let driveDescription = L10n.tr("Localizable", "SaveEmergencyKitOptionView.driveDescription")
    /// Save to Drive
    internal static let driveTitle = L10n.tr("Localizable", "SaveEmergencyKitOptionView.driveTitle")
    /// Use your Apple account to save and access your Kit.
    internal static let icloudDescription = L10n.tr("Localizable", "SaveEmergencyKitOptionView.icloudDescription")
    /// Enable iCloud on your phone settings to export your Kit.
    internal static let icloudDisabledDescription = L10n.tr("Localizable", "SaveEmergencyKitOptionView.icloudDisabledDescription")
    /// Save to iCloud
    internal static let icloudTitle = L10n.tr("Localizable", "SaveEmergencyKitOptionView.icloudTitle")
    /// Not enabled
    internal static let notEnabled = L10n.tr("Localizable", "SaveEmergencyKitOptionView.notEnabled")
    /// OPEN IN DRIVE
    internal static let openInDrive = L10n.tr("Localizable", "SaveEmergencyKitOptionView.openInDrive")
    /// OPEN IN ICLOUD
    internal static let openInICloud = L10n.tr("Localizable", "SaveEmergencyKitOptionView.openInICloud")
    /// Recommended
    internal static let recommended = L10n.tr("Localizable", "SaveEmergencyKitOptionView.recommended")
    /// You saved your Kit to Google Drive. Before you go, find it and take a good look inside. Make sure you can do this in the future.
    internal static let verifyDescriptionDrive = L10n.tr("Localizable", "SaveEmergencyKitOptionView.verifyDescriptionDrive")
    /// You saved your Kit to iCloud. Before you go, find it and take a good look inside. Make sure you can do this in the future.
    internal static let verifyDescriptionICloud = L10n.tr("Localizable", "SaveEmergencyKitOptionView.verifyDescriptionICloud")
    /// Verify your Emergency Kit
    internal static let verifyTitle = L10n.tr("Localizable", "SaveEmergencyKitOptionView.verifyTitle")
  }

  internal enum ScanQRViewController {
    /// ENTER TEXT ADDRESS
    internal static let s1 = L10n.tr("Localizable", "ScanQRViewController.s1")
    /// SEND TO ADDRESS IN CLIPBOARD
    internal static let s2 = L10n.tr("Localizable", "ScanQRViewController.s2")
    /// Send bitcoin
    internal static let s3 = L10n.tr("Localizable", "ScanQRViewController.s3")
    /// Scan a bitcoin or lightning QR code
    internal static let s4 = L10n.tr("Localizable", "ScanQRViewController.s4")
    /// Enable your camera to scan QR codes with addresses or invoices
    internal static let s5 = L10n.tr("Localizable", "ScanQRViewController.s5")
    /// Scan a bitcoin or\nlightning QR code
    internal static let s6 = L10n.tr("Localizable", "ScanQRViewController.s6")
    /// USE LNURL LINK IN CLIPBOARD
    internal static let s7 = L10n.tr("Localizable", "ScanQRViewController.s7")
  }

  internal enum SecurityCenter {
    /// You have complete, undisputed ownership of your bitcoin.
    internal static let ekSuccessDescription = L10n.tr("Localizable", "SecurityCenter.EKSuccessDescription")
    /// You exported your keys
    internal static let s1 = L10n.tr("Localizable", "SecurityCenter.s1")
    /// There was a connectivity issue and the operation timed out. Please try again.
    internal static let s10 = L10n.tr("Localizable", "SecurityCenter.s10")
    /// GO BACK TO HOME
    internal static let s11 = L10n.tr("Localizable", "SecurityCenter.s11")
    /// Success!
    internal static let s12 = L10n.tr("Localizable", "SecurityCenter.s12")
    /// Why can't the password be reset?
    internal static let s13 = L10n.tr("Localizable", "SecurityCenter.s13")
    /// What is the Recovery Code?
    internal static let s14 = L10n.tr("Localizable", "SecurityCenter.s14")
    /// Muun doesn't keep a copy of this code
    internal static let s15 = L10n.tr("Localizable", "SecurityCenter.s15")
    /// How will Muun use my email?
    internal static let s16 = L10n.tr("Localizable", "SecurityCenter.s16")
    /// Your password is used to encrypt your wallet backup, so nobody without the password can access it — not even Muun. If you lose your original password, the backup is impossible to decrypt and restore.
    internal static let s17 = L10n.tr("Localizable", "SecurityCenter.s17")
    /// It is a set of randomly-generated characters.\n\nWe use the Recovery Code to create an encrypted backup of your Personal Key in case you forget your password. You can access your wallet using this backup and your code.\n\nWe do not keep a copy of this code, so write it down on paper and keep it safe.
    internal static let s18 = L10n.tr("Localizable", "SecurityCenter.s18")
    /// Muun will send you an email every time somebody tries to access your wallet, asking for your authorization. This protects you from people (or computers) attempting to guess your password, and alerts you if somebody tries.
    internal static let s19 = L10n.tr("Localizable", "SecurityCenter.s19")
    /// Recovery tool
    internal static let s2 = L10n.tr("Localizable", "SecurityCenter.s2")
    /// Is cloud storage safe?
    internal static let s20 = L10n.tr("Localizable", "SecurityCenter.s20")
    /// Data inside your Emergency Kit is securely encrypted with your Recovery Code. Without access to that code, the Kit is harmless.\n\nSince your Recovery Code is written in paper, you can save your Emergency Kit in the cloud without risk. It will be safe and available in the long term.
    internal static let s21 = L10n.tr("Localizable", "SecurityCenter.s21")
    /// Create an Emergency Kit
    internal static let s3 = L10n.tr("Localizable", "SecurityCenter.s3")
    /// Download the data you need to recover your money without using Muun.
    internal static let s4 = L10n.tr("Localizable", "SecurityCenter.s4")
    /// You created an Emergency Kit
    internal static let s5 = L10n.tr("Localizable", "SecurityCenter.s5")
    /// Follow the instructions in the Kit you saved to recover your money without using Muun.
    internal static let s6 = L10n.tr("Localizable", "SecurityCenter.s6")
    /// You wrote down your Private Keys. Use them with your Recovery Code and the Recovery Tool to recover your money without using Muun.
    internal static let s7 = L10n.tr("Localizable", "SecurityCenter.s7")
    /// EXCELLENT
    internal static let s8 = L10n.tr("Localizable", "SecurityCenter.s8")
    /// Something went wrong
    internal static let s9 = L10n.tr("Localizable", "SecurityCenter.s9")
    internal enum TaprootActivated {
      /// You can now send and receive payments using Taproot addresses. Your payments will be cheaper and less traceable.
      internal static let description = L10n.tr("Localizable", "SecurityCenter.taprootActivated.description")
      /// You're ready for Taproot!
      internal static let title = L10n.tr("Localizable", "SecurityCenter.taprootActivated.title")
    }
    internal enum TaprootActivationCountdown {
      /// When the Bitcoin Network mines block 709,632 Taproot will activate globally.\n\nTo protect you from potential blockchain reorganizations, you'll be able to start using Taproot addresses %1@ blocks later.\n\nWe have %2@ blocks to go!
      internal static func description(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "SecurityCenter.taprootActivationCountdown.description", String(describing: p1), String(describing: p2))
      }
      /// It's the final countdown!
      internal static let title = L10n.tr("Localizable", "SecurityCenter.taprootActivationCountdown.title")
    }
    internal enum TaprootPreactivated {
      /// In %@ blocks (~%@ hours), the Bitcoin Network will activate Taproot globally.\n\nWhen this happens, you'll be able to receive funds in Taproot addresses.
      internal static func description(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "SecurityCenter.taprootPreactivated.description", String(describing: p1), String(describing: p2))
      }
    }
  }

  internal enum SecurityCenterPresenter {
    /// Your wallet is not backed up
    internal static let s1 = L10n.tr("Localizable", "SecurityCenterPresenter.s1")
    /// You're one step away from a complete setup
    internal static let s2 = L10n.tr("Localizable", "SecurityCenterPresenter.s2")
    /// Your wallet has a basic backup
    internal static let s3 = L10n.tr("Localizable", "SecurityCenterPresenter.s3")
  }

  internal enum SecurityCenterViewController {
    /// Security Center
    internal static let s1 = L10n.tr("Localizable", "SecurityCenterViewController.s1")
    /// You completed your setup
    internal static let s2 = L10n.tr("Localizable", "SecurityCenterViewController.s2")
    /// Create another Emergency Kit
    internal static let s3 = L10n.tr("Localizable", "SecurityCenterViewController.s3")
    /// Export private keys again
    internal static let s4 = L10n.tr("Localizable", "SecurityCenterViewController.s4")
  }

  internal enum SelectFeeViewController {
    /// Edit network fee
    internal static let s1 = L10n.tr("Localizable", "SelectFeeViewController.s1")
    /// CONFIRM FEE
    internal static let s2 = L10n.tr("Localizable", "SelectFeeViewController.s2")
    /// Notice:
    internal static let s3 = L10n.tr("Localizable", "SelectFeeViewController.s3")
    /// Select a confirmation time. What's this?
    internal static let s4 = L10n.tr("Localizable", "SelectFeeViewController.s4")
    /// Notice: Because you are using all your funds, the fee is deducted from the total amount you are sending.
    internal static let s5 = L10n.tr("Localizable", "SelectFeeViewController.s5")
  }

  internal enum SessionExpiredViewController {
    /// You were logged out
    internal static let s1 = L10n.tr("Localizable", "SessionExpiredViewController.s1")
    /// Your session has expired. Please restart Muun to recover your wallet.
    internal static let s2 = L10n.tr("Localizable", "SessionExpiredViewController.s2")
    /// RESTART
    internal static let s3 = L10n.tr("Localizable", "SessionExpiredViewController.s3")
  }

  internal enum SetUpRecoveryCodeWording {
    /// Create an alternative backup
    internal static let s1 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s1")
    /// Write down a code on paper to recover your wallet if you change your phone or reinstall Muun.
    internal static let s10 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s10")
    /// Write down a code on paper to recover your wallet if you forget your password.
    internal static let s11 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s11")
    /// Improve your security
    internal static let s13 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s13")
    /// I understand I will need my Recovery Code if I forget my password.
    internal static let s14 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s14")
    /// I understand I will need my Recovery Code to recover my wallet.
    internal static let s15 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s15")
    /// I understand Muun doesn't keep a copy of my Recovery Code, and it can't be changed.
    internal static let s16 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s16")
    /// Success!
    internal static let s17 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s17")
    /// You backed up your wallet, and can now recover it using your Recovery Code.
    internal static let s18 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s18")
    /// You can now recover your wallet using your email and Recovery Code.
    internal static let s19 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s19")
    /// Write down a code on paper to recover your wallet.
    internal static let s2 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s2")
    /// Write down a code on paper for additional security.
    internal static let s3 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s3")
    /// Write down a code on paper in case you forget your password.
    internal static let s4 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s4")
    /// You created an alternative backup
    internal static let s5 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s5")
    /// You can use the code you wrote down to recover your wallet.
    internal static let s6 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s6")
    /// Use your email and the code you wrote down to recover your wallet.
    internal static let s7 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s7")
    /// Back up your wallet
    internal static let s8 = L10n.tr("Localizable", "SetUpRecoveryCodeWording.s8")
  }

  internal enum Settings {
    /// You deleted your wallet
    internal static let s1 = L10n.tr("Localizable", "Settings.s1")
    /// FINISH
    internal static let s2 = L10n.tr("Localizable", "Settings.s2")
    /// You succesfully changed your password
    internal static let s3 = L10n.tr("Localizable", "Settings.s3")
    /// support team
    internal static let s4 = L10n.tr("Localizable", "Settings.s4")
    /// We are sorry to see you go. We would love to know what we could have done better. Reach out to our support team and let us know!
    internal static let s5 = L10n.tr("Localizable", "Settings.s5")
  }

  internal enum SettingsViewController {
    /// ADVANCED SETTINGS
    internal static let advanced = L10n.tr("Localizable", "SettingsViewController.advanced")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "SettingsViewController.cancel")
    /// Lightning Network
    internal static let lightningNetwork = L10n.tr("Localizable", "SettingsViewController.lightningNetwork")
    /// OK
    internal static let ok = L10n.tr("Localizable", "SettingsViewController.ok")
    /// Bitcoin Network
    internal static let onchain = L10n.tr("Localizable", "SettingsViewController.onchain")
    /// Settings
    internal static let s1 = L10n.tr("Localizable", "SettingsViewController.s1")
    /// You can’t delete your wallet at this moment
    internal static let s10 = L10n.tr("Localizable", "SettingsViewController.s10")
    /// You can't log out at this moment
    internal static let s12 = L10n.tr("Localizable", "SettingsViewController.s12")
    /// Some your payments have pending confirmations. Before logging out, wait for them to confirm.
    internal static let s13 = L10n.tr("Localizable", "SettingsViewController.s13")
    /// Are you sure you want to log out?
    internal static let s15 = L10n.tr("Localizable", "SettingsViewController.s15")
    /// You will need your password or Recovery Code to regain access.
    internal static let s16 = L10n.tr("Localizable", "SettingsViewController.s16")
    /// Are you sure?
    internal static let s19 = L10n.tr("Localizable", "SettingsViewController.s19")
    /// GENERAL
    internal static let s2 = L10n.tr("Localizable", "SettingsViewController.s2")
    /// You will lose your transaction history.
    internal static let s20 = L10n.tr("Localizable", "SettingsViewController.s20")
    /// Delete
    internal static let s22 = L10n.tr("Localizable", "SettingsViewController.s22")
    /// You need to empty your wallet. Make a payment using all your funds, and try again when the transaction has 6 confirmations.
    internal static let s23 = L10n.tr("Localizable", "SettingsViewController.s23")
    /// Disable feature flags
    internal static let s24 = L10n.tr("Localizable", "SettingsViewController.s24")
    /// SECURITY
    internal static let s3 = L10n.tr("Localizable", "SettingsViewController.s3")
    /// Log out
    internal static let s4 = L10n.tr("Localizable", "SettingsViewController.s4")
    /// Delete wallet
    internal static let s5 = L10n.tr("Localizable", "SettingsViewController.s5")
    /// Version 
    internal static let s6 = L10n.tr("Localizable", "SettingsViewController.s6")
    /// Bitcoin Unit
    internal static let s7 = L10n.tr("Localizable", "SettingsViewController.s7")
    /// Main Currency
    internal static let s8 = L10n.tr("Localizable", "SettingsViewController.s8")
    /// Change password
    internal static let s9 = L10n.tr("Localizable", "SettingsViewController.s9")
  }

  internal enum SetupEmailWording {
    /// Back up your wallet
    internal static let s1 = L10n.tr("Localizable", "SetupEmailWording.s1")
    /// Improve your security
    internal static let s10 = L10n.tr("Localizable", "SetupEmailWording.s10")
    /// Enter a recovery email
    internal static let s11 = L10n.tr("Localizable", "SetupEmailWording.s11")
    /// How will Muun use my email?
    internal static let s12 = L10n.tr("Localizable", "SetupEmailWording.s12")
    /// You will receive a verification link. How will Muun use my email?
    internal static let s13 = L10n.tr("Localizable", "SetupEmailWording.s13")
    /// I understand I will need my password and access to my email to recover my wallet.
    internal static let s14 = L10n.tr("Localizable", "SetupEmailWording.s14")
    /// I understand that Muun can't reset my password if I forget it.
    internal static let s15 = L10n.tr("Localizable", "SetupEmailWording.s15")
    /// Success!
    internal static let s16 = L10n.tr("Localizable", "SetupEmailWording.s16")
    /// You backed up your wallet, and can now recover it using your email and password.
    internal static let s17 = L10n.tr("Localizable", "SetupEmailWording.s17")
    /// Use your email and a password to conveniently recover your wallet if you change your phone or reinstall Muun.
    internal static let s18 = L10n.tr("Localizable", "SetupEmailWording.s18")
    /// Use your email and a password to conveniently recover your wallet if you change your phone or reinstall Muun.\n\nThis enables multi-factor authentication, improving security when you use your Recovery Code.
    internal static let s19 = L10n.tr("Localizable", "SetupEmailWording.s19")
    /// Use your email and a password to recover your wallet.
    internal static let s2 = L10n.tr("Localizable", "SetupEmailWording.s2")
    /// Create a recovery method in case you change your phone or reinstall Muun.
    internal static let s3 = L10n.tr("Localizable", "SetupEmailWording.s3")
    /// Use your email and a password to recover your wallet.
    internal static let s4 = L10n.tr("Localizable", "SetupEmailWording.s4")
    /// You backed up your wallet
    internal static let s5 = L10n.tr("Localizable", "SetupEmailWording.s5")
    /// Use %@ and your password to recover your wallet.
    internal static func s6(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SetupEmailWording.s6", String(describing: p1))
    }
    /// Back up with password
    internal static let s8 = L10n.tr("Localizable", "SetupEmailWording.s8")
  }

  internal enum ShareEmergencyKitView {
    /// Choose your preferred cloud service to ensure your Kit is never lost.
    internal static let description = L10n.tr("Localizable", "ShareEmergencyKitView.description")
    /// Save your Emergency Kit
    internal static let exportTitle = L10n.tr("Localizable", "ShareEmergencyKitView.exportTitle")
    /// I don’t want to use cloud storage
    internal static let saveManually = L10n.tr("Localizable", "ShareEmergencyKitView.saveManually")
    /// Update your Emergency Kit
    internal static let updateTitle = L10n.tr("Localizable", "ShareEmergencyKitView.updateTitle")
  }

  internal enum ShareEmergencyKitViewController {
    /// Cancel
    internal static let alertCancel = L10n.tr("Localizable", "ShareEmergencyKitViewController.alertCancel")
    /// Retry
    internal static let alertRetry = L10n.tr("Localizable", "ShareEmergencyKitViewController.alertRetry")
    /// We couldn’t upload your Emergency Kit to the cloud. Please, check your connection and try again.
    internal static let ekUploadErrorDescription = L10n.tr("Localizable", "ShareEmergencyKitViewController.ekUploadErrorDescription")
    /// Your Emergency Kit could not be saved
    internal static let ekUploadErrorTitle = L10n.tr("Localizable", "ShareEmergencyKitViewController.ekUploadErrorTitle")
    /// Muun - Emergency Kit.pdf
    internal static let fileName = L10n.tr("Localizable", "ShareEmergencyKitViewController.fileName")
    /// We couldn't generate your Emergency Kit.
    internal static let generateEmergencyKitError = L10n.tr("Localizable", "ShareEmergencyKitViewController.generateEmergencyKitError")
    /// Emergency Kit
    internal static let s1 = L10n.tr("Localizable", "ShareEmergencyKitViewController.s1")
    /// Updating your Emergency Kit
    internal static let updating = L10n.tr("Localizable", "ShareEmergencyKitViewController.updating")
    /// Uploading your Emergency Kit
    internal static let uploading = L10n.tr("Localizable", "ShareEmergencyKitViewController.uploading")
  }

  internal enum SignInAuthorizeEmailViewController {
    /// Authorize wallet recovery
    internal static let s1 = L10n.tr("Localizable", "SignInAuthorizeEmailViewController.s1")
    /// Recover your wallet
    internal static let s2 = L10n.tr("Localizable", "SignInAuthorizeEmailViewController.s2")
    /// Choose Email
    internal static let s3 = L10n.tr("Localizable", "SignInAuthorizeEmailViewController.s3")
    /// You will receive an authorization email at %@. Please click the link in the email to continue.
    internal static func s4(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SignInAuthorizeEmailViewController.s4", String(describing: p1))
    }
  }

  internal enum SignInEmailAndRCViewController {
    /// Recover your wallet
    internal static let s1 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s1")
    /// You haven't completed setting up this Recovery Code. You should have a newer one. Please, find it and try again.
    internal static let s10 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s10")
    /// Your credentials (email and Recovery Code) don't match.
    internal static let s11 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s11")
    /// Please make sure you enter the Recovery Code that recovers the wallet using the email %@
    internal static func s12(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SignInEmailAndRCViewController.s12", String(describing: p1))
    }
    /// Accept
    internal static let s13 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s13")
    /// Enter your Recovery Code
    internal static let s2 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s2")
    /// You set it up on %@ and most likely wrote it on a paper. What's this?
    internal static func s3(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SignInEmailAndRCViewController.s3", String(describing: p1))
    }
    /// What's this?
    internal static let s4 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s4")
    /// You most likely wrote it on a paper. What's this?
    internal static let s5 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s5")
    /// Wrong Recovery Code. Please try again.
    internal static let s7 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s7")
    /// ENTER RECOVERY CODE
    internal static let s8 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s8")
    /// Invalid Recovery Code
    internal static let s9 = L10n.tr("Localizable", "SignInEmailAndRCViewController.s9")
  }

  internal enum SignInEmailViewController {
    /// Recover your wallet
    internal static let s1 = L10n.tr("Localizable", "SignInEmailViewController.s1")
    /// Enter your email
    internal static let s2 = L10n.tr("Localizable", "SignInEmailViewController.s2")
    /// You chose it when you set up your wallet.
    internal static let s3 = L10n.tr("Localizable", "SignInEmailViewController.s3")
    /// Your email
    internal static let s4 = L10n.tr("Localizable", "SignInEmailViewController.s4")
    /// you@example.com
    internal static let s5 = L10n.tr("Localizable", "SignInEmailViewController.s5")
    /// ENTER EMAIL
    internal static let s6 = L10n.tr("Localizable", "SignInEmailViewController.s6")
    /// RECOVER WITH RECOVERY CODE
    internal static let s7 = L10n.tr("Localizable", "SignInEmailViewController.s7")
    /// This email is not registered
    internal static let s8 = L10n.tr("Localizable", "SignInEmailViewController.s8")
  }

  internal enum SignInPasswordViewController {
    /// Recover your wallet
    internal static let s1 = L10n.tr("Localizable", "SignInPasswordViewController.s1")
    /// Continue
    internal static let s10 = L10n.tr("Localizable", "SignInPasswordViewController.s10")
    /// Cancel
    internal static let s11 = L10n.tr("Localizable", "SignInPasswordViewController.s11")
    /// Wrong password
    internal static let s12 = L10n.tr("Localizable", "SignInPasswordViewController.s12")
    /// Enter your password
    internal static let s2 = L10n.tr("Localizable", "SignInPasswordViewController.s2")
    /// Password
    internal static let s3 = L10n.tr("Localizable", "SignInPasswordViewController.s3")
    /// At least 8 characters long
    internal static let s4 = L10n.tr("Localizable", "SignInPasswordViewController.s4")
    /// ENTER PASSWORD
    internal static let s6 = L10n.tr("Localizable", "SignInPasswordViewController.s6")
    /// I FORGOT MY PASSWORD
    internal static let s7 = L10n.tr("Localizable", "SignInPasswordViewController.s7")
    /// Cancel wallet recovery?
    internal static let s8 = L10n.tr("Localizable", "SignInPasswordViewController.s8")
    /// You haven't finished recovering your wallet. You can do this later.
    internal static let s9 = L10n.tr("Localizable", "SignInPasswordViewController.s9")
  }

  internal enum SignInWithRCVerifyEmailPresenter {
    /// Something went wrong
    internal static let s1 = L10n.tr("Localizable", "SignInWithRCVerifyEmailPresenter.s1")
  }

  internal enum SignInWithRCVerifyEmailViewController {
    /// Authorize wallet recovery
    internal static let s1 = L10n.tr("Localizable", "SignInWithRCVerifyEmailViewController.s1")
    /// Recover your wallet
    internal static let s2 = L10n.tr("Localizable", "SignInWithRCVerifyEmailViewController.s2")
    /// Choose Email
    internal static let s3 = L10n.tr("Localizable", "SignInWithRCVerifyEmailViewController.s3")
    /// You will receive an authorization email at %@. Please click the link in the email to continue.
    internal static func s4(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SignInWithRCVerifyEmailViewController.s4", String(describing: p1))
    }
  }

  internal enum SignInWithRCView {
    /// ENTER RECOVERY CODE
    internal static let s1 = L10n.tr("Localizable", "SignInWithRCView.s1")
    /// Enter your recovery code
    internal static let s2 = L10n.tr("Localizable", "SignInWithRCView.s2")
    /// What's this?
    internal static let s3 = L10n.tr("Localizable", "SignInWithRCView.s3")
    /// Wrong Recovery Code. Please try again.
    internal static let s4 = L10n.tr("Localizable", "SignInWithRCView.s4")
    /// entering your email first
    internal static let s5 = L10n.tr("Localizable", "SignInWithRCView.s5")
    /// This Recovery Code can't be used without entering your email first.
    internal static let s6 = L10n.tr("Localizable", "SignInWithRCView.s6")
  }

  internal enum SignInWithRCViewController {
    /// Recover your wallet
    internal static let s1 = L10n.tr("Localizable", "SignInWithRCViewController.s1")
  }

  internal enum SignUpEmailViewController {
    /// Need help?
    internal static let s1 = L10n.tr("Localizable", "SignUpEmailViewController.s1")
    /// Email
    internal static let s2 = L10n.tr("Localizable", "SignUpEmailViewController.s2")
    /// example@you.com
    internal static let s3 = L10n.tr("Localizable", "SignUpEmailViewController.s3")
    /// CONFIRM EMAIL
    internal static let s4 = L10n.tr("Localizable", "SignUpEmailViewController.s4")
    /// Another wallet is already using this email
    internal static let s5 = L10n.tr("Localizable", "SignUpEmailViewController.s5")
  }

  internal enum SignUpPasswordViewController {
    /// Create your password
    internal static let s1 = L10n.tr("Localizable", "SignUpPasswordViewController.s1")
    /// You haven’t finished setting up your recovery method. You can restart this setup later.
    internal static let s10 = L10n.tr("Localizable", "SignUpPasswordViewController.s10")
    /// Abort recovery setup?
    internal static let s11 = L10n.tr("Localizable", "SignUpPasswordViewController.s11")
    /// Cancel
    internal static let s12 = L10n.tr("Localizable", "SignUpPasswordViewController.s12")
    /// Abort
    internal static let s13 = L10n.tr("Localizable", "SignUpPasswordViewController.s13")
    /// CONFIRM PASSWORD
    internal static let s14 = L10n.tr("Localizable", "SignUpPasswordViewController.s14")
    /// Choose something memorable. If possible, avoid old passwords you're already using.
    internal static let s2 = L10n.tr("Localizable", "SignUpPasswordViewController.s2")
    /// At least 8 characters
    internal static let s3 = L10n.tr("Localizable", "SignUpPasswordViewController.s3")
    /// Your password
    internal static let s4 = L10n.tr("Localizable", "SignUpPasswordViewController.s4")
    /// Eg.: correct horse battery staple
    internal static let s5 = L10n.tr("Localizable", "SignUpPasswordViewController.s5")
    /// Passwords must match
    internal static let s6 = L10n.tr("Localizable", "SignUpPasswordViewController.s6")
    /// Confirm your password
    internal static let s7 = L10n.tr("Localizable", "SignUpPasswordViewController.s7")
    /// CREATE PASSWORD
    internal static let s9 = L10n.tr("Localizable", "SignUpPasswordViewController.s9")
  }

  internal enum SignUpVerifyEmailViewController {
    /// Verify your recovery email
    internal static let s1 = L10n.tr("Localizable", "SignUpVerifyEmailViewController.s1")
    /// Choose Email
    internal static let s2 = L10n.tr("Localizable", "SignUpVerifyEmailViewController.s2")
    /// You will receive a verification email at %@. Please click the link in the email to continue.
    internal static func s3(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SignUpVerifyEmailViewController.s3", String(describing: p1))
    }
  }

  internal enum SlidesViewController {
    /// Swipe to continue
    internal static let swipe = L10n.tr("Localizable", "SlidesViewController.swipe")
  }

  internal enum SupportViewController {
    /// Please include this support code
    internal static let s1 = L10n.tr("Localizable", "SupportViewController.s1")
    /// If you have any ideas, comments or problems write us at support@muun.com.
    internal static let s10 = L10n.tr("Localizable", "SupportViewController.s10")
    /// Your comments
    internal static let s11 = L10n.tr("Localizable", "SupportViewController.s11")
    /// Problem description
    internal static let s12 = L10n.tr("Localizable", "SupportViewController.s12")
    /// SEND FEEDBACK
    internal static let s13 = L10n.tr("Localizable", "SupportViewController.s13")
    /// REPORT PROBLEM
    internal static let s14 = L10n.tr("Localizable", "SupportViewController.s14")
    /// OPEN EMAIL CLIENT
    internal static let s15 = L10n.tr("Localizable", "SupportViewController.s15")
    /// Choose Email
    internal static let s2 = L10n.tr("Localizable", "SupportViewController.s2")
    /// Cancel
    internal static let s3 = L10n.tr("Localizable", "SupportViewController.s3")
    /// Support code copied to clipboard
    internal static let s4 = L10n.tr("Localizable", "SupportViewController.s4")
    /// Let's make Muun even better together
    internal static let s5 = L10n.tr("Localizable", "SupportViewController.s5")
    /// Report a problem
    internal static let s6 = L10n.tr("Localizable", "SupportViewController.s6")
    /// Help and Feedback
    internal static let s7 = L10n.tr("Localizable", "SupportViewController.s7")
    /// Share your ideas and comments. Your feedback is important to us.
    internal static let s8 = L10n.tr("Localizable", "SupportViewController.s8")
    /// Please describe your problem in detail. We'll come back to you as soon as possible.
    internal static let s9 = L10n.tr("Localizable", "SupportViewController.s9")
  }

  internal enum SyncViewController {
    /// Loading your wallet
    internal static let s1 = L10n.tr("Localizable", "SyncViewController.s1")
    /// Creating your wallet
    internal static let s2 = L10n.tr("Localizable", "SyncViewController.s2")
    /// Warning
    internal static let s3 = L10n.tr("Localizable", "SyncViewController.s3")
    /// You haven't completed the setup for the Recovery Code you just used to recover your wallet.\n\nPlease visit the Security Center to back up your wallet with a new Recovery Code, and make sure you finish the setup this time.\n\nAs soon as you create a new Recovery Code, the current one will be invalidated.\n
    internal static let s4 = L10n.tr("Localizable", "SyncViewController.s4")
    /// GOT IT!
    internal static let s5 = L10n.tr("Localizable", "SyncViewController.s5")
  }

  internal enum TaprootActivatedPopup {
    /// You can now send and receive payments using Taproot addresses. Your payments will be cheaper and less traceable.
    internal static let description = L10n.tr("Localizable", "TaprootActivatedPopup.description")
    /// EXCELLENT
    internal static let ok = L10n.tr("Localizable", "TaprootActivatedPopup.ok")
    /// Taproot is live!
    internal static let title = L10n.tr("Localizable", "TaprootActivatedPopup.title")
  }

  internal enum TaprootActivationSlides {
    /// You haven't activated Taproot yet. You can restart this process later.
    internal static let abortDescription = L10n.tr("Localizable", "TaprootActivationSlides.abortDescription")
    /// Leave activation?
    internal static let abortTitle = L10n.tr("Localizable", "TaprootActivationSlides.abortTitle")
    /// Taproot is one of the most anticipated upgrades in bitcoin.\n\nStarting with cheaper and less traceable payments, Taproot is setting the stage for massive innovation in bitcoin.
    internal static let description1 = L10n.tr("Localizable", "TaprootActivationSlides.description1")
    /// Taproot uses new scripts to create the addresses where you'll receive funds.\n\nTo recover those funds in an emergency, these scripts need to be included in your Emergency Kit.
    internal static let description2 = L10n.tr("Localizable", "TaprootActivationSlides.description2")
    /// Keep total control over your funds by updating your Emergency Kit before ever using Taproot.\n\nThe updated Kit replaces the one you already have, but your Recovery Code doesn't change.
    internal static let description3 = L10n.tr("Localizable", "TaprootActivationSlides.description3")
    /// UPDATE YOUR KIT
    internal static let finish = L10n.tr("Localizable", "TaprootActivationSlides.finish")
    /// Leave
    internal static let leave = L10n.tr("Localizable", "TaprootActivationSlides.leave")
    /// Stay
    internal static let stay = L10n.tr("Localizable", "TaprootActivationSlides.stay")
    /// A giant leap for bitcoin
    internal static let title1 = L10n.tr("Localizable", "TaprootActivationSlides.title1")
    /// Enabled by powerful scripts
    internal static let title2 = L10n.tr("Localizable", "TaprootActivationSlides.title2")
    /// Completely secure
    internal static let title3 = L10n.tr("Localizable", "TaprootActivationSlides.title3")
  }

  internal enum TargetedFeeTableViewCell {
    /// Less than %@
    internal static func s1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TargetedFeeTableViewCell.s1", String(describing: p1))
    }
  }

  internal enum TitleTableViewCell {
    /// What's this?
    internal static let s1 = L10n.tr("Localizable", "TitleTableViewCell.s1")
  }

  internal enum TransactionListEmptyView {
    /// Receive your first payment and get it started!
    internal static let description = L10n.tr("Localizable", "TransactionListEmptyView.description")
    /// Receive
    internal static let descriptionCta = L10n.tr("Localizable", "TransactionListEmptyView.descriptionCta")
    /// Your payment history will appear here
    internal static let title = L10n.tr("Localizable", "TransactionListEmptyView.title")
  }

  internal enum TransactionListViewController {
    /// Transactions
    internal static let vcTitle = L10n.tr("Localizable", "TransactionListViewController.vcTitle")
  }

  internal enum UIBarButtonItem {
    /// %@ of %@
    internal static func s1(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "UIBarButtonItem.s1", String(describing: p1), String(describing: p2))
    }
  }

  internal enum UnifiedAdvancedOptionsView {
    /// Settings
    internal static let header = L10n.tr("Localizable", "UnifiedAdvancedOptionsView.header")
  }

  internal enum UpdateAppViewController {
    /// Update Required
    internal static let s1 = L10n.tr("Localizable", "UpdateAppViewController.s1")
    /// This version is too old. You need to update your Muun app.
    internal static let s2 = L10n.tr("Localizable", "UpdateAppViewController.s2")
    /// UPDATE APP
    internal static let s3 = L10n.tr("Localizable", "UpdateAppViewController.s3")
  }

  internal enum VerifyEmergencyKitView {
    /// DONE
    internal static let done = L10n.tr("Localizable", "VerifyEmergencyKitView.done")
  }

  internal enum VerifyRecoveryCodeViewController {
    /// Confirm your Recovery Code
    internal static let s1 = L10n.tr("Localizable", "VerifyRecoveryCodeViewController.s1")
    /// Wrong Recovery Code. Please try again.
    internal static let s2 = L10n.tr("Localizable", "VerifyRecoveryCodeViewController.s2")
    /// CONFIRM RECOVERY CODE
    internal static let s3 = L10n.tr("Localizable", "VerifyRecoveryCodeViewController.s3")
  }

  internal enum WaitForEmailView {
    /// Verifying...
    internal static let s1 = L10n.tr("Localizable", "WaitForEmailView.s1")
    /// Open your latest email.
    internal static let s2 = L10n.tr("Localizable", "WaitForEmailView.s2")
    /// OPEN EMAIL CLIENT
    internal static let s3 = L10n.tr("Localizable", "WaitForEmailView.s3")
    /// Open your latest email. The email verification failed because the link you used expired. Click the link in the latest email you received.
    internal static let s4 = L10n.tr("Localizable", "WaitForEmailView.s4")
  }

  internal enum WelcomePopUpView {
    /// LET'S GO
    internal static let button = L10n.tr("Localizable", "WelcomePopUpView.button")
    /// You created a new wallet.\nWelcome to Muun!
    internal static let message = L10n.tr("Localizable", "WelcomePopUpView.message")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
