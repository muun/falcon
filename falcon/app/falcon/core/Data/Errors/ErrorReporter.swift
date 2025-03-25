//
//  ErrorReport.swift
//  Created by Federico Bond on 11/05/2021.
//

import Foundation
import UIKit

public class ErrorReporter {

    public func getSubjectAndBody(
        error: MuunError,
        user: User?,
        extraKeys: [String: String] = [:]
    ) -> (String, String) {

        let supportId = user?.getSupportId()
        let subject = "Muun error report (\(supportId ?? "anonymous"))"
        let body = """
            Error: \(error.errorDescription!)
            Extra keys: \(extraKeys)
            App version: \(Constant.buildVersion)
            SupportId: \(supportId ?? "Not logged in")
            OS Version: \(UIDevice.current.systemVersion)
            DeviceModel: \(UIDevice.current.model)
        """
        return (subject, body)
    }

}
