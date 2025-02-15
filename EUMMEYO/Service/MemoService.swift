//
//  MemoService.swift
//  EUMMEYO
//
//  Created by eunchanKim on 2/15/25.
//

import UIKit
import Combine

protocol MemoServiceType {
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, ServiceError>
    func fetchMemos(userId: String) -> AnyPublisher<[Memo], ServiceError>
    func fetchBookmarkedMemos(userId: String) -> AnyPublisher<[Memo], ServiceError>
    func toggleBookmark(memoId: String, currentStatus: Bool) -> AnyPublisher<Void, ServiceError>
    func deleteMemo(memoId: String) -> AnyPublisher<Void, ServiceError>
}

final class MemoService: MemoServiceType {
    private var dbRepository: MemoDBRepositoryType
    
    init(dbRepository: MemoDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, ServiceError> {
        dbRepository.addMemo(memo)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchMemos(userId: String) -> AnyPublisher<[Memo], ServiceError> {
        dbRepository.fetchMemos(userId: userId)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
        
    func fetchBookmarkedMemos(userId: String) -> AnyPublisher<[Memo], ServiceError> {
        dbRepository.fetchBookmarkedMemos(userId: userId)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func toggleBookmark(memoId: String, currentStatus: Bool) -> AnyPublisher<Void, ServiceError> {
        dbRepository.toggleBookmark(memoId: memoId, currentStatus: currentStatus)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteMemo(memoId: String) -> AnyPublisher<Void, ServiceError> {
        dbRepository.deleteMemo(memoId: memoId)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}
