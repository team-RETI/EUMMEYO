//
//  CalendarViewModel.swift
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
    var cancellables = Set<AnyCancellable>()
    
    //fix?
    private let memoDBRepository = MemoDBRepository()
    
    /// evan
    @Published var user: User?                      // 사용자 별 메모 가져오기 위한 변수
    @Published var userId: String
    private var container: DIContainer
    
    // MARK: - 초기 메모 데이터
    @Published var storedMemos: [Memo] = []
    
    //MARK: - evan : 현재 달에 해당하는 날짜 리스트를 저장
    @Published var currentMonth: [Date] = []
    
    // MARK: - 현재 주에 해당하는 날짜 리스트를 저장
    @Published var currentWeek: [Date] = []
    
    // MARK: - 현재 날짜 저장
    @Published var currentDay: Date = Date()
    
    // MARK: - 현재 날짜에 해당하는 필터링된 메모 데이터를 저장
    @Published var filteredMemos: [Memo]?
    
    @Published var leadingEmptyDays: Int = 0 // 빈 칸 개수
    
    @Published var toggleButtonTapped: Bool = false {
        didSet {
            print("\(toggleButtonTapped ? "북마크 모드" : "검색 모드" )")
        }
    }
    
    @Published var isBookmark = false
    @Published var showDeleteMemoAlarm = false
    
    // MARK: - 초기화
    init(container: DIContainer, userId: String){
        self.container = container
        self.userId = userId
        
        fetchCurrentWeek()  // 현재 주간 날짜 초기화
        fetchCurrentMonth() // 현재 월간 날짜 초기화
        filterTodayMemos()  // 오늘 날짜의 메모 필터링
        fetchMonthData(for: Date())
        
        // ✅ 검색어에 따라 필터링 적용
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterMemos()
            }
            .store(in: &cancellables)
    }
    
    /// ✅ 북마크 모드 & 검색 모드 구분하여 필터링
    func filterMemos() {
        if toggleButtonTapped {
            // 북마크 모드 (검색어 없으면 전체 북마크 표시)
            if searchText.isEmpty {
                fetchBookmarkedMemos(userId: userId)
            } else {
                bookmarkedMemos = bookmarkedMemos.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
            }
            // bookmarkedMemos.sort(by: { $0.date < $1.date })
        } else {
            // 검색 모드 (검색어 없으면 전체 메모 표시)
            if searchText.isEmpty {
                fetchMemos()
            } else {
                storedMemos = storedMemos.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        // storedMemos.sort(by: { $0.date < $1.date })
    }
    
    // MARK: - User 프로필 형변환하는 함수 (String -> UIImage)
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        // Decode Base64 string to Data
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        // Create UIImage from Data
        return UIImage(data: imageData)
    }
    
    // MARK: - User별 메모 가져오는 함수
    func getUserMemos() {
        getUser()
        fetchMemos()
    }
    
    // MARK: - User정보 가져오는 함수
    func getUser() {
        container.services.userService.getUser(userId: userId)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink { completion in
                switch completion {
                case .failure:
                    print("Error")
                case .finished:
                    print("Success")
                }
            } receiveValue: { user in
                self.user = user
            }.store(in: &cancellables)
    }
    
    // MARK: - firebase에서 메모 가져오는 함수
    func fetchMemos() {
        container.services.memoService.fetchMemos(userId: userId)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("메모 가져오기 실패: \(error)")
                case .finished:
                    print("메모 가져오기 성공")
                }
            }, receiveValue: { [weak self] memos in
                DispatchQueue.main.async {
                    self?.storedMemos = memos.sorted(by: { $0.date > $1.date }) // 최신순 정렬
                    self?.filterTodayMemos()
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Memo 삭제하는 함수
    func deleteMemo(memoId: String) {
        container.services.memoService.deleteMemo(memoId: memoId)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("메모 삭제 실패: \(error)")
                case .finished:
                    print("메모 삭제 성공")
                    self.getUserMemos()
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    // MARK: - 새로운 메모 추가 메서드
    func addNewMemo(title: String, content: String, isVoice: Bool) {
        let newMemo = Memo(
            title: title,
            content: content,
            date: Date(), // 현재 시간으로 설정
            isVoice: isVoice,
            isBookmarked: false, // 기본값
            userId: userId // evan
        )
        storedMemos.append(newMemo)
    }
    
    // MARK: - 메모 업데이트(수정) ==> 날짜 관련한 에러가 있음
    func updateMemo(memoId: String, title: String, content: String) {
        container.services.gptAPIService.summarizeContent(content)
            .receive(on: DispatchQueue.main) // UI 업데이트를 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("메모 저장 성공")
                case .failure(let error):
                    print("메모 저장 실패: \(error)")
                }
            }, receiveValue: { [self] summary in
                container.services.memoService.updateMemo(memoId: memoId, title: title, content: content, gptContent: summary)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("메모 업데이트 성공")
                            self.getUserMemos()
                            self.fetchBookmarkedMemos(userId: self.userId)
                        case .failure(let error):
                            print("메모 업데이트 실패: \(error)")
                        }
                    }, receiveValue: { })
                    .store(in: &cancellables)
            }).store(in: &cancellables)
    }
    
    // MARK: - 즐겨찾기 토글
    func toggleBookmark(memoId: String, isBookmark: Bool) {
        container.services.memoService.toggleBookmark(memoId: memoId, currentStatus: isBookmark)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("즐겨찾기 상태 업데이트 성공 \(isBookmark)")
                    self.getUserMemos()
                    self.fetchBookmarkedMemos(userId: self.userId)
                case .failure(let error):
                    print("즐겨찾기 상태 업데이트 실패: \(error)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    // MARK: - 즐겨찾기된 메모만 가져오는 함수
    func fetchBookmarkedMemos(userId: String) {
        container.services.memoService.fetchBookmarkedMemos(userId: userId)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("즐겨찾기 메모 가져오기 성공")
                    self.getUserMemos()
                case .failure(let error):
                    print("즐겨찾기 메모 가져오기 실패: \(error)")
                }
            }, receiveValue: { [weak self] memos in
                self?.bookmarkedMemos = memos.sorted(by: { $0.date > $1.date })
            })
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
    
    // MARK: - evan : 현재 월간 날짜를 계산하여 저장
    /// 이번달의 날짜 범위를 구하는 함수
    func monthDayRange() -> Range<Date> {
        let currentMonth = Date()
        let calendar = Calendar.current
        
        let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)!
        return monthInterval.start..<calendar.date(byAdding: .month, value: 1, to: monthInterval.start)!
    }
    /// 이번달에 해당하는  날짜를 currentMonth 배열에 추가
    func fetchCurrentMonth() {
        let dateRange = monthDayRange()
        let calendar = Calendar.current
        
        /// 해당 월에 첫번째날 구하기
        var date = dateRange.lowerBound
        
        /// 해당월에 첫번째 날 부터 마지막날까지 반복 (.upperBound = 마지막날)
        while date < dateRange.upperBound {
            /// 배열에 추가
            currentMonth.append(date)
            
            /// 하루씩 증가시키기
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
    // MARK: - 해당 월의 날짜와 빈 칸 계산
    func fetchMonthData(for date: Date) {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        
        // 배열 초기화
        currentMonth = range.map { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth)! }
        
        // 시작 요일 계산 (월요일 기준)
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        //        leadingEmptyDays = (weekday + 5) % 6 //fix? 계산이 이상함
        leadingEmptyDays = weekday - 1
        // 25년 2월 기준 weekday가 7(토요일)이면 빈공간은 6이 필요
        // weekday가 1(일요일)이면 빈공간은 안필요 즉, weekday - 1 의 로직이면 됨
    }
    
    // MARK: - 현재 주간 날짜를 계산하여 저장
    // fix: iOS는 일요일부터 주간을 계산하여 오늘이 일요일이면 주간 범위가 다음주로 넘어가버리기 때문에 월요일을 주간의 첫날로 설정
    func fetchCurrentWeek() {
        // 현재 날짜 가져오기
        let today = Date()
        let calendar = Calendar.current
        
        // 오늘 날짜가 포함된 주간 시작일 계산
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        // 월요일부터 시작하도록 조정
        currentWeek = (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
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
    
    func hasMemo(date: Date)-> Bool {
        if storedMemos.filter({formatDate($0.date) == formatDate(date)}).isEmpty{
            return false
        }
        else {
            return true
        }
    }
    
    func hasMemos(date: Date)-> Int {
        var result: Int
        if storedMemos.filter({formatDate($0.date) == formatDate(date)}).count > 0 {
            result = storedMemos.filter({formatDate($0.date) == formatDate(date)}).count
            // 최대 3개까지만 저장
            if result > 3 {
                result = 3
            }
            return result
        }
        else {
            return 0
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    func formatString(_ date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        return formatter.date(from: date)!
    }
    
    // MARK: - 주어진 시간의 hour가 현재 시간과 동일한지 확인.
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
    
    // MARK: - 날짜 포맷팅 (한국 형식)
    func formatDateToKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d EEEEE a hh:mm"
        return formatter.string(from: date)
    }
    
    func formatDateForTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"
        
        if calendar.isDate(Date(), inSameDayAs: date) {
            return "Today"
        }
        else {
            return formatter.string(from: date)
        }
    }
}

// MARK: - 주어진 날짜의 주 시각 날짜를 계산
extension Calendar {
    func startOfWeek(using date: Date = Date()) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
