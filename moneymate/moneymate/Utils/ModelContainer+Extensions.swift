//
//  ModelContainer+Extensions.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftData
import Foundation

extension ModelContainer {
    static var sample: ModelContainer = {
        let schema = Schema([
            Currency.self,
            PriceAlert.self,
            FavoriteCurrency.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("Failed to create sample ModelContainer: \(error)")
        }
    }()
    
    @MainActor
    static var sampleWithData: ModelContainer {
        let container = ModelContainer.sample
        let context = container.mainContext
        
        // Sample currencies
        let sampleCurrencies = [
            Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
            Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8),
            Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", rate: 41.12, changePercentage: 2.1)
        ]
        
        for currency in sampleCurrencies {
            context.insert(currency)
        }
        
        // Sample price alerts
        let sampleAlerts = [
            PriceAlert(currencyCode: "USD", targetPrice: 33.0, alertType: .above),
            PriceAlert(currencyCode: "EUR", targetPrice: 34.0, alertType: .below)
        ]
        
        for alert in sampleAlerts {
            context.insert(alert)
        }
        
        // Sample favorites
        let sampleFavorites = [
            FavoriteCurrency(currencyCode: "USD", position: 0, isWatchlistItem: false),
            FavoriteCurrency(currencyCode: "EUR", position: 1, isWatchlistItem: false),
            FavoriteCurrency(currencyCode: "GBP", position: 0, isWatchlistItem: true)
        ]
        
        for favorite in sampleFavorites {
            context.insert(favorite)
        }
        
        try? context.save()
        return container
    }
}

extension ModelContext {
    @MainActor
    static var sample: ModelContext {
        return ModelContainer.sampleWithData.mainContext
    }
}