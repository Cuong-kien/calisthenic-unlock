import SwiftUI
import SwiftData
import AuthenticationServices

struct OnboardingView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0

    // Profile form state
    @State private var profileName = ""
    @State private var profileAge = ""
    @State private var profileLevel = "beginner"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch currentStep {
            case 0:
                OnboardingWelcomeStep(onNext: { withAnimation { currentStep = 1 } })
            case 1:
                OnboardingProfileStep(
                    name: $profileName,
                    age: $profileAge,
                    level: $profileLevel,
                    onBack: { withAnimation { currentStep = 0 } },
                    onNext: {
                        saveProfile()
                        withAnimation { currentStep = 2 }
                    }
                )
            case 2:
                OnboardingPaywallStep(
                    onBack: { withAnimation { currentStep = 1 } },
                    onComplete: { markOnboardingComplete() }
                )
            default:
                EmptyView()
            }
        }
    }

    private func saveProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        let existing = (try? modelContext.fetch(descriptor))?.first

        let profile = existing ?? {
            let p = UserProfile()
            modelContext.insert(p)
            return p
        }()

        profile.name = profileName
        profile.age = Int(profileAge) ?? 0
        profile.heightCm = 0
        profile.weightKg = 0
        profile.fitnessLevel = profileLevel
        try? modelContext.save()
    }

    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Step Indicator

private struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                if index == currentStep {
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

// MARK: - Back Button

private struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Top Bar

private struct OnboardingTopBar: View {
    let title: String
    let step: Int
    let onBack: () -> Void

    var body: some View {
        HStack {
            OnboardingBackButton(action: onBack)
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            // Invisible spacer to balance the back button
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)

        StepIndicator(currentStep: step, totalSteps: 3)
            .padding(.bottom, 16)
    }
}

// MARK: - Step 1: Welcome + Sign-In

private struct OnboardingWelcomeStep: View {
    @EnvironmentObject private var authManager: AuthManager
    let onNext: () -> Void

    @State private var isSignedIn = false

    var body: some View {
        VStack(spacing: 0) {
            // Hero gradient area (no icon)
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)

            Spacer().frame(height: 32)

            // Title
            Text("Master Your\n\(Text("Body Weight").foregroundStyle(Color.blue))")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Progressive calisthenics training.\nFrom basics to planche, step by step.")
                .font(.system(size: 15))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.horizontal, 24)

            Spacer()

            // Sign-in options
            VStack(spacing: 12) {
                if isSignedIn {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.green)
                        Text("Signed in as \(authManager.displayName)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.4), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Button(action: onNext) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        authManager.handleSignIn(result)
                        if case .success = result {
                            withAnimation { isSignedIn = true }
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let error = authManager.signInError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }

                if !isSignedIn {
                    Button {
                        authManager.continueAsGuest()
                        onNext()
                    } label: {
                        Text("Sign in without account")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 2: Profile Form

private struct OnboardingProfileStep: View {
    @Binding var name: String
    @Binding var age: String
    @Binding var level: String
    let onBack: () -> Void
    let onNext: () -> Void

    private let levels: [(id: String, title: String, desc: String)] = [
        ("beginner", "Beginner", "New to calisthenics, building foundations"),
        ("fundamental", "Fundamental", "Comfortable with push-ups, pull-ups & dips"),
        ("mastery", "Mastery", "Working towards planche, front lever"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingTopBar(title: "Your Profile", step: 1, onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Tell us about you")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(.primary)
                        .padding(.top, 16)

                    Text("We'll personalize your training plan.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    // NAME
                    OnboardingFieldLabel("NAME")
                    OnboardingTextField(text: $name, placeholder: "Your name")
                        .padding(.bottom, 16)

                    // AGE
                    OnboardingFieldLabel("AGE")
                    OnboardingTextField(text: $age, placeholder: "25", keyboardType: .numberPad)
                        .padding(.bottom, 24)

                    // CHOOSE YOUR LEVEL
                    OnboardingFieldLabel("CHOOSE YOUR LEVEL")
                        .padding(.bottom, 8)

                    VStack(spacing: 10) {
                        ForEach(levels, id: \.id) { item in
                            LevelRadioCard(
                                title: item.title,
                                description: item.desc,
                                isSelected: level == item.id,
                                action: { level = item.id }
                            )
                        }
                    }
                    .padding(.bottom, 24)

                    // Continue button
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Profile Form Components

private struct OnboardingFieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(.secondaryLabel))
            .tracking(0.5)
            .padding(.bottom, 8)
    }
}

private struct OnboardingTextField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var suffix: String? = nil

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
            if let suffix {
                Text(suffix)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct LevelRadioCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Radio circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color(.separator), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                isSelected
                    ? Color.blue.opacity(0.15)
                    : Color(.secondarySystemBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.blue : Color(.separator), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Paywall

private struct OnboardingPaywallStep: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            OnboardingTopBar(title: "", step: 2, onBack: onBack)
            PaywallContent(dismissAction: onComplete)
        }
    }
}
