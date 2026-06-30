import SwiftUI

struct ControlButtonsView: View {
    let phase: TimerPhase
    let isRunning: Bool
    let isPaused: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void

    @State private var startScale = 1.0
    @State private var secondaryOpacity = 1.0

    var body: some View {
        HStack(spacing: 16) {
            LiquidButton(
                icon: "arrow.counterclockwise",
                label: loc("Reset"),
                action: onReset,
                phase: phase,
                isActive: isPaused || isRunning,
                size: .small
            )
            .opacity(secondaryOpacity)

            if isRunning {
                PrimaryButton(
                    icon: "pause.fill",
                    label: loc("Pause"),
                    action: onPause,
                    phase: phase
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .scaleEffect(startScale)
            } else {
                PrimaryButton(
                    icon: "play.fill",
                    label: isPaused ? loc("Resume") : loc("Start"),
                    action: onStart,
                    phase: phase,
                    isActive: !isPaused
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .scaleEffect(startScale)
            }

            LiquidButton(
                icon: "forward.fill",
                label: loc("Skip"),
                action: onSkip,
                phase: phase,
                isActive: isRunning || isPaused,
                size: .small
            )
            .opacity(secondaryOpacity)
        }
        .onChange(of: isRunning) { _, running in
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
                startScale = running ? 0.97 : 1
                secondaryOpacity = running ? 1 : 0.6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
                    startScale = 1
                }
            }
        }
    }
}
