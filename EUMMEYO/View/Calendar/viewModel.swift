//
//  viewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/29/24.
//

import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    
    // MARK: - Boomarkview 관련
    @Published var searchText: String = ""              // 검색 필드 텍스트
    @Published var bookmarkedMemos: [Memo] = []         // 즐겨찾기된 메모
    
    // Combine에서 publisher를 구독 취소 가능한 작업 저장(searchText 변경사항을 모니터링 및 필터랑 작업 진행)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 북마크된 메모만 필터링하여 bookmarkedMemos에 저장
    func filterBookmarkedMemos() {
        // 비동기작업(백그라운드에서 실행)
        DispatchQueue.global(qos: .userInteractive).async {
            let filtered = self.storedMemos.filter { memo in
                memo.isBookmarked && (self.searchText.isEmpty || memo.title.localizedCaseInsensitiveContains(self.searchText))
            }
            
            // 결과를 메인스레드에서 ui 업데이트
            DispatchQueue.main.async {
                withAnimation {
                    self.bookmarkedMemos = filtered
                }
            }
        }
    }

    // MARK: - 초기 메모 데이터(현재 하드코딩)
    @Published var storedMemos: [Memo] = [
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
        Memo(title: "정보보안 수업", content: "카페에서 패스트캠퍼스 swift 강의 듣기", date: makeDate(from: "2024-12-05 15:00"), isVoice: false, isBookmarked: true),
        Memo(title: "친구와 삼겹살 파티", content: "오늘 저녁 6시에 광안리에서 삼겹살 먹기", date: makeDate(from: "2024-12-05 18:00"), isVoice: true, isBookmarked: true),
        Memo(title: "음메요 개발 회의", content: "21시 음메요 앱 개발을 위한 회의 예정", date: makeDate(from: "2024-12-05 21:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "회의", content: "팀 작업 논의", date: makeDate(from: "2024-12-06 10:00"), isVoice: false, isBookmarked: true),
        Memo(title: "아이콘 편집", content: "팀 작업 아이콘 편집", date: makeDate(from: "2024-12-06 12:30"), isVoice: false, isBookmarked: false),
        Memo(title: "프로토타입 제작", content: "프로토타입 제작 및 전달", date: makeDate(from: "2024-12-06 14:00"), isVoice: false, isBookmarked: true),
        
        Memo(title: "정보보호 수업", content: "오늘 종강 수업", date: makeDate(from: "2024-12-10 10:00"), isVoice: true, isBookmarked: true),
        Memo(title: "Swift 공부", content: "카페에서 패스트캠퍼스 swift 강의 듣기", date: makeDate(from: "2024-12-10 15:00"), isVoice: false, isBookmarked: true),
        Memo(title: "친구와 삼겹살 파티", content: "오늘 저녁 6시에 광안리에서 삼겹살 먹기", date: makeDate(from: "2024-12-10 18:00"), isVoice: true, isBookmarked: true),
        Memo(title: "음메요 개발 회의", content: "21시 음메요 앱 개발을 위한 회의 예정", date: makeDate(from: "2024-12-10 21:00"), isVoice: false, isBookmarked: true),
        
    ]

    // MARK: - 현재 주에 해당하는 날짜 리스트를 저장
    @Published var currentWeek: [Date] = []
    
    // MARK: - 현재 날짜 저장
    @Published var currentDay: Date = Date()
    
    // MARK: - 월간 날짜 저장
    @Published var currentMonth: [Date] = []
    
    // MARK: - 현재 날짜에 해당하는 필터링된 메모 데이터를 저장
    @Published var filteredMemos: [Memo]?
    
    // MARK: - 초기화
    init() {
        fetchCurrentWeek()  // 현재 주간 날짜 초기화
        fetchCurrentMonth() // 현재 월간 날짜 초기화
        filterTodayMemos()  // 오늘 날짜의 메모 필터링
        
        // 텍스트가 변경될때 300ms 후 filterBookmarkedMemos 로출
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.filterBookmarkedMemos() }
            .store(in: &cancellables)
    }
    
    // MARK: - 문자열 -> Date 변환
    private static func makeDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 문자열 형식 지정
        formatter.locale = Locale(identifier: "en_US_POSIX") // 정확한 날짜 파싱을 위해 설정
        
        return formatter.date(from: string) ?? Date() // 문자열을 Date로 변환 (실패 시 현재 시간 반환)
    }
    
    // MARK: - 현재 날짜와 동일한 날짜를 가지는 메모만 필터링
    func filterTodayMemos() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            let calendar = Calendar.current
            
            let filtered = self.storedMemos.filter {
                return calendar.isDate($0.date, inSameDayAs: self.currentDay)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.filteredMemos = filtered
                }
            }
        }
    }
    
    // MARK: - 현재 주간 날짜를 계산하여 저장
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
    
    // MARK: - 현재 월간 날짜를 계산하여 저장
    func fetchCurrentMonth() {
            let today = Date()
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: today) else { return }

            var dates: [Date] = []
            var currentDate = monthInterval.start

            // 시작 요일 조정: 월요일부터 시작
            let weekday = calendar.component(.weekday, from: currentDate)
            let daysToSubtract = (weekday == 1 ? 6 : weekday - 2) // 일요일(1)이면 6일, 그 외엔 (weekday - 2)일 전으로 이동
            if let adjustedStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: currentDate) {
                currentDate = adjustedStart
            }

            // 월간 달력 데이터 생성
            while currentDate < monthInterval.end || calendar.component(.weekday, from: currentDate) != 2 {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }

            currentMonth = dates
        }
    
    
    // MARK: - 주어진 날짜를 특정 형식(String)으로 변환하여 반환(월, 화, 수, 목, 금)
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    // MARK: - 주어진 날짜가 오늘인지 확인
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: - 주어진 시간의 hour가 현재 시간과 동일한지 확인.
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
}

// MARK: - 주어진 날짜의 주 시각 날짜를 계산
extension Calendar {
    func startOfWeek(using date: Date = Date()) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
