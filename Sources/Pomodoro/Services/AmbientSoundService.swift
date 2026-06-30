import AVFoundation
import SwiftUI

@Observable
final class AmbientSoundService {
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private(set) var isPlaying = false
    private(set) var selectedSound: AmbientSoundType?

    var volume: Float = 0.3 {
        didSet { playerNode?.volume = volume }
    }

    enum AmbientSoundType: String, CaseIterable {
        case alphaWaves
        case thetaWaves
        case whiteNoise
        case pinkNoise
        case brownNoise
        case rain

        var label: String {
            switch self {
            case .alphaWaves: loc("Alpha Focus (10 Hz)")
            case .thetaWaves: loc("Theta Relax (6 Hz)")
            case .whiteNoise: loc("White Noise")
            case .pinkNoise: loc("Pink Noise")
            case .brownNoise: loc("Brown Noise")
            case .rain: loc("Soft Rain")
            }
        }

        var icon: String {
            switch self {
            case .alphaWaves: "brain.head.profile"
            case .thetaWaves: "moon.zzz"
            case .whiteNoise: "sparkles"
            case .pinkNoise: "waveform"
            case .brownNoise: "waveform.path"
            case .rain: "cloud.drizzle"
            }

        }

        var description: String {
            switch self {
            case .alphaWaves: loc("Binaural beats at 10 Hz — ideal for focused work and learning.")
            case .thetaWaves: loc("Binaural beats at 6 Hz — deep relaxation and meditation.")
            case .whiteNoise: loc("Full-spectrum white noise — masks distractions effectively.")
            case .pinkNoise: loc("Softer noise with more low frequencies — gentle and calming.")
            case .brownNoise: loc("Deep rumbling noise — even softer than pink, great for sleep.")
            case .rain: loc("Filtered noise mimicking gentle rainfall.")
            }
        }
    }

    // MARK: - Selection (user taps a sound)

    func toggleSelection(_ sound: AmbientSoundType) {
        if selectedSound == sound {
            selectedSound = nil
            engineStop()
        } else {
            selectedSound = sound
            engineStop()
        }
    }

    // MARK: - Playback control (called by ContentView)

    /// Start or resume playback — called when focus session is active
    func startForFocus() {
        guard let sound = selectedSound, !isPlaying else { return }
        if engine != nil {
            // Engine exists but paused → resume
            do {
                try engine?.start()
                playerNode?.play()
                isPlaying = true
            } catch {
                print("Failed to resume audio: \(error)")
            }
        } else {
            // Create engine from scratch
            engineStart(sound)
        }
    }

    /// Pause playback — called when focus session pauses or break starts
    func pauseForInactive() {
        guard isPlaying else { return }
        playerNode?.stop()
        engine?.pause()
        isPlaying = false
    }

    /// Full stop — destroys the engine entirely
    func engineStop() {
        playerNode?.stop()
        engine?.stop()
        engine = nil
        playerNode = nil
        isPlaying = false
    }

    // MARK: - Engine

    private func engineStart(_ sound: AmbientSoundType) {
        engineStop()

        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine, let playerNode else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)

        let buffer = generateBuffer(for: sound, format: format)
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops)

        do {
            try engine.start()
            playerNode.volume = volume
            playerNode.play()
            isPlaying = true
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    private func generateBuffer(for sound: AmbientSoundType, format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sampleRate: Double = 44100
        let duration: Double = 4
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let channels = buffer.floatChannelData else { return buffer }

        let isMono = buffer.format.channelCount < 2
        let leftChannel = channels[0]
        let rightChannel = isMono ? channels[0] : channels[1]

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate

            let (left, right) = generateSample(sound, time: t)
            leftChannel[frame] = Float(left)
            rightChannel[frame] = Float(right)
        }

        return buffer
    }

    private func generateSample(_ sound: AmbientSoundType, time: Double) -> (Double, Double) {
        switch sound {
        case .alphaWaves:
            // Binaural beat: 200 Hz left, 210 Hz right = 10 Hz binaural beat
            let baseFreq = 200.0
            let beatFreq = 10.0
            let left = sin(2 * .pi * baseFreq * time) * 0.15
            let right = sin(2 * .pi * (baseFreq + beatFreq) * time) * 0.15
            return (left, right)

        case .thetaWaves:
            // Binaural beat: 200 Hz left, 206 Hz right = 6 Hz binaural beat
            let baseFreq = 200.0
            let beatFreq = 6.0
            let left = sin(2 * .pi * baseFreq * time) * 0.15
            let right = sin(2 * .pi * (baseFreq + beatFreq) * time) * 0.15
            return (left, right)

        case .whiteNoise:
            let noise = whiteNoise(time)
            return (noise * 0.08, noise * 0.08)

        case .pinkNoise:
            return pinkNoise(time)

        case .brownNoise:
            let noise = brownNoise(time)
            return (noise * 0.12, noise * 0.12)

        case .rain:
            return rainNoise(time)
        }
    }

    private var whiteState: Double = 0
    private func whiteNoise(_ time: Double) -> Double {
        // Simple white noise via random sampling at each sample
        Double.random(in: -1...1)
    }

    private var pinkState: (Double, Double, Double, Double, Double, Double, Double) = (0, 0, 0, 0, 0, 0, 0)
    private func pinkNoise(_ time: Double) -> (Double, Double) {
        // Paul Kellet's refined pink noise algorithm
        var b = pinkState
        let w = Double.random(in: -1...1)
        b.0 = 0.99886 * b.0 + w * 0.0555179
        b.1 = 0.99332 * b.1 + w * 0.0750759
        b.2 = 0.96900 * b.2 + w * 0.1538520
        b.3 = 0.86650 * b.3 + w * 0.3104856
        b.4 = 0.55000 * b.4 + w * 0.5329522
        b.5 = -0.7616 * b.5 - w * 0.0168980
        pinkState = b
        let v = (b.0 + b.1 + b.2 + b.3 + b.4 + b.5 + b.6 + w * 0.5362) * 0.11
        b.6 = w * 0.115926
        return (v, v)
    }

    private var brownState: Double = 0
    private func brownNoise(_ time: Double) -> Double {
        // Brownian noise: integrated white noise
        let w = Double.random(in: -1...1)
        brownState = (brownState + w * 0.02).clamped(to: -1...1)
        return brownState
    }

    private func rainNoise(_ time: Double) -> (Double, Double) {
        // Filtered noise to simulate rain: lots of high-frequency crackles
        let tick = Double.random(in: -1...1)
        let filtered = tick * 0.06
        let envelope = sin(Double.random(in: 0.5...2.0) * time * 10) * 0.5 + 0.5
        let left = filtered * envelope * 0.5
        let right = filtered * (1 - envelope) * 0.5
        return (left, right)
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        max(range.lowerBound, min(self, range.upperBound))
    }
}
