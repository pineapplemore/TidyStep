//
//  RootView.swift
//  TidyStep
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appLanguage: AppLanguage
    @StateObject private var session = SessionManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StartView()
                .tabItem {
                    Label(appLanguage.string("tab_start"), systemImage: "play.circle.fill")
                }
                .tag(0)
            HistoryView()
                .tabItem {
                    Label(appLanguage.string("tab_history"), systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
            StatisticsView()
                .tabItem {
                    Label(appLanguage.string("tab_statistics"), systemImage: "chart.bar.fill")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label(appLanguage.string("tab_settings"), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .preferredColorScheme(.dark)
        .alert(appLanguage.string("alert_still_cleaning_title"), isPresented: $session.showThirtyMinuteAlert) {
            Button(appLanguage.string("alert_still_yes")) {
                session.userStillCleaning(dismissOnly: true)
            }
            Button(appLanguage.string("alert_still_no")) {
                session.userEndSession()
            }
            Button(appLanguage.string("alert_still_dont_remind")) {
                session.userStillCleaning(dismissOnly: false)
            }
        } message: {
            Text(appLanguage.string("alert_still_message"))
        }
        .alert(appLanguage.string("alert_two_hour_title"), isPresented: $session.showTwoHourAlert) {
            Button(appLanguage.string("alert_two_hour_end")) {
                session.confirmTwoHourEnd()
            }
            Button(appLanguage.string("alert_two_hour_continue"), role: .cancel) {
                session.cancelTwoHourAlert()
            }
        } message: {
            Text(appLanguage.string("alert_two_hour_message"))
        }
        .fullScreenCover(item: $session.sessionResult) { result in
            EndSessionView(session: result) {
                session.sessionResult = nil
            }
        }
    }
}
