import Foundation

enum ExerciseType {
    case timed      // e.g. Plank 30s — shows countdown timer
    case repBased   // e.g. Push-up 12 reps — no timer, user controls pace
}

enum ExerciseCategory: String, Codable {
    case supplementary
    case specialized
}

struct Exercise: Identifiable, Hashable {
    let id: UUID
    let name: String
    let skillID: String
    let description: String
    let imageName: String
    let spriteConfig: SpriteConfig?
    let videoName: String?
    let reps: String
    let durationSeconds: Int
    let exerciseType: ExerciseType
    let guide: String
    let sets: Int
    let stages: [ExerciseStage]?
    let summary: String
    let category: ExerciseCategory

    init(
        id: UUID = UUID(),
        name: String,
        skillID: String,
        description: String,
        imageName: String = "figure.mixed.cardio",
        spriteConfig: SpriteConfig? = nil,
        videoName: String? = nil,
        reps: String = "10 rep",
        durationSeconds: Int = 30,
        exerciseType: ExerciseType = .repBased,
        guide: String = "",
        sets: Int = 3,
        stages: [ExerciseStage]? = nil,
        summary: String = "",
        category: ExerciseCategory = .supplementary
    ) {
        self.id = id
        self.name = name
        self.skillID = skillID
        self.description = description
        self.imageName = imageName
        self.spriteConfig = spriteConfig
        self.videoName = videoName
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.exerciseType = exerciseType
        self.guide = guide
        self.sets = sets
        self.stages = stages
        self.summary = summary
        self.category = category
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
