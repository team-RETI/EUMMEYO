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
        if player == nil {
            player = AVPlayer(url: url)
            
            if let duration = player?.currentItem?.asset.duration.seconds, duration > 0 {
                totalTimeString = formatTime(duration)
            }
            
            // 타임 옵저버 추가
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self else { return }
                let current = time.seconds
                let total = self.player?.currentItem?.duration.seconds ?? 1
                if total > 0 {
                    self.progress = current / total
                    self.currentTimeString = self.formatTime(current)
                }
            }
        }
        
        // 사용자가 슬라이더로 이동한 경우
        if hasSeeked {
            seekToProgress()
            hasSeeked = false
        }
        
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
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
