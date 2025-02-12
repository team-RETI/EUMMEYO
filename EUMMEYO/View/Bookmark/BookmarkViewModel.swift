//
//  BookmarkViewModel.swift
//  EUMMEYO
//
//  Created by 장주진 on 1/21/25.
//

import SwiftUI
import Combine

final class BookmarkViewModel: ObservableObject {

//    private let userId: String
//    private let container: DIContainer
//    private var subscriptions = Set<AnyCancellable>()
//    //evan
//    init(container: DIContainer, userId: String) {
//        self.container = container
//        self.userId = userId
//        print("bookmark initialized")
//    }
    
    // MARK: - 날짜 포맷팅 (한국 형식)
    func formatDateToKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

