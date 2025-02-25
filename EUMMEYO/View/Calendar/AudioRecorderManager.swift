//
//  AudioRecorderManager.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/14/25.
//

import SwiftUI
import AVFoundation
import FirebaseStorage

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
    
    // 메모용
    var memoURL: URL?
    
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
    
    // 🔹 Firebase Storage에 업로드
    func uploadAudioToFirebase(userId: String, completion: @escaping (String?) -> Void) {
        guard let audioURL = recordedFileURL else {
            print("🔴 업로드할 파일이 없음")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("Voices/\(userId)/\(UUID().uuidString).m4a")
        
        storageRef.putFile(from: audioURL, metadata: nil) { metadata, error in
            if let error = error {
                print("🔴 업로드 실패: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { [self] (url, error) in
                    if let downloadURL = url {
                        print("✅ 업로드 완료: \(downloadURL.absoluteString)")
                        memoURL = downloadURL

                        completion(downloadURL.absoluteString) // URL 반환
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func uploadAudioToFirebase(userId: String) {
        guard let audioURL = recordedFileURL else {
            print("🔴 업로드할 파일이 없음")
            return
        }

        let storageRef = Storage.storage().reference().child("Voices/\(userId)/\(UUID().uuidString).m4a")
        
        storageRef.putFile(from: audioURL, metadata: nil) { metadata, error in
            if let error = error {
                print("🔴 업로드 실패: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { [weak self] (url, error) in
                guard let self = self, let downloadURL = url else { return }
                print("✅ 업로드 완료: \(downloadURL.absoluteString)")
                self.memoURL = downloadURL  // 상태 변수에 저장
            }
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
