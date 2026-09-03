//
//  MuunTheme.swift
//  falcon
//
//  Top-level facade for Falcon's design system. Feature code should consume
//  tokens via this enum (e.g. `MuunTheme.Color.Text.bodyPrimary`,
//  `MuunTheme.Spacing.md`) — never reach into `MuunPrimitives` or
//  `MuunAliases` directly.
//
//  Layer model (mirrors the shared Figma token library):
//
//      MuunPrimitives ──► MuunAliases ──► MuunTheme
//      (raw palette)      (semantic       (component-ready
//                          + light/dark)   tokens)
//

import UIKit

enum MuunTheme {

    enum Color {
        typealias Text = MuunAliases.Text
        typealias Surface = MuunAliases.Surface
        typealias Icon = MuunAliases.Icon
        typealias Border = MuunAliases.Border
        typealias Pill = MuunAliases.Pill
    }

    /// Spacing scale aliases (3xs … 3xl). Values come from `MuunPrimitives.Scale`.
    enum Spacing {
        static let xs3: CGFloat = MuunPrimitives.Scale.s50    // 2
        static let xs2: CGFloat = MuunPrimitives.Scale.s100   // 4
        static let  xs: CGFloat = MuunPrimitives.Scale.s200   // 8
        static let  sm: CGFloat = MuunPrimitives.Scale.s300   // 12
        static let  md: CGFloat = MuunPrimitives.Scale.s400   // 16
        static let  lg: CGFloat = MuunPrimitives.Scale.s500   // 20
        static let  xl: CGFloat = MuunPrimitives.Scale.s600   // 24
        static let xl2: CGFloat = MuunPrimitives.Scale.s700   // 28
        static let xl3: CGFloat = MuunPrimitives.Scale.s800   // 32
    }

    /// Off-scale values shared by more than one screen, kept here as migration
    /// scaffolding until they earn a real design-system home (Figma scale or a
    /// Component token). Single-use values do NOT belong here — keep those as
    /// private constants in their owning class.
    enum Legacy {
        static let s6:   CGFloat = 6
        static let s18:  CGFloat = 18
        static let s40:  CGFloat = 40
        static let s44:  CGFloat = 44
        static let s52:  CGFloat = 52
        static let s220: CGFloat = 220
    }

    enum Font {

        enum Heading {
            static let h1 = UIFont.systemFont(
                ofSize: 32,
                weight: MuunAliases.FontWeight.headingDefault
            )
            static let h2 = UIFont.systemFont(
                ofSize: 28,
                weight: MuunAliases.FontWeight.headingDefault
            )
            static let h3 = UIFont.systemFont(
                ofSize: 24,
                weight: MuunAliases.FontWeight.headingDefault
            )
            static let h4 = UIFont.systemFont(
                ofSize: 20,
                weight: MuunAliases.FontWeight.headingDefault
            )
        }

        enum Body {
            static let lg = UIFont.systemFont(
                ofSize: 18,
                weight: MuunAliases.FontWeight.textDefault
            )
            static let md = UIFont.systemFont(
                ofSize: 16,
                weight: MuunAliases.FontWeight.textDefault
            )
            static let mdStrong = UIFont.systemFont(
                ofSize: 16,
                weight: MuunAliases.FontWeight.textStrong
            )
            static let sm = UIFont.systemFont(
                ofSize: 14,
                weight: MuunAliases.FontWeight.textDefault
            )
            static let xs = UIFont.systemFont(
                ofSize: 12,
                weight: MuunAliases.FontWeight.textDefault
            )
        }

        enum LineHeight {
            static let h1: CGFloat = 38
            static let h2: CGFloat = 28
            static let h3: CGFloat = 24
            static let h4: CGFloat = 22
            static let bodyLg: CGFloat = 28
            static let bodyMd: CGFloat = 24
            static let bodySm: CGFloat = 22
        }
    }

    enum Component {

        enum Button {
            static let cornerRadius: CGFloat   = MuunPrimitives.Scale.s100
            static let primary: UIColor        = MuunAliases.Surface.actionPrimary
            static let secondary: UIColor      = MuunAliases.Surface.actionSecondary
            static let textPrimary: UIColor    = MuunAliases.Text.onActionPrimary
            static let iconPrimary: UIColor    = MuunAliases.Text.onActionPrimary
            static let textSecondary: UIColor  = MuunAliases.Text.onActionSecondary
            static let iconSecondary: UIColor  = MuunAliases.Text.onActionSecondary
        }

        enum TextField {
            static let background: UIColor  = MuunAliases.Surface.field
            static let placeholder: UIColor = MuunAliases.Text.bodySecondary
        }

        enum BottomSheet {
            static let cornerRadius: CGFloat            = MuunPrimitives.Scale.s400
            static let background: UIColor              = MuunAliases.Surface.background
            static let illustrationBackground: UIColor  = MuunAliases.Surface.sheetIllustration
        }

        enum Card {
            static let surfacePrimary: UIColor  = MuunAliases.Surface.actionPrimary
            static let surfaceSelected: UIColor = MuunAliases.Surface.background
            static let borderSelected: UIColor  = MuunAliases.Border.selected
        }

        enum ProviderPill {
            static let text: UIColor          = MuunAliases.Pill.text
            static let border: UIColor        = MuunAliases.Pill.border
            static let textSelected: UIColor  = MuunAliases.Text.action
            static let background: UIColor    = MuunAliases.Surface.background
        }
    }
}
