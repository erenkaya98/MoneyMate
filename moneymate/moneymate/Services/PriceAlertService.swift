//
//  PriceAlertService.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class PriceAlertService: ObservableObject {
    @Published var alerts: [PriceAlert] = []
    @Published var activeAlertsCount: Int = 0
    
    private let modelContext: ModelContext
    private var previousPrices: [String: Double] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAlerts()
    }
    
    func loadAlerts() {
        do {
            let descriptor = FetchDescriptor<PriceAlert>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            alerts = try modelContext.fetch(descriptor)
            updateActiveAlertsCount()
        } catch {
            print("Failed to load alerts: \(error)")
        }
    }
    
    func createAlert(
        currencyCode: String,
        targetPrice: Double,
        alertType: PriceAlert.AlertType,
        title: String? = nil,
        message: String? = nil
    ) {
        let alert = PriceAlert(
            currencyCode: currencyCode,
            targetPrice: targetPrice,
            alertType: alertType,
            title: title,
            message: message
        )
        
        modelContext.insert(alert)
        
        do {
            try modelContext.save()
            loadAlerts()
        } catch {
            print("Failed to save alert: \(error)")
        }
    }
    
    func deleteAlert(_ alert: PriceAlert) {
        modelContext.delete(alert)
        
        do {
            try modelContext.save()
            loadAlerts()
        } catch {
            print("Failed to delete alert: \(error)")
        }
    }
    
    func toggleAlert(_ alert: PriceAlert) {
        alert.isActive.toggle()
        
        do {
            try modelContext.save()
            loadAlerts()
        } catch {
            print("Failed to update alert: \(error)")
        }
    }
    
    func checkAlertsForCurrencies(_ currencies: [Currency]) {
        for currency in currencies {
            let previousPrice = previousPrices[currency.code] ?? currency.rate
            
            // Check all active alerts for this currency
            let currencyAlerts = alerts.filter { 
                $0.currencyCode == currency.code && $0.isActive 
            }
            
            for alert in currencyAlerts {
                if alert.checkTrigger(currentPrice: currency.rate, previousPrice: previousPrice) {
                    alert.trigger()
                }
            }
            
            // Update previous price
            previousPrices[currency.code] = currency.rate
        }
        
        // Save any triggered alerts
        do {
            try modelContext.save()
            loadAlerts()
        } catch {
            print("Failed to save triggered alerts: \(error)")
        }
    }
    
    private func updateActiveAlertsCount() {
        activeAlertsCount = alerts.filter { $0.isActive }.count
    }
    
    func getAlertsForCurrency(_ currencyCode: String) -> [PriceAlert] {
        return alerts.filter { $0.currencyCode == currencyCode }
    }
    
    func getActiveAlerts() -> [PriceAlert] {
        return alerts.filter { $0.isActive }
    }
    
    func getTriggeredAlerts() -> [PriceAlert] {
        return alerts.filter { $0.triggeredAt != nil }
    }
    
    func clearTriggeredAlerts() {
        let triggeredAlerts = getTriggeredAlerts()
        
        for alert in triggeredAlerts {
            modelContext.delete(alert)
        }
        
        do {
            try modelContext.save()
            loadAlerts()
        } catch {
            print("Failed to clear triggered alerts: \(error)")
        }
    }
}