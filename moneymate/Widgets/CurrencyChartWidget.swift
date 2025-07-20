//
//  CurrencyChartWidget.swift
//  MoneyMateWidgets
//
//  Created by pc on 17.07.2025.
//

import WidgetKit
import SwiftUI
import Charts

struct CurrencyChartWidget: Widget {
    let kind: String = "CurrencyChartWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrencyChartProvider()) { entry in
            CurrencyChartWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Döviz Grafiği")
        .description("Seçili dövizin trend grafiğini görüntüleyin")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct CurrencyChartEntry: TimelineEntry {
    let date: Date
    let currency: Currency
    let chartData: [ChartDataPoint]
    let timeRange: ChartTimeRange
}

struct ChartDataPoint {
    let date: Date
    let value: Double
    let change: Double
}

enum ChartTimeRange: String, CaseIterable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    
    var displayName: String {
        switch self {
        case .day: return "1 Gün"
        case .week: return "1 Hafta"
        case .month: return "1 Ay"
        case .threeMonths: return "3 Ay"
        }
    }
    
    var pointCount: Int {
        switch self {
        case .day: return 24
        case .week: return 168
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

struct CurrencyChartProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrencyChartEntry {
        CurrencyChartEntry(
            date: Date(),
            currency: sampleCurrency,
            chartData: generateSampleData(for: .day),
            timeRange: .day
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CurrencyChartEntry) -> ()) {
        let entry = CurrencyChartEntry(
            date: Date(),
            currency: sampleCurrency,
            chartData: generateSampleData(for: .day),
            timeRange: .day
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currency = await fetchCurrency()
            let chartData = await fetchChartData(for: currency, timeRange: .day)
            
            let entry = CurrencyChartEntry(
                date: Date(),
                currency: currency,
                chartData: chartData,
                timeRange: .day
            )
            
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func fetchCurrency() async -> Currency {
        // In real app, this would fetch from user's selected currency for widget
        return sampleCurrency
    }
    
    private func fetchChartData(for currency: Currency, timeRange: ChartTimeRange) async -> [ChartDataPoint] {
        // In real app, this would fetch historical data from API
        return generateSampleData(for: timeRange)
    }
    
    private var sampleCurrency: Currency {
        Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2)
    }
    
    private func generateSampleData(for timeRange: ChartTimeRange) -> [ChartDataPoint] {
        let count = min(timeRange.pointCount, 24) // Limit for widget performance
        let baseValue = 32.45
        var data: [ChartDataPoint] = []
        
        for i in 0..<count {
            let date = Calendar.current.date(byAdding: .hour, value: -count + i + 1, to: Date()) ?? Date()
            let variation = sin(Double(i) * 0.3) * 0.5 + Double.random(in: -0.2...0.2)
            let value = baseValue + variation
            let change = i > 0 ? ((value - data[i-1].value) / data[i-1].value) * 100 : 0
            
            data.append(ChartDataPoint(date: date, value: value, change: change))
        }
        
        return data
    }
}

struct CurrencyChartWidgetEntryView: View {
    var entry: CurrencyChartProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumChartWidget(entry: entry)
        case .systemLarge:
            LargeChartWidget(entry: entry)
        default:
            MediumChartWidget(entry: entry)
        }
    }
}

struct MediumChartWidget: View {
    let entry: CurrencyChartEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Text(entry.currency.flag)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.currency.code)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(entry.currency.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₺\(String(format: "%.2f", entry.currency.rate))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        Image(systemName: entry.currency.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text(String(format: "%.1f%%", abs(entry.currency.changePercentage)))
                            .font(.caption)
                    }
                    .foregroundColor(entry.currency.changePercentage >= 0 ? .green : .red)
                }
            }
            
            // Chart
            Chart(entry.chartData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Zaman", dataPoint.date),
                    y: .value("Kur", dataPoint.value)
                )
                .foregroundStyle(chartColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Zaman", dataPoint.date),
                    y: .value("Kur", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [chartColor.opacity(0.3), chartColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 60)
            
            // Footer
            HStack {
                Text(entry.timeRange.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Son: \(entry.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var chartColor: Color {
        entry.currency.changePercentage >= 0 ? .green : .red
    }
}

struct LargeChartWidget: View {
    let entry: CurrencyChartEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Text(entry.currency.flag)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.currency.code)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(entry.currency.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(String(format: "%.4f", entry.currency.rate))")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: entry.currency.changePercentage >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.subheadline)
                        Text(String(format: "%.2f%%", abs(entry.currency.changePercentage)))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(entry.currency.changePercentage >= 0 ? .green : .red)
                }
            }
            
            // Chart with more details
            VStack(spacing: 8) {
                HStack {
                    Text("Trend Analizi")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(entry.timeRange.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Chart(entry.chartData, id: \.date) { dataPoint in
                    LineMark(
                        x: .value("Zaman", dataPoint.date),
                        y: .value("Kur", dataPoint.value)
                    )
                    .foregroundStyle(chartColor)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Zaman", dataPoint.date),
                        y: .value("Kur", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [chartColor.opacity(0.4), chartColor.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Data points
                    PointMark(
                        x: .value("Zaman", dataPoint.date),
                        y: .value("Kur", dataPoint.value)
                    )
                    .foregroundStyle(chartColor)
                    .symbolSize(30)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 120)
            }
            
            // Statistics
            HStack(spacing: 16) {
                StatBox(title: "En Yüksek", value: maxValue, color: .green)
                StatBox(title: "En Düşük", value: minValue, color: .red)
                StatBox(title: "Ortalama", value: avgValue, color: .blue)
            }
            
            Spacer()
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption2)
                    Text("Grafik Analizi")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Son güncelleme: \(entry.date, formatter: timeFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var chartColor: Color {
        entry.currency.changePercentage >= 0 ? .green : .red
    }
    
    private var maxValue: Double {
        entry.chartData.map(\.value).max() ?? 0
    }
    
    private var minValue: Double {
        entry.chartData.map(\.value).min() ?? 0
    }
    
    private var avgValue: Double {
        let sum = entry.chartData.map(\.value).reduce(0, +)
        return sum / Double(entry.chartData.count)
    }
}

struct StatBox: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("₺\(String(format: "%.2f", value))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

#Preview(as: .systemLarge) {
    CurrencyChartWidget()
} timeline: {
    let sampleData = (0..<24).map { i in
        let date = Calendar.current.date(byAdding: .hour, value: -24 + i, to: Date()) ?? Date()
        let value = 32.45 + sin(Double(i) * 0.3) * 0.5
        return ChartDataPoint(date: date, value: value, change: Double.random(in: -2...2))
    }
    
    return CurrencyChartEntry(
        date: Date(),
        currency: Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", rate: 32.45, changePercentage: 1.2),
        chartData: sampleData,
        timeRange: .day
    )
}