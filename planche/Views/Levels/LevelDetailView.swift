import SwiftUI
import SwiftData

struct LevelDetailView: View {
    let level: Level
    @Environment(\.modelContext) private var modelContext

    private var exercises: [Exercise] {
        ExerciseStore.shared.exercises(for: level)
    }

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(progressManager.completedSessionCount(for: level))/\(Level.sessionsToUnlock) sessions completed")
                            .font(.subheadline)
                        ProgressView(value: Double(progressManager.completedSessionCount(for: level)), total: Double(Level.sessionsToUnlock))
                            .tint(level.color)
                    }
                    Spacer()
                    NavigationLink {
                        TrainingView(level: level)
                    } label: {
                        Text("Train")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(level.color)
                            .clipShape(Capsule())
                    }
                }
            }

            Section("Exercises") {
                ForEach(exercises) { exercise in
                    NavigationLink {
                        ExerciseDetailView(exercise: exercise)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: exercise.imageName)
                                .font(.title3)
                                .foregroundStyle(level.color)
                                .frame(width: 36)
                            Text(exercise.name)
                        }
                    }
                }
            }
        }
        .navigationTitle(level.displayName)
    }
}
