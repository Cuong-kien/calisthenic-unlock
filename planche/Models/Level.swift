import SwiftUI

enum Level: String, Codable, CaseIterable, Identifiable {
    case foundation
    case beginner
    case advanced
    case solid
    case mastery

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .foundation: return "Foundation"
        case .beginner: return "Beginner"
        case .advanced: return "Advanced"
        case .solid: return "Solid"
        case .mastery: return "Mastery"
        }
    }

    var order: Int {
        switch self {
        case .foundation: return 0
        case .beginner: return 1
        case .advanced: return 2
        case .solid: return 3
        case .mastery: return 4
        }
    }

    var color: Color {
        switch self {
        case .foundation: return .green
        case .beginner: return .blue
        case .advanced: return .orange
        case .solid: return .purple
        case .mastery: return .red
        }
    }

    var iconName: String {
        switch self {
        case .foundation: return "figure.walk"
        case .beginner: return "figure.run"
        case .advanced: return "figure.strengthtraining.traditional"
        case .solid: return "figure.highintensity.intervaltraining"
        case .mastery: return "figure.martial.arts"
        }
    }

    var previousLevel: Level? {
        switch self {
        case .foundation: return nil
        case .beginner: return .foundation
        case .advanced: return .beginner
        case .solid: return .advanced
        case .mastery: return .solid
        }
    }

    static let sessionsToUnlock = 5
}
