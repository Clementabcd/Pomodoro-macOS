import SwiftUI

@Observable
final class TimerViewModel {
    var timerService: TimerService

    private let settings: AppSettings

    var currentPhase: TimerPhase { timerService.currentPhase }
    var timeRemaining: Double { timerService.timeRemaining }
    var totalDuration: Double { timerService.totalDuration }
    var isRunning: Bool { timerService.isRunning }
    var progress: Double { timerService.progress }
    var formattedTime: String { timerService.formattedTime }
    var accentColor: Color { timerService.accentColor }
    var completedPomodoros: Int { timerService.completedPomodoros }
    var activeGoal: Goal? { timerService.activeGoal }
    var formattedTotalDuration: String {
        let mins = Int(totalDuration) / 60
        return "\(mins) min"
    }

    init(timerService: TimerService = .init(),
         settings: AppSettings = .shared) {
        self.timerService = timerService
        self.settings = settings
    }

    func start() { timerService.start() }
    func pause() { timerService.pause() }
    func reset() { timerService.reset() }
    func skip() { timerService.skip() }
    func setPhase(_ phase: TimerPhase) { timerService.setPhase(phase) }

    var isPaused: Bool { !isRunning && timeRemaining < totalDuration }
    var isIdle: Bool { !isRunning && timeRemaining >= totalDuration }
}
