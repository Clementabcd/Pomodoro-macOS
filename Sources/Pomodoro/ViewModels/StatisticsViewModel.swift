import Foundation

@Observable
final class StatisticsViewModel {
    private let persistence: PersistenceService
    private(set) var sessions: [PomodoroSession] = []

    init(persistence: PersistenceService = .init()) {
        self.persistence = persistence
        refresh()
    }

    func refresh() {
        sessions = persistence.loadSessions()
    }

    // MARK: - Today
    var todaySessions: [PomodoroSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startTime) && $0.isCompleted }
    }

    var todayFocusCount: Int {
        todaySessions.filter { $0.phase == .work }.count
    }

    var todayBreakCount: Int {
        todaySessions.filter { $0.phase != .work }.count
    }

    var todayFocusDuration: TimeInterval {
        todaySessions.filter { $0.phase == .work }.reduce(0) { $0 + $1.effectiveDuration }
    }

    var todayBreakDuration: TimeInterval {
        todaySessions.filter { $0.phase != .work }.reduce(0) { $0 + $1.effectiveDuration }
    }

    var todayDistractingDuration: TimeInterval {
        todaySessions.filter { $0.phase == .work }.reduce(0) { $0 + $1.distractingDuration }
    }

    var todayFocusScore: Int {
        let focus = todayFocusDuration
        let distract = todayDistractingDuration
        guard focus + distract > 0 else { return 100 }
        return Int((focus / (focus + distract)) * 100)
    }

    // MARK: - Week
    var weekFocusData: [(day: String, count: Int)] {
        Calendar.current.weekDates().map { date in
            let label = date.formatted(.dateTime.weekday(.abbreviated))
            let count = sessions.filter {
                Calendar.current.isDate($0.startTime, inSameDayAs: date) && $0.phase == .work && $0.isCompleted
            }.count
            return (label, count)
        }
    }

    var weekBreakData: [(day: String, count: Int)] {
        Calendar.current.weekDates().map { date in
            let label = date.formatted(.dateTime.weekday(.abbreviated))
            let count = sessions.filter {
                Calendar.current.isDate($0.startTime, inSameDayAs: date) && $0.phase != .work && $0.isCompleted
            }.count
            return (label, count)
        }
    }

    var weekAppData: [(appName: String, duration: TimeInterval)] {
        var appTotals: [String: TimeInterval] = [:]
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        for session in sessions where session.startTime >= weekStart && session.phase == .work {
            for usage in session.appUsage {
                appTotals[usage.appName, default: 0] += usage.duration
            }
        }
        return appTotals.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    // MARK: - All-time
    var totalSessions: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var totalFocusSessions: Int {
        sessions.filter { $0.isCompleted && $0.phase == .work }.count
    }

    var totalBreaks: Int {
        sessions.filter { $0.isCompleted && $0.phase != .work }.count
    }

    var totalFocusDuration: TimeInterval {
        sessions.filter { $0.isCompleted && $0.phase == .work }.reduce(0) { $0 + $1.effectiveDuration }
    }

    var totalBreakDuration: TimeInterval {
        sessions.filter { $0.isCompleted && $0.phase != .work }.reduce(0) { $0 + $1.effectiveDuration }
    }

    var totalDistractingDuration: TimeInterval {
        sessions.filter { $0.isCompleted && $0.phase == .work }.reduce(0) { $0 + $1.distractingDuration }
    }

    var overallFocusScore: Int {
        guard totalFocusDuration + totalDistractingDuration > 0 else { return 100 }
        return Int((totalFocusDuration / (totalFocusDuration + totalDistractingDuration)) * 100)
    }

    var topAppsAllTime: [(appName: String, duration: TimeInterval)] {
        var appTotals: [String: TimeInterval] = [:]
        for session in sessions where session.phase == .work {
            for usage in session.appUsage {
                appTotals[usage.appName, default: 0] += usage.duration
            }
        }
        return appTotals.sorted { $0.value > $1.value }.prefix(8).map { ($0.key, $0.value) }
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var count = 0
        var date = Date()
        while true {
            let hasSession = sessions.contains {
                calendar.isDate($0.startTime, inSameDayAs: date) && $0.phase == .work && $0.isCompleted
            }
            if hasSession {
                count += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return count
    }

    var dailyAverage: Double {
        let daysWithSessions = Set(sessions.filter { $0.isCompleted && $0.phase == .work }
            .map { Calendar.current.startOfDay(for: $0.startTime) })
        guard !daysWithSessions.isEmpty else { return 0 }
        return Double(totalFocusSessions) / Double(daysWithSessions.count)
    }

    var bestDayCount: Int {
        let calendar = Calendar.current
        var dayCounts: [Date: Int] = [:]
        for session in sessions where session.isCompleted && session.phase == .work {
            let day = calendar.startOfDay(for: session.startTime)
            dayCounts[day, default: 0] += 1
        }
        return dayCounts.values.max() ?? 0
    }

    var gradeBreakdown: [(grade: String, percentage: Int)] {
        let focus = totalFocusDuration
        let distract = totalDistractingDuration
        let total = focus + distract
        guard total > 0 else { return [("S", 0)] }
        let focusPct = Int((focus / total) * 100)
        return [
            ("Focus", focusPct),
            ("Distractions", 100 - focusPct)
        ]
    }
}

extension Calendar {
    func weekDates() -> [Date] {
        var dates: [Date] = []
        for i in (0..<7).reversed() {
            guard let date = date(byAdding: .day, value: -i, to: Date()) else { continue }
            dates.append(date)
        }
        return dates
    }
}
