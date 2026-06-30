import SwiftUI

// MARK: - Natural Glass Background
struct NaturalGlassBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material

    init(material: NSVisualEffectView.Material = .hudWindow) {
        self.material = material
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}

// MARK: - Warm Cream Ambient Background
struct AmbientBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            NaturalGlassBackground()

            Color.creamBg.opacity(0.85)

            RadialGradient(
                colors: [Color.cream.opacity(0.12), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )

            RadialGradient(
                colors: [Color.sand.opacity(0.07), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 600
            )
            .opacity(animate ? 1 : 0.4)
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)

            RadialGradient(
                colors: [Color.sky.opacity(0.04), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .opacity(animate ? 0.6 : 1)
            .animation(.easeInOut(duration: 14).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Liquid Glass Card
struct LiquidCard<Content: View>: View {
    let cornerRadius: CGFloat
    let depth: CGFloat
    @ViewBuilder let content: Content

    init(
        cornerRadius: CGFloat = 24,
        depth: CGFloat = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.depth = depth
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.sand.opacity(0.06))

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
                            colors: [Color.glassEdge, Color.glassHighlight, .clear, Color.glassHighlight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.15 * depth), radius: 30 * depth, y: 15 * depth)
            .shadow(color: Color.sand.opacity(0.04 * depth), radius: 60 * depth, y: 30 * depth)
    }
}

// MARK: - Glass Button (Liquid Orb)
struct LiquidButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    var phase: TimerPhase = .work
    var isActive: Bool = true
    var size: ControlSize = .regular

    enum ControlSize {
        case small, regular, large

        var padding: CGFloat {
            switch self {
            case .small: 8
            case .regular: 14
            case .large: 18
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: 12
            case .regular: 16
            case .large: 20
            }
        }

        var font: Font {
            switch self {
            case .small: .system(size: 11, weight: .medium)
            case .regular: .system(size: 13, weight: .medium)
            case .large: .system(size: 15, weight: .semibold)
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .semibold))
                Text(label)
                    .font(size.font)
            }
            .foregroundStyle(isActive ? Color.warmWhite : Color.warmGray)
            .padding(.horizontal, size.padding * 1.5)
            .padding(.vertical, size.padding)
            .background {
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)

                    Capsule()
                        .fill(phase.tint.opacity(isActive ? 0.2 : 0.05))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(isActive ? 0.15 : 0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(isActive ? 0.25 : 0.08),
                                .white.opacity(isActive ? 0.05 : 0.02),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: phase.color.opacity(isActive ? 0.2 : 0), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .opacity(isActive ? 1 : 0.4)
    }
}

// MARK: - Primary Action Button
struct PrimaryButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    var phase: TimerPhase = .work
    var isActive: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color.warmWhite)
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .background {
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)

                    Capsule()
                        .fill(phase.tint.opacity(0.35))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: phase.glowColor.opacity(0.3), radius: 20, y: 8)
            .shadow(color: phase.glowColor.opacity(0.15), radius: 40, y: 16)
        }
        .buttonStyle(.plain)
        .opacity(isActive ? 1 : 0.5)
        .keyboardShortcut(.space, modifiers: [])
    }
}

// MARK: - Glow Modifier
struct WarmGlow: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.35), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.15), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func warmGlow(color: Color, radius: CGFloat = 12) -> some View {
        modifier(WarmGlow(color: color, radius: radius))
    }
}

// MARK: - Phase Icon with natural animation
struct PhaseIconView: View {
    let phase: TimerPhase
    var size: CGFloat = 20

    @State private var breathe = false

    var body: some View {
        Image(systemName: phase.icon)
            .font(.system(size: size, weight: .light))
            .foregroundStyle(phase.tint)
            .scaleEffect(breathe ? 1.06 : 1)
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: breathe)
            .onAppear { breathe = true }
    }
}

// MARK: - Phase Indicator
struct PhaseIndicator: View {
    let phase: TimerPhase
    let completedPomodoros: Int

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(phase.tint.opacity(0.15))
                    .frame(width: 36, height: 36)

                PhaseIconView(phase: phase, size: 16)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(phase.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.warmWhite)

                if phase == .work {
                    Text(String(format: loc("%d sessions today"), completedPomodoros))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                }
            }
        }
    }
}
