//
//  FavoriteCurrencyRowView.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI
import SwiftData

struct FavoriteCurrencyRowView: View {
    let currency: Currency
    let favoriteItem: FavoriteCurrency?
    let isEditMode: Bool
    let onEdit: () -> Void
    let onRemove: () -> Void
    
    @EnvironmentObject var favoritesService: FavoritesService
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency Flag and Code
            HStack(spacing: 8) {
                Text(currency.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currency.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Rate and percentage change
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.4f", currency.rate))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
                    
                    Text(String(format: "%.2f%%", abs(currency.changePercentage)))
                        .font(.caption)
                        .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
                }
            }
            
            // Edit/Action buttons
            if isEditMode {
                VStack(spacing: 8) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Action buttons for different favorite types
                HStack(spacing: 8) {
                    // Notifications toggle
                    if let favoriteItem = favoriteItem {
                        Button(action: {
                            favoritesService.toggleNotifications(currencyCode: currency.code)
                        }) {
                            Image(systemName: favoriteItem.notificationEnabled ? "bell.fill" : "bell.slash")
                                .font(.callout)
                                .foregroundColor(favoriteItem.notificationEnabled ? .blue : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Star/Watchlist toggle
                    Button(action: {
                        if favoritesService.isFavorite(currencyCode: currency.code) {
                            favoritesService.removeFromFavorites(currencyCode: currency.code)
                        } else {
                            favoritesService.addToFavorites(currencyCode: currency.code)
                        }
                    }) {
                        Image(systemName: favoritesService.isFavorite(currencyCode: currency.code) ? "star.fill" : "star")
                            .font(.callout)
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditMode {
                favoritesService.addToRecentlyViewed(currencyCode: currency.code)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditFavoriteView(currency: currency, favoriteItem: favoriteItem)
                .environmentObject(favoritesService)
        }
    }
    
    private var displayName: String {
        if let favoriteItem = favoriteItem, let customAlias = favoriteItem.customAlias, !customAlias.isEmpty {
            return customAlias
        }
        return currency.name
    }
}

struct EditFavoriteView: View {
    let currency: Currency
    let favoriteItem: FavoriteCurrency?
    
    @EnvironmentObject var favoritesService: FavoritesService
    @Environment(\.dismiss) private var dismiss
    
    @State private var customAlias: String = ""
    @State private var notes: String = ""
    @State private var notificationEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Para Birimi Bilgileri")) {
                    HStack {
                        Text(currency.flag)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(currency.name)
                                .font(.headline)
                            Text(currency.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                
                Section(header: Text("Özelleştirme"), footer: Text("Kendi tanımladığınız isim ve notlar")) {
                    TextField("Özel İsim", text: $customAlias)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Notlar", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Bildirimler")) {
                    Toggle("Fiyat Değişikliği Bildirimleri", isOn: $notificationEnabled)
                }
            }
            .navigationTitle("Favori Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveFavorite()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadFavoriteData()
        }
    }
    
    private func loadFavoriteData() {
        if let favoriteItem = favoriteItem {
            customAlias = favoriteItem.customAlias ?? ""
            notes = favoriteItem.notes ?? ""
            notificationEnabled = favoriteItem.notificationEnabled
        }
    }
    
    private func saveFavorite() {
        if !customAlias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            favoritesService.updateCustomAlias(currencyCode: currency.code, alias: customAlias)
        }
        
        if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            favoritesService.updateNotes(currencyCode: currency.code, notes: notes)
        }
        
        if favoriteItem?.notificationEnabled != notificationEnabled {
            favoritesService.toggleNotifications(currencyCode: currency.code)
        }
    }
}

#Preview {
    let mockCurrency = Currency(
        code: "USD",
        name: "US Dollar",
        symbol: "$",
        flag: "🇺🇸",
        rate: 32.45,
        change24h: 2.5,
        trend: "up"
    )
    
    FavoriteCurrencyRowView(
        currency: mockCurrency,
        favoriteItem: nil,
        isEditMode: false,
        onEdit: { },
        onRemove: { }
    )
    .environmentObject(FavoritesService(modelContext: ModelContext.sample))
}