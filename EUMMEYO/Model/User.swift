//
//  User.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import Foundation

struct User {
    var id: String                   // primary Key
    var nickname: String = ""        // 닉네임
    var loginPlatform: LoginPlatform // 로그인 플랫폼
    var registerDate: Date           // 가입일
    var jandies: [Jandie] = []       // 잔디: 항상 관리되는 데이터 (빈 배열로 초기화)
    var memos: [Memo] = []           // 메모: 항상 관리되는 데이터 (빈 배열로 초기화)
    
    var maxUsage: Int = 10           // 최대 요약 횟수
    var currentUsage: Int = 0        // 현재 요약 횟수
    var first: String = ""           // 여분용 변수
}

// MARK: - 앱애서 사용하는 User -> 데이터베이스에서 사용하는 UserObject
extension User {
    func toObject() -> UserObject {
        let formatter = ISO8601DateFormatter()                              // 날짜를 ISO8601 문자열로 변환
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")             // KST (UTC+9)
        return UserObject(
            id: id,
            nickname: nickname,
            loginPlatform: loginPlatform.rawValue,                          // 열거형 -> String
            registerDate: formatter.string(from: registerDate),             // Date -> String
            Jandies: jandies.map {
                [
                    "date": formatter.string(from: $0.date),                // Date -> String
                    "numOfMemo": "\($0.numOfMemo)"                          // Int -> String
                ]
            },
            memos: memos.map {
               [
                   "id": $0.id,
                   "title": $0.title,
                   "content": $0.content,
                   "date": formatter.string(from: $0.date),                 // Date -> String
                   "isVoice": String($0.isVoice),                           // Bool -> String
                   "isBookmarked": String($0.isBookmarked),                 // Bool -> String
                   "voiceMemoURL": $0.voiceMemoURL?.absoluteString ?? ""    // URL -> String
               ]
            },
            maxUsage: maxUsage,
            currentUsage: currentUsage,
            first: first)
    }
}

// MARK: - Codable채택 이유: 모든 속성을 Json으로 변환하거나 반대로 Json에서 값을 복원하는 작업을 자동으로 처리 가능
// JSONEncoder: 객체 → JSON
// JSONDecoder: JSON → 객체
struct UserObject: Codable {
    var id: String
    var nickname: String = ""
    var loginPlatform: String
    var registerDate: String
    var Jandies: [[String: String]]?
    var memos: [[String: String]]?
    
    var maxUsage: Int
    var currentUsage: Int
    var first: String
}

// MARK: - 데이터베이스에서 사용하는 UserObject -> 앱애서 사용하는 User
extension UserObject {
    func toModel() -> User {
        let formatter = ISO8601DateFormatter()                                  // 문자열 -> Date로 변환
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")                 // KST (UTC+9)
        return User(
            id: id,
            nickname: nickname,
            loginPlatform: LoginPlatform(rawValue: loginPlatform) ?? .google,   // String -> 열거형
            registerDate: formatter.date(from: registerDate) ?? Date(),
            jandies: Jandies?.compactMap { dict in
                guard let dateString = dict["date"],                            // date값 가져오기
                      let date = formatter.date(from: dateString),              // String -> Date
                      let numOfMemo = Int(dict["numOfMemo"] ?? "0")             // String -> Int
                else {return nil}
                return Jandie(date: date, numOfMemo: numOfMemo)
            } ?? [],
            memos: memos?.compactMap { dict in
                guard
                    let id = dict["id"],
                    let title = dict["title"],
                    let content = dict["content"],
                    let dateString = dict["date"],
                    let date = formatter.date(from: dateString),                // String -> Date
                    let isVoice = Bool(dict["isVoice"] ?? "false"),             // String -> Bool
                    let isBookmarked = Bool(dict["isBookmarked"] ?? "false")    // String -> Bool
                else { return nil }
                
                let voiceMemoURL = dict["voiceMemoURL"].flatMap { URL(string: $0) } // String -> URL
                return Memo(id: id, title: title, content: content, date: date, isVoice: isVoice, isBookmarked: isBookmarked, voiceMemoURL: voiceMemoURL)
            } ?? [],
            maxUsage: maxUsage,
            currentUsage: currentUsage,
            first: first
        )
    }
}

enum LoginPlatform: String {
    case apple = "Apple"
    case google = "Google"
}

struct Jandie {
    var date: Date
    var numOfMemo: Int
}

