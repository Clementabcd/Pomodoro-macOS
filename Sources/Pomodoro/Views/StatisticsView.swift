import SwiftUI
import Charts

struct StatisticsView: View {
    var statsVM: StatisticsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header

                todayCard
                weekCard
                appUsageCard
                allTimeCard
            }
            .padding(24)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 13))
                .foregroundStyle(Color.warmGray)
            Text(loc("Analytics"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(gradeColor(statsVM.todayFocusScore)).frame(width: 6, height: 6)
                Text(gradeLetter(statsVM.todayFocusScore))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(gradeColor(statsVM.todayFocusScore))
            }
        }
    }

    // MARK: - Today
    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sun.max")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.sand)
                Text(loc("Today"))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }

            HStack(spacing: 0) {
                statBlock(icon: "timer", value: statsVM.todayFocusCount, label: loc("Focus"), color: Color.sand)
                divider
                statBlock(icon: "leaf", value: statsVM.todayBreakCount, label: loc("Pauses"), color: Color.sage)
                divider
                statBlock(icon: "clock", value: minutes(statsVM.todayFocusDuration), label: loc("min focus"), color: Color.terracotta)
                divider
                statBlock(icon: "moon.haze", value: minutes(statsVM.todayBreakDuration), label: loc("min break"), color: Color.sky)
            }

            if statsVM.todayFocusCount + statsVM.todayBreakCount > 0 {
                ratioBar
            }
        }
        .padding(16)
        .background(cardBg(color: Color.sand))
    }

    private var ratioBar: some View {
        HStack(spacing: 8) {
            Text("\(statsVM.todayFocusCount)f / \(statsVM.todayBreakCount)p")
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.5))
                .monospacedDigit()

            GeometryReader { geo in
                let total = CGFloat(max(statsVM.todayFocusCount + statsVM.todayBreakCount, 1))
                let focusRatio = CGFloat(statsVM.todayFocusCount) / total
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(nsColor: .thinSeparator)).frame(height: 3)
                    HStack(spacing: 2) {
                        Capsule().fill(Color.sand).frame(width: geo.size.width * focusRatio, height: 3)
                        if statsVM.todayBreakCount > 0 {
                            Capsule().fill(Color.sage).frame(width: geo.size.width * (1 - focusRatio), height: 3)
                        }
                    }
                }
            }
            .frame(height: 3)
        }
    }

    // MARK: - Week
    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.sky)
                Text(loc("This Week"))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }

            if !statsVM.weekFocusData.isEmpty {
                Chart {
                    ForEach(statsVM.weekFocusData, id: \.day) { day, count in
                        BarMark(x: .value("Day", day), y: .value("Focus", count))
                            .foregroundStyle(Color.sand.gradient)
                            .cornerRadius(3)
                            .position(by: .value("Type", "Focus"))
                    }
                    ForEach(statsVM.weekBreakData, id: \.day) { day, count in
                        BarMark(x: .value("Day", day), y: .value("Breaks", count))
                            .foregroundStyle(Color.sage.gradient)
                            .cornerRadius(3)
                            .position(by: .value("Type", "Pause"))
                    }
                }
                .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.warmGray.opacity(0.4)).font(.system(size: 8)) } }
                .chartYAxis { AxisMarks { _ in AxisGridLine().foregroundStyle(Color(nsColor: .thinSeparator)); AxisValueLabel().foregroundStyle(Color.warmGray.opacity(0.4)).font(.system(size: 8)) } }
                .chartForegroundStyleScale([loc("Focus"): Color.sand, loc("Pause"): Color.sage])
                .chartLegend(.hidden)
                .frame(height: 100)

                HStack(spacing: 10) {
                    HStack(spacing: 4) { Circle().fill(Color.sand).frame(width: 5, height: 5); Text(loc("Focus")).font(.system(size: 8, design: .rounded)).foregroundStyle(.secondary) }
                    HStack(spacing: 4) { Circle().fill(Color.sage).frame(width: 5, height: 5); Text(loc("Pause")).font(.system(size: 8, design: .rounded)).foregroundStyle(.secondary) }
                }
            } else {
                Text(loc("No data this week"))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .padding(16)
        .background(cardBg(color: Color.sky))
    }

    // MARK: - App Usage
    private var appUsageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "app")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.terracotta)
                Text(loc("Top Apps (7 days)"))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }

            if !statsVM.weekAppData.isEmpty {
                VStack(spacing: 6) {
                    ForEach(statsVM.weekAppData, id: \.appName) { app, duration in
                        HStack(spacing: 8) {
                            Image(systemName: appIcon(for: app))
                                .font(.system(size: 9))
                                .foregroundStyle(Color.warmGray)
                                .frame(width: 16)

                            Text(app)
                                .font(.system(size: 10, design: .rounded))
                                .foregroundStyle(Color.warmWhite)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(Int(duration / 60))m")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.warmGray)
                                .monospacedDigit()

                            GeometryReader { geo in
                                let total = statsVM.weekAppData.map(\.duration).max() ?? 1
                                Capsule()
                                    .fill(Color.terracotta.opacity(0.5))
                                    .frame(width: geo.size.width * CGFloat(duration / total), height: 4)
                            }
                            .frame(width: 40, height: 4)
                        }
                    }
                }
            } else {
                Text(loc("No app data yet — start a focus session"))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            }
        }
        .padding(16)
        .background(cardBg(color: Color.terracotta))
    }

    // MARK: - All-Time
    private var allTimeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "infinity")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.moss)
                Text(loc("All Time"))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.warmGray)
            }

            if statsVM.totalSessions > 0 {
                // Focus score ring
                HStack {
                    ZStack {
                        Circle()
                            .stroke(Color(nsColor: .thinSeparator), lineWidth: 5)
                            .frame(width: 52, height: 52)

                        Circle()
                            .trim(from: 0, to: CGFloat(statsVM.overallFocusScore) / 100)
                            .stroke(gradeColor(statsVM.overallFocusScore).gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .frame(width: 52, height: 52)
                            .rotationEffect(.degrees(-90))

                        Text("\(statsVM.overallFocusScore)%")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.warmWhite)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("Focus Score"))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Text(gradeLetter(statsVM.overallFocusScore))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(gradeColor(statsVM.overallFocusScore))
                    }
                    .padding(.leading, 12)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: loc("%d min distracted"), Int(statsVM.totalDistractingDuration / 60)))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(Color.warmGray.opacity(0.6))
                        Text(String(format: loc("%d sessions"), statsVM.totalFocusSessions))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(Color.warmGray.opacity(0.6))
                    }
                }
                .padding(.bottom, 8)

                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 6), count: 4), spacing: 8) {
                    miniBlock(value: "\(statsVM.totalFocusSessions)", label: loc("Focus"))
                    miniBlock(value: "\(statsVM.totalBreaks)", label: loc("Breaks"))
                    miniBlock(value: "\(minutes(statsVM.totalFocusDuration))", label: loc("min focus"))
                    miniBlock(value: "\(statsVM.streakDays)", label: loc("Streak"))
                    miniBlock(value: "\(statsVM.bestDayCount)", label: loc("Best day"))
                    miniBlock(value: String(format: "%.1f", statsVM.dailyAverage), label: loc("Avg/day"))
                    miniBlock(value: "\(statsVM.totalSessions)", label: loc("Total"))
                    miniBlock(value: gradeLetter(statsVM.overallFocusScore), label: loc("Grade"))
                }
            } else {
                Text(loc("Complete your first session to see stats"))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(16)
        .background(cardBg(color: Color.moss))
    }

    // MARK: - Helpers
    private func minutes(_ interval: TimeInterval) -> Int { Int(interval) / 60 }

    private func gradeColor(_ score: Int) -> Color {
        switch score {
        case 90...: Color.moss
        case 70..<90: Color.sand
        case 50..<70: Color.terracotta
        default: Color(red: 0.8, green: 0.3, blue: 0.3)
        }
    }

    private func gradeLetter(_ score: Int) -> String {
        switch score {
        case 95...: "S"
        case 85..<95: "A"
        case 70..<85: "B"
        case 50..<70: "C"
        default: "D"
        }
    }

    private func appIcon(for name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("xcode") || lower.contains("code") { return "chevron.left.forwardslash.chevron.right" }
        if lower.contains("safari") || lower.contains("chrome") || lower.contains("firefox") || lower.contains("browser") || lower.contains("edge") || lower.contains("brave") { return "safari" }
        if lower.contains("spotify") || lower.contains("music") { return "music.note" }
        if lower.contains("slack") || lower.contains("message") || lower.contains("whatsapp") || lower.contains("telegram") || lower.contains("discord") { return "bubble.left" }
        if lower.contains("mail") || lower.contains("outlook") { return "envelope" }
        if lower.contains("terminal") || lower.contains("iterm") { return "terminal" }
        if lower.contains("finder") { return "folder" }
        if lower.contains("note") { return "note.text" }
        if lower.contains("calendar") { return "calendar" }
        if lower.contains("game") || lower.contains("steam") { return "gamecontroller" }
        if lower.contains("social") || lower.contains("twitter") || lower.contains("x") { return "message" }
        return "app"
    }

    private var divider: some View {
        Divider().frame(height: 30).foregroundStyle(Color(nsColor: .thinSeparator))
    }

    private func cardBg(color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(color.opacity(0.03))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(LinearGradient(colors: [Color.glassEdge, Color.glassHighlight, .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }

    private func statBlock(icon: String, value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9)).foregroundStyle(color.opacity(0.7))
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label).font(.system(size: 8, design: .rounded)).foregroundStyle(Color.warmGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private func miniBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
                .lineLimit(1)
            Text(label)
                .font(.system(size: 7, design: .rounded))
                .foregroundStyle(Color.warmGray.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
