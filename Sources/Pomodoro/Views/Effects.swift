import SwiftUI

// MARK: - Completion Celebration
struct CelebrationView: View {
    let phase: TimerPhase
    @State private var particles: [Particle] = []
    @State private var burst = false

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: CGFloat
        var rotation: Double
        var speed: Double
        var color: Color
        var symbol: String
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: particle.symbol)
                    .font(.system(size: 10))
                    .foregroundStyle(particle.color)
                    .rotationEffect(.degrees(particle.rotation))
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                burst = true
            }
            createBurst()
        }
    }

    private func createBurst() {
        let centerX: CGFloat = 250
        let centerY: CGFloat = 180
        let symbols = ["circle.fill", "star.fill", "diamond.fill", "leaf", "star", "moon.stars", "flame", "bolt"]
        let colors: [Color] = [.sand, .terracotta, .sage, .sky, .moss, .stoneblue]

        for i in 0..<24 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...220)
            let delay = Double(i) * 0.025

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    particles.append(Particle(
                        x: centerX + cos(angle) * distance,
                        y: centerY + sin(angle) * distance,
                        scale: CGFloat.random(in: 0.3...1.4),
                        opacity: 1,
                        rotation: Double.random(in: 0...360),
                        speed: Double.random(in: 0.5...1.5),
                        color: colors.randomElement() ?? .sand,
                        symbol: symbols.randomElement() ?? "circle.fill"
                    ))
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                for i in particles.indices {
                    particles[i].opacity = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                particles.removeAll()
            }
        }
    }
}

// MARK: - Focus Grade Toast
struct FocusGradeToast: View {
    let score: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: gradeIcon)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 1) {
                Text(String(format: loc("Focus Score: %@"), gradeLetter))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Text(String(format: loc("%d%% focus — %@"), score, gradeMessage))
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.glassEdge, lineWidth: 0.5)
                )
        }
    }

    private var gradeLetter: String {
        switch score {
        case 95...: "S"
        case 85..<95: "A"
        case 70..<85: "B"
        case 50..<70: "C"
        default: "D"
        }
    }

    private var gradeIcon: String {
        switch score {
        case 95...: "star.fill"
        case 85..<95: "hand.thumbsup.fill"
        case 70..<85: "exclamationmark.circle"
        default: "arrow.down.circle"
        }
    }

    private var gradeMessage: String {
        switch score {
        case 95...: loc("Perfect session!")
        case 85..<95: loc("Great concentration")
        case 70..<85: loc("Some distractions")
        default: loc("Try to minimize distractions")
        }
    }
}

// MARK: - Hover Glow Card
struct HoverGlassCard<Content: View>: View {
    @State private var isHovered = false
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.sand.opacity(isHovered ? 0.08 : 0.03))

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.glassHighlight, .clear, .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.glassEdge,
                                Color.glassHighlight,
                                .clear,
                                isHovered ? Color.sand.opacity(0.15) : Color.glassHighlight,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(isHovered ? 0.2 : 0.12), radius: isHovered ? 40 : 24, y: isHovered ? 20 : 12)
            .shadow(color: Color.sand.opacity(isHovered ? 0.06 : 0.03), radius: isHovered ? 80 : 40, y: isHovered ? 40 : 20)
            .scaleEffect(isHovered ? 1.01 : 1)
            .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 18), value: isHovered)
            .onHover { hovered in
                withAnimation(.interpolatingSpring(mass: 0.8, stiffness: 180, damping: 16)) {
                    isHovered = hovered
                }
            }
    }
}

// MARK: - Staggered Entrance
struct StaggeredEntrance<Content: View>: View {
    let index: Int
    @ViewBuilder let content: Content
    @State private var appeared = false

    var body: some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .scaleEffect(appeared ? 1 : 0.95)
            .blur(radius: appeared ? 0 : 4)
            .animation(
                .interpolatingSpring(mass: 0.8, stiffness: 80, damping: 14)
                    .delay(Double(index) * 0.08),
                value: appeared
            )
            .onAppear { appeared = true }
    }
}

// MARK: - Count Up Animation
struct CountUpView: View {
    let target: Int
    let label: String
    let icon: String
    let color: Color

    @State private var count = 0

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color.opacity(0.7))

            Text("\(count)")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.7))
        }
        .onAppear {
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 60, damping: 12)) {
                count = target
            }
        }
        .onChange(of: target) { _, new in
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 60, damping: 12)) {
                count = new
            }
        }
    }
}

// MARK: - Smooth Progress Ring
struct ProgressRing: View {
    let progress: CGFloat
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .animation(.interpolatingSpring(mass: 0.8, stiffness: 60, damping: 12), value: progress)
    }
}
