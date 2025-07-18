//
//  ThemeManager.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system
    @Published var currentColorScheme: AppColorScheme = .blue
    @Published var isDarkMode: Bool = false
    
    private init() {
        loadThemeSettings()
        updateSystemTheme()
    }
    
    // MARK: - Theme Management
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        updateSystemTheme()
        saveThemeSettings()
    }
    
    func setColorScheme(_ colorScheme: AppColorScheme) {
        currentColorScheme = colorScheme
        saveThemeSettings()
    }
    
    func toggleDarkMode() {
        if currentTheme == .system {
            currentTheme = isDarkMode ? .light : .dark
        } else {
            currentTheme = currentTheme == .dark ? .light : .dark
        }
        updateSystemTheme()
        saveThemeSettings()
    }
    
    private func updateSystemTheme() {
        switch currentTheme {
        case .system:
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        }
    }
    
    // MARK: - Color Accessors
    
    var primaryColor: Color {
        currentColorScheme.primaryColor
    }
    
    var secondaryColor: Color {
        currentColorScheme.secondaryColor
    }
    
    var accentColor: Color {
        currentColorScheme.accentColor
    }
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemBackground) : Color(.systemBackground)
    }
    
    var surfaceColor: Color {
        isDarkMode ? Color(.systemGray6) : Color(.systemGray5)
    }
    
    var cardColor: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textPrimaryColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    var textSecondaryColor: Color {
        isDarkMode ? Color(.systemGray) : Color(.systemGray2)
    }
    
    var borderColor: Color {
        isDarkMode ? Color(.systemGray4) : Color(.systemGray5)
    }
    
    var upColor: Color {
        isDarkMode ? Color.green : Color.green
    }
    
    var downColor: Color {
        isDarkMode ? Color.red : Color.red
    }
    
    var warningColor: Color {
        isDarkMode ? Color.orange : Color.orange
    }
    
    // MARK: - Gradient Accessors
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardColor, cardColor.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Persistence
    
    private func saveThemeSettings() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
        UserDefaults.standard.set(currentColorScheme.rawValue, forKey: "AppColorScheme")
    }
    
    private func loadThemeSettings() {
        if let themeRawValue = UserDefaults.standard.string(forKey: "AppTheme"),
           let theme = AppTheme(rawValue: themeRawValue) {
            currentTheme = theme
        }
        
        if let colorSchemeRawValue = UserDefaults.standard.string(forKey: "AppColorScheme"),
           let colorScheme = AppColorScheme(rawValue: colorSchemeRawValue) {
            currentColorScheme = colorScheme
        }
    }
}

// MARK: - Theme Models

enum AppTheme: String, CaseIterable {
    case system = "Sistem"
    case light = "Açık"
    case dark = "Koyu"
    
    var displayName: String {
        return rawValue
    }
    
    var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

enum AppColorScheme: String, CaseIterable {
    case blue = "Mavi"
    case green = "Yeşil"
    case orange = "Turuncu"
    case purple = "Mor"
    case red = "Kırmızı"
    case teal = "Deniz Mavisi"
    case pink = "Pembe"
    case indigo = "Çivit Mavisi"
    
    var displayName: String {
        return rawValue
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        case .pink: return .pink
        case .indigo: return .indigo
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .blue: return .cyan
        case .green: return .mint
        case .orange: return .yellow
        case .purple: return .pink
        case .red: return .orange
        case .teal: return .blue
        case .pink: return .purple
        case .indigo: return .blue
        }
    }
    
    var accentColor: Color {
        return primaryColor
    }
    
    var colorPreview: Color {
        return primaryColor
    }
}

// MARK: - Theme Environment

struct ThemeEnvironment: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeEnvironment.self] }
        set { self[ThemeEnvironment.self] = newValue }
    }
}

// MARK: - Theme Modifier

struct ThemedModifier: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.theme, themeManager)
            .preferredColorScheme(themeManager.currentTheme == .system ? nil : 
                                (themeManager.currentTheme == .dark ? .dark : .light))
            .accentColor(themeManager.primaryColor)
    }
}

extension View {
    func themed() -> some View {
        modifier(ThemedModifier())
    }
}