//
//  AudioRecorderManager.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/14/25.
//

import Foundation
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    var audioRecorder: AVAudioRecorder?
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
