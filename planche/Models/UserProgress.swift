import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID = UUID()
    var currentLevelRawValue: String = Level.foundation.rawValue
    var startDate: Date = Date()

    var currentLevel: Level {
        get { Level(rawValue: currentLevelRawValue) ?? .foundation }
        set { currentLevelRawValue = newValue.rawValue }
    }

    init(currentLevel: Level = .foundation, startDate: Date = Date()) {
        self.id = UUID()
        self.currentLevelRawValue = currentLevel.rawValue
        self.startDate = startDate
    }
}
