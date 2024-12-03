//
//  viewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/29/24.
//

import SwiftUI
import Combine

final class TaskViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var bookmarkedMemos: [Memo] = []
    private var cancellables = Set<AnyCancellable>()
    
    func filterBookmarkedTasks() {
        DispatchQueue.global(qos: .userInteractive).async {
            let filtered = self.storedTasks.filter { task in
                task.isBookmarked && (self.searchText.isEmpty || task.title.localizedCaseInsensitiveContains(self.searchText))
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.bookmarkedMemos = filtered
                }
            }
        }
    }
    
    // Sample Tasks
    @Published var storedTasks: [Memo] = [
        Memo(title: "회의", content: "팀 작업 논의", date: makeDate(from: "2024-12-02 10:00"), isVoice: false, isBookmarked: false),
        Memo(title: "아이콘 편집", content: "팀 작업 아이콘 편집", date: makeDate(from: "2024-12-02 12:30"), isVoice: false, isBookmarked: false),
        Memo(title: "프로토타입 제작", content: "프로토타입 제작 및 전달", date: makeDate(from: "2024-12-02 14:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "죽어가는 학부생", content: "논문 준비를 위한 교수님과의 면담..", date: makeDate(from: "2024-12-03 10:00"), isVoice: true, isBookmarked: true),
        Memo(title: "swift 공부", content: "카페에서 패스트캠퍼스 swift 강의 듣기", date: makeDate(from: "2024-12-03 16:00"), isVoice: false, isBookmarked: true),
        Memo(title: "친구와 삼겹살 파티", content: "오늘 저녁 6시에 광안리에서 삼겹살 먹기", date: makeDate(from: "2024-12-03 18:00"), isVoice: true, isBookmarked: true),
        Memo(title: "음메요 개발 회의", content: "21시 음메요 앱 개발을 위한 회의 예정", date: makeDate(from: "2024-12-03 21:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "죽어가는 학부생", content: "논문 준비를 위한 교수님과의 면담..", date: makeDate(from: "2024-12-04 10:00"), isVoice: true, isBookmarked: true),
        Memo(title: "swift 공부", content: "카페에서 패스트캠퍼스 swift 강의 듣기", date: makeDate(from: "2024-12-04 16:00"), isVoice: false, isBookmarked: true),
        Memo(title: "친구와 삼겹살 파티", content: "오늘 저녁 6시에 광안리에서 삼겹살 먹기", date: makeDate(from: "2024-12-04 18:00"), isVoice: true, isBookmarked: true),
        Memo(title: "음메요 개발 회의", content: "21시 음메요 앱 개발을 위한 회의 예정", date: makeDate(from: "2024-12-04 21:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "죽어가는 학부생", content: "논문 준비를 위한 교수님과의 면담..", date: makeDate(from: "2024-12-05 10:00"), isVoice: true, isBookmarked: true),
        Memo(title: "swift 공부", content: "카페에서 패스트캠퍼스 swift 강의 듣기", date: makeDate(from: "2024-12-05 16:00"), isVoice: false, isBookmarked: true),
        Memo(title: "친구와 삼겹살 파티", content: "오늘 저녁 6시에 광안리에서 삼겹살 먹기", date: makeDate(from: "2024-12-05 18:00"), isVoice: true, isBookmarked: true),
        Memo(title: "음메요 개발 회의", content: "21시 음메요 앱 개발을 위한 회의 예정", date: makeDate(from: "2024-12-05 21:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "회의", content: "팀 작업 논의", date: makeDate(from: "2024-12-06 10:00"), isVoice: false, isBookmarked: true),
        Memo(title: "아이콘 편집", content: "팀 작업 아이콘 편집", date: makeDate(from: "2024-12-06 12:30"), isVoice: false, isBookmarked: false),
        Memo(title: "프로토타입 제작", content: "프로토타입 제작 및 전달", date: makeDate(from: "2024-12-06 14:00"), isVoice: false, isBookmarked: true),
        
    ]
        
    /// Helper function to create a `Date` from a string
    private static func makeDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 문자열 형식 지정
        formatter.locale = Locale(identifier: "en_US_POSIX") // 정확한 날짜 파싱을 위해 설정
        
        return formatter.date(from: string) ?? Date() // 문자열을 Date로 변환 (실패 시 현재 시간 반환)
    }

    
    // MARK: - Current Week Days
    @Published var currentWeek: [Date] = []
    
    // MARK: - Current Day
    @Published var currentDay: Date = Date()
    
    // MARK: - Filtering Today Tasks
    @Published var filteredTasks: [Memo]?
    
    // MARK: - Initializing
    init() {
        fetchCurrentWeek()
        filterTodayMemos()
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.filterBookmarkedTasks() }
            .store(in: &cancellables)
    }
    
    // MARK: - Filter Today Tasks
    func filterTodayMemos() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            let calendar = Calendar.current
            
            let filtered = self.storedTasks.filter {
                return calendar.isDate($0.date, inSameDayAs: self.currentDay)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.filteredTasks = filtered
                }
            }
        }
    }
    
    func fetchCurrentWeek() {
        // 현재 날짜 가져오기   2024년 11월 29일
        let today = Date()
        
        // 현재 달력 객체 가져오기
        let calendar = Calendar.current
        
        // 현재주 시작과 끝을 가져옴
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        // 주의 첫번째 날
        guard let firstWeekDay = week?.start else {
            return
        }
        
        // 7일 동안 날짜 계산
        (1...7).forEach { day in
            // 첫번째 날부터 day만큼 더한 날짜를 반환, 반환된 날짜를 currentWeek 배열에 추가
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: - 주어진 날짜를 특정 형식(String)으로 변환하여 반환(월, 화, 수, 목, 금)
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    // MARK: - Checking if current Date is Today
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: - Checking if the currentHour is task Hour
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
}

extension Calendar {
    func startOfWeek(using date: Date = Date()) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
