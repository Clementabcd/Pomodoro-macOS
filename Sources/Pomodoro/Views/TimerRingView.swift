import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let phase: TimerPhase
    let isRunning: Bool
    let formattedTime: String
    let totalDuration: String

    @State private var appear = false
    @State private var breathe = false
    @State private var shimmer = false
    @State private var urgentPulse = false

    private let lineWidth: CGFloat = 12
    private let ringSize: CGFloat = 240

    private var isUrgent: Bool {
        isRunning && progress > 0.85
    }

    var body: some View {
        ZStack {
            // Ambient glow behind ring
            Circle()
                .fill(phase.glowColor.opacity(isUrgent ? 0.12 : 0.06))
                .frame(width: ringSize + 80, height: ringSize + 80)
                .blur(radius: 60)
                .scaleEffect(urgentPulse && isUrgent ? 1.08 : 1)
                .opacity(appear ? 1 : 0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: urgentPulse && isUrgent)

            // Outer glow ring
            Circle()
                .stroke(
                    phase.color.opacity(isRunning ? (isUrgent ? 0.35 : 0.2) : 0.08),
                    lineWidth: lineWidth + 6
                )
                .frame(width: ringSize + 20, height: ringSize + 20)
                .blur(radius: 16)
                .scaleEffect(breathe ? 1.025 : 1)
                .animation(
                    .easeInOut(duration: isUrgent ? 1.2 : 3).repeatForever(autoreverses: true),
                    value: breathe
                )

            // Track ring
            Circle()
                .stroke(Color(nsColor: .trackRing), lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)

            // Inner glow under progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    phase.color.opacity(isUrgent ? 0.25 : 0.15),
                    style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)
                .opacity(isRunning ? (isUrgent ? 0.8 : 0.6) : 0.2)

            // Shimmer overlay on progress ring
            if isRunning {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0), .white.opacity(0.15), .white.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth - 2, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(shimmer ? 360 : -360))
                    .animation(
                        .linear(duration: 3).repeatForever(autoreverses: false),
                        value: shimmer
                    )
            }

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    phase.tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.interpolatingSpring(mass: 1, stiffness: 80, damping: 15), value: progress)
                .warmGlow(color: phase.glowColor, radius: isUrgent ? 16 : 8)

            // Urgent border flash
            if isUrgent {
                Circle()
                    .stroke(
                        phase.glowColor.opacity(urgentPulse ? 0.3 : 0),
                        lineWidth: 2
                    )
                    .frame(width: ringSize + 4, height: ringSize + 4)
                    .blur(radius: 4)
            }

            // Inner content
            VStack(spacing: 6) {
                Text(formattedTime)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.interpolatingSpring(mass: 0.5, stiffness: 100, damping: 15), value: formattedTime)
                    .scaleEffect(isUrgent && urgentPulse ? 1.02 : 1)

                Text(totalDuration)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.warmGray)
                    .textCase(.uppercase)
                    .tracking(2)
            }

            // Breathing dot
            if isRunning {
                Circle()
                    .fill(phase.color)
                    .frame(width: 4, height: 4)
                    .offset(y: ringSize / 2 + 16)
                    .opacity(breathe ? 0.15 : 0.8)
            }
        }
        .scaleEffect(appear ? 1 : 0.92)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.interpolatingSpring(mass: 1, stiffness: 60, damping: 12)) {
                appear = true
            }
            breathe = true
            shimmer = true
        }
        .onChange(of: phase) { _, _ in
            withAnimation(.interpolatingSpring(mass: 1, stiffness: 60, damping: 12)) {
                appear = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.interpolatingSpring(mass: 1, stiffness: 60, damping: 12)) {
                    appear = true
                }
            }
        }
        .onChange(of: isUrgent) { _, urgent in
            if urgent {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    urgentPulse = true
                }
            } else {
                urgentPulse = false
            }
        }
    }
}
