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

    func completeSession(for level: Level, duration: TimeInterval = 0) {
        let session = TrainingSession(level: level, completed: true, duration: duration)
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

    func overallProgress() -> Double {
        let totalPossible = Level.allCases.count * Level.sessionsToUnlock
        guard totalPossible > 0 else { return 0 }
        var totalCompleted = 0
        for level in Level.allCases {
            totalCompleted += completedSessionCount(for: level)
        }
        return Double(totalCompleted) / Double(totalPossible) * 100
    }

    func resetProgress() {
        do {
            try modelContext.delete(model: TrainingSession.self)
            try modelContext.delete(model: UserProgress.self)
            try modelContext.delete(model: ExerciseCustomization.self)
            try modelContext.save()
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }
}
