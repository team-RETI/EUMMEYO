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
    
    /// 오늘이면 "Today", 아니면 요일(월, 화, ...)을 반환 (예: "Today" 또는 "화요일")
    var formattedWeekdayOrToday: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else {
            return formatter.string(from: self)
        }
    }
    
    /// 한국어 스타일로 날짜 및 시간 포맷 반환 (예: "5.4 일요일 오전 11:30")
    var formatDateToKorean: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d EEEEE a hh:mm"
        return formatter.string(from: self)
    }
}

