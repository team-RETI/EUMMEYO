//
//  MemoDBRepository.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/7/25.
//

import FirebaseDatabase
import Combine
import FirebaseAuth

enum MemoDBError: Error {
    case error(Error)
    case memoNotFound
    case invalidDataType
}

protocol MemoDBRepositoryType {
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, MemoDBError>
    func fetchMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError>
    func fetchBookmarkedMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError>
    func toggleBookmark(memoId: String, currentStatus: Bool) -> AnyPublisher<Void, MemoDBError>
    func updateGPTMemo(memoId: String, title: String, content: String, gptContent: String) -> AnyPublisher<Void, MemoDBError>
    func updateMemo(memoId: String, memo: Memo) -> AnyPublisher<Void, MemoDBError>
    func deleteMemo(memoId: String) -> AnyPublisher<Void, MemoDBError>
    func observeMemos(userId: String, onUpdate: @escaping ([Memo]) -> Void)
}

final class MemoDBRepository: MemoDBRepositoryType {

    var db: DatabaseReference = Database.database().reference()
    private var memoListenerHandle: DatabaseHandle?
    
    // 메모 추가 함수
    func addMemo(_ memo: Memo) -> AnyPublisher<Void, MemoDBError> {
        Just(memo)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
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
    func fetchMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError> {
        Future<Any?, MemoDBError> { [weak self] promise in
            self?.db.child("Memos")
                .queryOrdered(byChild: "userId")
                .queryEqual(toValue: Auth.auth().currentUser?.uid)
                .getData() { error, snapshot in
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
                return Fail(error: .invalidDataType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeMemos(userId: String, onUpdate: @escaping ([Memo]) -> Void) {
        let dbRef = self.db.child("Memos").queryOrdered(byChild: "userId").queryEqual(toValue: Auth.auth().currentUser?.uid)

        // 기존 리스너 제거 (중복 방지)
        if let handle = memoListenerHandle {
            dbRef.removeObserver(withHandle: handle)
        }

        memoListenerHandle = dbRef.observe(.value, with: { snapshot in
            var memos: [Memo] = []

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let memo = try? JSONDecoder().decode(Memo.self, from: jsonData) {
                    memos.append(memo)
                }
            }
            // 최신순 정렬 후 콜백
            onUpdate(memos.sorted(by: { $0.date > $1.date }))
        })
    }

    
    // 즐겨찾기 메모 리스트 가져오기 함수
    func fetchBookmarkedMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError> {
        Future<Any?, MemoDBError> { [weak self] promise in
            self?.db.child("Memos")
                .queryOrdered(byChild: "userId")
                .queryEqual(toValue: userId)
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
                    .map { $0.values.filter { $0.isBookmarked == true } } // 필터 적용
                    .mapError { MemoDBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidDataType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    // 즐겨찾기 토글 함수
    func toggleBookmark(memoId: String, currentStatus: Bool) -> AnyPublisher<Void, MemoDBError> {
        Future<Void, Error> { [weak self] promise in
            let updates: [String: Any] = ["isBookmarked": currentStatus]
            self?.db.child("Memos").child(memoId).updateChildValues(updates) { error, _ in
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
    
    // 요약된 메모 수정 함수
    func updateGPTMemo(memoId: String, title: String, content: String, gptContent: String)  -> AnyPublisher<Void, MemoDBError> {
        Future<Void, Error> { [weak self] promise in
            let updates: [String: Any] = [
                "title": title,
                "content": content,
                "gptContent": gptContent,
            ]
            
            self?.db.child("Memos").child(memoId).updateChildValues(updates) { error, _ in
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
    
    // 메모 업데이트 함수
    func updateMemo(memoId: String, memo: Memo) -> AnyPublisher<Void, MemoDBError> {
        Future<Void, Error> { [weak self] promise in
            let updates: [String: Any] = [
                "title": memo.title,
                "content": memo.content,
                "gptContent": memo.gptContent ?? "",
            ]
            
            self?.db.child("Memos").child(memoId).updateChildValues(updates) { error, _ in
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
    
    // 메모 삭제 함수
    func deleteMemo(memoId: String) -> AnyPublisher<Void, MemoDBError> {
        Future<Void, Error> { [weak self] promise in
            self?.db.child("Memos").child(memoId).removeValue { error, _ in
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
