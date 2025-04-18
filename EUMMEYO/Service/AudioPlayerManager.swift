//
//  AudioPlayerManager.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/10/25.
//

import AVFoundation
import FirebaseStorage
import Combine

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var currentTimeString: String = "00:00"
    @Published var totalTimeString: String = "00:00"
    
    private var timeObserver: Any?
    private var player: AVPlayer?
    private var lastProgress: Double = 0.0
    private var hasSeeked = false
    
    func play(url: URL) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        if player == nil {
            player = AVPlayer(url: url)

            // 비동기로 duration 로딩 (iOS 16+)
            if let asset = player?.currentItem?.asset {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        let duration = try await asset.load(.duration)
                        let seconds = CMTimeGetSeconds(duration)
                        if seconds > 0 {
                            self.totalTimeString = self.formatTime(seconds)
                        }
                    } catch {
                        print("🔴 duration 불러오기 실패: \(error)")
                    }
                }
            }

            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self else { return }
                let current = time.seconds
                if let duration = self.player?.currentItem?.duration.seconds, duration > 0 {
                    self.progress = current / duration
                    self.currentTimeString = self.formatTime(current)
                }
            }
        }

        if hasSeeked {
            seekToProgress()
            hasSeeked = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.player?.play()
            self.isPlaying = true
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        isPlaying = false
        progress = 0.0
        currentTimeString = "00:00"
    }
    
    func seekToProgress() {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
        let seconds = progress * duration
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func userSeeked(to value: Double) {
        progress = value
        hasSeeked = true
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
