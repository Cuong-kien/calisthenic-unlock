import SwiftUI
import SwiftData

struct TrainingView: View {
    let level: Level
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var showCompletion = false

    private var exercises: [Exercise] {
        ExerciseStore.shared.exercises(for: level)
    }

    private var isLastExercise: Bool {
        currentIndex >= exercises.count - 1
    }

    var body: some View {
        VStack(spacing: 24) {
            // Progress bar
            ProgressView(value: Double(currentIndex + 1), total: Double(exercises.count))
                .tint(level.color)
                .padding(.horizontal)

            Text("Exercise \(currentIndex + 1) of \(exercises.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if currentIndex < exercises.count {
                let exercise = exercises[currentIndex]

                Image(systemName: exercise.imageName)
                    .font(.system(size: 80))
                    .foregroundStyle(level.color)

                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(exercise.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                if isLastExercise {
                    completeSession()
                } else {
                    withAnimation {
                        currentIndex += 1
                    }
                }
            } label: {
                Text(isLastExercise ? "Complete Training" : "Next Exercise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLastExercise ? Color.green : level.color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Training Complete!", isPresented: $showCompletion) {
            Button("Done") { dismiss() }
        } message: {
            Text("Great job! You've completed a \(level.displayName) training session.")
        }
    }

    private func completeSession() {
        let manager = ProgressManager(modelContext: modelContext)
        manager.completeSession(for: level)
        showCompletion = true
    }
}
