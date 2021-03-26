// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let actionCardBackUp = ImageAsset(name: "action_card_back_up")
    internal static let actionCardReceive = ImageAsset(name: "action_card_receive")
    internal static let btcLogo = ImageAsset(name: "btc_logo")
    internal static let cameraPriming = ImageAsset(name: "camera_priming")
    internal static let changePassword = ImageAsset(name: "change_password")
    internal static let check = ImageAsset(name: "check")
    internal static let chevron = ImageAsset(name: "chevron")
    internal static let chevronAlt = ImageAsset(name: "chevron_alt")
    internal static let clock = ImageAsset(name: "clock")
    internal static let copy = ImageAsset(name: "copy")
    internal static let defaultFlag = ImageAsset(name: "default_flag")
    internal static let editPencil = ImageAsset(name: "edit_pencil")
    internal static let editPencilAlt = ImageAsset(name: "edit_pencil_alt")
    internal static let ekActivationCode = ImageAsset(name: "ek_activation_code")
    internal static let ekOptionDrive = ImageAsset(name: "ek_option_drive")
    internal static let ekOptionIcloud = ImageAsset(name: "ek_option_icloud")
    internal static let ekOptionManually = ImageAsset(name: "ek_option_manually")
    internal static let ekVerifyDrive = ImageAsset(name: "ek_verify_drive")
    internal static let ekVerifyIcloud = ImageAsset(name: "ek_verify_icloud")
    internal static let emailExpired = ImageAsset(name: "email_expired")
    internal static let emergencyKit1 = ImageAsset(name: "emergency_kit_1")
    internal static let emergencyKit2 = ImageAsset(name: "emergency_kit_2")
    internal static let emergencyKit3 = ImageAsset(name: "emergency_kit_3")
    internal static let emptyTransactions = ImageAsset(name: "empty_transactions")
    internal static let envelope = ImageAsset(name: "envelope")
    internal static let envelopeWithLock = ImageAsset(name: "envelope_with_lock")
    internal static let erase = ImageAsset(name: "erase")
    internal static let feedback = ImageAsset(name: "feedback")
    internal static let help = ImageAsset(name: "help")
    internal static let info = ImageAsset(name: "info")
    internal static let informationIcon = ImageAsset(name: "information_icon")
    internal static let mLogo = ImageAsset(name: "m_logo")
    internal static let navBack = ImageAsset(name: "nav_back")
    internal static let navClose = ImageAsset(name: "nav_close")
    internal static let notice = ImageAsset(name: "notice")
    internal static let notificationsPriming = ImageAsset(name: "notifications_priming")
    internal static let openArrow = ImageAsset(name: "open_arrow")
    internal static let passwordHide = ImageAsset(name: "password_hide")
    internal static let passwordShow = ImageAsset(name: "password_show")
    internal static let pendingClock = ImageAsset(name: "pending_clock")
    internal static let radioOption = ImageAsset(name: "radio_option")
    internal static let radioOptionSelected = ImageAsset(name: "radio_option_selected")
    internal static let rbfNotice = ImageAsset(name: "rbf_notice")
    internal static let recoveryCodeMissing = ImageAsset(name: "recovery_code_missing")
    internal static let securityCenter = ImageAsset(name: "security_center")
    internal static let settings = ImageAsset(name: "settings")
    internal static let share = ImageAsset(name: "share")
    internal static let shield = ImageAsset(name: "shield")
    internal static let shortcutReceive = ImageAsset(name: "shortcut_receive")
    internal static let shortcutSend = ImageAsset(name: "shortcut_send")
    internal static let stateError = ImageAsset(name: "state_error")
    internal static let success = ImageAsset(name: "success")
    internal static let tick = ImageAsset(name: "tick")
    internal static let toggleBalance = ImageAsset(name: "toggle_balance")
    internal static let warningHigh = ImageAsset(name: "warning_high")
    internal static let warningLow = ImageAsset(name: "warning_low")
    internal static let welcomeAstronaut = ImageAsset(name: "welcome_astronaut")
  }
  internal enum Colors {
    internal static let background = ColorAsset(name: "background")
    internal static let cardViewBorder = ColorAsset(name: "cardViewBorder")
    internal static let cellBackground = ColorAsset(name: "cellBackground")
    internal static let muunAlmostWhite = ColorAsset(name: "muunAlmostWhite")
    internal static let muunBlue = ColorAsset(name: "muunBlue")
    internal static let muunBlueLight = ColorAsset(name: "muunBlueLight")
    internal static let muunBluePale = ColorAsset(name: "muunBluePale")
    internal static let muunButtonLeft = ColorAsset(name: "muunButtonLeft")
    internal static let muunButtonRight = ColorAsset(name: "muunButtonRight")
    internal static let muunDisabled = ColorAsset(name: "muunDisabled")
    internal static let muunGrayDark = ColorAsset(name: "muunGrayDark")
    internal static let muunGrayLight = ColorAsset(name: "muunGrayLight")
    internal static let muunGreen = ColorAsset(name: "muunGreen")
    internal static let muunGreenOpsBadgeBackground = ColorAsset(name: "muunGreenOpsBadgeBackground")
    internal static let muunGreenOpsBadgeText = ColorAsset(name: "muunGreenOpsBadgeText")
    internal static let muunGreenPale = ColorAsset(name: "muunGreenPale")
    internal static let muunHomeBackgroundColor = ColorAsset(name: "muunHomeBackgroundColor")
    internal static let muunOverlay = ColorAsset(name: "muunOverlay")
    internal static let muunRed = ColorAsset(name: "muunRed")
    internal static let muunWarning = ColorAsset(name: "muunWarning")
    internal static let muunWarningRBF = ColorAsset(name: "muunWarningRBF")
    internal static let noticeBackground = ColorAsset(name: "noticeBackground")
    internal static let noticeBorder = ColorAsset(name: "noticeBorder")
    internal static let oddKeyRowBackground = ColorAsset(name: "oddKeyRowBackground")
    internal static let operationOutgoing = ColorAsset(name: "operationOutgoing")
    internal static let separator = ColorAsset(name: "separator")
    internal static let title = ColorAsset(name: "title")
    internal static let toastLeft = ColorAsset(name: "toastLeft")
    internal static let toastRight = ColorAsset(name: "toastRight")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
