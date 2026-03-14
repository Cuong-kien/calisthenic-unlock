import SwiftData
import Foundation

@Model
final class UserProfile {
    var name: String = ""
    var age: Int = 0
    var heightCm: Int = 0
    var weightKg: Int = 0
    var fitnessLevel: String = "beginner" // beginner | fundamental | mastery
    @Attribute(.externalStorage) var avatarData: Data? = nil

    /// Auth identity — links this profile to a specific Sign in with Apple user
    var authUserID: String = ""
    /// Auth provider: "apple" or "guest"
    var authProvider: String = ""
    /// Email from Sign in with Apple (only provided on first sign-in)
    var email: String = ""

    init() {}

    init(name: String, age: Int, heightCm: Int, weightKg: Int, fitnessLevel: String) {
        self.name = name
        self.age = age
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.fitnessLevel = fitnessLevel
    }
}
