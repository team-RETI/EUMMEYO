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
    func updateGPTMemo(memoId: String, title: String, content: String, gptContent: String) -> AnyPublisher<Void, ServiceError>
    func updateMemo(memoId: String, memo: Memo) -> AnyPublisher<Void, ServiceError>
    func deleteMemo(memoId: String) -> AnyPublisher<Void, ServiceError>
    func observeMemos(userId: String, onUpdate: @escaping ([Memo]) -> Void)
}

final class MemoService: MemoServiceType {

    
    private var dbRepository: MemoDBRepositoryType
    
    init(dbRepository: MemoDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func observeMemos(userId: String, onUpdate: @escaping ([Memo]) -> Void) {
        dbRepository.observeMemos(userId: userId, onUpdate: onUpdate)
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
    
    func updateGPTMemo(memoId: String, title: String, content: String, gptContent: String)  -> AnyPublisher<Void, ServiceError> {
        dbRepository.updateGPTMemo(memoId: memoId, title: title, content: content, gptContent: gptContent)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func updateMemo(memoId: String, memo: Memo) -> AnyPublisher<Void, ServiceError> {
        dbRepository.updateMemo(memoId: memoId, memo: memo)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteMemo(memoId: String) -> AnyPublisher<Void, ServiceError> {
        dbRepository.deleteMemo(memoId: memoId)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}
