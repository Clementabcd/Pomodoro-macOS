import Foundation
import SwiftUI

@Observable
final class AppSettings: Codable {
    var workDuration: Double = 25 * 60
    var shortBreakDuration: Double = 5 * 60
    var longBreakDuration: Double = 15 * 60
    var longBreakInterval: Int = 4
    var dailyGoal: Int = 8

    var enableNotifications = true
    var enableSounds = true
    var enableAmbientMusic = true
    var autoStartBreaks = false
    var autoStartWork = false
    var enableMenuBarTimer = true
    var dockBadge = true

    var soundTheme: SoundTheme = .classic
    var customSoundPath: String?
    var glassStyle: GlassStyle = .ultraThin
    var animationSpeed: AnimationSpeed = .normal

    var trackApps = true
    var detectDistractions = true
    var distractionNotification = true
    var focusScoreEnabled = true
    var hasSeenOnboarding = false

    nonisolated(unsafe) static let shared = AppSettings()

    private init() {
        load()
    }

    func duration(for phase: TimerPhase) -> Double {
        switch phase {
        case .work: workDuration
        case .shortBreak: shortBreakDuration
        case .longBreak: longBreakDuration
        }
    }
}

enum AnimationSpeed: String, Codable, CaseIterable {
    case reduced, normal, smooth

    var label: String {
        switch self {
        case .reduced: loc("Reduced")
        case .normal: loc("Normal")
        case .smooth: loc("Smooth")
        }
    }

    var duration: Double {
        switch self {
        case .reduced: 0.15
        case .normal: 0.35
        case .smooth: 0.6
        }
    }
}

enum SoundTheme: String, Codable, CaseIterable {
    case classic, digital, zen, nature

    var label: String {
        switch self {
        case .classic: loc("Classic Bell")
        case .digital: loc("Digital")
        case .zen: loc("Zen Gong")
        case .nature: loc("Nature")
        }
    }
}

enum GlassStyle: String, Codable, CaseIterable {
    case ultraThin, thin, regular, thick, ultraThick, hudWindow

    var label: String {
        switch self {
        case .ultraThin: loc("Ultra Thin")
        case .thin: loc("Thin")
        case .regular: loc("Regular")
        case .thick: loc("Thick")
        case .ultraThick: loc("Ultra Thick")
        case .hudWindow: loc("HUD")
        }
    }

    var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        case .hudWindow: .ultraThinMaterial
        }
    }

    var visualEffectMaterial: NSVisualEffectView.Material {
        switch self {
        case .ultraThin: .hudWindow
        case .thin: .windowBackground
        case .regular: .contentBackground
        case .thick: .headerView
        case .ultraThick: .titlebar
        case .hudWindow: .hudWindow
        }
    }
}

extension AppSettings {
    private static let key = "com.pomodoro.settings"

    func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data)
        else { return }
        workDuration = decoded.workDuration
        shortBreakDuration = decoded.shortBreakDuration
        longBreakDuration = decoded.longBreakDuration
        longBreakInterval = decoded.longBreakInterval
        dailyGoal = decoded.dailyGoal
        enableNotifications = decoded.enableNotifications
        enableSounds = decoded.enableSounds
        enableAmbientMusic = decoded.enableAmbientMusic
        autoStartBreaks = decoded.autoStartBreaks
        autoStartWork = decoded.autoStartWork
        enableMenuBarTimer = decoded.enableMenuBarTimer
        dockBadge = decoded.dockBadge
        soundTheme = decoded.soundTheme
        customSoundPath = decoded.customSoundPath
        glassStyle = decoded.glassStyle
        animationSpeed = decoded.animationSpeed
        trackApps = decoded.trackApps
        detectDistractions = decoded.detectDistractions
        distractionNotification = decoded.distractionNotification
        focusScoreEnabled = decoded.focusScoreEnabled
        hasSeenOnboarding = decoded.hasSeenOnboarding
    }
}
