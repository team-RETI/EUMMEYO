//
//  MemoDetailVIewModel.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/7/25.
//
import Combine
import SwiftUI

final class MemoDetailViewModel: ObservableObject{
    @ObservedObject var memoStore: MemoStore
    
    var cancellables = Set<AnyCancellable>()
    private let container: DIContainer
    var audioPlayer: AudioPlayerRepository
    
    @Published var isVoiceView = false
    @Published var showUpdateMemoAlarm: Bool = false
    @Published var showDeleteMemoAlarm: Bool = false
    @Published var isEditing: Bool = false
    
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var currentTime: String = "00:00"
    @Published var totalTime: String = "00:00"
    @Published var isBookmark = false
    
    init (
        memoStore: MemoStore,
        container: DIContainer,
        audioPlayer: AudioPlayerRepository
    ) {
        self.audioPlayer = audioPlayer
        self.memoStore = memoStore
        self.container = container
        
        // 콜백 설정
        audioPlayer.onProgressUpdate = { [weak self] progress, current, total in
            DispatchQueue.main.async {
                self?.progress = progress
                self?.currentTime = self?.formatTime(current) ?? "00:00"
                self?.totalTime = self?.formatTime(total) ?? "00:00"
            }
        }
    }
    
    func audioPlay(url: URL) {
        audioPlayer.audioPlay(url: url)
        isPlaying = true
    }
    func audioPause() {
        audioPlayer.audioPause()
        isPlaying = false
    }
    func audioStop() {
        audioPlayer.audioStop()
        isPlaying = false
    }
    func seek(to progress: Double) {
        audioPlayer.seek(to: progress)
    }
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 개별 메모 공유 함수
    func shareText(title: String, content: String) {
        let fullText = """
        📌 \(title)

        \(content)

        📲 음메요(음성과 메모를 요약)
        """
        let activityVC = UIActivityViewController(activityItems: [fullText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    /// 즐겨찾기 On/Off
    /// - Parameters:
    ///   - memoId: 메모 개별 아이디
    ///   - isBookmark: On/Off 값
    func toggleBookmark(memoId: String, isBookmark: Bool) {
        container.services.memoService.toggleBookmark(memoId: memoId, currentStatus: isBookmark)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("즐겨찾기 상태 업데이트 성공 \(isBookmark)")
                case .failure(let error):
                    print("즐겨찾기 상태 업데이트 실패: \(error)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }

    /// 메모 업데이트
    /// - Parameters:
    ///   - memoId: 메모 개별 아이디
    ///   - title: 메모 제목
    ///   - content: 수정한 메모 내용
    func updateMemo(memoId: String, title: String, content: String) {
        container.services.gptAPIService.summarizeContent(content)
            .receive(on: DispatchQueue.main) // UI 업데이트를 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("메모 저장 성공")
                case .failure(let error):
                    print("메모 저장 실패: \(error)")
                }
            }, receiveValue: { [self] summary in
                container.services.memoService.updateGPTMemo(memoId: memoId, title: title, content: content, gptContent: summary)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("메모 업데이트 성공")

                        case .failure(let error):
                            print("메모 업데이트 실패: \(error)")
                        }
                    }, receiveValue: { })
                    .store(in: &cancellables)
            }).store(in: &cancellables)
    }
}
