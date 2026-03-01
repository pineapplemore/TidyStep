//
//  TidyStepApp.swift
//  TidyStep
//
//  Entry point. Dark theme, locale-based language.
//

import SwiftUI

@main
struct TidyStepApp: App {
    @StateObject private var storage = StorageManager.shared
    @StateObject private var appLanguage = AppLanguage.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .environmentObject(storage)
                .environmentObject(appLanguage)
                .overlay {
                    if !hasSeenOnboarding {
                        OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    }
                }
        }
    }
}
