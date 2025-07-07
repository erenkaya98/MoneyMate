import SwiftUI

struct CurrencyInfo: Identifiable {
    let id = UUID()
    let code: String
    let symbol: String
    let name: String
}

struct WatchlistView: View {
    @State private var rates: [String: Double] = ["USD": 1.0]
    @State private var prevRates: [String: Double] = ["USD": 1.0]
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var lastUpdated: Date? = nil
    @State private var timerProgress: Double = 1.0
    @State private var updateTimer: Timer? = nil
    @Namespace private var animation
    @State private var convertFrom: String = "USD"
    @State private var convertTo: String = "EUR"
    @State private var convertAmount: String = "1"
    @State private var rate: Double? = nil
    @State private var history: [(date: String, value: Double)] = []

    let currencies: [CurrencyInfo] = [
        CurrencyInfo(code: "EUR", symbol: "€", name: "Euro"),
        CurrencyInfo(code: "USD", symbol: "$", name: "US Dollar"),
        CurrencyInfo(code: "GBP", symbol: "£", name: "British Pound"),
        CurrencyInfo(code: "TRY", symbol: "₺", name: "Turkish Lira"),
        CurrencyInfo(code: "JPY", symbol: "¥", name: "Japanese Yen"),
        CurrencyInfo(code: "CAD", symbol: "C$", name: "Canadian Dollar"),
        CurrencyInfo(code: "AUD", symbol: "A$", name: "Australian Dollar"),
        CurrencyInfo(code: "NZD", symbol: "NZ$", name: "New Zealand Dollar"),
        CurrencyInfo(code: "CHF", symbol: "Fr", name: "Swiss Franc"),
        CurrencyInfo(code: "CNY", symbol: "¥", name: "Chinese Yuan"),
        CurrencyInfo(code: "HKD", symbol: "HK$", name: "Hong Kong Dollar")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TopBarView(lastUpdated: lastUpdated, timerProgress: timerProgress)
                    RatesTableView(
                        currencies: currencies,
                        rates: rates,
                        prevRates: prevRates,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        animation: animation
                    )
                    ConvertCardView2(
                        currencies: currencies.map { (code: $0.code, symbol: $0.symbol, flag: "", name: $0.name) },
                        from: $convertFrom,
                        to: $convertTo,
                        rate: $rate,
                        history: $history,
                        isLoading: $isLoading
                    )
                    AlertCardView2(
                        currencies: currencies.map { (code: $0.code, symbol: $0.symbol, flag: "", name: $0.name) },
                        from: $convertFrom,
                        to: $convertTo,
                        rate: $rate
                    )
                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                fetchRatesWithPrev()
                startUpdateTimer()
            }
            .onDisappear {
                stopUpdateTimer()
            }
        }
    }
    
    var convertedResult: String {
        guard let amount = Double(convertAmount.replacingOccurrences(of: ",", with: ".")),
              let fromRate = rates[convertFrom],
              let toRate = rates[convertTo] else { return "-" }
        let result = amount / fromRate * toRate
        return String(format: "%.4f", result)
    }
    
    func swapCurrencies() {
        let temp = convertFrom
        convertFrom = convertTo
        convertTo = temp
    }
    
    // Timer functions for 1-minute updates
    func startUpdateTimer() {
        stopUpdateTimer()
        timerProgress = 1.0
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.linear(duration: 1)) {
                timerProgress -= 1.0 / 60.0 // Decrease by 1/60th each second (1 minute total)
                
                if timerProgress <= 0 {
                    timerProgress = 1.0
                    fetchRatesWithPrev()
                }
            }
        }
    }
    
    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func fetchRatesWithPrev() {
        isLoading = true
        errorMessage = nil
        let symbols = currencies.map { $0.code }.joined(separator: ",")
        let today = Date()
        let calendar = Calendar.current
        // Find the most recent previous weekday (for 24h ago)
        var prevDate = calendar.date(byAdding: .day, value: -1, to: today)!
        while calendar.isDateInWeekend(prevDate) {
            prevDate = calendar.date(byAdding: .day, value: -1, to: prevDate)!
        }
        let prevDateString = DateFormatter.yyyyMMdd.string(from: prevDate)
        let group = DispatchGroup()
        var latestRates: [String: Double] = ["USD": 1.0]
        var previousRates: [String: Double] = ["USD": 1.0]
        var fetchError: String? = nil
        // Fetch latest
        group.enter()
        let urlString = "https://api.frankfurter.app/latest?from=USD&to=\(symbols)"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    fetchError = "Failed to fetch rates: \(error.localizedDescription)"
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let ratesAny = json["rates"] as? [String: Any] {
                            for (code, value) in ratesAny {
                                if let doubleValue = value as? Double {
                                    latestRates[code] = doubleValue
                                } else if let intValue = value as? Int {
                                    latestRates[code] = Double(intValue)
                                } else if let strValue = value as? String, let doubleValue = Double(strValue) {
                                    latestRates[code] = doubleValue
                                }
                            }
                        } else {
                            fetchError = "Invalid response format."
                        }
                    } catch {
                        fetchError = "Failed to parse rates."
                    }
                }
                group.leave()
            }.resume()
        } else {
            fetchError = "Invalid URL."
            group.leave()
        }
        // Fetch previous
        group.enter()
        let prevUrlString = "https://api.frankfurter.app/\(prevDateString)?from=USD&to=\(symbols)"
        if let url = URL(string: prevUrlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    fetchError = "Failed to fetch previous rates: \(error.localizedDescription)"
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let ratesAny = json["rates"] as? [String: Any] {
                            for (code, value) in ratesAny {
                                if let doubleValue = value as? Double {
                                    previousRates[code] = doubleValue
                                } else if let intValue = value as? Int {
                                    previousRates[code] = Double(intValue)
                                } else if let strValue = value as? String, let doubleValue = Double(strValue) {
                                    previousRates[code] = doubleValue
                                }
                            }
                        } else {
                            fetchError = "Invalid response format (prev)."
                        }
                    } catch {
                        fetchError = "Failed to parse previous rates."
                    }
                }
                group.leave()
            }.resume()
        } else {
            fetchError = "Invalid URL (prev)."
            group.leave()
        }
        group.notify(queue: .main) {
            isLoading = false
            if let fetchError = fetchError {
                errorMessage = fetchError
            } else {
                withAnimation {
                    rates = latestRates
                    prevRates = previousRates
                    lastUpdated = Date()
                }
            }
        }
    }
}

