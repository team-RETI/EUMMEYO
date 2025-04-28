//
//  PromptDBRepository.swift
//  EUMMEYO
//
//  Created by 김동현 on 2/11/25.
//

import Combine
import FirebaseDatabase

enum GPTDBError: Error {
    case error(Error)
    case dataNotFound
    case dataParsingError    // 네트워크 요청 중 발생한 오류
    case networkError(Error) // JSON 응답을 파싱하는 중 발생한 오류
}

protocol GPTDBRepositoryType {
    func getPrompt() -> AnyPublisher<String, GPTDBError>
    func sendToGPT(_ prompt: String) -> AnyPublisher<String, GPTDBError>
}

final class GPTDBRepository: GPTDBRepositoryType {
    private let apiKey = Bundle.main.infoDictionary?["GptAPIKey"] as! String
    var db: DatabaseReference = Database.database().reference()
    
    /// 서버에 저장된 프롬포트 받아오기
    /// - Returns: 프롬포트
    func getPrompt() -> AnyPublisher<String, GPTDBError> {
        Future<String, GPTDBError> { [weak self] promise in
            self?.db.child("Prompts").getData { error, snapshot in
                if let error = error {
                    // Firebase 요청 중 에러 발생시
                    promise(.failure(GPTDBError.error(error)))
                } else {
                    // 성공시 데이터 가져오기
                    promise(.success(snapshot?.value as? String ?? "프로프트"))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// OpenAI API 요청
    /// - Parameter prompt: 프롬포트
    /// - Returns: AnyPublisher<요약된 내용, 에러>
    func sendToGPT(_ prompt: String) -> AnyPublisher<String, GPTDBError> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return Fail(error: .dataParsingError).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": prompt]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            return Fail(error: .dataParsingError).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { GPTDBError.networkError($0) }
            .flatMap { response -> AnyPublisher<String, GPTDBError> in
                
                guard String(data: response.data, encoding: .utf8) != nil else {
                    return Fail(error: .dataParsingError).eraseToAnyPublisher()
                }

                if let result = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                   let choices = result["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    return Just(content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .setFailureType(to: GPTDBError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: .dataParsingError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

final class StubPromptDBRepository: GPTDBRepositoryType {
    func getPrompt() -> AnyPublisher<String, GPTDBError> {
        Empty().eraseToAnyPublisher()
    }
    
    func sendToGPT(_ prompt: String) -> AnyPublisher<String, GPTDBError> {
        Empty().eraseToAnyPublisher()
    }
}
