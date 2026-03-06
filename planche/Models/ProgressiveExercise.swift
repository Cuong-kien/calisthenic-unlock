import Foundation

// MARK: - ExerciseStage

struct ExerciseStage: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String
    let guide: String
    let reps: String
    let durationSeconds: Int
    let exerciseType: ExerciseType
    let spriteConfig: SpriteConfig?
    let nextStageCondition: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageName: String = "demo-exercise",
        guide: String = "",
        reps: String = "8 rep",
        durationSeconds: Int = 20,
        exerciseType: ExerciseType = .repBased,
        spriteConfig: SpriteConfig? = nil,
        nextStageCondition: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageName = imageName
        self.guide = guide
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.exerciseType = exerciseType
        self.spriteConfig = spriteConfig
        self.nextStageCondition = nextStageCondition
    }
}

