//
//  PromptDBRepository.swift
//  EUMMEYO
//
//  Created by 김동현 on 2/11/25.
//

import Combine
import FirebaseDatabase

enum PromptDBError: Error {
    case error(Error)
    case dataNotFound          // 데이터가 없는 경우
}

protocol PromptDBRepositoryType {
    func getPrompt() -> AnyPublisher<String, PromptDBError>
}

final class PromptDBRepository: PromptDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference()
    
    // 프롬포트 가져오기
    func getPrompt() -> AnyPublisher<String, PromptDBError> {
        Future<String, PromptDBError> { [weak self] promise in
            self?.db.child("Prompts").getData { error, snapshot in
                if let error = error {
                    // Firebase 요청 중 에러 발생시
                    promise(.failure(PromptDBError.error(error)))
                } else {
                    // 성공시 데이터 가져오기
                    promise(.success(snapshot?.value as? String ?? "프로프트"))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

final class StubPromptDBRepository: PromptDBRepositoryType {
    func getPrompt() -> AnyPublisher<String, PromptDBError> {
        Empty().eraseToAnyPublisher()
    }
}
