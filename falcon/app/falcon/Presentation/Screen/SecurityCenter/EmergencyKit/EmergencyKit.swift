//
//  EmergencyKit.swift
//  falcon
//
//  Created by Federico Bond on 04/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Libwallet


class EmergencyKit {

    let verificationCode: String
    let url: URL
    let version: Int

    static func generate(data: EmergencyKitData) -> EmergencyKit {
        let input = LibwalletEKInput()
        input.firstEncryptedKey = data.userKey
        input.firstFingerprint = data.userFingerprint
        input.secondEncryptedKey = data.muunKey
        input.secondFingerprint = data.muunFingerprint

        do {
            let out = try doWithError({ error in
                LibwalletGenerateEmergencyKitHTML(input, NSLocale.current.languageCode, error)
            })

            let srcUrl = PDFGenerator.getURL(html: out.html, fileName: "emergency_kit_no_metadata.pdf")

            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let destUrl = temporaryDirectoryURL.appendingPathComponent("emergency_kit.pdf")

            _ = try doWithError({ error in
                LibwalletAddEmergencyKitMetadata(out.metadata, srcUrl.path, destUrl.path, error)
            })

            try FileManager.default.removeItem(at: srcUrl)

            return EmergencyKit(
                url: destUrl,
                verificationCode: out.verificationCode,
                version: out.version
            )
        } catch {
            Logger.fatal(error: error)
        }
    }

    private init(url: URL, verificationCode: String, version: Int) {
        self.url = url
        self.verificationCode = verificationCode
        self.version = version
    }

    func dispose() {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.log(.warn, "Could not remove emergency kit PDF")
        }
    }

    func generated() -> ExportEmergencyKit {
        return ExportEmergencyKit(
            lastExportedAt: Date(),
            verificationCode: verificationCode,
            verified: false,
            version: version,
            method: nil
        )
    }

    func exported(method: ExportEmergencyKit.Method) -> ExportEmergencyKit {
        return ExportEmergencyKit(
            lastExportedAt: Date(),
            verificationCode: verificationCode,
            verified: true,
            version: version,
            method: method
        )
    }
}
