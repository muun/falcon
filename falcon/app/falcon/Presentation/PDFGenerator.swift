//
//  PDFGenerator.swift
//  falcon
//
//  Created by Manu Herrera on 07/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class PDFGenerator {

    // Generate PDF from an html string and store it locally
    static func getURL(html: String, fileName: String) -> URL {
        // 1. Create a print formatter
        let fmt = UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect
        let page = CGRect(
            x: 0,
            y: 0,
            width: 392,
            height: 1100
        ) // Size to fit the first page of the EK
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPageWithInfo(page, [:]) // Make the renderer use the page rect values
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        // 5. Write your file to the disk.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryURL = temporaryDirectoryURL.appendingPathComponent(fileName)
        pdfData.write(to: temporaryURL, atomically: true)

        return temporaryURL
    }

}
