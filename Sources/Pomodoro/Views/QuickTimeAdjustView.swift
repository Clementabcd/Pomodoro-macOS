import SwiftUI

struct QuickTimeAdjustView: View {
    let timerService: TimerService
    let settings: AppSettings

    @State private var editing = false
    @State private var editText = ""
    @FocusState private var isFocused: Bool
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.warmGray)
                Text(loc("Quick Adjust"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }

            // Focus time
            VStack(spacing: 4) {
                Text(loc("Focus"))
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1)

                if editing {
                    TextField("", text: $editText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
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
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.warmWhite)
                        .scaleEffect(bounce ? 1.04 : 1)
                        .onTapGesture {
                            editText = timerService.formattedTime
                            withAnimation { editing = true }
                        }
                }
            }

            // Presets row
            HStack(spacing: 6) {
                ForEach([-10, -5, -1, 1, 5, 10], id: \.self) { mins in
                    Button(action: { adjust(by: Double(mins) * 60) }) {
                        Text(mins > 0 ? "+\(mins)" : "\(mins)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                            .frame(width: 32, height: 26)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(mins > 0 ? Color.sand.opacity(0.1) : Color.terracotta.opacity(0.1))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .foregroundStyle(Color(nsColor: .thinSeparator))

            // Break info
            HStack {
                Image(systemName: "leaf")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.sage)
                Text(String(format: loc("Break: %d min"), Int(settings.shortBreakDuration / 60)))
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.6))
                Spacer()
                Text(loc("Auto-adjusted"))
                    .font(.system(size: 7, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.3))
            }

            Text(loc("Changes apply immediately to the current session."))
                .font(.system(size: 7, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.3))
        }
        .frame(width: 220)
    }

    private func adjust(by seconds: Double) {
        withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
            timerService.adjustTime(by: seconds)
            bounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { bounce = false }
        }
    }

    private func commitEdit() {
        let parts = editText.split(separator: ":")
        if parts.count == 2,
           let mins = Int(parts[0]),
           let secs = Int(parts[1]),
           mins >= 0, secs >= 0, secs < 60 {
            let newTime = Double(mins * 60 + secs)
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 80, damping: 12)) {
                timerService.timeRemaining = max(60, newTime)
            }
        }
        withAnimation { editing = false }
    }
}
