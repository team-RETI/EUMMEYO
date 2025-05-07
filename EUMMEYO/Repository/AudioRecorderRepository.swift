//
//  AudioRecorderRepository.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/7/25.
//

import SwiftUI
import AVFoundation
import AVFAudio
import FirebaseStorage

protocol AudioRecorderRepositoryType {
    func setupRecordingSession()
    func startRecord()
    func pauseRecord()
    func stopRecord()
}

final class AudioRecorderRepository: NSObject, AudioRecorderRepositoryType, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordedFileURL: URL?  // 저장된 파일 경로
    @Published var recordedFirebaseURL: URL?  // 저장된 파일 경로
    @Published var uploadProgress: Double = 0.0  // 0.0 ~ 1.0
    
    override init() {
        super.init()
        setupRecordingSession()
    }
    
    func setupRecordingSession() {
        do {
            try recordingSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try recordingSession.setActive(true)

            if recordingSession.isInputGainSettable {
                try recordingSession.setInputGain(1.0)
            }

            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { allowed in
                    if !allowed {
                        print("🎤 녹음 권한이 필요합니다.")
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
    
    func startRecord() {
        if let recorder = audioRecorder, !recorder.isRecording, isPaused {
            recorder.record()
            isRecording = true
            isPaused = false
            return
        }
        
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(UUID().uuidString).m4a")
        recordedFileURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            isPaused = false
        } catch {
            print("녹음 시작 실패: \(error)")
        }
    }
    
    func pauseRecord() {
        audioRecorder?.pause()
        isRecording = false
        isPaused = true
    }
    func stopRecord() {
        audioRecorder?.stop()
        isRecording = false
        isPaused = false
    }
    
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
                    self.recordedFirebaseURL = url
                    print("✅ 업로드 성공! 다운로드 URL: \(url)")
                    completion?(.success(url))
                    print("📌 전달된 URL: \(String(describing: self.recordedFirebaseURL))")
                    
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
