//
//  FavoritesService.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class FavoritesService: ObservableObject {
    @Published var favorites: [FavoriteCurrency] = []
    @Published var watchlist: [FavoriteCurrency] = []
    @Published var recentlyViewed: [FavoriteCurrency] = []
    
    private let modelContext: ModelContext
    private let maxRecentItems = 10
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadFavorites()
    }
    
    func loadFavorites() {
        do {
            // Load favorites
            let favoritesDescriptor = FetchDescriptor<FavoriteCurrency>(
                predicate: #Predicate { !$0.isWatchlistItem },
                sortBy: [SortDescriptor(\.position), SortDescriptor(\.addedAt)]
            )
            favorites = try modelContext.fetch(favoritesDescriptor)
            
            // Load watchlist
            let watchlistDescriptor = FetchDescriptor<FavoriteCurrency>(
                predicate: #Predicate { $0.isWatchlistItem },
                sortBy: [SortDescriptor(\.position), SortDescriptor(\.addedAt)]
            )
            watchlist = try modelContext.fetch(watchlistDescriptor)
            
            // Load recently viewed (from last 30 days)
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let recentsDescriptor = FetchDescriptor<FavoriteCurrency>(
                predicate: #Predicate { $0.lastViewedAt > thirtyDaysAgo },
                sortBy: [SortDescriptor(\.lastViewedAt, order: .reverse)]
            )
            let allRecents = try modelContext.fetch(recentsDescriptor)
            recentlyViewed = Array(allRecents.prefix(maxRecentItems))
            
        } catch {
            print("Failed to load favorites: \(error)")
        }
    }
    
    // MARK: - Favorites Management
    
    func addToFavorites(
        currencyCode: String,
        notes: String? = nil,
        customAlias: String? = nil
    ) {
        // Check if already exists
        if favorites.contains(where: { $0.currencyCode == currencyCode }) {
            return
        }
        
        let position = favorites.count
        let favorite = FavoriteCurrency(
            currencyCode: currencyCode,
            position: position,
            notes: notes,
            customAlias: customAlias,
            isWatchlistItem: false
        )
        
        modelContext.insert(favorite)
        saveChanges()
    }
    
    func removeFromFavorites(currencyCode: String) {
        if let favorite = favorites.first(where: { $0.currencyCode == currencyCode }) {
            modelContext.delete(favorite)
            
            // Reorder remaining favorites
            reorderFavorites()
            saveChanges()
        }
    }
    
    func addToWatchlist(
        currencyCode: String,
        notes: String? = nil,
        customAlias: String? = nil
    ) {
        // Check if already exists
        if watchlist.contains(where: { $0.currencyCode == currencyCode }) {
            return
        }
        
        let position = watchlist.count
        let watchlistItem = FavoriteCurrency(
            currencyCode: currencyCode,
            position: position,
            notes: notes,
            customAlias: customAlias,
            isWatchlistItem: true
        )
        
        modelContext.insert(watchlistItem)
        saveChanges()
    }
    
    func removeFromWatchlist(currencyCode: String) {
        if let watchlistItem = watchlist.first(where: { $0.currencyCode == currencyCode }) {
            modelContext.delete(watchlistItem)
            saveChanges()
        }
    }
    
    func toggleFavorite(currencyCode: String) {
        if isFavorite(currencyCode: currencyCode) {
            removeFromFavorites(currencyCode: currencyCode)
        } else {
            addToFavorites(currencyCode: currencyCode)
        }
    }
    
    func toggleWatchlist(currencyCode: String) {
        if isInWatchlist(currencyCode: currencyCode) {
            removeFromWatchlist(currencyCode: currencyCode)
        } else {
            addToWatchlist(currencyCode: currencyCode)
        }
    }
    
    // MARK: - Recently Viewed
    
    func addToRecentlyViewed(currencyCode: String) {
        // Remove if already exists
        if let existing = recentlyViewed.first(where: { $0.currencyCode == currencyCode }) {
            existing.lastViewedAt = Date()
        } else {
            // Create new recent item
            let recent = FavoriteCurrency(
                currencyCode: currencyCode,
                isWatchlistItem: false
            )
            recent.lastViewedAt = Date()
            modelContext.insert(recent)
        }
        
        saveChanges()
    }
    
    func clearRecentlyViewed() {
        let oldRecents = recentlyViewed.filter { recent in
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return recent.lastViewedAt < thirtyDaysAgo
        }
        
        for recent in oldRecents {
            if !isFavorite(currencyCode: recent.currencyCode) && !isInWatchlist(currencyCode: recent.currencyCode) {
                modelContext.delete(recent)
            }
        }
        
        saveChanges()
    }
    
    // MARK: - Custom Management
    
    func updateNotes(currencyCode: String, notes: String) {
        if let favorite = favorites.first(where: { $0.currencyCode == currencyCode }) {
            favorite.notes = notes.isEmpty ? nil : notes
        } else if let watchlistItem = watchlist.first(where: { $0.currencyCode == currencyCode }) {
            watchlistItem.notes = notes.isEmpty ? nil : notes
        }
        saveChanges()
    }
    
    func updateCustomAlias(currencyCode: String, alias: String) {
        if let favorite = favorites.first(where: { $0.currencyCode == currencyCode }) {
            favorite.customAlias = alias.isEmpty ? nil : alias
        } else if let watchlistItem = watchlist.first(where: { $0.currencyCode == currencyCode }) {
            watchlistItem.customAlias = alias.isEmpty ? nil : alias
        }
        saveChanges()
    }
    
    func toggleNotifications(currencyCode: String) {
        if let favorite = favorites.first(where: { $0.currencyCode == currencyCode }) {
            favorite.notificationEnabled.toggle()
        } else if let watchlistItem = watchlist.first(where: { $0.currencyCode == currencyCode }) {
            watchlistItem.notificationEnabled.toggle()
        }
        saveChanges()
    }
    
    // MARK: - Reordering
    
    func reorderFavorites() {
        for (index, favorite) in favorites.enumerated() {
            favorite.position = index
        }
        saveChanges()
    }
    
    func moveFavorite(from source: IndexSet, to destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
        reorderFavorites()
    }
    
    func moveWatchlistItem(from source: IndexSet, to destination: Int) {
        watchlist.move(fromOffsets: source, toOffset: destination)
        for (index, item) in watchlist.enumerated() {
            item.position = index
        }
        saveChanges()
    }
    
    // MARK: - Utility Functions
    
    func isFavorite(currencyCode: String) -> Bool {
        return favorites.contains { $0.currencyCode == currencyCode }
    }
    
    func isInWatchlist(currencyCode: String) -> Bool {
        return watchlist.contains { $0.currencyCode == currencyCode }
    }
    
    func getFavoriteItem(currencyCode: String) -> FavoriteCurrency? {
        return favorites.first { $0.currencyCode == currencyCode } ??
               watchlist.first { $0.currencyCode == currencyCode }
    }
    
    func getAllFavoriteCodes() -> Set<String> {
        let favoriteCodes = Set(favorites.map { $0.currencyCode })
        let watchlistCodes = Set(watchlist.map { $0.currencyCode })
        return favoriteCodes.union(watchlistCodes)
    }
    
    func getFilteredCurrencies(from currencies: [Currency], category: FavoriteCategory) -> [Currency] {
        switch category {
        case .favorites:
            let favoriteCodes = Set(favorites.map { $0.currencyCode })
            return currencies.filter { favoriteCodes.contains($0.code) }
                
        case .watchlist:
            let watchlistCodes = Set(watchlist.map { $0.currencyCode })
            return currencies.filter { watchlistCodes.contains($0.code) }
                
        case .recents:
            let recentCodes = Set(recentlyViewed.map { $0.currencyCode })
            return currencies.filter { recentCodes.contains($0.code) }
        }
    }
    
    // MARK: - Statistics
    
    func getFavoritesCount() -> Int {
        return favorites.count
    }
    
    func getWatchlistCount() -> Int {
        return watchlist.count
    }
    
    func getRecentlyViewedCount() -> Int {
        return recentlyViewed.count
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
            loadFavorites()
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}