//
//  PremiumPaywallView.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI

struct PremiumPaywallView: View {
    @StateObject private var premiumService = PremiumService.shared
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    
    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var currentTestimonial = 0
    
    let testimonials = [
        Testimonial(
            text: "Gelişmiş grafikler sayesinde döviz piyasasını çok daha iyi anlıyorum. Yatırım kararlarım artık daha bilinçli.",
            author: "Ahmet K."
        ),
        Testimonial(
            text: "Sınırsız uyarılar ile hiçbir fırsatı kaçırmıyorum. MoneyMate Premium gerçekten işimi kolaylaştırdı.",
            author: "Zeynep M."
        ),
        Testimonial(
            text: "Teknik analiz araçları ile kripto yatırımlarımda çok başarılı sonuçlar aldım. Kesinlikle tavsiye ederim.",
            author: "Can S."
        )
    ]
    
    enum PremiumPlan: CaseIterable {
        case monthly
        case yearly
        
        var title: String {
            switch self {
            case .monthly: return "AYLIK"
            case .yearly: return "YILLIK"
            }
        }
        
        var price: String {
            switch self {
            case .monthly: return "₺49,99"
            case .yearly: return "₺399,99"
            }
        }
        
        var monthlyPrice: String {
            switch self {
            case .monthly: return "₺49,99 / ay"
            case .yearly: return "₺33,33 / ay"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "EN POPÜLER"
            }
        }
        
        var discount: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "₺199,89 tasarruf · 7 gün ücretsiz"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with close button
                        headerView
                        
                        // Main content
                        VStack(spacing: 32) {
                            // Hero section
                            heroSection
                            
                            // Pricing cards
                            pricingSection
                            
                            // Testimonials
                            testimonialsSection
                            
                            // CTA Button
                            ctaSection
                            
                            // Footer
                            footerSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Hata", isPresented: $showingError) {
            Button("Tamam") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            startTestimonialTimer()
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            Button {
                hapticManager.buttonPressed()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Icon and title
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                
                Text("Döviz analizinde\nyeni seviyeye çıkın")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
            }
            
            // Key benefits
            VStack(spacing: 16) {
                BenefitRow(
                    icon: "chart.bar.xaxis",
                    title: "Gelişmiş Grafikler",
                    description: "1 yıllık veriye erişim"
                )
                
                BenefitRow(
                    icon: "bell.badge",
                    title: "Sınırsız Uyarılar",
                    description: "Hiçbir fırsatı kaçırmayın"
                )
                
                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Teknik Analiz",
                    description: "Professional araçlar"
                )
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(PremiumPlan.allCases, id: \.self) { plan in
                    PlanCard(
                        plan: plan,
                        isSelected: selectedPlan == plan
                    ) {
                        hapticManager.selectionChanged()
                        selectedPlan = plan
                    }
                }
            }
        }
    }
    
    private var testimonialsSection: some View {
        VStack(spacing: 16) {
            // Testimonial content
            VStack(spacing: 12) {
                Image(systemName: "quote.bubble.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(testimonials[currentTestimonial].text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                
                Text(testimonials[currentTestimonial].author)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            // Dots indicator
            HStack(spacing: 8) {
                ForEach(0..<testimonials.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTestimonial ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    private var ctaSection: some View {
        VStack(spacing: 16) {
            Button {
                hapticManager.buttonPressed()
                Task {
                    await purchaseSelectedPlan()
                }
            } label: {
                HStack {
                    if premiumService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("7 gün ücretsiz dene")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(premiumService.isLoading)
            
            VStack(spacing: 4) {
                Text("7 gün ücretsiz deneme sonrası \(selectedPlan.price) (\(selectedPlan.monthlyPrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Taahhüt yok. İstediğiniz zaman iptal edebilirsiniz.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Button("Satın alımları geri yükle") {
                hapticManager.buttonPressed()
                Task {
                    await restorePurchases()
                }
            }
            .foregroundColor(.blue)
            
            Button("Tüm planları gör") {
                // Show all plans
            }
            .foregroundColor(.blue)
            .underline()
            
            HStack(spacing: 16) {
                Link("Şartlar", destination: URL(string: "https://moneymate.app/terms")!)
                Text("•")
                Link("Gizlilik", destination: URL(string: "https://moneymate.app/privacy")!)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    private func startTestimonialTimer() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTestimonial = (currentTestimonial + 1) % testimonials.count
            }
        }
    }
    
    private func purchaseSelectedPlan() async {
        do {
            switch selectedPlan {
            case .monthly:
                try await premiumService.purchaseMonthlySubscription()
            case .yearly:
                try await premiumService.purchaseYearlySubscription()
            }
            hapticManager.actionSuccess()
            dismiss()
        } catch {
            hapticManager.actionError()
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func restorePurchases() async {
        do {
            try await premiumService.restorePurchases()
            hapticManager.actionSuccess()
            dismiss()
        } catch {
            hapticManager.actionError()
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: PremiumPaywallView.PremiumPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Badge
                ZStack {
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(12)
                    } else {
                        Spacer()
                            .frame(height: 20)
                    }
                }
                
                // Plan title
                Text(plan.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                // Price
                Text(plan.price)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                // Monthly price
                Text(plan.monthlyPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Discount info
                if let discount = plan.discount {
                    Text(discount)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Testimonial {
    let text: String
    let author: String
}

#Preview {
    PremiumPaywallView()
}