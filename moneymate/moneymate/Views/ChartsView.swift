//
//  ChartsView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct ChartsView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @StateObject private var premiumService = PremiumService.shared
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @Environment(\.theme) private var theme
    
    @State private var baseCurrency: Currency?
    @State private var targetCurrency: Currency?
    @State private var selectedTimeRange: TimeRange = .oneDay
    @State private var chartData: [ChartDataPoint] = []
    @State private var showingBasePicker = false
    @State private var showingTargetPicker = false
    @State private var showingPremiumPaywall = false
    
    enum TimeRange: String, CaseIterable {
        case oneHour = "1s"
        case fourHours = "4s"
        case oneDay = "1g"
        case oneWeek = "1h"
        case oneMonth = "1a"
        case threeMonths = "3a"
        case sixMonths = "6a"
        case oneYear = "1y"
        
        var title: String {
            switch self {
            case .oneHour: return "1 Saat"
            case .fourHours: return "4 Saat"
            case .oneDay: return "1 Gün"
            case .oneWeek: return "1 Hafta"
            case .oneMonth: return "1 Ay"
            case .threeMonths: return "3 Ay"
            case .sixMonths: return "6 Ay"
            case .oneYear: return "1 Yıl"
            }
        }
        
        var isPremium: Bool {
            switch self {
            case .oneDay, .oneWeek, .oneMonth:
                return false
            case .oneHour, .fourHours, .threeMonths, .sixMonths, .oneYear:
                return true
            }
        }
        
        var dataPoints: Int {
            switch self {
            case .oneHour: return 60
            case .fourHours: return 48
            case .oneDay: return 24
            case .oneWeek: return 7
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .oneYear: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Currency Pair Selector
                currencyPairSelector
                
                // Chart
                if let base = baseCurrency, let target = targetCurrency {
                    chartView(base: base, target: target)
                } else {
                    Text("Grafik görmek için döviz çifti seçin")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Time Range Selector with Premium Lock
                timeRangeSelectorWithPremium
                
                // Stats
                if baseCurrency != nil && targetCurrency != nil {
                    statsView
                }
            }
            .padding()
            .navigationTitle("Kur Grafikleri")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupInitialCurrencies()
            }
            .onChange(of: baseCurrency) {
                generateChartData()
            }
            .onChange(of: targetCurrency) {
                generateChartData()
            }
            .onChange(of: selectedTimeRange) {
                generateChartData()
            }
        }
        .sheet(isPresented: $showingBasePicker) {
            CurrencyPickerView(selectedCurrency: $baseCurrency, title: "Ana Döviz")
                .environmentObject(currencyService)
        }
        .sheet(isPresented: $showingTargetPicker) {
            CurrencyPickerView(selectedCurrency: $targetCurrency, title: "Hedef Döviz")
                .environmentObject(currencyService)
        }
        .sheet(isPresented: $showingPremiumPaywall) {
            PremiumPaywallView()
        }
    }
    
    private var currencyPairSelector: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Base Currency
                Button {
                    showingBasePicker = true
                } label: {
                    HStack(spacing: 8) {
                        if let base = baseCurrency {
                            Text(base.flag)
                                .font(.title3)
                            Text(base.code)
                                .font(.headline)
                                .fontWeight(.medium)
                        } else {
                            Text("Ana Döviz")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("/")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                // Target Currency
                Button {
                    showingTargetPicker = true
                } label: {
                    HStack(spacing: 8) {
                        if let target = targetCurrency {
                            Text(target.flag)
                                .font(.title3)
                            Text(target.code)
                                .font(.headline)
                                .fontWeight(.medium)
                        } else {
                            Text("Hedef Döviz")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Swap Button
                Button {
                    let temp = baseCurrency
                    baseCurrency = targetCurrency
                    targetCurrency = temp
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .disabled(baseCurrency == nil || targetCurrency == nil)
            }
        }
    }
    
    private func chartView(base: Currency, target: Currency) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chart Header
            HStack {
                VStack(alignment: .leading) {
                    Text("\(base.code)/\(target.code)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(base.name) → \(target.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    let exchangeRate = currencyService.convertCurrency(amount: 1.0, from: base, to: target)
                    
                    Text(String(format: "%.4f", exchangeRate))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        let combinedTrend = calculateTrend(base: base, target: target)
                        let combinedChange = abs(base.change24h - target.change24h)
                        
                        Image(systemName: combinedTrend == "up" ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        
                        Text(String(format: "%.2f%%", combinedChange))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(calculateTrend(base: base, target: target) == "up" ? .green : .red)
                }
            }
            
            // Simple Chart Simulation
            SimpleLineChartView(
                data: chartData,
                color: calculateTrend(base: base, target: target) == "up" ? .green : .red
            )
            .frame(height: 200)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func calculateTrend(base: Currency, target: Currency) -> String {
        let combinedChange = base.change24h - target.change24h
        return combinedChange > 0 ? "up" : "down"
    }
    
    private var timeRangeSelectorWithPremium: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Zaman Aralığı")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !premiumService.isPremium {
                    Button {
                        hapticManager.buttonPressed()
                        showingPremiumPaywall = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                            Text("Premium")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [.yellow.opacity(0.2), .orange.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                    .foregroundColor(.orange)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        timeRangeButton(range: range)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func timeRangeButton(range: TimeRange) -> some View {
        Button {
            if range.isPremium && !premiumService.isPremium {
                hapticManager.buttonPressed()
                showingPremiumPaywall = true
            } else {
                hapticManager.selectionChanged()
                selectedTimeRange = range
            }
        } label: {
            HStack(spacing: 4) {
                Text(range.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if range.isPremium && !premiumService.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                selectedTimeRange == range ? 
                theme.primaryColor : 
                (range.isPremium && !premiumService.isPremium ? 
                 Color.gray.opacity(0.3) : theme.cardColor)
            )
            .foregroundColor(
                selectedTimeRange == range ? .white : 
                (range.isPremium && !premiumService.isPremium ? 
                 Color.gray : theme.textPrimaryColor)
            )
            .cornerRadius(8)
        }
        .disabled(range.isPremium && !premiumService.isPremium && selectedTimeRange != range)
        .opacity(range.isPremium && !premiumService.isPremium ? 0.6 : 1.0)
    }
    
    private var timeRangeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(range.rawValue) {
                        selectedTimeRange = range
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        selectedTimeRange == range ? 
                        Color.blue : Color(.systemGray6)
                    )
                    .foregroundColor(
                        selectedTimeRange == range ? 
                        .white : .primary
                    )
                    .cornerRadius(20)
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var statsView: some View {
        guard let base = baseCurrency, let target = targetCurrency else { return AnyView(EmptyView()) }
        
        let exchangeRate = currencyService.convertCurrency(amount: 1.0, from: base, to: target)
        
        return AnyView(
            HStack(spacing: 16) {
                StatItemView(
                    title: "En Yüksek",
                    value: String(format: "%.4f", exchangeRate * 1.02),
                    color: .green
                )
                
                StatItemView(
                    title: "En Düşük",
                    value: String(format: "%.4f", exchangeRate * 0.98),
                    color: .red
                )
                
                StatItemView(
                    title: "Ortalama",
                    value: String(format: "%.4f", exchangeRate),
                    color: .blue
                )
                
                StatItemView(
                    title: "Volatilite",
                    value: "1.2%",
                    color: .orange
                )
            }
        )
    }
    
    private func setupInitialCurrencies() {
        if baseCurrency == nil && !currencyService.currencies.isEmpty {
            baseCurrency = currencyService.currencies.first { $0.code == "USD" } ?? currencyService.currencies.first
        }
        if targetCurrency == nil && !currencyService.currencies.isEmpty {
            // Try to find TRY first, but if not available, use EUR, then any other currency
            targetCurrency = currencyService.currencies.first { $0.code == "TRY" } 
                ?? currencyService.currencies.first { $0.code == "EUR" }
                ?? currencyService.currencies.first { $0.code != baseCurrency?.code }
        }
        generateChartData()
    }
    
    private func generateChartData() {
        guard let base = baseCurrency, let target = targetCurrency else { return }
        
        let exchangeRate = currencyService.convertCurrency(amount: 1.0, from: base, to: target)
        let dataPoints = selectedTimeRange.dataPoints
        var newChartData: [ChartDataPoint] = []
        
        for i in 0..<dataPoints {
            let date = Calendar.current.date(byAdding: .hour, value: -i, to: Date()) ?? Date()
            let variation = sin(Double(i) * 0.5) + Double.random(in: -0.2...0.2)
            let rate = exchangeRate * (1 + variation * 0.02)
            
            newChartData.append(ChartDataPoint(date: date, rate: rate))
        }
        
        chartData = newChartData.reversed()
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let rate: Double
}

struct StatItemView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SimpleLineChartView: View {
    let data: [ChartDataPoint]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !data.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(data.count - 1)
                
                let minRate = data.map { $0.rate }.min() ?? 0
                let maxRate = data.map { $0.rate }.max() ?? 1
                let range = maxRate - minRate
                
                // Start path
                let firstPoint = CGPoint(
                    x: 0,
                    y: height - CGFloat((data[0].rate - minRate) / range) * height
                )
                path.move(to: firstPoint)
                
                // Draw line through all points
                for (index, dataPoint) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat((dataPoint.rate - minRate) / range) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(color, lineWidth: 2)
            
            // Add dots for each data point
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(data.count - 1)
                
                let minRate = data.map { $0.rate }.min() ?? 0
                let maxRate = data.map { $0.rate }.max() ?? 1
                let range = maxRate - minRate
                
                let x = CGFloat(index) * stepX
                let y = height - CGFloat((dataPoint.rate - minRate) / range) * height
                
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .position(x: x, y: y)
            }
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(CurrencyService())
}