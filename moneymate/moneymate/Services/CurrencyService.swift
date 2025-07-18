//
//  CurrencyService.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import Combine

@MainActor
final class CurrencyService: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let alternativeAPIURL = "https://api.fxratesapi.com/latest"
    private let exchangeAPIURL = "https://api.exchangerate-api.com/v4/latest/USD"
    
    // Cache için mevcut değerleri sakla
    private var lastKnownRates: [String: Double] = [:]
    private var lastUpdateTime: Date = Date()
    
    // Alert service reference
    var alertService: PriceAlertService?
    
    // Crypto service reference
    var cryptoService: CryptocurrencyService?
    
    init() {
        loadMockData()
        cacheCurrentRates()
    }
    
    func setAlertService(_ alertService: PriceAlertService) {
        self.alertService = alertService
    }
    
    func setCryptoService(_ cryptoService: CryptocurrencyService) {
        self.cryptoService = cryptoService
    }
    
    func loadMockData() {
        currencies = Currency.mockCurrencies
    }
    
    private func cacheCurrentRates() {
        lastKnownRates = Dictionary(uniqueKeysWithValues: currencies.map { ($0.code, $0.rate) })
        lastUpdateTime = Date()
    }
    
    func refreshRates() async {
        isLoading = true
        errorMessage = nil
        
        // Refresh crypto prices separately
        await cryptoService?.refreshCryptoPrices()
        
        do {
            let updatedCurrencies = try await fetchRealTimeRates()
            currencies = await updateCurrenciesWithCryptoPrices(updatedCurrencies)
            cacheCurrentRates()
            
            // Check price alerts
            alertService?.checkAlertsForCurrencies(currencies)
        } catch {
            errorMessage = "Failed to fetch rates: \(error.localizedDescription)"
            // Keep using stable mock data on error
            updateStableRates()
            
            // Still check alerts with updated mock data
            alertService?.checkAlertsForCurrencies(currencies)
        }
        
        isLoading = false
    }
    
    private func updateCurrenciesWithCryptoPrices(_ currencies: [Currency]) async -> [Currency] {
        guard let cryptoService = cryptoService else { return currencies }
        
        return currencies.map { currency in
            if currency.isCryptocurrency, let cryptoPrice = cryptoService.getCryptoPrice(for: currency.code) {
                // Use USD price for crypto to maintain consistency with other currencies
                let updatedCurrency = Currency(
                    code: currency.code,
                    name: currency.name,
                    symbol: currency.symbol,
                    flag: currency.flag,
                    country: currency.country,
                    rate: cryptoPrice.priceUSD, // Use USD price for crypto
                    change24h: cryptoPrice.change24hUSD,
                    trend: cryptoPrice.change24hUSD >= 0 ? "up" : "down",
                    isFavorite: currency.isFavorite,
                    isVisible: currency.isVisible,
                    category: currency.category,
                    isCryptocurrency: true
                )
                return updatedCurrency
            }
            return currency
        }
    }
    
    private func fetchRealTimeRates() async throws -> [Currency] {
        guard let url = URL(string: alternativeAPIURL) else {
            throw CurrencyError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        return currencies.compactMap { currency in
            guard let newRate = response.rates[currency.code] else { return currency }
            
            let oldRate = lastKnownRates[currency.code] ?? currency.rate
            let change24h = ((newRate - oldRate) / oldRate) * 100
            
            let updatedCurrency = Currency(
                code: currency.code,
                name: currency.name,
                symbol: currency.symbol,
                flag: currency.flag,
                country: currency.country,
                rate: newRate,
                change24h: change24h,
                trend: change24h > 0 ? "up" : "down",
                isFavorite: currency.isFavorite,
                isVisible: currency.isVisible,
                category: currency.category,
                isCryptocurrency: currency.isCryptocurrency
            )
            return updatedCurrency
        }
    }
    
    private func updateStableRates() {
        // Sadece trend'i güncelle, ana kurları değiştirme
        currencies = currencies.map { currency in
            let baseRate = lastKnownRates[currency.code] ?? currency.rate
            let timeElapsed = Date().timeIntervalSince(lastUpdateTime)
            
            // 24 saatlik değişim simülasyonu (daha gerçekçi)
            let dailyVariation = sin(timeElapsed / 86400) * 0.01 // %1 max variation
            let simulatedChange = dailyVariation * 100
            
            let updatedCurrency = Currency(
                code: currency.code,
                name: currency.name,
                symbol: currency.symbol,
                flag: currency.flag,
                country: currency.country,
                rate: baseRate,
                change24h: simulatedChange,
                trend: simulatedChange > 0 ? "up" : "down",
                isFavorite: currency.isFavorite,
                isVisible: currency.isVisible,
                category: currency.category,
                isCryptocurrency: currency.isCryptocurrency
            )
            return updatedCurrency
        }
    }
    
    func toggleFavorite(for currency: Currency) {
        if let index = currencies.firstIndex(where: { $0.code == currency.code }) {
            currencies[index].isFavorite.toggle()
        }
    }
    
    func convertCurrency(
        amount: Double,
        from: Currency,
        to: Currency
    ) -> Double {
        if from.code == to.code { return amount }
        
        // Handle crypto to crypto conversion
        if from.isCryptocurrency && to.isCryptocurrency {
            // Both are in USD, direct conversion
            return (amount / from.rate) * to.rate
        }
        
        // Handle crypto to fiat conversion
        if from.isCryptocurrency && !to.isCryptocurrency {
            // From crypto (USD) to fiat (rate from USD)
            let usdAmount = amount * from.rate
            return usdAmount / to.rate
        }
        
        // Handle fiat to crypto conversion
        if !from.isCryptocurrency && to.isCryptocurrency {
            // From fiat (rate from USD) to crypto (USD)
            let usdAmount = amount / from.rate
            return usdAmount / to.rate
        }
        
        // Handle fiat to fiat conversion (original logic)
        let usdAmount = amount / from.rate
        return usdAmount * to.rate
    }
    
    func addCurrency(_ currency: Currency) {
        // Check if currency already exists
        if !currencies.contains(where: { $0.code == currency.code }) {
            currencies.append(currency)
        }
    }
    
    func removeCurrency(_ currencyCode: String) {
        currencies.removeAll { $0.code == currencyCode }
    }
    
    func updateCurrencyVisibility(_ currencyCode: String, isVisible: Bool) {
        if let index = currencies.firstIndex(where: { $0.code == currencyCode }) {
            currencies[index].isVisible = isVisible
        }
    }
    
    func getVisibleCurrencies() -> [Currency] {
        return currencies.filter { $0.isVisible }
    }
    
    func getCurrenciesByCategory(_ category: String) -> [Currency] {
        return currencies.filter { $0.category == category }
    }
}

// MARK: - Models
struct ExchangeRateResponse: Codable {
    let base: String
    let rates: [String: Double]
}

enum CurrencyError: Error {
    case invalidURL
    case noData
    case decodingError
}