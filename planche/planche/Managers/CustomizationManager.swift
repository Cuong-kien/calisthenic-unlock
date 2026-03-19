import Foundation
import SwiftData

struct CustomizationManager {
    let modelContext: ModelContext

    func customization(
        for exerciseName: String,
        skillID: String
    ) -> ExerciseCustomization? {
        let descriptor = FetchDescriptor<ExerciseCustomization>(
            predicate: #Predicate<ExerciseCustomization> {
                $0.exerciseName == exerciseName &&
                $0.skillID == skillID
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func effectiveReps(for exercise: Exercise) -> String {
        if let custom = customization(for: exercise.name, skillID: exercise.skillID),
           let reps = custom.customReps {
            return "\(reps) rep"
        }
        return exercise.reps
    }

    func effectiveDuration(for exercise: Exercise) -> Int {
        if let custom = customization(for: exercise.name, skillID: exercise.skillID),
           let duration = custom.customDurationSeconds {
            return duration
        }
        return exercise.durationSeconds
    }

    func effectiveDisplayText(for exercise: Exercise) -> String {
        if exercise.exerciseType == .timed {
            let secs = effectiveDuration(for: exercise)
            let min = secs / 60
            let sec = secs % 60
            return min > 0 ? String(format: "%d:%02d", min, sec) : "\(sec)s"
        }
        return effectiveReps(for: exercise)
    }

    func setCustomValue(
        for exerciseName: String,
        skillID: String,
        reps: Int? = nil,
        durationSeconds: Int? = nil
    ) {
        if let existing = customization(for: exerciseName, skillID: skillID) {
            existing.customReps = reps
            existing.customDurationSeconds = durationSeconds
        } else {
            let new = ExerciseCustomization(
                exerciseName: exerciseName,
                skillID: skillID,
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
}
