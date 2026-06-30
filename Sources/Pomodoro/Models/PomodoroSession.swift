import Foundation

struct PomodoroSession: Identifiable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var phase: TimerPhase
    var isCompleted = false
    var appUsage: [AppUsage] = []
    var focusScore: Int?
    var goalTitle: String?

    var effectiveDuration: TimeInterval {
        guard let endTime else { return duration }
        return endTime.timeIntervalSince(startTime)
    }

    var distractingDuration: TimeInterval {
        appUsage.filter(\.isDistracting).reduce(0) { $0 + $1.duration }
    }

    var topApps: [AppUsage] {
        appUsage.sorted { $0.duration > $1.duration }.prefix(5).map { $0 }
    }
}
