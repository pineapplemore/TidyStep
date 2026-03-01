//
//  SubscriptionManager.swift
//  TidyStep
//
//  StoreKit 2: 3-day trial, monthly & yearly. Product IDs in App Store Connect:
//  - com.tidystep.app.monthly
//  - com.tidystep.app.yearly
//  Configure 3-day free trial as introductory offer for both in App Store Connect.
//

import StoreKit
import SwiftUI

private let monthlyId = "com.tidystep.app.monthly"
private let yearlyId = "com.tidystep.app.yearly"

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed: Bool = false
    // 调试时可恢复：@Published var debugForceSubscribed: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var purchaseError: String? = nil

    /// 是否有权使用高级功能：仅真实订阅时为 true。
    var hasAccess: Bool { isSubscribed }

    private var updateListener: Task<Void, Never>? = nil

    init() {
        updateListener = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListener?.cancel()
    }

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyId }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == yearlyId }
    }

    /// True if any product has an introductory offer (e.g. 3-day trial).
    func hasIntroOffer(_ product: Product) -> Bool {
        guard let sub = product.subscription else { return false }
        return sub.introductoryOffer != nil
    }

    /// Caller should show paywall_trial_days (e.g. "3-day free trial") when hasIntroOffer is true.
    func hasTrial(_ product: Product) -> Bool {
        guard let sub = product.subscription,
              let intro = sub.introductoryOffer else { return false }
        return intro.paymentMode == .freeTrial
    }

    func loadProducts() async {
        do {
            let ids = [monthlyId, yearlyId]
            products = try await Product.products(for: ids).sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func updateSubscriptionStatus() async {
        var hasAccess = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result {
                if tx.productID == monthlyId || tx.productID == yearlyId {
                    hasAccess = true
                    break
                }
            }
        }
        isSubscribed = hasAccess
    }

    func purchase(_ product: Product) async -> Bool {
        purchaseError = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                    await updateSubscriptionStatus()
                    return true
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase pending"
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        return false
    }

    func restore() async {
        purchaseError = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    await tx.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }
}
