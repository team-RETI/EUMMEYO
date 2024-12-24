//
//  model.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/29/24.
//

import SwiftUI

// Task Model
//struct Memo: Identifiable {     // 데이터 항목을 고유하게 식별하기 위해 사용
//    var id = UUID().uuidString  // 고유한 문자열 생성
//    var taskTitle: String
//    var taskDescription: String
//    var taskDate: Date
//}

//// MARK: - Memo Model
//struct Memo: Identifiable {
//    var id = UUID().uuidString  // 고유한 문자열 생성
//    var title: String       // 요약한줄, 원한다면 수정 가능
//    var content: String     // 원본 메모
//    var date: Date        // 생성된 날짜 시간
//    var isVoice: Bool       // 일반메모인지 음성메모인지
//    var isBookmarked: Bool  // 즐겨찾기인지 아닌지
//}

// MARK: - Published를 위해 class로 바꿈
class Memo: Identifiable, ObservableObject {
    var id = UUID().uuidString
    var title: String
    var content: String
    var date: Date
    var isVoice: Bool
    @Published var isBookmarked: Bool

    init(title: String, content: String, date: Date, isVoice: Bool, isBookmarked: Bool) {
        self.title = title
        self.content = content
        self.date = date
        self.isVoice = isVoice
        self.isBookmarked = isBookmarked
    }
}

