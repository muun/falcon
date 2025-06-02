//
//  AsciiUtilsTests.swift
//  falconTests
//
//  Created by Franco Mucci on 09/04/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import XCTest

@testable import Muun

final class AsciiUtilsTests: XCTestCase {

    private let asciiSanitizer = AsciiUtils()

    func testToSafeAsciiWithLanguages() {
        let input = [
            "ascii: Hello word!!",
            "japanese: ドメイン名例",
            "japaneseWithAscii: MajiでKoiする5秒前",
            "already encoded japanese: \u{30c9}\u{30e1}\u{30a4}\u{30f3}\u{540d}\u{4f8b}",
            "korean: 도메인",
            "thai: ยจฆฟคฏข",
            "russian: правда",
            "emoji: 😉",
            "non encoded: \\\\ud83d9",
            "non-ascii mixup: 「 Б ü æ α 例 αβγ 」"
        ].joined(separator: "\n")

        let expected = """
        ascii: Hello word!!
        japanese: \\u30C9\\u30E1\\u30A4\\u30F3\\u540D\\u4F8B
        japaneseWithAscii: Maji\\u3067Koi\\u3059\\u308B5\\u79D2\\u524D
        already encoded japanese: \\u30C9\\u30E1\\u30A4\\u30F3\\u540D\\u4F8B
        korean: \\uB3C4\\uBA54\\uC778
        thai: \\u0E22\\u0E08\\u0E06\\u0E1F\\u0E04\\u0E0F\\u0E02
        russian: \\u043F\\u0440\\u0430\\u0432\\u0434\\u0430
        emoji: \\uD83D\\uDE09
        non encoded: \\\\ud83d9
        non-ascii mixup: \\u300C \\u0411 \\u00FC \\u00E6 \\u03B1 \\u4F8B \\u03B1\\u03B2\\u03B3 \\u300D
        """

        let result = asciiSanitizer.toSafeAscii(input)
        XCTAssertEqual(result, expected)
    }

    func testToSafeAsciiWithJsonLikeResponse() {
        let actualResponse = """
        {
          "epochInMilliseconds": 1734567549279,
          "batteryLevel": 92,
          "maxBatteryLevel": 100,
          "batteryHealth": "GOOD",
          "batteryDischargePrediction": -1,
          "batteryState": "UNPLUGGED",
          "totalInternalStorage": 3087986688,
          "freeInternalStorage": 866512896,
          "freeExternalStorage": [
            530092032,
            75595776
          ],
          "totalExternalStorage": [
            18224549888,
            2438987776
          ],
          "totalRamStorage": 1922134016,
          "freeRamStorage": 519774208,
          "dataState": "DATA_DISCONNECTED",
          "simStates": [
            "SIM_STATE_READY",
            "SIM_STATE_READY"
          ],
          "networkTransport": "WIFI",
          "androidUptimeMillis": 450455711,
          "androidElapsedRealtimeMillis": 787550180,
          "androidBootCount": 980,
          "language": "es_ES",
          "timeZoneOffsetInSeconds": -14400,
          "telephonyNetworkRegion": "VE",
          "simRegion": "ve",
          "appDataDir": "/data/user/0/io.muun.apollo",
          "vpnState": 0,
          "appImportance": 230,
          "displayMetrics": {
            "density": 1.75,
            "densityDpi": 280,
            "widthPixels": 720,
            "heightPixels": 1422,
            "xdpi": 281.353,
            "ydpi": 283.028
          },
          "usbConnected": 0,
          "usbPersistConfig": "mtp",
          "bridgeEnabled": 0,
          "bridgeDaemonStatus": "stopped",
          "developerEnabled": 1,
          "proxyHttp": "",
          "proxyHttps": "",
          "proxySocks": "",
          "autoDateTime": 1,
          "autoTimeZone": 1,
          "timeZoneId": "America/Caracas",
          "androidDateFormat": "d/M/yy",
          "regionCode": "ES",
          "androidCalendarIdentifier": "gregory",
          "androidMobileRxTraffic": 0,
          "androidSimOperatorId": "73404",
          "androidSimOperatorName": "Corporación Digitel",
          "androidMobileOperatorId": "73402",
          "mobileOperatorName": "DIGITEL",
          "androidMobileRoaming": false,
          "androidMobileDataStatus": 0,
          "androidMobileRadioType": 1,
          "androidMobileDataActivity": 2,
          "androidNetworkLink": {
            "interfaceName": "wlan0",
            "routesSize": 3,
            "routesInterfaces": [
              "wlan0"
            ],
            "hasGatewayRoute": 1,
            "dnsAddresses": [
              "192.168.0.1"
            ],
            "linkHttpProxyHost": ""
          }
        }
        """

        let expectedEncodedResponse = """
        {
          "epochInMilliseconds": 1734567549279,
          "batteryLevel": 92,
          "maxBatteryLevel": 100,
          "batteryHealth": "GOOD",
          "batteryDischargePrediction": -1,
          "batteryState": "UNPLUGGED",
          "totalInternalStorage": 3087986688,
          "freeInternalStorage": 866512896,
          "freeExternalStorage": [
            530092032,
            75595776
          ],
          "totalExternalStorage": [
            18224549888,
            2438987776
          ],
          "totalRamStorage": 1922134016,
          "freeRamStorage": 519774208,
          "dataState": "DATA_DISCONNECTED",
          "simStates": [
            "SIM_STATE_READY",
            "SIM_STATE_READY"
          ],
          "networkTransport": "WIFI",
          "androidUptimeMillis": 450455711,
          "androidElapsedRealtimeMillis": 787550180,
          "androidBootCount": 980,
          "language": "es_ES",
          "timeZoneOffsetInSeconds": -14400,
          "telephonyNetworkRegion": "VE",
          "simRegion": "ve",
          "appDataDir": "/data/user/0/io.muun.apollo",
          "vpnState": 0,
          "appImportance": 230,
          "displayMetrics": {
            "density": 1.75,
            "densityDpi": 280,
            "widthPixels": 720,
            "heightPixels": 1422,
            "xdpi": 281.353,
            "ydpi": 283.028
          },
          "usbConnected": 0,
          "usbPersistConfig": "mtp",
          "bridgeEnabled": 0,
          "bridgeDaemonStatus": "stopped",
          "developerEnabled": 1,
          "proxyHttp": "",
          "proxyHttps": "",
          "proxySocks": "",
          "autoDateTime": 1,
          "autoTimeZone": 1,
          "timeZoneId": "America/Caracas",
          "androidDateFormat": "d/M/yy",
          "regionCode": "ES",
          "androidCalendarIdentifier": "gregory",
          "androidMobileRxTraffic": 0,
          "androidSimOperatorId": "73404",
          "androidSimOperatorName": "Corporaci\\u00F3n Digitel",
          "androidMobileOperatorId": "73402",
          "mobileOperatorName": "DIGITEL",
          "androidMobileRoaming": false,
          "androidMobileDataStatus": 0,
          "androidMobileRadioType": 1,
          "androidMobileDataActivity": 2,
          "androidNetworkLink": {
            "interfaceName": "wlan0",
            "routesSize": 3,
            "routesInterfaces": [
              "wlan0"
            ],
            "hasGatewayRoute": 1,
            "dnsAddresses": [
              "192.168.0.1"
            ],
            "linkHttpProxyHost": ""
          }
        }
        """

        let result = asciiSanitizer.toSafeAscii(actualResponse)
        XCTAssertEqual(result, expectedEncodedResponse)
    }
}
