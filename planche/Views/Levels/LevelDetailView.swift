import SwiftUI
import SwiftData

struct LevelDetailView: View {
    let level: Level
    var isUnlocked: Bool = true
    @Environment(\.modelContext) private var modelContext
    @Query private var customizations: [ExerciseCustomization]
    @State private var selectedDifficulty: Difficulty = .standard
    @State private var selectedExercise: Exercise? = nil

    private var exercises: [Exercise] {
        ExerciseStore.shared.exercises(for: level)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.12).ignoresSafeArea()

            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        heroSection
                        contentSection
                    }
                    .padding(.bottom, 80)

                    // Icon straddling the blue/dark seam
                    levelIcon
                        .padding(.leading, 24)
                        .padding(.top, 110) // 190 hero - 20 card overlap - 60 half icon
                }
            }
            .ignoresSafeArea(edges: .top)

            startWorkoutButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        Color.trainingBlue
            .frame(height: 190)
    }

    // MARK: - Level Icon (straddles hero/card seam)

    private var levelIcon: some View {
        Group {
            if let imageName = level.levelIconImageName(active: isUnlocked) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: level.iconName)
                    .font(.system(size: 70))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 120, height: 120)
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(level.displayName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            // Description
            Text(level.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            // Difficulty row
            HStack(spacing: 8) {
                Text("Difficulty level:")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                starsView(for: level.difficultyStars)
            }

            // Require row
            Text("Require: \(level.requirement ?? "—")")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            // Divider
            Rectangle()
                .fill(Color(white: 0.25))
                .frame(height: 1)

            // Equipment row
            VStack(alignment: .leading, spacing: 8) {
                Text("Equipment")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(level.equipment.components(separatedBy: ", "), id: \.self) { item in
                            Text(item)
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(white: 0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Section header
            Text("Programs Training (\(exercises.count) exercise)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 4)

            // Exercise list
            exerciseList
        }
        .padding(.horizontal, 24)
        .padding(.top, 76) // 60 (half icon into card) + 16 gap
        .background(
            Color(white: 0.12)
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
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(
                exercise: exercise,
                difficulty: level == .foundation ? selectedDifficulty : nil,
                isLevelLocked: !isUnlocked
            )
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let config = exercise.spriteConfig {
                    SpriteAnimationView(config: config)
                        .frame(width: 70, height: 60)
                        .clipped()
                } else if exercise.imageName.contains(".") {
                    Image(systemName: exercise.imageName)
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 70, height: 60)
                        .background(Color(white: 0.2))
                } else {
                    Image(exercise.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Text(currentReps(for: exercise))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func currentReps(for exercise: Exercise) -> String {
        let diff: Difficulty? = level == .foundation ? selectedDifficulty : nil
        let lookupDiff = exercise.level == .foundation ? diff : nil

        let custom = customizations.first {
            $0.exerciseName == exercise.name &&
            $0.levelRawValue == exercise.level.rawValue &&
            $0.difficultyRawValue == lookupDiff?.rawValue
        }

        let setsLabel = "× \(exercise.sets) sets"
        if exercise.exerciseType == .timed {
            let secs: Int
            if let customSecs = custom?.customDurationSeconds {
                secs = customSecs
            } else if let diff, exercise.level == .foundation {
                let text = exercise.reps(for: diff).trimmingCharacters(in: .whitespaces).lowercased()
                secs = (text.hasSuffix("s") ? Int(text.dropLast()) : nil) ?? exercise.durationSeconds
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
            else if let diff, exercise.level == .foundation { repsLabel = exercise.reps(for: diff) }
            else { repsLabel = exercise.reps }
            return "\(repsLabel) \(setsLabel)"
        }
    }

    // MARK: - Recommended Level

    private var recommendedLevel: Level {
        ProgressManager(modelContext: modelContext).currentLevel()
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutButton: some View {
        if isUnlocked {
            NavigationLink(value: AppRoute.training(level, difficulty: level == .foundation ? selectedDifficulty : nil)) {
                Text("Start Training")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(
                Color(white: 0.12)
                    .ignoresSafeArea(edges: .bottom)
            )
        } else {
            NavigationLink(value: AppRoute.levelDetail(recommendedLevel, isUnlocked: true)) {
                Text("Unlock Programs")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(
                Color(white: 0.12)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
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
