import SwiftUI
import SwiftData
import AuthenticationServices
import SafariServices
import StoreKit
import PhotosUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.requestReview) private var requestReview
    @Query private var userProfiles: [UserProfile]
    @State private var showPaywall = false
    @State private var showNotificationSettings = false
    @State private var showSignIn = false
    @State private var showSignOutConfirmation = false
    @State private var showPrivacyPolicy = false
    @State private var showProfileSheet = false
    @State private var displayedMonth: Date = Calendar.current.startOfSettingsMonth(for: Date())

    private var profileDisplayName: String {
        if let profile = userProfiles.first, !profile.name.isEmpty {
            return profile.name
        }
        return authManager.displayName
    }

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    // MARK: - Stats

    private var skillUnlockCount: Int {
        SkillCatalog.shared.allSkills().filter { progressManager.isSkillProgressComplete($0.id) }.count
    }

    private var totalDurationHours: Int {
        Int(progressManager.totalTrainingTime() / 3600)
    }

    private var totalRecords: Int {
        progressManager.totalSessionCount()
    }

    // MARK: - Calendar

    private var sundayCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }

    private var trainingDates: Set<DateComponents> {
        progressManager.trainingDates()
    }

    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayedMonth)
    }

    // Offset from Sunday; nil = empty leading cell
    private var daysInMonth: [Date?] {
        guard let range = sundayCalendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = sundayCalendar.component(.weekday, from: displayedMonth) // 1=Sun
        let offset = firstWeekday - 1
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            var comps = sundayCalendar.dateComponents([.year, .month], from: displayedMonth)
            comps.day = day
            if let date = sundayCalendar.date(from: comps) {
                days.append(date)
            }
        }
        return days
    }

    private let weekdayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    private func hasTrained(on date: Date) -> Bool {
        let comps = sundayCalendar.dateComponents([.year, .month, .day], from: date)
        return trainingDates.contains(comps)
    }

    private func prevMonth() {
        if let d = sundayCalendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = sundayCalendar.startOfSettingsMonth(for: d)
        }
    }

    private var currentMonthStart: Date {
        sundayCalendar.startOfSettingsMonth(for: Date())
    }

    private func nextMonth() {
        let currentMonthStart = sundayCalendar.startOfSettingsMonth(for: Date())
        guard displayedMonth < currentMonthStart else { return }
        if let d = sundayCalendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = sundayCalendar.startOfSettingsMonth(for: d)
        }
    }

    // MARK: - DEBUG (remove before release)
    @EnvironmentObject private var adManager: AdManager

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug")
                .font(.system(size: 20))
                .foregroundStyle(.primary)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                // Subscription toggle
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.yellow)
                        .frame(width: 28)
                    Text("Force Premium")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { storeManager.debugOverrideSubscribed == true },
                        set: { storeManager.debugOverrideSubscribed = $0 ? true : nil }
                    ))
                    .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 60)

                // Current status
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 17))
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    Text("isSubscribed")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(storeManager.isSubscribed ? "true" : "false")
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundStyle(storeManager.isSubscribed ? .green : Color(.secondaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 60)

                // Test interstitial
                Button {
                    adManager.showInterstitial { print("Debug: interstitial dismissed") }
                } label: {
                    HStack {
                        Image(systemName: "play.rectangle")
                            .font(.system(size: 17))
                            .foregroundStyle(.orange)
                            .frame(width: 28)
                        Text("Test Interstitial Ad")
                            .font(.system(size: 17))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(adManager.interstitialReady ? "Ready" : "Not loaded")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                Divider().padding(.leading, 60)

                // Preload ads
                Button {
                    adManager.preloadInterstitial()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 17))
                            .foregroundStyle(.green)
                            .frame(width: 28)
                        Text("Preload Ads")
                            .font(.system(size: 17))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 32)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Profile ──────────────────────────────────
                VStack(spacing: 14) {
                    Button { showProfileSheet = true } label: {
                        ZStack(alignment: .bottomTrailing) {
                            if let avatarData = userProfiles.first?.avatarData,
                               let uiImage = UIImage(data: avatarData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color(.systemGray3))
                            }
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color(.secondaryLabel))
                                .background(Circle().fill(Color(.systemBackground)).frame(width: 20, height: 20))
                        }
                    }
                    .buttonStyle(.plain)

                    Text(profileDisplayName)
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 14)

                // ── Stats row ────────────────────────────────
                HStack(spacing: 6) {
                    StatCell(value: "\(skillUnlockCount)", label: "Skill unlock")
                    StatCell(value: "\(totalRecords)", label: "Records")
                    StatCell(value: "\(totalDurationHours)", label: "Durations(hours)")
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 16)

                // ── Premium Banner ────────────────────────────
                if storeManager.isSubscribed {
                    // Already subscribed — compact "Pro" badge
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Planche Pro")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "0061EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } else {
                    Button { showPaywall = true } label: {
                        ZStack(alignment: .trailing) {
                            // Glow spotlight — replicates the diagonal light in Figma
                            Ellipse()
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 220, height: 220)
                                .blur(radius: 44)
                                .offset(x: 50, y: 0)

                            // Content row
                            HStack(spacing: 0) {
                                // Left: title + subtitle
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Get Premium")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text("enjoy all the benefits of the app")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white)
                                }

                                Spacer()

                                // Right: frosted pill
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.white)
                                    Text("Upgrade")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                                )
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(Color(hex: "0061EB"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }

                // ── Records (Calendar) ───────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Records")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)

                    VStack(spacing: 0) {
                        // Month nav header
                        HStack {
                            Button { prevMonth() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.blue)
                                    .frame(width: 24, height: 24)
                            }
                            Spacer()
                            Text(monthTitle)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Button { nextMonth() } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(displayedMonth < currentMonthStart ? Color.blue : Color(.systemGray4))
                                    .frame(width: 24, height: 24)
                            }
                            .disabled(displayedMonth >= currentMonthStart)
                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 12)

                        // Weekday header row
                        HStack(spacing: 0) {
                            ForEach(weekdayLabels, id: \.self) { label in
                                Text(label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 20)

                        // Day grid
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                            spacing: 7
                        ) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, dateOpt in
                                if let date = dateOpt {
                                    let trained  = hasTrained(on: date)
                                    let isToday  = sundayCalendar.isDateInToday(date)
                                    let dayNum   = sundayCalendar.component(.day, from: date)

                                    ZStack {
                                        if trained {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 16, height: 16)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 7, weight: .bold))
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(dayNum)")
                                                .font(.system(size: 20))
                                                .foregroundStyle(isToday ? Color.primary : Color.secondary)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                } else {
                                    Color.clear.frame(width: 44, height: 44)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 3)

                        // Bottom separator
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 0.5)
                            .padding(.top, 8)
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                // ── Settings list ────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)

                    VStack(spacing: 0) {
                        SettingsRowItem(icon: "bell.fill", title: "Notification") { showNotificationSettings = true }
                        SettingsRowItem(icon: "star.fill", title: "Rate us") {
                            requestReview()
                        }
                        SettingsRowItem(icon: "ladybug.fill", title: "Report a bug") {
                            if let url = URL(string: "https://plancheapp.com/report-bug") {
                                UIApplication.shared.open(url)
                            }
                        }
                        SettingsRowItem(icon: "lock.shield.fill", title: "Privacy Policy") {
                            showPrivacyPolicy = true
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text("Version \(version)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                }

                // MARK: - DEBUG (remove before release)
                debugSection
            }
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileSheet()
                .environmentObject(authManager)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://plancheapp.com/privacy")!)
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authManager.signOut(modelContext: modelContext)
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Profile Sheet

private struct ProfileSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var userProfiles: [UserProfile]

    @State private var showEditNickname = false
    @State private var editedName = ""
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showSignOutConfirmation = false

    private var profile: UserProfile? { userProfiles.first }

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if authManager.isAppleSignedIn {
                // Signed-in state
                signedInContent
            } else {
                // Not signed in — show sign in option
                signInContent
            }

            Spacer()
        }
        .background(Color(.secondarySystemBackground))
        .alert("Edit Nickname", isPresented: $showEditNickname) {
            TextField("Name", text: $editedName)
            Button("Cancel", role: .cancel) {}
            Button("Save") { saveNickname() }
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authManager.signOut(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: selectedPhoto) { _, newItem in
            if let newItem {
                Task { await loadPhoto(from: newItem) }
            }
        }
    }

    // MARK: - Signed In

    private var signedInContent: some View {
        VStack(spacing: 16) {
            // Avatar
            if let avatarData = profile?.avatarData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(Color(.systemGray3))
            }

            // Name
            Text(profileDisplayName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            // Email — prefer profile (synced via CloudKit), fallback to UserDefaults
            if let profileEmail = profile?.email, !profileEmail.isEmpty {
                Text(profileEmail)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.secondaryLabel))
            } else if let email = authManager.email {
                Text(email)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            // Auth provider badge
            Text("Apple ID")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())

            // Action buttons
            VStack(spacing: 0) {
                ProfileSheetButton(title: "Edit Nickname", color: .blue) {
                    editedName = profile?.name ?? authManager.displayName
                    showEditNickname = true
                }
                Divider().padding(.leading, 16)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Edit Avatar")
                        .font(.system(size: 17))
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                Divider().padding(.leading, 16)

                ProfileSheetButton(title: "Log Out", color: .red) {
                    showSignOutConfirmation = true
                }
            }
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Sign In

    private var signInContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color(.systemGray3))

            Text("Sign in to sync your data")
                .font(.system(size: 17))
                .foregroundStyle(Color(.secondaryLabel))

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                authManager.handleSignIn(result)
                if case .success = result {
                    dismiss()
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 40)
        }
        .padding(.top, 16)
    }

    // MARK: - Helpers

    private var profileDisplayName: String {
        if let profile, !profile.name.isEmpty { return profile.name }
        return authManager.displayName
    }

    private func saveNickname() {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let descriptor = FetchDescriptor<UserProfile>()
        let existing = (try? modelContext.fetch(descriptor))?.first
        let target = existing ?? {
            let p = UserProfile()
            modelContext.insert(p)
            return p
        }()
        target.name = trimmed
        try? modelContext.save()
    }

    private func loadPhoto(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        // Downscale for storage
        guard let uiImage = UIImage(data: data),
              let resized = uiImage.preparingThumbnail(of: CGSize(width: 300, height: 300)),
              let jpegData = resized.jpegData(compressionQuality: 0.8) else { return }
        await MainActor.run {
            let descriptor = FetchDescriptor<UserProfile>()
            let existing = (try? modelContext.fetch(descriptor))?.first
            let target = existing ?? {
                let p = UserProfile()
                modelContext.insert(p)
                return p
            }()
            target.avatarData = jpegData
            try? modelContext.save()
        }
    }
}

// MARK: - Profile Sheet Button

private struct ProfileSheetButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
    }
}

// MARK: - Safari View

private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Stat Cell

private struct StatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Settings Row Item

private struct SettingsRowItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 52)

                VStack(spacing: 0) {
                    Divider()
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 51)
                }
            }
            .padding(.leading, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar extension (private)

private extension Calendar {
    func startOfSettingsMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
