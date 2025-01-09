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

        // 3️⃣ 요청 바디 설정
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "당신은 텍스트를 한국어로 요약하는 도움을 주는 AI 비서입니다."],
                ["role": "user", "content": "다음을 한국어로 확실하게 요약해 주세요: \(content)"]
            ]
        ]

        // 4️⃣ JSON 변환
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ 요청 바디 생성 실패: \(error)")
            completion(nil)
            return
        }

        // 5️⃣ URLSession을 통한 요청
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
