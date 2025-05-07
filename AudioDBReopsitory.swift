//
//  AudioRecorderDBRepository.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/30/25.
//

import Foundation

protocol AudioRecorderDBRepositoryType {
    func setupRecordingSession()
    func startRecording()
    func pauseRecording()
    func stopRecording()
    
    // 델리게이트 함수
    func audioRecorderDidFinishRecording()
    func deleteFileFromFirebase()
    func uploadAudioToFirebase()
}

final class AudioRecorderDBRepository: AudioRecorderDBRepositoryType {
    func setupRecordingSession() {
        <#code#>
    }
    
    func startRecording() {
        <#code#>
    }
    
    func pauseRecording() {
        <#code#>
    }
    
    func stopRecording() {
        <#code#>
    }
    
    func audioRecorderDidFinishRecording() {
        <#code#>
    }
    
    func deleteFileFromFirebase() {
        <#code#>
    }
    
    func uploadAudioToFirebase() {
        <#code#>
    }
    
    
}
