//
//  SlidesViewConfiguration.swift
//  falcon
//
//  Created by Juan Pablo Civile on 27/10/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import UIKit

struct SlidesViewConfiguration {
    struct Slide {
        let title: String
        let image: ImageAsset
        let description: String
    }

    let title: String?
    let finish: String
    let slides: [Slide]
    let screenEvent: String
    let abortTapped: (SlidesViewController) -> ()
    let finishTapped: (SlidesViewController) -> ()
}

extension SlidesViewConfiguration {

    static var exportKit = SlidesViewConfiguration(
        title: L10n.EmergencyKitSlides.s1,
        finish: L10n.EmergencyKitSlides.s2,
        slides: [
            Slide(
                title: L10n.EmergencyKitSlides.s4,
                image: Asset.Assets.emergencyKit1,
                description: L10n.EmergencyKitSlides.s12
            ),
            Slide(
                title: L10n.EmergencyKitSlides.s6,
                image: Asset.Assets.emergencyKit2,
                description: L10n.EmergencyKitSlides.s5
            ),
            Slide(
                title: L10n.EmergencyKitSlides.s7,
                image: Asset.Assets.emergencyKit3,
                description: L10n.EmergencyKitSlides.s13
            )
        ],
        screenEvent: "emergency_kit_slides",
        abortTapped: { vc in
            let desc = L10n.EmergencyKitSlides.s8
            let alert = UIAlertController(
                title: L10n.EmergencyKitSlides.s9,
                message: desc,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: L10n.EmergencyKitSlides.s10, style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))

            alert.addAction(UIAlertAction(title: L10n.EmergencyKitSlides.s11, style: .destructive, handler: { _ in
                vc.logEvent("emergency_kit_aborted")
                vc.navigationController!.popTo(type: SecurityCenterViewController.self)
            }))

            alert.view.tintColor = Asset.Colors.muunGrayDark.color

            vc.navigationController!.present(alert, animated: true)
        },
        finishTapped: { vc in
            vc.navigationController!.pushViewController(
                ShareEmergencyKitViewController(flow: .export),
                animated: true
            )

        }
    )

    static func taprootActivation(successFeedback: FeedbackModel) -> SlidesViewConfiguration {
        return SlidesViewConfiguration(
            title: nil,
            finish: L10n.TaprootActivationSlides.finish,
            slides: [
                Slide(
                    title: L10n.TaprootActivationSlides.title1,
                    image: Asset.Assets.taprootSlides1,
                    description: L10n.TaprootActivationSlides.description1
                ),
                Slide(
                    title: L10n.TaprootActivationSlides.title2,
                    image: Asset.Assets.taprootSlides2,
                    description: L10n.TaprootActivationSlides.description2
                ),
                Slide(
                    title: L10n.TaprootActivationSlides.title3,
                    image: Asset.Assets.taprootSlides3,
                    description: L10n.TaprootActivationSlides.description3
                )
            ],
            screenEvent: "taproot_slides",
            abortTapped: { vc in
                let alert = UIAlertController(
                    title: L10n.TaprootActivationSlides.abortTitle,
                    message: L10n.TaprootActivationSlides.abortDescription,
                    preferredStyle: .alert
                )

                let stayAction = UIAlertAction(title: L10n.TaprootActivationSlides.stay, style: .default, handler: { _ in
                    alert.dismiss(animated: true)
                })
                alert.addAction(stayAction)
                alert.preferredAction = stayAction

                alert.addAction(UIAlertAction(title: L10n.TaprootActivationSlides.leave, style: .destructive, handler: { _ in
                    vc.navigationController?.popToRootViewController(animated: true)
                }))

                vc.navigationController!.present(alert, animated: true)
            },
            finishTapped: { vc in
                vc.navigationController!.pushViewController(
                    ShareEmergencyKitViewController(flow: .update(feedback: successFeedback)),
                    animated: true
                )
            }
        )
    }

}
