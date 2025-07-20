//
//  HapticFeedbackManager.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import Foundation
import UIKit

class HapticFeedbackManager: ObservableObject {
    static let shared = HapticFeedbackManager()
    
    @Published var isEnabled: Bool = true
    @Published var intensityLevel: HapticIntensity = .medium
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    enum HapticType {
        case selection
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case success
        case warning
        case error
        case buttonTap
        case swipeAction
        case toggle
        case refresh
        case priceAlert
        case favoriteToggle
    }
    
    enum HapticIntensity: String, CaseIterable {
        case light = "Hafif"
        case medium = "Orta"
        case heavy = "Güçlü"
        case off = "Kapalı"
        
        var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .off: return .light
            }
        }
    }
    
    private init() {
        loadSettings()
        prepareHapticFeedback()
    }
    
    // MARK: - Public Methods
    
    func trigger(_ type: HapticType) {
        guard isEnabled && intensityLevel != .off else { return }
        
        switch type {
        case .selection:
            selectionFeedbackGenerator.selectionChanged()
            
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
            
        case .notification(let type):
            notificationFeedbackGenerator.notificationOccurred(type)
            
        case .success:
            notificationFeedbackGenerator.notificationOccurred(.success)
            
        case .warning:
            notificationFeedbackGenerator.notificationOccurred(.warning)
            
        case .error:
            notificationFeedbackGenerator.notificationOccurred(.error)
            
        case .buttonTap:
            let generator = UIImpactFeedbackGenerator(style: intensityLevel.feedbackStyle)
            generator.impactOccurred()
            
        case .swipeAction:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case .toggle:
            selectionFeedbackGenerator.selectionChanged()
            
        case .refresh:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case .priceAlert:
            notificationFeedbackGenerator.notificationOccurred(.warning)
            
        case .favoriteToggle:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func prepareHapticFeedback() {
        guard isEnabled else { return }
        
        impactFeedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
    
    // MARK: - Settings
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        saveSettings()
        
        if enabled {
            prepareHapticFeedback()
        }
    }
    
    func setIntensity(_ intensity: HapticIntensity) {
        intensityLevel = intensity
        saveSettings()
        
        if intensity != .off {
            prepareHapticFeedback()
        }
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: "HapticFeedbackEnabled")
        UserDefaults.standard.set(intensityLevel.rawValue, forKey: "HapticFeedbackIntensity")
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "HapticFeedbackEnabled")
        if UserDefaults.standard.object(forKey: "HapticFeedbackEnabled") == nil {
            isEnabled = true // Default to enabled
        }
        
        if let intensityString = UserDefaults.standard.string(forKey: "HapticFeedbackIntensity"),
           let intensity = HapticIntensity(rawValue: intensityString) {
            intensityLevel = intensity
        }
    }
    
    // MARK: - Convenience Methods
    
    func buttonPressed() {
        trigger(.buttonTap)
    }
    
    func selectionChanged() {
        trigger(.selection)
    }
    
    func actionSuccess() {
        trigger(.success)
    }
    
    func actionError() {
        trigger(.error)
    }
    
    func toggleAction() {
        trigger(.toggle)
    }
    
    func swipeAction() {
        trigger(.swipeAction)
    }
    
    func refreshAction() {
        trigger(.refresh)
    }
    
    func priceAlertTriggered() {
        trigger(.priceAlert)
    }
    
    func favoriteToggled() {
        trigger(.favoriteToggle)
    }
}