import Foundation

struct SkillCatalog {
    static let shared = SkillCatalog()

    let groups: [SkillGroup]
    private let skillMap: [String: Skill]
    private let exerciseMap: [String: [Exercise]]

    init() {
        // Aggregate all groups
        let allGroups = [Self.plancheGroup]
        self.groups = allGroups

        // Build skill lookup
        var sMap: [String: Skill] = [:]
        for skill in Self.plancheSkills {
            sMap[skill.id] = skill
        }
        self.skillMap = sMap

        // Build exercise lookup
        self.exerciseMap = Self.plancheExercises
    }

    func skill(for id: String) -> Skill? {
        skillMap[id]
    }

    func exercises(for skillID: String) -> [Exercise] {
        exerciseMap[skillID] ?? []
    }

    func skills(in groupID: String) -> [Skill] {
        guard let group = groups.first(where: { $0.id == groupID }) else { return [] }
        return group.skillIDs.compactMap { skillMap[$0] }
    }

    func allSkills() -> [Skill] {
        groups.flatMap { skills(in: $0.id) }
    }

    func nextSkill(after skillID: String) -> Skill? {
        for group in groups {
            let ids = group.skillIDs
            guard let idx = ids.firstIndex(of: skillID), idx + 1 < ids.count else { continue }
            return skillMap[ids[idx + 1]]
        }
        return nil
    }

    func group(for skillID: String) -> SkillGroup? {
        guard let skill = skillMap[skillID] else { return nil }
        return groups.first(where: { $0.id == skill.groupID })
    }
}
