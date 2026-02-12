import Foundation
import SwiftData

@Model
final class TrainingSession {
    var id: UUID
    var levelRawValue: String
    var date: Date
    var completed: Bool

    var level: Level {
        get { Level(rawValue: levelRawValue) ?? .foundation }
        set { levelRawValue = newValue.rawValue }
    }

    init(level: Level, date: Date = Date(), completed: Bool = false) {
        self.id = UUID()
        self.levelRawValue = level.rawValue
        self.date = date
        self.completed = completed
    }
}
