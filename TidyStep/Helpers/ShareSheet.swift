//
//  ShareSheet.swift
//  TidyStep
//
//  Presents system share sheet (iOS 15 compatible).
//  分享面板前的方形「A」图标是系统对纯文本的默认预览，无法改为自定义图标（除非同时分享图片）。
//

import SwiftUI
import UIKit

/// Carries share text so sheet(item:) gets the correct content when presented (avoids empty text from state timing).
struct ShareItem: Identifiable {
    let id = UUID()
    let text: String
}

/// 自定义分享源：提供完整文本，并可为邮件设置主题（如 TidyStep），分享内容不会被截断。
final class TextActivityItemSource: NSObject, UIActivityItemSource {
    private let text: String
    private let subject: String

    init(text: String, subject: String = "TidyStep") {
        self.text = text
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        text
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        text
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        subject
    }
}

/// Builds share text for "this week": header + one line per session (date – steps, cal). Never returns empty.
func buildWeeklyShareText(sessions: [CleaningSession], appLanguage: AppLanguage) -> String {
    let header = appLanguage.string("share_stats_week_header")
    let lineTemplate = appLanguage.string("share_stats_line")
    let emptyMsg = appLanguage.string("share_stats_empty")
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d"
    formatter.locale = Locale(identifier: appLanguage.resolvedLanguage == "zh-Hans" ? "zh_Hans" : "en_US")

    let sorted = sessions.sorted { $0.endDate < $1.endDate }
    if sorted.isEmpty {
        return header + " " + emptyMsg
    }
    let lines = sorted.map { (s: CleaningSession) -> String in
        let dateStr = formatter.string(from: s.endDate)
        return String(format: lineTemplate, dateStr, s.steps, s.estimatedCalories)
    }
    return header + "\n" + lines.joined(separator: "\n")
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let safeItems: [Any] = {
            if items.isEmpty { return ["TidyStep"] }
            if let first = items.first as? String {
                let trimmed = first.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { return ["TidyStep"] }
                return [trimmed]
            }
            return items
        }()
        let vc = UIActivityViewController(activityItems: safeItems, applicationActivities: nil)
        // iPad: provide source for popover to avoid crash
        if let popover = vc.popoverPresentationController {
            let scenes = UIApplication.shared.connectedScenes
            let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
            if let windowScene = windowScenes.first,
               let window = windowScene.windows.first(where: { (w: UIWindow) -> Bool in w.isKeyWindow }),
               let rootView = window.rootViewController?.view {
                popover.sourceView = rootView
                popover.sourceRect = CGRect(x: rootView.bounds.midX, y: rootView.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
