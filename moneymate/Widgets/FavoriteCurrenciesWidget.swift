//
//  FavoriteCurrenciesWidget.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import WidgetKit
import SwiftUI

struct FavoriteCurrenciesWidget: Widget {
    let kind: String = "FavoriteCurrenciesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteCurrenciesProvider()) { entry in
            FavoriteCurrenciesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Favori Dövizler")
        .description("Favori döviz kurlarınızı takip edin")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct FavoriteCurrenciesEntry: TimelineEntry {
    let date: Date
    let favorites: [Currency]
    let watchlist: [Currency]
    let hasData: Bool
}

struct FavoriteCurrenciesProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoriteCurrenciesEntry {
        FavoriteCurrenciesEntry(
            date: Date(),
            favorites: sampleFavorites,
            watchlist: sampleWatchlist,
            hasData: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoriteCurrenciesEntry) -> ()) {
        let entry = FavoriteCurrenciesEntry(
            date: Date(),
            favorites: sampleFavorites,
            watchlist: sampleWatchlist,
            hasData: true
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let (favorites, watchlist) = await fetchFavoriteData()
            let entry = FavoriteCurrenciesEntry(
                date: Date(),
                favorites: favorites,
                watchlist: watchlist,
                hasData: !favorites.isEmpty || !watchlist.isEmpty
            )
            
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func fetchFavoriteData() async -> ([Currency], [Currency]) {
        // In real app, this would fetch from FavoritesService and update with current rates
        return (sampleFavorites, sampleWatchlist)
    }
    
    private var sampleFavorites: [Currency] {
        [
            Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
            Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8),
            Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", rate: 41.12, changePercentage: 2.1)
        ]
    }
    
    private var sampleWatchlist: [Currency] {
        [
            Currency(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", rate: 0.22, changePercentage: -0.3),
            Currency(code: "CHF", name: "Swiss Franc", flag: "🇨🇭", rate: 37.89, changePercentage: 0.5)
        ]
    }
}

struct FavoriteCurrenciesWidgetEntryView: View {
    var entry: FavoriteCurrenciesProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if !entry.hasData {
            EmptyFavoritesWidget()
        } else {
            switch family {
            case .systemSmall:
                SmallFavoritesWidget(entry: entry)
            case .systemMedium:
                MediumFavoritesWidget(entry: entry)
            case .systemLarge:
                LargeFavoritesWidget(entry: entry)
            default:
                SmallFavoritesWidget(entry: entry)
            }
        }
    }
}

struct SmallFavoritesWidget: View {
    let entry: FavoriteCurrenciesEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Favoriler")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(entry.favorites.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Top favorite
            if let topFavorite = entry.favorites.first {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text(topFavorite.flag)
                            .font(.title2)
                        Text(topFavorite.code)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("₺\(String(format: "%.2f", topFavorite.rate))")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: topFavorite.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                            Text(String(format: "%.1f%%", abs(topFavorite.changePercentage)))
                                .font(.caption)
                        }
                        .foregroundColor(topFavorite.changePercentage >= 0 ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            // Quick action
            if entry.favorites.count > 1 {
                Text("+\(entry.favorites.count - 1) daha")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct MediumFavoritesWidget: View {
    let entry: FavoriteCurrenciesEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with tabs
            HStack {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("Favoriler")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("(\(entry.favorites.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("İzleme")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("(\(entry.watchlist.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            
            // Favorites list
            VStack(spacing: 6) {
                ForEach(Array(entry.favorites.prefix(3)), id: \.code) { currency in
                    HStack {
                        HStack(spacing: 6) {
                            Text(currency.flag)
                                .font(.subheadline)
                            Text(currency.code)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("₺\(String(format: "%.2f", currency.rate))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 2) {
                                Image(systemName: currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption2)
                                Text(String(format: "%.1f%%", abs(currency.changePercentage)))
                                    .font(.caption2)
                            }
                            .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Son: \(entry.date, style: .time)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                if entry.favorites.count > 3 {
                    Text("+\(entry.favorites.count - 3) daha")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct LargeFavoritesWidget: View {
    let entry: FavoriteCurrenciesEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                VStack(alignment: .leading) {
                    Text("Favori Dövizlerim")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Kişisel takip listeniz")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Two sections
            HStack(spacing: 16) {
                // Favorites column
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("Favoriler (\(entry.favorites.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    VStack(spacing: 6) {
                        ForEach(Array(entry.favorites.prefix(4)), id: \.code) { currency in
                            FavoriteRowCompact(currency: currency)
                        }
                    }
                    
                    if entry.favorites.count > 4 {
                        Text("+\(entry.favorites.count - 4) daha")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                Divider()
                
                // Watchlist column
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("İzleme (\(entry.watchlist.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    if entry.watchlist.isEmpty {
                        VStack(spacing: 4) {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                                .font(.title3)
                            Text("İzleme listesi boş")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(Array(entry.watchlist.prefix(4)), id: \.code) { currency in
                                FavoriteRowCompact(currency: currency)
                            }
                        }
                        
                        if entry.watchlist.count > 4 {
                            Text("+\(entry.watchlist.count - 4) daha")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Son güncelleme: \(entry.date, formatter: timeFormatter)")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Favorilerini yönet →")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

struct FavoriteRowCompact: View {
    let currency: Currency
    
    var body: some View {
        HStack(spacing: 6) {
            Text(currency.flag)
                .font(.caption)
            Text(currency.code)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 1) {
                Text("₺\(String(format: "%.1f", currency.rate))")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                HStack(spacing: 1) {
                    Image(systemName: currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 8))
                    Text(String(format: "%.1f%%", abs(currency.changePercentage)))
                        .font(.system(size: 9))
                }
                .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
            }
        }
    }
}

struct EmptyFavoritesWidget: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star")
                .font(.title)
                .foregroundColor(.yellow)
            
            VStack(spacing: 4) {
                Text("Henüz Favori Yok")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("MoneyMate uygulamasında favori dövizlerinizi ekleyin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Text("Uygulamayı Aç →")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

#Preview(as: .systemMedium) {
    FavoriteCurrenciesWidget()
} timeline: {
    FavoriteCurrenciesEntry(
        date: Date(),
        favorites: [
            Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
            Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8),
            Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", rate: 41.12, changePercentage: 2.1)
        ],
        watchlist: [
            Currency(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", rate: 0.22, changePercentage: -0.3)
        ],
        hasData: true
    )
}