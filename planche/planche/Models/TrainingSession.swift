import Foundation
import SwiftData

@Model
final class TrainingSession {
    var id: UUID = UUID()
    var skillID: String = ""
    var groupID: String = "planche"
    var date: Date = Date()
    var completed: Bool = false
    var duration: TimeInterval = 0

    var skill: Skill? {
        SkillCatalog.shared.skill(for: skillID)
    }

    init(skill: Skill, date: Date = Date(), completed: Bool = false, duration: TimeInterval = 0) {
        self.id = UUID()
        self.skillID = skill.id
        self.groupID = skill.groupID
        self.date = date
        self.completed = completed
        self.duration = duration
    }

    init(skillID: String, groupID: String = "planche", date: Date = Date(), completed: Bool = false, duration: TimeInterval = 0) {
        self.id = UUID()
        self.skillID = skillID
        self.groupID = groupID
        self.date = date
        self.completed = completed
        self.duration = duration
    }
}
