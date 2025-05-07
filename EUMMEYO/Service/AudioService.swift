//
//  AudioService.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/7/25.
//

import Foundation

protocol AudioServiceType {
    // Recorder
    func setupRecordingSession()
    func startRecord()
    func pauseRecord()
    func stopRecord()
    
    // Player
    func audioPlay(url: URL)
    func audioPause()
    func audioStop()
    func seek(to progress: Double)
}

final class AudioService: AudioServiceType {
    private var recordRepository: AudioRecorderRepositoryType
    private var playerRepository: AudioPlayerRepositoryType
    
    init(
        recorderRepository: AudioRecorderRepositoryType,
        playerRepository: AudioPlayerRepositoryType
    ) {
        self.recordRepository = recorderRepository
        self.playerRepository = playerRepository
    }
    
    /// 오디오 세션 설정
    func setupRecordingSession() {
        recordRepository.setupRecordingSession()
    }
    
    /// 오디오 녹음 시작
    func startRecord() {
        recordRepository.startRecord()
    }
    
    /// 현재 녹음 일시 정지
    func pauseRecord() {
        recordRepository.pauseRecord()
    }
    
    /// 오디오 녹음 종료 및 파일 저장
    func stopRecord() {
        recordRepository.stopRecord()
    }
    
    /// 녹음된 파일 재생
    func audioPlay(url: URL) {
        playerRepository.audioPlay(url: url)
    }
    
    /// 오디오 재생 일시정지
    func audioPause() {
        playerRepository.audioPause()
    }
    
    /// 오디오 재생 정지
    func audioStop() {
        playerRepository.audioStop()
    }
    
    
    /// 파일 진행 상황(초단위)
    /// - Parameter progress: 초단위의 진행상황
    func seek(to progress: Double) {
        playerRepository.seek(to: progress)
    }
}
