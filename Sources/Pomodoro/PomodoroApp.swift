import SwiftUI

@main
struct PomodoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var timerService = TimerService()
    @State private var settings = AppSettings.shared
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView(timerService: timerService)
                .onAppear {
                    appDelegate.setTimerService(timerService)
                    if !settings.hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView(settings: settings)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)

        MenuBarExtra {
            MenuBarView(timerService: timerService)
        } label: {
            TimerMenuLabel(timerService: timerService)
        }
    }
}
