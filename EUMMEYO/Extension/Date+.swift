//
//  Date+.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/28/25.
//

import Foundation

extension Date {
    
    
    /// 현재 날짜에서 연도(yyyy)만 문자열로 반환 (예: "2025")
    var formattedYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    /// 현재 날짜에서 월(M월) 형식으로 반환 (예: "4월")
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: self)
    }

    /// 현재 날짜에서 영어 월(MMMM) 형식으로 반환 (예: "April")
    var formattedMonthEng: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
}
