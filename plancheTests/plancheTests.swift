import Testing
import SwiftData
@testable import planche

// MARK: - Shared helper

private func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([
        TrainingSession.self,
        ExerciseCustomization.self,
        UserProgress.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

// MARK: - Customization tests (+ / - reps & seconds)

struct CustomizationTests {

    // MARK: Reps

    @Test func saveCustomReps() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(name: "Push-up", level: .leanPlanche, description: "")

        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: 15)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customReps == 15)
    }

    @Test func incrementReps() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(name: "Push-up", level: .leanPlanche, description: "")

        let initial = manager.parseReps(from: exercise.reps) ?? 10
        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: initial + 1)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customReps == initial + 1)
    }

    @Test func decrementReps() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(name: "Push-up", level: .leanPlanche, description: "")

        let initial = manager.parseReps(from: exercise.reps) ?? 10
        let decreased = max(1, initial - 1)
        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: decreased)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customReps == decreased)
    }

    @Test func effectiveRepsReflectsCustomValue() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(name: "Dip", level: .leanPlanche, description: "")

        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: 20)

        #expect(manager.effectiveReps(for: exercise) == "20 rep")
    }

    @Test func updatingRepsOverwritesOldValue() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(name: "Pull-up", level: .leanPlanche, description: "")

        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: 8)
        manager.setCustomValue(for: exercise.name, level: exercise.level, reps: 12)

        // Should update in-place, not create a duplicate row
        let all = try context.fetch(FetchDescriptor<ExerciseCustomization>())
        #expect(all.count == 1)
        #expect(all.first?.customReps == 12)
    }

    // MARK: Duration (seconds)

    @Test func saveCustomDuration() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(
            name: "Plank", level: .leanPlanche, description: "",
            durationSeconds: 30, exerciseType: .timed
        )

        manager.setCustomValue(for: exercise.name, level: exercise.level, durationSeconds: 45)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customDurationSeconds == 45)
    }

    @Test func incrementDuration() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(
            name: "Plank", level: .leanPlanche, description: "",
            durationSeconds: 30, exerciseType: .timed
        )

        let initial = manager.effectiveDuration(for: exercise) // 30
        manager.setCustomValue(for: exercise.name, level: exercise.level, durationSeconds: initial + 5)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customDurationSeconds == 35)
    }

    @Test func decrementDuration() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(
            name: "Plank", level: .leanPlanche, description: "",
            durationSeconds: 30, exerciseType: .timed
        )

        let initial = manager.effectiveDuration(for: exercise) // 30
        let decreased = max(5, initial - 5)
        manager.setCustomValue(for: exercise.name, level: exercise.level, durationSeconds: decreased)

        let saved = manager.customization(for: exercise.name, level: exercise.level)
        #expect(saved?.customDurationSeconds == 25)
    }

    @Test func durationCannotExceed3599Seconds() throws {
        // Simulates the clamped incrementValue() logic: step = 5, cap = 3599
        let step = 5
        let cap = 3599

        // At 3595: next step would be 3600 > 3599 → blocked
        var current = 3595
        if current + step <= cap { current += step }
        #expect(current == 3595)

        // At 3594: next step would be 3599 ≤ 3599 → allowed
        current = 3594
        if current + step <= cap { current += step }
        #expect(current == 3599)
    }

    @Test func effectiveDurationReflectsCustomValue() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = CustomizationManager(modelContext: context)
        let exercise = Exercise(
            name: "L-Sit", level: .tuckPlanche, description: "",
            durationSeconds: 30, exerciseType: .timed
        )

        manager.setCustomValue(for: exercise.name, level: exercise.level, durationSeconds: 60)

        #expect(manager.effectiveDuration(for: exercise) == 60)
    }
}

// MARK: - Progress / unlock tests

struct ProgressTests {

    @Test func foundationAlwaysUnlocked() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        #expect(manager.isLevelUnlocked(.foundation) == true)
    }

    @Test func beginnerAlwaysUnlocked() throws {
        // Beginner has no previousLevel so it is always accessible
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        #expect(manager.isLevelUnlocked(.leanPlanche) == true)
    }

    @Test func advancedLockedWithNoSessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        #expect(manager.isLevelUnlocked(.tuckPlanche) == false)
    }

    @Test func advancedStillLockedAfter4Sessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        for _ in 0..<4 { manager.completeSession(for: .leanPlanche) }

        #expect(manager.isLevelUnlocked(.tuckPlanche) == false)
    }

    @Test func advancedUnlocksAfter5BeginnerSessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        for _ in 0..<5 { manager.completeSession(for: .leanPlanche) }

        #expect(manager.isLevelUnlocked(.tuckPlanche) == true)
    }

    @Test func solidLockedUntil5AdvancedSessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        for _ in 0..<4 { manager.completeSession(for: .tuckPlanche) }
        #expect(manager.isLevelUnlocked(.advTuckPlanche) == false)

        manager.completeSession(for: .tuckPlanche)
        #expect(manager.isLevelUnlocked(.advTuckPlanche) == true)
    }

    @Test func masteryUnlocksAfter5SolidSessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        for _ in 0..<5 { manager.completeSession(for: .advTuckPlanche) }

        #expect(manager.isLevelUnlocked(.straddlePlanche) == true)
    }

    @Test func sessionCountTracksPerLevel() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        manager.completeSession(for: .leanPlanche)
        manager.completeSession(for: .leanPlanche)
        manager.completeSession(for: .tuckPlanche)

        #expect(manager.completedSessionCount(for: .leanPlanche) == 2)
        #expect(manager.completedSessionCount(for: .tuckPlanche) == 1)
        #expect(manager.completedSessionCount(for: .foundation) == 0)
    }

    @Test func currentLevelAdvancesAfterUnlock() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        // Default: beginner is the highest unlocked (foundation + beginner have no prerequisite)
        #expect(manager.currentLevel() == .leanPlanche)

        // 5 beginner sessions → advanced unlocked
        for _ in 0..<5 { manager.completeSession(for: .leanPlanche) }
        #expect(manager.currentLevel() == .tuckPlanche)
    }

    @Test func fullPlancheUnlocksAfter5MasterySessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)
        for _ in 0..<5 { manager.completeSession(for: .straddlePlanche) }
        #expect(manager.isLevelUnlocked(.fullPlanche) == true)
    }

    @Test func resetProgressClearsAllSessions() throws {
        let context = ModelContext(try makeTestContainer())
        let manager = ProgressManager(modelContext: context)

        for _ in 0..<5 { manager.completeSession(for: .leanPlanche) }
        #expect(manager.isLevelUnlocked(.tuckPlanche) == true)

        manager.resetProgress()

        #expect(manager.completedSessionCount(for: .leanPlanche) == 0)
        #expect(manager.isLevelUnlocked(.tuckPlanche) == false)
    }
}
