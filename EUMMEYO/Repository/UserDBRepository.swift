//
//  UserDBRepository.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import Foundation
import Combine
import FirebaseDatabase

enum DBError: Error {
    case error(Error)       // Firebase에서 발생하는 일반적인 에러
    case userNotFound       // 사용자를 찾을 수 없는 경우
    case invalidatedType    // loadUsers에서 사용하는 에러타입(유효하지 않은 데이터 타입)
}

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError>
    func updateUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
    func loadUsers() -> AnyPublisher<[UserObject], DBError>
}

final class UserDBRepository: UserDBRepositoryType {
    
    // 파이어베이스 db 접근하려면 레퍼런스 객체 필요
    var db: DatabaseReference = Database.database().reference()
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> {
        // object -> data화시킨다 -> dic만들어서 값을 -> DB에 넣는다
        Just(object)                                                     // Combine에서 **단일 값(object)**을 방출하는 퍼블리셔를 생성, UserObject를 다음 작업으로 전달
            .compactMap { try? JSONEncoder().encode($0)}                 // UserObject를 Json형식의 Data로 인코딩, 실패할경우 nil반환(UserObject -> Json 직렬화로 DB호환성 높임)
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } // JSON -> 딕셔너리화(Firebase Realtime Database에 적합한 형태)
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in // Users/userId/...
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            // DBError로 에러 타입을 변환해서 퍼블리셔로 보내자
            .mapError { DBError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).child(userId).getData { error, snapshot in
                if let error = error {
                    // Firebase요청 중 에러 발생시
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    // 요청은 성공했으나 값이 NSNull인 경우 사용자 존재x
                    promise(.failure(.userNotFound))
                } else {
                    // 성공시 데이터 가져오기
                    promise(.success(snapshot?.value))
                }
            }
        }
        // 데이터 변환 및 디코딩
        .flatMap { value in
            // 데이터가 유효하면
            if let value {
                return Just(value)
                    // snapshot?.value는 Firebase의 raw json형식으로 제공되므로 JSONSerialization을 통해 Data로 변환
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: UserObject.self, decoder: JSONDecoder())  // 변환된 Data를 UserObject로 변환
                    .mapError { DBError.error($0) }     // 디코딩 또는 직렬화 과정에서 발생하는 에러를 DBError.error로 매핑하여 반환
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .userNotFound).eraseToAnyPublisher()
            }
        }
        // 반환 타입을 AnyPublisher로 변환하여, 호출자가 세부 구현을 알 필요 없도록 한다
        .eraseToAnyPublisher()
    }
    
    func updateUser(_ object: UserObject) -> AnyPublisher<Void, DBError> {
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .flatMap { value in
                Future<Void, DBError> { [weak self] promise in
                    // 업데이트할 필드들을 딕셔너리로 설정
                    let updates: [String: Any?] = [
                        "nickname": object.nickname,
                    ].compactMapValues { $0 } // nil 값은 제외

                    self?.db.child(DBKey.Users).child(object.id).updateChildValues(updates as [AnyHashable : Any]) { error, _ in
                        if let error = error {
                            promise(.failure(DBError.error(error))) // DBError로 변환
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                    // DB에 해당 유저정보가 없는걸 체크할때 없으면 nil이 아닌 NSNULL을 갖고있기 떄문에 NSNULL일경우 nil을 아웃풋으로 넘겨줌
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        // 딕셔너리형태(userID: Userobject) -> 배열형태
        .flatMap { value in
            if let dic = value as? [String: [String: Any]] {
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0)}
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder()) // 형식
                    .map { $0.values.map {$0 as UserObject} }
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}



