//
//  MoneyMateWidgets.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import WidgetKit
import SwiftUI

@main
struct MoneyMateWidgets: WidgetBundle {
    var body: some Widget {
        CurrencyRateWidget()
        FavoriteCurrenciesWidget()
        CurrencyChartWidget()
    }
}

// MARK: - Preview Support

struct WidgetPreviewData {
    static let sampleCurrencies = [
        Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
        Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8),
        Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", rate: 41.12, changePercentage: 2.1),
        Currency(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", rate: 0.22, changePercentage: -0.3),
        Currency(code: "CHF", name: "Swiss Franc", flag: "🇨🇭", rate: 37.89, changePercentage: 0.5),
        Currency(code: "AUD", name: "Australian Dollar", flag: "🇦🇺", rate: 21.67, changePercentage: 1.8)
    ]
    
    static let sampleChartData: [ChartDataPoint] = {
        let baseValue = 32.45
        return (0..<24).map { i in
            let date = Calendar.current.date(byAdding: .hour, value: -24 + i, to: Date()) ?? Date()
            let value = baseValue + sin(Double(i) * 0.3) * 0.5 + Double.random(in: -0.2...0.2)
            return ChartDataPoint(date: date, value: value, change: Double.random(in: -2...2))
        }
    }()
}