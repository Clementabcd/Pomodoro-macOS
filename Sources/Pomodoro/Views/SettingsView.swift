import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header

                section(icon: "clock", title: loc("Timers"), color: Color.sand) {
                    TimeStepper(label: loc("Focus"), value: $settings.workDuration, range: 10...120, step: 60, color: .sand, format: .minutes)
                    TimeStepper(label: loc("Short Break"), value: $settings.shortBreakDuration, range: 1...30, step: 60, color: .sage, format: .minutes)
                    TimeStepper(label: loc("Long Break"), value: $settings.longBreakDuration, range: 5...60, step: 60, color: .sky, format: .minutes)

                    HStack {
                        Text(loc("Long break every"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Picker("", selection: $settings.longBreakInterval) {
                            ForEach(2...8, id: \.self) { n in Text(String(format: loc("%d sessions"), n)).tag(n) }
                        }
                        .labelsHidden().frame(width: 120).scaleEffect(0.85)
                    }

                    HStack {
                        Text(loc("Daily goal"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Picker("", selection: $settings.dailyGoal) {
                            ForEach([2, 4, 6, 8, 10, 12, 16], id: \.self) { n in Text(String(format: loc("%d sessions"), n)).tag(n) }
                        }
                        .labelsHidden().frame(width: 120).scaleEffect(0.85)
                    }
                }

                section(icon: "leaf", title: loc("Behavior"), color: Color.sage) {
                    Toggle(loc("Auto-start breaks"), isOn: $settings.autoStartBreaks)
                        .toggleStyle(.switch).tint(Color.sage)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    Toggle(loc("Auto-start focus"), isOn: $settings.autoStartWork)
                        .toggleStyle(.switch).tint(Color.sage)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    Toggle(loc("Focus score tracking"), isOn: $settings.focusScoreEnabled)
                        .toggleStyle(.switch).tint(Color.sage)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                }

                section(icon: "app.badge", title: loc("Focus & Distractions"), color: Color.terracotta) {
                    Toggle(loc("Track active apps during focus"), isOn: $settings.trackApps)
                        .toggleStyle(.switch).tint(Color.terracotta)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    if settings.trackApps {
                        Toggle(loc("Detect distractions"), isOn: $settings.detectDistractions)
                            .toggleStyle(.switch).tint(Color.terracotta)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        if settings.detectDistractions {
                            Toggle(loc("Notify on distraction"), isOn: $settings.distractionNotification)
                                .toggleStyle(.switch).tint(Color.terracotta)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.warmGray)
                        }
                        Text(loc("Games, social media, and entertainment apps are detected and scored. You'll see your focus grade in stats."))
                            .font(.system(size: 8, design: .rounded))
                            .foregroundStyle(Color.warmGray.opacity(0.4))
                    }
                }

                section(icon: "bell", title: loc("Sounds & Notifications"), color: Color.sand) {
                    Toggle(loc("Notifications"), isOn: $settings.enableNotifications)
                        .toggleStyle(.switch).tint(Color.sand)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    Toggle(loc("Sounds"), isOn: $settings.enableSounds)
                        .toggleStyle(.switch).tint(Color.sand)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    HStack {
                        Text(loc("Sound theme"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Picker("", selection: $settings.soundTheme) {
                            ForEach(SoundTheme.allCases, id: \.self) { t in Text(t.label).tag(t) }
                        }
                        .labelsHidden().frame(width: 120).scaleEffect(0.85)
                    }
                    HStack {
                        Text(loc("Custom sound"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Button(action: pickCustomSound) {
                            HStack(spacing: 4) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 9))
                                Text(settings.customSoundPath != nil ? loc("Change…") : loc("Choose…"))
                                    .font(.system(size: 10, design: .rounded))
                            }
                            .foregroundStyle(Color.warmGray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(.white.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                        if settings.customSoundPath != nil {
                            Button(action: { settings.customSoundPath = nil; settings.save() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.warmGray.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                section(icon: "eye", title: loc("Display"), color: Color.sky) {
                    Toggle(loc("Show timer in menu bar"), isOn: $settings.enableMenuBarTimer)
                        .toggleStyle(.switch).tint(Color.sky)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    Toggle(loc("Badge count in Dock"), isOn: $settings.dockBadge)
                        .toggleStyle(.switch).tint(Color.sky)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.warmGray)
                    HStack {
                        Text(loc("Glass style"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Picker("", selection: $settings.glassStyle) {
                            ForEach(GlassStyle.allCases, id: \.self) { s in Text(s.label).tag(s) }
                        }
                        .labelsHidden().frame(width: 120).scaleEffect(0.85)
                    }
                    HStack {
                        Text(loc("Animation speed"))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.warmGray)
                        Spacer()
                        Picker("", selection: $settings.animationSpeed) {
                            ForEach(AnimationSpeed.allCases, id: \.self) { s in Text(s.label).tag(s) }
                        }
                        .labelsHidden().frame(width: 120).scaleEffect(0.85)
                    }
                }

                section(icon: "info.circle", title: loc("About"), color: Color.warmGray) {
                    HStack {
                        Text(loc("Pomodoro")).font(.system(size: 11, design: .rounded)).foregroundStyle(Color.warmGray)
                        Spacer()
                        Text("1.1.0").font(.system(size: 10, design: .rounded)).foregroundStyle(Color.warmGray.opacity(0.5))
                    }
                    Button(action: {
                        let p = PersistenceService()
                        p.clearAll()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash").font(.system(size: 9))
                            Text(loc("Reset all data"))
                        }
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(Color.terracotta.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 13))
                .foregroundStyle(Color.warmGray)
            Text(loc("Settings"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.warmWhite)
        }
    }

    private func pickCustomSound() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = loc("Choose a sound file for phase notifications")
        panel.begin { response in
            if response == .OK, let url = panel.url {
                settings.customSoundPath = url.path
                settings.save()
                NSSound(contentsOf: url, byReference: true)?.play()
            }
        }
    }

    @ViewBuilder
    private func section(icon: String, title: String, color: Color, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 9)).foregroundStyle(color)
                Text(title).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(Color.warmGray)
            }
            VStack(spacing: 8) { content() }
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(color.opacity(0.03))
                }
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color(nsColor: .glassEdgeColor), lineWidth: 0.5))
        }
    }
}