struct Notice {
    var date: String
    var title: String
    var content: String
}

// MARK: - Memo Model
// MARK: - 데이터를 외부에 전송하거나 저장해야 하는경우 UUID().uuidString 사용한다.
struct Memo: Identifiable {
    var id = UUID().uuidString  // 고유한 문자열 생성()
    var title: String           // 요약한줄, 원한다면 수정 가능
    var content: String         // 원본 메모
    var date: Date              // 생성된 날짜 시간
    var isVoice: Bool           // 일반메모인지 음성메모인지
    var isBookmarked: Bool      // 즐겨찾기인지 아닌지
    var voiceMemoURL: URL?      // 음성 파일의 저장 위치 (Optional)
}


// MARK: - 데이터베이스로 전달 예시
let userObject = UserObject(
    id: "12345",
    nickname: "Donghyun",
    loginPlatform: "Apple",
    registerDate: "2024-12-22",
    Jandies: [
        ["date": "2024-12-21T00:00:00Z", "numOfMemo": "5"],
        ["date": "2024-12-22T00:00:00Z", "numOfMemo": "3"],
        ["date": "2024-12-23T00:00:00Z", "numOfMemo": "8"]
    ],
    memos: [
        ["id": "m1", "title": "First Memo", "content": "Content 1", "date": "2024-12-22T12:00:00Z", "isVoice": "true", "isBookmarked": "false"],
        ["id": "m2", "title": "Second Memo", "content": "Content 2", "date": "2024-12-23T14:30:00Z", "isVoice": "false", "isBookmarked": "true"],
        ["id": "m3", "title": "Third Memo", "content": "Content 3", "date": "2024-12-24T09:15:00Z", "isVoice": "true", "isBookmarked": "false"]
    ],
    maxUsage: 10,
    currentUsage: 5,
    first: ""
)

// MARK: - 디버깅용
extension User {
    // User를 출력 가능한 형식으로 변환
    func description() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정

        let jandiesDescription = jandies.map { jandie in
            "- Date(날짜): \(formatter.string(from: jandie.date)), Num of Memo(메모 개수): \(jandie.numOfMemo)"
        }.joined(separator: "\n")

        let memosDescription = memos.map { memo in
            """
            - ID(메모 아이디): \(memo.id)
              Title(제목): \(memo.title)
              Content(내용): \(memo.content)
              Date(생성 날짜): \(formatter.string(from: memo.date))
              Is Voice(음성 메모 여부): \(memo.isVoice)
              Is Bookmarked(즐겨찾기 여부): \(memo.isBookmarked)
            """
        }.joined(separator: "\n")

        return """
        User Information(사용자 정보):
        - ID(아이디): \(id)
        - Nickname(닉네임): \(nickname)
        - Login Platform(로그인 플랫폼): \(loginPlatform.rawValue)
        - Register Date(가입일): \(formatter.string(from: registerDate))
        - Max Usage(최대 사용 가능 횟수): \(maxUsage)
        - Current Usage(현재 사용 횟수): \(currentUsage)
        - Additional Info(기타 정보): \(first)
        - Jandies(잔디):
        \(jandiesDescription)
        - Memos(메모):
        \(memosDescription)
        """
    }
}

// MARK: - 디버깅용
extension UserObject {
    // UserObject를 출력 가능한 형식으로 변환
    /*
    func description() -> String {
        let jandiesDescription = Jandies.map { jandie in
            "- Date(날짜): \(jandie["date"] ?? "N/A"), Num of Memo(메모 개수): \(jandie["numOfMemo"] ?? "N/A")"
        }.joined(separator: "\n")

        let memosDescription = memos.map { memo in
            """
            - ID(메모 아이디): \(memo["id"] ?? "N/A")
              Title(제목): \(memo["title"] ?? "N/A")
              Content(내용): \(memo["content"] ?? "N/A")
              Date(생성 날짜): \(memo["date"] ?? "N/A")
              Is Voice(음성 메모 여부): \(memo["isVoice"] ?? "N/A")
              Is Bookmarked(즐겨찾기 여부): \(memo["isBookmarked"] ?? "N/A")
            """
        }.joined(separator: "\n")

        return """
        UserObject Information(사용자 데이터베이스 정보):
        - ID(아이디): \(id)
        - Nickname(닉네임): \(nickname)
        - Login Platform(로그인 플랫폼): \(loginPlatform)
        - Register Date(가입일): \(registerDate)
        - Max Usage(최대 사용 가능 횟수): \(maxUsage)
        - Current Usage(현재 사용 횟수): \(currentUsage)
        - Additional Info(기타 정보): \(first)
        - Jandies(잔디):
        \(jandiesDescription)
        - Memos(메모):
        \(memosDescription)
        """
    }
     */
}

