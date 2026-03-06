import SwiftUI

enum Level: String, Codable, CaseIterable, Identifiable {
    case foundation
    case foundation2
    case tuckPlanche
    case advTuckPlanche
    case straddlePlanche
    case fullPlanche

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .foundation:    return "Base"
        case .foundation2:   return "Frog Stand"
        case .tuckPlanche:   return "Tuck Planche"
        case .advTuckPlanche: return "ADV Tuck Planche"
        case .straddlePlanche: return "Straddle Planche"
        case .fullPlanche:   return "Full Planche"
        }
    }

    var order: Int {
        switch self {
        case .foundation:    return 0
        case .foundation2:   return 1
        case .tuckPlanche:   return 2
        case .advTuckPlanche: return 3
        case .straddlePlanche: return 4
        case .fullPlanche:   return 5
        }
    }

    var color: Color {
        switch self {
        case .foundation:    return Color(hex: "#067D41")
        case .foundation2:   return Color(hex: "#067D41")
        case .tuckPlanche:   return Color(hex: "#6E47EF")
        case .advTuckPlanche: return Color(hex: "#E67E22")
        case .straddlePlanche: return Color(hex: "#A21832")
        case .fullPlanche:   return Color(hex: "#0D0D0D")
        }
    }

    var iconName: String {
        switch self {
        case .foundation:    return "figure.walk"
        case .foundation2:   return "figure.walk"
        case .tuckPlanche:   return "figure.strengthtraining.traditional"
        case .advTuckPlanche: return "figure.highintensity.intervaltraining"
        case .straddlePlanche: return "figure.martial.arts"
        case .fullPlanche:   return "crown.fill"
        }
    }

    var description: String {
        switch self {
        case .foundation:    return "Xây dựng sức mạnh nền tảng, chuẩn bị cho mọi skill sau này"
        case .foundation2:   return "The frog stand is a foundational, beginner-level calisthenics balance skill that builds strength in the shoulders, arms, and core."
        case .tuckPlanche:   return "The Tuck planche is a fundamental calisthenics skill body to the ground, supported by straight arms with knees tucked tightly to the chest."
        case .advTuckPlanche: return "Body horizontal with legs at 90-degree hip angle. Knees bent outward, no chest compression — more extended than basic tuck."
        case .straddlePlanche: return "Your entire body parallel to ground with legs straddled wide apart, held in perfect balance on straight extended arms."
        case .fullPlanche:   return "Body perfectly horizontal, supported only by straight arms. The legendary position that represents the peak of your Planche journey."
        }
    }

    var estimatedTime: String {
        switch self {
        case .foundation:    return "~23 min"
        case .foundation2:   return "~23 min"
        case .tuckPlanche:   return "~30 min"
        case .advTuckPlanche: return "~35 min"
        case .straddlePlanche: return "~40 min"
        case .fullPlanche:   return "~45 min"
        }
    }

    var equipment: String {
        switch self {
        case .foundation:    return "Parallettes"
        case .foundation2:   return "Parallettes"
        case .tuckPlanche:   return "Parallettes, Band"
        case .advTuckPlanche: return "Parallettes, Band"
        case .straddlePlanche: return "Parallettes"
        case .fullPlanche:   return "Parallettes"
        }
    }

    var categoryLabel: String {
        switch self {
        case .foundation:      return "STARTER"
        case .foundation2:     return "BEGINNER"
        case .tuckPlanche:     return "FUNDAMENTAL"
        case .advTuckPlanche:  return "ADVANCED"
        case .straddlePlanche: return "PROFESSIONAL"
        case .fullPlanche:     return "MASTERY"
        }
    }

    func levelIconImageName(active: Bool) -> String? {
        let suffix = active ? "active" : "deactive"
        switch self {
        case .foundation2:     return "icon-frog-stand-\(suffix)"
        case .tuckPlanche:     return "icon-tuck-planche-\(suffix)"
        case .advTuckPlanche:  return "icon-adv-tuck-planche-\(suffix)"
        case .straddlePlanche: return "icon-straddle-planche-\(suffix)"
        case .fullPlanche:     return "icon-full-planche-\(suffix)"
        default:               return nil
        }
    }

    var requirement: String? {
        switch self {
        case .foundation:    return nil
        case .foundation2:   return nil
        case .tuckPlanche:   return "You can hold a tuck planche for 10 seconds"
        case .advTuckPlanche: return "You can hold an advanced tuck planche for 10 seconds"
        case .straddlePlanche: return "You can hold a straddle planche for 5 seconds"
        case .fullPlanche:   return "You can hold a full planche for 3 seconds"
        }
    }

    var previousLevel: Level? {
        switch self {
        case .foundation:    return nil
        case .foundation2:   return nil
        case .tuckPlanche:   return .foundation2
        case .advTuckPlanche: return .tuckPlanche
        case .straddlePlanche: return .advTuckPlanche
        case .fullPlanche:   return .straddlePlanche
        }
    }

    var difficultyStars: Double {
        switch self {
        case .foundation:      return 1.0
        case .foundation2:     return 1.0
        case .tuckPlanche:     return 3.0
        case .advTuckPlanche:  return 3.5
        case .straddlePlanche: return 4.0
        case .fullPlanche:     return 5.0
        }
    }

    static let sessionsToUnlock = 5
}

extension Color {
    static let trainingBlue = Color(hex: "#035CD5")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
