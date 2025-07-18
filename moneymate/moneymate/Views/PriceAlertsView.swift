//
//  PriceAlertsView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

struct PriceAlertsView: View {
    @EnvironmentObject var alertService: PriceAlertService
    @Environment(\.theme) private var theme
    @State private var selectedTab: AlertTab = .active
    
    enum AlertTab: String, CaseIterable {
        case active = "Aktif"
        case triggered = "Tetiklenen"
        
        var systemImage: String {
            switch self {
            case .active: return "bell"
            case .triggered: return "bell.badge"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector
                
                // Content
                TabView(selection: $selectedTab) {
                    activeAlertsView
                        .tag(AlertTab.active)
                    
                    triggeredAlertsView
                        .tag(AlertTab.triggered)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(theme.backgroundColor)
            .navigationTitle("Fiyat Uyarıları")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .triggered && !alertService.getTriggeredAlerts().isEmpty {
                        Button("Temizle") {
                            alertService.clearTriggeredAlerts()
                        }
                        .foregroundColor(theme.downColor)
                    }
                }
            }
        }
        .onAppear {
            alertService.loadAlerts()
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(AlertTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.systemImage)
                            .font(.callout)
                        
                        Text(tab.rawValue)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        if tab == .active {
                            let activeCount = alertService.getActiveAlerts().count
                            if activeCount > 0 {
                                Text("\(activeCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.primaryColor)
                                    .clipShape(Capsule())
                            }
                        } else {
                            let triggeredCount = alertService.getTriggeredAlerts().count
                            if triggeredCount > 0 {
                                Text("\(triggeredCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.downColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .foregroundColor(selectedTab == tab ? theme.primaryColor : theme.textSecondaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab ? 
                        theme.primaryColor.opacity(0.1) : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(theme.surfaceColor)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var activeAlertsView: some View {
        let activeAlerts = alertService.getActiveAlerts()
        
        return Group {
            if activeAlerts.isEmpty {
                emptyActiveAlertsView
            } else {
                List {
                    ForEach(activeAlerts, id: \.id) { alert in
                        AlertRowView(alert: alert, isActive: true)
                            .environmentObject(alertService)
                            .listRowBackground(theme.backgroundColor)
                    }
                    .onDelete(perform: deleteActiveAlerts)
                }
                .listStyle(PlainListStyle())
                .background(theme.backgroundColor)
                .refreshable {
                    alertService.loadAlerts()
                }
            }
        }
    }
    
    private var triggeredAlertsView: some View {
        let triggeredAlerts = alertService.getTriggeredAlerts()
        
        return Group {
            if triggeredAlerts.isEmpty {
                emptyTriggeredAlertsView
            } else {
                List {
                    ForEach(triggeredAlerts, id: \.id) { alert in
                        AlertRowView(alert: alert, isActive: false)
                            .environmentObject(alertService)
                            .listRowBackground(theme.backgroundColor)
                    }
                    .onDelete(perform: deleteTriggeredAlerts)
                }
                .listStyle(PlainListStyle())
                .background(theme.backgroundColor)
                .refreshable {
                    alertService.loadAlerts()
                }
            }
        }
    }
    
    private var emptyActiveAlertsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(theme.textSecondaryColor)
            
            VStack(spacing: 8) {
                Text("Aktif Uyarı Yok")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimaryColor)
                
                Text("Döviz kurları için fiyat uyarıları oluşturun")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondaryColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundColor)
    }
    
    private var emptyTriggeredAlertsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(theme.upColor)
            
            VStack(spacing: 8) {
                Text("Tetiklenen Uyarı Yok")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimaryColor)
                
                Text("Tetiklenen uyarılar burada görünecek")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondaryColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundColor)
    }
    
    // MARK: - Helper Functions
    
    private func deleteActiveAlerts(at offsets: IndexSet) {
        let activeAlerts = alertService.getActiveAlerts()
        for index in offsets {
            if index < activeAlerts.count {
                alertService.deleteAlert(activeAlerts[index])
            }
        }
    }
    
    private func deleteTriggeredAlerts(at offsets: IndexSet) {
        let triggeredAlerts = alertService.getTriggeredAlerts()
        for index in offsets {
            if index < triggeredAlerts.count {
                alertService.deleteAlert(triggeredAlerts[index])
            }
        }
    }
}

struct AlertRowView: View {
    let alert: PriceAlert
    let isActive: Bool
    @EnvironmentObject var alertService: PriceAlertService
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Type Icon
            Image(systemName: alert.alertType.systemImage)
                .font(.title2)
                .foregroundColor(isActive ? theme.primaryColor : theme.textSecondaryColor)
                .frame(width: 30, height: 30)
            
            // Alert Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.currencyCode)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Text(alert.alertType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.surfaceColor)
                        .cornerRadius(8)
                        .foregroundColor(theme.textSecondaryColor)
                }
                
                Text(targetPriceText)
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondaryColor)
                
                if let triggeredAt = alert.triggeredAt {
                    Text("Tetiklendi: \(triggeredAt, style: .relative)")
                        .font(.caption)
                        .foregroundColor(theme.upColor)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                if isActive {
                    Button {
                        alertService.toggleAlert(alert)
                    } label: {
                        Image(systemName: "pause.circle")
                            .font(.title3)
                            .foregroundColor(theme.warningColor)
                    }
                }
                
                Button {
                    alertService.deleteAlert(alert)
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(theme.downColor)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var targetPriceText: String {
        switch alert.alertType {
        case .above, .below:
            return String(format: "%.4f", alert.targetPrice)
        case .change:
            return "%\(String(format: "%.2f", alert.targetPrice))"
        }
    }
}

#Preview {
    PriceAlertsView()
        .environmentObject(PriceAlertService(modelContext: ModelContext.sample))
}