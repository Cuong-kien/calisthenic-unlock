import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var navigationState: NavigationState
    @Query private var activePrograms: [ActiveProgram]
    @State private var showUpdateModal = false

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var activeProgram: ActiveProgram? {
        activePrograms.first(where: { !$0.isCompleted }) ?? activePrograms.last
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMMM"
        return formatter.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateText)
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                        Text(greetingText)
                            .font(.system(size: 20))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                // Week strip
                WeekStripView(trainingDates: progressManager.trainingDates())
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
                    .padding(.bottom, 16)

                // Active program card or choose program
                if let program = activeProgram, let skill = program.skill {
                    ActiveProgramCard(
                        program: program,
                        sessionCount: progressManager.activeProgramSessionCount(),
                        trainingTime: progressManager.activeProgramTrainingTime(),
                        progressPercent: progressManager.progressPercent(),
                        showUpdateModal: $showUpdateModal,
                        skill: skill
                    )
                    .padding(16)

                    // Recommend next skill when complete
                    if program.isCompleted {
                        RecommendSection(onViewProgram: {
                            navigationState.switchToProcessTab = true
                        })
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                } else {
                    NoProgramCard {
                        navigationState.switchToProcessTab = true
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showUpdateModal) {
            if let program = activeProgram {
                UpdateProgressModal(activeProgram: program)
            }
        }
    }
}

// MARK: - Week Strip

struct WeekStripView: View {
    let trainingDates: Set<DateComponents>

    private var calendar: Calendar { Calendar.current }
    private let dayLabels = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    private var weekDates: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        let offset = (weekday - 2 + 7) % 7
        guard let monday = calendar.date(byAdding: .day, value: -offset, to: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private func hasTrained(on date: Date) -> Bool {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return trainingDates.contains(comps)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { i, date in
                let trained = hasTrained(on: date)
                let isToday = calendar.isDateInToday(date)
                let isPast = date < Date() && !isToday
                let dayNum = calendar.component(.day, from: date)

                VStack(spacing: 8) {
                    Text(dayLabels[i])
                        .font(.system(size: 17))
                        .foregroundStyle(isToday ? Color.primary : Color.secondary)

                    ZStack {
                        if trained {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Color.primary, lineWidth: 1.5)
                                .frame(width: 16, height: 16)
                        } else if isPast {
                            Circle()
                                .fill(Color.secondary.opacity(0.5))
                                .frame(width: 16, height: 16)
                        } else {
                            Text("\(dayNum)")
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 20, height: 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Active Program Card

struct ActiveProgramCard: View {
    let program: ActiveProgram
    let sessionCount: Int
    let trainingTime: TimeInterval
    let progressPercent: Double
    @Binding var showUpdateModal: Bool
    let skill: Skill

    private static let skillPreviewImages: [String: String] = [
        "foundation2": "frog-stand",
        "tuckPlanche": "tuck-parallettes",
        "advTuckPlanche": "preview-adv-tuck-planche",
        "straddlePlanche": "straddle-planche-hold",
    ]

    private var trainingTimeText: String {
        let totalMinutes = Int(trainingTime) / 60
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h > 0 {
            return "\(h)h \(m)m"
        }
        return "\(m)m"
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: thumbnail + Current Skill + name
                HStack(spacing: 14) {
                    Group {
                        if let imageName = Self.skillPreviewImages[skill.id] {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else if let iconImage = skill.skillIconImageName(active: true) {
                            Image(iconImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: skill.iconName)
                                .font(.system(size: 30))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGray4))
                        }
                    }
                    .frame(width: 90, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Skill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            Text(skill.displayName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            if progressPercent >= 100 {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.blue)
                            }
                        }
                    }

                    Spacer()
                }

                // Stats row: Sessions + Duration
                HStack(spacing: 8) {
                    // Sessions card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Sessions")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        Text("\(sessionCount)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Duration card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Duration")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        Text(trainingTimeText)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Overall Progress
                VStack(spacing: 10) {
                    HStack {
                        Text("Overall Progress")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                        if progressPercent >= 100 {
                            Text("Completed")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.green)
                        } else {
                            Text("\(Int(progressPercent))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            Capsule()
                                .fill(progressPercent >= 100 ? Color.green : Color.blue)
                                .frame(width: geo.size.width * min(progressPercent / 100, 1.0), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 9)
            }
            .padding(12)

            // Divider
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)

            // Bottom buttons: Process + Start Training
            HStack(spacing: 10) {
                Button {
                    showUpdateModal = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("Process")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(16)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                NavigationLink(value: AppRoute.skillDetail(skill)) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Text("Start Training")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 17)
            .padding(.bottom, 16)
        }
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - No Program Card

struct NoProgramCard: View {
    var onExploreSkills: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Start Your Journey")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Explore skills and track your progress step by step")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onExploreSkills) {
                Text("All Skill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "0061EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 17)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Recommend Section

struct RecommendSection: View {
    var onViewProgram: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's next?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)

                VStack(spacing: 6) {
                    Text("Skill Completed!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Conquer new challenges")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: onViewProgram) {
                    Text("Explore Skills")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "0061EB"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
