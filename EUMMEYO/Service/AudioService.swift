//
//  AudioRecorderService.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/29/25.
//

import Foundation

protocol AudioRecorderServiceType {
    // Recorder
    func setupRecordingSession()
    func startRecord()
    func pauseRecord()
    func stopRecord()
    
    // Player
    func audioPlay()
    func audioPause()
    func audioStop()
    
    // 델리게이트 함수
    func audioRecorderDidFinishRecording()
    func deleteFileFromFirebase()
    func uploadAudioToFirebase()
}

final class AudioRecorderService: AudioRecorderServiceType {
    
    private var dbRepository: AudioRecorderDBRepositoryType
    
    init(dbRepository: AudioRecorderDBRepositoryType) {
        self.dbRepository = dbRepository
    }
  
}
