import Foundation
import SwiftData

@Model
final class TrainingSession {
    var id: UUID = UUID()
    var levelRawValue: String = ""
    var date: Date = Date()
    var completed: Bool = false
    var duration: TimeInterval = 0

    var level: Level {
        get { Level(rawValue: levelRawValue) ?? .foundation }
        set { levelRawValue = newValue.rawValue }
    }

    init(level: Level, date: Date = Date(), completed: Bool = false, duration: TimeInterval = 0) {
        self.id = UUID()
        self.levelRawValue = level.rawValue
        self.date = date
        self.completed = completed
        self.duration = duration
    }
}
