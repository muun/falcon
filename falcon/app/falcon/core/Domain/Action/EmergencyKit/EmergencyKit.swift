//
//  EmergencyKit.swift
//  falcon
//
//  Created by Federico Bond on 04/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Libwallet

class EmergencyKit: Resolver {

    let verificationCode: String
    let url: URL
    let version: Int
    static let emergencyKitName = "emergency_kit.pdf"
    private static let walletService: WalletService = resolve()

    static func generate(data: EmergencyKitData, usingGoImplementation: Bool) -> EmergencyKit {
        let input = LibwalletEKInput()
        input.firstEncryptedKey = data.userKey
        input.firstFingerprint = data.userFingerprint
        input.secondEncryptedKey = data.muunKey
        input.secondFingerprint = data.muunFingerprint
        input.rcChecksum = data.rcChecksum

        if usingGoImplementation {
            return generatePDF(input)
        } else {
            return generateKitWithHTML(input)
        }
    }

    private static func generatePDF(_ input: LibwalletEKInput) -> EmergencyKit {
        do {
            let url = getEmergencyKitTempPath()

            // Convert LibwalletEKInput to EmergencyKitData for gRPC call
            let data = EmergencyKitData(
                userKey: input.firstEncryptedKey,
                userFingerprint: input.firstFingerprint,
                muunKey: input.secondEncryptedKey,
                muunFingerprint: input.secondFingerprint,
                rcChecksum: input.rcChecksum
            )

            let timeTracker: TimeTracker = EmergencyKit.resolve()
            let trace = timeTracker.start(.ekNewPdfGeneration)
            defer { trace.finish() }

            let result = try walletService.generateEmergencyKitPDF(
                data: data,
                outputPath: url.absoluteString,
                language: NSLocale.current.languageCode ?? "en"
            )
            addRenderProfiling(to: trace, from: result)

            return EmergencyKit(
                url: url,
                verificationCode: result.verificationCode,
                version: Int(result.version)
            )
        } catch {
            Logger.log(error: error) // find this error using the filename.
            return generateKitWithHTML(input)
        }
    }

    /// Forward libwallet's per-stage render profiling as children of the PDF-generation trace, so
    /// prod telemetry can validate the offline profiling against real devices.
    private static func addRenderProfiling(
        to trace: Trace,
        from response: Rpc_GenerateEmergencyKitPDFResponse
    ) {
        let p = response.profiling
        let children: [(EmergencyKitRenderChildTrace, Int64)] = [
            (.loadTranslations, p.loadTranslationsMs),
            (.registerFonts, p.registerFontsMs),
            (.registerImages, p.registerImagesMs),
            (.componentsRendering, p.componentsRenderingMs),
            (.createAndSaveOnDisk, p.createAndSaveOnDiskMs),
            (.totalHeapAllocated, p.totalHeapAllocatedBytes),
            (.totalObjectsAllocated, p.totalObjectsAllocated),
            (.embedMetadata, p.embedMetadataMs),
            (.totalInsideGo, p.totalInsideGoMs),
            (.kitSizeBytes, p.kitSizeBytes),
            (.drawIcons, p.drawIconsMs),
        ]
        for (child, value) in children {
            trace.addChild(child.rawValue, value: value)
        }
    }

    private static func generateKitWithHTML(_ input: LibwalletEKInput) -> EmergencyKit {
        let timeTracker: TimeTracker = EmergencyKit.resolve()
        let trace = timeTracker.start(.ekLegacyPdfGeneration)
        do {
            let out = try doWithError({ error in
                LibwalletGenerateEmergencyKitHTML(input, NSLocale.current.languageCode, error)
            })

            let srcUrl = PDFGenerator.getURL(
                html: out.html,
                fileName: "emergency_kit_no_metadata.pdf"
            )

            let destUrl = getEmergencyKitTempPath()

            _ = try doWithError({ error in
                LibwalletAddEmergencyKitMetadata(out.metadata, srcUrl.path, destUrl.path, error)
            })

            try FileManager.default.removeItem(at: srcUrl)

            let kit = EmergencyKit(
                url: destUrl,
                verificationCode: out.verificationCode,
                version: out.version
            )
            trace.finish()
            return kit
        } catch {
            Logger.fatal(error: error)
        }
    }

    private static func getEmergencyKitTempPath() -> URL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return temporaryDirectoryURL.appendingPathComponent(emergencyKitName)
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
