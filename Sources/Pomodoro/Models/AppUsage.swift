import Foundation

struct AppUsage: Identifiable, Codable {
    var id = UUID()
    var bundleId: String
    var appName: String
    var duration: TimeInterval
    var isDistracting: Bool
    var category: AppCategory
}

enum AppCategory: String, Codable, CaseIterable {
    case productivity, communication, development, design
    case browser, entertainment, game, social, music
    case utility, other

    var label: String {
        switch self {
        case .productivity: "Productivity"
        case .communication: "Communication"
        case .development: "Development"
        case .design: "Design"
        case .browser: "Browser"
        case .entertainment: "Entertainment"
        case .game: "Game"
        case .social: "Social"
        case .music: "Music"
        case .utility: "Utility"
        case .other: "Other"
        }
    }

    var isDistracting: Bool {
        switch self {
        case .entertainment, .game, .social: true
        case .browser: true
        default: false
        }
    }
}

struct FocusScore {
    let total: Int
    let distractingDuration: TimeInterval
    let focusDuration: TimeInterval
    let distractionCount: Int

    var percentage: Int {
        guard focusDuration + distractingDuration > 0 else { return 100 }
        return Int((focusDuration / (focusDuration + distractingDuration)) * 100)
    }

    var grade: String {
        switch percentage {
        case 95...100: "S"
        case 85..<95: "A"
        case 70..<85: "B"
        case 50..<70: "C"
        default: "D"
        }
    }
}
