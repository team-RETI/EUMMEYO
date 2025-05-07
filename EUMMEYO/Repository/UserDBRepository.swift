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
    func deleteUser(userId: String) -> AnyPublisher<Void, DBError> 
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
                    // print("불러온 사용자 데이터: \(String(describing: snapshot?.value))") // 디버깅 출력
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
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } // Dictionary로 변환
            .flatMap { value in
                Future<Void, DBError> { [weak self] promise in
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in
                        if let error = error {
                            promise(.failure(DBError.error(error)))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        print("사용자 목록 불러오기 요청") // 디버깅 출력 추가
        return Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).getData { error, snapshot in
                if let error = error {
                    print("데이터베이스 오류 발생: \(error.localizedDescription)") // 오류 메시지 출력
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    print("데이터베이스에 해당 유저 정보가 없습니다.") // 유저 정보 없음 출력
                    promise(.success(nil))
                } else {
                    print("데이터베이스에서 사용자 정보를 성공적으로 불러왔습니다.") // 성공 메시지 출력
                    promise(.success(snapshot?.value))
                }
            }
        }
        // 딕셔너리형태(userID: UserObject) -> 배열형태
        .flatMap { value in
            if let dic = value as? [String: [String: Any]] {
                //print("불러온 사용자 데이터 딕셔너리: \(dic)") // 불러온 데이터 출력
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder()) // 형식
                    .map { $0.values.map { $0 as UserObject } }
//                    .mapError { error in
//                        print("JSON 디코딩 오류: \(error.localizedDescription)") // 디코딩 오류 출력
//                        return DBError.error(error)
//                    }
                    .mapError { error in
                        print("JSON 디코딩 오류: \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("키 누락: \(key.stringValue), \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("타입 불일치: \(type), \(context.debugDescription)")
                            case .valueNotFound(let value, let context):
                                print("값 누락: \(value), \(context.debugDescription)")
                            case .dataCorrupted(let context):
                                print("데이터 손상: \(context.debugDescription)")
                            default:
                                print("디코딩 실패: \(error.localizedDescription)")
                            }
                        }
                        return DBError.error(error)
                    }

                    .eraseToAnyPublisher()
            } else if value == nil {
                print("불러온 데이터가 nil입니다.") // nil 데이터 출력
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
            } else {
                print("유효하지 않은 데이터 타입입니다.") // 유효하지 않은 타입 출력
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteUser(userId: String) -> AnyPublisher<Void, DBError> {
        Future { promise in
            self.db.child(DBKey.Users).child(userId).removeValue { error, _ in
                if let error = error {
                    promise(.failure(.error(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}



