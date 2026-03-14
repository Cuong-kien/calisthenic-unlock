import Foundation
import SwiftData

struct CustomizationManager {
    let modelContext: ModelContext

    func customization(
        for exerciseName: String,
        skillID: String,
        difficulty: Difficulty? = nil
    ) -> ExerciseCustomization? {
        let diffRaw = difficulty?.rawValue

        let descriptor = FetchDescriptor<ExerciseCustomization>(
            predicate: #Predicate<ExerciseCustomization> {
                $0.exerciseName == exerciseName &&
                $0.skillID == skillID &&
                $0.difficultyRawValue == diffRaw
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func effectiveReps(for exercise: Exercise, difficulty: Difficulty? = nil) -> String {
        let diff = exercise.skillID == "foundation" ? difficulty : nil
        if let custom = customization(for: exercise.name, skillID: exercise.skillID, difficulty: diff),
           let reps = custom.customReps {
            return "\(reps) rep"
        }
        if let diff = difficulty, exercise.skillID == "foundation" {
            return exercise.reps(for: diff)
        }
        return exercise.reps
    }

    func effectiveDuration(for exercise: Exercise, difficulty: Difficulty? = nil) -> Int {
        let diff = exercise.skillID == "foundation" ? difficulty : nil
        if let custom = customization(for: exercise.name, skillID: exercise.skillID, difficulty: diff),
           let duration = custom.customDurationSeconds {
            return duration
        }
        if let diff = difficulty, exercise.skillID == "foundation" {
            return parseDuration(from: exercise.reps(for: diff)) ?? exercise.durationSeconds
        }
        return exercise.durationSeconds
    }

    func effectiveDisplayText(for exercise: Exercise, difficulty: Difficulty? = nil) -> String {
        if exercise.exerciseType == .timed {
            let secs = effectiveDuration(for: exercise, difficulty: difficulty)
            let min = secs / 60
            let sec = secs % 60
            return min > 0 ? String(format: "%d:%02d", min, sec) : "\(sec)s"
        }
        return effectiveReps(for: exercise, difficulty: difficulty)
    }

    func setCustomValue(
        for exerciseName: String,
        skillID: String,
        difficulty: Difficulty? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil
    ) {
        if let existing = customization(for: exerciseName, skillID: skillID, difficulty: difficulty) {
            existing.customReps = reps
            existing.customDurationSeconds = durationSeconds
        } else {
            let new = ExerciseCustomization(
                exerciseName: exerciseName,
                skillID: skillID,
                difficulty: difficulty,
                customReps: reps,
                customDurationSeconds: durationSeconds
            )
            modelContext.insert(new)
        }
        try? modelContext.save()
    }

    func parseReps(from text: String) -> Int? {
        let parts = text.trimmingCharacters(in: .whitespaces).split(separator: " ")
        if let first = parts.first {
            return Int(first)
        }
        return nil
    }

    private func parseDuration(from text: String) -> Int? {
        let cleaned = text.trimmingCharacters(in: .whitespaces).lowercased()
        if cleaned.hasSuffix("s") {
            return Int(cleaned.dropLast())
        }
        return nil
    }
}
