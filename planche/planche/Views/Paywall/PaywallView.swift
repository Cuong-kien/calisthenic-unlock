import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with close button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)

            PaywallContent(dismissAction: { dismiss() })
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Shared Paywall Content

struct PaywallContent: View {
    @EnvironmentObject private var storeManager: StoreManager
    let dismissAction: () -> Void

    @State private var selectedProductID: String? = nil
    @State private var isPurchasing = false
    @State private var isLoadingProducts = true
    @State private var errorMessage: String? = nil

    private var monthlyProduct: Product? {
        storeManager.products.first { $0.id == "com.fitness.planche.monthly" }
    }

    private var yearlyProduct: Product? {
        storeManager.products.first { $0.id == "com.fitness.planche.yearly" }
    }

    private let features = [
        "All levels & exercises unlocked",
        "Tracking Process",
        "No Ads",
        "Priority support",
    ]

    private static let termsURL = URL(string: "https://plancheapp.com/terms")
    private static let privacyURL = URL(string: "https://plancheapp.com/privacy")

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Heading
                Text("Go Premium")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Feature list
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.blue)
                            Text(feature)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 28)

                // Plan cards
                VStack(spacing: 12) {
                    if isLoadingProducts {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    } else if storeManager.products.isEmpty {
                        PaywallPlanCard(
                            title: "Yearly",
                            price: "$49.99 / year",
                            detail: "$4.17/mo billed annually",
                            badge: "BEST VALUE",
                            saveBadge: "Save 17%",
                            isSelected: selectedProductID != "com.fitness.planche.monthly",
                            action: { selectedProductID = "com.fitness.planche.yearly" }
                        )
                        PaywallPlanCard(
                            title: "Monthly",
                            price: "$4.99 / month",
                            detail: nil,
                            badge: nil,
                            saveBadge: nil,
                            isSelected: selectedProductID == "com.fitness.planche.monthly",
                            action: { selectedProductID = "com.fitness.planche.monthly" }
                        )
                    } else {
                        if let yearly = yearlyProduct {
                            let perMonth = yearly.price / 12
                            let perMonthStr = perMonth.formatted(yearly.priceFormatStyle)
                            PaywallPlanCard(
                                title: "Yearly",
                                price: "\(yearly.displayPrice) / year",
                                detail: "\(perMonthStr)/mo billed annually",
                                badge: "BEST VALUE",
                                saveBadge: "Save 17%",
                                isSelected: selectedProductID == yearly.id,
                                action: { selectedProductID = yearly.id }
                            )
                        }
                        if let monthly = monthlyProduct {
                            PaywallPlanCard(
                                title: "Monthly",
                                price: "\(monthly.displayPrice) / month",
                                detail: nil,
                                badge: nil,
                                saveBadge: nil,
                                isSelected: selectedProductID == monthly.id,
                                action: { selectedProductID = monthly.id }
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
            }
        }

        // Bottom actions
        VStack(spacing: 12) {
            Button {
                Task { await handlePurchase() }
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text("Start 7-Day Free Trial")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    selectedProductID == nil && !storeManager.products.isEmpty
                        ? Color(.systemGray3)
                        : Color.blue
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled((selectedProductID == nil && !storeManager.products.isEmpty) || isPurchasing)

            Button { dismissAction() } label: {
                Text("Maybe later")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            // Legal text
            VStack(spacing: 4) {
                Text("Cancel anytime. Subscription auto-renews.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.tertiaryLabel))

                HStack(spacing: 4) {
                    if let url = Self.termsURL {
                        Link("Terms", destination: url)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.tertiaryLabel))
                    if let url = Self.privacyURL {
                        Link("Privacy", destination: url)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.tertiaryLabel))
                    Button("Restore Purchase") {
                        Task {
                            await storeManager.restorePurchases()
                            if storeManager.isSubscribed {
                                dismissAction()
                            } else {
                                errorMessage = "No active subscription found."
                            }
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .task {
            if selectedProductID == nil {
                selectedProductID = "com.fitness.planche.yearly"
            }
            if storeManager.products.isEmpty {
                await storeManager.loadProducts()
            }
            isLoadingProducts = false
        }
        .onChange(of: storeManager.products) { _, _ in
            isLoadingProducts = false
            if selectedProductID == nil, yearlyProduct != nil {
                selectedProductID = "com.fitness.planche.yearly"
            }
        }
    }

    private func handlePurchase() async {
        guard let id = selectedProductID,
              let product = storeManager.products.first(where: { $0.id == id }) else {
            errorMessage = "Unable to load plans. Check your connection and try again."
            return
        }
        isPurchasing = true
        errorMessage = nil
        do {
            try await storeManager.purchase(product)
            if storeManager.isSubscribed { dismissAction() }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
        isPurchasing = false
    }
}

// MARK: - Plan Card

struct PaywallPlanCard: View {
    let title: String
    let price: String
    let detail: String?
    let badge: String?
    let saveBadge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            if let saveBadge {
                                Text(saveBadge)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(price)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)
                        if let detail {
                            Text(detail)
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.blue : Color(.separator), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.blue : Color(.separator), lineWidth: 1.5)
                        )
                )

                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .offset(x: -12, y: -10)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
