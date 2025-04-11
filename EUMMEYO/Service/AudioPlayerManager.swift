//
//  AudioPlayerManager.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/10/25.
//

import AVFoundation
import FirebaseStorage

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying: Bool = false
    
    func playAudio(fromRemoteURL url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        isPlaying = true
        print("🎧 재생 시작: \(url)")
    }
    
    func stop() {
        player?.pause()
        isPlaying = false
    }
    
    func fetchAndPlay(fromURL url: URL) {
        print("🎧 바로 재생: \(url)")
        playAudio(fromRemoteURL: url)
    }    
}
