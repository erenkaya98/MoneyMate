//
//  CurrencySelectionView.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI
import SwiftData

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var favoritesService: FavoritesService
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @Environment(\.theme) private var theme
    
    @State private var searchText = ""
    @State private var selectedCategory: CurrencySelectionCategory = .all
    @State private var showingCategoryFilter = false
    @State private var selectedCurrencies: Set<String> = []
    @State private var showingConfirmation = false
    
    private let database = GlobalCurrencyDatabase.shared
    
    var filteredCurrencies: [CurrencyInfo] {
        let categoryFiltered: [CurrencyInfo]
        if selectedCategory == .all {
            categoryFiltered = database.allCurrencies
        } else if let category = selectedCategory.correspondingCategory {
            categoryFiltered = database.getCurrencies(by: category)
        } else {
            categoryFiltered = database.allCurrencies
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText) ||
                currency.country.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                categoryFilterView
                
                // Currency List
                currencyListView
            }
            .navigationTitle("Para Birimleri")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        hapticManager.buttonPressed()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ekle (\(selectedCurrencies.count))") {
                        hapticManager.buttonPressed()
                        showingConfirmation = true
                    }
                    .disabled(selectedCurrencies.isEmpty)
                }
            }
        }
        .alert("Para Birimlerini Ekle", isPresented: $showingConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Ekle") {
                addSelectedCurrencies()
                dismiss()
            }
        } message: {
            Text("\(selectedCurrencies.count) para birimi ana ekrana eklenecek.")
        }
    }
    
    private var currencyListView: some View {
        Group {
            if filteredCurrencies.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredCurrencies) { currencyInfo in
                        GlobalCurrencySelectionRow(
                            currencyInfo: currencyInfo,
                            isSelected: selectedCurrencies.contains(currencyInfo.code),
                            isAlreadyAdded: isAlreadyAdded(currencyInfo.code)
                        ) {
                            toggleCurrencySelection(currencyInfo.code)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Para birimi ara...")
            }
        }
    }
    
    private func isAlreadyAdded(_ code: String) -> Bool {
        return currencyService.currencies.contains { $0.code == code }
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CurrencySelectionCategory.allCases, id: \.self) { category in
                    Button {
                        hapticManager.selectionChanged()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.systemImage)
                                .font(.caption)
                            
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedCategory == category ? 
                            theme.primaryColor : theme.cardColor
                        )
                        .foregroundColor(
                            selectedCategory == category ? 
                            .white : theme.textPrimaryColor
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(theme.surfaceColor)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(theme.textSecondaryColor)
            
            VStack(spacing: 8) {
                Text("Sonuç Bulunamadı")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Arama kriterlerinizi değiştirmeyi deneyin")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondaryColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func toggleCurrencySelection(_ code: String) {
        hapticManager.selectionChanged()
        
        if selectedCurrencies.contains(code) {
            selectedCurrencies.remove(code)
        } else {
            selectedCurrencies.insert(code)
        }
    }
    
    private func addSelectedCurrencies() {
        hapticManager.actionSuccess()
        
        for code in selectedCurrencies {
            if let currencyInfo = database.getCurrency(by: code) {
                let newCurrency = Currency(
                    code: currencyInfo.code,
                    name: currencyInfo.name,
                    symbol: currencyInfo.symbol,
                    flag: currencyInfo.flag,
                    country: currencyInfo.country,
                    rate: 1.0, // Default rate, will be updated by service
                    change24h: 0.0,
                    trend: "neutral",
                    category: currencyInfo.category.rawValue,
                    isCryptocurrency: currencyInfo.category == .crypto
                )
                
                currencyService.addCurrency(newCurrency)
            }
        }
        
        selectedCurrencies.removeAll()
    }
}

struct GlobalCurrencySelectionRow: View {
    let currencyInfo: CurrencyInfo
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onTap: () -> Void
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Flag and Info
                HStack(spacing: 12) {
                    Text(currencyInfo.flag)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currencyInfo.code)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(currencyInfo.name)
                            .font(.subheadline)
                            .foregroundColor(theme.textSecondaryColor)
                        
                        Text(currencyInfo.country)
                            .font(.caption)
                            .foregroundColor(theme.textSecondaryColor)
                    }
                }
                
                Spacer()
                
                // Category Badge
                Text(currencyInfo.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(currencyInfo.category.color).opacity(0.2))
                    .foregroundColor(Color(currencyInfo.category.color))
                    .cornerRadius(8)
                
                // Selection State
                if isAlreadyAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? theme.primaryColor : theme.textSecondaryColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAlreadyAdded)
        .opacity(isAlreadyAdded ? 0.6 : 1.0)
    }
}

// MARK: - Extended Currency Category

enum CurrencySelectionCategory: String, CaseIterable {
    case all = "Tümü"
    case major = "Ana Para Birimleri"
    case asian = "Asya Para Birimleri"
    case european = "Avrupa Para Birimleri"
    case middleEastern = "Orta Doğu Para Birimleri"
    case african = "Afrika Para Birimleri"
    case latinAmerican = "Latin Amerika Para Birimleri"
    case crypto = "Kripto Para Birimleri"
    case other = "Diğer Para Birimleri"
    
    var systemImage: String {
        switch self {
        case .all: return "globe"
        case .major: return "star.fill"
        case .asian: return "globe.asia.australia.fill"
        case .european: return "globe.europe.africa.fill"
        case .middleEastern: return "globe.asia.australia.fill"
        case .african: return "globe.europe.africa.fill"
        case .latinAmerican: return "globe.americas.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .other: return "globe"
        }
    }
    
    var correspondingCategory: CurrencyCategory? {
        switch self {
        case .all: return nil
        case .major: return .major
        case .asian: return .asian
        case .european: return .european
        case .middleEastern: return .middleEastern
        case .african: return .african
        case .latinAmerican: return .latinAmerican
        case .crypto: return .crypto
        case .other: return .other
        }
    }
}

#Preview {
    CurrencySelectionView()
        .environmentObject(CurrencyService())
        .environmentObject(FavoritesService(modelContext: ModelContext.sample))
}