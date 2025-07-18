//
//  HomeView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var alertService: PriceAlertService
    @EnvironmentObject var favoritesService: FavoritesService
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @State private var showingCreateAlert = false
    @State private var showingAlertsList = false
    @State private var showingCurrencySelection = false
    @State private var selectedCurrencyForAlert: Currency?
    
    var filteredCurrencies: [Currency] {
        let visibleCurrencies = currencyService.getVisibleCurrencies()
        
        if searchText.isEmpty {
            return visibleCurrencies
        } else {
            return visibleCurrencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Stats
                statsHeaderView
                
                // Currency List
                if currencyService.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        
                        Text("Kurlar güncelleniyor...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredCurrencies, id: \.code) { currency in
                        CurrencyRowView(
                            currency: currency,
                            onFavoriteToggle: {
                                hapticManager.favoriteToggled()
                                currencyService.toggleFavorite(for: currency)
                            },
                            onCreateAlert: {
                                hapticManager.buttonPressed()
                                selectedCurrencyForAlert = currency
                                showingCreateAlert = true
                            }
                        )
                    }
                    .refreshable {
                        hapticManager.refreshAction()
                        await currencyService.refreshRates()
                    }
                    .searchable(text: $searchText, prompt: "Döviz ara...")
                    
                    // Error Message
                    if let errorMessage = currencyService.errorMessage {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            
                            HapticButton("Tekrar Dene", hapticType: .buttonTap) {
                                Task {
                                    await currencyService.refreshRates()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("MoneyMate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HapticButton(hapticType: .buttonTap) {
                        showingAlertsList = true
                    } content: {
                        ZStack {
                            Image(systemName: "bell")
                                .font(.title3)
                            
                            if alertService.activeAlertsCount > 0 {
                                Text("\(alertService.activeAlertsCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        HapticButton(hapticType: .buttonTap) {
                            showingCurrencySelection = true
                        } content: {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                        }
                        
                        HapticButton("Yenile", hapticType: .refresh) {
                            Task {
                                await currencyService.refreshRates()
                            }
                        }
                        .disabled(currencyService.isLoading)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateAlert) {
            if let currency = selectedCurrencyForAlert {
                CreateAlertView(currency: currency)
                    .environmentObject(alertService)
                    .themed()
            }
        }
        .sheet(isPresented: $showingAlertsList) {
            PriceAlertsView()
                .environmentObject(alertService)
                .themed()
        }
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView()
                .environmentObject(currencyService)
                .environmentObject(favoritesService)
                .themed()
        }
    }
    
    private var statsHeaderView: some View {
        HStack {
            StatCard(
                title: "Yükselişte",
                value: "\(currencyService.getVisibleCurrencies().filter { $0.trend == "up" }.count)",
                color: .green
            )
            
            StatCard(
                title: "Düşüşte",
                value: "\(currencyService.getVisibleCurrencies().filter { $0.trend == "down" }.count)",
                color: .red
            )
            
            StatCard(
                title: "Toplam",
                value: "\(currencyService.getVisibleCurrencies().count)",
                color: .blue
            )
        }
        .padding()
        .background(theme.surfaceColor)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.primaryColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.cardColor)
        .cornerRadius(8)
    }
}

struct CurrencyRowView: View {
    let currency: Currency
    let onFavoriteToggle: () -> Void
    let onCreateAlert: () -> Void
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            // Flag and Info
            HStack(spacing: 12) {
                Text(currency.flag)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(currency.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Rate and Change
            VStack(alignment: .trailing, spacing: 2) {
                if currency.isCryptocurrency {
                    // Crypto: Show as USD price
                    Text(formatCryptoPrice(currency.rate))
                        .font(.headline)
                        .fontWeight(.medium)
                } else {
                    // Fiat: Show as USD exchange rate
                    Text(String(format: "%.4f", currency.rate))
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: currency.trend == "up" ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    
                    Text(String(format: "%.2f%%", abs(currency.change24h)))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(currency.trend == "up" ? theme.upColor : theme.downColor)
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                // Alert Button - Daha görünür hale getir
                Button(action: onCreateAlert) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(theme.primaryColor)
                        .frame(width: 32, height: 32)
                        .background(theme.primaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: currency.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(currency.isFavorite ? theme.warningColor : theme.textSecondaryColor)
                        .frame(width: 32, height: 32)
                        .background(currency.isFavorite ? theme.warningColor.opacity(0.1) : theme.surfaceColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCryptoPrice(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "$%.0f", price)
        } else if price >= 1 {
            return String(format: "$%.2f", price)
        } else {
            return String(format: "$%.4f", price)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CurrencyService())
        .environmentObject(PriceAlertService(modelContext: ModelContext.sample))
        .environmentObject(FavoritesService(modelContext: ModelContext.sample))
}