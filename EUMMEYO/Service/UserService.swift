//
//  UserService.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import Foundation
import Combine

protocol UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError>
    func getUser(userId: String) -> AnyPublisher<User, ServiceError>
    func updateUserNickname(userId: String, nickname: String) -> AnyPublisher<Void, ServiceError>
    func checkNicknameDuplicate(_ nickname: String) -> AnyPublisher<Bool, ServiceError> 
}

final class UserService: UserServiceType {
    
    private var dbRepository: UserDBRepositoryType
    
    init(dbRepository: UserDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        dbRepository.addUser(user.toObject())
            .map { user }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        dbRepository.getUser(userId: userId)
            .map { $0.toModel() }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func updateUserNickname(userId: String, nickname: String) -> AnyPublisher<Void, ServiceError> {
        dbRepository.getUser(userId: userId)
            .mapError { ServiceError.error($0) } // DBError를 ServiceError로 변환
            .flatMap { userObject -> AnyPublisher<Void, ServiceError> in
                var updatedUserObject = userObject
                updatedUserObject.nickname = nickname // 닉네임 업데이트
                
                return self.dbRepository.updateUser(updatedUserObject)
                    .mapError { ServiceError.error($0) } // 반환된 AnyPublisher의 에러도 변환
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func checkNicknameDuplicate(_ nickname: String) -> AnyPublisher<Bool, ServiceError> {
        dbRepository.loadUsers()
            .map { users in
                users.contains { $0.nickname == nickname }
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}


