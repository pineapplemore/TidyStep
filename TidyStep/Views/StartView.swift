//
//  StartView.swift
//  TidyStep
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage
    @StateObject private var session = SessionManager.shared
    @State private var showWeightSheet = false
    @State private var weightText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                if session.isSessionActive {
                    SessionView()
                } else {
                    VStack(spacing: 32) {
                        Spacer()
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)

                        Text(appLanguage.string("start_title"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(appLanguage.string("start_subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if storage.userWeightKg == nil {
                            Button {
                                showWeightSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "scalemass")
                                    Text(appLanguage.string("start_add_weight"))
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: 0x60A5FA))
                            }
                            .padding(.top, 8)
                        }

                        Button {
                            session.startSession(weightKg: storage.userWeightKg)
                        } label: {
                            Text(appLanguage.string("start_button"))
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: 0x5EEAD4))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)

                        Spacer()
                    }
                }
            }
            .navigationTitle(appLanguage.string("tab_start"))
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
}

// MARK: - Weight input
struct WeightInputSheet: View {
    let initialWeight: Double?
    let onSave: (Double?) -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var appLanguage: AppLanguage
    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x111113)
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    Text(appLanguage.string("weight_accuracy_tip"))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                    TextField(appLanguage.string("weight_placeholder"), text: $text)
                        .keyboardType(.decimalPad)
                        .focused($focused)
                        .padding()
                        .background(Color(hex: 0x1F1F23))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .padding()
            }
            .navigationTitle(appLanguage.string("weight_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appLanguage.string("weight_cancel")) { onDismiss() }
                        .foregroundStyle(Color(hex: 0x60A5FA))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let kg = Double(text.replacingOccurrences(of: ",", with: "."))
                        onSave(kg)
                    } label: {
                        Text(appLanguage.string("weight_save"))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: 0x60A5FA))
                    }
                }
            }
            .onAppear {
                if let w = initialWeight, w > 0 {
                    text = String(format: "%.1f", w)
                }
                focused = true
            }
        }
    }
}
