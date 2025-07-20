//
//  ThemeSelectionView.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI

struct ThemeSelectionView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Theme Mode Selection
                Section("Görünüm Modu") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Image(systemName: theme.systemImage)
                                .foregroundColor(themeManager.primaryColor)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(theme.displayName)
                                    .font(.headline)
                                
                                Text(themeDescription(for: theme))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.primaryColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hapticManager.selectionChanged()
                            themeManager.setTheme(theme)
                        }
                    }
                }
                
                // Color Scheme Selection
                Section("Renk Teması") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(AppColorScheme.allCases, id: \.self) { colorScheme in
                            ColorSchemeButton(
                                colorScheme: colorScheme,
                                isSelected: themeManager.currentColorScheme == colorScheme
                            ) {
                                hapticManager.selectionChanged()
                                themeManager.setColorScheme(colorScheme)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Preview Section
                Section("Önizleme") {
                    ThemePreviewCard()
                }
            }
            .navigationTitle("Tema Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HapticButton("Bitti") {
                        dismiss()
                    }
                }
            }
        }
        .themed()
    }
    
    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .system:
            return "Sistem ayarını takip eder"
        case .light:
            return "Her zaman açık tema"
        case .dark:
            return "Her zaman koyu tema"
        }
    }
}

struct ColorSchemeButton: View {
    let colorScheme: AppColorScheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Color Preview Circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [colorScheme.primaryColor, colorScheme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                // Color Name
                Text(colorScheme.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ThemePreviewCard: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MoneyMate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Text("Tema Önizleme")
                        .font(.caption)
                        .foregroundColor(theme.textSecondaryColor)
                }
                
                Spacer()
                
                Circle()
                    .fill(theme.primaryGradient)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "dollarsign")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
            }
            
            // Sample Currency Row
            HStack {
                Text("🇺🇸")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("USD")
                        .font(.headline)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Text("US Dollar")
                        .font(.caption)
                        .foregroundColor(theme.textSecondaryColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("32.45")
                        .font(.headline)
                        .foregroundColor(theme.textPrimaryColor)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                        
                        Text("1.2%")
                            .font(.caption)
                    }
                    .foregroundColor(theme.upColor)
                }
                
                // Sample Action Button
                Button(action: {}) {
                    Image(systemName: "star")
                        .font(.callout)
                        .foregroundColor(theme.primaryColor)
                }
            }
            .padding(.horizontal, 4)
            
            // Sample Stats
            HStack(spacing: 12) {
                ForEach(["Yükselişte", "Düşüşte", "Toplam"], id: \.self) { title in
                    VStack(spacing: 4) {
                        Text("12")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(theme.primaryColor)
                        
                        Text(title)
                            .font(.caption)
                            .foregroundColor(theme.textSecondaryColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(theme.surfaceColor)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Quick Theme Toggle

struct QuickThemeToggle: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    
    var body: some View {
        HapticButton(hapticType: .toggle) {
            themeManager.toggleDarkMode()
        } content: {
            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.title3)
                .foregroundColor(themeManager.primaryColor)
                .scaleEffect(themeManager.isDarkMode ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: themeManager.isDarkMode)
        }
    }
}

#Preview {
    ThemeSelectionView()
}