//
//  CurrencyRateWidget.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import WidgetKit
import SwiftUI

struct CurrencyRateWidget: Widget {
    let kind: String = "CurrencyRateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrencyRateProvider()) { entry in
            CurrencyRateWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Döviz Kurları")
        .description("Güncel döviz kurlarını görüntüleyin")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CurrencyRateEntry: TimelineEntry {
    let date: Date
    let currencies: [Currency]
    let configuration: CurrencyRateConfiguration
}

struct CurrencyRateConfiguration {
    let selectedCurrencies: [String]
    let baseCurrency: String
    
    init(selectedCurrencies: [String] = ["USD", "EUR", "GBP", "JPY"], baseCurrency: String = "TRY") {
        self.selectedCurrencies = selectedCurrencies
        self.baseCurrency = baseCurrency
    }
}

struct CurrencyRateProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrencyRateEntry {
        CurrencyRateEntry(
            date: Date(),
            currencies: sampleCurrencies,
            configuration: CurrencyRateConfiguration()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CurrencyRateEntry) -> ()) {
        let entry = CurrencyRateEntry(
            date: Date(),
            currencies: sampleCurrencies,
            configuration: CurrencyRateConfiguration()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currencies = await fetchCurrencies()
            let entry = CurrencyRateEntry(
                date: Date(),
                currencies: currencies,
                configuration: CurrencyRateConfiguration()
            )
            
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func fetchCurrencies() async -> [Currency] {
        // Simulate API call - in real app, this would use CurrencyService
        return sampleCurrencies.map { currency in
            Currency(
                code: currency.code,
                name: currency.name,
                flag: currency.flag,
                rate: currency.rate * Double.random(in: 0.98...1.02), // Simulate rate changes
                changePercentage: Double.random(in: -3.0...3.0)
            )
        }
    }
    
    private var sampleCurrencies: [Currency] {
        [
            Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
            Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8),
            Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", rate: 41.12, changePercentage: 2.1),
            Currency(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", rate: 0.22, changePercentage: -0.3)
        ]
    }
}

struct CurrencyRateWidgetEntryView: View {
    var entry: CurrencyRateProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallCurrencyWidget(entry: entry)
        case .systemMedium:
            MediumCurrencyWidget(entry: entry)
        case .systemLarge:
            LargeCurrencyWidget(entry: entry)
        default:
            SmallCurrencyWidget(entry: entry)
        }
    }
}

struct SmallCurrencyWidget: View {
    let entry: CurrencyRateEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.blue)
                Text("Döviz")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Single currency (first in list)
            if let currency = entry.currencies.first {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text(currency.flag)
                            .font(.title2)
                        Text(currency.code)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    HStack {
                        Text("₺\(String(format: "%.2f", currency.rate))")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                            Text(String(format: "%.1f%%", abs(currency.changePercentage)))
                                .font(.caption)
                        }
                        .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            // Update time
            Text("Son: \(entry.date, style: .time)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MediumCurrencyWidget: View {
    let entry: CurrencyRateEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.blue)
                Text("Güncel Döviz Kurları")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("₺")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Currency list (up to 4)
            VStack(spacing: 8) {
                ForEach(Array(entry.currencies.prefix(4)), id: \.code) { currency in
                    HStack {
                        HStack(spacing: 6) {
                            Text(currency.flag)
                                .font(.title3)
                            Text(currency.code)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.2f", currency.rate))
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
            
            // Update time
            HStack {
                Spacer()
                Text("Son güncelleme: \(entry.date, style: .time)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct LargeCurrencyWidget: View {
    let entry: CurrencyRateEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("MoneyMate")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Güncel Döviz Kurları")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("TRY")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text("Baz")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Currency grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Array(entry.currencies.prefix(8)), id: \.code) { currency in
                    CurrencyCard(currency: currency)
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
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                    Text("15 dk")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct CurrencyCard: View {
    let currency: Currency
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(currency.flag)
                    .font(.title3)
                Text(currency.code)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack {
                Text("₺\(String(format: "%.2f", currency.rate))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    Text(String(format: "%.1f%%", abs(currency.changePercentage)))
                        .font(.caption2)
                }
                .foregroundColor(currency.changePercentage >= 0 ? .green : .red)
                Spacer()
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

#Preview(as: .systemSmall) {
    CurrencyRateWidget()
} timeline: {
    CurrencyRateEntry(
        date: Date(),
        currencies: [
            Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
            Currency(code: "EUR", name: "Euro", flag: "🇪🇺", rate: 35.23, changePercentage: -0.8)
        ],
        configuration: CurrencyRateConfiguration()
    )
}