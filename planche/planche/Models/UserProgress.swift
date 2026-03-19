import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID = UUID()
    var currentSkillID: String = "foundation2"
    var startDate: Date = Date()

    var currentSkill: Skill? {
        SkillCatalog.shared.skill(for: currentSkillID)
    }

    init(currentSkillID: String = "foundation2", startDate: Date = Date()) {
        self.id = UUID()
        self.currentSkillID = currentSkillID
        self.startDate = startDate
    }
}
