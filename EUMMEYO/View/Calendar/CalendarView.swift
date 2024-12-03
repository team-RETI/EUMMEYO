//  CalendatView.swift
//  EUMMEYO

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var currentMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var memos: [Memo] = [
        Memo(
            id: 0,
            title: "이마트에서 살 것",
            content: "텍스트 메모 내용",
            date: "2024-12-03 00:00:00",
            isVoice: false,
            isBookmarked: false
        ),
        Memo(
            id: 1,
            title: "딥러닝 1주차 수업 녹음",
            content: "음성 메모 내용",
            date: "2024-12-03 00:00:00",
            isVoice: true,
            isBookmarked: true
        ),
        Memo(
            id: 2,
            title: "오픽 1~3번 말하기 연습",
            content: "음성 메모 내용",
            date: "2024-12-03 00:00:00",
            isVoice: true,
            isBookmarked: false
        ),
        Memo(
            id: 3,
            title: "3시 회의 내용 정리",
            content: "텍스트 메모 내용",
            date: "2024-12-04 00:00:00",
            isVoice: false,
            isBookmarked: true
        ),
        Memo(
            id: 4,
            title: "음성 메모 제목",
            content: "음성 메모 내용",
            date: "2024-12-05 00:00:00",
            isVoice: true,
            isBookmarked: true
        ),
        Memo(
            id: 5,
            title: "텍스트 메모 제목",
            content: "텍스트 메모 내용",
            date: "2024-12-06 00:00:00",
            isVoice: false,
            isBookmarked: false
        )
    ]
    
    var body: some View {
        VStack {
            // 월 선택
            MonthSelectorView(selectedDate: $selectedDate, currentMonth: $currentMonth)
            
            // 캘린더
            MonthCalendarView(selectedDate: $selectedDate, currentMonth: $currentMonth)
                .frame(height: 220)
            
            Divider()
            
            // 메모 리스트
            MemoListView(selectedDate: $selectedDate, currentMonth: $currentMonth, memos: $memos)
                .frame(height: 130)
            
            Divider()
            
            // 세부 메모
            MemoDetailView()
        }
        .navigationTitle("Calendar & Memos")
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Month Selector View
struct MonthSelectorView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            // < 버튼
            Button(action: { moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
            }
            .padding()
            
            // 2024년 12월
            Text(currentMonthString())
                .font(.title3)
                .bold()
                .padding()
            
            // > 버튼
            Button(action: { moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom, 15)
    }
    
    private func moveMonth(by value: Int) {
        // Move to the new month
        currentMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth)!
        
        // Set the selectedDate to the 1st of the current month
        selectedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
    }
    
    private func currentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter.string(from: currentMonth)
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    private let calendar = Calendar(identifier: .gregorian)
    private let daysOfWeek = ["월", "화", "수", "목", "금", "토", "일"] // Week starts on Monday
    
    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let startWeekdayOffset = (calendar.component(.weekday, from: startOfMonth) + 5) % 7 // Adjust for Monday start
        return (0..<startWeekdayOffset).map { _ in Date.distantPast } + // Empty cells for alignment
        range.map { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)! }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Days of the Week Header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.bold)
                        .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .primary))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5)
            
            // Calendar Grid
            let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    if calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                        Color.clear.frame(maxHeight: 40) // Empty cell
                    } else {
                        Text("\(calendar.component(.day, from: date))")
                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .top) // Top-aligned text in the cell
                            .foregroundColor(
                                calendar.component(.weekday, from: date) == 1 ? .red :
                                    (calendar.component(.weekday, from: date) == 7 ? .blue : .primary)
                            )
                            .background(
                                isSelected(date) ? Color.yellow.opacity(0.5) : (isToday(date) ?  Color.gray.opacity(0.3) : Color.clear)
                            )
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)  // Ensure the entire grid is top-aligned within the container
    }
}

// MARK: - Memo List View
struct MemoListView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @Binding var memos: [Memo]
    
    var body: some View {
        List {
            ForEach(memosForSelectedDate, id: \.id) { memo in
                HStack {
                    // Memo Type Icon
                    Text(memo.isVoice ? "🎧" : "📝")
                    
                    // Memo Title
                    VStack(alignment: .leading) {
                        Text(memo.title)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Bookmark Icon with toggle action (clickable)
                    Button(action: {
                        toggleBookmark(for: memo)
                    }) {
                        Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                            .foregroundColor(memo.isBookmarked ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)
            }
            if memosForSelectedDate.isEmpty {
                Text("이 날짜에는 메모가 없습니다.")
                    .foregroundColor(.gray)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var memosForSelectedDate: [Memo] {
        memos.filter { isSameDay(memoDateString: $0.date, selectedDate: selectedDate) }
    }
    
    private func toggleBookmark(for memo: Memo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[index].isBookmarked.toggle()  // Toggle the bookmark value
        }
    }
    
    private func isSameDay(memoDateString: String, selectedDate: Date) -> Bool {
        // Parse memo date string to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let memoDate = dateFormatter.date(from: memoDateString) else { return false }
        
        // Compare day, month, and year
        return Calendar.current.isDate(memoDate, inSameDayAs: selectedDate)
    }
}

// MARK: - Memo Detail View
struct MemoDetailView: View {
    var memo: Memo = Memo(
        id: 0,
        title: "이마트에서 살 것",
        content: "메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다. 메모 내용입니다.",
        date: "2024-12-03 09:41:00",
        isVoice: false,
        isBookmarked: false
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(memo.title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text("\(formattedDate(from: memo.date))에 작성한")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if memo.isVoice {
                Text("음성 메모 (\(calculateVoiceMemoLength(from: memo.content)))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("텍스트 메모 (\(memo.content.count)자)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            ScrollView {
                Text(memo.content)
                    .font(.body)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Memo Details")
    }
    
    private func calculateVoiceMemoLength(from content: String) -> String {
        if let seconds = Int(content) {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)분 \(remainingSeconds)초"
        }
        return "Unknown length"
    }
    
    private func formattedDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일 H시 m분"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Memo
struct Memo: Identifiable, Codable {
    let id: Int // UUID()
    var title: String
    var content: String
    var date: String
    var isVoice: Bool
    var isBookmarked: Bool
}

#Preview {
    CalendarView()
}
