import SwiftUI

struct PhaseBadgeView: View {
    let phase: TimerPhase
    let completedPomodoros: Int

    @State private var animate = false
    @State private var pulseRing = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(phase.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(phase.color.opacity(pulseRing ? 0.4 : 0.1), lineWidth: 2)
                            .scaleEffect(pulseRing ? 1.15 : 1)
                    )

                Image(systemName: phase.icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(phase.tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(phase.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.warmWhite)

                if phase == .work {
                    Text(String(format: loc("%d sessions today"), completedPomodoros))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(phase.color.opacity(0.06))

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.glassHighlight, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.glassEdge, phase.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(animate ? 1 : 0.9)
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.interpolatingSpring(mass: 0.8, stiffness: 80, damping: 12)) {
                animate = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseRing = true
            }
        }
        .onChange(of: phase) { _, _ in
            withAnimation(.interpolatingSpring(mass: 0.8, stiffness: 80, damping: 12)) {
                animate = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(mass: 0.8, stiffness: 80, damping: 12)) {
                    animate = true
                }
            }
        }
    }
}
