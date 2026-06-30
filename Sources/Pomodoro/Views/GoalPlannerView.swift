import SwiftUI

struct GoalPlannerView: View {
    @State private var title = ""
    @State private var estimatedMinutes: Double = 60
    @State private var showResult = false
    @Environment(\.dismiss) private var dismiss
    var onPlan: ((Goal) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.sand)
                Text(loc("Goal Planner"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
            }

            VStack(spacing: 10) {
                TextField(loc("What do you want to accomplish?"), text: $title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }

                HStack {
                    Text(loc("Estimated time:"))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)

                    Spacer()

                    HStack(spacing: 4) {
                        Button(action: { estimatedMinutes = max(5, estimatedMinutes - 5) }) {
                            Image(systemName: "minus")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(Color.warmGray)
                                .frame(width: 20, height: 20)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.warmGray.opacity(0.08)))
                        }
                        .buttonStyle(.plain)

                        Text("\(Int(estimatedMinutes)) \(loc("min"))")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.warmWhite)
                            .frame(width: 60, alignment: .center)

                        Button(action: { estimatedMinutes = min(480, estimatedMinutes + 5) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(Color.warmGray)
                                .frame(width: 20, height: 20)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.warmGray.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !title.isEmpty {
                let goal = Goal(title: title, estimatedMinutes: Int(estimatedMinutes))
                VStack(spacing: 8) {
                    HStack {
                        statItem(icon: "timer", value: "\(goal.focusSessionsNeeded)", label: loc("Focus sessions"))
                        statItem(icon: "leaf", value: "\(goal.breaksNeeded)", label: loc("Breaks"))
                        statItem(icon: "clock", value: goal.formattedEstimate, label: loc("Total time"))
                    }

                    // Visual timeline
                    timelineView(goal: goal)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)))
            }

            if !title.isEmpty {
                Button(action: {
                    let goal = Goal(title: title, estimatedMinutes: Int(estimatedMinutes))
                    onPlan?(goal)
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                        Text(loc("Plan this goal"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Color.warmWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.sand.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(Color.sand.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .buttonStyle(.plain)
            }

            Text(loc("Plan a task and see how many focus sessions and breaks you need. Adjust the timer automatically."))
                .font(.system(size: 8, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.4))
        }
    }

    @ViewBuilder
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(Color.warmGray)
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 8, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func timelineView(goal: Goal) -> some View {
        VStack(spacing: 4) {
            let sessions = goal.focusSessionsNeeded
            let total = sessions * 2

            HStack(spacing: 2) {
                ForEach(0..<total, id: \.self) { idx in
                    let isFocus = idx % 2 == 0
                    let sessionIdx = idx / 2
                    let isLongBreak = !isFocus && (sessionIdx + 1) % 4 == 0
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(isFocus ? Color.sand : (isLongBreak ? Color.stoneblue : Color.sage))
                        .frame(height: 8)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Circle().fill(Color.sand).frame(width: 4, height: 4)
                    Text(loc("Focus")).font(.system(size: 7, design: .rounded)).foregroundStyle(.secondary)
                }
                HStack(spacing: 3) {
                    Circle().fill(Color.sage).frame(width: 4, height: 4)
                    Text(loc("Short break")).font(.system(size: 7, design: .rounded)).foregroundStyle(.secondary)
                }
                HStack(spacing: 3) {
                    Circle().fill(Color.stoneblue).frame(width: 4, height: 4)
                    Text(loc("Long break")).font(.system(size: 7, design: .rounded)).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}
