import Foundation
import SwiftData

@Model
final class StageProgress {
    var id: UUID = UUID()
    var exerciseName: String = ""
    var skillID: String = ""
    var stageIndex: Int = 0
    var currentValue: Int = 0
    var updatedAt: Date = Date()

    init(exerciseName: String, skillID: String, stageIndex: Int, currentValue: Int) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.skillID = skillID
        self.stageIndex = stageIndex
        self.currentValue = currentValue
        self.updatedAt = Date()
    }
}
