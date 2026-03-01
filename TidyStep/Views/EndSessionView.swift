//
//  EndSessionView.swift
//  TidyStep
//

import SwiftUI

struct EndSessionView: View {
    let session: CleaningSession
    let onDismiss: () -> Void

    @EnvironmentObject var appLanguage: AppLanguage
    @State private var shareItem: ShareItem?

    var body: some View {
        ZStack {
            Color(hex: 0x0D0D0F)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(hex: 0x38BDF8))

                Text(appLanguage.string("end_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                VStack(spacing: 16) {
                    Row(label: appLanguage.string("session_duration"), value: formatDuration(session.durationSeconds))
                    Row(label: appLanguage.string("session_steps"), value: "\(session.steps)")
                    Row(label: appLanguage.string("end_calories"), value: String(format: "%.0f", session.estimatedCalories))
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(hex: 0x1A1A1E))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    Button {
                        let template = appLanguage.string("share_session_with_date")
                        let formatter = DateFormatter()
                        formatter.dateFormat = "M/d"
                        formatter.locale = Locale(identifier: appLanguage.resolvedLanguage == "zh-Hans" ? "zh_Hans" : "en_US")
                        let dateStr = formatter.string(from: session.endDate)
                        let text = String(format: template, dateStr, session.steps, session.estimatedCalories)
                        shareItem = ShareItem(text: text)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(Color(hex: 0x5EEAD4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: 0x1A1A1E))
                            .clipShape(Capsule())
                    }
                    Button {
                        onDismiss()
                    } label: {
                        Text(appLanguage.string("end_done"))
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: 0x5EEAD4))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .sheet(item: $shareItem) { item in
            let text = item.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "TidyStep"
                : item.text
            ShareSheet(items: [text])
        }
        .interactiveDismissDisabled()
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%d %@ %02d %@", m, appLanguage.string("time_min"), s, appLanguage.string("time_sec"))
    }
}

private struct Row: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}
