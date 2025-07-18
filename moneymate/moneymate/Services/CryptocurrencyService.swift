//
//  CryptocurrencyService.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import Foundation
import Combine

@MainActor
final class CryptocurrencyService: ObservableObject {
    @Published var cryptoPrices: [String: CryptoPrice] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // CoinGecko API - Ücretsiz ve güvenilir
    private let coinGeckoAPIURL = "https://api.coingecko.com/api/v3/simple/price"
    private let cryptoSymbols = ["bitcoin", "ethereum", "litecoin", "ripple", "cardano"]
    
    // Crypto ID mapping
    private let cryptoIDMap: [String: String] = [
        "BTC": "bitcoin",
        "ETH": "ethereum",
        "LTC": "litecoin",
        "XRP": "ripple",
        "ADA": "cardano"
    ]
    
    init() {
        Task {
            await fetchCryptoPrices()
        }
    }
    
    func fetchCryptoPrices() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let prices = try await fetchRealTimeCryptoPrices()
            cryptoPrices = prices
        } catch {
            errorMessage = "Kripto fiyatları alınamadı: \(error.localizedDescription)"
            // Fallback to mock data
            loadMockCryptoPrices()
        }
        
        isLoading = false
    }
    
    private func fetchRealTimeCryptoPrices() async throws -> [String: CryptoPrice] {
        let ids = cryptoSymbols.joined(separator: ",")
        let currencies = "usd,try"
        
        guard let url = URL(string: "\(coinGeckoAPIURL)?ids=\(ids)&vs_currencies=\(currencies)&include_24hr_change=true") else {
            throw CryptoError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([String: CryptoAPIResponse].self, from: data)
        
        var prices: [String: CryptoPrice] = [:]
        
        for (cryptoID, priceData) in response {
            if let symbol = cryptoIDMap.first(where: { $0.value == cryptoID })?.key {
                prices[symbol] = CryptoPrice(
                    symbol: symbol,
                    priceUSD: priceData.usd,
                    priceTRY: priceData.try ?? 0,
                    change24hUSD: priceData.usd_24h_change ?? 0,
                    lastUpdated: Date()
                )
            }
        }
        
        return prices
    }
    
    private func loadMockCryptoPrices() {
        cryptoPrices = [
            "BTC": CryptoPrice(
                symbol: "BTC",
                priceUSD: 43250.0,
                priceTRY: 1404125.0,
                change24hUSD: 2.3,
                lastUpdated: Date()
            ),
            "ETH": CryptoPrice(
                symbol: "ETH",
                priceUSD: 2650.0,
                priceTRY: 86062.5,
                change24hUSD: -1.2,
                lastUpdated: Date()
            ),
            "LTC": CryptoPrice(
                symbol: "LTC",
                priceUSD: 95.0,
                priceTRY: 3087.5,
                change24hUSD: 0.8,
                lastUpdated: Date()
            ),
            "XRP": CryptoPrice(
                symbol: "XRP",
                priceUSD: 0.52,
                priceTRY: 16.9,
                change24hUSD: -0.3,
                lastUpdated: Date()
            ),
            "ADA": CryptoPrice(
                symbol: "ADA",
                priceUSD: 0.45,
                priceTRY: 14.6,
                change24hUSD: 1.1,
                lastUpdated: Date()
            )
        ]
    }
    
    func getCryptoPrice(for symbol: String) -> CryptoPrice? {
        return cryptoPrices[symbol]
    }
    
    func isCryptocurrency(_ symbol: String) -> Bool {
        return cryptoIDMap.keys.contains(symbol)
    }
    
    func refreshCryptoPrices() async {
        await fetchCryptoPrices()
    }
}

// MARK: - Models

struct CryptoPrice {
    let symbol: String
    let priceUSD: Double
    let priceTRY: Double
    let change24hUSD: Double
    let lastUpdated: Date
    
    var formattedPriceUSD: String {
        if priceUSD >= 1000 {
            return String(format: "$%.0f", priceUSD)
        } else if priceUSD >= 1 {
            return String(format: "$%.2f", priceUSD)
        } else {
            return String(format: "$%.4f", priceUSD)
        }
    }
    
    var formattedPriceTRY: String {
        if priceTRY >= 1000 {
            return String(format: "₺%.0f", priceTRY)
        } else if priceTRY >= 1 {
            return String(format: "₺%.2f", priceTRY)
        } else {
            return String(format: "₺%.4f", priceTRY)
        }
    }
    
    var changeColor: String {
        return change24hUSD >= 0 ? "green" : "red"
    }
    
    var changeIcon: String {
        return change24hUSD >= 0 ? "arrow.up" : "arrow.down"
    }
}

struct CryptoAPIResponse: Codable {
    let usd: Double
    let `try`: Double?
    let usd_24h_change: Double?
}

enum CryptoError: Error {
    case invalidURL
    case noData
    case decodingError
}