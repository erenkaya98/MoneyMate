//
//  WidgetDataProvider.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import Foundation
import SwiftData

actor WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private init() {}
    
    // MARK: - Currency Data
    
    func fetchLatestCurrencies() async -> [Currency] {
        // In a real app, this would fetch from the currency API
        // For now, return sample data with realistic variations
        let baseCurrencies = [
            ("USD", "US Dollar", "🇺🇸", 32.45),
            ("EUR", "Euro", "🇪🇺", 35.23),
            ("GBP", "British Pound", "🇬🇧", 41.12),
            ("JPY", "Japanese Yen", "🇯🇵", 0.22),
            ("CHF", "Swiss Franc", "🇨🇭", 37.89),
            ("AUD", "Australian Dollar", "🇦🇺", 21.67),
            ("CAD", "Canadian Dollar", "🇨🇦", 23.98),
            ("SEK", "Swedish Krona", "🇸🇪", 3.01)
        ]
        
        return baseCurrencies.map { (code, name, flag, baseRate) in
            let variation = Double.random(in: 0.95...1.05)
            let rate = baseRate * variation
            let change = Double.random(in: -3.0...3.0)
            
            return Currency(
                code: code,
                name: name,
                flag: flag,
                rate: rate,
                changePercentage: change
            )
        }
    }
    
    // MARK: - Favorites Data
    
    func fetchFavorites() async -> [Currency] {
        // In a real app, this would load from SwiftData
        let favoriteCodes = UserDefaults.standard.array(forKey: "widget_favorites") as? [String] ?? ["USD", "EUR", "GBP"]
        let allCurrencies = await fetchLatestCurrencies()
        
        return allCurrencies.filter { favoriteCodes.contains($0.code) }
    }
    
    func fetchWatchlist() async -> [Currency] {
        // In a real app, this would load from SwiftData
        let watchlistCodes = UserDefaults.standard.array(forKey: "widget_watchlist") as? [String] ?? ["JPY", "CHF"]
        let allCurrencies = await fetchLatestCurrencies()
        
        return allCurrencies.filter { watchlistCodes.contains($0.code) }
    }
    
    // MARK: - Chart Data
    
    func fetchChartData(for currencyCode: String, timeRange: ChartTimeRange) async -> [ChartDataPoint] {
        let baseRate = await getBaseRate(for: currencyCode)
        let pointCount = min(timeRange.pointCount, 50) // Limit for performance
        
        var data: [ChartDataPoint] = []
        let now = Date()
        
        for i in 0..<pointCount {
            let timeInterval: TimeInterval
            switch timeRange {
            case .day:
                timeInterval = Double(-pointCount + i) * 3600 // Hours
            case .week:
                timeInterval = Double(-pointCount + i) * 3600 * 4 // 4-hour intervals
            case .month:
                timeInterval = Double(-pointCount + i) * 86400 // Days
            case .threeMonths:
                timeInterval = Double(-pointCount + i) * 86400 * 3 // 3-day intervals
            }
            
            let date = Date(timeInterval: timeInterval, since: now)
            
            // Generate realistic price movement
            let timeProgress = Double(i) / Double(pointCount)
            let trend = sin(timeProgress * .pi * 2) * 0.02 // 2% trend cycle
            let noise = Double.random(in: -0.01...0.01) // 1% random noise
            let variation = trend + noise
            
            let value = baseRate * (1 + variation)
            let change = i > 0 ? ((value - data[i-1].value) / data[i-1].value) * 100 : 0
            
            data.append(ChartDataPoint(date: date, value: value, change: change))
        }
        
        return data
    }
    
    private func getBaseRate(for currencyCode: String) async -> Double {
        let currencies = await fetchLatestCurrencies()
        return currencies.first { $0.code == currencyCode }?.rate ?? 1.0
    }
    
    // MARK: - User Preferences
    
    func getPreferredChartCurrency() -> String {
        return UserDefaults.standard.string(forKey: "widget_chart_currency") ?? "USD"
    }
    
    func setPreferredChartCurrency(_ code: String) {
        UserDefaults.standard.set(code, forKey: "widget_chart_currency")
    }
    
    func updateFavorites(_ codes: [String]) {
        UserDefaults.standard.set(codes, forKey: "widget_favorites")
    }
    
    func updateWatchlist(_ codes: [String]) {
        UserDefaults.standard.set(codes, forKey: "widget_watchlist")
    }
}