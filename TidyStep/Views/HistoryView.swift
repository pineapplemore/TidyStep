//
//  HistoryView.swift
//  TidyStep
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                if storage.sessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(Color(hex: 0x6B7280))
                        Text(appLanguage.string("history_empty"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(storage.sessions) { session in
                            HistoryRow(session: session)
                                .listRowBackground(Color(hex: 0x1A1A1E))
                                .listRowSeparatorTint(Color(hex: 0x2D2D32))
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(appLanguage.string("tab_history"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appLanguage.toggleLanguage()
                    } label: {
                        Image(systemName: "globe")
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                }
            }
        }
    }
}

private struct HistoryRow: View {
    let session: CleaningSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDate(session.endDate))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            HStack {
                Label("\(session.steps)", systemImage: "figure.walk")
                Spacer()
                Text(String(format: "%.0f kcal", session.estimatedCalories))
                Spacer()
                Text(formatDuration(session.durationSeconds))
            }
            .font(.caption)
            .foregroundStyle(Color(hex: 0x9CA3AF))
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let m = Int(sec) / 60
        return "\(m) min"
    }
}
