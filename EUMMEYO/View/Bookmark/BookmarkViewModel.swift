//
//  BookmarkViewModel.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/21/25.
//

import SwiftUI
import Combine

final class BookmarkViewModel: ObservableObject {
    @ObservedObject var memoStore: MemoStore
    
    private let container: DIContainer
    var cancellables = Set<AnyCancellable>()
    private let userId: String
    
    @Published var searchText: String = ""              // 검색 필드 텍스트
    @Published var bookmarkedMemos: [Memo] = []
    @Published var toggleButtonTapped: Bool = false {
        didSet {
            print("\(toggleButtonTapped ? "북마크 모드" : "검색 모드" )")
        }
    }
    
    init(container: DIContainer, userId: String, memoStore: MemoStore) {
        self.container = container
        self.userId = userId
        self.memoStore = memoStore
        
        // 북마크된 메모 호출
        fetchBookmarkedMemos(userId: userId)
        
        // 검색어에 따라 필터링 적용
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterMemos()
            }
            .store(in: &cancellables)
        
        // 북마크 변경확인용 스냅샷 호출
        observeMemos()
    }
    
    func observeMemos() {
        memoStore.$memoList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchBookmarkedMemos(userId: self?.userId ?? "unknown")
            }
            .store(in: &cancellables)
    }
    
    /// 메모 제목 필터링
    func filterMemos() {
        if searchText.isEmpty {
            print("검색모드")
        } else {
            memoStore.memoList = memoStore.memoList.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// 즐겨찾기된 메모만 가져오는 함수
    func fetchBookmarkedMemos(userId: String) {
        container.services.memoService.fetchBookmarkedMemos(userId: userId)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("즐겨찾기 메모 가져오기 성공")
                case .failure(let error):
                    print("즐겨찾기 메모 가져오기 실패: \(error)")
                }
            }, receiveValue: { [weak self] memos in
                self?.bookmarkedMemos = memos.sorted(by: { $0.date > $1.date })
            })
            .store(in: &cancellables)
    }
}

