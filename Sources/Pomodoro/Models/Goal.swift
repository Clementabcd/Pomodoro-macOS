import Foundation

struct Goal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var estimatedMinutes: Int
    var createdAt = Date()
    var isCompleted = false

    var focusSessionsNeeded: Int {
        let sessions = Int(ceil(Double(estimatedMinutes) / 25.0))
        return max(sessions, 1)
    }

    var breaksNeeded: Int {
        let s = focusSessionsNeeded
        return s > 1 ? s : 0
    }

    var totalEstimatedMinutes: Int {
        let s = focusSessionsNeeded
        guard s > 1 else { return estimatedMinutes }
        let longBreaks = s / 4
        let shortBreaks = s - longBreaks
        return estimatedMinutes + shortBreaks * 5 + longBreaks * 15
    }

    var formattedEstimate: String {
        let hours = totalEstimatedMinutes / 60
        let mins = totalEstimatedMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)min"
        }
        return "\(mins)min"
    }
}
