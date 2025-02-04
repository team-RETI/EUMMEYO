import Foundation

final class GPTAPIService {
    private let apiKey = Bundle.main.infoDictionary?["GptAPIKey"] as! String

    func summarizeContent(_ content: String, completion: @escaping (String?) -> Void) {
        // 1️⃣ URL 설정
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ URL 생성 실패")
            completion(nil)
            return
        }

        // 2️⃣ 요청 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3️⃣ 기본 요약 스타일 설정 (concise)
        let defaultSummaryType = "concise"
        
        // 4️⃣ 요청 바디 설정
        let prompt = """
        당신은 한국어 요약 전문가입니다. 사용자가 제공한 내용을 주어진 요약 스타일에 맞춰 요약하세요.

        [요약 스타일]
        - concise: 핵심 내용만 짧고 명확하게 70자 이내로 요약합니다.
        - detailed: 중요한 정보는 유지하면서 비교적 자세히 요약합니다.
        - bullet_points: 정보를 핵심 포인트 위주로 정리해 요약합니다.
        - academic: 학술적으로 자연스럽고 논리적인 흐름을 유지하며 요약합니다.

        [요약 규칙]
        1. 불필요한 반복이나 군더더기 표현을 제거하세요.
        2. 본문의 핵심 메시지를 유지하세요.
        3. 사용자가 선택한 요약 스타일을 반영하세요.

        [입력 내용]
        \(content)
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": "요약 스타일: \(defaultSummaryType)"]
            ]
        ]

        // 5️⃣ JSON 변환
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ 요청 바디 생성 실패: \(error)")
            completion(nil)
            return
        }

        // 6️⃣ URLSession을 통한 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 요청 실패: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ 응답 데이터가 없음")
                completion(nil)
                return
            }

            // ✅ 응답 데이터 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ 응답 데이터(JSON): \(jsonString)")
            } else {
                print("❌ 응답 데이터를 문자열로 변환 실패")
            }

            // 🔍 기존 JSON 파싱 코드
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = result["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                print("❌ JSON 파싱 실패")
                completion(nil)
            }
        }.resume()
    }
}
