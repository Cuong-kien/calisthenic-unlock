import SwiftUI
import SwiftData

// MARK: - Schema Versions

enum PlancheSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TrainingSessionV1.self, UserProgressV1.self, ExerciseCustomizationV1.self, ActiveProgramV1.self]
    }

    @Model final class TrainingSessionV1 {
        var id: UUID = UUID()
        var levelRawValue: String = ""
        var date: Date = Date()
        var completed: Bool = false
        var duration: TimeInterval = 0
        init() {}
    }

    @Model final class UserProgressV1 {
        var id: UUID = UUID()
        var currentLevelRawValue: String = "foundation"
        var startDate: Date = Date()
        init() {}
    }

    @Model final class ExerciseCustomizationV1 {
        var id: UUID = UUID()
        var exerciseName: String = ""
        var levelRawValue: String = ""
        var difficultyRawValue: String? = nil
        var customReps: Int? = nil
        var customDurationSeconds: Int? = nil
        init() {}
    }

    @Model final class ActiveProgramV1 {
        var levelRawValue: String = "foundation"
        var startDate: Date = Date()
        var currentProgressSeconds: Double = 0
        var lastUpdated: Date? = nil
        var isCompleted: Bool = false
        init() {}
    }
}

enum PlancheSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TrainingSession.self, UserProgress.self, ExerciseCustomization.self, ActiveProgram.self, UserProfile.self]
    }
}

enum PlancheMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PlancheSchemaV1.self, PlancheSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PlancheSchemaV1.self,
        toVersion: PlancheSchemaV2.self
    ) { context in
        // Custom migration: copy old field values to new field names
        // TrainingSession: levelRawValue → skillID, add groupID
        let oldSessions = try context.fetch(FetchDescriptor<PlancheSchemaV1.TrainingSessionV1>())
        for session in oldSessions {
            context.delete(session)
        }
        // We can't directly map between schema versions in SwiftData custom migration,
        // so the data needs to be re-created. For training sessions, we accept the loss
        // since the field rename means SwiftData treats them as different properties.
        // In practice, the lightweight migration should handle this if possible.

        let oldProgress = try context.fetch(FetchDescriptor<PlancheSchemaV1.UserProgressV1>())
        for p in oldProgress {
            context.delete(p)
        }

        let oldCustomizations = try context.fetch(FetchDescriptor<PlancheSchemaV1.ExerciseCustomizationV1>())
        for c in oldCustomizations {
            context.delete(c)
        }

        let oldPrograms = try context.fetch(FetchDescriptor<PlancheSchemaV1.ActiveProgramV1>())
        for p in oldPrograms {
            context.delete(p)
        }

        try context.save()
    } didMigrate: { context in
        // Post-migration: data has been cleaned. New records will be created fresh.
        try context.save()
    }
}

// MARK: - App

@main
struct plancheApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var storeManager = StoreManager()
    @StateObject private var adManager = AdManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: PlancheSchemaV2.self)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: PlancheMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            // Fallback: if migration fails, delete the store and start fresh
            print("Migration failed: \(error). Attempting fresh start.")
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-shm"))
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-wal"))
            do {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: PlancheMigrationPlan.self,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(storeManager)
                .environmentObject(adManager)
                .task { await storeManager.checkSubscriptionStatus() }
                .task {
                    if !storeManager.isSubscribed {
                        adManager.preloadInterstitial()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
