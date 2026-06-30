import SwiftUI

struct MenuBarView: View {
    let timerService: TimerService
    private let settings: AppSettings
    @State private var showAdjuster = false

    init(timerService: TimerService = .init(), settings: AppSettings = .shared) {
        self.timerService = timerService
        self.settings = settings
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with phase
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(timerService.currentPhase.color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    PhaseIconView(phase: timerService.currentPhase, size: 12)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(timerService.currentPhase.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.warmWhite)
                    Text(String(format: loc("%d today"), timerService.completedPomodoros))
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                }

                Spacer()

                // Quick adjust button
                Button(action: { showAdjuster.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.warmGray)
                        .frame(width: 22, height: 22)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.warmGray.opacity(0.1)))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAdjuster) {
                    TimeAdjustView(timerService: timerService)
                        .frame(width: 200)
                        .padding(16)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // Timer display
            Text(timerService.formattedTime)
                .font(.system(size: 36, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerService.isRunning ? Color.warmWhite : Color.warmGray)
                .contentTransition(.numericText(countsDown: true))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

            Divider()
                .padding(.horizontal, 14)

            // Controls
            HStack(spacing: 12) {
                if timerService.isRunning {
                    controlButton(icon: "pause.fill", label: loc("Pause"), color: Color.sand) { timerService.pause() }
                    controlButton(icon: "stop.fill", label: loc("Stop"), color: Color.terracotta) { timerService.reset() }
                } else {
                    controlButton(icon: "play.fill", label: timerService.timeRemaining < timerService.totalDuration ? loc("Resume") : loc("Start"),
                                  color: Color.sage) { timerService.start() }
                    if timerService.timeRemaining < timerService.totalDuration {
                        controlButton(icon: "arrow.counterclockwise", label: loc("Reset"), color: Color.warmGray) { timerService.reset() }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // Distraction warning
            if timerService.isOnDistractingApp && timerService.isRunning {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 8))
                    Text(loc("Distracting app active"))
                        .font(.system(size: 8, design: .rounded))
                }
                .foregroundStyle(Color.terracotta)
                .padding(.horizontal, 14)
                .padding(.bottom, 6)
            }

            Divider()
                .padding(.horizontal, 14)

            // Bottom actions
            VStack(spacing: 0) {
                MenuBarAction(icon: "timer", label: loc("Show Pomodoro")) {
                    NSApp.activate(ignoringOtherApps: true)
                }
                MenuBarAction(icon: "xmark", label: loc("Quit")) {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(width: 210)
        .background(AmbientBackground())
    }

    private func controlButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundStyle(Color.warmWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                ZStack {
                    Capsule().fill(.ultraThinMaterial).opacity(0.8)
                    Capsule().fill(color.opacity(0.25))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Time Adjust Popover
struct TimeAdjustView: View {
    let timerService: TimerService
    @State private var editing = false
    @State private var editText = ""
    @FocusState private var isFocused: Bool
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 16) {
            Text(loc("Adjust Time"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmGray)

            // Time display
            if editing {
                TextField("", text: $editText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 40, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.warmWhite)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onSubmit(commitEdit)
                    .onAppear {
                        editText = timerService.formattedTime
                        isFocused = true
                    }
            } else {
                Text(timerService.formattedTime)
                    .font(.system(size: 40, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.warmWhite)
                    .scaleEffect(bounce ? 1.03 : 1)
                    .onTapGesture {
                        editText = timerService.formattedTime
                        withAnimation { editing = true }
                    }
            }

            // Preset buttons
            HStack(spacing: 8) {
                adjustPreset(icon: "minus", value: -300, label: "-5m")
                adjustPreset(icon: "minus", value: -60, label: "-1m")
                adjustPreset(icon: "plus", value: 60, label: "+1m")
                adjustPreset(icon: "plus", value: 300, label: "+5m")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func adjustPreset(icon: String, value: Double, label: String) -> some View {
        Button(action: {
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
                timerService.adjustTime(by: value)
                bounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { bounce = false }
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                Text(label)
                    .font(.system(size: 8, design: .rounded))
            }
            .foregroundStyle(Color.warmGray)
            .frame(width: 42, height: 36)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.warmGray.opacity(0.08))
            }
        }
        .buttonStyle(.plain)
    }

    private func commitEdit() {
        let parts = editText.split(separator: ":")
        if parts.count == 2,
           let mins = Int(parts[0]),
           let secs = Int(parts[1]),
           mins >= 0, secs >= 0, secs < 60 {
            let newTime = Double(mins * 60 + secs)
            let clamped = max(60, min(timerService.totalDuration, newTime))
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 80, damping: 12)) {
                timerService.timeRemaining = clamped
            }
        }
        withAnimation { editing = false }
    }
}

// MARK: - Menu Bar Action Row
struct MenuBarAction: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.warmGray)
                    .frame(width: 16)
                Text(label)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
