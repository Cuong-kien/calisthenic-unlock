import Foundation

struct Skill: Identifiable, Hashable, Codable {
    let id: String
    let groupID: String
    let displayName: String
    let categoryLabel: String
    let iconName: String
    let description: String
    let estimatedTime: String
    let equipment: String
    let difficultyStars: Double
    let order: Int
    let progressGoalSeconds: Double
    let progressRequirements: [String]
    let skillPrerequisites: [String]
    let requirement: String?
    let requiresSubscription: Bool
    let recommendedPreviousSkillID: String?
    let activeIconImageName: String?
    let deactiveIconImageName: String?

    var progressGoalDescription: String { "\(Int(progressGoalSeconds))s hold" }

    func skillIconImageName(active: Bool) -> String? {
        active ? activeIconImageName : deactiveIconImageName
    }
}
