//
//  NotificationParser.swift
//  core
//
//  Created by Juan Pablo Civile on 31/05/2019.
//

import Foundation

public enum NotificationParser {

    public static func parseReport(_ data: Data, decrypter: OperationMetadataDecrypter) throws -> NotificationReport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601

        let report = try decoder.decode(NotificationReportJsonContainer.self, from: data).message

        return NotificationReport(previousId: report.previousId,
                                  maximumId: report.maximumId,
                                  preview: report.preview.toModel(decrypter: decrypter))
    }

}
