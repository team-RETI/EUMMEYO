//
//  CalendarViewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/29/24.
//

import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {

    @ObservedObject var memoStore: MemoStore
    @ObservedObject var userStore: AuthenticationViewModel
    @AppStorage("jColor") private var jColor: Int = 0
    var cancellables = Set<AnyCancellable>()
    private var container: DIContainer

    // 유저 뷰
    @Published var user: User?
    @Published var userId: String
    
    // 캘린더 뷰
    @Published var currentMonth: [Date] = []
    @Published var currentWeek: [Date] = []
    @Published var currentDay: Date = Date()
    @Published var leadingEmptyDays: Int = 0 // 빈 칸 개수
    @Published var offsetX: CGFloat = 0 // 제스쳐 용
    
    // 메모 뷰
    @Published var filteredMemos: [Memo]?
    @Published var memoCountByDate: [String: Int] = [:]

    init(container: DIContainer, userId: String, memoStore: MemoStore, userStore: AuthenticationViewModel){
        self.container = container
        self.userId = userId
        self.memoStore = memoStore
        self.userStore = userStore
        
        fetchCurrentWeek(for: Date())  // 현재 주 초기화
        fetchCurrentMonth(for: Date()) // 현재 월 초기화
        filterTodayMemos() // 메모 오늘것만 가져오기
        
        self.user = userStore.user ?? nil
        
        // 서버 변경 감시용
        self.observeMemos()
        self.observeDate()
        self.observeUser()
    }
    
    /// 서버의 메모 변경이 있는지 감시
    func observeMemos() {
        memoStore.$memoList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.cacheMemoCountByDate()
                self?.filterTodayMemos()
            }
            .store(in: &cancellables)
    }
    
    /// 서버의 메모 선택 날짜의 변경이 있는지 감시
    func observeDate() {
        memoStore.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.updateCalendar(to: date)
            }
            .store(in: &cancellables)
    }
    
    /// 서버의 유저 변경이 있는지 감시
    func observeUser() {
        userStore.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
    
    
    /// Firebase 유저 이미지를 받아서 UIImage로 변환
    /// - Parameter base64String: 문자열
    /// - Returns: UIImage
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    
    /// 날짜별 메모 갯수 캐싱
    func cacheMemoCountByDate() {
        var countDict: [String: Int] = [:]
        for memo in memoStore.memoList {
            let date =  (memo.selectedDate ?? memo.date).formattedStringYYYY_MM_dd
            countDict[date, default: 0] += 1
        }
        
        // 최대 3개까지만 저장
        for (key, value) in countDict {
            countDict[key] = min(value, 3)
        }
        memoCountByDate = countDict
    }

    /// 해당 날짜의 메모 캐싱
    func filterTodayMemos() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            let calendar = Calendar.current
            let filtered = self.memoStore.memoList.filter {
                if $0.selectedDate != nil {
                    return calendar.isDate($0.selectedDate!, inSameDayAs: self.currentDay)
                }
                return calendar.isDate($0.date, inSameDayAs: self.currentDay)
            }
            
            DispatchQueue.main.async {
                self.filteredMemos = filtered
            }
        }
    }
    
    /// 해당 날짜의 월간 뷰 캐싱
    func fetchCurrentMonth(for date: Date) {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        
        currentMonth = range.map { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth)! }
        
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        leadingEmptyDays = weekday - 1
    }
    
    /// 해당 날짜의 주간 뷰 캐싱
    func fetchCurrentWeek(for date: Date) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
        currentWeek = (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
        
        // 비동기적으로 상태 업데이트 (뷰 업데이트 이후)
        DispatchQueue.main.async {
            self.currentDay = date
        }
    }
    
    
    /// 선택한 날짜의 해당하는 일/주/월로 업데이트
    /// - Parameter selectedDate: 선택된 날짜
    func updateCalendar(to selectedDate: Date) {
        currentDay = selectedDate
        fetchCurrentWeek(for: selectedDate)
        fetchCurrentMonth(for: selectedDate)
    }
    
    
    /// 선택한 날짜가 오늘인지 확인용
    /// - Parameter date: 선택된 날짜
    /// - Returns: 참/거짓 판단
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    
    /// 선택한 날짜가 메모를 가지고 있는지 확인용
    /// - Parameter date: 선택된 날짜
    /// - Returns: 참/거짓 판단
    func hasMemo(date: Date)-> Bool {
        if memoStore.memoList.filter({($0.selectedDate ?? $0.date).formattedStringYYYY_MM_dd ==
            (date).formattedStringYYYY_MM_dd}).isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    /// 선택한 날짜의 메모 갯수 캐싱
    /// - Parameter date: 선택된 날짜
    /// - Returns: 메모 갯수
    func hasMemos(date: Date) -> Int {
        let key = date.formattedStringYYYY_MM_dd
        return memoCountByDate[key] ?? 0
    }

}
