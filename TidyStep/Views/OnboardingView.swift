//
//  OnboardingView.swift
//  TidyStep
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @AppStorage("onboarding_do_not_show_again") private var doNotShowAgain = false
    @EnvironmentObject var appLanguage: AppLanguage

    var body: some View {
        ZStack {
            Color(hex: 0x0D0D0F)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack(spacing: 10) {
                    Image(systemName: "figure.walk")
                    Image(systemName: "iphone")
                }
                .font(.system(size: 48))
                .foregroundStyle(.white)

                Text(appLanguage.string("onboarding_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(appLanguage.string("onboarding_body"))
                    .font(.body)
                    .foregroundStyle(Color(hex: 0xD1D5DB))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)

                Toggle(isOn: $doNotShowAgain) {
                    Text(appLanguage.string("onboarding_dont_show"))
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .tint(Color(hex: 0x5EEAD4))
                .padding(.horizontal, 32)
                .padding(.top, 8)

                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text(appLanguage.string("onboarding_ok"))
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: 0x5EEAD4))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
        }
    }
}
