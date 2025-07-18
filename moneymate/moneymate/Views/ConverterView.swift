//
//  ConverterView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @Environment(\.theme) private var theme
    @State private var amount = "100"
    @State private var fromCurrency: Currency?
    @State private var toCurrency: Currency?
    @State private var showingFromPicker = false
    @State private var showingToPicker = false
    
    private var convertedAmount: Double {
        guard let from = fromCurrency,
              let to = toCurrency,
              let amountValue = Double(amount) else {
            return 0.0
        }
        
        return currencyService.convertCurrency(
            amount: amountValue,
            from: from,
            to: to
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Amount Input
                    amountInputView
                    
                    // From Currency
                    currencySelectionView(
                        title: "Gönderen",
                        currency: fromCurrency,
                        action: { showingFromPicker = true }
                    )
                    
                    // Swap Button
                    swapButton
                    
                    // To Currency
                    currencySelectionView(
                        title: "Alan",
                        currency: toCurrency,
                        action: { showingToPicker = true }
                    )
                    
                    // Result
                    resultView
                    
                    // Error Message
                    if let errorMessage = currencyService.errorMessage {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(theme.warningColor)
                                
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondaryColor)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(theme.warningColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Quick Amount Buttons
                    quickAmountButtons
                    
                    // Bottom spacing for tab bar
                    Color.clear
                        .frame(height: 80)
                }
                .padding()
            }
            .onTapGesture {
                // Keyboard'u kapat
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Döviz Dönüştürücü")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupInitialCurrencies()
            }
        }
        .sheet(isPresented: $showingFromPicker) {
            CurrencyPickerView(selectedCurrency: $fromCurrency)
                .environmentObject(currencyService)
        }
        .sheet(isPresented: $showingToPicker) {
            CurrencyPickerView(selectedCurrency: $toCurrency)
                .environmentObject(currencyService)
        }
    }
    
    private var amountInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Miktar")
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(theme.cardColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .onSubmit {
                    // Keyboard'u kapat
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
    }
    
    private func currencySelectionView(
        title: String,
        currency: Currency?,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            Button(action: action) {
                HStack(spacing: 12) {
                    if let currency = currency {
                        HStack(spacing: 12) {
                            Text(currency.flag)
                                .font(.title2)
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.code)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textPrimaryColor)
                                
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondaryColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(theme.borderColor)
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Döviz Seç")
                                    .font(.headline)
                                    .foregroundColor(theme.textSecondaryColor)
                                
                                Text("Bir döviz seçin")
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondaryColor)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(theme.textSecondaryColor)
                        .font(.caption)
                }
                .padding(16)
                .frame(height: 80)
                .background(theme.cardColor)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var swapButton: some View {
        Button {
            let temp = fromCurrency
            fromCurrency = toCurrency
            toCurrency = temp
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.title2)
                .foregroundColor(theme.primaryColor)
                .padding()
                .background(theme.cardColor)
                .clipShape(Circle())
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 8) {
            Text("Sonuç")
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            if currencyService.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
            } else {
                Text(formatConvertedAmount(convertedAmount, currency: toCurrency))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimaryColor)
                    .animation(.easeInOut(duration: 0.3), value: convertedAmount)
            }
            
            if let to = toCurrency {
                Text(to.symbol)
                    .font(.title2)
                    .foregroundColor(theme.textSecondaryColor)
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(12)
    }
    
    private var quickAmountButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hızlı Miktar")
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            HStack(spacing: 12) {
                ForEach([10, 50, 100, 500, 1000], id: \.self) { value in
                    Button("\(value)") {
                        amount = String(value)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(theme.cardColor)
                    .foregroundColor(theme.textPrimaryColor)
                    .cornerRadius(8)
                    .font(.subheadline)
                }
            }
        }
    }
    
    private func setupInitialCurrencies() {
        if fromCurrency == nil && !currencyService.currencies.isEmpty {
            fromCurrency = currencyService.currencies.first { $0.code == "USD" }
        }
        if toCurrency == nil && !currencyService.currencies.isEmpty {
            toCurrency = currencyService.currencies.first { $0.code == "TRY" } ?? currencyService.currencies.first
        }
    }
    
    private func formatConvertedAmount(_ amount: Double, currency: Currency?) -> String {
        guard let currency = currency else { return "0.00" }
        
        if currency.isCryptocurrency {
            // Format crypto amounts
            if amount >= 1000 {
                return String(format: "%.0f", amount)
            } else if amount >= 1 {
                return String(format: "%.2f", amount)
            } else {
                return String(format: "%.4f", amount)
            }
        } else {
            // Format fiat amounts
            if amount >= 1000 {
                return String(format: "%.0f", amount)
            } else {
                return String(format: "%.2f", amount)
            }
        }
    }
}

struct CurrencyPickerView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @Binding var selectedCurrency: Currency?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    let title: String
    
    init(selectedCurrency: Binding<Currency?>, title: String = "Döviz Seç") {
        self._selectedCurrency = selectedCurrency
        self.title = title
    }
    
    var body: some View {
        NavigationView {
            List(currencyService.currencies, id: \.code) { currency in
                Button {
                    selectedCurrency = currency
                    dismiss()
                } label: {
                    HStack {
                        Text(currency.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(currency.code)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.textPrimaryColor)
                            
                            Text(currency.name)
                                .font(.caption)
                                .foregroundColor(theme.textSecondaryColor)
                        }
                        
                        Spacer()
                        
                        if selectedCurrency?.code == currency.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ConverterView()
        .environmentObject(CurrencyService())
}