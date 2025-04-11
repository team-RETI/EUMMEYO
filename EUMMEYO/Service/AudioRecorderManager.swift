//
//  AudioRecorderManager.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/14/25.
//

import SwiftUI
import AVFoundation
import AVFAudio
import FirebaseStorage

class AudioRecorderManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordedFileURL: URL?  // 저장된 파일 경로
    @Published var recordedFileMemoURL: URL?  // 저장된 파일 경로
    @Published var uploadProgress: Double = 0.0  // 0.0 ~ 1.0
    
    override init() {
        self.recordedFileURL = nil
        super.init()
        setupRecordingSession()
    }
    
    private func setupRecordingSession() {
        do {
            try recordingSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try recordingSession.setActive(true)
            
            // 입력 게인을 수동으로 설정 (1.0 = 최대)
            if recordingSession.isInputGainSettable {
                try recordingSession.setInputGain(1.0)  // 0.0 ~ 1.0 사이
            }
            
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { allowed in
                    if !allowed {
                        print("🎤 녹음 권한이 필요합니다.")
                        print("test")
                    }
                }
            } else {
                recordingSession.requestRecordPermission { allowed in
                    if !allowed {
                        print("🎤 녹음 권한이 필요합니다.")
                    }
                }
            }
        } catch {
            print("녹음 세션 설정 실패: \(error)")
        }
    }
    
    func startRecording() {
        if let recorder = audioRecorder, !recorder.isRecording, isPaused {
            // 이미 녹음 중이었다면 이어서 계속 녹음
            recorder.record()
            isRecording = true
            isPaused = false
            print("녹음 이어서 시작")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        recordedFileURL = audioFileName // 저장 경로 미리 저장
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            isPaused = false
            print("녹음 시작: \(audioFileName)")
        } catch {
            print("녹음 시작 실패: \(error)")
        }
    }
    
    func pauseRecording() {
        audioRecorder?.pause()
        isPaused = true
        print("녹음 일시정지")
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        isPaused = false
        print("녹음 종료, 저장 위치: \(recordedFileURL?.absoluteString ?? "없음")")
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("녹음 완료됨, 파일 경로: \(recorder.url)")
            recordedFileURL = recorder.url // 안전하게 다시 설정
        } else {
            print("녹음 실패")
        }
    }
    
    func deleteFileFromFirebase(userId: String, fileName: String) {
        let path = "Voices/\(userId)/\(fileName)"
        let storageRef = Storage.storage().reference().child(path)

        storageRef.delete { error in
            if let error = error {
                print("❌ 파일 삭제 실패: \(error.localizedDescription)")
            } else {
                print("✅ 파일 삭제 성공: \(path)")
            }
        }
    }
    
    func uploadAudioToFirebase(userId: String, completion: ((Result<URL, Error>) -> Void)? = nil) {
        guard let fileURL = recordedFileURL else {
            print("⚠️ 녹음 파일 URL이 없음")
            completion?(.failure(NSError(domain: "NoFile", code: -1)))
            return
        }
        
        let storage = Storage.storage()
        let fileName = "Voices/\(userId)/\(UUID().uuidString).m4a"
        let storageRef = storage.reference().child(fileName)
        
        let uploadTask = storageRef.putFile(from: fileURL)  // 🔥 메타데이터 제거

        // 📈 업로드 진행률
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                DispatchQueue.main.async {
                    self.uploadProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                }
            }
        }

        // ✅ 완료
        uploadTask.observe(.success) { _ in
            storageRef.downloadURL { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        self.uploadProgress = 1.0
                    }
                    print("✅ 업로드 성공! 다운로드 URL: \(url)")
                    completion?(.success(url))
                    print("📌 전달된 URL: \(url.absoluteString)")
                    self.recordedFileMemoURL = url
                } else {
                    completion?(.failure(error ?? NSError(domain: "Unknown", code: -2)))
                }
            }
        }

        // ❌ 실패
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                DispatchQueue.main.async {
                    self.uploadProgress = 0.0
                }
                completion?(.failure(error))
            }
        }
    }
}
