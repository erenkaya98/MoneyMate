//
//  FavoriteCurrency.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import SwiftData

@Model
final class FavoriteCurrency {
    var id: UUID
    var currencyCode: String
    var addedAt: Date
    var position: Int // For custom ordering
    var notes: String? // User notes
    var customAlias: String? // Custom name for the currency
    var isWatchlistItem: Bool // Different from regular favorites
    var lastViewedAt: Date
    var notificationEnabled: Bool
    
    init(
        currencyCode: String,
        position: Int = 0,
        notes: String? = nil,
        customAlias: String? = nil,
        isWatchlistItem: Bool = false,
        notificationEnabled: Bool = true
    ) {
        self.id = UUID()
        self.currencyCode = currencyCode
        self.addedAt = Date()
        self.position = position
        self.notes = notes
        self.customAlias = customAlias
        self.isWatchlistItem = isWatchlistItem
        self.lastViewedAt = Date()
        self.notificationEnabled = notificationEnabled
    }
}

// MARK: - Favorite Categories
enum FavoriteCategory: String, CaseIterable {
    case favorites = "favorites"
    case watchlist = "watchlist"
    case recents = "recents"
    
    var displayName: String {
        switch self {
        case .favorites: return "Favoriler"
        case .watchlist: return "İzleme Listesi"
        case .recents: return "Son Görüntülenen"
        }
    }
    
    var systemImage: String {
        switch self {
        case .favorites: return "star.fill"
        case .watchlist: return "eye.fill"
        case .recents: return "clock.fill"
        }
    }
    
    var color: String {
        switch self {
        case .favorites: return "yellow"
        case .watchlist: return "blue"
        case .recents: return "green"
        }
    }
}