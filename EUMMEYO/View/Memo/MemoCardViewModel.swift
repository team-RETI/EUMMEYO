//
//  MemoCardViewModel.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/24/25.
//

import SwiftUI
import Combine

final class MemoCardViewModel: ObservableObject{
    
    @ObservedObject var memoStore: MemoStore
    
    private let container: DIContainer
    var cancellables = Set<AnyCancellable>()
    var audioRecorderManager = AudioRecorderRepository()
    
    var isBookmark = false
    var currentDay: Date = Date()
    
    init(memoStore: MemoStore,container: DIContainer) {
        self.container = container
        self.memoStore = memoStore
    }
    
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
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
}
