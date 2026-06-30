import Foundation
import AppKit

@Observable
final class AppTracker {
    private(set) var currentApp: (bundleId: String, appName: String)?
    private var usageLog: [Date: (bundleId: String, appName: String)] = [:]
    private var appAccumulated: [String: (name: String, duration: TimeInterval, bundleId: String)] = [:]
    private var lastSwitchDate: Date?
    private var isActive = false
    private var lastNotificationDate: Date?

    private let distractingCategories: [AppCategory] = [.game, .social, .entertainment]

    static let commonApps: [String: (name: String, category: AppCategory)] = [
        "com.apple.Safari": ("Safari", .browser),
        "com.google.Chrome": ("Chrome", .browser),
        "org.mozilla.firefox": ("Firefox", .browser),
        "com.brave.Browser": ("Brave", .browser),
        "com.microsoft.edgemac": ("Edge", .browser),
        "com.apple.mail": ("Mail", .communication),
        "com.apple.iChat": ("Messages", .communication),
        "com.apple.facetime": ("FaceTime", .communication),
        "com.tinyspeck.slackmacgap": ("Slack", .communication),
        "com.microsoft.VSCode": ("VS Code", .development),
        "com.apple.dt.Xcode": ("Xcode", .development),
        "com.jetbrains.intellij": ("IntelliJ", .development),
        "com.apple.Terminal": ("Terminal", .development),
        "com.apple.ActivityMonitor": ("Activity Monitor", .utility),
        "com.apple.finder": ("Finder", .utility),
        "com.apple.systempreferences": ("System Settings", .utility),
        "com.spotify.client": ("Spotify", .music),
        "com.apple.Music": ("Music", .music),
        "com.apple.Notes": ("Notes", .productivity),
        "com.apple.iCal": ("Calendar", .productivity),
        "com.apple.Preview": ("Preview", .utility),
        "com.apple.TextEdit": ("TextEdit", .utility),
        "com.apple.Photos": ("Photos", .entertainment),
        "com.apple.TV": ("TV", .entertainment),
        "net.whatsapp.WhatsApp": ("WhatsApp", .social),
        "com.twitter.X": ("X", .social),
        "com.apple.reminders": ("Reminders", .productivity),
        "com.apple.Pages": ("Pages", .productivity),
        "com.apple.Numbers": ("Numbers", .productivity),
        "com.apple.Keynote": ("Keynote", .productivity),
        "com.figma.Desktop": ("Figma", .design),
        "com.adobe.Photoshop": ("Photoshop", .design),
        "com.apple.preview": ("Preview", .utility),
    ]

    func startTracking() {
        guard !isActive else { return }
        isActive = true
        usageLog = [:]
        appAccumulated = [:]
        lastSwitchDate = Date()
        recordCurrentApp()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    func stopTracking() -> [AppUsage] {
        isActive = false
        NSWorkspace.shared.notificationCenter.removeObserver(
            self,
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        recordCurrentApp()

        return appAccumulated.map { _, data in
            AppUsage(
                bundleId: data.bundleId,
                appName: data.name,
                duration: data.duration,
                isDistracting: category(for: data.bundleId).isDistracting,
                category: category(for: data.bundleId)
            )
        }
    }

    var focusScore: FocusScore {
        let total = appAccumulated.values.reduce(0) { $0 + $1.duration }
        let distracting = appAccumulated.values
            .filter { category(for: $0.bundleId).isDistracting }
            .reduce(0) { $0 + $1.duration }
        let distractionCount = appAccumulated.values
            .filter { category(for: $0.bundleId).isDistracting && $0.duration > 5 }
            .count
        return FocusScore(
            total: Int(total),
            distractingDuration: distracting,
            focusDuration: total - distracting,
            distractionCount: distractionCount
        )
    }

    var isOnDistractingApp: Bool {
        guard let app = currentApp else { return false }
        return category(for: app.bundleId).isDistracting
    }

    func checkAndNotifyDistraction() -> Bool {
        guard isActive, isOnDistractingApp else { return false }
        let now = Date()
        if let last = lastNotificationDate, now.timeIntervalSince(last) < 120 { return false }
        lastNotificationDate = now
        return true
    }

    @objc private func activeAppChanged(_ notification: Notification) {
        recordCurrentApp()
        lastSwitchDate = Date()

        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            let bundleId = app.bundleIdentifier ?? "unknown"
            let appName = app.localizedName ?? bundleId
            currentApp = (bundleId, appName)
        }
    }

    private func recordCurrentApp() {
        guard let lastSwitch = lastSwitchDate, let app = currentApp else { return }
        let elapsed = Date().timeIntervalSince(lastSwitch)
        guard elapsed > 0.5 else { return }

        if var existing = appAccumulated[app.bundleId] {
            existing.duration += elapsed
            appAccumulated[app.bundleId] = existing
        } else {
            appAccumulated[app.bundleId] = (app.appName, elapsed, app.bundleId)
        }
    }

    func category(for bundleId: String) -> AppCategory {
        Self.commonApps[bundleId]?.category ?? {
            let name = bundleId.lowercased()
            if name.contains("game") || name.contains("unity") || name.contains("steam") { return .game }
            if name.contains("social") || name.contains("chat") { return .social }
            if name.contains("browser") || name.contains("safari") || name.contains("chrome") || name.contains("firefox") { return .browser }
            if name.contains("music") || name.contains("spotify") { return .music }
            if name.contains("code") || name.contains("terminal") || name.contains("xcode") { return .development }
            return .other
        }()
    }
}
