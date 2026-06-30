import SwiftUI

struct ContentView: View {
    let timerService: TimerService
    @State private var timerVM: TimerViewModel
    @State private var statsVM = StatisticsViewModel()
    @State private var settings = AppSettings.shared
    @State private var selectedTab: Tab = .timer
    @State private var showCelebration = false
    @State private var previousPhase: TimerPhase = .work
    @State private var sidebarHovered: Tab? = nil
    @State private var ambientService = AmbientSoundService()
    @State private var keyMonitor: Any?
    @State private var isFullscreen = false

    init(timerService: TimerService) {
        self.timerService = timerService
        self._timerVM = State(initialValue: TimerViewModel(timerService: timerService))
    }

    enum Tab: String, CaseIterable {
        case timer
        case today
        case stats
        case sound
        case settings

        var icon: String {
            switch self {
            case .timer: "timer"
            case .today: "sun.max"
            case .stats: "chart.xyaxis.line"
            case .sound: "speaker.wave.2"
            case .settings: "slider.horizontal.3"
            }
        }
    }

    var body: some View {
        Group {
            if isFullscreen {
                fullscreenContent
                    .frame(minWidth: 400, minHeight: 400)
            } else {
                HStack(spacing: 0) {
                    sidebar
                    mainContent
                        .overlay(alignment: .top) {
                            if showCelebration {
                                CelebrationView(phase: timerVM.currentPhase)
                                    .transition(.opacity)
                            }
                        }
                }
                .frame(width: 500, height: 620)
            }
        }
        .background(AmbientBackground())
        .onChange(of: timerVM.currentPhase) { _, newPhase in
            if newPhase != previousPhase {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCelebration = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showCelebration = false
                    }
                }
                previousPhase = newPhase
                statsVM.refresh()
            }
        }
        .onChange(of: timerVM.isRunning) { _, _ in updateAmbientForPhase() }
        .onChange(of: timerVM.currentPhase) { _, _ in updateAmbientForPhase() }
        .onChange(of: ambientService.selectedSound) { _, _ in updateAmbientForPhase() }
        .onChange(of: settings.enableAmbientMusic) { _, _ in
            if !settings.enableAmbientMusic { ambientService.engineStop() }
        }
        .onAppear {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard selectedTab == .timer else { return event }
                let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
                switch chars {
                case " ":
                    if timerVM.isRunning {
                        timerVM.pause()
                    } else {
                        timerVM.start()
                    }
                    return nil
                case "r":
                    timerVM.reset()
                    return nil
                case "s":
                    timerVM.skip()
                    return nil
                default:
                    return event
                }
            }
        }
        .onDisappear {
            if let monitor = keyMonitor as? AnyObject {
                NSEvent.removeMonitor(monitor)
            }
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.sand.opacity(0.2), Color.terracotta.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: "timer")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cream, Color.sand],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 4)

            ForEach(Tab.allCases, id: \.self) { tab in
                sidebarButton(tab)
            }

            Spacer()

            // Timer indicator at bottom
            Circle()
                .fill(timerVM.isRunning ? timerVM.currentPhase.color : Color.warmGray.opacity(0.3))
                .frame(width: 5, height: 5)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 10)
        .frame(width: 56)
        .background(
            LinearGradient(
                colors: [Color.deepWarm.opacity(0.3), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    @ViewBuilder
    private func sidebarButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        let isHovered = sidebarHovered == tab
        Button(action: {
            withAnimation(.interpolatingSpring(mass: 0.8, stiffness: 120, damping: 14)) {
                selectedTab = tab
            }
            if tab == .stats { statsVM.refresh() }
        }) {
            Image(systemName: tab.icon)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.warmWhite : (isHovered ? Color.warmWhite : Color.warmGray.opacity(0.6)))
                .frame(width: 34, height: 34)
                .background {
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(Color.sand.opacity(0.1))

                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.08), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        } else if isHovered {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(.white.opacity(0.04))
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(isSelected ? .white.opacity(0.08) : .clear, lineWidth: 1)
                    )
                }
                .scaleEffect(isSelected ? 1 : (isHovered ? 1.04 : 1))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 150, damping: 16)) {
                sidebarHovered = hovering ? tab : nil
            }
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .timer:
                timerContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .today:
                todayContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .stats:
                statsContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .sound:
                soundContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .settings:
                settingsContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.interpolatingSpring(mass: 0.8, stiffness: 80, damping: 14), value: selectedTab)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Timer Tab
    @State private var showGoalPlanner = false

    private var timerContent: some View {
        VStack(spacing: 16) {
            StaggeredEntrance(index: 0) {
                TimerView(timerVM: timerVM)
                    .padding(.horizontal, 40)
                    .padding(.top, 28)
            }

            StaggeredEntrance(index: 1) {
                dailyProgress
                    .padding(.horizontal, 40)
            }

            // Bottom controls (goal planner + fullscreen)
            StaggeredEntrance(index: 2) {
                HStack(spacing: 8) {
                    Button(action: { showGoalPlanner.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "target")
                                .font(.system(size: 10))
                            Text(loc("Plan a Goal"))
                                .font(.system(size: 10, design: .rounded))
                        }
                        .foregroundStyle(Color.warmGray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.ultraThinMaterial).opacity(0.6)
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showGoalPlanner) {
                        GoalPlannerView(onPlan: { goal in
                            timerVM.timerService.activeGoal = goal
                            timerVM.timerService.sessionDurationOverride = Double(goal.estimatedMinutes) * 60
                            timerVM.timerService.setPhase(.work)
                            timerVM.start()
                        })
                            .padding(20)
                            .frame(width: 320)
                    }

                    Button(action: { toggleFullscreen() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 9))
                            Text(loc("Focus"))
                                .font(.system(size: 10, design: .rounded))
                        }
                        .foregroundStyle(Color.warmGray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.ultraThinMaterial).opacity(0.6)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
            }

            Spacer()
        }
    }

    // MARK: - Today Tab
    private var todayContent: some View {
        TodayView(timerVM: timerVM)
    }

    // MARK: - Fullscreen
    private var fullscreenContent: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { toggleFullscreen() }) {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.warmGray)
                        .frame(width: 28, height: 28)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial).opacity(0.6))
                }
                .buttonStyle(.plain)
                .padding(.leading, 16)
                .padding(.top, 8)
                Spacer()
            }
            Spacer()
            TimerView(timerVM: timerVM)
                .padding(.horizontal, 60)
            Spacer()
        }
    }

    private func toggleFullscreen() {
        isFullscreen.toggle()
        if let window = NSApplication.shared.windows.first {
            window.toggleFullScreen(nil)
        }
    }

    // MARK: - Stats Tab
    private var statsContent: some View {
        StatisticsView(statsVM: statsVM)
            .onAppear { statsVM.refresh() }
    }

    // MARK: - Sound Tab
    private var soundContent: some View {
        ScrollView {
            AmbientSoundPlayerView(ambientService: ambientService, timerIsRunning: timerVM.isRunning)
                .padding(28)
                .padding(.top, 20)
        }
    }

    // MARK: - Settings Tab
    private var settingsContent: some View {
        SettingsView(settings: settings)
    }

    // MARK: - Ambient Sound
    private func updateAmbientForPhase() {
        if settings.enableAmbientMusic && timerVM.isRunning && timerVM.currentPhase == .work {
            ambientService.startForFocus()
        } else {
            ambientService.pauseForInactive()
        }
    }

    // MARK: - Daily Progress
    private var dailyProgress: some View {
        HStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.sage)

            Text("\(min(timerVM.completedPomodoros, settings.dailyGoal))")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.warmWhite)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(String(format: loc("/ %d sessions"), settings.dailyGoal))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.warmGray)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.06))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.sage, Color.moss],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * min(
                                CGFloat(timerVM.completedPomodoros) / CGFloat(max(settings.dailyGoal, 1)), 1
                            ),
                            height: 4
                        )
                        .animation(.interpolatingSpring(mass: 0.6, stiffness: 80, damping: 14), value: timerVM.completedPomodoros)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.sage.opacity(0.04))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.glassEdge, Color.glassHighlight, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }
}
