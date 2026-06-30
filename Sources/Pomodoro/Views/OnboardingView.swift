import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(loc("Skip")) {
                    complete()
                }
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.warmGray)
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .opacity(currentPage < pages.count - 1 ? 1 : 0)
            }

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(0..<pages.count, id: \.self) { idx in
                        pages[idx]
                            .frame(width: geo.size.width)
                    }
                }
                .offset(x: -CGFloat(currentPage) * geo.size.width)
                .animation(.interpolatingSpring(mass: 0.6, stiffness: 80, damping: 14), value: currentPage)
            }

            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { idx in
                    Capsule()
                        .fill(currentPage == idx ? Color.sand : Color.warmGray.opacity(0.2))
                        .frame(width: currentPage == idx ? 20 : 6, height: 6)
                        .animation(.interpolatingSpring(mass: 0.6, stiffness: 100, damping: 12), value: currentPage)
                }
            }
            .padding(.bottom, 20)

            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    complete()
                }
            }) {
                HStack(spacing: 6) {
                    Text(currentPage < pages.count - 1 ? loc("Continue") : loc("Get Started"))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.warmWhite)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(Color.sand.opacity(0.25))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.sand.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 32)
        }
        .frame(width: 420, height: 520)
        .background(AmbientBackground())
        .clipped()
    }

    private func complete() {
        settings.hasSeenOnboarding = true
        settings.save()
        dismiss()
    }

    private var pages: [AnyView] {
        [welcomePage, setupPage, readyPage]
    }

    // MARK: - Welcome Page
    private var welcomePage: AnyView {
        AnyView(
            VStack(spacing: 20) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.sand.opacity(0.12))
                        .frame(width: 80, height: 80)

                    Image(systemName: "timer")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.cream, Color.sand], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                VStack(spacing: 8) {
                    Text(loc("Welcome to Pomodoro"))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.warmWhite)

                    Text(loc("A gentle focus timer that helps you work in flow, one session at a time."))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }

                Spacer()

                cyclePreview
                    .padding(.bottom, 20)
            }
        )
    }

    private var cyclePreview: some View {
        HStack(spacing: 12) {
            phaseDot(icon: "timer", color: Color.sand, label: loc("Focus"))
            arrow
            phaseDot(icon: "leaf", color: Color.sage, label: loc("Short break"))
            arrow
            phaseDot(icon: "timer", color: Color.sand, label: loc("Focus"))
            arrow
            phaseDot(icon: "moon.haze", color: Color.stoneblue, label: loc("Long break"))
        }
    }

    private func phaseDot(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.6))
        }
        .frame(width: 52)
    }

    private var arrow: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 8, weight: .semibold))
            .foregroundStyle(Color.warmGray.opacity(0.3))
    }

    // MARK: - Quick Setup Page
    private var setupPage: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 16) {
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.sand)
                    Text(loc("Your Preferences"))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.warmWhite)
                }

                Text(loc("Set your session lengths to get started. You can change these anytime in Settings."))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.warmGray)
                    .lineSpacing(3)

                VStack(spacing: 10) {
                    setupRow(icon: "timer", label: loc("Focus duration"), color: .sand) {
                        TimeStepper(label: "", value: $settings.workDuration, range: 10...120, step: 60, color: .sand, format: .minutes)
                    }
                    setupRow(icon: "leaf", label: loc("Short break"), color: .sage) {
                        TimeStepper(label: "", value: $settings.shortBreakDuration, range: 1...30, step: 60, color: .sage, format: .minutes)
                    }
                    setupRow(icon: "moon.haze", label: loc("Long break"), color: .stoneblue) {
                        TimeStepper(label: "", value: $settings.longBreakDuration, range: 5...60, step: 60, color: .stoneblue, format: .minutes)
                    }
                    setupRow(icon: "target", label: loc("Daily goal"), color: .terracotta) {
                        DailyGoalStepper(value: $settings.dailyGoal)
                    }
                }
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
        )
    }

    @ViewBuilder
    private func setupRow<Content: View>(icon: String, label: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
                .frame(width: 16)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.warmGray)
            Spacer()
            content()
                .frame(width: 120)
        }
    }

    // MARK: - Ready Page
    private var readyPage: AnyView {
        AnyView(
            VStack(spacing: 16) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.sage.opacity(0.1))
                        .frame(width: 70, height: 70)

                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(Color.sage)
                }

                VStack(spacing: 8) {
                    Text(loc("You're all set!"))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.warmWhite)

                    Text(loc("Start your first focus session whenever you're ready. Use the sidebar to explore stats, sounds, and settings."))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }

                Spacer()
            }
        )
    }
}

// MARK: - Daily Goal Stepper (simplified for onboarding)
struct DailyGoalStepper: View {
    @Binding var value: Int

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { value = max(2, value - 2) }) {
                Image(systemName: "minus")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.warmGray)
                    .frame(width: 24, height: 24)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.terracotta.opacity(0.08))
                    }
            }
            .buttonStyle(.plain)

            Text("\(value)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.warmWhite)
                .frame(width: 50)
                .contentTransition(.numericText())

            Text(loc("sessions"))
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.5))
                .frame(width: 40, alignment: .leading)

            Button(action: { value = min(16, value + 2) }) {
                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.warmGray)
                    .frame(width: 24, height: 24)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.terracotta.opacity(0.08))
                    }
            }
            .buttonStyle(.plain)
        }
    }
}
