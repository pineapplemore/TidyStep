//
//  AppLanguage.swift
//  TidyStep
//
//  In-app language override. Globe button toggles between en and zh-Hans.
//

import Foundation
import SwiftUI

final class AppLanguage: ObservableObject {
    static let shared = AppLanguage()

    private let key = "app_language"
    private let supported = ["en", "zh-Hans"]

    /// Current override: "en", "zh-Hans", or nil to follow system.
    @Published var currentLanguage: String? {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: key)
        }
    }

    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: key)
        if let lang = currentLanguage, !supported.contains(lang) {
            currentLanguage = nil
        }
    }

    /// Toggle between English and 简体中文.
    func toggleLanguage() {
        let next: String
        if currentLanguage == "zh-Hans" {
            next = "en"
        } else {
            next = "zh-Hans"
        }
        currentLanguage = next
    }

    /// Localized string for key; uses current override or system locale.
    func string(_ key: String) -> String {
        let lang = currentLanguage ?? preferredSystemLanguage()
        if let lang = lang,
           let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: key, table: "Localizable")
        }
        return Bundle.main.localizedString(forKey: key, value: key, table: "Localizable")
    }

    private func preferredSystemLanguage() -> String? {
        let code = Locale.preferredLanguages.first ?? Locale.current.identifier
        if code.hasPrefix("zh") { return "zh-Hans" }
        return "en"
    }
}
