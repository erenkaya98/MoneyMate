import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0 // Home tab default
    // Currency list (ordered as requested)
    let currencies: [(code: String, symbol: String, flag: String, name: String)] = [
        ("EUR", "€", "🇪🇺", "Euro"),
        ("USD", "$", "🇺🇸", "US Dollar"),
        ("GBP", "£", "🇬🇧", "British Pound"),
        ("TRY", "₺", "🇹🇷", "Turkish Lira"),
        ("JPY", "¥", "🇯🇵", "Japanese Yen"),
        ("CAD", "C$", "🇨🇦", "Canadian Dollar"),
        ("AUD", "A$", "🇦🇺", "Australian Dollar"),
        ("NZD", "NZ$", "🇳🇿", "New Zealand Dollar"),
        ("CHF", "Fr", "🇨🇭", "Swiss Franc"),
        ("CNY", "¥", "🇨🇳", "Chinese Yuan"),
        ("HKD", "HK$", "🇭🇰", "Hong Kong Dollar")
    ]
    @State private var from: String = "USD"
    @State private var to: String = "TRY"
    @State private var rate: Double? = nil
    @State private var history: [(date: String, value: Double)] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab - WatchlistView
            WatchlistView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }.tag(0)
            
            // Convert tab
            convertTabView
                .tabItem {
                    Image(systemName: "arrow.2.squarepath")
                    Text("Convert")
                }.tag(1)
            
            // Send tab placeholder
            Text("Send").tabItem {
                Image(systemName: "arrow.up")
                Text("Send")
            }.tag(2)
            // Charts tab placeholder
            Text("Charts").tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Charts")
            }.tag(3)
            // More tab placeholder
            Text("More").tabItem {
                Image(systemName: "ellipsis")
                Text("More")
            }.tag(4)
        }
    }
    
    // Extract Convert tab content to reduce complexity
    private var convertTabView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Top bar
                    HStack {
                        Image(systemName: "person.circle.fill").font(.system(size: 32)).foregroundColor(.gray)
                        Spacer()
                        Text("Welcome").font(.title2).bold()
                        Spacer()
                        Image(systemName: "bell.fill").font(.title2).foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ConvertCardView(
                        currencies: currencies,
                        from: $from,
                        to: $to,
                        rate: rate,
                        history: history,
                        isLoading: isLoading
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                                            AlertCardView(
                            currencies: currencies,
                            from: $from,
                            to: $to,
                            rate: rate
                        )
                        .padding(.horizontal)
                        .padding(.top, 16)
                        Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear(perform: fetchAll)
            .onChange(of: from) { fetchAll() }
            .onChange(of: to) { fetchAll() }
        }
    }
    
    // Fetch live rate and 1-month history
    func fetchAll() {
        isLoading = true
        errorMessage = nil
        // Fetch current rate
        let rateUrl = "https://api.frankfurter.app/latest?from=\(from)&to=\(to)"
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.string(from: monthAgo)
        let historyUrl = "https://api.frankfurter.app/\(startDate)..latest?from=\(from)&to=\(to)"
        // Fetch both in parallel
        let group = DispatchGroup()
        var fetchedRate: Double? = nil
        var fetchedHistory: [(String, Double)] = []
        group.enter()
        if let url = URL(string: rateUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rates = json["rates"] as? [String: Any],
                   let val = rates[to] as? Double {
                    fetchedRate = val
                }
            }.resume()
        } else { group.leave() }
        group.enter()
        if let url = URL(string: historyUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rates = json["rates"] as? [String: [String: Double]] {
                    let sorted = rates.sorted { $0.key < $1.key }
                    fetchedHistory = sorted.compactMap { (date, dict) in
                        if let val = dict[to] { return (date, val) } else { return nil }
                    }
                }
            }.resume()
        } else { group.leave() }
        group.notify(queue: .main) {
            self.rate = fetchedRate
            self.history = fetchedHistory
            self.isLoading = false
        }
    }
}

