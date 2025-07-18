//
//  AddToFavoritesView.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI
import SwiftData

struct AddToFavoritesView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var favoritesService: FavoritesService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedCurrencies: Set<String> = []
    @State private var selectedCategory: FavoriteCategory = .favorites
    @State private var customAlias: String = ""
    @State private var notes: String = ""
    @State private var notificationEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selection
                categorySelector
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Currency List
                List {
                    ForEach(filteredCurrencies, id: \.code) { currency in
                        FavoriteCurrencySelectionRow(
                            currency: currency,
                            isSelected: selectedCurrencies.contains(currency.code),
                            isAlreadyAdded: isAlreadyInCategory(currency.code),
                            onToggle: { toggleCurrency(currency.code) }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                
                // Custom Settings (only when currencies are selected)
                if !selectedCurrencies.isEmpty {
                    customSettingsSection
                }
                
                // Add Button
                addButton
            }
            .navigationTitle("Favori Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var categorySelector: some View {
        HStack(spacing: 0) {
            ForEach([FavoriteCategory.favorites, FavoriteCategory.watchlist], id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCategory = category
                        selectedCurrencies.removeAll()
                    }
                } label: {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: category.systemImage)
                                .font(.callout)
                            
                            Text(category.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedCategory == category ? getCategoryColor(category) : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedCategory == category ? 
                        getCategoryColor(category).opacity(0.1) : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var customSettingsSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                Text("Özelleştirme")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if selectedCurrencies.count == 1 {
                    TextField("Özel İsim (opsiyonel)", text: $customAlias)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                TextField("Notlar (opsiyonel)", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                
                Toggle("Bildirimler", isOn: $notificationEnabled)
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }
    
    private var addButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: addSelectedCurrencies) {
                HStack {
                    Image(systemName: selectedCategory.systemImage)
                    Text("Seçili \(selectedCurrencies.count) para birimini \(selectedCategory.displayName.lowercased()) ekle")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(getCategoryColor(selectedCategory))
                .foregroundColor(.white)
                .font(.headline)
            }
            .disabled(selectedCurrencies.isEmpty)
            .opacity(selectedCurrencies.isEmpty ? 0.6 : 1.0)
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private var filteredCurrencies: [Currency] {
        let currencies = currencyService.currencies
        
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func toggleCurrency(_ currencyCode: String) {
        if selectedCurrencies.contains(currencyCode) {
            selectedCurrencies.remove(currencyCode)
        } else {
            selectedCurrencies.insert(currencyCode)
        }
    }
    
    private func isAlreadyInCategory(_ currencyCode: String) -> Bool {
        switch selectedCategory {
        case .favorites:
            return favoritesService.isFavorite(currencyCode: currencyCode)
        case .watchlist:
            return favoritesService.isInWatchlist(currencyCode: currencyCode)
        case .recents:
            return false
        }
    }
    
    private func getCategoryColor(_ category: FavoriteCategory) -> Color {
        switch category {
        case .favorites: return .yellow
        case .watchlist: return .blue
        case .recents: return .green
        }
    }
    
    private func addSelectedCurrencies() {
        for currencyCode in selectedCurrencies {
            let alias = selectedCurrencies.count == 1 && !customAlias.isEmpty ? customAlias : nil
            let notes = !notes.isEmpty ? notes : nil
            
            switch selectedCategory {
            case .favorites:
                favoritesService.addToFavorites(
                    currencyCode: currencyCode,
                    notes: notes,
                    customAlias: alias
                )
            case .watchlist:
                favoritesService.addToWatchlist(
                    currencyCode: currencyCode,
                    notes: notes,
                    customAlias: alias
                )
            case .recents:
                break // Recents are added automatically
            }
            
            // Set notification preference
            if !notificationEnabled {
                favoritesService.toggleNotifications(currencyCode: currencyCode)
            }
        }
        
        dismiss()
    }
}

struct FavoriteCurrencySelectionRow: View {
    let currency: Currency
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .gray)
                .onTapGesture {
                    if !isAlreadyAdded {
                        onToggle()
                    }
                }
            
            // Currency info
            HStack(spacing: 8) {
                Text(currency.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                        .font(.headline)
                        .foregroundColor(isAlreadyAdded ? .gray : .primary)
                    
                    Text(currency.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Rate
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.4f", currency.rate))
                    .font(.subheadline)
                    .foregroundColor(isAlreadyAdded ? .gray : .primary)
                
                if isAlreadyAdded {
                    Text("Zaten eklendi")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isAlreadyAdded {
                onToggle()
            }
        }
        .opacity(isAlreadyAdded ? 0.6 : 1.0)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Para birimi ara...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    AddToFavoritesView()
        .environmentObject(CurrencyService())
        .environmentObject(FavoritesService(modelContext: ModelContext.sample))
}