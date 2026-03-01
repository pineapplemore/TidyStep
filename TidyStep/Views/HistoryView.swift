//
//  HistoryView.swift
//  TidyStep
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage
    @EnvironmentObject var subscription: SubscriptionManager
    @State private var showPaywall = false

    /// 非订阅时只显示最新一条；订阅时显示全部。
    private var displayedSessions: [CleaningSession] {
        if subscription.isSubscribed {
            return storage.sessions
        }
        return Array(storage.sessions.prefix(1))
    }

    /// 未订阅且存在多条记录时，提示用户订阅可查看全部
    private var showSubscribeHint: Bool {
        !subscription.isSubscribed && storage.sessions.count > 1
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                if displayedSessions.isEmpty {
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
                        ForEach(displayedSessions) { session in
                            HistoryRow(session: session)
                                .listRowBackground(Color(hex: 0x1A1A1E))
                                .listRowSeparatorTint(Color(hex: 0x2D2D32))
                        }
                        if showSubscribeHint {
                            Section {
                                VStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.circle.fill")
                                            .foregroundStyle(Color(hex: 0x5EEAD4))
                                        Text(appLanguage.string("history_subscribe_to_unlock"))
                                            .font(.subheadline)
                                            .foregroundStyle(Color(hex: 0x9CA3AF))
                                            .multilineTextAlignment(.center)
                                    }
                                    Button {
                                        showPaywall = true
                                    } label: {
                                        Text(appLanguage.string("paywall_unlock"))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(hex: 0x5EEAD4))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 8)
                                .listRowBackground(Color(hex: 0x1A1A1E))
                            }
                        } else if !subscription.isSubscribed && !storage.sessions.isEmpty {
                            Section {
                                Text(appLanguage.string("history_subscribe_hint"))
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: 0x6B7280))
                                    .listRowBackground(Color(hex: 0x1A1A1E))
                            }
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
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
                    .environmentObject(subscription)
                    .environmentObject(appLanguage)
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
