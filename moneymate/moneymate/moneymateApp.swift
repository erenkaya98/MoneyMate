//
//  MoneyMateApp.swift
//  MoneyMate
//
//  Created by pc on 16.07.2025.
//

import SwiftUI
import SwiftData

@main
struct MoneyMateApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Currency.self,
            PriceAlert.self,
            FavoriteCurrency.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
