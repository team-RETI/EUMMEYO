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
        NavigationView {
            VStack {
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
                                MemoCardView(memo: memo)
                            }
                        }
                        .padding()
                    }
                }
                
                // Spacer를 추가해 검색창을 위로 고정
                Spacer()
            }
            .onAppear {
                taskViewModel.filterMemos()
            }
        }
    }
    
    //     MARK: - MemoCardView (캘린더와 동일한 카드 스타일)
    func MemoCardView(memo: Memo) -> some View {
        NavigationLink(destination: MemoDetailView(memo: memo ,viewModel: taskViewModel, editMemo: memo.content, editTitle: memo.title)) {
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
                    Text(memo.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 15))
                    Button {
                        taskViewModel.isBookmark.toggle()
                        taskViewModel.toggleBookmark(memoId: memo.id, isBookmark: taskViewModel.isBookmark)
                    } label: {
                        Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                            .foregroundColor(memo.isBookmarked ? .mainPink : .mainGray)

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
        }
        .simultaneousGesture(
            LongPressGesture().onEnded { _ in
                taskViewModel.showDeleteMemoAlarm = true
            }
        )
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

struct test: View {
    var body: some View {
        Text("Hello, World!")
    }
}


// evan
struct BookmarkView_Previews: PreviewProvider {
    static let container: DIContainer = .stub
    
    static var previews: some View {
        BookmarkView(taskViewModel: .init(container: Self.container, userId: "user1_id"))
            .environmentObject(Self.container)
    }
}

//#Preview {
//    BookmarkView()
//        .environmentObject(CalendarViewModel(container: .stub, userId: "user1_id"))
//}
