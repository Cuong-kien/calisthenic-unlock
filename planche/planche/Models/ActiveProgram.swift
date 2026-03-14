import Foundation
import SwiftData
import SwiftUI

@Model
final class ActiveProgram {
    var skillID: String = "foundation"
    var groupID: String = "planche"
    var startDate: Date = Date()
    var currentProgressSeconds: Double = 0
    var lastUpdated: Date? = nil
    var isCompleted: Bool = false

    var skill: Skill? {
        SkillCatalog.shared.skill(for: skillID)
    }

    init(skill: Skill) {
        self.skillID = skill.id
        self.groupID = skill.groupID
        self.startDate = Date()
        self.currentProgressSeconds = 0
        self.lastUpdated = nil
        self.isCompleted = false
    }

    init(skillID: String = "foundation", groupID: String = "planche") {
        self.skillID = skillID
        self.groupID = groupID
        self.startDate = Date()
        self.currentProgressSeconds = 0
        self.lastUpdated = nil
        self.isCompleted = false
    }
}
