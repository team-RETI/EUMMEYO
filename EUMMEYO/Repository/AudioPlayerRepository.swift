//
//  AudioPlayerRepository.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/7/25.
//

import Foundation
import AVFoundation

protocol AudioPlayerRepositoryType {
    func audioPlay(url: URL)
    func audioPause()
    func audioStop()
    func seek(to progress: Double)
}

final class AudioPlayerRepository: AudioPlayerRepositoryType {
    private var timeObserver: Any?
    private var player: AVPlayer?
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    
    var onProgressUpdate: ((Double, TimeInterval, TimeInterval) -> Void)?
    
    func audioPlay(url: URL) {
        // 오디오 세션 설정
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        // 기존 플레이어가 있다면 제거
        if player != nil {
            cleanUpPlayer()
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        // duration 비동기 로딩
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                let durationCM = try await item.asset.load(.duration)
                let totalSeconds = CMTimeGetSeconds(durationCM)
                self.duration = totalSeconds
            } catch {
                print("🔴 duration 불러오기 실패: \(error)")
            }
        }

        // 시간 업데이트 옵저버 등록
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if self.duration > 0 {
                let progress = self.currentTime / self.duration
                self.onProgressUpdate?(progress, self.currentTime, self.duration)
            }
        }

        // 재생 시작
        player?.play()

        // 끝났을 때 자동 정리
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.cleanUpPlayer()
        }
    }

    /// 플레이어 정리 함수
    func cleanUpPlayer() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        print("플레이어 해제완료")
    }
    
    func audioPause() {
        player?.pause()
    }
    
    func audioStop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        currentTime = 0
        duration = 0
    }
    
    func seek(to progress: Double) {
        guard duration > 0 else { return }
        let targetTime = CMTime(seconds: progress * duration, preferredTimescale: 600)
        player?.seek(to: targetTime)
    }
}


