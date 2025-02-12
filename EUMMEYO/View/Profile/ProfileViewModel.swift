//
//  ProfileViewModel.swift
//  EUMMEYO
//
//  Created by eunchanKim on 1/6/25.
//

import Foundation
import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    @AppStorage("jColor") private var jColor: Int = 0           // 잔디 색상 가져오기
    @Published var userInfo: User?
    @Published var tempNickname: String? //기존 닉네임 복원을 위한 임시 저장
    @Published var storedMemos: [Memo] = [] //초기 메모 데이터
    var userJandies: [Date: Int] = [:]
    var sortedJandies: [[Date]] = []
    
    private let userId: String
    private let container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    private let memoDBRepository = MemoDBRepository()
    
    // 공지사항 url
    var infoUrl = "https://ray-the-pioneer.notion.site/90ee757d57364b619006cabfdea2bff8?pvs=4"
    // 개인정보동의 url
    var policyUrl = "https://ray-the-pioneer.notion.site/1f0dcbdd5d934735b81a590398f8e70d?pvs=4"
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
    }
    
    func getUserInfo() {
        getUser()
        getMemo()
        getJandie()
    }

    func getUser() {
        container.services.userService.getUser(userId: userId)
            .sink { completion in
                switch completion {
                case .failure:
                    print("Error")
                case .finished:
                    print("Success")
                    
                }
            } receiveValue: { user in
                self.userInfo = user
                

            }.store(in: &subscriptions)
    }
    
    func getMemo() {
        memoDBRepository.fetchMemos(userId: self.userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("메모 가져오기 성공")
                case .failure(let error):
                    print("메모 가져오기 실패: \(error)")
                }
            }, receiveValue: { [weak self] memos in
                self?.storedMemos = memos
                self?.getJandie()
            })
            .store(in: &subscriptions)
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

    
    // MARK: - 유저 프로필 업데이트
    func updateUserProfile(nick: String, photo: String){
        // TODO: 여기에 닉네임/프로필사진/테두리 색의 변화가 한가지라도 있으면 바꿀건지 묻고 yes이면 update하기
        // 기존 닉네임을 tempNickname에 저장
        tempNickname = userInfo?.nickname
        
        // 새 닉네임을 즉시 반영
        userInfo?.nickname = nick
        userInfo?.profile = photo
        // 1. nickName update
        container.services.userService.updateUserProfile(userId: userId, nickName: nick, photo: photo)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("success")
                    self.tempNickname = nil
                    
                case .failure(let error):
                    print("닉네임 업데이트 실패: \(error)") // 오류 처리
                    // 실패 시 기존 닉네임 복원
                    self.userInfo?.nickname = self.tempNickname!
                    self.tempNickname = nil // 복원 후 tempNickname 초기화
                }
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
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
    
    
    // MARK: - 이미지로 변경하는 함수
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        // Decode Base64 string to Data
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        // Create UIImage from Data
        return UIImage(data: imageData)
    }
}

