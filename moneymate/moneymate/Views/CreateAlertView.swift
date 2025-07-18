//
//  CreateAlertView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct CreateAlertView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @EnvironmentObject var alertService: PriceAlertService
    @StateObject private var notificationManager = NotificationManager()
    
    let currency: Currency
    
    @State private var selectedAlertType: PriceAlert.AlertType = .above
    @State private var targetPrice: String = ""
    @State private var customTitle: String = ""
    @State private var customMessage: String = ""
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Currency Info
                    currencyInfoSection
                    
                    // Alert Type Picker
                    alertTypeSection
                    
                    // Target Price Input
                    targetPriceSection
                    
                    // Custom Messages (Optional)
                    customMessageSection
                    
                    // Create Button
                    createButtonSection
                    
                    // Bottom spacing
                    Color.clear
                        .frame(height: 50)
                }
                .padding()
            }
            .background(theme.backgroundColor)
            .navigationTitle("Fiyat Uyarısı Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
        .background(theme.backgroundColor)
        .onAppear {
            setupInitialValues()
        }
        .alert("Bildirim İzni Gerekli", isPresented: $showingPermissionAlert) {
            Button("Ayarlara Git") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Fiyat uyarıları için bildirim iznine ihtiyacımız var.")
        }
    }
    
    private var currencyInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(currency.flag)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(currency.code)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Text(currency.name)
                        .font(.caption)
                        .foregroundColor(theme.textSecondaryColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "%.4f", currency.rate))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    HStack(spacing: 4) {
                        Image(systemName: currency.trend == "up" ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        
                        Text(String(format: "%.2f%%", abs(currency.change24h)))
                            .font(.caption)
                    }
                    .foregroundColor(currency.trend == "up" ? theme.upColor : theme.downColor)
                }
            }
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)
        }
    }
    
    private var alertTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Uyarı Türü")
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(PriceAlert.AlertType.allCases, id: \.self) { alertType in
                    Button {
                        selectedAlertType = alertType
                        updateTargetPriceForType()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: alertType.systemImage)
                                .font(.title2)
                                .foregroundColor(selectedAlertType == alertType ? .white : theme.primaryColor)
                            
                            Text(alertType.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedAlertType == alertType ? .white : theme.textPrimaryColor)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedAlertType == alertType ? 
                            theme.primaryColor : theme.cardColor
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var targetPriceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(targetPriceLabel)
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            TextField(targetPricePlaceholder, text: $targetPrice)
                .keyboardType(.decimalPad)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(theme.cardColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
                .multilineTextAlignment(.center)
        }
    }
    
    private var customMessageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Özel Mesaj (İsteğe Bağlı)")
                .font(.headline)
                .foregroundColor(theme.textSecondaryColor)
            
            VStack(spacing: 8) {
                TextField("Başlık", text: $customTitle)
                    .padding()
                    .background(theme.cardColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.borderColor, lineWidth: 1)
                    )
                
                TextField("Mesaj", text: $customMessage, axis: .vertical)
                    .padding()
                    .background(theme.cardColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.borderColor, lineWidth: 1)
                    )
                    .lineLimit(3)
            }
        }
    }
    
    private var createButtonSection: some View {
        Button {
            createAlert()
        } label: {
            HStack {
                Image(systemName: "bell")
                Text("Uyarı Oluştur")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isFormValid ? 
                theme.primaryColor : 
                theme.textSecondaryColor
            )
            .cornerRadius(12)
        }
        .disabled(!isFormValid)
    }
    
    private var isFormValid: Bool {
        !targetPrice.isEmpty && Double(targetPrice) != nil
    }
    
    private var targetPriceLabel: String {
        switch selectedAlertType {
        case .above: return "Hedef Fiyat (Üstü)"
        case .below: return "Hedef Fiyat (Altı)"
        case .change: return "Değişim Yüzdesi (%)"
        }
    }
    
    private var targetPricePlaceholder: String {
        switch selectedAlertType {
        case .above: return String(format: "%.4f", currency.rate * 1.05)
        case .below: return String(format: "%.4f", currency.rate * 0.95)
        case .change: return "5.0"
        }
    }
    
    private func setupInitialValues() {
        updateTargetPriceForType()
    }
    
    private func updateTargetPriceForType() {
        switch selectedAlertType {
        case .above:
            targetPrice = String(format: "%.4f", currency.rate * 1.05)
        case .below:
            targetPrice = String(format: "%.4f", currency.rate * 0.95)
        case .change:
            targetPrice = "5.0"
        }
    }
    
    private func createAlert() {
        guard let price = Double(targetPrice) else { return }
        
        if !notificationManager.hasPermission {
            notificationManager.requestPermission()
            showingPermissionAlert = true
            return
        }
        
        alertService.createAlert(
            currencyCode: currency.code,
            targetPrice: price,
            alertType: selectedAlertType,
            title: customTitle.isEmpty ? nil : customTitle,
            message: customMessage.isEmpty ? nil : customMessage
        )
        
        dismiss()
    }
}

#Preview {
    CreateAlertView(currency: Currency.mockCurrencies[0])
        .environmentObject(PriceAlertService(modelContext: ModelContext.sample))
}