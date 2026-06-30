import AppKit
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let notificationService = NotificationService()
    private var timerService: TimerService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        notificationService.requestAuthorization()

        NSApplication.shared.setActivationPolicy(.regular)

        if let window = NSApplication.shared.windows.first {
            window.titleVisibility = .visible
            window.titlebarAppearsTransparent = false
            window.isOpaque = true
            window.title = loc("Pomodoro")
        }

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, AppSettings.shared.dockBadge else {
                    NSApp.dockTile.badgeLabel = ""
                    return
                }
                if let service = self.timerService {
                    if service.isRunning {
                        let mins = Int(service.timeRemaining) / 60
                        let secs = Int(service.timeRemaining) % 60
                        NSApp.dockTile.badgeLabel = secs > 0 ? "\(mins):\(String(format: "%02d", secs))" : "\(mins)"
                    } else {
                        NSApp.dockTile.badgeLabel = "\(service.completedPomodoros)"
                    }
                }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return true }
        for window in sender.windows {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            return true
        }
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }

    func setTimerService(_ service: TimerService) {
        timerService = service
    }
}
