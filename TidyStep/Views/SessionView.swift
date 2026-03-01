//
//  SessionView.swift
//  TidyStep
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var appLanguage: AppLanguage
    @StateObject private var session = SessionManager.shared

    var body: some View {
        VStack(spacing: 24) {
            if session.isPaused {
                Text(appLanguage.string("session_paused"))
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0xF59E0B))
            } else {
                Text(appLanguage.string("session_in_progress"))
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
            }

            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("\(session.currentSteps)")
                        .font(.system(size: 44, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text(appLanguage.string("session_steps"))
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
                VStack(spacing: 8) {
                    Text(formatDuration(session.currentDuration))
                        .font(.system(size: 44, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text(appLanguage.string("session_duration"))
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
            }
            .padding(.vertical, 24)

            if session.isPaused {
                Button {
                    session.endPause()
                } label: {
                    Text(appLanguage.string("session_resume"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: 0x2563EB))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
            } else {
                Button {
                    session.startPause()
                } label: {
                    Text(appLanguage.string("session_pause"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: 0x38BDF8))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
            }

            Button {
                session.userEndSession()
            } label: {
                Text(appLanguage.string("session_end"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: 0x2563EB))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatDuration(_ sec: TimeInterval) -> String {
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%d:%02d", m, s)
    }
}
