//
//  AudioRecorderManager.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/14/25.
//

import Foundation
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // 음성메모 녹음 관련 프로퍼티
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false

    // 음성메모 재생 관련 프로퍼티
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var isPaused = false

    // 음성메모된 데이터
    var recordedFileURL: URL?
    
    // 녹음 시작
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            // 녹음 파일 저장 경로
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFileName = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordedFileURL = audioFileName
        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
        }
    }

    // 녹음 중지
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    // 델리게이트 메서드
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("녹음 성공적으로 완료")
        } else {
            print("녹음 실패")
        }
    }
}

// MARK: - 음성메모 재생 관련 메서드
extension AudioRecorderManager {
  func startPlaying(recordingURL: URL) {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
      audioPlayer?.delegate = self
      audioPlayer?.play()
      self.isPlaying = true
      self.isPaused = false
    } catch {
      print("재생 중 오류 발생: \(error.localizedDescription)")
    }
  }
  
  func stopPlaying() {
    audioPlayer?.stop()
    self.isPlaying = false
  }
  
  func pausePlaying() {
    audioPlayer?.pause()
    self.isPaused = true
  }
  
  func resumePlaying() {
    audioPlayer?.play()
    self.isPaused = false
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    self.isPlaying = false
    self.isPaused = false
  }
}
