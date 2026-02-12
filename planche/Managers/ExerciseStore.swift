import Foundation

struct ExerciseStore {
    static let shared = ExerciseStore()

    let exercises: [Level: [Exercise]]

    private init() {
        var all: [Level: [Exercise]] = [:]
        for level in Level.allCases {
            all[level] = (1...10).map { index in
                Exercise(
                    name: "\(level.displayName) Exercise \(index)",
                    level: level,
                    description: "This is exercise \(index) for the \(level.displayName) level. Perform this exercise with proper form and controlled movements.",
                    imageName: "figure.mixed.cardio"
                )
            }
        }
        exercises = all
    }

    func exercises(for level: Level) -> [Exercise] {
        exercises[level] ?? []
    }
}
