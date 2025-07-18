//
//  PriceAlert.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import Foundation
import SwiftData
import UserNotifications

@Model
final class PriceAlert {
    var id: UUID
    var currencyCode: String
    var targetPrice: Double
    var alertType: AlertType
    var isActive: Bool
    var createdAt: Date
    var triggeredAt: Date?
    var title: String
    var message: String
    
    enum AlertType: String, Codable, CaseIterable {
        case above = "above"
        case below = "below"
        case change = "change" // Percentage change
        
        var displayName: String {
            switch self {
            case .above: return "Üzerine Çıkınca"
            case .below: return "Altına İninçe"
            case .change: return "Değişim %"
            }
        }
        
        var systemImage: String {
            switch self {
            case .above: return "arrow.up.circle"
            case .below: return "arrow.down.circle"
            case .change: return "percent"
            }
        }
    }
    
    init(
        currencyCode: String,
        targetPrice: Double,
        alertType: AlertType,
        title: String? = nil,
        message: String? = nil
    ) {
        self.id = UUID()
        self.currencyCode = currencyCode
        self.targetPrice = targetPrice
        self.alertType = alertType
        self.isActive = true
        self.createdAt = Date()
        self.triggeredAt = nil
        self.title = title ?? PriceAlert.generateDefaultTitle(for: currencyCode, alertType: alertType)
        self.message = message ?? PriceAlert.generateDefaultMessage(for: currencyCode, alertType: alertType, targetPrice: targetPrice)
    }
    
    private static func generateDefaultTitle(for currencyCode: String, alertType: AlertType) -> String {
        switch alertType {
        case .above:
            return "\(currencyCode) Fiyat Uyarısı"
        case .below:
            return "\(currencyCode) Düşüş Uyarısı"
        case .change:
            return "\(currencyCode) Değişim Uyarısı"
        }
    }
    
    private static func generateDefaultMessage(for currencyCode: String, alertType: AlertType, targetPrice: Double) -> String {
        switch alertType {
        case .above:
            return "\(currencyCode) \(String(format: "%.4f", targetPrice)) seviyesini aştı!"
        case .below:
            return "\(currencyCode) \(String(format: "%.4f", targetPrice)) seviyesinin altına indi!"
        case .change:
            return "\(currencyCode) %\(String(format: "%.2f", targetPrice)) değişim gösterdi!"
        }
    }
    
    func checkTrigger(currentPrice: Double, previousPrice: Double) -> Bool {
        guard isActive else { return false }
        
        switch alertType {
        case .above:
            return currentPrice >= targetPrice && previousPrice < targetPrice
        case .below:
            return currentPrice <= targetPrice && previousPrice > targetPrice
        case .change:
            let changePercent = abs(((currentPrice - previousPrice) / previousPrice) * 100)
            return changePercent >= targetPrice
        }
    }
    
    func trigger() {
        isActive = false
        triggeredAt = Date()
        sendNotification()
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.badge = 1
        
        // Custom data
        content.userInfo = [
            "alertId": id.uuidString,
            "currencyCode": currencyCode,
            "alertType": alertType.rawValue
        ]
        
        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}

// MARK: - Notification Permission Helper
class NotificationManager: ObservableObject {
    @Published var hasPermission = false
    
    init() {
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
}