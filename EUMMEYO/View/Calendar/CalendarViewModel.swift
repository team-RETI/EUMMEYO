//
//  CalendarViewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/29/24.
//

import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    private var container: DIContainer

    // var audioRecorderManager = AudioRecorderManager()
    var audioRecorderManager = AudioRecorderRepository()
    
    @AppStorage("jColor") private var jColor: Int = 0           // 잔디 색상 가져오기
    // MARK: - Boomarkview 관련
    @Published var searchText: String = ""              // 검색 필드 텍스트
    @Published var bookmarkedMemos: [Memo] = []         // 즐겨찾기된 메모
    
    // Combine에서 publisher를 구독 취소 가능한 작업 저장(searchText 변경사항을 모니터링 및 필터랑 작업 진행)
    var cancellables = Set<AnyCancellable>()
    
    /// evan
    @Published var user: User?                      // 사용자 별 메모 가져오기 위한 변수
    @Published var userId: String
    @Published var offsetX: CGFloat = 0
    
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
    
    // MARK: - 날짜별 메모 갯수 카운팅
    @Published var memoCountByDate: [String: Int] = [:]
    
    @Published var leadingEmptyDays: Int = 0 // 빈 칸 개수
    
    @Published var toggleButtonTapped: Bool = false {
        didSet {
            print("\(toggleButtonTapped ? "북마크 모드" : "검색 모드" )")
        }
    }
    @Published var isBookmark = false
    @Published var showDeleteMemoAlarm = false
    @Published var tempNickname: String? //기존 닉네임 복원을 위한 임시 저장
    
    // 공지사항 url
    var infoUrl = "https://ray-the-pioneer.notion.site/90ee757d57364b619006cabfdea2bff8?pvs=4"
    // 개인정보동의 url
    var policyUrl = "https://ray-the-pioneer.notion.site/1f0dcbdd5d934735b81a590398f8e70d?pvs=4"
    var userJandies: [Date: Int] = [:]
    var sortedJandies: [[Date]] = []
    
    var deleteTarget: String?
    
    var selectedMemo: Memo?
    
    // MARK: - 초기화
    init(container: DIContainer, userId: String){
        self.container = container
        self.userId = userId
        
        fetchCurrentWeek(for: Date())  // 현재 주간 날짜 초기화
        fetchCurrentMonth(for: Date())
        filterTodayMemos()  // 오늘 날짜의 메모 필터링
        
        
        // ✅ 검색어에 따라 필터링 적용
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterMemos()
            }
            .store(in: &cancellables)
        
        // 캘린더 한번 호출
        self.getUserMemos()
        
        // 북마크 한번 호출
        // print("한번출력")
        self.filterMemos()
        self.fetchBookmarkedMemos(userId: userId)
        
        
        // ✅ audioRecorderManager의 isRecording 변화를 감지해서 CalendarViewModel에 반영
        audioRecorderManager.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.isRecording = newValue
            }
            .store(in: &cancellables)
        
        audioRecorderManager.$uploadProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.uploadProgress = newValue
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
                    self.fetchMemos()
                    
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
                    self.storedMemos = []
                    self.filteredMemos = []
                    self.bookmarkedMemos = []
                case .finished:
                    print("메모 가져오기 성공")
                    
                }
            }, receiveValue: { [weak self] memos in
                DispatchQueue.main.async {
                    self?.storedMemos = memos.sorted(by: { $0.date > $1.date }) // 최신순 정렬
                    self?.cacheMemoCountByDate()
                    self?.filterTodayMemos()
                    self?.getJandie()
                }
            })
            .store(in: &cancellables)
    }
    // MARK: - 날짜 별 Memo 갯수 캐싱하는 함수
    func cacheMemoCountByDate() {
        var countDict: [String: Int] = [:]
        for memo in storedMemos {
            let date =  formatDate(memo.selectedDate ?? memo.date)
            countDict[date, default: 0] += 1
        }
        
        // 최대 3개까지만 저장
        for (key, value) in countDict {
            countDict[key] = min(value, 3)
        }
        memoCountByDate = countDict
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
                    self.fetchBookmarkedMemos(userId: self.userId)
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        
        
    }
    
    // MARK: - Memo 삭제 최종 함수
    func deleteMemo() {
        if let memoId = self.selectedMemo?.id {
            self.deleteMemo(memoId: memoId)
            if let url = self.selectedMemo?.voiceMemoURL {
                audioRecorderManager.deleteFileFromFirebase(userId: self.userId, fileName: url.lastPathComponent)
            }
        }
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
    
    // MARK: - 현재 월간 날짜를 계산하여 저장
    func fetchCurrentMonth(for date: Date) {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        
        currentMonth = range.map { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth)! }
        
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        leadingEmptyDays = weekday - 1
    }
    
    // MARK: - 현재 주간 날짜를 계산하여 저장
    // fix: iOS는 일요일부터 주간을 계산하여 오늘이 일요일이면 주간 범위가 다음주로 넘어가버리기 때문에 월요일을 주간의 첫날로 설정
    func fetchCurrentWeek(for date: Date) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
        currentWeek = (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
        currentDay = date
    }
    // MARK: - 날짜를 넘겨받아서 그 날짜에 해당하는 주/월로 변경
    func updateCalendar(to selectedDate: Date) {
        currentDay = selectedDate
        fetchCurrentWeek(for: selectedDate)
        fetchCurrentMonth(for: selectedDate)
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
        if storedMemos.filter({formatDate($0.selectedDate ?? $0.date) == formatDate(date)}).isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    func hasMemos(date: Date) -> Int {
        let key = formatDate(date)
        return memoCountByDate[key] ?? 0
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
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
    
    // MARK: - 사용량 업데이트 함수 수정
    func incrementUsage() {
        guard user != nil else { return }
        
        container.services.userService.updateUserCount(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("사용량 업데이트 성공")
                    self.getUser() // 업데이트된 사용자 정보 다시 가져오기
                case .failure(let error):
                    print("사용량 업데이트 실패: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: - 유저 잔디 업데이트 (2025년용 추후 연도별로 만들어야함)
    func getJandie() {
        var jandieArray: [Date: Int] = [:]
        var test = [Date: Int]()
        let calendar = Calendar.current
        let startDate = formatString("2025-01-01")

        var dates: [Date] = []
        var containedMemo: [Date] = []
        
        storedMemos.forEach { memo in containedMemo.append(memo.date) }
        jandieArray = countMemosByDate(jandies: containedMemo)
        
        for i in 0..<365 {
            let date = formatDate(calendar.date(byAdding: .day, value: i, to: startDate)!)
            dates.append(formatString(date))
            if jandieArray[formatString(date)] != nil {
                userJandies[formatString(date)] = jandieArray[formatString(date)]
            }
            else {
                test[formatString(date)] = 0
                userJandies[formatString(date)] = test[formatString(date)]
            }
        }
        // 1월 1일이 무슨 요일인지 확인
        let firstWeekday = (calendar.component(.weekday, from: startDate) + 5) % 7  // (월요일=0, 일요일=6)
        // 52주 * 7일 배열 초기화
        var gridDates = Array(repeating: Array(repeating: Date?.none, count: 53), count: 7)
        var weekIndex = 0
        var dayIndex = firstWeekday

        for date in dates {
            gridDates[dayIndex][weekIndex] = date
            // 다음 요일로 이동
            dayIndex += 1
            if dayIndex == 7 { // 일요일 -> 월요일로 변경
                dayIndex = 0
                weekIndex += 1
            }
        }
        // 1월 1일이 수요일이므로 월,화요일 배열 무효처리
        gridDates[0][0] = formatString("2024-12-30")
        gridDates[1][0] = formatString("2024-12-31")
        
        // 12월 31일 이후 목,금,토,일 배열 무효처리
        gridDates[3][52] = formatString("2026-1-1")
        gridDates[4][52] = formatString("2026-1-2")
        gridDates[5][52] = formatString("2026-1-3")
        gridDates[6][52] = formatString("2026-1-4")
        
        // Optional을 제거하고 반환
        sortedJandies = gridDates.map { $0.compactMap { $0 } }
    }
    
    // 색상 팔레트: 활동량에 따라 다르게 설정
    func color(for level: Int) -> Color {
        let jColor: Color = Color(hex: jColor)

        switch level {
        case 0: return jColor.opacity(0.1)
        case 1: return jColor.opacity(0.5)
        case 2: return jColor.opacity(0.7)
        case 3: return jColor.opacity(0.8)
        case 4: return jColor.opacity(0.9)
        default: return jColor
        }
    }
    func countMemosByDate(jandies: [Date]) -> [Date: Int] {
        var dateArray: [Date: Int] = [:]
        for jandie in jandies {
            let dateKey = formatDate(jandie) // String 일때 비교가능
            dateArray[formatString(dateKey), default: 0] += 1
        }
        return dateArray
    }
    
    // MARK: - 유저 프로필 업데이트
    func updateUserProfile(nick: String, photo: String){
        // TODO: 여기에 닉네임/프로필사진/잔디색의 변화가 한가지라도 있으면 바꿀건지 묻고 yes이면 update하기
        // 기존 닉네임을 tempNickname에 저장
//        tempNickname = userInfo?.nickname
        tempNickname = user?.nickname
        // 새 닉네임을 즉시 반영
//        userInfo?.nickname = nick
        user?.nickname = nick
//        userInfo?.profile = photo
        user?.profile = photo
        // 1. nickName update
        container.services.userService.updateUserProfile(userId: userId, nickName: nick, photo: photo)
            .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("success")
                    self.tempNickname = nil
                case .failure(let error):
                    print("닉네임 업데이트 실패: \(error)") // 오류 처리
                    // 실패 시 기존 닉네임 복원
//                    self.userInfo?.nickname = self.tempNickname!
                    self.user?.nickname = self.tempNickname!
                    self.tempNickname = nil // 복원 후 tempNickname 초기화
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    // MARK: - 날짜 비교 함수
    func calculateDaySince(_ registerDate: Date) -> Int {
        let currentDate = Date()
        let calendar = Calendar(identifier: .gregorian)
        var calendarInKorea = calendar
        calendarInKorea.timeZone = TimeZone(identifier: "Asia/Seoul")! // 한국 시간대 설정
        
        // 날짜 단위로 비교하여 차이를 계산
        let startOfRegisterDate = calendarInKorea.startOfDay(for: registerDate)
        let startOfCurrentDate = calendarInKorea.startOfDay(for: currentDate)
        
        let days = calendarInKorea.dateComponents([.day], from: startOfRegisterDate, to: startOfCurrentDate).day ?? 0
        return days
    }
    
    // MARK: - 일반 메모 저장 함수
    func saveTextMemo(memo: Memo, isSummary: Bool) {
        // 일반 메모 저장 시 GPT 요약하고 나서 저장
        
        if isSummary {
            // 요약모드 ON
            container.services.gptAPIService.summarizeContent(memo.content)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("GPT 요약 성공")
                    case .failure(let error):
                        print("GPT 요약 성공 실패: \(error)")
                    }
                }, receiveValue: { summary in
                    
                    let newMemo = Memo(
                        title: memo.title,
                        content: memo.content,
                        gptContent: summary,
                        date: Date(),
                        selectedDate: memo.selectedDate,
                        isVoice: memo.isVoice,
                        isBookmarked: false,
                        voiceMemoURL: self.audioRecorderManager.recordedFirebaseURL,
                        userId: self.userId
                    )
                    self.container.services.memoService.addMemo(newMemo)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                self.getUserMemos()
                                print("텍스트 요약모드 메모 저장 성공")
                            case .failure(let error):
                                print("텍스트 요약모드 메모 저장 실패 : \(error)")
                            }
                        }, receiveValue: {
                            self.incrementUsage()
                        })
                        .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
        } else {
            // 요약모드 OFF
            let newMemo = Memo(
                title: memo.title,
                content: memo.content,
                gptContent: nil,
                date: Date(),
                selectedDate: memo.selectedDate,
                isVoice: memo.isVoice,
                isBookmarked: false,
                voiceMemoURL: self.audioRecorderManager.recordedFirebaseURL,
                userId: self.userId
            )
            container.services.memoService.addMemo(newMemo)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.getUserMemos()
                        print("텍스트 메모 저장 성공")
                    case .failure(let error):
                        print("텍스트 메모 저장 실패 : \(error)")
                    }
                }, receiveValue: {})
                .store(in: &cancellables)
        }
    }
    
    // MARK: - 음성 메모 저장 함수
    func saveVoiceMemo(memo: Memo, isSummary: Bool) {
        if isSummary {
            // ✅ 요약 모드 ON: 음성 -> 텍스트 변환 후 GPT 요약
            guard let localURL = audioRecorderManager.recordedFileURL else {
                print("🔥 오류: 로컬 녹음 파일 URL 없음")
                return
            }

            container.services.gptAPIService.audioToTextGPT(url: localURL)
                .flatMap { [weak self] transcription -> AnyPublisher<(String, String), ServiceError> in
                    guard let self = self else {
                        return Fail(error: .invalidData).eraseToAnyPublisher()
                    }
                    // 🎯 transcription(변환된 텍스트)와 summary 둘 다 넘긴다
                        return self.container.services.gptAPIService.summarizeContent(transcription)
                            .map { summary in (transcription, summary) } // (원본, 요약) 튜플로 변환
                            .eraseToAnyPublisher()
                    // return self.container.services.gptAPIService.summarizeContent(transcription)
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("음성 메모 요약 성공")
                    case .failure(let error):
                        print("음성 메모 요약 실패: \(error)")
                    }
                }, receiveValue: { [weak self] transcription, summary in
                    guard let self = self else { return }
                    guard let uploadedURL = self.audioRecorderManager.recordedFirebaseURL else {
                        print("🔥 오류: 업로드된 Firebase URL 없음")
                        return
                    }

                    let newMemo = Memo(
                        title: memo.title,
                        content: transcription,
                        gptContent: summary,
                        date: Date(),
                        selectedDate: memo.selectedDate,
                        isVoice: true,
                        isBookmarked: false,
                        voiceMemoURL: uploadedURL,
                        userId: self.userId
                    )

                    self.container.services.memoService.addMemo(newMemo)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                self.getUserMemos()
                                print("🔥 음성 메모 (요약모드) 저장 성공")
                            case .failure(let error):
                                print("🔥 음성 메모 (요약모드) 저장 실패: \(error)")
                            }
                        }, receiveValue: {
                            self.incrementUsage()
                        })
                        .store(in: &self.cancellables)
                })
                .store(in: &cancellables)

        } else {
            // ✅ 요약 모드 OFF: 바로 저장
            guard let uploadedURL = audioRecorderManager.recordedFirebaseURL else {
                print("🔥 오류: 업로드된 Firebase URL 없음")
                return
            }

            let newMemo = Memo(
                title: memo.title,
                content: memo.content,
                gptContent: nil,
                date: Date(),
                selectedDate: memo.selectedDate,
                isVoice: true,
                isBookmarked: false,
                voiceMemoURL: uploadedURL,
                userId: self.userId
            )

            container.services.memoService.addMemo(newMemo)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.getUserMemos()
                        print("🔥 음성 메모 (요약 OFF) 저장 성공")
                    case .failure(let error):
                        print("🔥 음성 메모 (요약 OFF) 저장 실패: \(error)")
                    }
                }, receiveValue: {
                    self.incrementUsage()
                })
                .store(in: &cancellables)
        }
    }
    
    @Published var isRecording = false
    @Published var uploadProgress = 0.0

}

// MARK: - 주어진 날짜의 주 시각 날짜를 계산
extension Calendar {
    func startOfWeek(using date: Date = Date()) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

