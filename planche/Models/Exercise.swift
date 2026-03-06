import Foundation

enum ExerciseType {
    case timed      // e.g. Plank 30s — shows countdown timer
    case repBased   // e.g. Push-up 12 reps — no timer, user controls pace
}

enum Difficulty: String, CaseIterable, Identifiable {
    case starter, standard, solid

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var stars: Int {
        switch self {
        case .starter: return 1
        case .standard: return 2
        case .solid: return 3
        }
    }
}

struct Exercise: Identifiable, Hashable {
    let id: UUID
    let name: String
    let level: Level
    let description: String
    let imageName: String
    let spriteConfig: SpriteConfig?
    let videoName: String?
    let reps: String
    let repsByDifficulty: [Difficulty: String]
    let durationSeconds: Int
    let exerciseType: ExerciseType
    let guide: String
    let sets: Int
    let stages: [ExerciseStage]?

    init(
        id: UUID = UUID(),
        name: String,
        level: Level,
        description: String,
        imageName: String = "figure.mixed.cardio",
        spriteConfig: SpriteConfig? = nil,
        videoName: String? = nil,
        reps: String = "10 rep",
        repsByDifficulty: [Difficulty: String] = [
            .starter: "8 rep",
            .standard: "10 rep",
            .solid: "12 rep"
        ],
        durationSeconds: Int = 30,
        exerciseType: ExerciseType = .repBased,
        guide: String = "",
        sets: Int = 3,
        stages: [ExerciseStage]? = nil
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.description = description
        self.imageName = imageName
        self.spriteConfig = spriteConfig
        self.videoName = videoName
        self.reps = reps
        self.repsByDifficulty = repsByDifficulty
        self.durationSeconds = durationSeconds
        self.exerciseType = exerciseType
        self.guide = guide
        self.sets = sets
        self.stages = stages
    }

    func reps(for difficulty: Difficulty) -> String {
        repsByDifficulty[difficulty] ?? reps
    }

    // Hashable conformance excluding dictionary
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
