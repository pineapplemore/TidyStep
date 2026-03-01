//
//  PaywallView.swift
//  TidyStep
//
//  Subscription paywall: 3-day trial, monthly & yearly. Optional onDismiss for sheet presentation.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscription: SubscriptionManager
    @EnvironmentObject var appLanguage: AppLanguage
    var onDismiss: (() -> Void)?

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    private let accent = Color(hex: 0x2563EB)

    var body: some View {
        ZStack {
            Color(hex: 0x0D0D0F)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    features
                    if subscription.products.isEmpty {
                        progressView
                    } else {
                        subscriptionOptions
                    }
                    restoreButton
                    if let onDismiss = onDismiss {
                        Button {
                            onDismiss()
                        } label: {
                            Text(appLanguage.string("paywall_maybe_later"))
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: 0x9CA3AF))
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
            }
            .overlay {
                if subscription.purchaseError != nil {
                    errorBanner
                }
            }
        }
        .onAppear {
            selectedProduct = subscription.yearlyProduct ?? subscription.monthlyProduct
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 44))
                .foregroundStyle(accent)
            Text(appLanguage.string("paywall_title"))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(appLanguage.string("paywall_subtitle"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: "chart.bar", text: appLanguage.string("paywall_feature_stats"))
            featureRow(icon: "bell.badge", text: appLanguage.string("paywall_feature_reminder"))
            featureRow(icon: "square.grid.2x2", text: appLanguage.string("paywall_feature_widget"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x1A1A1E))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(accent)
                .frame(width: 24, alignment: .center)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    private var progressView: some View {
        ProgressView()
            .tint(.white)
            .frame(maxWidth: .infinity)
            .padding(32)
    }

    private var subscriptionOptions: some View {
        VStack(spacing: 12) {
            if let yearly = subscription.yearlyProduct {
                optionRow(
                    product: yearly,
                    title: appLanguage.string("paywall_yearly"),
                    badge: subscription.hasTrial(yearly) ? appLanguage.string("paywall_trial_days") : nil,
                    isSelected: selectedProduct?.id == yearly.id
                ) {
                    selectedProduct = yearly
                }
            }
            if let monthly = subscription.monthlyProduct {
                optionRow(
                    product: monthly,
                    title: appLanguage.string("paywall_monthly"),
                    badge: subscription.hasTrial(monthly) ? appLanguage.string("paywall_trial_days") : nil,
                    isSelected: selectedProduct?.id == monthly.id
                ) {
                    selectedProduct = monthly
                }
            }
            if let product = selectedProduct {
                Button {
                    isPurchasing = true
                    Task {
                        _ = await subscription.purchase(product)
                        isPurchasing = false
                    }
                } label: {
                    HStack {
                        if isPurchasing || subscription.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(appLanguage.string("paywall_start_trial"))
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isPurchasing || subscription.isLoading)
            }
        }
    }

    private func optionRow(
        product: Product,
        title: String,
        badge: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .foregroundStyle(accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(accent.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? accent : Color(hex: 0x6B7280))
            }
            .padding(14)
            .background(isSelected ? accent.opacity(0.15) : Color(hex: 0x1A1A1E))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accent : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var restoreButton: some View {
        Button {
            Task {
                await subscription.restore()
            }
        } label: {
            Text(appLanguage.string("paywall_restore"))
                .font(.footnote)
                .foregroundStyle(Color(hex: 0x9CA3AF))
        }
        .disabled(subscription.isLoading)
    }

    private var errorBanner: some View {
        VStack {
            if let msg = subscription.purchaseError {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color(hex: 0xEF4444))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 24)
            }
            Spacer()
        }
        .padding(.top, 16)
    }
}
