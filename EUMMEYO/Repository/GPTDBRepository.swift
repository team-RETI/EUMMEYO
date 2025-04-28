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
    case urlError
    case jsonEncodingError
    case badStatusError
}

protocol GPTDBRepositoryType {
    func getPrompt() -> AnyPublisher<String, GPTDBError>
    func sendToGPT(_ prompt: String) -> AnyPublisher<String, GPTDBError>
    func audioToTextGPT(url: URL) -> AnyPublisher<String, GPTDBError>
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
    
    /// 텍스트를 요약해주는 함수
    /// - Parameter prompt: 프롬포트
    /// - Returns: 요약된 내용
    func sendToGPT(_ prompt: String) -> AnyPublisher<String, GPTDBError> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return Fail(error: .urlError).eraseToAnyPublisher()
        }
        
        // header
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
            // 딕셔너리 -> json 직렬화
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            return Fail(error: .jsonEncodingError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { GPTDBError.networkError($0) } /// URLError -> GPTDBError.networkError(URLError)로 에러타입 형변환
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw GPTDBError.badStatusError
                }
                
                return data
            }
            .mapError {
                if let gptError = $0 as? GPTDBError {
                    return gptError
                } else {
                    return GPTDBError.error($0)
                }
            }
            .flatMap { data -> AnyPublisher<String, GPTDBError> in
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        return Just(content)
                            .setFailureType(to: GPTDBError.self)
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: GPTDBError.dataParsingError).eraseToAnyPublisher()
                    }
                } catch {
                    return Fail(error: GPTDBError.dataParsingError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// 음성 -> 텍스트로 변환하는 함수
    /// - Parameter url: 음성 URL
    /// - Returns: 텍스트
    func audioToTextGPT(url: URL) -> AnyPublisher<String, GPTDBError> {
        guard let audioData = try? Data(contentsOf: url) else {
            return Fail(error: .dataParsingError).eraseToAnyPublisher()
        }
        
        guard let requestURL = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
            return Fail(error: .urlError).eraseToAnyPublisher()
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // multipart body 구성
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        body.append("gpt-4o-transcribe\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n")
        body.append("text\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n")
        body.append("Content-Type: audio/m4a\r\n\r\n")
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n")
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { GPTDBError.networkError($0) }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw GPTDBError.badStatusError
                }
                
                print("📡 상태코드: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let errorBody = String(data: data, encoding: .utf8) {
                        print("❗️에러 응답 본문: \(errorBody)")
                    }
                    throw GPTDBError.badStatusError
                }
                
                guard let text = String(data: data, encoding: .utf8) else {
                    throw GPTDBError.dataParsingError
                }
                
                return text
            }
            .mapError {
                ($0 as? GPTDBError) ?? GPTDBError.error($0)
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
    
    func audioToTextGPT(url: URL) -> AnyPublisher<String, GPTDBError> {
        Empty().eraseToAnyPublisher()
    }
}

// MARK: - Data + Multipart Helper
extension Data {
    
    /// Swift의 Data 타입은 .append(Data)는 되지만 .append(String)은 기본적으로 지원하지 않는다
    /// multipart/form-data를 수동으로 만들고 있기 때문에 문자열을 Data로 바꿔서 붙여줘야 한다
    /// - Parameter string: multipart body
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
