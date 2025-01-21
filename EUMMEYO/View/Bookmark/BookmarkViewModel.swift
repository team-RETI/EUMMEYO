//
//  BookmarkViewModel.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/21/25.
//

import Foundation

final class BookmarkViewModel: ObservableObject {
    // MARK: - 날짜 포맷팅 (한국 형식)
    func formatDateToKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}


