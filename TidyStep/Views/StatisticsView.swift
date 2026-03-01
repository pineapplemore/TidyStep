//
//  StatisticsView.swift
//  TidyStep
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage
    @EnvironmentObject var subscription: SubscriptionManager
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                if subscription.isSubscribed {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            statsCard(
                                title: appLanguage.string("stats_this_week"),
                                summary: storage.statsThisWeek
                            )
                            statsCard(
                                title: appLanguage.string("stats_this_month"),
                                summary: storage.statsThisMonth
                            )
                            last12MonthsBarSection
                        }
                        .padding()
                    }
                } else {
                    premiumLockView
                }
            }
            .navigationTitle(appLanguage.string("tab_statistics"))
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

    private var premiumLockView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: 0x5EEAD4))
            Text(appLanguage.string("paywall_stats_locked"))
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(appLanguage.string("paywall_stats_locked_subtitle"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
                .multilineTextAlignment(.center)
            Button {
                showPaywall = true
            } label: {
                Text(appLanguage.string("paywall_unlock"))
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: 0x5EEAD4))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statsCard(title: String, summary: StatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            HStack(spacing: 16) {
                miniStat(value: "\(summary.count)", label: appLanguage.string("stats_sessions"))
                miniStat(value: formatMin(Int(summary.totalDurationSeconds / 60)), label: appLanguage.string("session_duration"))
                miniStat(value: "\(summary.totalSteps)", label: appLanguage.string("session_steps"))
                miniStat(value: String(format: "%.0f", summary.totalCalories), label: appLanguage.string("end_calories"))
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x1A1A1E))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color(hex: 0x6B7280))
        }
        .frame(maxWidth: .infinity)
    }

    /// 近 12 个月柱状图（与记录保留 1 年一致）
    private var last12MonthsBarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appLanguage.string("stats_last_12_months"))
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            let items = storage.last12MonthsLineItems
            let maxCount = max(1, items.map(\.sessionCount).max() ?? 1)
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(items) { item in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: 0x5EEAD4))
                            .frame(height: max(4, CGFloat(item.sessionCount) / CGFloat(maxCount) * 80))
                        Text(shortMonthLabel(item.monthStart))
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(Color(hex: 0x6B7280))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(20)
            .background(Color(hex: 0x1A1A1E))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func formatMin(_ min: Int) -> String {
        if min < 60 { return "\(min)m" }
        let h = min / 60
        let m = min % 60
        return m > 0 ? "\(h)h\(m)m" : "\(h)h"
    }

    private func shortWeekLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale.current
        return f.string(from: date)
    }

    private func shortMonthLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M"
        f.locale = Locale.current
        return f.string(from: date)
    }
}
