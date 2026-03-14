import StoreKit
import Combine
import Foundation

final class StoreManager: ObservableObject, @unchecked Sendable {
    // MARK: - DEBUG TOGGLE (remove before release)
    @Published var debugOverrideSubscribed: Bool? = nil // set true/false to override, nil = real check

    @Published private(set) var _isSubscribed: Bool = false
    var isSubscribed: Bool {
        if let override = debugOverrideSubscribed { return override }
        return _isSubscribed
    }
    @Published private(set) var products: [Product] = []

    private let productIDs = [
        "com.fitness.planche.monthly",
        "com.fitness.planche.yearly"
    ]

    private var updatesTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    init() {
        updatesTask = Task {
            await listenForTransactionUpdates()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        if !products.isEmpty { return }
        if let existing = loadTask {
            await existing.value
            return
        }
        let task = Task {
            do {
                let fetched = try await Product.products(for: productIDs)
                let sorted = fetched.sorted { $0.id < $1.id }
                await MainActor.run { self.products = sorted }
            } catch {
                print("StoreManager: failed to load products: \(error)")
            }
        }
        loadTask = task
        await task.value
        loadTask = nil
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await checkSubscriptionStatus()
            await transaction.finish()
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            print("StoreManager: restore failed: \(error)")
        }
    }

    func checkSubscriptionStatus() async {
        let active = await hasActiveEntitlement()
        DispatchQueue.main.async { [weak self] in self?._isSubscribed = active }
    }

    private func hasActiveEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await checkSubscriptionStatus()
                await transaction.finish()
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
