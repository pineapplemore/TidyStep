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

    /// 用户选择的语言；nil 表示首次未选，按地区默认（中国区中文，其余英文）；一旦用户切换过则持久化，下次按选择加载。
    @Published var currentLanguage: String? {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: key)
            WidgetDataManager.setAppLanguage(resolvedLanguage)
        }
    }

    /// 首次启动按地区：中国区优先中文，其他地区优先英文。（用 countryCode，兼容 iOS 15）
    private static func regionBasedDefault() -> String {
        let code = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        return code == "CN" ? "zh-Hans" : "en"
    }

    /// 当前实际使用的语言（用户设置或按地区默认）
    var resolvedLanguage: String {
        currentLanguage ?? Self.regionBasedDefault()
    }

    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: key)
        if let lang = currentLanguage, !supported.contains(lang) {
            currentLanguage = nil
        }
        WidgetDataManager.setAppLanguage(resolvedLanguage)
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

    /// Localized string for key; uses current override or region-based default.
    func string(_ key: String) -> String {
        let lang = resolvedLanguage
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: key, table: "Localizable")
        }
        return Bundle.main.localizedString(forKey: key, value: key, table: "Localizable")
    }

    private func preferredSystemLanguage() -> String? {
        Self.regionBasedDefault()
    }
}
