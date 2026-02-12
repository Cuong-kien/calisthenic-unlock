import Foundation

struct Exercise: Identifiable, Hashable {
    let id: UUID
    let name: String
    let level: Level
    let description: String
    let imageName: String

    init(id: UUID = UUID(), name: String, level: Level, description: String, imageName: String = "figure.mixed.cardio") {
        self.id = id
        self.name = name
        self.level = level
        self.description = description
        self.imageName = imageName
    }
}
