import SwiftUI

struct TodayView: View {
    let timerVM: TimerViewModel
    @State private var statsVM = StatisticsViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                statsGrid
                if let goal = timerVM.activeGoal {
                    activeGoalCard(goal)
                }
                todayTimeline
            }
            .padding(24)
        }
        .onAppear { statsVM.refresh() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "sun.max")
                .font(.system(size: 13))
                .foregroundStyle(Color.sand)
            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            statCard(icon: "timer", value: "\(statsVM.todayFocusCount)", label: loc("Sessions"), color: .sand)
            statCard(icon: "clock", value: statsVM.todayFocusDuration.formattedShort, label: loc("Focus time"), color: .sand)
            statCard(icon: "cup.and.saucer", value: statsVM.todayBreakDuration.formattedShort, label: loc("Break time"), color: .sage)
        }
    }

    @ViewBuilder
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    private func activeGoalCard(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.sand)
                Text(loc("Active goal"))
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }
            HStack {
                Text(goal.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                    .lineLimit(1)
                Spacer()
                Text(String(format: loc("%d/%d sessions"), timerVM.completedPomodoros, goal.focusSessionsNeeded))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(goal.isCompleted ? Color.sage : Color.sand)
                    .monospacedDigit()
            }
            if !goal.isCompleted {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.06)).frame(height: 4)
                        Capsule()
                            .fill(Color.sand)
                            .frame(width: geo.size.width * min(CGFloat(timerVM.completedPomodoros) / CGFloat(max(goal.focusSessionsNeeded, 1)), 1), height: 4)
                            .animation(.interpolatingSpring(mass: 0.6, stiffness: 80, damping: 14), value: timerVM.completedPomodoros)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    private var todayTimeline: some View {
        if !statsVM.todaySessions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.sage)
                    Text(loc("Today's timeline"))
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                }
                VStack(spacing: 4) {
                    let sessions = statsVM.todaySessions.sorted { $0.startTime < $1.startTime }
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { _, session in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(session.phase == .work ? Color.sand : Color.sage)
                                .frame(width: 6, height: 6)
                            Text(session.startTime.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 9, design: .rounded))
                                .foregroundStyle(Color.warmGray)
                            Text(session.phase.label)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(session.phase.color)
                            Spacer()
                            Text(session.effectiveDuration.formattedShort)
                                .font(.system(size: 9, design: .rounded))
                                .foregroundStyle(Color.warmGray.opacity(0.6))
                                .monospacedDigit()
                            if let title = session.goalTitle {
                                Text(title)
                                    .font(.system(size: 8, design: .rounded))
                                    .foregroundStyle(Color.warmGray.opacity(0.4))
                                    .lineLimit(1)
                                    .frame(maxWidth: 60, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(session.phase == .work ? Color.sand.opacity(0.05) : Color.sage.opacity(0.05))
                        }
                    }
                }
            }
        } else {
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.warmGray.opacity(0.3))
                    Text(loc("No sessions yet today"))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray.opacity(0.4))
                }
                .padding(.vertical, 24)
                Spacer()
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
    }
}

extension TimeInterval {
    var formattedShort: String {
        let mins = Int(self) / 60
        let hours = mins / 60
        let remainMins = mins % 60
        if hours > 0 {
            return "\(hours)h \(remainMins)m"
        }
        return "\(mins)m"
    }
}
