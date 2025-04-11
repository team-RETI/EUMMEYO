//
//  BookmarkView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
//    @Binding var isDragging: Bool
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        withAnimation(.spring(duration: 0.5)) {
                            calendarViewModel.toggleButtonTapped.toggle()
                        }
                        // 진동 발생
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: calendarViewModel.toggleButtonTapped ? "star.fill" : "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.mainBlack)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.mainBlack)
                            }
                    }
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.bottom)
                
                // 검색창
                if !calendarViewModel.toggleButtonTapped {
                    TextField("검색어를 입력하세요", text: $calendarViewModel.searchText)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.mainBlack)
                                .frame(height: 50)
                        )
                        .padding(.horizontal)
                }
                
            }

            
            // ✅ 리스트 데이터를 먼저 변수에 저장하여 중복 방지
            let memos = calendarViewModel.toggleButtonTapped ? calendarViewModel.bookmarkedMemos : calendarViewModel.storedMemos
            
            if memos.isEmpty {
                Text(calendarViewModel.toggleButtonTapped ? "즐겨찾기된 항목이 없습니다." : "메모가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(memos) { memo in
                            NavigationLink {
                                MemoDetailView(memo: memo, editMemo: memo.content, editTitle: memo.title)
<<<<<<< HEAD
=======
                                    .environmentObject(calendarViewModel)
>>>>>>> refactor-#66
                            } label: {
                                MemoCardView(memo: memo)
                            }
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
        
        /* 최초 한번 실행을 위해 "viewModel 클래스의 생성자로 이동
        .onAppear {
            taskViewModel.filterMemos()
            taskViewModel.fetchBookmarkedMemos(userId: taskViewModel.userId)
        }
         */
    }
}

// preview
//struct BookmarkView_Previews: PreviewProvider {
//    static let container: DIContainer = .stub
//    
//    static var previews: some View {
//        BookmarkView(taskViewModel: .init(container: Self.container, userId: "user1_id"))
//            .environmentObject(Self.container)
//    }
//}

struct ScrollViewGestureButtonStyle: ButtonStyle {
    
    init(
        pressAction: @escaping () -> Void,
        doubleTapTimeoutout: TimeInterval,
        doubleTapAction: @escaping () -> Void,
        longPressTime: TimeInterval,
        longPressAction: @escaping () -> Void,
        endAction: @escaping () -> Void
    ) {
        self.pressAction = pressAction
        self.doubleTapTimeoutout = doubleTapTimeoutout
        self.doubleTapAction = doubleTapAction
        self.longPressTime = longPressTime
        self.longPressAction = longPressAction
        self.endAction = endAction
    }
    
    private var doubleTapTimeoutout: TimeInterval
    private var longPressTime: TimeInterval
    
    private var pressAction: () -> Void
    private var longPressAction: () -> Void
    private var doubleTapAction: () -> Void
    private var endAction: () -> Void
    
    @State
    var doubleTapDate = Date()
    
    @State
    var longPressDate = Date()
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                longPressDate = Date()
                if isPressed {
                    pressAction()
                    doubleTapDate = tryTriggerDoubleTap() ? .distantPast : .now
                    tryTriggerLongPressAfterDelay(triggered: longPressDate)
                } else {
                    endAction()
                }
            }
    }
}

private extension ScrollViewGestureButtonStyle {
    
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(doubleTapDate)
        guard interval < doubleTapTimeoutout else { return false }
        doubleTapAction()
        return true
    }
    
    func tryTriggerLongPressAfterDelay(triggered date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + longPressTime) {
            guard date == longPressDate else { return }
            longPressAction()
        }
    }
}
