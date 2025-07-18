//
//  GlobalCurrencyDatabase.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import Foundation

struct GlobalCurrencyDatabase {
    static let shared = GlobalCurrencyDatabase()
    
    private init() {}
    
    // MARK: - Global Currency Data
    
    let allCurrencies: [CurrencyInfo] = [
        // Major World Currencies
        CurrencyInfo(code: "USD", name: "US Dollar", flag: "🇺🇸", country: "United States", symbol: "$", isPopular: true, category: .major),
        CurrencyInfo(code: "EUR", name: "Euro", flag: "🇪🇺", country: "European Union", symbol: "€", isPopular: true, category: .major),
        CurrencyInfo(code: "GBP", name: "British Pound", flag: "🇬🇧", country: "United Kingdom", symbol: "£", isPopular: true, category: .major),
        CurrencyInfo(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", country: "Japan", symbol: "¥", isPopular: true, category: .major),
        CurrencyInfo(code: "CHF", name: "Swiss Franc", flag: "🇨🇭", country: "Switzerland", symbol: "Fr", isPopular: true, category: .major),
        CurrencyInfo(code: "CAD", name: "Canadian Dollar", flag: "🇨🇦", country: "Canada", symbol: "C$", isPopular: true, category: .major),
        CurrencyInfo(code: "AUD", name: "Australian Dollar", flag: "🇦🇺", country: "Australia", symbol: "A$", isPopular: true, category: .major),
        CurrencyInfo(code: "NZD", name: "New Zealand Dollar", flag: "🇳🇿", country: "New Zealand", symbol: "NZ$", isPopular: true, category: .major),
        
        // Turkish Lira
        CurrencyInfo(code: "TRY", name: "Turkish Lira", flag: "🇹🇷", country: "Turkey", symbol: "₺", isPopular: true, category: .major),
        
        // Asian Currencies
        CurrencyInfo(code: "CNY", name: "Chinese Yuan", flag: "🇨🇳", country: "China", symbol: "¥", isPopular: true, category: .asian),
        CurrencyInfo(code: "KRW", name: "South Korean Won", flag: "🇰🇷", country: "South Korea", symbol: "₩", isPopular: true, category: .asian),
        CurrencyInfo(code: "INR", name: "Indian Rupee", flag: "🇮🇳", country: "India", symbol: "₹", isPopular: true, category: .asian),
        CurrencyInfo(code: "SGD", name: "Singapore Dollar", flag: "🇸🇬", country: "Singapore", symbol: "S$", isPopular: true, category: .asian),
        CurrencyInfo(code: "HKD", name: "Hong Kong Dollar", flag: "🇭🇰", country: "Hong Kong", symbol: "HK$", isPopular: true, category: .asian),
        CurrencyInfo(code: "TWD", name: "Taiwan Dollar", flag: "🇹🇼", country: "Taiwan", symbol: "NT$", isPopular: false, category: .asian),
        CurrencyInfo(code: "THB", name: "Thai Baht", flag: "🇹🇭", country: "Thailand", symbol: "฿", isPopular: false, category: .asian),
        CurrencyInfo(code: "MYR", name: "Malaysian Ringgit", flag: "🇲🇾", country: "Malaysia", symbol: "RM", isPopular: false, category: .asian),
        CurrencyInfo(code: "IDR", name: "Indonesian Rupiah", flag: "🇮🇩", country: "Indonesia", symbol: "Rp", isPopular: false, category: .asian),
        CurrencyInfo(code: "PHP", name: "Philippine Peso", flag: "🇵🇭", country: "Philippines", symbol: "₱", isPopular: false, category: .asian),
        CurrencyInfo(code: "VND", name: "Vietnamese Dong", flag: "🇻🇳", country: "Vietnam", symbol: "₫", isPopular: false, category: .asian),
        
        // European Currencies
        CurrencyInfo(code: "NOK", name: "Norwegian Krone", flag: "🇳🇴", country: "Norway", symbol: "kr", isPopular: false, category: .european),
        CurrencyInfo(code: "SEK", name: "Swedish Krona", flag: "🇸🇪", country: "Sweden", symbol: "kr", isPopular: false, category: .european),
        CurrencyInfo(code: "DKK", name: "Danish Krone", flag: "🇩🇰", country: "Denmark", symbol: "kr", isPopular: false, category: .european),
        CurrencyInfo(code: "PLN", name: "Polish Zloty", flag: "🇵🇱", country: "Poland", symbol: "zł", isPopular: false, category: .european),
        CurrencyInfo(code: "CZK", name: "Czech Koruna", flag: "🇨🇿", country: "Czech Republic", symbol: "Kč", isPopular: false, category: .european),
        CurrencyInfo(code: "HUF", name: "Hungarian Forint", flag: "🇭🇺", country: "Hungary", symbol: "Ft", isPopular: false, category: .european),
        CurrencyInfo(code: "RON", name: "Romanian Leu", flag: "🇷🇴", country: "Romania", symbol: "lei", isPopular: false, category: .european),
        CurrencyInfo(code: "BGN", name: "Bulgarian Lev", flag: "🇧🇬", country: "Bulgaria", symbol: "лв", isPopular: false, category: .european),
        CurrencyInfo(code: "HRK", name: "Croatian Kuna", flag: "🇭🇷", country: "Croatia", symbol: "kn", isPopular: false, category: .european),
        CurrencyInfo(code: "RSD", name: "Serbian Dinar", flag: "🇷🇸", country: "Serbia", symbol: "din", isPopular: false, category: .european),
        CurrencyInfo(code: "RUB", name: "Russian Ruble", flag: "🇷🇺", country: "Russia", symbol: "₽", isPopular: false, category: .european),
        CurrencyInfo(code: "UAH", name: "Ukrainian Hryvnia", flag: "🇺🇦", country: "Ukraine", symbol: "₴", isPopular: false, category: .european),
        
        // Middle Eastern Currencies
        CurrencyInfo(code: "SAR", name: "Saudi Riyal", flag: "🇸🇦", country: "Saudi Arabia", symbol: "﷼", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "AED", name: "UAE Dirham", flag: "🇦🇪", country: "United Arab Emirates", symbol: "د.إ", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "QAR", name: "Qatari Riyal", flag: "🇶🇦", country: "Qatar", symbol: "﷼", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "KWD", name: "Kuwaiti Dinar", flag: "🇰🇼", country: "Kuwait", symbol: "د.ك", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "BHD", name: "Bahraini Dinar", flag: "🇧🇭", country: "Bahrain", symbol: "د.ب", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "OMR", name: "Omani Rial", flag: "🇴🇲", country: "Oman", symbol: "﷼", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "JOD", name: "Jordanian Dinar", flag: "🇯🇴", country: "Jordan", symbol: "د.ا", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "LBP", name: "Lebanese Pound", flag: "🇱🇧", country: "Lebanon", symbol: "£", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "IRR", name: "Iranian Rial", flag: "🇮🇷", country: "Iran", symbol: "﷼", isPopular: false, category: .middleEastern),
        CurrencyInfo(code: "ILS", name: "Israeli Shekel", flag: "🇮🇱", country: "Israel", symbol: "₪", isPopular: false, category: .middleEastern),
        
        // African Currencies
        CurrencyInfo(code: "ZAR", name: "South African Rand", flag: "🇿🇦", country: "South Africa", symbol: "R", isPopular: false, category: .african),
        CurrencyInfo(code: "EGP", name: "Egyptian Pound", flag: "🇪🇬", country: "Egypt", symbol: "£", isPopular: false, category: .african),
        CurrencyInfo(code: "NGN", name: "Nigerian Naira", flag: "🇳🇬", country: "Nigeria", symbol: "₦", isPopular: false, category: .african),
        CurrencyInfo(code: "MAD", name: "Moroccan Dirham", flag: "🇲🇦", country: "Morocco", symbol: "د.م.", isPopular: false, category: .african),
        CurrencyInfo(code: "TND", name: "Tunisian Dinar", flag: "🇹🇳", country: "Tunisia", symbol: "د.ت", isPopular: false, category: .african),
        CurrencyInfo(code: "KES", name: "Kenyan Shilling", flag: "🇰🇪", country: "Kenya", symbol: "KSh", isPopular: false, category: .african),
        CurrencyInfo(code: "GHS", name: "Ghanaian Cedi", flag: "🇬🇭", country: "Ghana", symbol: "GH₵", isPopular: false, category: .african),
        
        // Latin American Currencies
        CurrencyInfo(code: "BRL", name: "Brazilian Real", flag: "🇧🇷", country: "Brazil", symbol: "R$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "MXN", name: "Mexican Peso", flag: "🇲🇽", country: "Mexico", symbol: "$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "ARS", name: "Argentine Peso", flag: "🇦🇷", country: "Argentina", symbol: "$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "CLP", name: "Chilean Peso", flag: "🇨🇱", country: "Chile", symbol: "$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "COP", name: "Colombian Peso", flag: "🇨🇴", country: "Colombia", symbol: "$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "PEN", name: "Peruvian Sol", flag: "🇵🇪", country: "Peru", symbol: "S/", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "UYU", name: "Uruguayan Peso", flag: "🇺🇾", country: "Uruguay", symbol: "$", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "BOB", name: "Bolivian Boliviano", flag: "🇧🇴", country: "Bolivia", symbol: "Bs", isPopular: false, category: .latinAmerican),
        CurrencyInfo(code: "VES", name: "Venezuelan Bolívar", flag: "🇻🇪", country: "Venezuela", symbol: "Bs", isPopular: false, category: .latinAmerican),
        
        // Cryptocurrencies
        CurrencyInfo(code: "BTC", name: "Bitcoin", flag: "₿", country: "Digital", symbol: "₿", isPopular: true, category: .crypto),
        CurrencyInfo(code: "ETH", name: "Ethereum", flag: "⟠", country: "Digital", symbol: "Ξ", isPopular: true, category: .crypto),
        CurrencyInfo(code: "LTC", name: "Litecoin", flag: "Ł", country: "Digital", symbol: "Ł", isPopular: false, category: .crypto),
        CurrencyInfo(code: "XRP", name: "XRP", flag: "✗", country: "Digital", symbol: "XRP", isPopular: false, category: .crypto),
        CurrencyInfo(code: "ADA", name: "Cardano", flag: "₳", country: "Digital", symbol: "₳", isPopular: false, category: .crypto),
        
        // Other Notable Currencies
        CurrencyInfo(code: "ISK", name: "Icelandic Króna", flag: "🇮🇸", country: "Iceland", symbol: "kr", isPopular: false, category: .other),
        CurrencyInfo(code: "LKR", name: "Sri Lankan Rupee", flag: "🇱🇰", country: "Sri Lanka", symbol: "Rs", isPopular: false, category: .other),
        CurrencyInfo(code: "BDT", name: "Bangladeshi Taka", flag: "🇧🇩", country: "Bangladesh", symbol: "৳", isPopular: false, category: .other),
        CurrencyInfo(code: "PKR", name: "Pakistani Rupee", flag: "🇵🇰", country: "Pakistan", symbol: "Rs", isPopular: false, category: .other),
        CurrencyInfo(code: "AFN", name: "Afghan Afghani", flag: "🇦🇫", country: "Afghanistan", symbol: "؋", isPopular: false, category: .other),
        CurrencyInfo(code: "ALL", name: "Albanian Lek", flag: "🇦🇱", country: "Albania", symbol: "L", isPopular: false, category: .other),
        CurrencyInfo(code: "AMD", name: "Armenian Dram", flag: "🇦🇲", country: "Armenia", symbol: "֏", isPopular: false, category: .other),
        CurrencyInfo(code: "AZN", name: "Azerbaijani Manat", flag: "🇦🇿", country: "Azerbaijan", symbol: "₼", isPopular: false, category: .other),
        CurrencyInfo(code: "GEL", name: "Georgian Lari", flag: "🇬🇪", country: "Georgia", symbol: "₾", isPopular: false, category: .other),
        CurrencyInfo(code: "KZT", name: "Kazakhstani Tenge", flag: "🇰🇿", country: "Kazakhstan", symbol: "₸", isPopular: false, category: .other),
        CurrencyInfo(code: "KGS", name: "Kyrgyzstani Som", flag: "🇰🇬", country: "Kyrgyzstan", symbol: "с", isPopular: false, category: .other),
        CurrencyInfo(code: "TJS", name: "Tajikistani Somoni", flag: "🇹🇯", country: "Tajikistan", symbol: "ЅМ", isPopular: false, category: .other),
        CurrencyInfo(code: "TMT", name: "Turkmenistani Manat", flag: "🇹🇲", country: "Turkmenistan", symbol: "m", isPopular: false, category: .other),
        CurrencyInfo(code: "UZS", name: "Uzbekistani Som", flag: "🇺🇿", country: "Uzbekistan", symbol: "so'm", isPopular: false, category: .other),
        CurrencyInfo(code: "BYN", name: "Belarusian Ruble", flag: "🇧🇾", country: "Belarus", symbol: "Br", isPopular: false, category: .other),
        CurrencyInfo(code: "MDL", name: "Moldovan Leu", flag: "🇲🇩", country: "Moldova", symbol: "L", isPopular: false, category: .other),
    ]
    
    // MARK: - Helper Methods
    
    func getCurrencies(by category: CurrencyCategory) -> [CurrencyInfo] {
        return allCurrencies.filter { $0.category == category }
    }
    
    func getPopularCurrencies() -> [CurrencyInfo] {
        return allCurrencies.filter { $0.isPopular }
    }
    
    func searchCurrencies(query: String) -> [CurrencyInfo] {
        let lowercaseQuery = query.lowercased()
        return allCurrencies.filter { currency in
            currency.name.lowercased().contains(lowercaseQuery) ||
            currency.code.lowercased().contains(lowercaseQuery) ||
            currency.country.lowercased().contains(lowercaseQuery)
        }
    }
    
    func getCurrency(by code: String) -> CurrencyInfo? {
        return allCurrencies.first { $0.code == code }
    }
    
    func getAllCurrencyCodes() -> [String] {
        return allCurrencies.map { $0.code }
    }
    
    func getCurrenciesByRegion() -> [CurrencyCategory: [CurrencyInfo]] {
        return Dictionary(grouping: allCurrencies, by: { $0.category })
    }
}

// MARK: - Currency Information Model

struct CurrencyInfo: Identifiable, Codable, Hashable {
    let id: UUID
    let code: String
    let name: String
    let flag: String
    let country: String
    let symbol: String
    let isPopular: Bool
    let category: CurrencyCategory
    
    init(code: String, name: String, flag: String, country: String, symbol: String, isPopular: Bool, category: CurrencyCategory) {
        self.id = UUID()
        self.code = code
        self.name = name
        self.flag = flag
        self.country = country
        self.symbol = symbol
        self.isPopular = isPopular
        self.category = category
    }
    
    var displayName: String {
        return "\(name) (\(code))"
    }
    
    var fullDescription: String {
        return "\(name) - \(country)"
    }
}

// MARK: - Currency Categories

enum CurrencyCategory: String, CaseIterable, Codable {
    case major = "Ana Para Birimleri"
    case asian = "Asya Para Birimleri"
    case european = "Avrupa Para Birimleri"
    case middleEastern = "Orta Doğu Para Birimleri"
    case african = "Afrika Para Birimleri"
    case latinAmerican = "Latin Amerika Para Birimleri"
    case crypto = "Kripto Para Birimleri"
    case other = "Diğer Para Birimleri"
    
    var systemImage: String {
        switch self {
        case .major: return "star.fill"
        case .asian: return "globe.asia.australia.fill"
        case .european: return "globe.europe.africa.fill"
        case .middleEastern: return "globe.asia.australia.fill"
        case .african: return "globe.europe.africa.fill"
        case .latinAmerican: return "globe.americas.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .other: return "globe"
        }
    }
    
    var color: String {
        switch self {
        case .major: return "blue"
        case .asian: return "green"
        case .european: return "purple"
        case .middleEastern: return "orange"
        case .african: return "red"
        case .latinAmerican: return "pink"
        case .crypto: return "yellow"
        case .other: return "gray"
        }
    }
}