// Convert card as a subview
struct ConvertCardView: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var from: String
    @Binding var to: String
    let rate: Double?
    let history: [(date: String, value: Double)]
    let isLoading: Bool
    @State private var amount: String = "1"
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            currencyPickerRow
            amountInputSection
            rateDisplayView
            chartSection
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color(.systemGray4), radius: 8, x: 0, y: 2)
    }
    
    // Break down into smaller components
    private var currencyPickerRow: some View {
        HStack(spacing: 8) {
            CurrencyPickerView(currencies: currencies, selection: $from)
            Image(systemName: "arrow.right")
                .font(.title2)
                .foregroundColor(.gray)
            CurrencyPickerView(currencies: currencies, selection: $to)
        }
        .padding(.top, 8)
    }
    
    private var amountInputSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Amount")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                
                Text(symbol(for: from))
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            if let rate = rate, let inputAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) {
                let convertedAmount = inputAmount * rate
                HStack {
                    Text("\(String(format: "%.2f", inputAmount)) \(from)")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", convertedAmount)) \(to)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var rateDisplayView: some View {
        Group {
            if let rate = rate {
                Text("1 \(from) = \(String(format: "%.6f", rate)) \(to)  Today")
                    .font(.headline)
                    .padding(.top, 4)
            } else if isLoading {
                ProgressView().padding(.top, 4)
            }
        }
    }
    
    private var chartSection: some View {
        Group {
            if !history.isEmpty {
                VStack {
                    LineChart(data: history.map { $0.value })
                        .frame(height: 120)
                        .padding(.vertical, 8)
                    HStack {
                        Text(history.first?.date ?? "").font(.caption).foregroundColor(.secondary)
                        Spacer()
                        Text("Today").font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
    

    
    // Helper function to get currency symbol
    private func symbol(for code: String) -> String {
        currencies.first(where: { $0.code == code })?.symbol ?? code
    }
}

// Currency picker as a subview
struct CurrencyPickerView: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var selection: String
    var body: some View {
        Menu {
            ForEach(currencies, id: \ .code) { currency in
                Button(action: { selection = currency.code }) {
                    Text("\(currency.flag) \(currency.code)")
                }
            }
        } label: {
            let selected = currencies.first(where: { $0.code == selection })
            HStack {
                Text(selected?.flag ?? "")
                Text(selected?.code ?? "")
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

// Alert card as a subview
struct AlertCardView: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var from: String
    @Binding var to: String
    let rate: Double?
    
    @State private var alertAmount: String = ""
    @State private var targetRate: String = ""
    @State private var isAlertSheetPresented = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge").font(.title2).foregroundColor(.orange)
                Text("Currency Alerts")
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top, 8)
            
            Button(action: {
                isAlertSheetPresented = true
            }) {
                Text("Create Alert")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                    .font(.headline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color(.systemGray4), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $isAlertSheetPresented) {
            AlertSetupSheet(
                currencies: currencies,
                from: $from,
                to: $to,
                rate: rate,
                alertAmount: $alertAmount,
                targetRate: $targetRate,
                isPresented: $isAlertSheetPresented,
                showingAlert: $showingAlert,
                alertMessage: $alertMessage
            )
        }
        .alert("Alert Created", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

// Alert setup sheet
struct AlertSetupSheet: View {
    let currencies: [(code: String, symbol: String, flag: String, name: String)]
    @Binding var from: String
    @Binding var to: String
    let rate: Double?
    @Binding var alertAmount: String
    @Binding var targetRate: String
    @Binding var isPresented: Bool
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isRateFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current rate display
                if let currentRate = rate {
                    VStack(spacing: 8) {
                        Text("Current Rate")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("1 \(from) = \(String(format: "%.6f", currentRate)) \(to)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount to Monitor")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter amount", text: $alertAmount)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(symbol(for: from))
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Target amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Amount")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter target amount", text: $targetRate)
                            .keyboardType(.decimalPad)
                            .focused($isRateFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(symbol(for: to))
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Alert preview
                if let amount = Double(alertAmount), let targetAmount = Double(targetRate), let current = rate {
                    let currentConverted = amount * current
                    let requiredRate = targetAmount / amount
                    let difference = targetAmount - currentConverted
                    
                    VStack(spacing: 8) {
                        Text("Alert Preview")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 4) {
                            Text("When \(String(format: "%.2f", amount)) \(from) = \(String(format: "%.2f", targetAmount)) \(to)")
                                .font(.body)
                                .multilineTextAlignment(.center)
                            Text("Required rate: \(String(format: "%.6f", requiredRate)) \(to)/\(from)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Current: \(String(format: "%.2f", currentConverted)) \(to)")
                                .font(.body)
                            Text("Difference: \(String(format: "%.2f", difference)) \(to)")
                                .font(.body)
                                .foregroundColor(difference > 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createAlert()
                    }
                    .disabled(alertAmount.isEmpty || targetRate.isEmpty)
                }
            }
        }
    }
    
    private func createAlert() {
        guard let amount = Double(alertAmount), let targetAmount = Double(targetRate) else {
            alertMessage = "Please enter valid amounts"
            showingAlert = true
            return
        }
        
        // Here you would typically save the alert to a database or notification system
        alertMessage = "Alert created! You'll be notified when \(String(format: "%.2f", amount)) \(from) equals \(String(format: "%.2f", targetAmount)) \(to)"
        showingAlert = true
        isPresented = false
        
        // Reset form
        alertAmount = ""
        targetRate = ""
    }
    
    // Helper function to get currency symbol
    private func symbol(for code: String) -> String {
        currencies.first(where: { $0.code == code })?.symbol ?? code
    }
}

// Simple line chart for demo
struct LineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geo in
            if data.count > 1 {
                chartContent(geometry: geo)
            }
        }
    }
    
    private func chartContent(geometry: GeometryProxy) -> some View {
        let minY = data.min() ?? 0
        let maxY = data.max() ?? 1
        let points = calculatePoints(geometry: geometry, minY: minY, maxY: maxY)
        
        return ZStack {
            chartBackground(points: points, geometry: geometry)
            chartLine(points: points)
        }
    }
    
    private func calculatePoints(geometry: GeometryProxy, minY: Double, maxY: Double) -> [CGPoint] {
        var points: [CGPoint] = []
        let width = geometry.size.width
        let height = geometry.size.height
        let count = data.count
        
        for (i, val) in data.enumerated() {
            let x = width * CGFloat(i) / CGFloat(count - 1)
            let normalizedValue = (val - minY) / (maxY - minY + 0.0001)
            let y = height * CGFloat(1 - normalizedValue)
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
    
    private func chartLine(points: [CGPoint]) -> some View {
        Path { path in
            path.move(to: points.first ?? .zero)
            for pt in points.dropFirst() { 
                path.addLine(to: pt) 
            }
        }
        .stroke(Color.blue, lineWidth: 2)
    }
    
    private func chartBackground(points: [CGPoint], geometry: GeometryProxy) -> some View {
        Path { path in
            path.move(to: points.first ?? .zero)
            for pt in points.dropFirst() { 
                path.addLine(to: pt) 
            }
            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
            path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
            path.closeSubpath()
        }
        .fill(Color.blue.opacity(0.08))
    }
}

#Preview {
    MainTabView()
} 