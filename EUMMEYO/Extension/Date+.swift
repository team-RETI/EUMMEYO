//
//  Date+.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/28/25.
//

import Foundation

extension Date {
    var formattedYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: self)
    }

    var formattedMonthEng: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
}
