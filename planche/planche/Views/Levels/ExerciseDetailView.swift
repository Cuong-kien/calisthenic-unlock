import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    var isLevelLocked: Bool = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var currentValue: Int = 0
    @State private var hasChanges: Bool = false
    @State private var selectedStageIndex: Int = 0

    private var currentStage: ExerciseStage? {
        exercise.stages?[selectedStageIndex]
    }

    private var minimumValue: Int {
        if exercise.exerciseType == .timed {
            return exercise.durationSeconds
        } else {
            let parts = exercise.reps.split(separator: " ")
            if let first = parts.first, let val = Int(first) {
                return val
            }
            return 1
        }
    }

    private var maximumValue: Int? {
        exercise.exerciseType == .timed ? 3599 : nil
    }

    private var stepValue: Int {
        1
    }

    private var displayValue: String {
        if exercise.exerciseType == .timed {
            let min = currentValue / 60
            let sec = currentValue % 60
            return String(format: "%02d:%02d", min, sec)
        }
        return "\(currentValue)"
    }

    private var typeLabel: String {
        exercise.exerciseType == .timed ? "DURATION (SECONDS)" : "REPS"
    }

    @ViewBuilder
    private func stageTabStrip(stages: [ExerciseStage]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(stages.indices, id: \.self) { index in
                    let isActive = selectedStageIndex == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStageIndex = index
                        }
                    } label: {
                        Text("Stage \(index + 1)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? Color.blue : Color(.systemGray5))
                            .foregroundStyle(isActive ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var stageImageView: some View {
        if let stage = currentStage {
            if let sprite = stage.spriteConfig {
                SpriteAnimationView(config: sprite)
            } else {
                Image(stage.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
        }
    }

    @ViewBuilder
    private var exerciseImageView: some View {
        if let sprite = exercise.spriteConfig {
            SpriteAnimationView(config: sprite)
        } else if exercise.imageName.hasPrefix("figure.") {
            Color(.secondarySystemBackground)
                .overlay(
                    Image(systemName: exercise.imageName)
                        .font(.system(size: 72))
                        .foregroundStyle(.secondary)
                )
        } else {
            Image(exercise.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        .padding(.bottom, 24)

                    // STAGED PATH
                    if let stages = exercise.stages, let stage = currentStage {
                        stageTabStrip(stages: stages)
                        stageImageView
                        VStack(alignment: .leading, spacing: 24) {
                            Text(stage.name)
                                .font(.title2).fontWeight(.bold).foregroundStyle(.primary)
                            if !stage.summary.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DESCRIPTION")
                                        .font(.subheadline).fontWeight(.bold).foregroundStyle(.blue)
                                    Text(stage.summary)
                                        .font(.body).foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("GUIDE")
                                    .font(.subheadline).fontWeight(.bold).foregroundStyle(.blue)
                                Text(stage.description)
                                    .font(.body).foregroundStyle(Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            if !stage.guide.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("TIP")
                                        .font(.subheadline).fontWeight(.bold).foregroundStyle(.blue)
                                    Text(stage.guide)
                                        .font(.body).foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 28)
                    } else {
                        // NORMAL PATH
                        exerciseImageView

                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text(typeLabel)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)

                                Spacer()

                                HStack(spacing: 12) {
                                    Button {
                                        decrementValue()
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 36, height: 36)
                                            .background(Color(.systemGray3))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .disabled(currentValue <= minimumValue)
                                    .opacity(!isLevelLocked && currentValue <= minimumValue ? 0.4 : 1)

                                    Text(displayValue)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .monospacedDigit()
                                        .frame(minWidth: 50)

                                    Button {
                                        incrementValue()
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 36, height: 36)
                                            .background(Color(.systemGray3))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .disabled(maximumValue.map { currentValue >= $0 } ?? false)
                                    .opacity(maximumValue.map { currentValue >= $0 ? 0.4 : 1.0 } ?? 1.0)
                                }
                                .disabled(isLevelLocked)
                            }

                            if !exercise.summary.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DESCRIPTION")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                    Text(exercise.summary)
                                        .font(.body)
                                        .foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("GUIDE")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)

                                Text(exercise.description)
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if !exercise.guide.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("TIP")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)

                                    Text(exercise.guide)
                                        .font(.body)
                                        .foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 28)
                    }
                }
            }

            // Bottom buttons
            Group {
                if exercise.stages != nil {
                    Button { dismiss() } label: {
                        Text("Close")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else if hasChanges {
                    HStack(spacing: 12) {
                        Button {
                            loadCurrentValue()
                            hasChanges = false
                        } label: {
                            Text("Reset")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            saveCustomValue()
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .onAppear {
            loadCurrentValue()
        }
    }

    private func loadCurrentValue() {
        let manager = CustomizationManager(modelContext: modelContext)
        if exercise.exerciseType == .timed {
            currentValue = manager.effectiveDuration(for: exercise)
        } else {
            let repsText = manager.effectiveReps(for: exercise)
            currentValue = manager.parseReps(from: repsText) ?? 10
        }
    }

    private func incrementValue() {
        if let max = maximumValue, currentValue + stepValue > max { return }
        currentValue += stepValue
        hasChanges = true
    }

    private func decrementValue() {
        let newValue = currentValue - stepValue
        if newValue >= minimumValue {
            currentValue = newValue
            hasChanges = true
        }
    }

    private func saveCustomValue() {
        let manager = CustomizationManager(modelContext: modelContext)
        if exercise.exerciseType == .timed {
            manager.setCustomValue(
                for: exercise.name,
                skillID: exercise.skillID,
                durationSeconds: currentValue
            )
        } else {
            manager.setCustomValue(
                for: exercise.name,
                skillID: exercise.skillID,
                reps: currentValue
            )
        }
    }
}
