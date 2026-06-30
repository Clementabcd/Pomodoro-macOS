import Foundation

final class PersistenceService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var sessionsURL: URL {
        fileURL(for: "sessions.json")
    }

    private func fileURL(for fileName: String) -> URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("Pomodoro")
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent(fileName)
    }

    func loadSessions() -> [PomodoroSession] {
        guard let data = try? Data(contentsOf: sessionsURL),
              let sessions = try? decoder.decode([PomodoroSession].self, from: data)
        else { return [] }
        return sessions
    }

    func saveSession(_ session: PomodoroSession) {
        var sessions = loadSessions()
        sessions.append(session)
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: sessionsURL, options: .atomic)
    }

    func saveSessions(_ sessions: [PomodoroSession]) {
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: sessionsURL, options: .atomic)
    }

    func clearAll() {
        try? FileManager.default.removeItem(at: sessionsURL)
    }
}
