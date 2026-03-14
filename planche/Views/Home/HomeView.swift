import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var currentLevel: Level {
        progressManager.currentLevel()
    }

    private var sessionsCompleted: Int {
        progressManager.completedSessionCount(for: currentLevel)
    }

    // MARK: - Greeting

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

    // MARK: - Stats

    private var dayCount: Int {
        progressManager.dayCount()
    }

    private var startDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: progressManager.startDate())
    }

    private var totalTimeText: String {
        let total = progressManager.totalTrainingTime()
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private var overallProgress: Double {
        progressManager.overallProgress()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Greeting header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateText)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text(greetingText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal)

                // Stats cards
                statsCards

                // Level card
                levelCard

                if sessionsCompleted >= Level.sessionsToUnlock {
                    Text("Level complete! Move to \(currentLevel.displayName) exercises or advance.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Stats Cards

    private var statsCards: some View {
        HStack(spacing: 12) {
            // Left: Day card (tall)
            VStack(alignment: .leading) {
                Text("Day \(dayCount)")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start at")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text(startDateText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Right: Two stacked cards
            VStack(spacing: 12) {
                // Total time card
                VStack(alignment: .leading, spacing: 4) {
                    Text(totalTimeText)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total time training")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Progress card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(Int(overallProgress))%")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Progress")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: min(overallProgress / 100, 1.0))
                        .tint(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Level Card

    private var levelCard: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [currentLevel.color.opacity(1.0), currentLevel.color.opacity(1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            VStack(alignment: .leading, spacing: 10) {
                Text("Level \(currentLevel.order)")
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))

                Text(currentLevel.displayName.uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("\(sessionsCompleted)/\(Level.sessionsToUnlock) sessions")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))

                Text(currentLevel.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                NavigationLink(value: AppRoute.levelDetail(currentLevel, isUnlocked: true)) {
                    Text("Start Training")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
