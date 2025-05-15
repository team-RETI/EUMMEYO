//
//  MemoFirestoreRepository.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/7/25.
//

import FirebaseFirestore
import Combine
import FirebaseAuth

import FirebaseDatabase

//final class MemoFirestoreRepository: MemoDBRepositoryType {
//
//
//    var db = Firestore.firestore()
//    func observeMemos(userId: String, onUpdate: @escaping ([Memo]) -> Void) {
//        print("test")
//    }
//    
//    func updateMemo(memoId: String, memo: Memo) -> AnyPublisher<Void, MemoDBError> {
//        print("test")
//    }
//    
//    func addMemo(_ memo: Memo) -> AnyPublisher<Void, MemoDBError> {
//        return Future<Void, Error> { [weak self] promise in
//            do {
//                try self?.db.collection("users")
//                    .document(memo.userId)
//                    .collection("memos")
//                    .document(memo.id)
//                    .setData(from: memo) { error in
//                        if let error = error {
//                            promise(.failure(error))
//                        } else {
//                            promise(.success(()))
//                        }
//                    }
//            } catch {
//                promise(.failure(error))
//            }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//    
//    func fetchMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError> {
//        return Future<[Memo], Error> { [weak self] promise in
//            self?.db.collection("users")
//                .document(userId)
//                .collection("memos")
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        promise(.failure(error))
//                    } else if let snapshot = snapshot {
//                        do {
//                            let memos = try snapshot.documents.map {
//                                try $0.data(as: Memo.self)
//                            }
//                            promise(.success(memos))
//                        } catch {
//                            promise(.failure(error))
//                        }
//                    } else {
//                        promise(.success([])) // 또는 에러 처리
//                    }
//                }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//
//    func fetchBookmarkedMemos(userId: String) -> AnyPublisher<[Memo], MemoDBError> {
//        return Future<[Memo], Error> { [weak self] promise in
//            self?.db.collection("users")
//                .document(userId)
//                .collection("memos")
//                .whereField("isBookmarked", isEqualTo: true)
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        promise(.failure(error))
//                    } else if let snapshot = snapshot {
//                        do {
//                            let memos = try snapshot.documents.map {
//                                try $0.data(as: Memo.self)
//                            }
//                            promise(.success(memos))
//                        } catch {
//                            promise(.failure(error))
//                        }
//                    } else {
//                        promise(.success([]))
//                    }
//                }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//
//    func toggleBookmark(memoId: String, currentStatus: Bool) -> AnyPublisher<Void, MemoDBError> {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            return Fail(error: MemoDBError.invalidDataType).eraseToAnyPublisher()
//        }
//
//        return Future<Void, Error> { [weak self] promise in
//            self?.db.collection("users")
//                .document(userId)
//                .collection("memos")
//                .document(memoId)
//                .updateData(["isBookmarked": currentStatus]) { error in
//                    if let error = error {
//                        promise(.failure(error))
//                    } else {
//                        promise(.success(()))
//                    }
//                }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//
//    func updateGPTMemo(memoId: String, title: String, content: String, gptContent: String) -> AnyPublisher<Void, MemoDBError> {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            return Fail(error: MemoDBError.invalidDataType).eraseToAnyPublisher()
//        }
//
//        let updates: [String: Any] = [
//            "title": title,
//            "content": content,
//            "gptContent": gptContent
//        ]
//
//        return Future<Void, Error> { [weak self] promise in
//            self?.db.collection("users")
//                .document(userId)
//                .collection("memos")
//                .document(memoId)
//                .updateData(updates) { error in
//                    if let error = error {
//                        promise(.failure(error))
//                    } else {
//                        promise(.success(()))
//                    }
//                }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//
//    func deleteMemo(memoId: String) -> AnyPublisher<Void, MemoDBError> {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            return Fail(error: MemoDBError.invalidDataType).eraseToAnyPublisher()
//        }
//
//        return Future<Void, Error> { [weak self] promise in
//            self?.db.collection("users")
//                .document(userId)
//                .collection("memos")
//                .document(memoId)
//                .delete() { error in
//                    if let error = error {
//                        promise(.failure(error))
//                    } else {
//                        promise(.success(()))
//                    }
//                }
//        }
//        .mapError { MemoDBError.error($0) }
//        .eraseToAnyPublisher()
//    }
//}