struct TopBarView: View {
    let lastUpdated: Date?
    let timerProgress: Double
    var body: some View {
        HStack {
            Text("Live Rates")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            HStack(spacing: 8) {
                if let lastUpdated = lastUpdated {
                    Text("Last Updated \(lastUpdated, formatter: DateFormatter.timeOnly)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    Circle()
                        .trim(from: 0, to: timerProgress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerProgress)
                    Text("\(Int(ceil(timerProgress * 60)))")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct RatesTableView: View {
    let currencies: [CurrencyInfo]
    let rates: [String: Double]
    let prevRates: [String: Double]
    let isLoading: Bool
    let errorMessage: String?
    let animation: Namespace.ID
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Currency").font(.caption).foregroundColor(.secondary).frame(width: 100, alignment: .leading)
                Spacer()
                Text("Rate (USD)").font(.caption).foregroundColor(.secondary).frame(width: 90, alignment: .trailing)
                Spacer()
                Text("24h Change").font(.caption).foregroundColor(.secondary).frame(width: 90, alignment: .trailing)
            }
            .padding(.horizontal)
            Divider()
            if isLoading {
                ProgressView("Fetching rates...").padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red).padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(currencies) { currency in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(currency.symbol) \(currency.code)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 100, alignment: .leading)
                            Spacer()
                            Text(String(format: "%.4f", rates[currency.code] ?? 0.0))
                                .font(.headline)
                                .fontWeight(.medium)
                                .frame(width: 90, alignment: .trailing)
                                .matchedGeometryEffect(id: currency.code, in: animation)
                            Spacer()
                            let change = (rates[currency.code] ?? 0.0) - (prevRates[currency.code] ?? 0.0)
                            let (arrow, color, bgColor) = change > 0 ? ("▲", Color.green, Color.green.opacity(0.15)) : (change < 0 ? ("▼", Color.red, Color.red.opacity(0.15)) : ("→", Color.gray, Color.gray.opacity(0.15)))
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(arrow)
                                        .font(.caption2)
                                        .bold()
                                    Text(String(format: "%@%.4f", change >= 0 ? "+" : "", change))
                                        .font(.caption)
                                        .bold()
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(bgColor)
                                .foregroundColor(color)
                                .cornerRadius(8)
                            }
                            .frame(width: 90, alignment: .trailing)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        Divider()
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: rates)
            }
        }
    }
}

struct ConvertCardView2: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var from: String
    @Binding var to: String
    @Binding var rate: Double?
    @Binding var history: [(date: String, value: Double)]
    @Binding var isLoading: Bool

    var body: some View {
        // Implementation of ConvertCardView
        Text("Convert Card View")
    }
}

struct AlertCardView2: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var from: String
    @Binding var to: String
    @Binding var rate: Double?

    var body: some View {
        // Implementation of AlertCardView
        Text("Alert Card View")
    }
}

fileprivate extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    static let timeOnly: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        return df
    }()
}

#Preview {
    WatchlistView()
} 