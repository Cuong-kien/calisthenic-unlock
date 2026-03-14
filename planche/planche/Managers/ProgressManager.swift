import Foundation
import SwiftData

struct ProgressManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func isSkillProgressComplete(_ skillID: String) -> Bool {
        if let program = activeProgram(), program.skillID == skillID {
            return program.isCompleted
        }
        return false
    }

    func isSkillRecommended(_ skillID: String) -> Bool {
        guard let skill = SkillCatalog.shared.skill(for: skillID),
              let prevID = skill.recommendedPreviousSkillID else {
            return true
        }
        return isSkillProgressComplete(prevID)
    }

    func currentSkill() -> Skill? {
        activeProgram()?.skill
    }

    func completeSession(for skill: Skill, duration: TimeInterval = 0) {
        let session = TrainingSession(skill: skill, completed: true, duration: duration)
        modelContext.insert(session)
        try? modelContext.save()
    }

    func startDate() -> Date {
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try? modelContext.fetch(descriptor).first {
            return progress.startDate
        }
        let sessionDescriptor = FetchDescriptor<TrainingSession>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        if let earliest = try? modelContext.fetch(sessionDescriptor).first {
            return earliest.date
        }
        return Date()
    }

    func dayCount() -> Int {
        let days = Calendar.current.dateComponents([.day], from: startDate(), to: Date()).day ?? 0
        return days + 1
    }

    func totalTrainingTime() -> TimeInterval {
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.completed == true }
        )
        guard let sessions = try? modelContext.fetch(descriptor) else { return 0 }
        return sessions.reduce(0) { $0 + $1.duration }
    }

    func totalSessionCount() -> Int {
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.completed == true }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func overallProgress() -> Double {
        guard let program = activeProgram(),
              let skill = program.skill else { return 0 }
        return min(program.currentProgressSeconds / skill.progressGoalSeconds, 1.0) * 100
    }

    func resetProgress() {
        do {
            try modelContext.delete(model: TrainingSession.self)
            try modelContext.delete(model: UserProgress.self)
            try modelContext.delete(model: ExerciseCustomization.self)
            try modelContext.delete(model: ActiveProgram.self)
            try modelContext.save()
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }

    // MARK: - Active Program

    func activeProgram() -> ActiveProgram? {
        let descriptor = FetchDescriptor<ActiveProgram>()
        return try? modelContext.fetch(descriptor).first
    }

    func setActiveProgram(skill: Skill) {
        if let existing = activeProgram() { modelContext.delete(existing) }
        let program = ActiveProgram(skill: skill)
        modelContext.insert(program)
        try? modelContext.save()
    }

    func clearActiveProgram() {
        if let existing = activeProgram() {
            modelContext.delete(existing)
            try? modelContext.save()
        }
    }

    func updateProgress(seconds: Double) {
        guard let program = activeProgram(),
              let skill = program.skill else { return }
        program.currentProgressSeconds = seconds
        program.lastUpdated = Date()
        program.isCompleted = seconds >= skill.progressGoalSeconds
        try? modelContext.save()
    }

    func progressPercent() -> Double {
        guard let program = activeProgram(),
              let skill = program.skill else { return 0 }
        return min(program.currentProgressSeconds / skill.progressGoalSeconds, 1.0) * 100
    }

    func trainingDates() -> Set<DateComponents> {
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.completed == true }
        )
        guard let sessions = try? modelContext.fetch(descriptor) else { return [] }
        let cal = Calendar.current
        return Set(sessions.map { cal.dateComponents([.year, .month, .day], from: $0.date) })
    }

    func activeProgramSessionCount() -> Int {
        guard let program = activeProgram() else { return 0 }
        let sid = program.skillID
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.skillID == sid && $0.completed == true }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func activeProgramTrainingTime() -> TimeInterval {
        guard let program = activeProgram() else { return 0 }
        let sid = program.skillID
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.skillID == sid && $0.completed == true }
        )
        guard let sessions = try? modelContext.fetch(descriptor) else { return 0 }
        return sessions.reduce(0) { $0 + $1.duration }
    }
}
