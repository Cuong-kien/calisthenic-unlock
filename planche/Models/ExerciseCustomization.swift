import Foundation
import SwiftData

@Model
final class ExerciseCustomization {
    var id: UUID = UUID()
    var exerciseName: String = ""
    var levelRawValue: String = ""
    var difficultyRawValue: String? = nil
    var customReps: Int? = nil
    var customDurationSeconds: Int? = nil

    init(
        exerciseName: String,
        level: Level,
        difficulty: Difficulty? = nil,
        customReps: Int? = nil,
        customDurationSeconds: Int? = nil
    ) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.levelRawValue = level.rawValue
        self.difficultyRawValue = difficulty?.rawValue
        self.customReps = customReps
        self.customDurationSeconds = customDurationSeconds
    }
}
