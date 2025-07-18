//
//  MainTabView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var cryptoService = CryptocurrencyService()
    @StateObject private var premiumService = PremiumService.shared
    @StateObject private var alertService: PriceAlertService
    @StateObject private var favoritesService: FavoritesService
    @StateObject private var themeManager = ThemeManager.shared
    
    init(modelContext: ModelContext) {
        let alertService = PriceAlertService(modelContext: modelContext)
        let favoritesService = FavoritesService(modelContext: modelContext)
        self._alertService = StateObject(wrappedValue: alertService)
        self._favoritesService = StateObject(wrappedValue: favoritesService)
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfa")
                }
            
            ConverterView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Dönüştürücü")
                }
            
            ChartsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Grafikler")
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favoriler")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Hesap")
                }
        }
        .environmentObject(currencyService)
        .environmentObject(cryptoService)
        .environmentObject(premiumService)
        .environmentObject(alertService)
        .environmentObject(favoritesService)
        .accentColor(themeManager.primaryColor)
        .themed()
        .onAppear {
            currencyService.setAlertService(alertService)
            currencyService.setCryptoService(cryptoService)
        }
    }
}

#Preview {
    MainTabView(modelContext: ModelContext.sample)
}