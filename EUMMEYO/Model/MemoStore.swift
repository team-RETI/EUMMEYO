//
//  MemoStore.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/17/25.
//

import SwiftUI
import Combine

class MemoStore: ObservableObject {

    var audioRecorderManager = AudioRecorderRepository()
    
    private var cancellables = Set<AnyCancellable>()
    var container: DIContainer
    var userId: String
    @Published var memoList: [Memo] = []
    @Published var showDeleteMemoAlarm = false
    @Published var deleteTarget: Memo?
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
        observeMemos()
    }
    
    func setUserId(_ userId: String) {
        self.userId = userId
    }
    
    func observeMemos() {
        container.services.memoService.observeMemos(userId: userId) { [weak self] memos in
            DispatchQueue.main.async {
                self?.memoList = memos.sorted(by: { $0.date > $1.date })
            }
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
    
    /// 메모 삭제 함수 - Memo only
    /// - Parameter memoId: 메모 개별 아이디
    func deleteMemo(memoId: String) {
        container.services.memoService.deleteMemo(memoId: memoId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("메모 삭제 실패: \(error)")
                case .finished:
                    print("메모 삭제 성공")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    /// 메모 삭제 함수 - Memo + VoiceFile
    func deleteMemo() {
        if let memo = deleteTarget {
            print("memo Title: \(memo.title)")
            deleteMemo(memoId: memo.id)
            if let url = memo.voiceMemoURL {
                audioRecorderManager.deleteFileFromFirebase(userId: memo.userId, fileName: url.lastPathComponent)
            }
        }
    }
}
