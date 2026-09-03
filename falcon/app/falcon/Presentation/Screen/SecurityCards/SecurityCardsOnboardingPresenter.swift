//
//  SecurityCardsOnboardingPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 17/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

final class SecurityCardsOnboardingPresenter<Delegate: BasePresenterDelegate>: BasePresenter<
    Delegate
> {

    private let setSecurityCardCountryAction: SetSecurityCardCountryAction = resolve()

    /// Records the country picked during onboarding as the shared security cards
    /// selection, so downstream screens (marketplace, shipping) default to it.
    func set(selectedCountry country: Country) {
        setSecurityCardCountryAction.run(country)
    }
}
