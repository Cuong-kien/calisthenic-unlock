import Foundation

struct SkillGroup: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String
    let iconName: String
    let description: String
    let skillIDs: [String]
}
