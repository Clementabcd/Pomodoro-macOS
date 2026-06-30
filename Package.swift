// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pomodoro",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "Pomodoro",
            path: "Sources/Pomodoro",
            resources: [.process("Resources")],
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit"),
                .linkedFramework("UserNotifications"),
                .linkedFramework("Charts"),
            ]
        )
    ]
)
