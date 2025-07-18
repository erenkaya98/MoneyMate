//
//  ThemeTransition.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI

// MARK: - Theme Transition Animation

struct ThemeTransition: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var animationScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(animationScale)
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentColorScheme)
            .onChange(of: themeManager.currentTheme) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    animationScale = 0.95
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        animationScale = 1.0
                    }
                }
            }
            .onChange(of: themeManager.currentColorScheme) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    animationScale = 0.98
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        animationScale = 1.0
                    }
                }
            }
    }
}

extension View {
    func withThemeTransition() -> some View {
        modifier(ThemeTransition())
    }
}

// MARK: - Theme Color Animation

struct AnimatedThemeColor: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    let colorKeyPath: KeyPath<ThemeManager, Color>
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(themeManager[keyPath: colorKeyPath])
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentColorScheme)
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
}

extension View {
    func animatedThemeColor(_ keyPath: KeyPath<ThemeManager, Color>) -> some View {
        modifier(AnimatedThemeColor(colorKeyPath: keyPath))
    }
}

// MARK: - Theme Background Animation

struct AnimatedThemeBackground: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    let backgroundKeyPath: KeyPath<ThemeManager, Color>
    
    func body(content: Content) -> some View {
        content
            .background(themeManager[keyPath: backgroundKeyPath])
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentColorScheme)
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
}

extension View {
    func animatedThemeBackground(_ keyPath: KeyPath<ThemeManager, Color>) -> some View {
        modifier(AnimatedThemeBackground(backgroundKeyPath: keyPath))
    }
}

// MARK: - Theme Gradient Animation

struct AnimatedThemeGradient: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    let gradientKeyPath: KeyPath<ThemeManager, LinearGradient>
    
    func body(content: Content) -> some View {
        content
            .background(themeManager[keyPath: gradientKeyPath])
            .animation(.easeInOut(duration: 0.4), value: themeManager.currentColorScheme)
            .animation(.easeInOut(duration: 0.4), value: themeManager.currentTheme)
    }
}

extension View {
    func animatedThemeGradient(_ keyPath: KeyPath<ThemeManager, LinearGradient>) -> some View {
        modifier(AnimatedThemeGradient(gradientKeyPath: keyPath))
    }
}

// MARK: - Theme-aware Card

struct ThemeCard<Content: View>: View {
    let content: Content
    @Environment(\.theme) private var theme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)
            .shadow(color: theme.isDarkMode ? .clear : .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.borderColor, lineWidth: 0.5)
            )
            .withThemeTransition()
    }
}

// MARK: - Theme-aware Button

struct ThemeButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    @Environment(\.theme) private var theme
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(theme.primaryGradient)
                .cornerRadius(8)
        }
        .withThemeTransition()
    }
}

// MARK: - Theme-aware Surface

struct ThemeSurface<Content: View>: View {
    let content: Content
    @Environment(\.theme) private var theme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(theme.surfaceColor)
            .withThemeTransition()
    }
}