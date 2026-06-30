import SwiftUI

struct TimerMenuLabel: View {
    let timerService: TimerService

    @State private var pulse = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(timerService.isRunning ? timerService.currentPhase.color : Color.warmGray)
                .frame(width: 6, height: 6)
                .opacity(timerService.isRunning ? (pulse ? 0.4 : 1) : 0.5)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }

            Text(timerService.formattedTime)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerService.isRunning ? Color.warmWhite : Color.warmGray)
        }
        .fixedSize()
    }
}
