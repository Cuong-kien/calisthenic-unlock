import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var currentLevelRawValue: String

    var currentLevel: Level {
        get { Level(rawValue: currentLevelRawValue) ?? .foundation }
        set { currentLevelRawValue = newValue.rawValue }
    }

    init(currentLevel: Level = .foundation) {
        self.id = UUID()
        self.currentLevelRawValue = currentLevel.rawValue
    }
}
