//
//  GPTService.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/7/25.
//

import Foundation

final class GPTAPIService {
    private let apiKey = "YOUR_API_KEY"  // 🔑 OpenAI API Key
    
    func summarizeContent(_ content: String, completion: @escaping (String?) -> Void) {
        // 1️⃣ URL 설정
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
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
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that summarizes text."],
                ["role": "user", "content": "Summarize the following: \(content)"]
            ]
        ]
        
        // 4️⃣ JSON 변환
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        // 5️⃣ URLSession을 통한 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // 6️⃣ 응답 처리
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = result["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(nil)
            }
        }.resume()
    }
}
