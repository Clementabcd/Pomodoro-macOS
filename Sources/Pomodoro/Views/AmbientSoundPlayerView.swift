import SwiftUI

struct AmbientSoundPlayerView: View {
    @Bindable var ambientService: AmbientSoundService
    let timerIsRunning: Bool
    @State private var settings = AppSettings.shared

    @State private var hoveredSound: AmbientSoundService.AmbientSoundType?

    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.sand)
                Text(loc("Ambient Sounds"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
                Spacer()
                if ambientService.isPlaying {
                    Text(loc("Playing"))
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.sand)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.sand.opacity(0.1)))
                } else if ambientService.selectedSound != nil {
                    Text(loc("Selected"))
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.warmGray.opacity(0.4))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.white.opacity(0.05)))
                }
            }

            // Enable/disable toggle
            HStack {
                Toggle(loc("Enable ambient music"), isOn: $settings.enableAmbientMusic)
                    .toggleStyle(.switch)
                    .tint(Color.sand)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.warmWhite)
            }
            .onChange(of: settings.enableAmbientMusic) { _, _ in
                if !settings.enableAmbientMusic {
                    ambientService.engineStop()
                }
            }

            // Sound list
            VStack(spacing: 3) {
                ForEach(AmbientSoundService.AmbientSoundType.allCases, id: \.rawValue) { sound in
                    let isSelected = ambientService.selectedSound == sound
                    let isActive = isSelected && ambientService.isPlaying
                    Button(action: { ambientService.toggleSelection(sound) }) {
                        HStack(spacing: 10) {
                            Image(systemName: sound.icon)
                                .font(.system(size: 11))
                                .foregroundStyle(isActive ? soundColor(sound) : Color.warmGray)
                                .frame(width: 18)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(sound.label)
                                    .font(.system(size: 11, weight: isActive ? .semibold : .regular, design: .rounded))
                                    .foregroundStyle(isActive ? Color.warmWhite : Color.warmGray)
                                Text(sound.description)
                                    .font(.system(size: 8, design: .rounded))
                                    .foregroundStyle(Color.warmGray.opacity(0.4))
                                    .lineLimit(1)
                            }

                            Spacer()

                            if isActive {
                                Circle()
                                    .fill(soundColor(sound))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            if isActive {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(soundColor(sound).opacity(0.12))
                            } else if isSelected {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(soundColor(sound).opacity(0.05))
                            } else if hoveredSound == sound {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.white.opacity(0.04))
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(
                                    isSelected ? soundColor(sound).opacity(0.3) : .clear,
                                    lineWidth: 0.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            hoveredSound = hovering ? sound : nil
                        }
                    }
                }
            }

            // Volume slider
            if ambientService.selectedSound != nil {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.warmGray.opacity(0.5))
                        Slider(value: $ambientService.volume, in: 0...1)
                            .tint(Color.sand)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.warmGray.opacity(0.5))
                    }
                    Text(loc("Sound is heard only during active focus sessions"))
                        .font(.system(size: 7, design: .rounded))
                        .foregroundStyle(Color.warmGray.opacity(0.3))
                }
                .padding(.horizontal, 4)
                .transition(.opacity)
            }
        }
    }

    private func soundColor(_ sound: AmbientSoundService.AmbientSoundType) -> Color {
        switch sound {
        case .alphaWaves: Color.sand
        case .thetaWaves: Color.sky
        case .whiteNoise: Color.warmGray
        case .pinkNoise: Color.sage
        case .brownNoise: Color.moss
        case .rain: Color.stoneblue
        }
    }
}
