//
//  Currency.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import SwiftData

@Model
final class Currency {
    var code: String
    var name: String
    var symbol: String
    var flag: String
    var country: String
    var rate: Double
    var change24h: Double
    var trend: String
    var isFavorite: Bool = false
    var isVisible: Bool = true
    var category: String
    var timestamp: Date
    var isCryptocurrency: Bool = false
    
    init(
        code: String,
        name: String,
        symbol: String,
        flag: String,
        country: String = "",
        rate: Double,
        change24h: Double,
        trend: String,
        isFavorite: Bool = false,
        isVisible: Bool = true,
        category: String = "major",
        isCryptocurrency: Bool = false,
        timestamp: Date = Date()
    ) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.flag = flag
        self.country = country
        self.rate = rate
        self.change24h = change24h
        self.trend = trend
        self.isFavorite = isFavorite
        self.isVisible = isVisible
        self.category = category
        self.isCryptocurrency = isCryptocurrency
        self.timestamp = timestamp
    }
}

// MARK: - Computed Properties for Compatibility
extension Currency {
    var changePercentage: Double {
        return change24h
    }
}

// MARK: - Convenience Initializer
extension Currency {
    convenience init(code: String, name: String, flag: String, rate: Double, changePercentage: Double) {
        self.init(
            code: code,
            name: name,
            symbol: Currency.getSymbol(for: code),
            flag: flag,
            country: "",
            rate: rate,
            change24h: changePercentage,
            trend: changePercentage >= 0 ? "up" : "down",
            isCryptocurrency: Currency.isCryptocurrency(code)
        )
    }
    
    private static func getSymbol(for code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "TRY": return "₺"
        case "JPY": return "¥"
        case "CAD": return "C$"
        case "AUD": return "A$"
        case "CHF": return "Fr"
        case "SEK": return "kr"
        case "NOK": return "kr"
        case "DKK": return "kr"
        default: return code
        }
    }
    
    static func isCryptocurrency(_ code: String) -> Bool {
        return ["BTC", "ETH", "LTC", "XRP", "ADA"].contains(code)
    }
}

// MARK: - Mock Data
extension Currency {
    static let mockCurrencies: [Currency] = [
        Currency(
            code: "USD",
            name: "US Dollar",
            symbol: "$",
            flag: "🇺🇸",
            country: "United States",
            rate: 1.0,
            change24h: 0.12,
            trend: "up",
            category: "major",
            isCryptocurrency: false
        ),
        Currency(
            code: "EUR",
            name: "Euro",
            symbol: "€",
            flag: "🇪🇺",
            country: "European Union",
            rate: 0.92,
            change24h: -0.08,
            trend: "down",
            category: "major",
            isCryptocurrency: false
        ),
        Currency(
            code: "GBP",
            name: "British Pound",
            symbol: "£",
            flag: "🇬🇧",
            country: "United Kingdom",
            rate: 0.79,
            change24h: 0.23,
            trend: "up",
            category: "major",
            isCryptocurrency: false
        ),
        Currency(
            code: "TRY",
            name: "Turkish Lira",
            symbol: "₺",
            flag: "🇹🇷",
            country: "Turkey",
            rate: 32.45,
            change24h: -0.45,
            trend: "down",
            category: "major",
            isCryptocurrency: false
        ),
        Currency(
            code: "JPY",
            name: "Japanese Yen",
            symbol: "¥",
            flag: "🇯🇵",
            country: "Japan",
            rate: 149.85,
            change24h: 0.31,
            trend: "up",
            category: "major",
            isCryptocurrency: false
        ),
        Currency(
            code: "CAD",
            name: "Canadian Dollar",
            symbol: "C$",
            flag: "🇨🇦",
            country: "Canada",
            rate: 1.36,
            change24h: 0.18,
            trend: "up",
            category: "major",
            isCryptocurrency: false
        )
    ]
}