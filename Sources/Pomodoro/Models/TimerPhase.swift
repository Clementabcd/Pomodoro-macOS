import SwiftUI
import AppKit

enum TimerPhase: String, Codable, CaseIterable {
    case work
    case shortBreak
    case longBreak

    var label: String {
        switch self {
        case .work: loc("Focus")
        case .shortBreak: loc("Short break")
        case .longBreak: loc("Long break")
        }
    }

    var icon: String {
        switch self {
        case .work: "timer"
        case .shortBreak: "leaf"
        case .longBreak: "moon.haze"
        }
    }

    var tint: LinearGradient {
        switch self {
        case .work:
            LinearGradient(colors: [Color.sand, Color.terracotta], startPoint: .bottomLeading, endPoint: .topTrailing)
        case .shortBreak:
            LinearGradient(colors: [Color.sage, Color.moss], startPoint: .bottomLeading, endPoint: .topTrailing)
        case .longBreak:
            LinearGradient(colors: [Color.sky, Color.stoneblue], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
    }

    var color: Color {
        switch self {
        case .work: Color.sand
        case .shortBreak: Color.sage
        case .longBreak: Color.sky
        }
    }

    var glowColor: Color {
        switch self {
        case .work: Color.terracotta
        case .shortBreak: Color.moss
        case .longBreak: Color.stoneblue
        }
    }

    var next: TimerPhase {
        switch self {
        case .work: .shortBreak
        case .shortBreak, .longBreak: .work
        }
    }
}

// MARK: - Dynamic NSColor helpers
extension NSColor {
    static var warmWhite: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1)
                : NSColor(red: 0.16, green: 0.14, blue: 0.13, alpha: 1)
        }
    }

    static var warmGray: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.71, green: 0.67, blue: 0.63, alpha: 1)
                : NSColor(red: 0.50, green: 0.46, blue: 0.42, alpha: 1)
        }
    }

    static var creamBg: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1)
                : NSColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
        }
    }

    static var deepWarm: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.16, green: 0.14, blue: 0.13, alpha: 1)
                : NSColor(red: 0.88, green: 0.84, blue: 0.78, alpha: 1)
        }
    }

    static var warmBlack: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                : NSColor(red: 0.90, green: 0.86, blue: 0.80, alpha: 1)
        }
    }

    static var sand: NSColor {
        NSColor(red: 0.77, green: 0.65, blue: 0.52, alpha: 1)
    }

    static var softSand: NSColor {
        NSColor(red: 0.85, green: 0.75, blue: 0.62, alpha: 1)
    }

    static var cream: NSColor {
        NSColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
    }

    static var glassHighlightColor: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white.withAlphaComponent(0.08)
                : NSColor.black.withAlphaComponent(0.04)
        }
    }

    static var glassEdgeColor: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white.withAlphaComponent(0.18)
                : NSColor.black.withAlphaComponent(0.08)
        }
    }

    static var trackRing: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white.withAlphaComponent(0.06)
                : NSColor.black.withAlphaComponent(0.06)
        }
    }

    static var thinSeparator: NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor.white.withAlphaComponent(0.06)
                : NSColor.black.withAlphaComponent(0.08)
        }
    }
}

// MARK: - Warm cream palette
extension Color {
    static let sand = Color(red: 0.77, green: 0.65, blue: 0.52)
    static let softSand = Color(red: 0.85, green: 0.75, blue: 0.62)
    static let terracotta = Color(red: 0.65, green: 0.49, blue: 0.42)
    static let sage = Color(red: 0.56, green: 0.66, blue: 0.54)
    static let moss = Color(red: 0.48, green: 0.58, blue: 0.45)
    static let sky = Color(red: 0.54, green: 0.66, blue: 0.77)
    static let stoneblue = Color(red: 0.46, green: 0.58, blue: 0.71)

    static let cream = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let creamWhite = Color(red: 0.97, green: 0.95, blue: 0.91)

    static var warmWhite: Color { Color(nsColor: .warmWhite) }
    static var warmGray: Color { Color(nsColor: .warmGray) }
    static var warmBlack: Color { Color(nsColor: .warmBlack) }
    static var deepWarm: Color { Color(nsColor: .deepWarm) }
    static var creamBg: Color { Color(nsColor: .creamBg) }

    static var glassHighlight: Color { Color(nsColor: .glassHighlightColor) }
    static var glassEdge: Color { Color(nsColor: .glassEdgeColor) }
}
