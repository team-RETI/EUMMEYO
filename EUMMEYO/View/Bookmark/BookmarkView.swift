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
            
            // ✅ `toggleButtonTapped` 값에 따라 다른 리스트 표시
           if (taskViewModel.toggleButtonTapped ? taskViewModel.bookmarkedMemos : taskViewModel.storedMemos).isEmpty {
               Text(taskViewModel.toggleButtonTapped ? "즐겨찾기된 항목이 없습니다." : "메모가 없습니다.")
                   .foregroundColor(.gray)
                   .padding()
           } else {
               ScrollView {
                   LazyVStack(spacing: 15) {
                       ForEach(taskViewModel.toggleButtonTapped ? taskViewModel.bookmarkedMemos : taskViewModel.storedMemos) { memo in
                           MemoCardView(memo: memo)
                       }
                   }
                   .padding()
               }
           }

            // Spacer를 추가해 검색창을 위로 고정
            Spacer()
        }
        .navigationTitle("즐겨찾기")

    }
    
    // MARK: - MemoCardView (캘린더와 동일한 카드 스타일)
    private func MemoCardView(memo: Memo) -> some View {
        HStack(alignment: .top, spacing: 30) {
            
            Button {
                
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .center) {
                        
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.mainWhite) // 이미지 색상 설정
                            .padding()
                            .background(
                                Circle() // 원형 배경
                                    .fill(.mainBlack)
                                    .frame(width: 30, height: 30)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)

                        
                        Text(memo.gptContent ?? "요약 없음")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary) // 보조 색상(회색톤)
                            .lineLimit(2)

                    }
                    .hLeading()
                    Text(taskViewModel.formatDateToKorean(memo.date))
                        .font(.system(size: 15))
                        .foregroundColor(.mainBlack)
                }
            }
            // 현재시간이면 흰색 아니면 검은색
            .foregroundColor(taskViewModel.isCurrentHour(date: memo.date) ? .mainWhite : .mainBlack)
            .padding()
            .hLeading()
            .background(
                Color.mainBlack
                    .cornerRadius(25)
                    .opacity(taskViewModel.isCurrentHour(date: memo.date) ? 1 : 0)
            )
            // 테두리 추가
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(lineWidth: 1)
            }
        }
        .hLeading()
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
