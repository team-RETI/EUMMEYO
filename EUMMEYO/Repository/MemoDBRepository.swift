//
//  MemoDBRepository.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/7/25.
//

import FirebaseDatabase
import Combine

enum MemoDBError: Error {
    case error(Error)
    case memoNotFound
    case invalidData
}

protocol MemoDBRepositoryType {
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, MemoDBError>
    func fetchMemos() -> AnyPublisher<[Memo], MemoDBError>
}

final class MemoDBRepository: MemoDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference()
    
    // 메모 추가 함수
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, MemoDBError> {
        Just(memo)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0) }
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child("Memos").child(memo.id).setValue(value) { error, _ in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { MemoDBError.error($0) }
            .eraseToAnyPublisher()
    }
    
    // 메모 리스트 가져오기 함수
    func fetchMemos() -> AnyPublisher<[Memo], MemoDBError> {
        Future<Any?, MemoDBError> { [weak self] promise in
            self?.db.child("Memos").getData { error, snapshot in
                if let error = error {
                    promise(.failure(.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value -> AnyPublisher<[Memo], MemoDBError> in
            if let data = value as? [String: [String: Any]] {
                return Just(data)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: Memo].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 } }
                    .mapError { MemoDBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidData).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 즐겨찾기 메모 리스트 가져오기 함수
    func fetchBookmarkedMemos() -> AnyPublisher<[Memo], MemoDBError> {
        Future<Any?, MemoDBError> { [weak self] promise in
            self?.db.child("Memos")
                .queryOrdered(byChild: "isBookmarked")
                .queryEqual(toValue: true)
                .getData { error, snapshot in
                    if let error = error {
                        promise(.failure(.error(error)))
                    } else if snapshot?.value is NSNull {
                        promise(.success(nil))
                    } else {
                        promise(.success(snapshot?.value))
                    }
                }
        }
        .flatMap { value -> AnyPublisher<[Memo], MemoDBError> in
            if let data = value as? [String: [String: Any]] {
                return Just(data)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: Memo].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 } }
                    .mapError { MemoDBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidData).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    // 즐겨찾기 토글 함수
    func toggleBookmark(memoID: String, currentStatus: Bool) -> AnyPublisher<Void, MemoDBError> {
        Future<Void, Error> { [weak self] promise in
            let newStatus = !currentStatus // 현재 상태 반대로 변경
            let updates: [String: Any] = ["isBookmarked": newStatus]

            self?.db.child("Memos").child(memoID).updateChildValues(updates) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .mapError { MemoDBError.error($0) }
        .eraseToAnyPublisher()
    }
}
