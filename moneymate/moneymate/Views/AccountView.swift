//
//  AccountView.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var premiumService = PremiumService.shared
    @State private var notifications = true
    @State private var showingLanguageSelection = false
    @State private var showingThemeSelection = false
    @State private var showingPremiumPaywall = false
    @State private var selectedLanguage = "Türkçe"
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    profileSection
                }
                
                // Premium Section
                Section {
                    premiumSection
                }
                
                // Settings Section
                Section("Ayarlar") {
                    settingsSection
                }
                
                // App Section
                Section("Uygulama") {
                    appSection
                }
                
                // Support Section
                Section("Destek") {
                    supportSection
                }
                
                // About Section
                Section("Hakkında") {
                    aboutSection
                }
            }
            .navigationTitle("Hesap & Ayarlar")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingLanguageSelection) {
            LanguageSelectionView(selectedLanguage: $selectedLanguage)
        }
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
        }
        .sheet(isPresented: $showingPremiumPaywall) {
            PremiumPaywallView()
        }
    }
    
    private var profileSection: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(themeManager.primaryGradient)
                .frame(width: 60, height: 60)
                .overlay {
                    Text("M")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("MoneyMate Kullanıcısı")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Premium özellikler yakında!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var premiumSection: some View {
        Group {
            if premiumService.isPremium {
                // Premium Active
                VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Aktif")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let subscription = premiumService.subscription {
                            Text("\(subscription.subscriptionType) Plan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Yönet") {
                        hapticManager.buttonPressed()
                        // Open subscription management
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                // Premium Features Status
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(Array(PremiumService.PremiumFeature.allCases.prefix(4)), id: \.self) { feature in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text(feature.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.yellow.opacity(0.1), .orange.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        } else {
            // Premium CTA
            Button {
                hapticManager.buttonPressed()
                showingPremiumPaywall = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium'a Geçin")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Gelişmiş grafikler ve sınırsız özellikler")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.yellow.opacity(0.1), .orange.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var settingsSection: some View {
        Group {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text("Dil Ayarları")
                
                Spacer()
                
                Text(selectedLanguage)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.selectionChanged()
                showingLanguageSelection = true
            }
            
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                
                Text("Bildirimler")
                
                Spacer()
                
                HapticToggle("", isOn: $notifications)
            }
            
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
                
                Text("Dokunsal Geri Bildirim")
                
                Spacer()
                
                HapticToggle("", isOn: Binding(
                    get: { hapticManager.isEnabled },
                    set: { hapticManager.setEnabled($0) }
                ))
            }
            
            HStack {
                Image(systemName: "hand.point.up")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text("Titreşim Gücü")
                
                Spacer()
                
                HapticPicker(selection: Binding(
                    get: { hapticManager.intensityLevel },
                    set: { hapticManager.setIntensity($0) }
                )) {
                    ForEach(HapticFeedbackManager.HapticIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.rawValue).tag(intensity)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!hapticManager.isEnabled)
            }
            
            HStack {
                Image(systemName: "paintbrush")
                    .foregroundColor(themeManager.primaryColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tema")
                    
                    Text("\(themeManager.currentTheme.displayName) • \(themeManager.currentColorScheme.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Quick theme toggle
                    QuickThemeToggle()
                    
                    // Theme selection chevron
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.selectionChanged()
                showingThemeSelection = true
            }
        }
    }
    
    private var appSection: some View {
        Group {
            HStack {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
                    .frame(width: 24, height: 24)
                
                Text("Uygulamayı Değerlendir")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.buttonPressed()
                // Rate app functionality
            }
            
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text("Uygulamayı Paylaş")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.buttonPressed()
                shareApp()
            }
        }
    }
    
    private var supportSection: some View {
        Group {
            HStack {
                Image(systemName: "message")
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                
                Text("Geri Bildirim Gönder")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.buttonPressed()
                sendFeedback()
            }
            
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
                
                Text("Yardım")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hapticManager.buttonPressed()
                // Help functionality
            }
        }
    }
    
    private var aboutSection: some View {
        Group {
            HStack {
                Image(systemName: "shield")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                
                Text("Gizlilik Politikası")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Privacy policy
            }
            
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                
                Text("Kullanım Koşulları")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Terms of service
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text("Versiyon")
                
                Spacer()
                
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func shareApp() {
        let activityVC = UIActivityViewController(
            activityItems: [
                "MoneyMate: En iyi döviz kuru uygulaması! 💰",
                URL(string: "https://apps.apple.com/app/moneymate")!
            ],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func sendFeedback() {
        if let url = URL(string: "mailto:support@moneymate.app?subject=MoneyMate%20Feedback") {
            UIApplication.shared.open(url)
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    
    private let languages = ["Türkçe", "English", "Español", "Français", "Deutsch"]
    
    var body: some View {
        NavigationView {
            List(languages, id: \.self) { language in
                HStack {
                    Text(language)
                    
                    Spacer()
                    
                    if selectedLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    hapticManager.selectionChanged()
                    selectedLanguage = language
                    dismiss()
                }
            }
            .navigationTitle("Dil Seçimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HapticButton("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView()
}