// MARK: - 앱 내부 사용 예시
extension User {
    static var stub1: User {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정
        return User(id: "user1_id", nickname: "Index", loginPlatform: .google, registerDate: formatter.date(from: "2024-12-22T00:00:00+09:00") ?? Date())
    }
    
    static var stub2: User {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정

        return User(
            id: "user1_id",
            nickname: "Index",
            loginPlatform: .google,
            registerDate: formatter.date(from: "2024-12-22T00:00:00+09:00") ?? Date(), // Date 설정
            jandies: [
                Jandie(date: formatter.date(from: "2024-12-21T00:00:00+09:00") ?? Date(), numOfMemo: 5),
                Jandie(date: formatter.date(from: "2024-12-22T00:00:00+09:00") ?? Date(), numOfMemo: 3),
                Jandie(date: formatter.date(from: "2024-12-23T00:00:00+09:00") ?? Date(), numOfMemo: 8)
            ],
            memos: [
                Memo(
                    id: "m1",
                    title: "First Memo",
                    content: "This is the first memo.",
                    date: formatter.date(from: "2024-12-22T12:00:00+09:00") ?? Date(),
                    isVoice: true,
                    isBookmarked: false,
                    voiceMemoURL: URL(string: "file:///path/to/voiceMemo1.m4a") // 음성 메모 경로
                ),
                Memo(
                    id: "m2",
                    title: "Second Memo",
                    content: "This is the second memo.",
                    date: formatter.date(from: "2024-12-23T14:30:00+09:00") ?? Date(),
                    isVoice: false,
                    isBookmarked: true,
                    voiceMemoURL: nil // 일반 메모
                ),
                Memo(
                    id: "m3",
                    title: "Third Memo",
                    content: "This is the third memo.",
                    date: formatter.date(from: "2024-12-24T09:15:00+09:00") ?? Date(),
                    isVoice: true,
                    isBookmarked: false,
                    voiceMemoURL: URL(string: "file:///path/to/voiceMemo3.m4a") // 음성 메모 경로
                )
            ],
            maxUsage: 10,
            currentUsage: 5,
            first: "First stub data"
        )
    }
}

// MARK: - 데이터베이스로 전달 예시
extension UserObject {
    static var example: UserObject {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정
        
        return UserObject(
            id: "12345",
            nickname: "Donghyun",
            loginPlatform: "Apple",
            registerDate: formatter.string(from: formatter.date(from: "2024-12-22T00:00:00+09:00") ?? Date()),
            Jandies: [
                ["date": formatter.string(from: formatter.date(from: "2024-12-21T00:00:00+09:00") ?? Date()), "numOfMemo": "5"],
                ["date": formatter.string(from: formatter.date(from: "2024-12-22T00:00:00+09:00") ?? Date()), "numOfMemo": "3"],
                ["date": formatter.string(from: formatter.date(from: "2024-12-23T00:00:00+09:00") ?? Date()), "numOfMemo": "8"]
            ],
            memos: [
                ["id": "m1", "title": "First Memo", "content": "Content 1", "date": formatter.string(from: formatter.date(from: "2024-12-22T12:00:00+09:00") ?? Date()), "isVoice": "true", "isBookmarked": "false", "voiceMemoURL": "file:///path/to/voiceMemo1.m4a"],
                ["id": "m2", "title": "Second Memo", "content": "Content 2", "date": formatter.string(from: formatter.date(from: "2024-12-23T14:30:00+09:00") ?? Date()), "isVoice": "false", "isBookmarked": "true", "voiceMemoURL": ""],
                ["id": "m3", "title": "Third Memo", "content": "Content 3", "date": formatter.string(from: formatter.date(from: "2024-12-24T09:15:00+09:00") ?? Date()), "isVoice": "true", "isBookmarked": "false", "voiceMemoURL": "file:///path/to/voiceMemo3.m4a"]
            ],
            maxUsage: 10,
            currentUsage: 5,
            first: ""
        )
    }
}

