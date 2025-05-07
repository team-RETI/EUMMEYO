//
//  Date+.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/28/25.
//

import Foundation

extension Date {
    
    /// self: 2025-05-04 -> "2025"
    var formattedYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    /// self: 2025-05-04 -> "5월"
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: self)
    }

    /// self: 2025-05-04 -> "May"
    var formattedMonthEng: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    /// self가 오늘이면 "Today", 아니면 "월요일", "화요일", ...
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
    
    /// self: 2025-05-04 11:30 -> "5.4 일요일 오전 11:30"
    var formattedKoreanDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d EEEEE a hh:mm"
        return formatter.string(from: self)
    }
    
    /// 요일을 "월", "화", "수" 형식으로 반환 (예: "수")
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    /// 이 날짜의 시간(hour)과 현재 시간과 같은지 여부 반환
    var isCurrentHour: Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
    
    /// self: 2025-05-04 -> "2025-05-04"
    var formattedStringYYYY_MM_dd: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

extension String {
    /// "yyyy-MM-dd" 형식의 문자열을 Date로 변환 (예: "2025-05-07" → Date)
    var formattedDateYYYY_MM_dd: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.date(from: self) ?? .now
    }
}
