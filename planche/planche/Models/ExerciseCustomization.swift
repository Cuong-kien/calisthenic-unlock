import Foundation
import SwiftData

@Model
final class ExerciseCustomization {
    var id: UUID = UUID()
    var exerciseName: String = ""
    var skillID: String = ""
    var difficultyRawValue: String? = nil
    var customReps: Int? = nil
    var customDurationSeconds: Int? = nil

    init(
        exerciseName: String,
        skillID: String,
        customReps: Int? = nil,
        customDurationSeconds: Int? = nil
    ) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.skillID = skillID
        self.difficultyRawValue = nil
        self.customReps = customReps
        self.customDurationSeconds = customDurationSeconds
    }
}
