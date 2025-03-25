//
//  CopyRandomInvoiceDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit

class CopyRandomInvoiceDebugExecutable: DebugExecutable {

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        let (invoice, _) = TestLapp.getLightningInvoice(satoshis: "1000")
        UIPasteboard.general.string = invoice
        completion()
    }

    func getTitleForCell() -> String {
        return "Save random invoice on clipboard"
    }
}
