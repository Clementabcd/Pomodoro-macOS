import SwiftUI

struct TimerView: View {
    @Bindable var timerVM: TimerViewModel
    @State private var showQuickAdjust = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                PhaseBadgeView(
                    phase: timerVM.currentPhase,
                    completedPomodoros: timerVM.completedPomodoros
                )
                .animation(.interpolatingSpring(mass: 0.8, stiffness: 80, damping: 12), value: timerVM.currentPhase)

                Spacer()

                Button(action: { showQuickAdjust.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.warmGray)
                        .frame(width: 28, height: 28)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.ultraThinMaterial).opacity(0.6)
                        }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showQuickAdjust) {
                    QuickTimeAdjustView(timerService: timerVM.timerService, settings: .shared)
                        .padding(16)
                }
            }
            .padding(.horizontal, 12)

            TimerRingView(
                progress: timerVM.progress,
                phase: timerVM.currentPhase,
                isRunning: timerVM.isRunning,
                formattedTime: timerVM.formattedTime,
                totalDuration: timerVM.formattedTotalDuration
            )

            if let goal = timerVM.activeGoal {
                GoalActiveCard(goal: goal, timerVM: timerVM)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            ControlButtonsView(
                phase: timerVM.currentPhase,
                isRunning: timerVM.isRunning,
                isPaused: timerVM.isPaused,
                onStart: { timerVM.start() },
                onPause: { timerVM.pause() },
                onReset: { timerVM.reset() },
                onSkip: { timerVM.skip() }
            )
            .animation(.interpolatingSpring(mass: 0.8, stiffness: 100, damping: 14), value: timerVM.isRunning)
        }
        .padding(.top, 8)
    }
}

// MARK: - Goal Active Card
struct GoalActiveCard: View {
    let goal: Goal
    let timerVM: TimerViewModel

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.sand)
                Text(goal.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                    .lineLimit(1)
                Spacer()
                Text(timerVM.formattedTime)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(timerVM.currentPhase.color)
                    .monospacedDigit()
                Button(action: {
                    timerVM.timerService.activeGoal = nil
                    timerVM.timerService.sessionDurationOverride = nil
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(Color.warmGray.opacity(0.5))
                        .frame(width: 16, height: 16)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.warmGray.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .help(loc("Remove goal"))
            }

            miniTimeline(goal: goal)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.sand.opacity(0.15), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func miniTimeline(goal: Goal) -> some View {
        let sessions = goal.focusSessionsNeeded
        let total = sessions * 2
        let completedSessions = min(timerVM.completedPomodoros, sessions)

        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { idx in
                let isFocus = idx % 2 == 0
                let sessionIdx = idx / 2
                let isLongBreak = !isFocus && (sessionIdx + 1) % 4 == 0
                let isCompleted = isFocus && sessionIdx < completedSessions
                let isCurrent = isFocus && sessionIdx == completedSessions && timerVM.currentPhase == .work

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(
                        isCompleted ? Color.sand.opacity(0.8) :
                        isCurrent ? Color.sand :
                        isFocus ? Color.sand.opacity(0.3) :
                        isLongBreak ? Color.stoneblue.opacity(0.4) : Color.sage.opacity(0.3)
                    )
                    .frame(height: 6)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
