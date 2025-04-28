import Foundation
import Combine

protocol GPTAPIServiceType {
    func summarizeContent(_ content: String) -> AnyPublisher<String, ServiceError>
}

final class GPTAPIService: GPTAPIServiceType {

    private var dbRepository: GPTDBRepositoryType
    
    init(dbRepository: GPTDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    /// 서버에 저장된 프롬포트 받아오기
    /// - Returns: 프롬포트
    private func getPrompt() -> AnyPublisher<String, ServiceError> {
        dbRepository.getPrompt()
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    /// OpenAI API 요청
    /// - Parameter prompt: 프롬포트
    /// - Returns: AnyPublisher<요약된 내용, 에러>
    private func sendToGPT(_ prompt: String) -> AnyPublisher<String, ServiceError> {
        dbRepository.sendToGPT(prompt)
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }

    /// 메모 요약
    /// - Parameter content: 요약할 내용
    /// - Returns: AnyPublisher<요약된 내용, 에러>
    func summarizeContent(_ content: String) -> AnyPublisher<String, ServiceError> {
        return getPrompt()
            .flatMap { [weak self] promptTemplate -> AnyPublisher<String, ServiceError> in
                guard let self = self else {
                    return Fail(error: .invalidData).eraseToAnyPublisher()
                }
                
                let prompt = promptTemplate.replacingOccurrences(of: "{content}", with: content) + content
                // print(prompt)
                return self.sendToGPT(prompt)
            }
            .eraseToAnyPublisher()
    }
}
