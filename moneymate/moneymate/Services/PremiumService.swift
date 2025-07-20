//
//  PremiumService.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import Foundation
import StoreKit

@MainActor
final class PremiumService: ObservableObject {
    static let shared = PremiumService()
    
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var subscription: PremiumSubscription?
    
    // Product IDs (App Store Connect'te tanımlanacak)
    private let monthlySubscriptionID = "com.moneymate.premium.monthly"
    private let yearlySubscriptionID = "com.moneymate.premium.yearly"
    
    private var products: [Product] = []
    
    enum PremiumFeature: String, CaseIterable {
        case advancedCharts = "Gelişmiş Grafikler"
        case unlimitedAlerts = "Sınırsız Uyarı"
        case exportData = "Veri Dışa Aktarma"
        case priceHistory = "Fiyat Geçmişi"
        case technicalIndicators = "Teknik Göstergeler"
        case realTimeData = "Gerçek Zamanlı Veri"
        case customThemes = "Özel Temalar"
        case portfolioTracking = "Portföy Takibi"
        
        var icon: String {
            switch self {
            case .advancedCharts: return "chart.line.uptrend.xyaxis"
            case .unlimitedAlerts: return "bell.badge"
            case .exportData: return "square.and.arrow.up"
            case .priceHistory: return "clock.arrow.circlepath"
            case .technicalIndicators: return "chart.bar.xaxis"
            case .realTimeData: return "bolt.fill"
            case .customThemes: return "paintbrush.fill"
            case .portfolioTracking: return "briefcase.fill"
            }
        }
        
        var description: String {
            switch self {
            case .advancedCharts: return "1 yıllık grafik verisi, çoklu zaman dilimi"
            case .unlimitedAlerts: return "Sınırsız fiyat uyarısı oluşturun"
            case .exportData: return "CSV, Excel formatında veri dışa aktarın"
            case .priceHistory: return "Tarihsel fiyat analizi ve karşılaştırma"
            case .technicalIndicators: return "RSI, MACD, Bollinger Bands"
            case .realTimeData: return "Saniye bazında güncel fiyatlar"
            case .customThemes: return "Özel renk şemaları ve temalar"
            case .portfolioTracking: return "Yatırımlarınızı takip edin"
            }
        }
    }
    
    private init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    // MARK: - Product Loading
    
    private func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlySubscriptionID, yearlySubscriptionID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlySubscriptionID || transaction.productID == yearlySubscriptionID {
                    isPremium = true
                    subscription = PremiumSubscription(
                        productID: transaction.productID,
                        purchaseDate: transaction.purchaseDate,
                        expirationDate: transaction.expirationDate
                    )
                    return
                }
            }
        }
        isPremium = false
        subscription = nil
    }
    
    // MARK: - Purchase
    
    func purchaseMonthlySubscription() async throws {
        guard let product = products.first(where: { $0.id == monthlySubscriptionID }) else {
            throw PremiumError.productNotFound
        }
        
        try await purchase(product: product)
    }
    
    func purchaseYearlySubscription() async throws {
        guard let product = products.first(where: { $0.id == yearlySubscriptionID }) else {
            throw PremiumError.productNotFound
        }
        
        try await purchase(product: product)
    }
    
    private func purchase(product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await updateSubscriptionStatus()
            case .unverified(_, let error):
                throw PremiumError.verificationFailed(error)
            }
        case .userCancelled:
            throw PremiumError.cancelled
        case .pending:
            throw PremiumError.pending
        @unknown default:
            throw PremiumError.unknown
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    // MARK: - Feature Access
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .advancedCharts, .unlimitedAlerts, .exportData, .priceHistory,
             .technicalIndicators, .realTimeData, .customThemes, .portfolioTracking:
            return isPremium
        }
    }
    
    // MARK: - Free Tier Limits
    
    func getChartDataLimit() -> Int {
        return isPremium ? 365 : 30 // Premium: 1 yıl, Free: 30 gün
    }
    
    func getAlertLimit() -> Int {
        return isPremium ? Int.max : 3 // Premium: Sınırsız, Free: 3 uyarı
    }
    
    func canAccessTimeFrame(_ timeFrame: ChartTimeFrame) -> Bool {
        if isPremium { return true }
        
        // Free tier: Sadece temel time frame'ler
        switch timeFrame {
        case .day, .week, .month:
            return true
        case .threeMonths, .sixMonths, .year:
            return false
        }
    }
    
    // MARK: - Mock Data (Development)
    
    func togglePremiumForTesting() {
        isPremium.toggle()
        if isPremium {
            subscription = PremiumSubscription(
                productID: monthlySubscriptionID,
                purchaseDate: Date(),
                expirationDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())
            )
        } else {
            subscription = nil
        }
    }
}

// MARK: - Models

struct PremiumSubscription {
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    
    var isActive: Bool {
        guard let expirationDate = expirationDate else { return true }
        return expirationDate > Date()
    }
    
    var subscriptionType: String {
        if productID.contains("yearly") {
            return "Yıllık"
        } else {
            return "Aylık"
        }
    }
}

enum ChartTimeFrame: String, CaseIterable {
    case day = "1G"
    case week = "1H"
    case month = "1A"
    case threeMonths = "3A"
    case sixMonths = "6A"
    case year = "1Y"
    
    var displayName: String {
        switch self {
        case .day: return "1 Gün"
        case .week: return "1 Hafta"
        case .month: return "1 Ay"
        case .threeMonths: return "3 Ay"
        case .sixMonths: return "6 Ay"
        case .year: return "1 Yıl"
        }
    }
}

enum PremiumError: Error {
    case productNotFound
    case verificationFailed(Error)
    case cancelled
    case pending
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .productNotFound: return "Ürün bulunamadı"
        case .verificationFailed: return "Doğrulama başarısız"
        case .cancelled: return "İptal edildi"
        case .pending: return "Beklemede"
        case .unknown: return "Bilinmeyen hata"
        }
    }
}