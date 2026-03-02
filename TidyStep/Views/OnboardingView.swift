//
//  OnboardingView.swift
//  TidyStep
//

import SwiftUI

struct OnboardingView: View {
    /// 本 session 内点击「知道了」后隐藏；下次启动若未勾选「不再提醒」会再次显示。
    @Binding var dismissedThisSession: Bool
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
                    dismissedThisSession = true
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 与其它页一致：右上角语言图标（等同 toolbar .navigationBarTrailing），落在导航栏高度内
            VStack {
                HStack {
                    Spacer()
                    Button {
                        appLanguage.toggleLanguage()
                    } label: {
                        Image(systemName: "globe")
                            .font(.system(size: 22, weight: .regular))
                            .frame(width: 44, height: 44, alignment: .center)
                            .contentShape(Rectangle())
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                    .padding(.trailing, 16)
                }
                .frame(height: 44)
                Spacer()
            }
        }
    }
}
