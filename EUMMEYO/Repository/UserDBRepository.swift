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
    case error(Error)
    case emptyValue
    case invalidatedType
}

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
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
}



