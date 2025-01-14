//
//  BookmarkView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var taskViewModel: CalendarViewModel

    var body: some View {
        VStack {
            // 검색창
            TextField("검색어를 입력하세요", text: $taskViewModel.searchText)
                .padding()
                .background(
                    Color.white
                        .cornerRadius(10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1.5)
                        .foregroundColor(.black)
                )
                .padding(.horizontal) // 좌우 여백 추가
                .padding(.top, 30)

            
            // 즐겨찾기 리스트
            if taskViewModel.bookmarkedMemos.isEmpty {
                Text("즐겨찾기된 항목이 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(taskViewModel.bookmarkedMemos) { memo in
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
        .onAppear {
            taskViewModel.fetchBookmarkedMemos()
        }
    }

    // MARK: - MemoCardView (캘린더와 동일한 카드 스타일)
    func MemoCardView(memo: Memo) -> some View {
        HStack(alignment: .top, spacing: 30) {
                        
            Button {
                
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .center) {
                        
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle() // 원형 배경
                                    .fill(.black)
                                    .frame(width: 30, height: 30)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                        
                        Text(memo.gptContent!)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary) // 보조 색상(회색톤)
                    }
                    .hLeading()
                    Text(memo.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 15))
                }
            }
            // 현재시간이면 흰색 아니면 검은색
            .foregroundColor(taskViewModel.isCurrentHour(date: memo.date) ? .white : .black)
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

#Preview {
    BookmarkView()
        .environmentObject(CalendarViewModel())
}
