//
//  SettingsView.swift
//  TidyStep
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage
    @EnvironmentObject var subscription: SubscriptionManager
    @State private var weightText: String = ""
    @State private var showWeightSheet = false
    @State private var showPaywall = false
    @State private var reminderEnabled: Bool = true
    @State private var reminderIntervalDays: Int = 0
    @State private var reminderWeekday: Int = 1
    @State private var reminderHour: Int = 8
    @State private var reminderMinute: Int = 0
    @State private var notificationPermissionGranted: Bool? = nil

    private let reminderIntervalOptions: [(Int, String)] = [
        (0, "reminder_weekly"),
        (3, "reminder_every_3_days"),
        (5, "reminder_every_5_days"),
    ]

    private var weekdays: [(Int, String)] {
        [
            (1, appLanguage.string("weekday_sun")),
            (2, appLanguage.string("weekday_mon")),
            (3, appLanguage.string("weekday_tue")),
            (4, appLanguage.string("weekday_wed")),
            (5, appLanguage.string("weekday_thu")),
            (6, appLanguage.string("weekday_fri")),
            (7, appLanguage.string("weekday_sat")),
        ]
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                Form {
                    Section {
                        HStack {
                            Text(appLanguage.string("weight_title"))
                                .foregroundStyle(.white)
                            Spacer()
                            if let w = storage.userWeightKg {
                                Text(String(format: "%.1f kg", w))
                                    .foregroundStyle(Color(hex: 0x9CA3AF))
                            } else {
                                Text(appLanguage.string("weight_not_set"))
                                    .foregroundStyle(Color(hex: 0x6B7280))
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color(hex: 0x6B7280))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { showWeightSheet = true }
                    } header: {
                        Text(appLanguage.string("settings_weight_section"))
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                    .listRowBackground(Color(hex: 0x1A1A1E))

                    Section {
                        Toggle(isOn: $reminderEnabled) {
                            Text(appLanguage.string("reminder_enabled"))
                                .foregroundStyle(.white)
                        }
                        .tint(Color(hex: 0x5EEAD4))
                        .onChange(of: reminderEnabled) { _ in
                            applyReminder()
                        }

                        if reminderEnabled {
                            Picker(appLanguage.string("reminder_frequency"), selection: $reminderIntervalDays) {
                                ForEach(reminderIntervalOptions, id: \.0) { opt in
                                    Text(appLanguage.string(opt.1)).tag(opt.0)
                                }
                            }
                            .foregroundStyle(.white)
                            .onChange(of: reminderIntervalDays) { _ in applyReminder() }

                            if reminderIntervalDays == 0 {
                                Picker(appLanguage.string("reminder_weekday"), selection: $reminderWeekday) {
                                    ForEach(weekdays, id: \.0) { day in
                                        Text(day.1).tag(day.0)
                                    }
                                }
                                .foregroundStyle(.white)
                                .onChange(of: reminderWeekday) { _ in applyReminder() }
                            }

                            DatePicker(
                                appLanguage.string("reminder_time"),
                                selection: Binding(
                                    get: {
                                        var c = DateComponents()
                                        c.hour = reminderHour
                                        c.minute = reminderMinute
                                        return Calendar.current.date(from: c) ?? Date()
                                    },
                                    set: { d in
                                        let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                                        reminderHour = c.hour ?? 8
                                        reminderMinute = c.minute ?? 0
                                        applyReminder()
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .foregroundStyle(.white)
                        }
                    } header: {
                        Text(appLanguage.string("settings_reminder_section"))
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    } footer: {
                        if notificationPermissionGranted == false {
                            Text(appLanguage.string("reminder_permission_denied"))
                                .foregroundStyle(Color(hex: 0xEF4444))
                        }
                    }
                    .listRowBackground(Color(hex: 0x1A1A1E))

                    Section {
                        if subscription.isSubscribed {
                            HStack {
                                Text(appLanguage.string("paywall_subscribed"))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: 0x22C55E))
                            }
                            .listRowBackground(Color(hex: 0x1A1A1E))
                        }
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Text(subscription.isSubscribed ? appLanguage.string("paywall_manage") : appLanguage.string("paywall_unlock"))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: 0x6B7280))
                            }
                        }
                        .listRowBackground(Color(hex: 0x1A1A1E))
                        Button {
                            Task { await subscription.restore() }
                        } label: {
                            Text(appLanguage.string("paywall_restore"))
                                .foregroundStyle(.white)
                        }
                        .listRowBackground(Color(hex: 0x1A1A1E))
                        .disabled(subscription.isLoading)
                    } header: {
                        Text(appLanguage.string("paywall_section"))
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                    .listRowBackground(Color(hex: 0x1A1A1E))
                }
            }
            .navigationTitle(appLanguage.string("tab_settings"))
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
            .onAppear {
                reminderEnabled = storage.reminderEnabled
                reminderIntervalDays = storage.reminderIntervalDays
                reminderWeekday = storage.reminderWeekday
                reminderHour = storage.reminderHour
                reminderMinute = storage.reminderMinute
                if reminderWeekday == 0 { reminderWeekday = 1 }
                requestNotificationAndSchedule()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
                    .environmentObject(subscription)
                    .environmentObject(appLanguage)
            }
            .sheet(isPresented: $showWeightSheet) {
                WeightInputSheet(
                    initialWeight: storage.userWeightKg,
                    onSave: { kg in
                        storage.saveWeight(kg)
                        showWeightSheet = false
                    },
                    onDismiss: { showWeightSheet = false }
                )
                .environmentObject(appLanguage)
            }
        }
    }

    private func requestNotificationAndSchedule() {
        NotificationManager.shared.requestAuthorization { granted in
            notificationPermissionGranted = granted
            if granted { applyReminder() }
        }
    }

    private func applyReminder() {
        storage.saveReminder(
            enabled: reminderEnabled,
            intervalDays: reminderIntervalDays,
            weekday: reminderWeekday,
            hour: reminderHour,
            minute: reminderMinute
        )
        if reminderEnabled {
            if reminderIntervalDays == 0 {
                NotificationManager.shared.scheduleWeekly(
                    weekday: reminderWeekday,
                    hour: reminderHour,
                    minute: reminderMinute
                )
            } else {
                NotificationManager.shared.scheduleInterval(
                    days: reminderIntervalDays,
                    hour: reminderHour,
                    minute: reminderMinute
                )
            }
        } else {
            NotificationManager.shared.cancelWeekly()
        }
    }
}
