//
//  WidgetConfiguration.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Intent Configuration for Widgets

struct CurrencySelectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Döviz Seç"
    static var description = IntentDescription("Widget için görüntülenecek dövizi seçin")
    
    @Parameter(title: "Döviz Kodu")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        WidgetDataProvider.shared.setPreferredChartCurrency(currencyCode)
        return .result()
    }
}

// MARK: - Widget Configuration Helpers

struct WidgetConfigurationHelper {
    static func getDisplayCurrencies() -> [String] {
        return ["USD", "EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "SEK", "NOK", "DKK"]
    }
    
    static func getCurrencyDisplayName(for code: String) -> String {
        let names: [String: String] = [
            "USD": "US Dollar",
            "EUR": "Euro",
            "GBP": "British Pound",
            "JPY": "Japanese Yen",
            "CHF": "Swiss Franc",
            "AUD": "Australian Dollar",
            "CAD": "Canadian Dollar",
            "SEK": "Swedish Krona",
            "NOK": "Norwegian Krone",
            "DKK": "Danish Krone"
        ]
        return names[code] ?? code
    }
    
    static func getCurrencyFlag(for code: String) -> String {
        let flags: [String: String] = [
            "USD": "🇺🇸",
            "EUR": "🇪🇺",
            "GBP": "🇬🇧",
            "JPY": "🇯🇵",
            "CHF": "🇨🇭",
            "AUD": "🇦🇺",
            "CAD": "🇨🇦",
            "SEK": "🇸🇪",
            "NOK": "🇳🇴",
            "DKK": "🇩🇰"
        ]
        return flags[code] ?? "💱"
    }
}

// MARK: - Widget Deep Link Support

struct WidgetDeepLink {
    enum Destination {
        case converter
        case favorites
        case charts(currency: String?)
        case alerts
        case specific(currency: String)
    }
    
    static func url(for destination: Destination) -> URL {
        let baseURL = "moneymate://"
        
        switch destination {
        case .converter:
            return URL(string: "\(baseURL)converter")!
        case .favorites:
            return URL(string: "\(baseURL)favorites")!
        case .charts(let currency):
            if let currency = currency {
                return URL(string: "\(baseURL)charts/\(currency)")!
            } else {
                return URL(string: "\(baseURL)charts")!
            }
        case .alerts:
            return URL(string: "\(baseURL)alerts")!
        case .specific(let currency):
            return URL(string: "\(baseURL)currency/\(currency)")!
        }
    }
}

// MARK: - Widget Error Handling

struct WidgetErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Hata")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Widget Loading View

struct WidgetLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
            
            Text("Yükleniyor...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Widget No Data View

struct WidgetNoDataView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.gray)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}