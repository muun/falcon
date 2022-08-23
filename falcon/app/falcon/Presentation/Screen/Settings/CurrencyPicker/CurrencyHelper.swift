//
//  CurrencyHelper.swift
//  falcon
//
//  Created by Manu Herrera on 21/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class CurrencyHelper: Resolver {

    static let preferences: Preferences = resolve()
    static let dollarCurrency: Currency = FiatCurrency(code: "USD", symbol: "$", name: "US Dollar", flag: "🇺🇸")
    static let euroCurrency: Currency = FiatCurrency(code: "EUR", symbol: "€", name: "Eurozone Euro", flag: "🇪🇺")
    static let bitcoinCurrency = BitcoinCurrency()

    static var allCurrencies: [String: Currency] {
        var allCurrencies: [String: Currency] = [:]

        func add(_ currency: Currency) {
            allCurrencies[currency.code] = currency
        }

        add(FiatCurrency(code: "AED", symbol: "د.إ", name: "UAE Dirham", flag: "🇦🇪"))
        add(FiatCurrency(code: "AFN", symbol: "؋", name: "Afghan Afghani", flag: "🇦🇫"))
        add(FiatCurrency(code: "ALL", symbol: "LEK", name: "Albanian Lek", flag: "🇦🇱"))
        add(FiatCurrency(code: "AMD", symbol: "Դրամ", name: "Armenian Dram", flag: "🇦🇲"))
        add(FiatCurrency(code: "ANG", symbol: "ƒ", name: "Netherlands Antillean Guilder", flag: "🇨🇼"))
        add(FiatCurrency(code: "AOA", symbol: "Kz", name: "Angolan Kwanza", flag: "🇦🇴"))
        add(FiatCurrency(code: "ARS", symbol: "$", name: "Argentine Peso", flag: "🇦🇷"))
        add(FiatCurrency(code: "AUD", symbol: "$", name: "Australian Dollar", flag: "🇦🇺"))
        add(FiatCurrency(code: "AWG", symbol: "ƒ", name: "Aruban Florin", flag: "🇦🇼"))
        add(FiatCurrency(code: "AZN", symbol: "ман", name: "Azerbaijani Manat", flag: "🇦🇿"))
        add(FiatCurrency(code: "BAM", symbol: "KM", name: "Bosnia-Herzegovina Convertible Mark", flag: "🇧🇦"))
        add(FiatCurrency(code: "BBD", symbol: "$", name: "Barbadian Dollar", flag: "🇧🇧"))
        add(FiatCurrency(code: "BDT", symbol: "৳", name: "Bangladeshi Taka", flag: "🇧🇩"))
        add(FiatCurrency(code: "BGN", symbol: "лв", name: "Bulgarian Lev", flag: "🇧🇬"))
        add(FiatCurrency(code: "BHD", symbol: ".د.ب", name: "Bahraini Dinar", flag: "🇧🇭"))
        add(FiatCurrency(code: "BIF", symbol: "FBu", name: "Burundian Franc", flag: "🇧🇮"))
        add(FiatCurrency(code: "BMD", symbol: "$", name: "Bermudan Dollar", flag: "🇧🇲"))
        add(FiatCurrency(code: "BND", symbol: "$", name: "Brunei Dollar", flag: "🇧🇳"))
        add(FiatCurrency(code: "BOB", symbol: "Bs", name: "Bolivian Boliviano", flag: "🇧🇴"))
        add(FiatCurrency(code: "BRL", symbol: "R$", name: "Brazilian Real", flag: "🇧🇷"))
        add(FiatCurrency(code: "BSD", symbol: "$", name: "Bahamian Dollar", flag: "🇧🇸"))
        add(FiatCurrency(code: "BTN", symbol: "Nu", name: "Bhutanese Ngultrum", flag: "🇧🇹"))
        add(FiatCurrency(code: "BWP", symbol: "P", name: "Botswanan Pula", flag: "🇧🇼"))
        add(FiatCurrency(code: "BYN", symbol: "BYN", name: "Belarusian Ruble", flag: "🇧🇾"))
        add(FiatCurrency(code: "BZD", symbol: "BZ$", name: "Belize Dollar", flag: "🇧🇿"))
        add(FiatCurrency(code: "CAD", symbol: "$", name: "Canadian Dollar", flag: "🇨🇦"))
        add(FiatCurrency(code: "CDF", symbol: "FC", name: "Congolese Franc", flag: "🇨🇩"))
        add(FiatCurrency(code: "CHF", symbol: "CHF", name: "Swiss Franc", flag: "🇨🇭"))
        add(FiatCurrency(code: "CLF", symbol: "UF", name: "Chilean Unit of Account (UF)", flag: "🇨🇱"))
        add(FiatCurrency(code: "CLP", symbol: "$", name: "Chilean Peso", flag: "🇨🇱"))
        add(FiatCurrency(code: "CNY", symbol: "¥", name: "Chinese Yuan", flag: "🇨🇳"))
        add(FiatCurrency(code: "COP", symbol: "$", name: "Colombian Peso", flag: "🇨🇴"))
        add(FiatCurrency(code: "CRC", symbol: "₡", name: "Costa Rican Colón", flag: "🇨🇷"))
        add(FiatCurrency(code: "CUP", symbol: "$", name: "Cuban Peso", flag: "🇨🇺"))
        add(FiatCurrency(code: "CVE", symbol: "$", name: "Cape Verdean Escudo", flag: "🇨🇻"))
        add(FiatCurrency(code: "CZK", symbol: "Kč", name: "Czech Koruna", flag: "🇨🇿"))
        add(FiatCurrency(code: "DJF", symbol: "Fdj", name: "Djiboutian Franc", flag: "🇩🇯"))
        add(FiatCurrency(code: "DKK", symbol: "kr", name: "Danish Krone", flag: "🇩🇰"))
        add(FiatCurrency(code: "DOP", symbol: "RD$", name: "Dominican Peso", flag: "🇩🇴"))
        add(FiatCurrency(code: "DZD", symbol: "دج", name: "Algerian Dinar", flag: "🇩🇿"))
        add(FiatCurrency(code: "EGP", symbol: "£", name: "Egyptian Pound", flag: "🇪🇬"))
        add(FiatCurrency(code: "ERN", symbol: "Nfk", name: "Eritrean Nakfa", flag: "🇪🇷"))
        add(FiatCurrency(code: "ETB", symbol: "Br", name: "Ethiopian Birr", flag: "🇪🇹"))
        add(euroCurrency)
        add(FiatCurrency(code: "FJD", symbol: "$", name: "Fijian Dollar", flag: "🇫🇯"))
        add(FiatCurrency(code: "FKP", symbol: "£", name: "Falkland Islands Pound", flag: "🇫🇰"))
        add(FiatCurrency(code: "GBP", symbol: "£", name: "Pound Sterling", flag: "🇬🇧"))
        add(FiatCurrency(code: "GEL", symbol: "ლ", name: "Georgian Lari", flag: "🇬🇪"))
        add(FiatCurrency(code: "GHS", symbol: "¢", name: "Ghanaian Cedi", flag: "🇬🇭"))
        add(FiatCurrency(code: "GIP", symbol: "£", name: "Gibraltar Pound", flag: "🇬🇮"))
        add(FiatCurrency(code: "GMD", symbol: "D", name: "Gambian Dalasi", flag: "🇬🇲"))
        add(FiatCurrency(code: "GNF", symbol: "FG", name: "Guinean Franc", flag: "🇬🇳"))
        add(FiatCurrency(code: "GTQ", symbol: "Q", name: "Guatemalan Quetzal", flag: "🇬🇹"))
        add(FiatCurrency(code: "GYD", symbol: "$", name: "Guyanaese Dollar", flag: "🇬🇾"))
        add(FiatCurrency(code: "HKD", symbol: "$", name: "Hong Kong Dollar", flag: "🇭🇰"))
        add(FiatCurrency(code: "HNL", symbol: "L", name: "Honduran Lempira", flag: "🇭🇳"))
        add(FiatCurrency(code: "HRK", symbol: "kn", name: "Croatian Kuna", flag: "🇭🇷"))
        add(FiatCurrency(code: "HTG", symbol: "G", name: "Haitian Gourde", flag: "🇭🇹"))
        add(FiatCurrency(code: "HUF", symbol: "Ft", name: "Hungarian Forint", flag: "🇭🇺"))
        add(FiatCurrency(code: "IDR", symbol: "Rp", name: "Indonesian Rupiah", flag: "🇮🇩"))
        add(FiatCurrency(code: "ILS", symbol: "₪", name: "Israeli Shekel", flag: "🇮🇱"))
        add(FiatCurrency(code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳"))
        add(FiatCurrency(code: "IQD", symbol: "ع.د", name: "Iraqi Dinar", flag: "🇮🇶"))
        add(FiatCurrency(code: "IRR", symbol: "﷼", name: "Iranian Rial", flag: "🇮🇷"))
        add(FiatCurrency(code: "ISK", symbol: "kr", name: "Icelandic Króna", flag: "🇮🇸"))
        add(FiatCurrency(code: "JMD", symbol: "J$", name: "Jamaican Dollar", flag: "🇯🇲"))
        add(FiatCurrency(code: "JOD", symbol: "د.ا", name: "Jordanian Dinar", flag: "🇯🇴"))
        add(FiatCurrency(code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵"))
        add(FiatCurrency(code: "KES", symbol: "KSh", name: "Kenyan Shilling", flag: "🇰🇪"))
        add(FiatCurrency(code: "KGS", symbol: "Лв", name: "Kyrgystani Som", flag: "🇰🇬"))
        add(FiatCurrency(code: "KHR", symbol: "៛", name: "Cambodian Riel", flag: "🇰🇭"))
        add(FiatCurrency(code: "KMF", symbol: "CF", name: "Comorian Franc", flag: "🇰🇲"))
        add(FiatCurrency(code: "KPW", symbol: "₩", name: "North Korean Won", flag: "🇰🇵"))
        add(FiatCurrency(code: "KRW", symbol: "₩", name: "South Korean Won", flag: "🇰🇷"))
        add(FiatCurrency(code: "KWD", symbol: "د.ك", name: "Kuwaiti Dinar", flag: "🇰🇼"))
        add(FiatCurrency(code: "KYD", symbol: "$", name: "Cayman Islands Dollar", flag: "🇰🇾"))
        add(FiatCurrency(code: "KZT", symbol: "лв", name: "Kazakhstani Tenge", flag: "🇰🇿"))
        add(FiatCurrency(code: "LAK", symbol: "₭", name: "Laotian Kip", flag: "🇱🇦"))
        add(FiatCurrency(code: "LBP", symbol: "£", name: "Lebanese Pound", flag: "🇱🇧"))
        add(FiatCurrency(code: "LKR", symbol: "₨", name: "Sri Lankan Rupee", flag: "🇱🇰"))
        add(FiatCurrency(code: "LRD", symbol: "$", name: "Liberian Dollar", flag: "🇱🇷"))
        add(FiatCurrency(code: "LSL", symbol: "L", name: "Lesotho Loti", flag: "🇱🇸"))
        add(FiatCurrency(code: "LYD", symbol: "ل.د", name: "Libyan Dinar", flag: "🇱🇾"))
        add(FiatCurrency(code: "MAD", symbol: "د.م", name: "Moroccan Dirham", flag: "🇲🇦"))
        add(FiatCurrency(code: "MDL", symbol: "L", name: "Moldovan Leu", flag: "🇲🇩"))
        add(FiatCurrency(code: "MGA", symbol: "Ar", name: "Malagasy Ariary", flag: "🇲🇬"))
        add(FiatCurrency(code: "MKD", symbol: "ден", name: "Macedonian Denar", flag: "🇲🇰"))
        add(FiatCurrency(code: "MMK", symbol: "K", name: "Myanma Kyat", flag: "🇲🇲"))
        add(FiatCurrency(code: "MNT", symbol: "₮", name: "Mongolian Tugrik", flag: "🇲🇳"))
        add(FiatCurrency(code: "MOP", symbol: "MOP$", name: "Macanese Pataca", flag: "🇲🇴"))
        add(FiatCurrency(code: "MRO", symbol: "UM", name: "Mauritanian Ouguiya", flag: "🇲🇷"))
        add(FiatCurrency(code: "MUR", symbol: "₨", name: "Mauritian Rupee", flag: "🇲🇺"))
        add(FiatCurrency(code: "MVR", symbol: "MRf", name: "Maldivian Rufiyaa", flag: "🇲🇻"))
        add(FiatCurrency(code: "MWK", symbol: "MK", name: "Malawian Kwacha", flag: "🇲🇼"))
        add(FiatCurrency(code: "MXN", symbol: "$", name: "Mexican Peso", flag: "🇲🇽"))
        add(FiatCurrency(code: "MYR", symbol: "RM", name: "Malaysian Ringgit", flag: "🇲🇾"))
        add(FiatCurrency(code: "MZN", symbol: "MT", name: "Mozambican Metical", flag: "🇲🇿"))
        add(FiatCurrency(code: "NAD", symbol: "MT", name: "Namibian Dollar", flag: "🇳🇦"))
        add(FiatCurrency(code: "NGN", symbol: "₦", name: "Nigerian Naira", flag: "🇳🇬"))
        add(FiatCurrency(code: "NIO", symbol: "C", name: "Nicaraguan Córdoba", flag: "🇳🇮"))
        add(FiatCurrency(code: "NOK", symbol: "kr", name: "Norwegian Krone", flag: "🇳🇴"))
        add(FiatCurrency(code: "NPR", symbol: "₨", name: "Nepalese Rupee", flag: "🇳🇵"))
        add(FiatCurrency(code: "NZD", symbol: "$", name: "New Zealand Dollar", flag: "🇳🇿"))
        add(FiatCurrency(code: "OMR", symbol: "﷼", name: "Omani Rial", flag: "🇴🇲"))
        add(FiatCurrency(code: "PAB", symbol: "B/.", name: "Panamanian Balboa", flag: "🇵🇦"))
        add(FiatCurrency(code: "PEN", symbol: "S/.", name: "Peruvian Nuevo Sol", flag: "🇵🇪"))
        add(FiatCurrency(code: "PGK", symbol: "K", name: "Papua New Guinean Kina", flag: "🇵🇬"))
        add(FiatCurrency(code: "PHP", symbol: "₱", name: "Philippine Peso", flag: "🇵🇭"))
        add(FiatCurrency(code: "PKR", symbol: "₨", name: "Pakistani Rupee", flag: "🇵🇰"))
        add(FiatCurrency(code: "PLN", symbol: "zł", name: "Polish Zloty", flag: "🇵🇱"))
        add(FiatCurrency(code: "PYG", symbol: "Gs", name: "Paraguayan Guarani", flag: "🇵🇾"))
        add(FiatCurrency(code: "QAR", symbol: "﷼", name: "Qatari Rial", flag: "🇶🇦"))
        add(FiatCurrency(code: "RON", symbol: "lei", name: "Romanian Leu", flag: "🇷🇴"))
        add(FiatCurrency(code: "RSD", symbol: "Дин.", name: "Serbian Dinar", flag: "🇷🇸"))
        add(FiatCurrency(code: "RUB", symbol: "ру", name: "Russian Ruble", flag: "🇷🇺"))
        add(FiatCurrency(code: "RWF", symbol: "RF", name: "Rwandan Franc", flag: "🇷🇼"))
        add(FiatCurrency(code: "SAR", symbol: "﷼", name: "Saudi Riyal", flag: "🇸🇦"))
        add(FiatCurrency(code: "SBD", symbol: "$", name: "Solomon Islands Dollar", flag: "🇸🇧"))
        add(FiatCurrency(code: "SCR", symbol: "₨", name: "Seychellois Rupee", flag: "🇸🇨"))
        add(FiatCurrency(code: "SDP", symbol: ".ج.س", name: "Sudanese Pound", flag: "🇸🇩"))
        add(FiatCurrency(code: "SEK", symbol: "kr", name: "Swedish Krona", flag: "🇸🇪"))
        add(FiatCurrency(code: "SGD", symbol: "$", name: "Singapore Dollar", flag: "🇸🇬"))
        add(FiatCurrency(code: "SHP", symbol: "£", name: "Saint Helena Pound", flag: "🇸🇭"))
        add(FiatCurrency(code: "SLL", symbol: "Le", name: "Sierra Leonean Leone", flag: "🇸🇱"))
        add(FiatCurrency(code: "SOS", symbol: "S", name: "Somali Shilling", flag: "🇸🇴"))
        add(FiatCurrency(code: "SRD", symbol: "$", name: "Surinamese Dollar", flag: "🇸🇷"))
        add(FiatCurrency(code: "SSP", symbol: "£", name: "South Sudanese Pound", flag: "🇸🇸"))
        add(FiatCurrency(code: "STD", symbol: "Db", name: "São Tomé and Príncipe Dobra", flag: "🇸🇹"))
        add(FiatCurrency(code: "SYP", symbol: "LS", name: "Syrian Pound", flag: "🇸🇾"))
        add(FiatCurrency(code: "SZL", symbol: "L", name: "Swazi Lilangeni", flag: "🇸🇿"))
        add(FiatCurrency(code: "THB", symbol: "฿", name: "Thai Baht", flag: "🇹🇭"))
        add(FiatCurrency(code: "TJS", symbol: "SM", name: "Tajikistani Somoni", flag: "🇹🇯"))
        add(FiatCurrency(code: "TMT", symbol: "m", name: "Turkmenistani Manat", flag: "🇹🇲"))
        add(FiatCurrency(code: "TND", symbol: "د.ت", name: "Tunisian Dinar", flag: "🇹🇳"))
        add(FiatCurrency(code: "TOP", symbol: "T$", name: "Tongan Paʻanga", flag: "🇹🇴"))
        add(FiatCurrency(code: "TRY", symbol: "₤", name: "Turkish Lira", flag: "🇹🇷"))
        add(FiatCurrency(code: "TTD", symbol: "TT$", name: "Trinidad and Tobago Dollar", flag: "🇹🇹"))
        add(FiatCurrency(code: "TWD", symbol: "NT$", name: "New Taiwan Dollar", flag: "🇹🇼"))
        add(FiatCurrency(code: "TZS", symbol: "x/y", name: "Tanzanian Shilling", flag: "🇹🇿"))
        add(FiatCurrency(code: "UAH", symbol: "₴", name: "Ukrainian Hryvnia", flag: "🇺🇦"))
        add(FiatCurrency(code: "UGX", symbol: "USh", name: "Ugandan Shilling", flag: "🇺🇬"))
        add(dollarCurrency)
        add(FiatCurrency(code: "UYU", symbol: "$U", name: "Uruguayan Peso", flag: "🇺🇾"))
        add(FiatCurrency(code: "UZS", symbol: "лв", name: "Uzbekistan Som", flag: "🇺🇿"))
        add(FiatCurrency(code: "VEF", symbol: "Bs.F", name: "Venezuelan Bolívar Fuerte", flag: "🇻🇪"))
        add(FiatCurrency(code: "VES", symbol: "Bs.S", name: "Venezuelan Bolívar Soberano", flag: "🇻🇪"))
        add(FiatCurrency(code: "VND", symbol: "₫", name: "Vietnamese Dong", flag: "🇻🇳"))
        add(FiatCurrency(code: "VUV", symbol: "Vt", name: "Vanuatu Vatu", flag: "🇻🇺"))
        add(FiatCurrency(code: "WST", symbol: "WS$", name: "Samoan Tala", flag: "🇼🇸"))
        add(FiatCurrency(code: "XAF", symbol: "FCFA", name: "CFA Franc BEAC", flag: nil))
        add(FiatCurrency(code: "XAG", symbol: "oz.", name: "Silver (troy ounce)", flag: "🥈"))
        add(FiatCurrency(code: "XAU", symbol: "oz.", name: "Gold (troy ounce)", flag: "🥇"))
        add(FiatCurrency(code: "XCD", symbol: "$", name: "East Caribbean Dollar", flag: "🇦🇮"))
        add(FiatCurrency(code: "XOF", symbol: "CFA", name: "CFA Franc BCEAO", flag: nil))
        add(FiatCurrency(code: "XPF", symbol: "F", name: "CFP Franc", flag: "🇵🇫"))
        add(FiatCurrency(code: "YER", symbol: "﷼", name: "Yemeni Rial", flag: "🇾🇪"))
        add(FiatCurrency(code: "ZAR", symbol: "R", name: "South African Rand", flag: "🇿🇦"))
        add(FiatCurrency(code: "ZMW", symbol: "ZK", name: "Zambian Kwacha", flag: "🇿🇲"))
        add(FiatCurrency(code: "ZWL", symbol: "Z$", name: "Zimbabwean Dollar", flag: "🇿🇼"))

        add(bitcoinCurrency)

        return allCurrencies
    }

    static func currencyList(currencyCodes: [String]) -> [Currency] {
        let allCurrencies = CurrencyHelper.allCurrencies

        var currencies: [Currency] = []

        for code in currencyCodes where allCurrencies[code] != nil {
            currencies.append(allCurrencies[code]!)
        }

        return currencies.sorted { $0.name < $1.name }
    }

    static func readableCurrency(code: String) -> String {
        if let currency = allCurrencies[code] {
            let name = currency.name
            if let flag = currency.flag {
                return "\(flag) \(name)"
            }
            return name
        }

        return ""
    }

    static func string(for code: String) -> String {
        if code == bitcoinCurrency.code {
            return bitcoinCurrency.displayCode
        }

        return code
    }

    static func currencyForLocale() -> Currency {
        if let currencyCode = Locale.current.currencyCode {
            for currency in allCurrencies where currency.key == currencyCode {
                return currency.value
            }
        }
        // If we cannot find a currency for a currency code, we default to USD
        return dollarCurrency
    }
}
