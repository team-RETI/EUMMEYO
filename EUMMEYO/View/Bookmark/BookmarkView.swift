//
//  BookmarkView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct BookmarkView: View {
    @StateObject var taskViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        NavigationStack {
            HStack {
                // 검색창
                TextField("검색어를 입력하세요", text: $taskViewModel.searchText)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1.5)
                            .foregroundColor(.mainBlack)
                            .frame(height: 50)
                    )
                
                Button {
                    taskViewModel.filterMemos()
                    taskViewModel.toggleButtonTapped.toggle()
                    
             } label: {
                    
                Image(systemName: taskViewModel.toggleButtonTapped ? "bookmark" : "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.mainBlack)
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(.mainBlack)
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal) // 좌우 여백 추가
            .padding(.top, 30)
            
            
            // ✅ 리스트 데이터를 먼저 변수에 저장하여 중복 방지
            let memos = taskViewModel.toggleButtonTapped ? taskViewModel.bookmarkedMemos : taskViewModel.storedMemos
            
            if memos.isEmpty {
                Text(taskViewModel.toggleButtonTapped ? "즐겨찾기된 항목이 없습니다." : "메모가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(memos) { memo in
                            NavigationLink {
                                MemoDetailView(memo: memo ,viewModel: taskViewModel, editMemo: memo.content, editTitle: memo.title)
                                
                            } label: {
                                MemoCardView(memo: memo)
                            }
                            .buttonStyle(ScrollViewGestureButtonStyle(
                                pressAction: {
                                    print("Button Pressed")
                                },
                                doubleTapTimeoutout: 0.3, // Time interval for detecting double tap
                                doubleTapAction: {
                                    print("Double Tap Detected")
                                },
                                longPressTime: 1.0, // Time required for long press to trigger
                                longPressAction: {
                                    taskViewModel.showDeleteMemoAlarm = true
                                },
                                endAction: {
                                    print("Button Released")
                                }
                            ))
    
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .onAppear {
            taskViewModel.filterMemos()
        }
    }
    
    // MARK: - MemoCardView
    
    func MemoCardView(memo: Memo) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .center) {
                Image(systemName: memo.isVoice ? "mic" : "doc.text")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 12, height: 12)
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(.black)
                            .frame(width: 30, height: 30)
                    )
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(memo.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                Text(memo.gptContent ?? "요약 없음")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .hLeading()
            VStack {
                Text(memo.date.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 15))
                Button {
                    taskViewModel.isBookmark.toggle()
                    taskViewModel.toggleBookmark(memoId: memo.id, isBookmark: taskViewModel.isBookmark)
                } label: {
                    Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                        .foregroundColor(memo.isBookmarked ? .mainPink : .mainGray)
                        .padding(1)
                }
            }
        }
        .padding()
        .foregroundColor(taskViewModel.isCurrentHour(date: memo.date) && taskViewModel.isToday(date: memo.date) ? .mainWhite : .mainBlack)
        .background(
            Color.mainBlack
                .opacity(taskViewModel.isToday(date: memo.date) && taskViewModel.isCurrentHour(date: memo.date) ? 1 : 0)
        )
        .cornerRadius(25)
        .overlay {
            RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: 1)
                .foregroundColor(.mainBlack)
        }
//        .simultaneousGesture(
//            LongPressGesture().onEnded { _ in
//                taskViewModel.showDeleteMemoAlarm = true
//            }
//
//        )
        .alert(isPresented: $taskViewModel.showDeleteMemoAlarm) {
            Alert(
                title: Text("메모 삭제"),
                message: Text("정말로 메모를 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    taskViewModel.deleteMemo(memoId: memo.id)
                },
                secondaryButton: .cancel()
            )
        }
        .hLeading()
        
    }
}

// preview
struct BookmarkView_Previews: PreviewProvider {
    static let container: DIContainer = .stub
    
    static var previews: some View {
        BookmarkView(taskViewModel: .init(container: Self.container, userId: "user1_id"))
            .environmentObject(Self.container)
    }
}

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
