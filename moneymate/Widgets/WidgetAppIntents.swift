//
//  WidgetAppIntents.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import AppIntents
import WidgetKit

// MARK: - Open App Intent

struct OpenMoneyMateIntent: AppIntent {
    static let title: LocalizedStringResource = "MoneyMate'i Aç"
    static let description = IntentDescription("MoneyMate uygulamasını açar")
    static let openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Currency Selection Intent

struct SelectCurrencyIntent: AppIntent {
    static let title: LocalizedStringResource = "Döviz Seç"
    static let description = IntentDescription("Widget için döviz seçin")
    
    @Parameter(title: "Döviz Kodu", description: "Görüntülenecek döviz kodu")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        await WidgetDataProvider.shared.setPreferredChartCurrency(currencyCode)
        return .result()
    }
}

// MARK: - Refresh Widget Intent

struct RefreshWidgetIntent: AppIntent {
    static let title: LocalizedStringResource = "Widget'ı Yenile"
    static let description = IntentDescription("Widget verilerini yeniler")
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Add to Favorites Intent

struct AddToFavoritesIntent: AppIntent {
    static let title: LocalizedStringResource = "Favorilere Ekle"
    static let description = IntentDescription("Seçili dövizi favorilere ekler")
    
    @Parameter(title: "Döviz Kodu")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        // Add to favorites via UserDefaults for widget access
        var favorites = UserDefaults.standard.array(forKey: "widget_favorites") as? [String] ?? []
        if !favorites.contains(currencyCode) {
            favorites.append(currencyCode)
            UserDefaults.standard.set(favorites, forKey: "widget_favorites")
        }
        
        // Refresh favorites widget
        WidgetCenter.shared.reloadTimelines(ofKind: "FavoriteCurrenciesWidget")
        
        return .result()
    }
}

// MARK: - Remove from Favorites Intent

struct RemoveFromFavoritesIntent: AppIntent {
    static let title: LocalizedStringResource = "Favorilerden Çıkar"
    static let description = IntentDescription("Seçili dövizi favorilerden çıkarır")
    
    @Parameter(title: "Döviz Kodu")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        var favorites = UserDefaults.standard.array(forKey: "widget_favorites") as? [String] ?? []
        favorites.removeAll { $0 == currencyCode }
        UserDefaults.standard.set(favorites, forKey: "widget_favorites")
        
        // Refresh favorites widget
        WidgetCenter.shared.reloadTimelines(ofKind: "FavoriteCurrenciesWidget")
        
        return .result()
    }
}

// MARK: - View Currency Details Intent

struct ViewCurrencyDetailsIntent: AppIntent {
    static let title: LocalizedStringResource = "Döviz Detayları"
    static let description = IntentDescription("Seçili dövizin detaylarını görüntüler")
    static let openAppWhenRun = true
    
    @Parameter(title: "Döviz Kodu")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        return .result(opensIntent: OpenURLIntent(WidgetDeepLink.url(for: .specific(currency: currencyCode))))
    }
}

// MARK: - View Charts Intent

struct ViewChartsIntent: AppIntent {
    static let title: LocalizedStringResource = "Grafikleri Görüntüle"
    static let description = IntentDescription("Döviz grafiklerini görüntüler")
    static let openAppWhenRun = true
    
    @Parameter(title: "Döviz Kodu", defaultValue: "USD")
    var currencyCode: String
    
    func perform() async throws -> some IntentResult {
        return .result(opensIntent: OpenURLIntent(WidgetDeepLink.url(for: .charts(currency: currencyCode))))
    }
}

// MARK: - App Intent Shortcuts Provider

struct MoneyMateWidgetShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: OpenMoneyMateIntent(),
                phrases: ["MoneyMate'i aç", "Döviz uygulamasını aç"],
                shortTitle: "MoneyMate'i Aç",
                systemImageName: "dollarsign.circle"
            ),
            AppShortcut(
                intent: RefreshWidgetIntent(),
                phrases: ["Döviz widget'ını yenile", "Kurları güncelle"],
                shortTitle: "Widget'ı Yenile",
                systemImageName: "arrow.clockwise"
            ),
            AppShortcut(
                intent: ViewChartsIntent(),
                phrases: ["Döviz grafiklerini göster", "Grafikleri aç"],
                shortTitle: "Grafikleri Görüntüle",
                systemImageName: "chart.line.uptrend.xyaxis"
            )
        ]
    }
}