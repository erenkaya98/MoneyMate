//
//  FavoritesView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var favoritesService: FavoritesService
    @State private var selectedCategory: FavoriteCategory = .favorites
    @State private var showingEditMode = false
    @State private var showingAddToFavorites = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selector
                categorySelector
                
                // Content
                TabView(selection: $selectedCategory) {
                    favoritesTab
                        .tag(FavoriteCategory.favorites)
                    
                    watchlistTab
                        .tag(FavoriteCategory.watchlist)
                    
                    recentsTab
                        .tag(FavoriteCategory.recents)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Favoriler")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedCategory != .recents {
                        Button(showingEditMode ? "Bitti" : "Düzenle") {
                            showingEditMode.toggle()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Favorilere Ekle") {
                            showingAddToFavorites = true
                        }
                        
                        if selectedCategory == .recents {
                            Button("Geçmişi Temizle") {
                                favoritesService.clearRecentlyViewed()
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Favorilerinde ara...")
        .onAppear {
            favoritesService.loadFavorites()
        }
        .sheet(isPresented: $showingAddToFavorites) {
            AddToFavoritesView()
                .environmentObject(currencyService)
                .environmentObject(favoritesService)
        }
    }
    
    private var categorySelector: some View {
        HStack(spacing: 0) {
            ForEach(FavoriteCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCategory = category
                        showingEditMode = false
                    }
                } label: {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: category.systemImage)
                                .font(.callout)
                            
                            Text(category.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // Count badge
                            let count = getCountForCategory(category)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(getCategoryColor(category))
                                    .clipShape(Capsule())
                            }
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
    
    private var favoritesTab: some View {
        FavoritesTabContent(
            currencies: getFavoriteCurrencies(),
            isEditMode: showingEditMode,
            emptyView: { emptyFavoritesView },
            onEdit: { currency in editFavorite(currency) },
            onRemove: { currency in favoritesService.removeFromFavorites(currencyCode: currency.code) },
            onMove: { from, to in favoritesService.moveFavorite(from: from, to: to) }
        )
        .environmentObject(favoritesService)
    }
    
    private var watchlistTab: some View {
        WatchlistTabContent(
            currencies: getWatchlistCurrencies(),
            isEditMode: showingEditMode,
            emptyView: { emptyWatchlistView },
            onEdit: { currency in editFavorite(currency) },
            onRemove: { currency in favoritesService.removeFromWatchlist(currencyCode: currency.code) },
            onMove: { from, to in favoritesService.moveWatchlistItem(from: from, to: to) }
        )
        .environmentObject(favoritesService)
    }
    
    private var recentsTab: some View {
        let recentCurrencies = getRecentCurrencies()
        
        return Group {
            if recentCurrencies.isEmpty {
                emptyRecentsView
            } else {
                List {
                    ForEach(recentCurrencies, id: \.code) { currency in
                        FavoriteCurrencyRowView(
                            currency: currency,
                            favoriteItem: favoritesService.getFavoriteItem(currencyCode: currency.code),
                            isEditMode: false,
                            onEdit: { editFavorite(currency) },
                            onRemove: { }
                        )
                        .environmentObject(favoritesService)
                    }
                }
            }
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            VStack(spacing: 8) {
                Text("Henüz Favori Yok")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Beğendiğiniz dövizleri favorilere ekleyin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Favori Ekle") {
                showingAddToFavorites = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyWatchlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("İzleme Listesi Boş")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Takip etmek istediğiniz dövizleri ekleyin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyRecentsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Son Görüntülenen Yok")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Görüntülediğiniz dövizler burada görünecek")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Functions
    
    private func getFavoriteCurrencies() -> [Currency] {
        let filtered = favoritesService.getFilteredCurrencies(
            from: currencyService.currencies,
            category: .favorites
        )
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func getWatchlistCurrencies() -> [Currency] {
        let filtered = favoritesService.getFilteredCurrencies(
            from: currencyService.currencies,
            category: .watchlist
        )
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func getRecentCurrencies() -> [Currency] {
        let filtered = favoritesService.getFilteredCurrencies(
            from: currencyService.currencies,
            category: .recents
        )
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func getCountForCategory(_ category: FavoriteCategory) -> Int {
        switch category {
        case .favorites: return favoritesService.getFavoritesCount()
        case .watchlist: return favoritesService.getWatchlistCount()
        case .recents: return favoritesService.getRecentlyViewedCount()
        }
    }
    
    private func getCategoryColor(_ category: FavoriteCategory) -> Color {
        switch category {
        case .favorites: return .yellow
        case .watchlist: return .blue
        case .recents: return .green
        }
    }
    
    private func editFavorite(_ currency: Currency) {
        // Implementation for editing favorite details
    }
}

// MARK: - Supporting Views

struct FavoritesTabContent: View {
    let currencies: [Currency]
    let isEditMode: Bool
    let emptyView: () -> AnyView
    let onEdit: (Currency) -> Void
    let onRemove: (Currency) -> Void
    let onMove: (IndexSet, Int) -> Void
    
    @EnvironmentObject var favoritesService: FavoritesService
    
    init(
        currencies: [Currency],
        isEditMode: Bool,
        @ViewBuilder emptyView: @escaping () -> some View,
        onEdit: @escaping (Currency) -> Void,
        onRemove: @escaping (Currency) -> Void,
        onMove: @escaping (IndexSet, Int) -> Void
    ) {
        self.currencies = currencies
        self.isEditMode = isEditMode
        self.emptyView = { AnyView(emptyView()) }
        self.onEdit = onEdit
        self.onRemove = onRemove
        self.onMove = onMove
    }
    
    var body: some View {
        if currencies.isEmpty {
            emptyView()
        } else {
            List {
                ForEach(currencies, id: \.code) { currency in
                    FavoriteCurrencyRowView(
                        currency: currency,
                        favoriteItem: favoritesService.getFavoriteItem(currencyCode: currency.code),
                        isEditMode: isEditMode,
                        onEdit: { onEdit(currency) },
                        onRemove: { onRemove(currency) }
                    )
                    .environmentObject(favoritesService)
                }
                .onMove(perform: isEditMode ? onMove : nil)
            }
            .environment(\.editMode, Binding.constant(isEditMode ? .active : .inactive))
        }
    }
}

struct WatchlistTabContent: View {
    let currencies: [Currency]
    let isEditMode: Bool
    let emptyView: () -> AnyView
    let onEdit: (Currency) -> Void
    let onRemove: (Currency) -> Void
    let onMove: (IndexSet, Int) -> Void
    
    @EnvironmentObject var favoritesService: FavoritesService
    
    init(
        currencies: [Currency],
        isEditMode: Bool,
        @ViewBuilder emptyView: @escaping () -> some View,
        onEdit: @escaping (Currency) -> Void,
        onRemove: @escaping (Currency) -> Void,
        onMove: @escaping (IndexSet, Int) -> Void
    ) {
        self.currencies = currencies
        self.isEditMode = isEditMode
        self.emptyView = { AnyView(emptyView()) }
        self.onEdit = onEdit
        self.onRemove = onRemove
        self.onMove = onMove
    }
    
    var body: some View {
        if currencies.isEmpty {
            emptyView()
        } else {
            List {
                ForEach(currencies, id: \.code) { currency in
                    FavoriteCurrencyRowView(
                        currency: currency,
                        favoriteItem: favoritesService.getFavoriteItem(currencyCode: currency.code),
                        isEditMode: isEditMode,
                        onEdit: { onEdit(currency) },
                        onRemove: { onRemove(currency) }
                    )
                    .environmentObject(favoritesService)
                }
                .onMove(perform: isEditMode ? onMove : nil)
            }
            .environment(\.editMode, Binding.constant(isEditMode ? .active : .inactive))
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(CurrencyService())
        .environmentObject(FavoritesService(modelContext: ModelContext.sample))
}