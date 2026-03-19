import SwiftUI
import SwiftData

struct LevelDetailView: View {
    let skill: Skill
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeManager: StoreManager
    @Query private var customizations: [ExerciseCustomization]
    @State private var selectedExercise: Exercise? = nil
    @State private var showPaywall = false

    private var exercises: [Exercise] {
        SkillCatalog.shared.exercises(for: skill.id)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.secondarySystemBackground).ignoresSafeArea()

            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        heroSection
                        contentSection
                    }
                    .padding(.bottom, 80)

                    skillIcon
                        .padding(.leading, 24)
                        .padding(.top, 110)
                }
            }
            .ignoresSafeArea(edges: .top)

            startWorkoutButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        Color.trainingBlue
            .frame(height: 190)
    }

    // MARK: - Skill Icon

    private var skillIcon: some View {
        Group {
            if let imageName = skill.skillIconImageName(active: true) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: skill.iconName)
                    .font(.system(size: 70))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 120, height: 120)
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(skill.displayName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text(skill.description)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)

            HStack(spacing: 8) {
                Text("Difficulty level:")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                starsView(for: skill.difficultyStars)
            }

            Text("Require: \(skill.requirement ?? "—")")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 8) {
                Text("Equipment")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(skill.equipment.components(separatedBy: ", "), id: \.self) { item in
                            Text(item)
                                .font(.system(size: 13))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Text("Programs Training (\(exercises.count) exercise)")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .padding(.top, 4)

            exerciseList
        }
        .padding(.horizontal, 24)
        .padding(.top, 76)
        .background(
            Color(.secondarySystemBackground)
                .clipShape(RoundedTopRectangle(cornerRadius: 20))
                .offset(y: -20)
        )
        .offset(y: -20)
    }

    // MARK: - Stars View

    private func starsView(for value: Double) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                let d = Double(i)
                Image(systemName: value >= d ? "star.fill"
                               : value >= d - 0.5 ? "star.leadinghalf.filled"
                               : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yellow)
            }
        }
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: 0) {
            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                Button {
                    selectedExercise = exercise
                } label: {
                    exerciseRow(exercise)
                }
                .buttonStyle(.plain)

                if index < exercises.count - 1 {
                    Divider()
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 14) {
            Group {
                if let config = exercise.spriteConfig {
                    GeometryReader { geo in
                        SpriteAnimationView(config: config)
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                } else if exercise.imageName.contains(".") {
                    Image(systemName: exercise.imageName)
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray5))
                } else {
                    Image(exercise.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(currentReps(for: exercise))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func currentReps(for exercise: Exercise) -> String {
        if let stages = exercise.stages, !stages.isEmpty {
            return "\(stages.count) stages / \(exercise.sets) sets"
        }

        let custom = customizations.first {
            $0.exerciseName == exercise.name &&
            $0.skillID == exercise.skillID
        }

        let setsLabel = "× \(exercise.sets) sets"
        if exercise.exerciseType == .timed {
            let secs: Int
            if let customSecs = custom?.customDurationSeconds {
                secs = customSecs
            } else {
                secs = exercise.durationSeconds
            }
            let min = secs / 60
            let sec = secs % 60
            let timeLabel = min > 0 ? String(format: "%d:%02d", min, sec) : "\(sec)s"
            return "\(timeLabel) \(setsLabel)"
        } else {
            let repsLabel: String
            if let reps = custom?.customReps { repsLabel = "\(reps) rep" }
            else { repsLabel = exercise.reps }
            return "\(repsLabel) \(setsLabel)"
        }
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutButton: some View {
        Group {
            if skill.requiresSubscription && !storeManager.isSubscribed {
                Button { showPaywall = true } label: {
                    primaryButtonLabel("Upgrade to Unlock")
                }
            } else {
                NavigationLink(value: AppRoute.training(skill)) {
                    primaryButtonLabel("Start Training")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color(.secondarySystemBackground).ignoresSafeArea(edges: .bottom))
    }

    private func primaryButtonLabel(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Custom Shape

struct RoundedTopRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
