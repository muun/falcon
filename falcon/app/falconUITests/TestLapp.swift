//
//  TestLapp.swift
//  falconUITests
//
//  Created by Manu Herrera on 07/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import UIKit

private let lappUrl = { () -> String in
    if Environment.current == .regtest {
        return "https://pub.reg.api.muun.wtf/lapp/"
    } else {
        return "http://localhost:7080/"
    }
}()

fileprivate func request<T>(_ urlString: String, timeout: TimeInterval = 60, _ processResponse: @escaping (Data) -> T) -> T {
    let url = URL(string: lappUrl + urlString)!
    var request = URLRequest(url: url)
    request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = timeout

    var result: T? = nil

    let semaphore = DispatchSemaphore(value: 0)

    let task = URLSession.shared.dataTask(with: request) { (body, response, error) in

        if error != nil, let response = response as? HTTPURLResponse, response.statusCode != 200 {
            preconditionFailure("request failed")
        } else if let body = body {
            result = processResponse(body)
        } else {
            preconditionFailure("empty body")
        }

        semaphore.signal()
    }

    task.resume()
    semaphore.wait()

    return result!
}

func getLightningInvoice(satoshis: String = "1500") -> (String, String) {

    let processResponse  = { (body: Data) -> (String, String) in
        if let htmlString = String(data: body, encoding: .utf8),
            let invoice = htmlString.slice(from: "<span>", to: "</span>"),
            let destination = htmlString.slice(from: "<p>", to: "</p>") {
            return (invoice, destination)
        }

        preconditionFailure("bad response")
    }

    let urlString = "/invoice?satoshis=\(satoshis)"

    return request(urlString, processResponse)
}


func generate(blocks: Int) {
    request("generate?blocks=\(blocks)", { _ in () })
}

func send(to address: String, amount: Decimal) {
    request("send?address=\(address)&amount=\(amount)", { _ in () })
}

func getBech32Address() -> String {
    return request("address", { body in
        String(data: body, encoding: .utf8)!
    })
}

func mempoolCount() -> Int {
    return request("mempoolSize", { body in
        let str = String(data: body, encoding: .utf8)!
        return Int(str)!
    })
}

func bip70Invoice() -> String {
    return request("bip70Invoice", { body in
        return String(data: body, encoding: .utf8)!
    })
}

func payWithLapp(invoice: String, amountInSats: Int64, onComplete: @escaping () -> ()) {

    DispatchQueue.global(qos: .background).async {
        request("payInvoice?invoice=\(invoice)&satoshis=\(amountInSats)", timeout: 3 * 60, { _ in () })
        onComplete()
    }
}

func dropLastTx() {

    DispatchQueue.global(qos: .background).async {
        request("dropLastTx", timeout: 3 * 60, { _ in () })
    }
}

func lnurlWithdraw(variant: String = "normal") -> String {
    return request("lnurl/withdrawStart?variant=\(variant)", { body in
        return String(data: body, encoding: .utf8)!
    })
}


extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
