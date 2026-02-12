import Foundation
import SwiftData

@Observable
class ProgressManager {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func completedSessionCount(for level: Level) -> Int {
        let rawValue = level.rawValue
        let descriptor = FetchDescriptor<TrainingSession>(
            predicate: #Predicate { $0.levelRawValue == rawValue && $0.completed == true }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func isLevelUnlocked(_ level: Level) -> Bool {
        guard let previous = level.previousLevel else { return true }
        return completedSessionCount(for: previous) >= Level.sessionsToUnlock
    }

    func currentLevel() -> Level {
        for level in Level.allCases.reversed() {
            if isLevelUnlocked(level) {
                return level
            }
        }
        return .foundation
    }

    func completeSession(for level: Level) {
        let session = TrainingSession(level: level, completed: true)
        modelContext.insert(session)
        try? modelContext.save()
    }

    func resetProgress() {
        do {
            try modelContext.delete(model: TrainingSession.self)
            try modelContext.delete(model: UserProgress.self)
            try modelContext.save()
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }
}
