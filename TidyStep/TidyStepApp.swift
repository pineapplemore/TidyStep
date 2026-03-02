//
//  TidyStepApp.swift
//  TidyStep
//
//  Entry point. Dark theme, locale-based language.
//

import SwiftUI
import UIKit

@main
struct TidyStepApp: App {
    @StateObject private var storage = StorageManager.shared
    @StateObject private var appLanguage = AppLanguage.shared
    @StateObject private var subscription = SubscriptionManager.shared
    @AppStorage("onboarding_do_not_show_again") private var doNotShowAgain = false
    @State private var onboardingDismissedThisSession = false

    init() {
        let mint = UIColor(red: 94/255, green: 234/255, blue: 212/255, alpha: 1)
        UITabBar.appearance().tintColor = mint
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Color(hex: 0x5EEAD4))
                .preferredColorScheme(.dark)
                .environmentObject(storage)
                .environmentObject(appLanguage)
                .environmentObject(subscription)
                .overlay {
                    if !doNotShowAgain && !onboardingDismissedThisSession {
                        OnboardingView(dismissedThisSession: $onboardingDismissedThisSession)
                            .environmentObject(appLanguage)
                    }
                }
        }
    }
}
