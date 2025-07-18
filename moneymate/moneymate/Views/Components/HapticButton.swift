//
//  HapticButton.swift
//  MoneyMate
//
//  Created by pc on 17.07.2025.
//

import SwiftUI

struct HapticButton<Content: View>: View {
    let hapticType: HapticFeedbackManager.HapticType
    let action: () -> Void
    let content: () -> Content
    
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    
    init(
        hapticType: HapticFeedbackManager.HapticType = .buttonTap,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hapticType = hapticType
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: {
            hapticManager.trigger(hapticType)
            action()
        }) {
            content()
        }
    }
}

// MARK: - Convenience Initializers

extension HapticButton where Content == Text {
    init(
        _ title: String,
        hapticType: HapticFeedbackManager.HapticType = .buttonTap,
        action: @escaping () -> Void
    ) {
        self.hapticType = hapticType
        self.action = action
        self.content = { Text(title) }
    }
}

extension HapticButton where Content == Label<Text, Image> {
    init(
        _ title: String,
        systemImage: String,
        hapticType: HapticFeedbackManager.HapticType = .buttonTap,
        action: @escaping () -> Void
    ) {
        self.hapticType = hapticType
        self.action = action
        self.content = { Label(title, systemImage: systemImage) }
    }
}

extension HapticButton where Content == Image {
    init(
        systemName: String,
        hapticType: HapticFeedbackManager.HapticType = .buttonTap,
        action: @escaping () -> Void
    ) {
        self.hapticType = hapticType
        self.action = action
        self.content = { Image(systemName: systemName) }
    }
}

// MARK: - Haptic Toggle

struct HapticToggle: View {
    @Binding var isOn: Bool
    let label: String
    let hapticType: HapticFeedbackManager.HapticType
    
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    
    init(
        _ label: String,
        isOn: Binding<Bool>,
        hapticType: HapticFeedbackManager.HapticType = .toggle
    ) {
        self.label = label
        self._isOn = isOn
        self.hapticType = hapticType
    }
    
    var body: some View {
        Toggle(label, isOn: Binding(
            get: { isOn },
            set: { newValue in
                hapticManager.trigger(hapticType)
                isOn = newValue
            }
        ))
    }
}

// MARK: - Haptic Picker

struct HapticPicker<SelectionValue: Hashable, Content: View>: View {
    let selection: Binding<SelectionValue>
    let content: () -> Content
    
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    
    init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.content = content
    }
    
    var body: some View {
        Picker("", selection: Binding(
            get: { selection.wrappedValue },
            set: { newValue in
                hapticManager.trigger(.selection)
                selection.wrappedValue = newValue
            }
        )) {
            content()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HapticButton("Tap Me") {
            print("Button tapped!")
        }
        .buttonStyle(.borderedProminent)
        
        HapticButton("Success", hapticType: .success) {
            print("Success button!")
        }
        .buttonStyle(.bordered)
        
        HapticButton("Error", hapticType: .error) {
            print("Error button!")
        }
        .buttonStyle(.bordered)
        
        HapticButton(systemName: "heart.fill", hapticType: .favoriteToggle) {
            print("Favorite toggled!")
        }
        .font(.title)
        .foregroundColor(.red)
        
        HapticToggle("Enable Notifications", isOn: .constant(true))
        
        HapticPicker(selection: .constant("Option 1")) {
            Text("Option 1").tag("Option 1")
            Text("Option 2").tag("Option 2")
            Text("Option 3").tag("Option 3")
        }
        .pickerStyle(.segmented)
    }
    .padding()
}