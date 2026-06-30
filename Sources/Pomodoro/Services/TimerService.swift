import Foundation
import Combine
import UserNotifications
import SwiftUI
import AppKit

@Observable
final class TimerService {
    var currentPhase: TimerPhase = .work
    var timeRemaining: Double
    var isRunning = false
    var completedPomodoros = 0
    var consecutivePomodoros = 0
    var currentSessionStart: Date?
    var currentSessionId: UUID?
    var lastDistractionWarning: Date?
    var activeGoal: Goal?
    var sessionDurationOverride: Double?

    private var timerCancellable: AnyCancellable?
    private let settings: AppSettings
    private let notificationService: NotificationService
    private let persistence: PersistenceService
    private let appTracker = AppTracker()

    var totalDuration: Double {
        if currentPhase == .work, let override = sessionDurationOverride {
            return override
        }
        return settings.duration(for: currentPhase)
    }

    var progress: Double {
        1 - (timeRemaining / totalDuration)
    }

    var formattedTime: String {
        let mins = Int(timeRemaining) / 60
        let secs = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    var accentColor: Color {
        currentPhase.color
    }

    var currentFocusScore: FocusScore? {
        settings.trackApps ? appTracker.focusScore : nil
    }

    var isOnDistractingApp: Bool {
        appTracker.isOnDistractingApp
    }

    init(settings: AppSettings = .shared,
         notificationService: NotificationService = .init(),
         persistence: PersistenceService = .init()) {
        self.settings = settings
        self.notificationService = notificationService
        self.persistence = persistence
        self.timeRemaining = settings.duration(for: .work)
        startIdleReminder()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        currentSessionStart = Date()
        currentSessionId = UUID()

        if settings.trackApps && currentPhase == .work {
            appTracker.startTracking()
        }

        stopIdleReminder()

        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
        startIdleReminder()
    }

    func reset() {
        pause()
        if settings.trackApps { _ = appTracker.stopTracking() }
        timeRemaining = totalDuration
        currentSessionStart = nil
        currentSessionId = nil
        activeGoal = nil
        sessionDurationOverride = nil
    }

    func skip() {
        pause()
        if settings.trackApps { _ = appTracker.stopTracking() }
        completePhase()
    }

    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 0.1
        }
        if timeRemaining <= 0 {
            pause()
            completePhase()
        }

        if settings.detectDistractions && currentPhase == .work && appTracker.checkAndNotifyDistraction() {
            let appName = appTracker.currentApp?.appName ?? "a distracting app"
            notificationService.sendNotification(
                title: loc("Heads up!"),
                body: String(format: loc("You're on %@ during focus time."), appName)
            )
        }
    }

    private func completePhase() {
        let usage = settings.trackApps && currentPhase == .work ? appTracker.stopTracking() : []
        let score = settings.focusScoreEnabled && currentPhase == .work ? appTracker.focusScore.percentage : nil

        let session = PomodoroSession(
            id: currentSessionId ?? UUID(),
            startTime: currentSessionStart ?? Date(),
            endTime: Date(),
            duration: totalDuration,
            phase: currentPhase,
            isCompleted: true,
            appUsage: usage,
            focusScore: score,
            goalTitle: activeGoal?.title
        )
        persistence.saveSession(session)

        if currentPhase == .work {
            completedPomodoros += 1
            consecutivePomodoros += 1
            checkGoalCompletion()
        }

        notificationService.sendNotification(
            title: phaseCompletionTitle(),
            body: phaseCompletionBody()
        )

        if settings.enableSounds {
            playPhaseSound()
        }

        advancePhase()
    }

    private func phaseCompletionTitle() -> String {
        switch currentPhase {
        case .work:
            if let score = currentFocusScore, score.percentage >= 85 {
                return String(format: loc("Great focus! %@ score"), score.grade)
            }
            return loc("Focus session complete!")
        case .shortBreak: return loc("Break's over!")
        case .longBreak: return loc("Long break complete!")
        }
    }

    private func phaseCompletionBody() -> String {
        switch currentPhase {
        case .work: return String(format: loc("Time for a %@ break."), settings.shortBreakDuration.formattedMinute)
        case .shortBreak: return loc("Ready to focus again?")
        case .longBreak: return loc("Ready for another round?")
        }
    }

    private func advancePhase() {
        if currentPhase == .work {
            if consecutivePomodoros >= settings.longBreakInterval {
                currentPhase = .longBreak
                consecutivePomodoros = 0
            } else {
                currentPhase = .shortBreak
            }
        } else {
            currentPhase = .work
        }
        timeRemaining = totalDuration

        let shouldAutoStart = (currentPhase == .work && settings.autoStartWork)
            || (currentPhase != .work && settings.autoStartBreaks)
        if shouldAutoStart {
            start()
        }
    }

    func setPhase(_ phase: TimerPhase) {
        pause()
        if settings.trackApps && currentPhase == .work { _ = appTracker.stopTracking() }
        currentPhase = phase
        timeRemaining = totalDuration
    }

    func adjustTime(by delta: Double) {
        timeRemaining = max(60, timeRemaining + delta)
    }

    // MARK: - Sound

    private func playPhaseSound() {
        if let path = settings.customSoundPath, let url = URL(string: path) {
            if let sound = NSSound(contentsOf: url, byReference: true) {
                sound.play()
                return
            }
        }
        let soundName: String
        switch settings.soundTheme {
        case .classic: soundName = "Purr"
        case .digital: soundName = "Pop"
        case .zen:     soundName = "Tink"
        case .nature:  soundName = "Bottle"
        }
        NSSound(named: soundName)?.play()
    }

    // MARK: - Goal auto-completion

    private func checkGoalCompletion() {
        guard let goal = activeGoal, currentPhase == .work else { return }
        if completedPomodoros >= goal.focusSessionsNeeded {
            activeGoal?.isCompleted = true
            notificationService.sendNotification(
                title: loc("Goal complete!"),
                body: String(format: loc("You finished \"%@\" — %d min of work."), goal.title, goal.estimatedMinutes)
            )
        }
    }

    // MARK: - Idle reminder

    private var idleTimer: DispatchSourceTimer?
    private let idleReminderInterval: TimeInterval = 15 * 60 // 15 min

    func startIdleReminder() {
        stopIdleReminder()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + idleReminderInterval, repeating: idleReminderInterval)
        timer.setEventHandler { [weak self] in
            guard let self, !self.isRunning else { return }
            self.notificationService.sendNotification(
                title: loc("Time to focus?"),
                body: loc("Your Pomodoro timer has been idle for a while. Start a session!")
            )
        }
        timer.resume()
        idleTimer = timer
    }

    func stopIdleReminder() {
        idleTimer?.cancel()
        idleTimer = nil
    }
}

extension TimeInterval {
    var formattedMinute: String {
        let mins = Int(self) / 60
        return "\(mins) \(loc("min"))"
    }
}
